

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE EXTENSION IF NOT EXISTS "pg_cron" WITH SCHEMA "pg_catalog";






CREATE EXTENSION IF NOT EXISTS "pg_net" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgsodium";






COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "wrappers" WITH SCHEMA "extensions";






CREATE TYPE "public"."admin_role" AS ENUM (
    'super_admin',
    'moderator',
    'support'
);


ALTER TYPE "public"."admin_role" OWNER TO "postgres";


CREATE TYPE "public"."campaign_status" AS ENUM (
    'pending',
    'active',
    'paused',
    'completed',
    'expired'
);


ALTER TYPE "public"."campaign_status" OWNER TO "postgres";


CREATE TYPE "public"."deliverable_category" AS ENUM (
    'social_media',
    'platform_review'
);


ALTER TYPE "public"."deliverable_category" OWNER TO "postgres";


CREATE TYPE "public"."deliverable_status" AS ENUM (
    'active',
    'disabled'
);


ALTER TYPE "public"."deliverable_status" OWNER TO "postgres";


CREATE TYPE "public"."enrollment_status" AS ENUM (
    'pending',
    'approved',
    'rejected',
    'invoiced',
    'paid',
    'expired',
    'withdrawn',
    'permanently_rejected'
);


ALTER TYPE "public"."enrollment_status" OWNER TO "postgres";


CREATE TYPE "public"."user_role" AS ENUM (
    'user',
    'admin',
    'editor',
    'manager',
    'super_admin'
);


ALTER TYPE "public"."user_role" OWNER TO "postgres";


CREATE TYPE "public"."user_status" AS ENUM (
    'active',
    'inactive',
    'suspended'
);


ALTER TYPE "public"."user_status" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."allocate_payment_to_invoices"("payment_id" bigint, "brand_id" bigint, "payment_amount" numeric) RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    remaining_amount DECIMAL(10,2) := payment_amount;
    invoice RECORD;
BEGIN
    -- Loop through unpaid invoices in FIFO order
    FOR invoice IN
        SELECT id, total_amount, amount_paid
        FROM invoices
        WHERE brand_id = brand_id  -- This should be the parameter
        AND status IN ('pending', 'partially_paid')
        ORDER BY created_at ASC
    LOOP
        -- If the remaining amount is zero, exit the loop
        IF remaining_amount <= 0 THEN
            EXIT;
        END IF;

        -- Determine the amount to allocate
        IF remaining_amount >= (invoice.total_amount - invoice.amount_paid) THEN
            -- Full payment for this invoice
            INSERT INTO invoice_payments (invoice_id, payment_id, amount, created_at)
            VALUES (invoice.id, payment_id, invoice.total_amount - invoice.amount_paid, CURRENT_TIMESTAMP);

            -- Mark invoice as completed
            UPDATE invoices 
            SET amount_paid = invoice.total_amount, status = 'paid'
            WHERE id = invoice.id;

            -- Deduct from remaining payment amount
            remaining_amount := remaining_amount - (invoice.total_amount - invoice.amount_paid);
        ELSE
            -- Partial payment for this invoice
            INSERT INTO invoice_payments (invoice_id, payment_id, amount, created_at)
            VALUES (invoice.id, payment_id, remaining_amount, CURRENT_TIMESTAMP);

            -- Update remaining invoice amount
            UPDATE invoices 
            SET amount_paid = amount_paid + remaining_amount,
                status = CASE 
                            WHEN amount_paid + remaining_amount >= total_amount THEN 'paid' 
                            ELSE 'partially_paid' 
                         END
            WHERE id = invoice.id;

            -- Set remaining amount to 0 (payment fully used)
            remaining_amount := 0;
        END IF;
    END LOOP;

    -- Handle excess payments
    IF remaining_amount > 0 THEN
        UPDATE payments
        SET excess_amount = remaining_amount
        WHERE id = payment_id;
    END IF;

END;
$$;


ALTER FUNCTION "public"."allocate_payment_to_invoices"("payment_id" bigint, "brand_id" bigint, "payment_amount" numeric) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."approve_or_reject_enrollment"("enrollment_id" bigint, "is_approved" boolean, "rejection_reason" "text" DEFAULT NULL::"text") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    IF is_approved THEN
        -- Approve the enrollment
        UPDATE public.enrollments
        SET status = 'approved', 
            approval_remarks = NULL, 
            rejection_count = 0,  -- Reset rejection count on approval
            created_at = NOW()  -- Update the created_at timestamp if needed
        WHERE id = enrollment_id;
    ELSE
        -- Reject the enrollment
        UPDATE public.enrollments
        SET rejection_count = rejection_count + 1  -- Increment rejection count
        WHERE id = enrollment_id;

        -- Check the rejection count
        IF (SELECT rejection_count FROM public.enrollments WHERE id = enrollment_id) = 1 THEN
            -- First rejection: increase expiration by 15 days
            UPDATE public.enrollments
            SET status = 'rejected', 
                approval_remarks = rejection_reason, 
                created_at = NOW(),  -- Update the created_at timestamp if needed
                expiration_date = expiration_date + INTERVAL '15 days'  -- Assuming there's an expiration_date column
            WHERE id = enrollment_id;
        ELSIF (SELECT rejection_count FROM public.enrollments WHERE id = enrollment_id) = 2 THEN
            -- Second rejection: set status to permanently rejected
            UPDATE public.enrollments
            SET status = 'permanently_rejected', 
                approval_remarks = rejection_reason, 
                created_at = NOW()  -- Update the created_at timestamp if needed
            WHERE id = enrollment_id;
        END IF;
    END IF;
END;
$$;


ALTER FUNCTION "public"."approve_or_reject_enrollment"("enrollment_id" bigint, "is_approved" boolean, "rejection_reason" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."auto_expire_campaigns"() RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Start a transaction
    BEGIN
        -- Expire campaigns based on expiration date and inactivity
        WITH expired_campaigns AS (
            UPDATE campaigns
            SET status = 'expired'
            WHERE (expiration_date <= NOW() OR 
                   (status = 'active' AND 
                    updated_at <= NOW() - INTERVAL '14 days' AND 
                    NOT EXISTS (SELECT 1 FROM enrollments WHERE campaign_id = campaigns.id AND status NOT IN ('expired', 'withdrawn', 'rejected'))))
            RETURNING id, brand_id
        )
        -- Log expiration in audit log
        INSERT INTO audit_logs (user_id, action, details, created_at)
        SELECT brand_id, 'Campaign Expired', 
               'Campaign ID ' || id || ' expired.', 
               NOW()
        FROM expired_campaigns;

        -- Insert in-app notifications for brands
        INSERT INTO notifications (user_id, message, is_read, created_at)
        SELECT brand_id, 
               'Your campaign has been automatically expired.', 
               FALSE, NOW()
        FROM expired_campaigns;

    EXCEPTION
        WHEN OTHERS THEN
            -- Handle any errors that occur
            RAISE NOTICE 'Error occurred while expiring campaigns: %', SQLERRM;
    END;
END;
$$;


ALTER FUNCTION "public"."auto_expire_campaigns"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."auto_expire_enrollment"() RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Start a transaction
    BEGIN
        -- Expire enrollments and log to audit logs
        WITH expired_enrollments AS (
            UPDATE enrollments 
            SET status = 'expired'
            WHERE status = 'pending' 
            AND created_at <= NOW() - INTERVAL '30 days'
            RETURNING id, shopper_id
        )
        INSERT INTO audit_logs (user_id, action, details, created_at)
        SELECT shopper_id, 'Enrollment Expired', 
               'Enrollment ID ' || id || ' was auto-expired after 30 days of inactivity.', 
               NOW()
        FROM expired_enrollments;

        -- Insert in-app notifications for expired enrollments
        INSERT INTO notifications (user_id, message, is_read, created_at)
        SELECT shopper_id, 'Your enrollment has expired due to inactivity for 30 days.', FALSE, NOW()
        FROM expired_enrollments;

    EXCEPTION
        WHEN OTHERS THEN
            -- Handle any errors that occur
            RAISE NOTICE 'Error occurred while auto-expiring enrollments: %', SQLERRM;
            -- Optionally, you can log the error to an error log table
    END;
END;
$$;


ALTER FUNCTION "public"."auto_expire_enrollment"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."auto_mark_overdue_invoices"() RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    overdue_invoice RECORD;
BEGIN
    -- Start a transaction
    BEGIN
        -- Update overdue invoices and insert notifications
        WITH overdue_invoices AS (
            UPDATE invoices
            SET status = 'overdue'
            WHERE status = 'pending'
            AND created_at <= NOW() - INTERVAL '7 days'
            RETURNING id, brand_id
        )
        -- Insert notifications for overdue invoices
        INSERT INTO notifications (user_id, message, is_read, created_at)
        SELECT brand_id, 
               'Your invoice (ID: ' || id || ') is overdue. Please make the payment immediately.', 
               FALSE, 
               NOW()
        FROM overdue_invoices;

    EXCEPTION
        WHEN OTHERS THEN
            -- Handle any errors that occur
            RAISE NOTICE 'Error occurred while marking overdue invoices: %', SQLERRM;
            -- Optionally, you can log the error to an error log table
    END;
END;
$$;


ALTER FUNCTION "public"."auto_mark_overdue_invoices"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."auto_refund_excess_payments"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE 
    total_outstanding NUMERIC;
    excess_amount NUMERIC;
BEGIN
    -- Calculate total unpaid invoice amount for the brand
    SELECT COALESCE(SUM(remaining_amount), 0)
    INTO total_outstanding
    FROM invoices
    WHERE brand_id = NEW.brand_id
    AND status = 'pending';

    -- Check if the payment exceeds outstanding invoices
    IF NEW.amount_paid > total_outstanding THEN
        excess_amount := NEW.amount_paid - total_outstanding;

        -- Only process refund if excess amount is greater than zero
        IF excess_amount > 0 THEN
            -- Insert refund record in payments table
            INSERT INTO payments (brand_id, amount_paid, payment_type, status, created_at)
            VALUES (NEW.brand_id, excess_amount, 'refund', 'processed', NOW());

            -- Log the refund in audit logs
            INSERT INTO audit_logs (user_id, action, details, created_at)
            VALUES (NEW.brand_id, 'Excess Payment Refunded', 
                    'Refund of INR ' || excess_amount || ' initiated for excess payment.', NOW());
        END IF;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."auto_refund_excess_payments"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_brand_approval"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Check if the brand is approved
    IF NOT EXISTS (
        SELECT 1 FROM public.brand_profiles WHERE id = NEW.brand_id AND admin_approved = true
    ) THEN
        RAISE EXCEPTION 'Brand is not approved. Cannot launch campaign.';
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."check_brand_approval"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_brand_integrations"("brand_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    brand RECORD;
    razorpay_api_key TEXT;
    zoho_auth_token TEXT;
    razorpay_response JSONB;
    zoho_response JSONB;
    virtual_account JSONB;
    customer_id TEXT;
BEGIN
    -- Fetch Razorpay API Key and Zoho Auth Token from Vault
    SELECT vault.get_secret('RAZORPAY_API_KEY') INTO razorpay_api_key;
    SELECT vault.get_secret('ZOHO_AUTH_TOKEN') INTO zoho_auth_token;

    -- Fetch brand details
    SELECT * INTO brand FROM public.brand_profiles WHERE id = brand_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Brand ID % not found.', brand_id;
    END IF;

    -- Create Virtual Account on Razorpay
    SELECT pg_net.http_post(
        url := 'https://api.razorpay.com/v1/virtual_accounts',
        headers := jsonb_build_object(
            'Authorization', 'Basic ' || encode(razorpay_api_key::bytea, 'base64'),
            'Content-Type', 'application/json'
        ),
        body := jsonb_build_object(
            'name', brand.brand_name,
            'description', 'Virtual Account for ' || brand.brand_name,
            'type', 'current',
            'receivers', jsonb_build_array(jsonb_build_object('types', 'upi,bank_account')),
            'close_by', NULL,
            'notes', jsonb_build_object('brand_id', brand_id)
        )
    ) INTO razorpay_response;

    -- Extract virtual account details if successful
    IF razorpay_response->>'id' IS NOT NULL THEN
        virtual_account := razorpay_response;
        UPDATE public.brand_profiles
        SET razorpay_va_id = virtual_account->>'id',
            razorpay_va_number = virtual_account->'receivers'->0->>'account_number',
            razorpay_va_ifsc = virtual_account->'receivers'->0->>'ifsc',
            razorpay_va_upi_id = virtual_account->'receivers'->0->>'upi_id'
        WHERE id = brand_id;
    ELSE
        RAISE EXCEPTION 'Failed to create Razorpay Virtual Account: %', razorpay_response;
    END IF;

    -- Create Zoho Books Customer
    SELECT pg_net.http_post(
        url := 'https://www.zohoapis.com/books/v3/customers',
        headers := jsonb_build_object(
            'Authorization', 'Zoho-oauthtoken ' || zoho_auth_token,
            'Content-Type', 'application/json'
        ),
        body := jsonb_build_object(
            'customer_name', brand.brand_name,
            'company_name', brand.company_name,
            'contact_persons', jsonb_build_array(jsonb_build_object(
                'email', brand.accounts_email,
                'phone', brand.phone_number
            )),
            'billing_address', jsonb_build_object(
                'attention', brand.contact_person,
                'address', brand.business_address,
                'city', brand.city,
                'state', brand.state,
                'zip', brand.postal_code
            ),
            'gst_treatment', 'business_gst',
            'gst_no', brand.gst_number
        )
    ) INTO zoho_response;

    -- Extract customer ID if successful
    IF zoho_response->>'customer_id' IS NOT NULL THEN
        customer_id := zoho_response->>'customer_id';
        UPDATE public.brand_profiles
        SET zoho_books_id = customer_id
        WHERE id = brand_id;
    ELSE
        RAISE EXCEPTION 'Failed to create Zoho Books Customer: %', zoho_response;
    END IF;

    -- Log success in audit logs
    INSERT INTO public.audit_logs (user_id, action, details, created_at)
    VALUES (
        NULL, 
        'BRAND_INTEGRATION_SUCCESS', 
        'Successfully created Razorpay VA and Zoho Books Customer for Brand ID ' || brand_id, 
        NOW()
    );

END;
$$;


ALTER FUNCTION "public"."create_brand_integrations"("brand_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_payouts_for_invoice"("invoice_id" bigint) RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    enrollments_count INT;
BEGIN
    -- Ensure the invoice exists
    IF NOT EXISTS (SELECT 1 FROM public.invoices WHERE id = invoice_id) THEN
        RAISE EXCEPTION 'Invoice ID % does not exist.', invoice_id;
    END IF;

    -- Insert payouts for eligible enrollments
    INSERT INTO public.payouts (enrollment_id, shopper_id, amount, status, created_at, order_id)
    SELECT 
        e.id, 
        e.shopper_id, 
        e.total_rebate, 
        'initiated',  -- Mark payouts as initiated
        NOW(), 
        e.order_id
    FROM public.invoice_enrollments ie
    JOIN public.enrollments e ON ie.enrollment_id = e.id
    WHERE ie.invoice_id = invoice_id
      AND e.status = 'invoiced'  
      AND e.order_id IS NOT NULL 
      AND e.expiry_date >= NOW() 
      AND e.total_rebate > 0 
      AND EXISTS (SELECT 1 FROM public.deliverable_submissions ds WHERE ds.enrollment_id = e.id)
      AND NOT EXISTS (SELECT 1 FROM public.payouts p WHERE p.enrollment_id = e.id AND p.order_id = e.order_id);

    -- Get count of processed enrollments
    GET DIAGNOSTICS enrollments_count = ROW_COUNT;

    -- If at least one payout was created, update the enrollments & invoice
    IF enrollments_count > 0 THEN
        -- Mark enrollments as 'paid'
        UPDATE public.enrollments
        SET status = 'paid'
        WHERE id IN (
            SELECT enrollment_id FROM public.invoice_enrollments WHERE invoice_id = invoice_id
        ) AND status = 'invoiced';

        -- Mark invoice as payout processed
        UPDATE public.invoices
        SET payout_processed = TRUE
        WHERE id = invoice_id;
    END IF;

    -- Log audit event
    INSERT INTO public.audit_logs (user_id, action, details, created_at)
    VALUES (
        NULL,
        'PAYOUTS_CREATED',
        'Processed ' || enrollments_count || ' payouts for invoice ID ' || invoice_id,
        NOW()
    );

EXCEPTION
    WHEN OTHERS THEN
        -- Log error
        INSERT INTO public.audit_logs (user_id, action, details, created_at)
        VALUES (
            NULL,
            'PAYOUTS_CREATION_FAILED',
            'Failed to process payouts for invoice ID ' || invoice_id || ' - Error: ' || SQLERRM,
            NOW()
        );
        -- Raise error
        RAISE;
END;
$$;


ALTER FUNCTION "public"."create_payouts_for_invoice"("invoice_id" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."enforce_one_time_coupon"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    is_one_time BOOLEAN;
BEGIN
    -- Check if the coupon exists and if it is a one-time use coupon
    SELECT one_time_use INTO is_one_time FROM coupons WHERE id = NEW.coupon_id;

    -- If the coupon is one-time use, check if it has already been redeemed
    IF is_one_time IS TRUE THEN
        IF EXISTS (
            SELECT 1 FROM coupon_redemptions
            WHERE coupon_id = NEW.coupon_id
            AND shopper_id = NEW.shopper_id
            AND status = 'successful'
        ) THEN
            RAISE EXCEPTION 'This coupon has already been redeemed by the shopper.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."enforce_one_time_coupon"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."expire_coupons"() RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Expire old coupons
    UPDATE coupons 
    SET status = 'expired'
    WHERE status = 'active' 
    AND expiration_date <= NOW();

    -- Optionally, log the expiration in an audit log
    INSERT INTO audit_logs (user_id, action, details, created_at)
    SELECT NULL, 'Coupons Expired', 
           'Expired coupons marked as inactive.', 
           NOW();

    -- Expire unused coupons
    UPDATE coupons 
    SET status = 'expired'
    WHERE status = 'active' 
    AND id NOT IN (SELECT coupon_id FROM coupon_redemptions WHERE status = 'successful');

    -- Optionally, log the expiration of unused coupons in an audit log
    INSERT INTO audit_logs (user_id, action, details, created_at)
    SELECT NULL, 'Unused Coupons Expired', 
           'Coupons that were not redeemed have been marked as expired.', 
           NOW();
END;
$$;


ALTER FUNCTION "public"."expire_coupons"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."generate_and_link_weekly_invoices"() RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    brand RECORD;
    invoice_id UUID;
    approved_enrollment_count integer;
BEGIN
    -- Start a transaction
    BEGIN
        -- Check for approved enrollments
        SELECT COUNT(*) INTO approved_enrollment_count
        FROM enrollments
        WHERE status = 'approved';

        IF approved_enrollment_count = 0 THEN
            RAISE NOTICE 'No approved enrollments found for invoicing.';
            RETURN;  -- Exit the function if there are no approved enrollments
        END IF;

        -- Loop through all brands with approved enrollments
        FOR brand IN
            SELECT DISTINCT brand_id
            FROM enrollments
            WHERE status = 'approved'
            AND id NOT IN (SELECT enrollment_id FROM invoice_enrollments)
        LOOP
            -- Create a new invoice for the brand
            INSERT INTO invoices (brand_id, status, created_at)
            VALUES (brand.brand_id, 'pending', NOW())
            RETURNING id INTO invoice_id;

            -- Attach all approved enrollments to the new invoice
            INSERT INTO invoice_enrollments (invoice_id, enrollment_id)
            SELECT invoice_id, id
            FROM enrollments
            WHERE brand_id = brand.brand_id
            AND status = 'approved'
            AND id NOT IN (SELECT enrollment_id FROM invoice_enrollments);

            -- Update the status of the enrollments to 'invoiced'
            UPDATE enrollments
            SET status = 'invoiced'
            WHERE brand_id = brand.brand_id
            AND status = 'approved';
        END LOOP;

        -- Commit the transaction
        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            -- Log the error in the audit_logs table
            INSERT INTO public.audit_logs (user_id, action, details, created_at)
            VALUES (NULL, 'Invoice Generation Error', 
                    'Error occurred while generating weekly invoices: ' || SQLERRM, 
                    NOW());
            ROLLBACK;  -- Rollback the transaction on error
            RAISE NOTICE 'Error occurred while generating weekly invoices: %', SQLERRM;
    END;
END;
$$;


ALTER FUNCTION "public"."generate_and_link_weekly_invoices"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."generate_invoices_in_zoho_books"() RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    invoice_record RECORD;
    brand_record RECORD;
    api_response JSONB;
    zoho_api_key TEXT;
    zoho_organization_id TEXT;
    zoho_api_url TEXT := 'https://books.zoho.in/api/v3/invoices';  -- Updated URL for Zoho India
BEGIN
    -- Fetch Zoho Books API credentials from Vault
    SELECT decrypted_secret INTO zoho_api_key 
    FROM vault.decrypted_secrets 
    WHERE name = 'ZOHO_API_KEY';

    IF zoho_api_key IS NULL THEN
        RAISE EXCEPTION 'Zoho API Key not found in vault';
    END IF;

    SELECT decrypted_secret INTO zoho_organization_id 
    FROM vault.decrypted_secrets 
    WHERE name = 'ZOHO_ORGANIZATION_ID';

    IF zoho_organization_id IS NULL THEN
        RAISE EXCEPTION 'Zoho Organization ID not found in vault';
    END IF;

    -- Loop through all invoices that need to be generated
    FOR invoice_record IN 
        SELECT id, brand_id, invoice_number, total_amount, gst_amount, subtotal, issued_at, due_date 
        FROM public.invoices 
        WHERE status = 'pending'  -- Assuming 'pending' means it needs to be generated
        ORDER BY created_at
    LOOP
        -- Fetch brand details for the invoice
        SELECT * INTO brand_record 
        FROM public.brand_profiles 
        WHERE id = invoice_record.brand_id;

        -- Make API request to Zoho Books to create an invoice
        BEGIN
            api_response := (
                SELECT pg_net.http_post(
                    url := zoho_api_url,
                    headers := jsonb_build_object(
                        'Authorization', 'Zoho-oauthtoken ' || zoho_api_key,
                        'Content-Type', 'application/json',
                        'X-com-zoho-books-organizationid', zoho_organization_id
                    ),
                    body := jsonb_build_object(
                        'customer_id', brand_record.zoho_books_id,  -- Use the Zoho Books ID from brand_profiles
                        'line_items', jsonb_build_array(
                            jsonb_build_object(
                                'item_id', 'ITEM_ID',  -- Replace with actual item ID or logic to fetch it
                                'quantity', 1,
                                'rate', invoice_record.total_amount,
                                'description', 'Invoice for ' || invoice_record.invoice_number
                            )
                        ),
                        'total', invoice_record.total_amount,
                        'gst_amount', invoice_record.gst_amount,
                        'issued_at', invoice_record.issued_at,
                        'due_date', invoice_record.due_date
                    )::TEXT
                )
            );

            -- Check for API response errors
            IF api_response->>'code' IS NOT NULL THEN
                -- Mark invoice as failed due to API error
                UPDATE public.invoices
                SET status = 'failed', 
                    failure_reason = api_response->>'message',
                    last_retry_at = CURRENT_TIMESTAMP
                WHERE id = invoice_record.id;

                -- Log failure in audit logs
                INSERT INTO public.audit_logs (user_id, action, details, created_at)
                VALUES (
                    brand_record.id,  -- Assuming user_id is the brand ID for logging
                    'INVOICE_GENERATION_FAILED',
                    'Invoice generation failed for invoice ID ' || invoice_record.id || ' - API error: ' || api_response->>'message',
                    CURRENT_TIMESTAMP
                );

                CONTINUE;
            END IF;

        EXCEPTION
            WHEN OTHERS THEN
                -- Handle any unexpected errors
                UPDATE public.invoices
                SET status = 'failed', 
                    failure_reason = 'Unexpected error: ' || SQLERRM,
                    last_retry_at = CURRENT_TIMESTAMP
                WHERE id = invoice_record.id;

                INSERT INTO public.audit_logs (user_id, action, details, created_at)
                VALUES (
                    brand_record.id,  -- Assuming user_id is the brand ID for logging
                    'INVOICE_GENERATION_FAILED',
                    'Invoice generation failed for invoice ID ' || invoice_record.id || ' - Unexpected error: ' || SQLERRM,
                    CURRENT_TIMESTAMP
                );

                CONTINUE;
        END;

        -- Update invoice status to 'generated' or any other status as needed
        UPDATE public.invoices
        SET status = 'generated', 
            zoho_invoice_id = api_response->>'id'  -- Store the Zoho invoice ID
        WHERE id = invoice_record.id;

        -- Log successful invoice generation
        INSERT INTO public.audit_logs (user_id, action, details, created_at)
        VALUES (
            brand_record.id,  -- Assuming user_id is the brand ID for logging
            'INVOICE_GENERATED',
            'Successfully generated invoice ID ' || invoice_record.id,
            CURRENT_TIMESTAMP
        );

    END LOOP;
END;
$$;


ALTER FUNCTION "public"."generate_invoices_in_zoho_books"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_combined_payout_notifications"("enrollment_id" bigint, "amount" numeric, "status" "text", "failure_reason" "text" DEFAULT NULL::"text") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    shopper_id BIGINT;
    message TEXT;
BEGIN
    -- Get the shopper ID for the enrollment
    SELECT shopper_id INTO shopper_id FROM enrollments WHERE id = enrollment_id;

    IF status = 'failed' THEN
        message := 'Your payout of ₹' || amount || ' for Enrollment ID ' || enrollment_id || ' has failed. Reason: ' || COALESCE(failure_reason, 'No reason provided.');
        -- Notify the shopper about the failed payout
        INSERT INTO notifications (user_id, message, is_read, created_at)
        VALUES (shopper_id, message, FALSE, NOW());

        -- Notify all admins about the failed payout
        message := 'A payout of ₹' || amount || ' for Enrollment ID ' || enrollment_id || ' has failed. Reason: ' || COALESCE(failure_reason, 'No reason provided.');
        INSERT INTO notifications (user_id, message, is_read, created_at)
        SELECT id, message, FALSE, NOW()
        FROM admin_profiles;

    ELSIF status = 'processed' THEN
        message := 'Your payout for Enrollment ID: ' || enrollment_id || ' has been successfully processed. Amount: ₹' || amount || '.';
        -- Notify the shopper about the successful payout
        INSERT INTO notifications (user_id, message, is_read, created_at)
        VALUES (shopper_id, message, FALSE, NOW());
    END IF;

    -- Optionally, log the notification in audit logs
    INSERT INTO audit_logs (user_id, action, details, created_at)
    VALUES (NULL, 'Payout Notification', message, NOW());

END;
$$;


ALTER FUNCTION "public"."handle_combined_payout_notifications"("enrollment_id" bigint, "amount" numeric, "status" "text", "failure_reason" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_enrollment_notifications"("enrollment_id" bigint, "status_change" "text") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    shopper_id BIGINT;
    message TEXT;
BEGIN
    -- Get the shopper ID for the enrollment
    SELECT shopper_id INTO shopper_id FROM enrollments WHERE id = enrollment_id;

    IF status_change = 'rejected' THEN
        message := 'Your enrollment (ID: ' || enrollment_id || ') has been rejected by the brand. Reason: ' || COALESCE(NEW.rejection_reason, 'No reason provided.');
        -- Notify the shopper about rejection
        INSERT INTO notifications (user_id, message, is_read, created_at)
        VALUES (shopper_id, message, FALSE, NOW());

    ELSIF status_change = 'approved' THEN
        message := 'Your enrollment (ID: ' || enrollment_id || ') has been approved by the brand. You can now proceed with your deliverables.';
        -- Notify the shopper about approval
        INSERT INTO notifications (user_id, message, is_read, created_at)
        VALUES (shopper_id, message, FALSE, NOW());
    END IF;

    -- Optionally, notify about pending deliverables
    IF status_change = 'pending_deliverables' THEN
        message := 'Reminder: Please submit your deliverables for enrollment (ID: ' || enrollment_id || ') before the deadline.';
        INSERT INTO notifications (user_id, message, is_read, created_at)
        VALUES (shopper_id, message, FALSE, NOW());
    END IF;

END;
$$;


ALTER FUNCTION "public"."handle_enrollment_notifications"("enrollment_id" bigint, "status_change" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_invoice_events"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    total_due NUMERIC;
    total_paid NUMERIC;
    message TEXT;
BEGIN
    -- Get total invoice amount and total paid so far
    SELECT total_amount, amount_paid INTO total_due, total_paid
    FROM invoices
    WHERE id = NEW.id;

    -- Determine and update invoice status
    IF total_paid = total_due THEN
        NEW.status := 'paid';
        message := 'Invoice ID ' || NEW.id || ' has been fully paid.';
    ELSIF total_paid > 0 THEN
        NEW.status := 'partially_paid';
        message := 'Invoice ID ' || NEW.id || ' is now partially paid.';
    ELSE
        NEW.status := 'pending';
        message := 'Invoice ID ' || NEW.id || ' is pending.';
    END IF;

    -- Insert audit log for invoice status change
    INSERT INTO audit_logs (user_id, action, details, created_at)
    VALUES (NEW.brand_id, 'Invoice Status Updated', message, NOW());

    RETURN NEW; -- Return the new record
END;
$$;


ALTER FUNCTION "public"."handle_invoice_events"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_invoice_events"("invoice_id" bigint) RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    total_due NUMERIC;
    total_paid NUMERIC;
    current_status TEXT;
    message TEXT;
    brand_id BIGINT;
BEGIN
    -- Get total invoice amount and total paid so far
    SELECT total_amount, (total_amount - remaining_amount), status, brand_id
    INTO total_due, total_paid, current_status, brand_id
    FROM invoices
    WHERE id = invoice_id;

    -- Determine and update invoice status
    IF total_paid = total_due THEN
        UPDATE invoices 
        SET status = 'paid'
        WHERE id = invoice_id;
        
        message := 'Invoice ID ' || invoice_id || ' has been fully paid.';
    ELSIF total_paid > 0 THEN
        UPDATE invoices 
        SET status = 'partially_paid'
        WHERE id = invoice_id;
        
        message := 'Invoice ID ' || invoice_id || ' is now partially paid.';
    ELSE
        UPDATE invoices 
        SET status = 'pending'
        WHERE id = invoice_id;
        
        message := 'Invoice ID ' || invoice_id || ' is pending.';
    END IF;

    -- Insert audit log for invoice status change
    INSERT INTO audit_logs (user_id, action, details, created_at)
    VALUES (NULL, 'Invoice Status Updated', message, NOW());

    -- Notify the brand about the invoice event
    INSERT INTO notifications (user_id, message, is_read, created_at)
    VALUES (brand_id, message, FALSE, NOW());

    -- Notify all admins about the invoice event
    INSERT INTO notifications (user_id, message, is_read, created_at)
    SELECT id, message, FALSE, NOW()
    FROM admin_profiles;

END;
$$;


ALTER FUNCTION "public"."handle_invoice_events"("invoice_id" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."notify_admins_about_new_brand"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Start a transaction
    BEGIN
        -- Notify all admins about the new brand sign-up
        INSERT INTO notifications (user_id, message, is_read, created_at)
        SELECT id, 
            'A new brand (' || NEW.brand_name || ') has signed up. Please review and approve.', 
            FALSE, 
            NOW()
        FROM admin_profiles;

        -- Insert audit log for brand sign-up
        INSERT INTO audit_logs (user_id, action, details, created_at)
        SELECT id,
            'New Brand Signup',
            'Brand "' || NEW.brand_name || '" has signed up and is awaiting approval.',
            NOW()
        FROM admin_profiles;

    EXCEPTION
        WHEN OTHERS THEN
            -- Handle any errors that occur
            RAISE NOTICE 'Error occurred while notifying admins about new brand sign-up: %', SQLERRM;
            -- Optionally, you can log the error to an error log table
    END;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."notify_admins_about_new_brand"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."notify_brands_about_invoices"("invoice_id" bigint, "brand_id" bigint, "is_overdue" boolean, "due_date" timestamp with time zone) RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    invoice_number TEXT;
    message TEXT;
BEGIN
    -- Get the invoice number for the generated invoice
    SELECT invoice_number INTO invoice_number FROM invoices WHERE id = invoice_id;

    -- Notify the brand about the new invoice or overdue status
    IF is_overdue THEN
        message := 'Your invoice (ID: ' || invoice_id || ', Number: ' || invoice_number || ') is overdue. Please make the payment immediately.';
    ELSE
        message := 'A new invoice (ID: ' || invoice_id || ', Number: ' || invoice_number || ') has been generated. Please make the payment before the due date.';
    END IF;

    INSERT INTO notifications (user_id, message, is_read, created_at)
    VALUES (brand_id, message, FALSE, NOW());

    -- Additional functionality: Notify about upcoming due dates
    IF NOT is_overdue AND due_date <= NOW() + INTERVAL '3 days' THEN
        message := 'Reminder: Your invoice (ID: ' || invoice_id || ', Number: ' || invoice_number || ') is due on ' || to_char(due_date, 'YYYY-MM-DD') || '. Please ensure timely payment.';
        INSERT INTO notifications (user_id, message, is_read, created_at)
        VALUES (brand_id, message, FALSE, NOW());
    END IF;

END;
$$;


ALTER FUNCTION "public"."notify_brands_about_invoices"("invoice_id" bigint, "brand_id" bigint, "is_overdue" boolean, "due_date" timestamp with time zone) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."notify_brands_about_pending_approvals"() RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Start a transaction
    BEGIN
        WITH pending_enrollments AS (
            SELECT e.campaign_id, c.brand_id, COUNT(*) AS pending_count
            FROM enrollments e
            JOIN campaigns c ON e.campaign_id = c.id
            WHERE e.status = 'pending'
            AND e.created_at <= NOW() - INTERVAL '3 days'
            GROUP BY e.campaign_id, c.brand_id
        )
        -- Insert notifications for brands
        INSERT INTO notifications (user_id, message, is_read, created_at)
        SELECT brand_id, 
               'You have ' || pending_count || ' pending enrollments awaiting approval for Campaign ID: ' || campaign_id || '.', 
               FALSE, 
               NOW()
        FROM pending_enrollments
        WHERE pending_count > 0;  -- Ensure there are pending enrollments

    EXCEPTION
        WHEN OTHERS THEN
            -- Handle any errors that occur
            RAISE NOTICE 'Error occurred while notifying brands about pending approvals: %', SQLERRM;
            -- Optionally, you can log the error to an error log table
    END;
END;
$$;


ALTER FUNCTION "public"."notify_brands_about_pending_approvals"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."notify_campaign_status"("campaign_id" bigint) RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    brand_id BIGINT;
    total_enrollments INT;
    max_enrollments INT;
    expiration_date TIMESTAMP WITH TIME ZONE;
    message TEXT;
BEGIN
    -- Get the brand ID, max enrollments, and expiration date for the campaign
    SELECT brand_id, max_enrollments, expiration_date INTO brand_id, max_enrollments, expiration_date 
    FROM campaigns WHERE id = campaign_id;

    -- Check the current enrollment count
    SELECT COUNT(*) INTO total_enrollments FROM enrollments WHERE campaign_id = campaign_id;

    -- Prepare messages based on conditions
    IF total_enrollments >= max_enrollments THEN
        message := 'Your campaign (ID: ' || campaign_id || ') has reached its maximum enrollments.';
        INSERT INTO notifications (user_id, message, is_read, created_at)
        VALUES (brand_id, message, FALSE, NOW());

        message := 'Campaign ID ' || campaign_id || ' has reached its maximum enrollments.';
        INSERT INTO notifications (user_id, message, is_read, created_at)
        SELECT id, message, FALSE, NOW()
        FROM admin_profiles;
    END IF;

    -- Notify about campaign expiration
    IF expiration_date <= NOW() + INTERVAL '3 days' THEN
        message := 'Your campaign (ID: ' || campaign_id || ') will expire in 3 days. Consider extending or creating a new campaign.';
        INSERT INTO notifications (user_id, message, is_read, created_at)
        VALUES (brand_id, message, FALSE, NOW());
    END IF;

END;
$$;


ALTER FUNCTION "public"."notify_campaign_status"("campaign_id" bigint) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."notify_invoice_status"("invoice_id" bigint, "event_type" "text") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    brand_id BIGINT;
    message TEXT;
    invoice_status TEXT;
BEGIN
    -- Get the brand ID and status for the invoice
    SELECT brand_id, status INTO brand_id, invoice_status FROM invoices WHERE id = invoice_id;

    -- Prepare the message based on the event type
    IF event_type = 'status_change' THEN
        message := 'The status of your invoice (ID: ' || invoice_id || ') has changed to ' || invoice_status || '.';
    ELSIF event_type = 'overdue' THEN
        message := 'Your invoice (ID: ' || invoice_id || ') is overdue. Please make the payment immediately.';
    END IF;

    -- Notify the brand about the invoice event
    INSERT INTO notifications (user_id, message, is_read, created_at)
    VALUES (brand_id, message, FALSE, NOW());

    -- Notify admins about the invoice event
    INSERT INTO notifications (user_id, message, is_read, created_at)
    SELECT id, message, FALSE, NOW()
    FROM admin_profiles;

END;
$$;


ALTER FUNCTION "public"."notify_invoice_status"("invoice_id" bigint, "event_type" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."notify_on_invoice_status_change"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    message TEXT;
BEGIN
    -- Prepare the notification message based on the old and new status
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        message := 'The status of your invoice (ID: ' || NEW.id || ') has changed from ' || OLD.status || ' to ' || NEW.status || '.';

        -- Notify the brand about the status change
        INSERT INTO notifications (user_id, message, is_read, created_at)
        VALUES (NEW.brand_id, message, FALSE, NOW());

        -- Notify all admins about the status change
        INSERT INTO notifications (user_id, message, is_read, created_at)
        SELECT id, message, FALSE, NOW() FROM admin_profiles;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."notify_on_invoice_status_change"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."notify_pending_deliverables"() RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Start a transaction
    BEGIN
        WITH pending_deliverables AS (
            SELECT e.id AS enrollment_id, e.shopper_id
            FROM enrollments e
            WHERE e.status = 'approved' 
            AND e.submission_deadline <= NOW() - INTERVAL '7 days'
            AND NOT EXISTS (
                SELECT 1 FROM deliverable_submissions ds
                WHERE ds.enrollment_id = e.id
            )
        )
        -- Insert in-app notifications for pending deliverables
        INSERT INTO notifications (user_id, message, is_read, created_at)
        SELECT shopper_id, 
               'Reminder: Please submit your deliverables before the deadline.', 
               FALSE, NOW()
        FROM pending_deliverables;

    EXCEPTION
        WHEN OTHERS THEN
            -- Handle any errors that occur
            RAISE NOTICE 'Error occurred while notifying pending deliverables: %', SQLERRM;
            -- Optionally, you can log the error to an error log table
    END;
END;
$$;


ALTER FUNCTION "public"."notify_pending_deliverables"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."notify_shoppers_about_submission_deadline"() RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Start a transaction
    BEGIN
        -- Notify shoppers about enrollments expiring in 3 days
        INSERT INTO notifications (user_id, message, is_read, created_at)
        SELECT e.shopper_id, 
            'Reminder: Your enrollment (ID: ' || e.id || ') submission deadline is in 3 days. Submit your deliverables on time.', 
            FALSE, 
            NOW()
        FROM enrollments e
        WHERE e.submission_deadline <= NOW() + INTERVAL '3 days'
        AND e.status = 'approved';

        -- Insert audit logs for upcoming deadlines
        INSERT INTO audit_logs (user_id, action, details, created_at)
        SELECT e.shopper_id,
            'Submission Deadline Reminder',
            'Enrollment ID ' || e.id || ' submission deadline is approaching.',
            NOW()
        FROM enrollments e
        WHERE e.submission_deadline <= NOW() + INTERVAL '3 days'
        AND e.status = 'approved';

    EXCEPTION
        WHEN OTHERS THEN
            -- Handle any errors that occur
            RAISE NOTICE 'Error occurred while notifying shoppers about submission deadlines: %', SQLERRM;
            -- Optionally, you can log the error to an error log table
    END;
END;
$$;


ALTER FUNCTION "public"."notify_shoppers_about_submission_deadline"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."prevent_duplicate_payouts"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM public.payouts 
        WHERE enrollment_id = NEW.enrollment_id
    ) THEN
        RAISE EXCEPTION 'Payout already exists for this enrollment';
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."prevent_duplicate_payouts"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."process_pending_payouts"() RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    payout_record RECORD;
    api_response JSONB;
    razorpay_api_key TEXT;
    razorpay_account_number TEXT;
    payout_method TEXT;
    payout_destination TEXT;
    payout_account_number TEXT;
    payout_ifsc TEXT;
    razorpay_api_url TEXT := 'https://api.razorpay.com/v1/payouts';  -- Store URL in a variable
BEGIN
    -- Fetch Razorpay API credentials from Vault
    SELECT decrypted_secret INTO razorpay_api_key 
    FROM vault.decrypted_secrets 
    WHERE name = 'RAZORPAY_API_KEY';

    IF razorpay_api_key IS NULL THEN
        RAISE EXCEPTION 'Razorpay API Key not found in vault';
    END IF;

    SELECT decrypted_secret INTO razorpay_account_number 
    FROM vault.decrypted_secrets 
    WHERE name = 'RAZORPAY_ACCOUNT_NUMBER';

    IF razorpay_account_number IS NULL THEN
        RAISE EXCEPTION 'Razorpay Account Number not found in vault';
    END IF;

    -- Loop through all payouts that have status 'initiated'
    FOR payout_record IN 
        SELECT id, shopper_id, enrollment_id, amount FROM public.payouts 
        WHERE payout_status = 'initiated'
        ORDER BY created_at
    LOOP
        -- Fetch payout method and destination details
        SELECT 
            payout_details->>'method',
            payout_details->>'upi_id',
            payout_details->>'bank_account',
            payout_details->>'ifsc'
        INTO payout_method, payout_destination, payout_account_number, payout_ifsc
        FROM public.shopper_profiles 
        WHERE id = payout_record.shopper_id;

        -- Validate payout details before processing
        IF payout_method IS NULL OR 
           (payout_method = 'upi' AND payout_destination IS NULL) OR 
           (payout_method = 'bank_transfer' AND (payout_account_number IS NULL OR payout_ifsc IS NULL)) THEN
            
            -- Mark payout as failed due to missing details
            UPDATE public.payouts
            SET payout_status = 'failed', 
                failure_reason = 'Missing payout details',
                last_retry_at = CURRENT_TIMESTAMP
            WHERE id = payout_record.id;

            -- Log failure in audit logs
            INSERT INTO public.audit_logs (user_id, action, details, created_at)
            VALUES (
                payout_record.shopper_id,
                'PAYOUT_FAILED',
                'Payout failed for enrollment ' || payout_record.enrollment_id || ' - Missing payout details',
                CURRENT_TIMESTAMP
            );
            
            CONTINUE;
        END IF;

        -- Make API request to Razorpay X
        BEGIN
            api_response := (
                SELECT pg_net.http_post(
                    url := razorpay_api_url,
                    headers := jsonb_build_object(
                        'Authorization', 'Basic ' || encode(razorpay_api_key::bytea, 'base64'),
                        'Content-Type', 'application/json'
                    ),
                    body := jsonb_build_object(
                        'account_number', razorpay_account_number,
                        'amount', payout_record.amount * 100,  -- Convert to paise
                        'currency', 'INR',
                        'mode', payout_method, -- Either UPI or Bank Transfer
                        'purpose', 'payout',
                        'queue_if_low_balance', true,
                        'fund_account', 
                            CASE 
                                WHEN payout_method = 'upi' THEN 
                                    jsonb_build_object(
                                        'account_type', 'vpa',
                                        'vpa', jsonb_build_object(
                                            'address', payout_destination
                                        )
                                    )
                                WHEN payout_method = 'bank_transfer' THEN 
                                    jsonb_build_object(
                                        'account_type', 'bank_account',
                                        'bank_account', jsonb_build_object(
                                            'account_number', payout_account_number,
                                            'ifsc', payout_ifsc
                                        )
                                    )
                            END
                    )::TEXT
                )
            );

            -- Check for API response errors
            IF api_response->>'error' IS NOT NULL THEN
                -- Mark payout as failed due to API error
                UPDATE public.payouts
                SET payout_status = 'failed', 
                    failure_reason = api_response->>'error',
                    last_retry_at = CURRENT_TIMESTAMP
                WHERE id = payout_record.id;

                -- Log failure in audit logs
                INSERT INTO public.audit_logs (user_id, action, details, created_at)
                VALUES (
                    payout_record.shopper_id,
                    'PAYOUT_FAILED',
                    'Payout failed for enrollment ' || payout_record.enrollment_id || ' - API error: ' || api_response->>'error',
                    CURRENT_TIMESTAMP
                );

                CONTINUE;
            END IF;

        EXCEPTION
            WHEN OTHERS THEN
                -- Handle any unexpected errors
                UPDATE public.payouts
                SET payout_status = 'failed', 
                    failure_reason = 'Unexpected error: ' || SQLERRM,
                    last_retry_at = CURRENT_TIMESTAMP
                WHERE id = payout_record.id;

                INSERT INTO public.audit_logs (user_id, action, details, created_at)
                VALUES (
                    payout_record.shopper_id,
                    'PAYOUT_FAILED',
                    'Payout failed for enrollment ' || payout_record.enrollment_id || ' - Unexpected error: ' || SQLERRM,
                    CURRENT_TIMESTAMP
                );

                CONTINUE;
        END;

        -- Store the Razorpay payout ID for tracking
        UPDATE public.payouts
        SET razorpay_payout_id = api_response->>'id'
        WHERE id = payout_record.id;

        -- Log payout attempt
        INSERT INTO public.audit_logs (user_id, action, details, created_at)
        VALUES (
            payout_record.shopper_id,
            'PAYOUT_ATTEMPT',
            'Initiated payout for enrollment ' || payout_record.enrollment_id || ' - Razorpay Payout ID: ' || api_response->>'id',
            CURRENT_TIMESTAMP
        );

    END LOOP;
END;
$$;


ALTER FUNCTION "public"."process_pending_payouts"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."retry_failed_payouts_on_payment_update"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Start a transaction
    BEGIN
        -- Update payouts to be retried if they previously failed
        UPDATE payouts
        SET status = 'pending', retry_count = retry_count + 1, last_retry_at = NOW()
        WHERE shopper_id = NEW.id
        AND status = 'failed';

        -- Optionally, you can log the retry action in an audit log
        INSERT INTO audit_logs (user_id, action, details, created_at)
        SELECT NEW.id, 
            'Retry Failed Payouts', 
            'Retrying payouts for shopper ID ' || NEW.id, 
            NOW()
        WHERE EXISTS (
            SELECT 1 FROM payouts WHERE shopper_id = NEW.id AND status = 'failed'
        );

    EXCEPTION
        WHEN OTHERS THEN
            -- Handle any errors that occur
            RAISE NOTICE 'Error occurred while retrying failed payouts: %', SQLERRM;
            -- Optionally, you can log the error to an error log table
    END;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."retry_failed_payouts_on_payment_update"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."sync_invoice_status_from_zoho"("zoho_invoice_id" "text", "new_status" "text") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    invoice_record RECORD;
BEGIN
    -- Fetch the invoice associated with the Zoho invoice ID
    SELECT * INTO invoice_record
    FROM public.invoices
    WHERE zoho_invoice_id = zoho_invoice_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invoice not found for Zoho invoice ID %', zoho_invoice_id;
    END IF;

    -- Update the invoice status based on the new status from Zoho Books
    UPDATE public.invoices
    SET status = new_status,
        last_updated = CURRENT_TIMESTAMP  -- Assuming there's a last_updated column
    WHERE id = invoice_record.id;

    -- Log the status change in audit logs
    INSERT INTO public.audit_logs (user_id, action, details, created_at)
    VALUES (
        invoice_record.brand_id,  -- Assuming user_id is the brand ID for logging
        'INVOICE_STATUS_SYNCED',
        'Invoice ID ' || invoice_record.id || ' status updated to ' || new_status || ' from Zoho Books.',
        CURRENT_TIMESTAMP
    );

END;
$$;


ALTER FUNCTION "public"."sync_invoice_status_from_zoho"("zoho_invoice_id" "text", "new_status" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."trigger_generate_invoices"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    api_response JSONB;
    zoho_api_key TEXT;
    zoho_organization_id TEXT;
    zoho_api_url TEXT := 'https://books.zoho.in/api/v3/invoices';  -- URL for Zoho India
BEGIN
    -- Fetch Zoho Books API credentials from Vault
    SELECT decrypted_secret INTO zoho_api_key 
    FROM vault.decrypted_secrets 
    WHERE name = 'ZOHO_API_KEY';

    IF zoho_api_key IS NULL THEN
        RAISE EXCEPTION 'Zoho API Key not found in vault';
    END IF;

    SELECT decrypted_secret INTO zoho_organization_id 
    FROM vault.decrypted_secrets 
    WHERE name = 'ZOHO_ORGANIZATION_ID';

    IF zoho_organization_id IS NULL THEN
        RAISE EXCEPTION 'Zoho Organization ID not found in vault';
    END IF;

    -- Make API request to Zoho Books to create an invoice
    BEGIN
        api_response := (
            SELECT pg_net.http_post(
                url := zoho_api_url,
                headers := jsonb_build_object(
                    'Authorization', 'Zoho-oauthtoken ' || zoho_api_key,
                    'Content-Type', 'application/json',
                    'X-com-zoho-books-organizationid', zoho_organization_id
                ),
                body := jsonb_build_object(
                    'customer_id', (SELECT zoho_books_id FROM public.brand_profiles WHERE id = NEW.brand_id),  -- Use the Zoho Books ID from brand_profiles
                    'line_items', jsonb_build_array(
                        jsonb_build_object(
                            'item_id', 'ITEM_ID',  -- Replace with actual item ID or logic to fetch it
                            'quantity', 1,
                            'rate', NEW.total_amount,
                            'description', 'Invoice for ' || NEW.invoice_number
                        )
                    ),
                    'total', NEW.total_amount,
                    'gst_amount', NEW.gst_amount,
                    'tds_percentage', NEW.tds_percentage,  -- Include TDS percentage
                    'tds_amount', NEW.tds_amount,          -- Include TDS amount
                    'issued_at', NEW.issued_at,
                    'due_date', NEW.due_date
                )::TEXT
            )
        );

        -- Check for API response errors
        IF api_response->>'code' IS NOT NULL THEN
            -- Mark invoice as failed due to API error
            UPDATE public.invoices
            SET status = 'failed', 
                failure_reason = api_response->>'message',
                last_retry_at = CURRENT_TIMESTAMP
            WHERE id = NEW.id;

            -- Log failure in audit logs
            INSERT INTO public.audit_logs (user_id, action, details, created_at)
            VALUES (
                NEW.brand_id,  -- Assuming user_id is the brand ID for logging
                'INVOICE_GENERATION_FAILED',
                'Invoice generation failed for invoice ID ' || NEW.id || ' - API error: ' || api_response->>'message',
                CURRENT_TIMESTAMP
            );

            RETURN NEW;  -- Exit the trigger function
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            -- Handle any unexpected errors
            UPDATE public.invoices
            SET status = 'failed', 
                failure_reason = 'Unexpected error: ' || SQLERRM,
                last_retry_at = CURRENT_TIMESTAMP
            WHERE id = NEW.id;

            INSERT INTO public.audit_logs (user_id, action, details, created_at)
            VALUES (
                NEW.brand_id,  -- Assuming user_id is the brand ID for logging
                'INVOICE_GENERATION_FAILED',
                'Invoice generation failed for invoice ID ' || NEW.id || ' - Unexpected error: ' || SQLERRM,
                CURRENT_TIMESTAMP
            );

            RETURN NEW;  -- Exit the trigger function
    END;

    -- Update invoice status to 'generated' or any other status as needed
    UPDATE public.invoices
    SET status = 'generated', 
        zoho_invoice_id = api_response->>'id'  -- Store the Zoho invoice ID
    WHERE id = NEW.id;

    -- Log successful invoice generation
    INSERT INTO public.audit_logs (user_id, action, details, created_at)
    VALUES (
        NEW.brand_id,  -- Assuming user_id is the brand ID for logging
        'INVOICE_GENERATED',
        'Successfully generated invoice ID ' || NEW.id,
        CURRENT_TIMESTAMP
    );

    RETURN NEW;  -- Return the new record
END;
$$;


ALTER FUNCTION "public"."trigger_generate_invoices"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."admin_profiles" (
    "id" bigint NOT NULL,
    "first_name" "text" NOT NULL,
    "last_name" "text" NOT NULL,
    "phone_number" "text" NOT NULL,
    "email" "text" NOT NULL,
    "profile_picture_url" "text",
    "role" "public"."admin_role" NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"(),
    "profile_id" bigint,
    CONSTRAINT "admin_profiles_email_check" CHECK (("email" ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'::"text")),
    CONSTRAINT "admin_profiles_phone_number_check" CHECK (("phone_number" ~ '^[0-9]{10}$'::"text"))
);


ALTER TABLE "public"."admin_profiles" OWNER TO "postgres";


ALTER TABLE "public"."admin_profiles" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."admin_profiles_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."brand_profiles" (
    "id" bigint NOT NULL,
    "brand_name" "text" NOT NULL,
    "company_name" "text" NOT NULL,
    "contact_person" "text" NOT NULL,
    "phone_number" "text" NOT NULL,
    "email" "text" NOT NULL,
    "accounts_email" "text" NOT NULL,
    "website" "text",
    "gst_number" "text",
    "business_address" "text" NOT NULL,
    "city" "text",
    "state" "text",
    "postal_code" "text",
    "brand_logo_url" "text",
    "payment_terms" "text" NOT NULL,
    "razorpay_va_id" "text",
    "razorpay_va_number" "text",
    "razorpay_va_ifsc" "text",
    "razorpay_va_upi_id" "text",
    "zoho_books_id" "text",
    "created_at" timestamp without time zone DEFAULT "now"(),
    "profile_id" bigint,
    "admin_approved" boolean DEFAULT false NOT NULL,
    "tds_rate" numeric(5,2) DEFAULT 0 NOT NULL,
    CONSTRAINT "brand_profiles_accounts_email_check" CHECK (("accounts_email" ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'::"text")),
    CONSTRAINT "brand_profiles_email_check" CHECK (("email" ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'::"text")),
    CONSTRAINT "brand_profiles_gst_number_check" CHECK (("gst_number" ~ '^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][0-9][A-Z][A-Z0-9]$'::"text")),
    CONSTRAINT "brand_profiles_phone_number_check" CHECK (("phone_number" ~ '^[0-9]{10}$'::"text")),
    CONSTRAINT "brand_profiles_postal_code_check" CHECK (("postal_code" ~ '^[0-9]{5,6}$'::"text")),
    CONSTRAINT "brand_profiles_razorpay_va_ifsc_check" CHECK (("razorpay_va_ifsc" ~ '^[A-Z]{4}0[A-Z0-9]{6}$'::"text")),
    CONSTRAINT "brand_profiles_razorpay_va_number_check" CHECK (("razorpay_va_number" ~ '^[0-9]{9,18}$'::"text")),
    CONSTRAINT "brand_profiles_razorpay_va_upi_id_check" CHECK (("razorpay_va_upi_id" ~ '^[a-zA-Z0-9.-_]{2,256}@[a-zA-Z]{2,64}$'::"text")),
    CONSTRAINT "brand_profiles_website_check" CHECK (("website" ~ '^https?://.+$'::"text"))
);


ALTER TABLE "public"."brand_profiles" OWNER TO "postgres";


ALTER TABLE "public"."brand_profiles" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."brand_profiles_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."campaign_deliverables" (
    "id" bigint NOT NULL,
    "campaign_id" bigint,
    "deliverable_id" bigint,
    "min_word_count" integer DEFAULT 0,
    "required_images" integer DEFAULT 0,
    "required_videos" integer DEFAULT 0,
    "hashtags" "text",
    "mentions" "text",
    "is_mandatory" boolean DEFAULT true NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"(),
    CONSTRAINT "campaign_deliverables_hashtags_check" CHECK (("char_length"("hashtags") <= 500)),
    CONSTRAINT "campaign_deliverables_mentions_check" CHECK (("char_length"("mentions") <= 500)),
    CONSTRAINT "campaign_deliverables_min_word_count_check" CHECK (("min_word_count" >= 0)),
    CONSTRAINT "campaign_deliverables_required_images_check" CHECK (("required_images" >= 0)),
    CONSTRAINT "campaign_deliverables_required_videos_check" CHECK (("required_videos" >= 0))
);


ALTER TABLE "public"."campaign_deliverables" OWNER TO "postgres";


ALTER TABLE "public"."campaign_deliverables" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."campaign_deliverables_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."campaign_images" (
    "id" bigint NOT NULL,
    "campaign_id" bigint,
    "image_url" "text" NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."campaign_images" OWNER TO "postgres";


ALTER TABLE "public"."campaign_images" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."campaign_images_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."campaigns" (
    "id" bigint NOT NULL,
    "brand_id" bigint,
    "title" "text" NOT NULL,
    "description" "text" NOT NULL,
    "product_id" bigint,
    "start_date" "date" NOT NULL,
    "end_date" "date" NOT NULL,
    "enrollment_deadline" "date" NOT NULL,
    "rebate_percentage" numeric(5,2) NOT NULL,
    "incentive_amount" numeric(10,2) DEFAULT 100 NOT NULL,
    "max_enrollments" integer NOT NULL,
    "approval_status" boolean DEFAULT false NOT NULL,
    "approval_remarks" "text",
    "approval_date" timestamp without time zone,
    "approved_by" bigint,
    "terms_and_conditions" "text" NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"(),
    "status" "public"."campaign_status" DEFAULT 'pending'::"public"."campaign_status" NOT NULL,
    CONSTRAINT "campaigns_check" CHECK (("end_date" > "start_date")),
    CONSTRAINT "campaigns_check1" CHECK ((("enrollment_deadline" >= "start_date") AND ("enrollment_deadline" <= "end_date"))),
    CONSTRAINT "campaigns_incentive_amount_check" CHECK (("incentive_amount" >= (0)::numeric)),
    CONSTRAINT "campaigns_max_enrollments_check" CHECK (("max_enrollments" > 0)),
    CONSTRAINT "campaigns_rebate_percentage_check" CHECK ((("rebate_percentage" >= (0)::numeric) AND ("rebate_percentage" <= (100)::numeric))),
    CONSTRAINT "campaigns_start_date_check" CHECK (("start_date" >= CURRENT_DATE))
);


ALTER TABLE "public"."campaigns" OWNER TO "postgres";


ALTER TABLE "public"."campaigns" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."campaigns_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."coupon_redemptions" (
    "id" bigint NOT NULL,
    "coupon_id" bigint NOT NULL,
    "shopper_id" bigint NOT NULL,
    "enrollment_id" bigint NOT NULL,
    "redeemed_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "status" "text" DEFAULT 'successful'::"text" NOT NULL,
    CONSTRAINT "coupon_redemptions_status_check" CHECK (("status" = ANY (ARRAY['successful'::"text", 'failed'::"text", 'revoked'::"text"])))
);


ALTER TABLE "public"."coupon_redemptions" OWNER TO "postgres";


ALTER TABLE "public"."coupon_redemptions" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."coupon_redemptions_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."coupons" (
    "id" bigint NOT NULL,
    "code" "text" NOT NULL,
    "discount_percentage" numeric(5,2),
    "bonus_amount" numeric(10,2),
    "usage_limit" integer,
    "one_time_use" boolean DEFAULT false NOT NULL,
    "valid_from" timestamp without time zone NOT NULL,
    "valid_until" timestamp without time zone NOT NULL,
    "applicable_to" "text" DEFAULT 'all'::"text" NOT NULL,
    "specific_campaign_id" bigint,
    "created_by" bigint NOT NULL,
    "status" "text" DEFAULT 'active'::"text" NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "coupons_applicable_to_check" CHECK (("applicable_to" = ANY (ARRAY['all'::"text", 'shoppers'::"text", 'new_users'::"text", 'specific_campaign'::"text"]))),
    CONSTRAINT "coupons_bonus_amount_check" CHECK (("bonus_amount" >= (0)::numeric)),
    CONSTRAINT "coupons_check" CHECK (("valid_until" > "valid_from")),
    CONSTRAINT "coupons_discount_percentage_check" CHECK ((("discount_percentage" >= (0)::numeric) AND ("discount_percentage" <= (100)::numeric))),
    CONSTRAINT "coupons_status_check" CHECK (("status" = ANY (ARRAY['active'::"text", 'expired'::"text", 'disabled'::"text"]))),
    CONSTRAINT "coupons_usage_limit_check" CHECK (("usage_limit" >= 0))
);


ALTER TABLE "public"."coupons" OWNER TO "postgres";


ALTER TABLE "public"."coupons" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."coupons_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."deliverable_submissions" (
    "id" bigint NOT NULL,
    "enrollment_id" bigint,
    "campaign_deliverable_id" bigint,
    "proof_link" "text",
    "proof_screenshot" "text",
    "created_at" timestamp without time zone DEFAULT "now"(),
    CONSTRAINT "deliverable_submissions_proof_link_check" CHECK (("proof_link" ~ '^https?://.+$'::"text"))
);


ALTER TABLE "public"."deliverable_submissions" OWNER TO "postgres";


ALTER TABLE "public"."deliverable_submissions" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."deliverable_submissions_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."deliverables" (
    "id" bigint NOT NULL,
    "name" "text" NOT NULL,
    "category" "public"."deliverable_category" NOT NULL,
    "platform_id" bigint,
    "status" "public"."deliverable_status" DEFAULT 'active'::"public"."deliverable_status" NOT NULL,
    "require_screenshot" boolean DEFAULT false NOT NULL,
    "require_link" boolean DEFAULT false NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."deliverables" OWNER TO "postgres";


ALTER TABLE "public"."deliverables" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."deliverables_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."enrollments" (
    "id" bigint NOT NULL,
    "campaign_id" bigint,
    "shopper_id" bigint,
    "order_id" "text" NOT NULL,
    "rebate_amount" numeric(10,2) NOT NULL,
    "bonus_amount" numeric(10,2) DEFAULT 0,
    "coupon_adjustment" numeric(10,2) DEFAULT 0,
    "total_rebate" numeric(10,2) GENERATED ALWAYS AS ((("rebate_amount" + "bonus_amount") + "coupon_adjustment")) STORED,
    "incentive_amount" numeric(10,2) NOT NULL,
    "deduction_amount" numeric(10,2) DEFAULT 0,
    "platform_profit" numeric(10,2) NOT NULL,
    "approval_remarks" "text",
    "created_at" timestamp without time zone DEFAULT "now"(),
    "coupon_id" bigint,
    "is_invoiced" boolean DEFAULT false NOT NULL,
    "status" "public"."enrollment_status" DEFAULT 'pending'::"public"."enrollment_status" NOT NULL,
    "rejection_count" integer DEFAULT 0 NOT NULL,
    "brand_id" bigint,
    CONSTRAINT "enrollments_bonus_amount_check" CHECK (("bonus_amount" >= (0)::numeric)),
    CONSTRAINT "enrollments_coupon_adjustment_check" CHECK (("coupon_adjustment" >= (0)::numeric)),
    CONSTRAINT "enrollments_deduction_amount_check" CHECK (("deduction_amount" >= (0)::numeric)),
    CONSTRAINT "enrollments_incentive_amount_check" CHECK (("incentive_amount" >= (0)::numeric)),
    CONSTRAINT "enrollments_platform_profit_check" CHECK (("platform_profit" >= (0)::numeric)),
    CONSTRAINT "enrollments_rebate_amount_check" CHECK (("rebate_amount" >= (0)::numeric))
);


ALTER TABLE "public"."enrollments" OWNER TO "postgres";


ALTER TABLE "public"."enrollments" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."enrollments_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."invoice_enrollments" (
    "id" bigint NOT NULL,
    "invoice_id" bigint NOT NULL,
    "enrollment_id" bigint NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."invoice_enrollments" OWNER TO "postgres";


ALTER TABLE "public"."invoice_enrollments" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."invoice_enrollments_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."invoice_payments" (
    "id" bigint NOT NULL,
    "invoice_id" bigint NOT NULL,
    "payment_id" bigint NOT NULL,
    "applied_amount" numeric(10,2) NOT NULL,
    "remaining_amount" numeric(10,2) NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "invoice_payments_applied_amount_check" CHECK (("applied_amount" > (0)::numeric)),
    CONSTRAINT "invoice_payments_remaining_amount_check" CHECK (("remaining_amount" >= (0)::numeric))
);


ALTER TABLE "public"."invoice_payments" OWNER TO "postgres";


ALTER TABLE "public"."invoice_payments" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."invoice_payments_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."invoices" (
    "id" bigint NOT NULL,
    "brand_id" bigint NOT NULL,
    "invoice_number" "text" NOT NULL,
    "total_order_amount" numeric(10,2) NOT NULL,
    "total_incentive_amount" numeric(10,2) NOT NULL,
    "subtotal" numeric(10,2) NOT NULL,
    "gst_amount" numeric(10,2) NOT NULL,
    "total_amount" numeric(10,2) NOT NULL,
    "amount_paid" numeric(10,2) DEFAULT 0,
    "status" "text" NOT NULL,
    "issued_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "due_date" timestamp without time zone NOT NULL,
    "zoho_invoice_id" "text",
    "created_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "tds_percentage" numeric(5,2) DEFAULT 0 NOT NULL,
    "tds_amount" numeric(10,2) DEFAULT 0 NOT NULL,
    "net_amount" numeric(10,2) DEFAULT 0 NOT NULL,
    "payout_processed" boolean DEFAULT false NOT NULL,
    CONSTRAINT "invoices_amount_paid_check" CHECK (("amount_paid" >= (0)::numeric)),
    CONSTRAINT "invoices_gst_amount_check" CHECK (("gst_amount" >= (0)::numeric)),
    CONSTRAINT "invoices_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'partially_paid'::"text", 'paid'::"text", 'cancelled'::"text"]))),
    CONSTRAINT "invoices_subtotal_check" CHECK (("subtotal" >= (0)::numeric)),
    CONSTRAINT "invoices_total_amount_check" CHECK (("total_amount" >= (0)::numeric)),
    CONSTRAINT "invoices_total_incentive_amount_check" CHECK (("total_incentive_amount" >= (0)::numeric)),
    CONSTRAINT "invoices_total_order_amount_check" CHECK (("total_order_amount" >= (0)::numeric))
);


ALTER TABLE "public"."invoices" OWNER TO "postgres";


ALTER TABLE "public"."invoices" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."invoices_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."items" (
    "id" bigint NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "price" numeric(10,2) NOT NULL,
    "gst_rate" numeric(5,2) DEFAULT 0 NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"()
);


ALTER TABLE "public"."items" OWNER TO "postgres";


ALTER TABLE "public"."items" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."items_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."notification_preferences" (
    "id" bigint NOT NULL,
    "user_id" bigint NOT NULL,
    "in_app" boolean DEFAULT true NOT NULL,
    "email" boolean DEFAULT true NOT NULL,
    "whatsapp" boolean DEFAULT false NOT NULL,
    "push_notifications" boolean DEFAULT false NOT NULL,
    "updated_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."notification_preferences" OWNER TO "postgres";


ALTER TABLE "public"."notification_preferences" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."notification_preferences_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."notifications" (
    "id" bigint NOT NULL,
    "user_id" bigint NOT NULL,
    "title" "text" NOT NULL,
    "message" "text" NOT NULL,
    "type" "text" NOT NULL,
    "thumbnail_url" "text",
    "context_type" "text" NOT NULL,
    "context_id" bigint NOT NULL,
    "action_link" "text",
    "status" "text" DEFAULT 'unread'::"text" NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "notifications_context_type_check" CHECK (("context_type" = ANY (ARRAY['enrollment'::"text", 'payout'::"text", 'invoice'::"text", 'campaign'::"text", 'system'::"text", 'announcement'::"text"]))),
    CONSTRAINT "notifications_status_check" CHECK (("status" = ANY (ARRAY['unread'::"text", 'read'::"text"]))),
    CONSTRAINT "notifications_type_check" CHECK (("type" = ANY (ARRAY['system'::"text", 'payment'::"text", 'payout'::"text", 'campaign'::"text", 'reminder'::"text", 'admin_announcement'::"text"])))
);


ALTER TABLE "public"."notifications" OWNER TO "postgres";


ALTER TABLE "public"."notifications" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."notifications_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."payments" (
    "id" bigint NOT NULL,
    "brand_id" bigint NOT NULL,
    "amount" numeric(10,2) NOT NULL,
    "status" "text" NOT NULL,
    "razorpay_payment_id" "text" NOT NULL,
    "utr_reference" "text" NOT NULL,
    "transaction_source" "text" NOT NULL,
    "razorpay_va_id" "text" NOT NULL,
    "received_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "payments_amount_check" CHECK (("amount" > (0)::numeric)),
    CONSTRAINT "payments_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'completed'::"text", 'failed'::"text", 'refunded'::"text"]))),
    CONSTRAINT "payments_transaction_source_check" CHECK (("transaction_source" = ANY (ARRAY['UPI'::"text", 'NEFT'::"text", 'IMPS'::"text", 'RTGS'::"text"])))
);


ALTER TABLE "public"."payments" OWNER TO "postgres";


ALTER TABLE "public"."payments" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."payments_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."payouts" (
    "id" bigint NOT NULL,
    "enrollment_id" bigint NOT NULL,
    "shopper_id" bigint NOT NULL,
    "amount" numeric(10,2) NOT NULL,
    "razorpay_payout_id" "text" NOT NULL,
    "retry_count" integer DEFAULT 0,
    "last_retry_at" timestamp without time zone,
    "failure_reason" "text",
    "processed_at" timestamp without time zone,
    "created_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "payout_status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "order_id" "text" NOT NULL,
    CONSTRAINT "payouts_amount_check" CHECK (("amount" > (0)::numeric)),
    CONSTRAINT "payouts_retry_count_check" CHECK (("retry_count" >= 0)),
    CONSTRAINT "valid_payout_status" CHECK (("payout_status" = ANY (ARRAY['initiated'::"text", 'processing'::"text", 'pending'::"text", 'processed'::"text", 'failed'::"text", 'retrying'::"text", 'cancelled'::"text", 'on_hold'::"text"])))
);


ALTER TABLE "public"."payouts" OWNER TO "postgres";


ALTER TABLE "public"."payouts" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."payouts_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."platform_settings" (
    "id" bigint NOT NULL,
    "key" "text" NOT NULL,
    "value" "text" NOT NULL,
    "description" "text",
    "updated_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."platform_settings" OWNER TO "postgres";


ALTER TABLE "public"."platform_settings" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."platform_settings_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."platforms" (
    "id" bigint NOT NULL,
    "name" "text" NOT NULL,
    "status" "text" DEFAULT 'active'::"text" NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"(),
    CONSTRAINT "platforms_status_check" CHECK (("status" = ANY (ARRAY['active'::"text", 'inactive'::"text"])))
);


ALTER TABLE "public"."platforms" OWNER TO "postgres";


ALTER TABLE "public"."platforms" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."platforms_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."products" (
    "id" bigint NOT NULL,
    "brand_id" bigint,
    "platform_id" bigint,
    "name" "text" NOT NULL,
    "category" "text" NOT NULL,
    "price" numeric(10,2) NOT NULL,
    "product_link" "text" NOT NULL,
    "product_images" "text"[] NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"(),
    "sku" "text" NOT NULL,
    CONSTRAINT "products_price_check" CHECK (("price" >= (0)::numeric)),
    CONSTRAINT "products_product_link_check" CHECK (("product_link" ~ '^https?://.+$'::"text"))
);


ALTER TABLE "public"."products" OWNER TO "postgres";


ALTER TABLE "public"."products" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."products_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."users" (
    "id" bigint NOT NULL,
    "auth_user_id" "uuid",
    "user_type" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "status" "public"."user_status" DEFAULT 'active'::"public"."user_status" NOT NULL,
    "onboarding_completed" boolean DEFAULT false NOT NULL,
    CONSTRAINT "profiles_user_type_check" CHECK (("user_type" = ANY (ARRAY['shopper'::"text", 'brand'::"text", 'admin'::"text"])))
);


ALTER TABLE "public"."users" OWNER TO "postgres";


ALTER TABLE "public"."users" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."profiles_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."razorpay_smart_collect_webhooks" (
    "id" bigint NOT NULL,
    "event_type" "text" NOT NULL,
    "payload" "jsonb" NOT NULL,
    "received_at" timestamp without time zone DEFAULT "now"(),
    "processed" boolean DEFAULT false NOT NULL,
    "processed_at" timestamp without time zone
);


ALTER TABLE "public"."razorpay_smart_collect_webhooks" OWNER TO "postgres";


ALTER TABLE "public"."razorpay_smart_collect_webhooks" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."razorpay_smart_collect_webhooks_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."razorpay_va_webhooks" (
    "id" bigint NOT NULL,
    "event_type" "text" NOT NULL,
    "virtual_account_id" "text" NOT NULL,
    "brand_id" bigint,
    "payload" "jsonb" NOT NULL,
    "received_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "processed" boolean DEFAULT false NOT NULL,
    "processed_at" timestamp without time zone
);


ALTER TABLE "public"."razorpay_va_webhooks" OWNER TO "postgres";


ALTER TABLE "public"."razorpay_va_webhooks" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."razorpay_va_webhooks_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."razorpay_x_webhooks" (
    "id" bigint NOT NULL,
    "event_type" "text" NOT NULL,
    "payout_id" "text" NOT NULL,
    "enrollment_id" bigint,
    "payload" "jsonb" NOT NULL,
    "received_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "processed" boolean DEFAULT false NOT NULL,
    "processed_at" timestamp without time zone
);


ALTER TABLE "public"."razorpay_x_webhooks" OWNER TO "postgres";


ALTER TABLE "public"."razorpay_x_webhooks" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."razorpay_x_webhooks_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."shopper_profiles" (
    "id" bigint NOT NULL,
    "first_name" "text" NOT NULL,
    "last_name" "text" NOT NULL,
    "phone_number" "text" NOT NULL,
    "address" "text",
    "city" "text",
    "state" "text",
    "postal_code" "text",
    "dob" "date" NOT NULL,
    "profile_picture_url" "text",
    "payment_method" "text" NOT NULL,
    "bank_account_number" "text",
    "ifsc_code" "text",
    "upi_id" "text",
    "created_at" timestamp without time zone DEFAULT "now"(),
    "profile_id" bigint,
    CONSTRAINT "shopper_profiles_bank_account_number_check" CHECK (("bank_account_number" ~ '^[0-9]{9,18}$'::"text")),
    CONSTRAINT "shopper_profiles_dob_check" CHECK (("dob" <= (CURRENT_DATE - '18 years'::interval))),
    CONSTRAINT "shopper_profiles_ifsc_code_check" CHECK (("ifsc_code" ~ '^[A-Z]{4}0[A-Z0-9]{6}$'::"text")),
    CONSTRAINT "shopper_profiles_payment_method_check" CHECK (("payment_method" = ANY (ARRAY['bank_transfer'::"text", 'upi'::"text"]))),
    CONSTRAINT "shopper_profiles_phone_number_check" CHECK (("phone_number" ~ '^[0-9]{10}$'::"text")),
    CONSTRAINT "shopper_profiles_postal_code_check" CHECK (("postal_code" ~ '^[0-9]{5,6}$'::"text")),
    CONSTRAINT "shopper_profiles_upi_id_check" CHECK (("upi_id" ~ '^[a-zA-Z0-9.-_]{2,256}@[a-zA-Z]{2,64}$'::"text"))
);


ALTER TABLE "public"."shopper_profiles" OWNER TO "postgres";


ALTER TABLE "public"."shopper_profiles" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."shopper_profiles_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."zeptomail_webhooks" (
    "id" bigint NOT NULL,
    "event_type" "text" NOT NULL,
    "payload" "jsonb" NOT NULL,
    "received_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "processed" boolean DEFAULT false NOT NULL,
    "processed_at" timestamp without time zone
);


ALTER TABLE "public"."zeptomail_webhooks" OWNER TO "postgres";


ALTER TABLE "public"."zeptomail_webhooks" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."zeptomail_webhooks_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."zoho_books_webhooks" (
    "id" bigint NOT NULL,
    "event_type" "text" NOT NULL,
    "payload" "jsonb" NOT NULL,
    "received_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "processed" boolean DEFAULT false NOT NULL,
    "processed_at" timestamp without time zone
);


ALTER TABLE "public"."zoho_books_webhooks" OWNER TO "postgres";


ALTER TABLE "public"."zoho_books_webhooks" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."zoho_books_webhooks_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



ALTER TABLE ONLY "public"."admin_profiles"
    ADD CONSTRAINT "admin_profiles_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."admin_profiles"
    ADD CONSTRAINT "admin_profiles_phone_number_key" UNIQUE ("phone_number");



ALTER TABLE ONLY "public"."admin_profiles"
    ADD CONSTRAINT "admin_profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."admin_profiles"
    ADD CONSTRAINT "admin_profiles_profile_id_key" UNIQUE ("profile_id");



ALTER TABLE ONLY "public"."brand_profiles"
    ADD CONSTRAINT "brand_profiles_accounts_email_key" UNIQUE ("accounts_email");



ALTER TABLE ONLY "public"."brand_profiles"
    ADD CONSTRAINT "brand_profiles_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."brand_profiles"
    ADD CONSTRAINT "brand_profiles_phone_number_key" UNIQUE ("phone_number");



ALTER TABLE ONLY "public"."brand_profiles"
    ADD CONSTRAINT "brand_profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."brand_profiles"
    ADD CONSTRAINT "brand_profiles_profile_id_key" UNIQUE ("profile_id");



ALTER TABLE ONLY "public"."brand_profiles"
    ADD CONSTRAINT "brand_profiles_razorpay_va_id_key" UNIQUE ("razorpay_va_id");



ALTER TABLE ONLY "public"."brand_profiles"
    ADD CONSTRAINT "brand_profiles_razorpay_va_number_key" UNIQUE ("razorpay_va_number");



ALTER TABLE ONLY "public"."brand_profiles"
    ADD CONSTRAINT "brand_profiles_razorpay_va_upi_id_key" UNIQUE ("razorpay_va_upi_id");



ALTER TABLE ONLY "public"."brand_profiles"
    ADD CONSTRAINT "brand_profiles_zoho_books_id_key" UNIQUE ("zoho_books_id");



ALTER TABLE ONLY "public"."campaign_deliverables"
    ADD CONSTRAINT "campaign_deliverables_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."campaign_images"
    ADD CONSTRAINT "campaign_images_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."campaigns"
    ADD CONSTRAINT "campaigns_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."coupon_redemptions"
    ADD CONSTRAINT "coupon_redemptions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."coupons"
    ADD CONSTRAINT "coupons_code_key" UNIQUE ("code");



ALTER TABLE ONLY "public"."coupons"
    ADD CONSTRAINT "coupons_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."deliverable_submissions"
    ADD CONSTRAINT "deliverable_submissions_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."deliverables"
    ADD CONSTRAINT "deliverables_name_key" UNIQUE ("name");



ALTER TABLE ONLY "public"."deliverables"
    ADD CONSTRAINT "deliverables_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."enrollments"
    ADD CONSTRAINT "enrollments_order_id_key" UNIQUE ("order_id");



ALTER TABLE ONLY "public"."enrollments"
    ADD CONSTRAINT "enrollments_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."invoice_enrollments"
    ADD CONSTRAINT "invoice_enrollments_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."invoice_payments"
    ADD CONSTRAINT "invoice_payments_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."invoices"
    ADD CONSTRAINT "invoices_invoice_number_key" UNIQUE ("invoice_number");



ALTER TABLE ONLY "public"."invoices"
    ADD CONSTRAINT "invoices_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."invoices"
    ADD CONSTRAINT "invoices_zoho_invoice_id_key" UNIQUE ("zoho_invoice_id");



ALTER TABLE ONLY "public"."items"
    ADD CONSTRAINT "items_name_key" UNIQUE ("name");



ALTER TABLE ONLY "public"."items"
    ADD CONSTRAINT "items_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."notification_preferences"
    ADD CONSTRAINT "notification_preferences_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."payments"
    ADD CONSTRAINT "payments_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."payments"
    ADD CONSTRAINT "payments_razorpay_payment_id_key" UNIQUE ("razorpay_payment_id");



ALTER TABLE ONLY "public"."payments"
    ADD CONSTRAINT "payments_utr_reference_key" UNIQUE ("utr_reference");



ALTER TABLE ONLY "public"."payouts"
    ADD CONSTRAINT "payouts_order_id_key" UNIQUE ("order_id");



ALTER TABLE ONLY "public"."payouts"
    ADD CONSTRAINT "payouts_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."payouts"
    ADD CONSTRAINT "payouts_razorpay_payout_id_key" UNIQUE ("razorpay_payout_id");



ALTER TABLE ONLY "public"."platform_settings"
    ADD CONSTRAINT "platform_settings_key_key" UNIQUE ("key");



ALTER TABLE ONLY "public"."platform_settings"
    ADD CONSTRAINT "platform_settings_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."platforms"
    ADD CONSTRAINT "platforms_name_key" UNIQUE ("name");



ALTER TABLE ONLY "public"."platforms"
    ADD CONSTRAINT "platforms_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "products_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "products_sku_key" UNIQUE ("sku");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "profiles_auth_user_id_key" UNIQUE ("auth_user_id");



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."razorpay_smart_collect_webhooks"
    ADD CONSTRAINT "razorpay_smart_collect_webhooks_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."razorpay_va_webhooks"
    ADD CONSTRAINT "razorpay_va_webhooks_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."razorpay_x_webhooks"
    ADD CONSTRAINT "razorpay_x_webhooks_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."shopper_profiles"
    ADD CONSTRAINT "shopper_profiles_phone_number_key" UNIQUE ("phone_number");



ALTER TABLE ONLY "public"."shopper_profiles"
    ADD CONSTRAINT "shopper_profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."shopper_profiles"
    ADD CONSTRAINT "shopper_profiles_profile_id_key" UNIQUE ("profile_id");



ALTER TABLE ONLY "public"."payouts"
    ADD CONSTRAINT "unique_enrollment_order" UNIQUE ("enrollment_id", "order_id");



ALTER TABLE ONLY "public"."invoice_enrollments"
    ADD CONSTRAINT "unique_invoice_enrollment" UNIQUE ("invoice_id", "enrollment_id");



ALTER TABLE ONLY "public"."zeptomail_webhooks"
    ADD CONSTRAINT "zeptomail_webhooks_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."zoho_books_webhooks"
    ADD CONSTRAINT "zoho_books_webhooks_pkey" PRIMARY KEY ("id");



CREATE INDEX "idx_brand_id" ON "public"."campaigns" USING "btree" ("brand_id");



CREATE INDEX "idx_shopper_id" ON "public"."payouts" USING "btree" ("shopper_id");



CREATE OR REPLACE TRIGGER "after_invoice_insert" AFTER INSERT ON "public"."invoices" FOR EACH ROW EXECUTE FUNCTION "public"."trigger_generate_invoices"();



CREATE OR REPLACE TRIGGER "enforce_brand_approval" BEFORE INSERT OR UPDATE ON "public"."campaigns" FOR EACH ROW EXECUTE FUNCTION "public"."check_brand_approval"();



CREATE OR REPLACE TRIGGER "invoice_events_trigger" AFTER UPDATE OF "amount_paid" ON "public"."invoices" FOR EACH ROW EXECUTE FUNCTION "public"."handle_invoice_events"();



CREATE OR REPLACE TRIGGER "invoice_status_change" AFTER UPDATE OF "status" ON "public"."invoices" FOR EACH ROW WHEN (("old"."status" IS DISTINCT FROM "new"."status")) EXECUTE FUNCTION "public"."notify_on_invoice_status_change"();



CREATE OR REPLACE TRIGGER "prevent_payout_duplication" BEFORE INSERT ON "public"."payouts" FOR EACH ROW EXECUTE FUNCTION "public"."prevent_duplicate_payouts"();



ALTER TABLE ONLY "public"."admin_profiles"
    ADD CONSTRAINT "admin_profiles_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."brand_profiles"
    ADD CONSTRAINT "brand_profiles_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."campaign_deliverables"
    ADD CONSTRAINT "campaign_deliverables_campaign_id_fkey" FOREIGN KEY ("campaign_id") REFERENCES "public"."campaigns"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."campaign_deliverables"
    ADD CONSTRAINT "campaign_deliverables_deliverable_id_fkey" FOREIGN KEY ("deliverable_id") REFERENCES "public"."deliverables"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."campaign_images"
    ADD CONSTRAINT "campaign_images_campaign_id_fkey" FOREIGN KEY ("campaign_id") REFERENCES "public"."campaigns"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."campaigns"
    ADD CONSTRAINT "campaigns_approved_by_fkey" FOREIGN KEY ("approved_by") REFERENCES "public"."admin_profiles"("id");



ALTER TABLE ONLY "public"."campaigns"
    ADD CONSTRAINT "campaigns_brand_id_fkey" FOREIGN KEY ("brand_id") REFERENCES "public"."brand_profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."campaigns"
    ADD CONSTRAINT "campaigns_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."coupon_redemptions"
    ADD CONSTRAINT "coupon_redemptions_coupon_id_fkey" FOREIGN KEY ("coupon_id") REFERENCES "public"."coupons"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."coupon_redemptions"
    ADD CONSTRAINT "coupon_redemptions_enrollment_id_fkey" FOREIGN KEY ("enrollment_id") REFERENCES "public"."enrollments"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."coupon_redemptions"
    ADD CONSTRAINT "coupon_redemptions_shopper_id_fkey" FOREIGN KEY ("shopper_id") REFERENCES "public"."shopper_profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."coupons"
    ADD CONSTRAINT "coupons_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."admin_profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."coupons"
    ADD CONSTRAINT "coupons_specific_campaign_id_fkey" FOREIGN KEY ("specific_campaign_id") REFERENCES "public"."campaigns"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."deliverable_submissions"
    ADD CONSTRAINT "deliverable_submissions_campaign_deliverable_id_fkey" FOREIGN KEY ("campaign_deliverable_id") REFERENCES "public"."campaign_deliverables"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."deliverable_submissions"
    ADD CONSTRAINT "deliverable_submissions_enrollment_id_fkey" FOREIGN KEY ("enrollment_id") REFERENCES "public"."enrollments"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."deliverables"
    ADD CONSTRAINT "deliverables_platform_id_fkey" FOREIGN KEY ("platform_id") REFERENCES "public"."platforms"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."enrollments"
    ADD CONSTRAINT "enrollments_campaign_id_fkey" FOREIGN KEY ("campaign_id") REFERENCES "public"."campaigns"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."enrollments"
    ADD CONSTRAINT "enrollments_coupon_id_fkey" FOREIGN KEY ("coupon_id") REFERENCES "public"."coupons"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."invoices"
    ADD CONSTRAINT "fk_brand_id" FOREIGN KEY ("brand_id") REFERENCES "public"."brand_profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."payments"
    ADD CONSTRAINT "fk_brand_id" FOREIGN KEY ("brand_id") REFERENCES "public"."brand_profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."payouts"
    ADD CONSTRAINT "fk_enrollment_id" FOREIGN KEY ("enrollment_id") REFERENCES "public"."enrollments"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."invoice_enrollments"
    ADD CONSTRAINT "fk_enrollment_id" FOREIGN KEY ("enrollment_id") REFERENCES "public"."enrollments"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."enrollments"
    ADD CONSTRAINT "fk_enrollments_brand" FOREIGN KEY ("brand_id") REFERENCES "public"."brand_profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."invoice_payments"
    ADD CONSTRAINT "fk_invoice_id" FOREIGN KEY ("invoice_id") REFERENCES "public"."invoices"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."invoice_enrollments"
    ADD CONSTRAINT "fk_invoice_id" FOREIGN KEY ("invoice_id") REFERENCES "public"."invoices"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."invoice_payments"
    ADD CONSTRAINT "fk_payment_id" FOREIGN KEY ("payment_id") REFERENCES "public"."payments"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."payments"
    ADD CONSTRAINT "fk_razorpay_va_id" FOREIGN KEY ("razorpay_va_id") REFERENCES "public"."brand_profiles"("razorpay_va_id");



ALTER TABLE ONLY "public"."payouts"
    ADD CONSTRAINT "fk_shopper_id" FOREIGN KEY ("shopper_id") REFERENCES "public"."shopper_profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."invoice_payments"
    ADD CONSTRAINT "invoice_payments_invoice_id_fkey" FOREIGN KEY ("invoice_id") REFERENCES "public"."invoices"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."invoice_payments"
    ADD CONSTRAINT "invoice_payments_payment_id_fkey" FOREIGN KEY ("payment_id") REFERENCES "public"."payments"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."invoices"
    ADD CONSTRAINT "invoices_brand_id_fkey" FOREIGN KEY ("brand_id") REFERENCES "public"."brand_profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."notification_preferences"
    ADD CONSTRAINT "notification_preferences_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."payments"
    ADD CONSTRAINT "payments_brand_id_fkey" FOREIGN KEY ("brand_id") REFERENCES "public"."brand_profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."payments"
    ADD CONSTRAINT "payments_razorpay_va_id_fkey" FOREIGN KEY ("razorpay_va_id") REFERENCES "public"."brand_profiles"("razorpay_va_id");



ALTER TABLE ONLY "public"."payouts"
    ADD CONSTRAINT "payouts_enrollment_id_fkey" FOREIGN KEY ("enrollment_id") REFERENCES "public"."enrollments"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."payouts"
    ADD CONSTRAINT "payouts_shopper_id_fkey" FOREIGN KEY ("shopper_id") REFERENCES "public"."shopper_profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "products_brand_id_fkey" FOREIGN KEY ("brand_id") REFERENCES "public"."brand_profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "products_platform_id_fkey" FOREIGN KEY ("platform_id") REFERENCES "public"."platforms"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."users"
    ADD CONSTRAINT "profiles_auth_user_id_fkey" FOREIGN KEY ("auth_user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."razorpay_va_webhooks"
    ADD CONSTRAINT "razorpay_va_webhooks_brand_id_fkey" FOREIGN KEY ("brand_id") REFERENCES "public"."brand_profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."razorpay_x_webhooks"
    ADD CONSTRAINT "razorpay_x_webhooks_enrollment_id_fkey" FOREIGN KEY ("enrollment_id") REFERENCES "public"."enrollments"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."shopper_profiles"
    ADD CONSTRAINT "shopper_profiles_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."users"("id") ON DELETE CASCADE;



CREATE POLICY "Allow admins to approve campaigns" ON "public"."campaigns" FOR UPDATE TO "authenticated" USING (("auth"."role"() = 'admin'::"text")) WITH CHECK (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Allow admins to delete any campaign" ON "public"."campaigns" FOR DELETE TO "authenticated" USING (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Allow admins to delete any coupon" ON "public"."coupons" FOR DELETE TO "authenticated" USING (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Allow admins to delete any deliverable" ON "public"."deliverables" FOR DELETE TO "authenticated" USING (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Allow admins to delete any payment" ON "public"."payments" FOR DELETE TO "authenticated" USING (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Allow admins to insert profiles" ON "public"."admin_profiles" FOR INSERT TO "authenticated" WITH CHECK (("profile_id" = ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_user_id" = "auth"."uid"()))));



CREATE POLICY "Allow admins to update any campaign image" ON "public"."campaign_images" FOR UPDATE TO "authenticated" USING (("auth"."role"() = 'admin'::"text")) WITH CHECK (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Allow admins to update any coupon" ON "public"."coupons" FOR UPDATE TO "authenticated" USING (("auth"."role"() = 'admin'::"text")) WITH CHECK (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Allow admins to update any deliverable" ON "public"."deliverables" FOR UPDATE TO "authenticated" USING (("auth"."role"() = 'admin'::"text")) WITH CHECK (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Allow admins to update any invoice enrollment" ON "public"."invoice_enrollments" FOR UPDATE TO "authenticated" USING (("auth"."role"() = 'admin'::"text")) WITH CHECK (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Allow admins to update any payout" ON "public"."payouts" FOR UPDATE TO "authenticated" USING (("auth"."role"() = 'admin'::"text")) WITH CHECK (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Allow admins to update any product" ON "public"."products" FOR UPDATE TO "authenticated" USING (("auth"."role"() = 'admin'::"text")) WITH CHECK (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Allow admins to update any profile" ON "public"."brand_profiles" FOR UPDATE TO "authenticated" USING (("auth"."role"() = 'admin'::"text")) WITH CHECK (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Allow admins to update their own profiles" ON "public"."admin_profiles" FOR UPDATE TO "authenticated" USING (("profile_id" = ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_user_id" = "auth"."uid"())))) WITH CHECK (("profile_id" = ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_user_id" = "auth"."uid"()))));



CREATE POLICY "Allow admins to view all Razorpay X webhooks" ON "public"."razorpay_x_webhooks" FOR SELECT TO "authenticated" USING (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Allow admins to view all ZeptoMail webhooks" ON "public"."zeptomail_webhooks" FOR SELECT TO "authenticated" USING (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Allow admins to view all brand profiles" ON "public"."brand_profiles" FOR SELECT TO "authenticated" USING (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Allow admins to view all campaign images" ON "public"."campaign_images" FOR SELECT TO "authenticated" USING (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Allow admins to view all campaigns" ON "public"."campaigns" FOR SELECT TO "authenticated" USING (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Allow admins to view all coupon redemptions" ON "public"."coupon_redemptions" FOR SELECT TO "authenticated" USING (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Allow admins to view all coupons" ON "public"."coupons" FOR SELECT TO "authenticated" USING (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Allow admins to view all deliverable submissions" ON "public"."deliverable_submissions" FOR SELECT TO "authenticated" USING (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Allow admins to view all deliverables" ON "public"."deliverables" FOR SELECT TO "authenticated" USING (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Allow admins to view all invoice enrollments" ON "public"."invoice_enrollments" FOR SELECT TO "authenticated" USING (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Allow admins to view all invoice payments" ON "public"."invoice_payments" FOR SELECT TO "authenticated" USING (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Allow admins to view all notifications" ON "public"."notifications" FOR SELECT TO "authenticated" USING (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Allow admins to view all payments" ON "public"."payments" FOR SELECT TO "authenticated" USING (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Allow admins to view all payouts" ON "public"."payouts" FOR SELECT TO "authenticated" USING (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Allow admins to view all platform settings" ON "public"."platform_settings" FOR SELECT TO "authenticated" USING (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Allow admins to view all products" ON "public"."products" FOR SELECT TO "authenticated" USING (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Allow admins to view all profiles" ON "public"."admin_profiles" FOR SELECT TO "authenticated" USING (("auth"."role"() = 'admin'::"text"));



CREATE POLICY "Allow admins to view their own profiles" ON "public"."admin_profiles" FOR SELECT TO "authenticated" USING (("profile_id" = ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_user_id" = "auth"."uid"()))));



CREATE POLICY "Allow brands to approve or reject enrollments" ON "public"."enrollments" FOR UPDATE TO "authenticated" USING (("brand_id" IN ( SELECT "brand_profiles"."id"
   FROM "public"."brand_profiles"
  WHERE ("brand_profiles"."profile_id" = ( SELECT "users"."id"
           FROM "public"."users"
          WHERE ("users"."auth_user_id" = "auth"."uid"())))))) WITH CHECK (("brand_id" IN ( SELECT "brand_profiles"."id"
   FROM "public"."brand_profiles"
  WHERE ("brand_profiles"."profile_id" = ( SELECT "users"."id"
           FROM "public"."users"
          WHERE ("users"."auth_user_id" = "auth"."uid"()))))));



CREATE POLICY "Allow brands to delete their own profile" ON "public"."brand_profiles" FOR DELETE TO "authenticated" USING (("id" = ( SELECT "brand_profiles"."profile_id"
   FROM "public"."users"
  WHERE ("users"."auth_user_id" = "auth"."uid"()))));



CREATE POLICY "Allow brands to insert campaigns" ON "public"."campaigns" FOR INSERT TO "authenticated" WITH CHECK (("brand_id" = ( SELECT "brand_profiles"."id"
   FROM "public"."brand_profiles"
  WHERE ("brand_profiles"."profile_id" = ( SELECT "users"."id"
           FROM "public"."users"
          WHERE ("users"."auth_user_id" = "auth"."uid"()))))));



CREATE POLICY "Allow brands to insert profiles" ON "public"."brand_profiles" FOR INSERT TO "authenticated" WITH CHECK (("profile_id" = ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_user_id" = "auth"."uid"()))));



CREATE POLICY "Allow brands to update their own campaign deliverables" ON "public"."campaign_deliverables" FOR UPDATE TO "authenticated" USING (("campaign_id" IN ( SELECT "campaigns"."id"
   FROM "public"."campaigns"
  WHERE ("campaigns"."brand_id" = ( SELECT "brand_profiles"."id"
           FROM "public"."brand_profiles"
          WHERE ("brand_profiles"."profile_id" = ( SELECT "users"."id"
                   FROM "public"."users"
                  WHERE ("users"."auth_user_id" = "auth"."uid"()))))))));



CREATE POLICY "Allow brands to update their own campaign images" ON "public"."campaign_images" FOR UPDATE TO "authenticated" USING (("campaign_id" IN ( SELECT "campaigns"."id"
   FROM "public"."campaigns"
  WHERE ("campaigns"."brand_id" = ( SELECT "brand_profiles"."id"
           FROM "public"."brand_profiles"
          WHERE ("brand_profiles"."profile_id" = ( SELECT "users"."id"
                   FROM "public"."users"
                  WHERE ("users"."auth_user_id" = "auth"."uid"()))))))));



CREATE POLICY "Allow brands to update their own campaigns" ON "public"."campaigns" FOR UPDATE TO "authenticated" USING (("brand_id" = ( SELECT "brand_profiles"."id"
   FROM "public"."brand_profiles"
  WHERE ("brand_profiles"."profile_id" = ( SELECT "users"."id"
           FROM "public"."users"
          WHERE ("users"."auth_user_id" = "auth"."uid"())))))) WITH CHECK (("brand_id" = ( SELECT "brand_profiles"."id"
   FROM "public"."brand_profiles"
  WHERE ("brand_profiles"."profile_id" = ( SELECT "users"."id"
           FROM "public"."users"
          WHERE ("users"."auth_user_id" = "auth"."uid"()))))));



CREATE POLICY "Allow brands to update their own products" ON "public"."products" FOR UPDATE TO "authenticated" USING (("brand_id" = ( SELECT "brand_profiles"."id"
   FROM "public"."brand_profiles"
  WHERE ("brand_profiles"."profile_id" = ( SELECT "users"."id"
           FROM "public"."users"
          WHERE ("users"."auth_user_id" = "auth"."uid"()))))));



CREATE POLICY "Allow brands to update their own profile" ON "public"."brand_profiles" FOR UPDATE TO "authenticated" USING (("id" = ( SELECT "brand_profiles"."profile_id"
   FROM "public"."users"
  WHERE ("users"."auth_user_id" = "auth"."uid"())))) WITH CHECK (("id" = ( SELECT "brand_profiles"."profile_id"
   FROM "public"."users"
  WHERE ("users"."auth_user_id" = "auth"."uid"()))));



CREATE POLICY "Allow brands to update their own profiles" ON "public"."brand_profiles" FOR UPDATE TO "authenticated" USING (("profile_id" = ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_user_id" = "auth"."uid"())))) WITH CHECK (("profile_id" = ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_user_id" = "auth"."uid"()))));



CREATE POLICY "Allow brands to update their own profiles if not approved" ON "public"."brand_profiles" FOR UPDATE TO "authenticated" USING ((("profile_id" = ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_user_id" = "auth"."uid"()))) AND ("admin_approved" = false))) WITH CHECK ((("profile_id" = ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_user_id" = "auth"."uid"()))) AND ("admin_approved" = false)));



CREATE POLICY "Allow brands to view deliverable submissions for their campaign" ON "public"."deliverable_submissions" FOR SELECT TO "authenticated" USING (("campaign_deliverable_id" IN ( SELECT "campaign_deliverables"."id"
   FROM "public"."campaign_deliverables"
  WHERE ("campaign_deliverables"."campaign_id" IN ( SELECT "campaigns"."id"
           FROM "public"."campaigns"
          WHERE ("campaigns"."brand_id" = ( SELECT "brand_profiles"."id"
                   FROM "public"."brand_profiles"
                  WHERE ("brand_profiles"."profile_id" = ( SELECT "users"."id"
                           FROM "public"."users"
                          WHERE ("users"."auth_user_id" = "auth"."uid"()))))))))));



CREATE POLICY "Allow brands to view deliverables for their campaigns" ON "public"."deliverables" FOR SELECT TO "authenticated" USING (("platform_id" IN ( SELECT "products"."platform_id"
   FROM "public"."products"
  WHERE ("products"."brand_id" = ( SELECT "brand_profiles"."id"
           FROM "public"."brand_profiles"
          WHERE ("brand_profiles"."profile_id" = ( SELECT "users"."id"
                   FROM "public"."users"
                  WHERE ("users"."auth_user_id" = "auth"."uid"()))))))));



CREATE POLICY "Allow brands to view platform settings" ON "public"."platform_settings" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Allow brands to view their own campaign deliverables" ON "public"."campaign_deliverables" FOR SELECT TO "authenticated" USING (("campaign_id" IN ( SELECT "campaigns"."id"
   FROM "public"."campaigns"
  WHERE ("campaigns"."brand_id" = ( SELECT "brand_profiles"."id"
           FROM "public"."brand_profiles"
          WHERE ("brand_profiles"."profile_id" = ( SELECT "users"."id"
                   FROM "public"."users"
                  WHERE ("users"."auth_user_id" = "auth"."uid"()))))))));



CREATE POLICY "Allow brands to view their own campaign images" ON "public"."campaign_images" FOR SELECT TO "authenticated" USING (("campaign_id" IN ( SELECT "campaigns"."id"
   FROM "public"."campaigns"
  WHERE ("campaigns"."brand_id" = ( SELECT "brand_profiles"."id"
           FROM "public"."brand_profiles"
          WHERE ("brand_profiles"."profile_id" = ( SELECT "users"."id"
                   FROM "public"."users"
                  WHERE ("users"."auth_user_id" = "auth"."uid"()))))))));



CREATE POLICY "Allow brands to view their own campaigns" ON "public"."campaigns" FOR SELECT TO "authenticated" USING (("brand_id" = ( SELECT "brand_profiles"."id"
   FROM "public"."brand_profiles"
  WHERE ("brand_profiles"."profile_id" = ( SELECT "users"."id"
           FROM "public"."users"
          WHERE ("users"."auth_user_id" = "auth"."uid"()))))));



CREATE POLICY "Allow brands to view their own invoice enrollments" ON "public"."invoice_enrollments" FOR SELECT TO "authenticated" USING (("invoice_id" IN ( SELECT "invoices"."id"
   FROM "public"."invoices"
  WHERE ("invoices"."brand_id" = ( SELECT "brand_profiles"."id"
           FROM "public"."brand_profiles"
          WHERE ("brand_profiles"."profile_id" = ( SELECT "users"."id"
                   FROM "public"."users"
                  WHERE ("users"."auth_user_id" = "auth"."uid"()))))))));



CREATE POLICY "Allow brands to view their own invoice payments" ON "public"."invoice_payments" FOR SELECT TO "authenticated" USING (("invoice_id" IN ( SELECT "invoices"."id"
   FROM "public"."invoices"
  WHERE ("invoices"."brand_id" = ( SELECT "brand_profiles"."id"
           FROM "public"."brand_profiles"
          WHERE ("brand_profiles"."profile_id" = ( SELECT "users"."id"
                   FROM "public"."users"
                  WHERE ("users"."auth_user_id" = "auth"."uid"()))))))));



CREATE POLICY "Allow brands to view their own invoices" ON "public"."invoices" FOR SELECT TO "authenticated" USING (("brand_id" = ( SELECT "brand_profiles"."id"
   FROM "public"."brand_profiles"
  WHERE ("brand_profiles"."profile_id" = ( SELECT "users"."id"
           FROM "public"."users"
          WHERE ("users"."auth_user_id" = "auth"."uid"()))))));



CREATE POLICY "Allow brands to view their own payments" ON "public"."payments" FOR SELECT TO "authenticated" USING (("brand_id" = ( SELECT "brand_profiles"."id"
   FROM "public"."brand_profiles"
  WHERE ("brand_profiles"."profile_id" = ( SELECT "users"."id"
           FROM "public"."users"
          WHERE ("users"."auth_user_id" = "auth"."uid"()))))));



CREATE POLICY "Allow brands to view their own products" ON "public"."products" FOR SELECT TO "authenticated" USING (("brand_id" = ( SELECT "brand_profiles"."id"
   FROM "public"."brand_profiles"
  WHERE ("brand_profiles"."profile_id" = ( SELECT "users"."id"
           FROM "public"."users"
          WHERE ("users"."auth_user_id" = "auth"."uid"()))))));



CREATE POLICY "Allow brands to view their own profile" ON "public"."brand_profiles" FOR SELECT TO "authenticated" USING (("id" = ( SELECT "brand_profiles"."profile_id"
   FROM "public"."users"
  WHERE ("users"."auth_user_id" = "auth"."uid"()))));



CREATE POLICY "Allow brands to view their own profiles" ON "public"."brand_profiles" FOR SELECT TO "authenticated" USING (("profile_id" = ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_user_id" = "auth"."uid"()))));



CREATE POLICY "Allow shoppers to insert enrollments" ON "public"."enrollments" FOR INSERT TO "authenticated" WITH CHECK (("shopper_id" = ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_user_id" = "auth"."uid"()))));



CREATE POLICY "Allow shoppers to insert payouts" ON "public"."payouts" FOR INSERT TO "authenticated" WITH CHECK (("shopper_id" = ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_user_id" = "auth"."uid"()))));



CREATE POLICY "Allow shoppers to insert profiles" ON "public"."shopper_profiles" FOR INSERT TO "authenticated" WITH CHECK ((("profile_id" = ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_user_id" = "auth"."uid"()))) AND (NOT (EXISTS ( SELECT 1
   FROM "public"."shopper_profiles" "shopper_profiles_1"
  WHERE ("shopper_profiles_1"."profile_id" = ( SELECT "users"."id"
           FROM "public"."users"
          WHERE ("users"."auth_user_id" = "auth"."uid"()))))))));



CREATE POLICY "Allow shoppers to update their own deliverable submissions" ON "public"."deliverable_submissions" FOR UPDATE TO "authenticated" USING (("enrollment_id" IN ( SELECT "enrollments"."id"
   FROM "public"."enrollments"
  WHERE ("enrollments"."shopper_id" = ( SELECT "shopper_profiles"."id"
           FROM "public"."shopper_profiles"
          WHERE ("shopper_profiles"."profile_id" = ( SELECT "users"."id"
                   FROM "public"."users"
                  WHERE ("users"."auth_user_id" = "auth"."uid"()))))))));



CREATE POLICY "Allow shoppers to update their own profiles" ON "public"."shopper_profiles" FOR UPDATE TO "authenticated" USING (("profile_id" = ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_user_id" = "auth"."uid"())))) WITH CHECK (("profile_id" = ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_user_id" = "auth"."uid"()))));



CREATE POLICY "Allow shoppers to view their own coupon redemptions" ON "public"."coupon_redemptions" FOR SELECT TO "authenticated" USING (("shopper_id" = ( SELECT "shopper_profiles"."id"
   FROM "public"."shopper_profiles"
  WHERE ("shopper_profiles"."profile_id" = ( SELECT "users"."id"
           FROM "public"."users"
          WHERE ("users"."auth_user_id" = "auth"."uid"()))))));



CREATE POLICY "Allow shoppers to view their own deliverable submissions" ON "public"."deliverable_submissions" FOR SELECT TO "authenticated" USING (("enrollment_id" IN ( SELECT "enrollments"."id"
   FROM "public"."enrollments"
  WHERE ("enrollments"."shopper_id" = ( SELECT "shopper_profiles"."id"
           FROM "public"."shopper_profiles"
          WHERE ("shopper_profiles"."profile_id" = ( SELECT "users"."id"
                   FROM "public"."users"
                  WHERE ("users"."auth_user_id" = "auth"."uid"()))))))));



CREATE POLICY "Allow shoppers to view their own enrollments" ON "public"."enrollments" FOR SELECT TO "authenticated" USING (("shopper_id" = ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_user_id" = "auth"."uid"()))));



CREATE POLICY "Allow shoppers to view their own payouts" ON "public"."payouts" FOR SELECT TO "authenticated" USING (("shopper_id" = ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_user_id" = "auth"."uid"()))));



CREATE POLICY "Allow shoppers to view their own profiles and related notificat" ON "public"."shopper_profiles" FOR SELECT TO "authenticated" USING ((("profile_id" = ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_user_id" = "auth"."uid"()))) OR (EXISTS ( SELECT 1
   FROM "public"."notifications"
  WHERE ("notifications"."user_id" = ( SELECT "users"."id"
           FROM "public"."users"
          WHERE ("users"."auth_user_id" = "auth"."uid"())))))));



CREATE POLICY "Allow users to delete their own enrollments" ON "public"."enrollments" FOR DELETE TO "authenticated" USING (("shopper_id" = ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_user_id" = "auth"."uid"()))));



CREATE POLICY "Allow users to insert enrollments" ON "public"."enrollments" FOR INSERT TO "authenticated" WITH CHECK (("shopper_id" = ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_user_id" = "auth"."uid"()))));



CREATE POLICY "Allow users to update their own enrollments" ON "public"."enrollments" FOR UPDATE TO "authenticated" USING (("shopper_id" = ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_user_id" = "auth"."uid"())))) WITH CHECK (("shopper_id" = ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_user_id" = "auth"."uid"()))));



CREATE POLICY "Allow users to view their own enrollments" ON "public"."enrollments" FOR SELECT TO "authenticated" USING (("shopper_id" = ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_user_id" = "auth"."uid"()))));



CREATE POLICY "Allow users to view their own notification preferences" ON "public"."notification_preferences" FOR SELECT TO "authenticated" USING (("user_id" = ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_user_id" = "auth"."uid"()))));



CREATE POLICY "Allow users to view their own notifications" ON "public"."notifications" FOR SELECT TO "authenticated" USING (("user_id" = ( SELECT "users"."id"
   FROM "public"."users"
  WHERE ("users"."auth_user_id" = "auth"."uid"()))));



ALTER TABLE "public"."campaign_deliverables" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."campaign_images" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."deliverables" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."enrollments" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."invoice_enrollments" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."invoice_payments" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."invoices" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."notification_preferences" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."notifications" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."payments" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."payouts" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."platforms" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."products" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."razorpay_smart_collect_webhooks" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."razorpay_va_webhooks" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."razorpay_x_webhooks" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."shopper_profiles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."zeptomail_webhooks" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."zoho_books_webhooks" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";








GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";




































































































































































































































































































































GRANT ALL ON FUNCTION "public"."allocate_payment_to_invoices"("payment_id" bigint, "brand_id" bigint, "payment_amount" numeric) TO "anon";
GRANT ALL ON FUNCTION "public"."allocate_payment_to_invoices"("payment_id" bigint, "brand_id" bigint, "payment_amount" numeric) TO "authenticated";
GRANT ALL ON FUNCTION "public"."allocate_payment_to_invoices"("payment_id" bigint, "brand_id" bigint, "payment_amount" numeric) TO "service_role";



GRANT ALL ON FUNCTION "public"."approve_or_reject_enrollment"("enrollment_id" bigint, "is_approved" boolean, "rejection_reason" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."approve_or_reject_enrollment"("enrollment_id" bigint, "is_approved" boolean, "rejection_reason" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."approve_or_reject_enrollment"("enrollment_id" bigint, "is_approved" boolean, "rejection_reason" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."auto_expire_campaigns"() TO "anon";
GRANT ALL ON FUNCTION "public"."auto_expire_campaigns"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."auto_expire_campaigns"() TO "service_role";



GRANT ALL ON FUNCTION "public"."auto_expire_enrollment"() TO "anon";
GRANT ALL ON FUNCTION "public"."auto_expire_enrollment"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."auto_expire_enrollment"() TO "service_role";



GRANT ALL ON FUNCTION "public"."auto_mark_overdue_invoices"() TO "anon";
GRANT ALL ON FUNCTION "public"."auto_mark_overdue_invoices"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."auto_mark_overdue_invoices"() TO "service_role";



GRANT ALL ON FUNCTION "public"."auto_refund_excess_payments"() TO "anon";
GRANT ALL ON FUNCTION "public"."auto_refund_excess_payments"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."auto_refund_excess_payments"() TO "service_role";



GRANT ALL ON FUNCTION "public"."check_brand_approval"() TO "anon";
GRANT ALL ON FUNCTION "public"."check_brand_approval"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_brand_approval"() TO "service_role";



GRANT ALL ON FUNCTION "public"."create_brand_integrations"("brand_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."create_brand_integrations"("brand_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_brand_integrations"("brand_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_payouts_for_invoice"("invoice_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."create_payouts_for_invoice"("invoice_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_payouts_for_invoice"("invoice_id" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."enforce_one_time_coupon"() TO "anon";
GRANT ALL ON FUNCTION "public"."enforce_one_time_coupon"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."enforce_one_time_coupon"() TO "service_role";



GRANT ALL ON FUNCTION "public"."expire_coupons"() TO "anon";
GRANT ALL ON FUNCTION "public"."expire_coupons"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."expire_coupons"() TO "service_role";



GRANT ALL ON FUNCTION "public"."generate_and_link_weekly_invoices"() TO "anon";
GRANT ALL ON FUNCTION "public"."generate_and_link_weekly_invoices"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."generate_and_link_weekly_invoices"() TO "service_role";



GRANT ALL ON FUNCTION "public"."generate_invoices_in_zoho_books"() TO "anon";
GRANT ALL ON FUNCTION "public"."generate_invoices_in_zoho_books"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."generate_invoices_in_zoho_books"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_combined_payout_notifications"("enrollment_id" bigint, "amount" numeric, "status" "text", "failure_reason" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."handle_combined_payout_notifications"("enrollment_id" bigint, "amount" numeric, "status" "text", "failure_reason" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_combined_payout_notifications"("enrollment_id" bigint, "amount" numeric, "status" "text", "failure_reason" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_enrollment_notifications"("enrollment_id" bigint, "status_change" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."handle_enrollment_notifications"("enrollment_id" bigint, "status_change" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_enrollment_notifications"("enrollment_id" bigint, "status_change" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_invoice_events"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_invoice_events"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_invoice_events"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_invoice_events"("invoice_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."handle_invoice_events"("invoice_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_invoice_events"("invoice_id" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."notify_admins_about_new_brand"() TO "anon";
GRANT ALL ON FUNCTION "public"."notify_admins_about_new_brand"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."notify_admins_about_new_brand"() TO "service_role";



GRANT ALL ON FUNCTION "public"."notify_brands_about_invoices"("invoice_id" bigint, "brand_id" bigint, "is_overdue" boolean, "due_date" timestamp with time zone) TO "anon";
GRANT ALL ON FUNCTION "public"."notify_brands_about_invoices"("invoice_id" bigint, "brand_id" bigint, "is_overdue" boolean, "due_date" timestamp with time zone) TO "authenticated";
GRANT ALL ON FUNCTION "public"."notify_brands_about_invoices"("invoice_id" bigint, "brand_id" bigint, "is_overdue" boolean, "due_date" timestamp with time zone) TO "service_role";



GRANT ALL ON FUNCTION "public"."notify_brands_about_pending_approvals"() TO "anon";
GRANT ALL ON FUNCTION "public"."notify_brands_about_pending_approvals"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."notify_brands_about_pending_approvals"() TO "service_role";



GRANT ALL ON FUNCTION "public"."notify_campaign_status"("campaign_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."notify_campaign_status"("campaign_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."notify_campaign_status"("campaign_id" bigint) TO "service_role";



GRANT ALL ON FUNCTION "public"."notify_invoice_status"("invoice_id" bigint, "event_type" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."notify_invoice_status"("invoice_id" bigint, "event_type" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."notify_invoice_status"("invoice_id" bigint, "event_type" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."notify_on_invoice_status_change"() TO "anon";
GRANT ALL ON FUNCTION "public"."notify_on_invoice_status_change"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."notify_on_invoice_status_change"() TO "service_role";



GRANT ALL ON FUNCTION "public"."notify_pending_deliverables"() TO "anon";
GRANT ALL ON FUNCTION "public"."notify_pending_deliverables"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."notify_pending_deliverables"() TO "service_role";



GRANT ALL ON FUNCTION "public"."notify_shoppers_about_submission_deadline"() TO "anon";
GRANT ALL ON FUNCTION "public"."notify_shoppers_about_submission_deadline"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."notify_shoppers_about_submission_deadline"() TO "service_role";



GRANT ALL ON FUNCTION "public"."prevent_duplicate_payouts"() TO "anon";
GRANT ALL ON FUNCTION "public"."prevent_duplicate_payouts"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."prevent_duplicate_payouts"() TO "service_role";



GRANT ALL ON FUNCTION "public"."process_pending_payouts"() TO "anon";
GRANT ALL ON FUNCTION "public"."process_pending_payouts"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."process_pending_payouts"() TO "service_role";



GRANT ALL ON FUNCTION "public"."retry_failed_payouts_on_payment_update"() TO "anon";
GRANT ALL ON FUNCTION "public"."retry_failed_payouts_on_payment_update"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."retry_failed_payouts_on_payment_update"() TO "service_role";



GRANT ALL ON FUNCTION "public"."sync_invoice_status_from_zoho"("zoho_invoice_id" "text", "new_status" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."sync_invoice_status_from_zoho"("zoho_invoice_id" "text", "new_status" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."sync_invoice_status_from_zoho"("zoho_invoice_id" "text", "new_status" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."trigger_generate_invoices"() TO "anon";
GRANT ALL ON FUNCTION "public"."trigger_generate_invoices"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."trigger_generate_invoices"() TO "service_role";



























GRANT ALL ON TABLE "public"."admin_profiles" TO "anon";
GRANT ALL ON TABLE "public"."admin_profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."admin_profiles" TO "service_role";



GRANT ALL ON SEQUENCE "public"."admin_profiles_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."admin_profiles_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."admin_profiles_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."brand_profiles" TO "anon";
GRANT ALL ON TABLE "public"."brand_profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."brand_profiles" TO "service_role";



GRANT ALL ON SEQUENCE "public"."brand_profiles_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."brand_profiles_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."brand_profiles_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."campaign_deliverables" TO "anon";
GRANT ALL ON TABLE "public"."campaign_deliverables" TO "authenticated";
GRANT ALL ON TABLE "public"."campaign_deliverables" TO "service_role";



GRANT ALL ON SEQUENCE "public"."campaign_deliverables_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."campaign_deliverables_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."campaign_deliverables_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."campaign_images" TO "anon";
GRANT ALL ON TABLE "public"."campaign_images" TO "authenticated";
GRANT ALL ON TABLE "public"."campaign_images" TO "service_role";



GRANT ALL ON SEQUENCE "public"."campaign_images_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."campaign_images_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."campaign_images_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."campaigns" TO "anon";
GRANT ALL ON TABLE "public"."campaigns" TO "authenticated";
GRANT ALL ON TABLE "public"."campaigns" TO "service_role";



GRANT ALL ON SEQUENCE "public"."campaigns_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."campaigns_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."campaigns_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."coupon_redemptions" TO "anon";
GRANT ALL ON TABLE "public"."coupon_redemptions" TO "authenticated";
GRANT ALL ON TABLE "public"."coupon_redemptions" TO "service_role";



GRANT ALL ON SEQUENCE "public"."coupon_redemptions_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."coupon_redemptions_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."coupon_redemptions_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."coupons" TO "anon";
GRANT ALL ON TABLE "public"."coupons" TO "authenticated";
GRANT ALL ON TABLE "public"."coupons" TO "service_role";



GRANT ALL ON SEQUENCE "public"."coupons_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."coupons_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."coupons_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."deliverable_submissions" TO "anon";
GRANT ALL ON TABLE "public"."deliverable_submissions" TO "authenticated";
GRANT ALL ON TABLE "public"."deliverable_submissions" TO "service_role";



GRANT ALL ON SEQUENCE "public"."deliverable_submissions_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."deliverable_submissions_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."deliverable_submissions_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."deliverables" TO "anon";
GRANT ALL ON TABLE "public"."deliverables" TO "authenticated";
GRANT ALL ON TABLE "public"."deliverables" TO "service_role";



GRANT ALL ON SEQUENCE "public"."deliverables_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."deliverables_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."deliverables_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."enrollments" TO "anon";
GRANT ALL ON TABLE "public"."enrollments" TO "authenticated";
GRANT ALL ON TABLE "public"."enrollments" TO "service_role";



GRANT ALL ON SEQUENCE "public"."enrollments_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."enrollments_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."enrollments_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."invoice_enrollments" TO "anon";
GRANT ALL ON TABLE "public"."invoice_enrollments" TO "authenticated";
GRANT ALL ON TABLE "public"."invoice_enrollments" TO "service_role";



GRANT ALL ON SEQUENCE "public"."invoice_enrollments_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."invoice_enrollments_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."invoice_enrollments_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."invoice_payments" TO "anon";
GRANT ALL ON TABLE "public"."invoice_payments" TO "authenticated";
GRANT ALL ON TABLE "public"."invoice_payments" TO "service_role";



GRANT ALL ON SEQUENCE "public"."invoice_payments_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."invoice_payments_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."invoice_payments_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."invoices" TO "anon";
GRANT ALL ON TABLE "public"."invoices" TO "authenticated";
GRANT ALL ON TABLE "public"."invoices" TO "service_role";



GRANT ALL ON SEQUENCE "public"."invoices_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."invoices_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."invoices_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."items" TO "anon";
GRANT ALL ON TABLE "public"."items" TO "authenticated";
GRANT ALL ON TABLE "public"."items" TO "service_role";



GRANT ALL ON SEQUENCE "public"."items_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."items_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."items_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."notification_preferences" TO "anon";
GRANT ALL ON TABLE "public"."notification_preferences" TO "authenticated";
GRANT ALL ON TABLE "public"."notification_preferences" TO "service_role";



GRANT ALL ON SEQUENCE "public"."notification_preferences_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."notification_preferences_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."notification_preferences_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."notifications" TO "anon";
GRANT ALL ON TABLE "public"."notifications" TO "authenticated";
GRANT ALL ON TABLE "public"."notifications" TO "service_role";



GRANT ALL ON SEQUENCE "public"."notifications_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."notifications_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."notifications_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."payments" TO "anon";
GRANT ALL ON TABLE "public"."payments" TO "authenticated";
GRANT ALL ON TABLE "public"."payments" TO "service_role";



GRANT ALL ON SEQUENCE "public"."payments_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."payments_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."payments_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."payouts" TO "anon";
GRANT ALL ON TABLE "public"."payouts" TO "authenticated";
GRANT ALL ON TABLE "public"."payouts" TO "service_role";



GRANT ALL ON SEQUENCE "public"."payouts_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."payouts_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."payouts_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."platform_settings" TO "anon";
GRANT ALL ON TABLE "public"."platform_settings" TO "authenticated";
GRANT ALL ON TABLE "public"."platform_settings" TO "service_role";



GRANT ALL ON SEQUENCE "public"."platform_settings_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."platform_settings_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."platform_settings_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."platforms" TO "anon";
GRANT ALL ON TABLE "public"."platforms" TO "authenticated";
GRANT ALL ON TABLE "public"."platforms" TO "service_role";



GRANT ALL ON SEQUENCE "public"."platforms_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."platforms_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."platforms_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."products" TO "anon";
GRANT ALL ON TABLE "public"."products" TO "authenticated";
GRANT ALL ON TABLE "public"."products" TO "service_role";



GRANT ALL ON SEQUENCE "public"."products_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."products_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."products_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."users" TO "anon";
GRANT ALL ON TABLE "public"."users" TO "authenticated";
GRANT ALL ON TABLE "public"."users" TO "service_role";



GRANT ALL ON SEQUENCE "public"."profiles_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."profiles_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."profiles_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."razorpay_smart_collect_webhooks" TO "anon";
GRANT ALL ON TABLE "public"."razorpay_smart_collect_webhooks" TO "authenticated";
GRANT ALL ON TABLE "public"."razorpay_smart_collect_webhooks" TO "service_role";



GRANT ALL ON SEQUENCE "public"."razorpay_smart_collect_webhooks_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."razorpay_smart_collect_webhooks_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."razorpay_smart_collect_webhooks_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."razorpay_va_webhooks" TO "anon";
GRANT ALL ON TABLE "public"."razorpay_va_webhooks" TO "authenticated";
GRANT ALL ON TABLE "public"."razorpay_va_webhooks" TO "service_role";



GRANT ALL ON SEQUENCE "public"."razorpay_va_webhooks_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."razorpay_va_webhooks_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."razorpay_va_webhooks_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."razorpay_x_webhooks" TO "anon";
GRANT ALL ON TABLE "public"."razorpay_x_webhooks" TO "authenticated";
GRANT ALL ON TABLE "public"."razorpay_x_webhooks" TO "service_role";



GRANT ALL ON SEQUENCE "public"."razorpay_x_webhooks_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."razorpay_x_webhooks_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."razorpay_x_webhooks_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."shopper_profiles" TO "anon";
GRANT ALL ON TABLE "public"."shopper_profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."shopper_profiles" TO "service_role";



GRANT ALL ON SEQUENCE "public"."shopper_profiles_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."shopper_profiles_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."shopper_profiles_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."zeptomail_webhooks" TO "anon";
GRANT ALL ON TABLE "public"."zeptomail_webhooks" TO "authenticated";
GRANT ALL ON TABLE "public"."zeptomail_webhooks" TO "service_role";



GRANT ALL ON SEQUENCE "public"."zeptomail_webhooks_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."zeptomail_webhooks_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."zeptomail_webhooks_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."zoho_books_webhooks" TO "anon";
GRANT ALL ON TABLE "public"."zoho_books_webhooks" TO "authenticated";
GRANT ALL ON TABLE "public"."zoho_books_webhooks" TO "service_role";



GRANT ALL ON SEQUENCE "public"."zoho_books_webhooks_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."zoho_books_webhooks_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."zoho_books_webhooks_id_seq" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";






























RESET ALL;
