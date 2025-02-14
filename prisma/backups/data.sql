SET session_replication_role = replica;

--
-- PostgreSQL database dump
--

-- Dumped from database version 15.8
-- Dumped by pg_dump version 15.8

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

--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") FROM stdin;
\.


--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."flow_state" ("id", "user_id", "auth_code", "code_challenge_method", "code_challenge", "provider_type", "provider_access_token", "provider_refresh_token", "created_at", "updated_at", "authentication_method", "auth_code_issued_at") FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."users" ("instance_id", "id", "aud", "role", "email", "encrypted_password", "email_confirmed_at", "invited_at", "confirmation_token", "confirmation_sent_at", "recovery_token", "recovery_sent_at", "email_change_token_new", "email_change", "email_change_sent_at", "last_sign_in_at", "raw_app_meta_data", "raw_user_meta_data", "is_super_admin", "created_at", "updated_at", "phone", "phone_confirmed_at", "phone_change", "phone_change_token", "phone_change_sent_at", "email_change_token_current", "email_change_confirm_status", "banned_until", "reauthentication_token", "reauthentication_sent_at", "is_sso_user", "deleted_at", "is_anonymous", "onboarding_completed") FROM stdin;
\.


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."identities" ("provider_id", "user_id", "identity_data", "provider", "last_sign_in_at", "created_at", "updated_at", "id") FROM stdin;
\.


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."instances" ("id", "uuid", "raw_base_config", "created_at", "updated_at") FROM stdin;
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."sessions" ("id", "user_id", "created_at", "updated_at", "factor_id", "aal", "not_after", "refreshed_at", "user_agent", "ip", "tag") FROM stdin;
\.


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."mfa_amr_claims" ("session_id", "created_at", "updated_at", "authentication_method", "id") FROM stdin;
\.


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."mfa_factors" ("id", "user_id", "friendly_name", "factor_type", "status", "created_at", "updated_at", "secret", "phone", "last_challenged_at", "web_authn_credential", "web_authn_aaguid") FROM stdin;
\.


--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."mfa_challenges" ("id", "factor_id", "created_at", "verified_at", "ip_address", "otp_code", "web_authn_session_data") FROM stdin;
\.


--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."one_time_tokens" ("id", "user_id", "token_type", "token_hash", "relates_to", "created_at", "updated_at") FROM stdin;
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."refresh_tokens" ("instance_id", "id", "token", "user_id", "revoked", "created_at", "updated_at", "parent", "session_id") FROM stdin;
\.


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."sso_providers" ("id", "resource_id", "created_at", "updated_at") FROM stdin;
\.


--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."saml_providers" ("id", "sso_provider_id", "entity_id", "metadata_xml", "metadata_url", "attribute_mapping", "created_at", "updated_at", "name_id_format") FROM stdin;
\.


--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."saml_relay_states" ("id", "sso_provider_id", "request_id", "for_email", "redirect_to", "created_at", "updated_at", "flow_state_id") FROM stdin;
\.


--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."sso_domains" ("id", "sso_provider_id", "domain", "created_at", "updated_at") FROM stdin;
\.


--
-- Data for Name: key; Type: TABLE DATA; Schema: pgsodium; Owner: supabase_admin
--

COPY "pgsodium"."key" ("id", "status", "created", "expires", "key_type", "key_id", "key_context", "name", "associated_data", "raw_key", "raw_key_nonce", "parent_key", "comment", "user_data") FROM stdin;
0bef341e-59b8-49e8-8a23-0d3119c4bd97	valid	2025-02-14 04:29:01.536929+00	\N	aead-det	1	\\x7067736f6469756d	razorpay		\N	\N	\N	\N	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."users" ("id", "auth_user_id", "user_type", "created_at", "status") FROM stdin;
\.


--
-- Data for Name: admin_profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."admin_profiles" ("id", "first_name", "last_name", "phone_number", "email", "profile_picture_url", "role", "created_at", "profile_id", "onboarding_completed") FROM stdin;
\.


--
-- Data for Name: brand_profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."brand_profiles" ("id", "brand_name", "company_name", "contact_person", "phone_number", "email", "accounts_email", "website", "gst_number", "business_address", "city", "state", "postal_code", "brand_logo_url", "payment_terms", "razorpay_va_id", "razorpay_va_number", "razorpay_va_ifsc", "razorpay_va_upi_id", "zoho_books_id", "created_at", "profile_id", "onboarding_completed", "admin_approved", "tds_rate") FROM stdin;
\.


--
-- Data for Name: platforms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."platforms" ("id", "name", "status", "created_at") FROM stdin;
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."products" ("id", "brand_id", "platform_id", "name", "category", "price", "product_link", "product_images", "created_at", "sku") FROM stdin;
\.


--
-- Data for Name: campaigns; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."campaigns" ("id", "brand_id", "title", "description", "product_id", "start_date", "end_date", "enrollment_deadline", "rebate_percentage", "incentive_amount", "max_enrollments", "approval_status", "approval_remarks", "approval_date", "approved_by", "terms_and_conditions", "created_at", "status") FROM stdin;
\.


--
-- Data for Name: deliverables; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."deliverables" ("id", "name", "category", "platform_id", "status", "require_screenshot", "require_link", "created_at") FROM stdin;
\.


--
-- Data for Name: campaign_deliverables; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."campaign_deliverables" ("id", "campaign_id", "deliverable_id", "min_word_count", "required_images", "required_videos", "hashtags", "mentions", "is_mandatory", "created_at") FROM stdin;
\.


--
-- Data for Name: campaign_images; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."campaign_images" ("id", "campaign_id", "image_url", "created_at") FROM stdin;
\.


--
-- Data for Name: coupons; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."coupons" ("id", "code", "discount_percentage", "bonus_amount", "usage_limit", "one_time_use", "valid_from", "valid_until", "applicable_to", "specific_campaign_id", "created_by", "status", "created_at") FROM stdin;
\.


--
-- Data for Name: shopper_profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."shopper_profiles" ("id", "first_name", "last_name", "phone_number", "address", "city", "state", "postal_code", "dob", "profile_picture_url", "payment_method", "bank_account_number", "ifsc_code", "upi_id", "created_at", "profile_id", "onboarding_completed") FROM stdin;
\.


--
-- Data for Name: enrollments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."enrollments" ("id", "campaign_id", "shopper_id", "order_id", "rebate_amount", "bonus_amount", "coupon_adjustment", "incentive_amount", "deduction_amount", "platform_profit", "approval_remarks", "created_at", "coupon_id", "is_invoiced", "status", "rejection_count") FROM stdin;
\.


--
-- Data for Name: coupon_redemptions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."coupon_redemptions" ("id", "coupon_id", "shopper_id", "enrollment_id", "redeemed_at", "status") FROM stdin;
\.


--
-- Data for Name: deliverable_submissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."deliverable_submissions" ("id", "enrollment_id", "campaign_deliverable_id", "proof_link", "proof_screenshot", "created_at") FROM stdin;
\.


--
-- Data for Name: invoices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."invoices" ("id", "brand_id", "invoice_number", "total_order_amount", "total_incentive_amount", "subtotal", "gst_amount", "total_amount", "amount_paid", "status", "issued_at", "due_date", "zoho_invoice_id", "created_at", "tds_percentage", "tds_amount", "net_amount", "payout_processed") FROM stdin;
\.


--
-- Data for Name: invoice_enrollments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."invoice_enrollments" ("id", "invoice_id", "enrollment_id", "created_at") FROM stdin;
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."payments" ("id", "brand_id", "amount", "status", "razorpay_payment_id", "utr_reference", "transaction_source", "razorpay_va_id", "received_at", "created_at") FROM stdin;
\.


--
-- Data for Name: invoice_payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."invoice_payments" ("id", "invoice_id", "payment_id", "applied_amount", "remaining_amount", "created_at") FROM stdin;
\.


--
-- Data for Name: notification_preferences; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."notification_preferences" ("id", "user_id", "in_app", "email", "whatsapp", "push_notifications", "updated_at", "created_at") FROM stdin;
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."notifications" ("id", "user_id", "title", "message", "type", "thumbnail_url", "context_type", "context_id", "action_link", "status", "created_at") FROM stdin;
\.


--
-- Data for Name: payouts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."payouts" ("id", "enrollment_id", "shopper_id", "amount", "razorpay_payout_id", "retry_count", "last_retry_at", "failure_reason", "processed_at", "created_at", "payout_status", "order_id") FROM stdin;
\.


--
-- Data for Name: platform_settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."platform_settings" ("id", "key", "value", "description", "updated_at", "created_at") FROM stdin;
\.


--
-- Data for Name: razorpay_smart_collect_webhooks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."razorpay_smart_collect_webhooks" ("id", "event_type", "payload", "received_at", "processed", "processed_at") FROM stdin;
1	virtual_account.credited	{"payment": {"entity": {"id": "pay_PvPBWuV9woiXA8", "fee": 1180, "tax": 180, "vpa": null, "bank": null, "email": null, "notes": [], "amount": 5665600, "entity": "payment", "method": "bank_transfer", "reward": null, "status": "captured", "wallet": null, "card_id": null, "contact": null, "captured": true, "currency": "INR", "order_id": null, "created_at": 1739495645, "error_code": null, "error_step": null, "invoice_id": null, "description": "", "error_reason": null, "error_source": null, "acquirer_data": {}, "international": false, "refund_status": null, "amount_refunded": 0, "error_description": null}}, "bank_transfer": {"entity": {"id": "bt_PvPBWmp1qU0Npv", "mode": "NEFT", "amount": 5665600, "entity": "bank_transfer", "payment_id": "pay_PvPBWuV9woiXA8", "bank_reference": "173949564190", "payer_bank_account": {"id": "ba_PvPBXpffJ99UiU", "ifsc": "RAZR0000001", "name": "ZIad Hossam", "notes": [], "entity": "bank_account", "bank_name": null, "account_number": "765432123456789"}, "virtual_account_id": "va_NTFXLYIDccRsDC"}}, "virtual_account": {"entity": {"id": "va_NTFXLYIDccRsDC", "name": "ZIad Hossam", "notes": [], "entity": "virtual_account", "status": "active", "close_by": null, "closed_at": null, "receivers": [{"id": "ba_NTFXLhXdzcxbDw", "ifsc": "RAZR0000001", "name": "ZIad Hossam", "notes": [], "entity": "bank_account", "bank_name": null, "account_number": "1112220069527311"}], "created_at": 1706273972, "amount_paid": 21731900, "customer_id": null, "description": null, "amount_expected": null}}}	2025-02-14 01:14:10.782	f	\N
2	virtual_account.credited	{"payment": {"entity": {"id": "pay_PvP8Tovwxsirn5", "fee": 1180, "tax": 180, "vpa": null, "bank": null, "email": null, "notes": [], "amount": 454500, "entity": "payment", "method": "bank_transfer", "reward": null, "status": "captured", "wallet": null, "card_id": null, "contact": null, "captured": true, "currency": "INR", "order_id": null, "created_at": 1739495472, "error_code": null, "error_step": null, "invoice_id": null, "description": "", "error_reason": null, "error_source": null, "acquirer_data": {}, "international": false, "refund_status": null, "amount_refunded": 0, "error_description": null}}, "bank_transfer": {"entity": {"id": "bt_PvP8Tbq45O3uDc", "mode": "NEFT", "amount": 454500, "entity": "bank_transfer", "payment_id": "pay_PvP8Tovwxsirn5", "bank_reference": "173949546753", "payer_bank_account": {"id": "ba_PvP8UhD9s0kTDT", "ifsc": "RAZR0000001", "name": "ZIad Hossam", "notes": [], "entity": "bank_account", "bank_name": null, "account_number": "765432123456789"}, "virtual_account_id": "va_NTFXLYIDccRsDC"}}, "virtual_account": {"entity": {"id": "va_NTFXLYIDccRsDC", "name": "ZIad Hossam", "notes": [], "entity": "virtual_account", "status": "active", "close_by": null, "closed_at": null, "receivers": [{"id": "ba_NTFXLhXdzcxbDw", "ifsc": "RAZR0000001", "name": "ZIad Hossam", "notes": [], "entity": "bank_account", "bank_name": null, "account_number": "1112220069527311"}], "created_at": 1706273972, "amount_paid": 16066300, "customer_id": null, "description": null, "amount_expected": null}}}	2025-02-14 01:15:03.258	f	\N
3	virtual_account.credited	{"payment": {"entity": {"id": "pay_PvOrWvw8R7hXs5", "fee": 1180, "tax": 180, "vpa": null, "bank": null, "email": null, "notes": [], "amount": 454500, "entity": "payment", "method": "bank_transfer", "reward": null, "status": "captured", "wallet": null, "card_id": null, "contact": null, "captured": true, "currency": "INR", "order_id": null, "created_at": 1739494509, "error_code": null, "error_step": null, "invoice_id": null, "description": "", "error_reason": null, "error_source": null, "acquirer_data": {}, "international": false, "refund_status": null, "amount_refunded": 0, "error_description": null}}, "bank_transfer": {"entity": {"id": "bt_PvOrWoETBlsSQW", "mode": "NEFT", "amount": 454500, "entity": "bank_transfer", "payment_id": "pay_PvOrWvw8R7hXs5", "bank_reference": "173949450329", "payer_bank_account": {"id": "ba_PvOrXoWvkqkrA5", "ifsc": "RAZR0000001", "name": "ZIad Hossam", "notes": [], "entity": "bank_account", "bank_name": null, "account_number": "765432123456789"}, "virtual_account_id": "va_NTFXLYIDccRsDC"}}, "virtual_account": {"entity": {"id": "va_NTFXLYIDccRsDC", "name": "ZIad Hossam", "notes": [], "entity": "virtual_account", "status": "active", "close_by": null, "closed_at": null, "receivers": [{"id": "ba_NTFXLhXdzcxbDw", "ifsc": "RAZR0000001", "name": "ZIad Hossam", "notes": [], "entity": "bank_account", "bank_name": null, "account_number": "1112220069527311"}], "created_at": 1706273972, "amount_paid": 8399700, "customer_id": null, "description": null, "amount_expected": null}}}	2025-02-14 01:24:11.541	f	\N
4	virtual_account.credited	{"payment": {"entity": {"id": "pay_PvOua2yu8unEFi", "fee": 1180, "tax": 180, "vpa": null, "bank": null, "email": null, "notes": [], "amount": 6546500, "entity": "payment", "method": "bank_transfer", "reward": null, "status": "captured", "wallet": null, "card_id": null, "contact": null, "captured": true, "currency": "INR", "order_id": null, "created_at": 1739494682, "error_code": null, "error_step": null, "invoice_id": null, "description": "", "error_reason": null, "error_source": null, "acquirer_data": {}, "international": false, "refund_status": null, "amount_refunded": 0, "error_description": null}}, "bank_transfer": {"entity": {"id": "bt_PvOuZduldfzXsS", "mode": "NEFT", "amount": 6546500, "entity": "bank_transfer", "payment_id": "pay_PvOua2yu8unEFi", "bank_reference": "173949467791", "payer_bank_account": {"id": "ba_PvOubdT7pttmB3", "ifsc": "RAZR0000001", "name": "ZIad Hossam", "notes": [], "entity": "bank_account", "bank_name": null, "account_number": "765432123456789"}, "virtual_account_id": "va_NTFXLYIDccRsDC"}}, "virtual_account": {"entity": {"id": "va_NTFXLYIDccRsDC", "name": "ZIad Hossam", "notes": [], "entity": "virtual_account", "status": "active", "close_by": null, "closed_at": null, "receivers": [{"id": "ba_NTFXLhXdzcxbDw", "ifsc": "RAZR0000001", "name": "ZIad Hossam", "notes": [], "entity": "bank_account", "bank_name": null, "account_number": "1112220069527311"}], "created_at": 1706273972, "amount_paid": 14946200, "customer_id": null, "description": null, "amount_expected": null}}}	2025-02-14 01:24:29.545	f	\N
5	virtual_account.credited	{"payment": {"entity": {"id": "pay_PvOvW8bXDAEPjB", "fee": 1180, "tax": 180, "vpa": null, "bank": null, "email": null, "notes": [], "amount": 665600, "entity": "payment", "method": "bank_transfer", "reward": null, "status": "captured", "wallet": null, "card_id": null, "contact": null, "captured": true, "currency": "INR", "order_id": null, "created_at": 1739494735, "error_code": null, "error_step": null, "invoice_id": null, "description": "", "error_reason": null, "error_source": null, "acquirer_data": {}, "international": false, "refund_status": null, "amount_refunded": 0, "error_description": null}}, "bank_transfer": {"entity": {"id": "bt_PvOvVwDFLWdVkD", "mode": "NEFT", "amount": 665600, "entity": "bank_transfer", "payment_id": "pay_PvOvW8bXDAEPjB", "bank_reference": "173949473554", "payer_bank_account": {"id": "ba_PvOvX1ULXoJ24O", "ifsc": "RAZR0000001", "name": "ZIad Hossam", "notes": [], "entity": "bank_account", "bank_name": null, "account_number": "765432123456789"}, "virtual_account_id": "va_NTFXLYIDccRsDC"}}, "virtual_account": {"entity": {"id": "va_NTFXLYIDccRsDC", "name": "ZIad Hossam", "notes": [], "entity": "virtual_account", "status": "active", "close_by": null, "closed_at": null, "receivers": [{"id": "ba_NTFXLhXdzcxbDw", "ifsc": "RAZR0000001", "name": "ZIad Hossam", "notes": [], "entity": "bank_account", "bank_name": null, "account_number": "1112220069527311"}], "created_at": 1706273972, "amount_paid": 15611800, "customer_id": null, "description": null, "amount_expected": null}}}	2025-02-14 01:24:46.495	f	\N
6	virtual_account.credited	{"payment": {"entity": {"id": "pay_PvRq2fmFWEQ8XV", "fee": 1180, "tax": 180, "vpa": null, "bank": null, "email": null, "notes": [], "amount": 646500, "entity": "payment", "method": "bank_transfer", "reward": null, "status": "captured", "wallet": null, "card_id": null, "contact": null, "captured": true, "currency": "INR", "order_id": null, "created_at": 1739504989, "error_code": null, "error_step": null, "invoice_id": null, "description": "", "error_reason": null, "error_source": null, "acquirer_data": {}, "international": false, "refund_status": null, "amount_refunded": 0, "error_description": null}}, "bank_transfer": {"entity": {"id": "bt_PvRq2XAbV9DV2I", "mode": "NEFT", "amount": 646500, "entity": "bank_transfer", "payment_id": "pay_PvRq2fmFWEQ8XV", "bank_reference": "173950497879", "payer_bank_account": {"id": "ba_PvRq3eq5E2rzGq", "ifsc": "RAZR0000001", "name": "ZIad Hossam", "notes": [], "entity": "bank_account", "bank_name": null, "account_number": "765432123456789"}, "virtual_account_id": "va_NTFXLYIDccRsDC"}}, "virtual_account": {"entity": {"id": "va_NTFXLYIDccRsDC", "name": "ZIad Hossam", "notes": [], "entity": "virtual_account", "status": "active", "close_by": null, "closed_at": null, "receivers": [{"id": "ba_NTFXLhXdzcxbDw", "ifsc": "RAZR0000001", "name": "ZIad Hossam", "notes": [], "entity": "bank_account", "bank_name": null, "account_number": "1112220069527311"}], "created_at": 1706273972, "amount_paid": 22378400, "customer_id": null, "description": null, "amount_expected": null}}}	2025-02-14 03:52:33.894	f	\N
\.


--
-- Data for Name: razorpay_va_webhooks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."razorpay_va_webhooks" ("id", "event_type", "virtual_account_id", "brand_id", "payload", "received_at", "processed", "processed_at") FROM stdin;
\.


--
-- Data for Name: razorpay_x_webhooks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."razorpay_x_webhooks" ("id", "event_type", "payout_id", "enrollment_id", "payload", "received_at", "processed", "processed_at") FROM stdin;
1	payout.pending	pout_1Aa00000000001	\N	{"payout": {"entity": {"id": "pout_1Aa00000000001", "tax": 0, "utr": null, "fees": 0, "mode": "NEFT", "notes": {"note_key 1": "Tea. Earl Gray. Hot.", "note_key 2": "Tea. Earl Gray. Decaf."}, "amount": 100, "entity": "payout", "status": "pending", "purpose": "refund", "batch_id": null, "currency": "INR", "fee_type": "", "narration": "Test Fund Transfer", "created_at": 1580808301, "reference_id": null, "status_details": {"reason": "beneficiary_bank_confirmation_pending", "source": "beneficiary_bank", "description": "Confirmation of the credit to the beneficiary is pending from HDFC bank. Please check the status after after 24th October 2021, 10:40 PM"}, "fund_account_id": "fa_1Aa00000000001"}}}	2025-02-14 03:36:28.768	f	\N
2	payout.pending	pout_1Aa00000000001	\N	{"payout": {"entity": {"id": "pout_1Aa00000000001", "tax": 0, "utr": null, "fees": 0, "mode": "NEFT", "notes": {"note_key 1": "Tea. Earl Gray. Hot.", "note_key 2": "Tea. Earl Gray. Decaf."}, "amount": 100, "entity": "payout", "status": "pending", "purpose": "refund", "batch_id": null, "currency": "INR", "fee_type": "", "narration": "Test Fund Transfer", "created_at": 1580808301, "reference_id": null, "status_details": {"reason": "beneficiary_bank_confirmation_pending", "source": "beneficiary_bank", "description": "Confirmation of the credit to the beneficiary is pending from HDFC bank. Please check the status after after 24th October 2021, 10:40 PM"}, "fund_account_id": "fa_1Aa00000000001"}}}	2025-02-14 03:41:48.386	f	\N
\.


--
-- Data for Name: zeptomail_webhooks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."zeptomail_webhooks" ("id", "event_type", "payload", "received_at", "processed", "processed_at") FROM stdin;
\.


--
-- Data for Name: zoho_books_webhooks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."zoho_books_webhooks" ("id", "event_type", "payload", "received_at", "processed", "processed_at") FROM stdin;
\.


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY "storage"."buckets" ("id", "name", "owner", "created_at", "updated_at", "public", "avif_autodetection", "file_size_limit", "allowed_mime_types", "owner_id") FROM stdin;
\.


--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY "storage"."objects" ("id", "bucket_id", "name", "owner", "created_at", "updated_at", "last_accessed_at", "metadata", "version", "owner_id", "user_metadata") FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY "storage"."s3_multipart_uploads" ("id", "in_progress_size", "upload_signature", "bucket_id", "key", "version", "owner_id", "created_at", "user_metadata") FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY "storage"."s3_multipart_uploads_parts" ("id", "upload_id", "size", "part_number", "bucket_id", "key", "etag", "owner_id", "version", "created_at") FROM stdin;
\.


--
-- Data for Name: secrets; Type: TABLE DATA; Schema: vault; Owner: supabase_admin
--

COPY "vault"."secrets" ("id", "name", "description", "secret", "key_id", "nonce", "created_at", "updated_at") FROM stdin;
052739e3-94bb-4fac-b552-a69034ec6aaf	razorpay-secret	RAZORPAY_SECRET	36cCcXDoJLnXk3EXXT1d7xTFiieLGa8frqT03ElYo7Nd8zUgbMrXXe6i/Bt2Y+oWoenMEq+kGuV9\nzpPsIdFeXg7158l9TVLb6HtnxBSNPH4KZ26cQM5fuf+H0ySdhffY	0bef341e-59b8-49e8-8a23-0d3119c4bd97	\\xc8ed652deac1d14d24bc81242cb58aca	2025-02-14 04:29:03.924113+00	2025-02-14 04:29:03.924113+00
\.


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: supabase_auth_admin
--

SELECT pg_catalog.setval('"auth"."refresh_tokens_id_seq"', 1, false);


--
-- Name: key_key_id_seq; Type: SEQUENCE SET; Schema: pgsodium; Owner: supabase_admin
--

SELECT pg_catalog.setval('"pgsodium"."key_key_id_seq"', 1, true);


--
-- Name: admin_profiles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."admin_profiles_id_seq"', 1, false);


--
-- Name: brand_profiles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."brand_profiles_id_seq"', 1, false);


--
-- Name: campaign_deliverables_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."campaign_deliverables_id_seq"', 1, false);


--
-- Name: campaign_images_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."campaign_images_id_seq"', 1, false);


--
-- Name: campaigns_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."campaigns_id_seq"', 1, false);


--
-- Name: coupon_redemptions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."coupon_redemptions_id_seq"', 1, false);


--
-- Name: coupons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."coupons_id_seq"', 1, false);


--
-- Name: deliverable_submissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."deliverable_submissions_id_seq"', 1, false);


--
-- Name: deliverables_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."deliverables_id_seq"', 1, false);


--
-- Name: enrollments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."enrollments_id_seq"', 1, false);


--
-- Name: invoice_enrollments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."invoice_enrollments_id_seq"', 1, false);


--
-- Name: invoice_payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."invoice_payments_id_seq"', 1, false);


--
-- Name: invoices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."invoices_id_seq"', 1, false);


--
-- Name: notification_preferences_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."notification_preferences_id_seq"', 1, false);


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."notifications_id_seq"', 1, false);


--
-- Name: payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."payments_id_seq"', 1, false);


--
-- Name: payouts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."payouts_id_seq"', 1, false);


--
-- Name: platform_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."platform_settings_id_seq"', 1, false);


--
-- Name: platforms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."platforms_id_seq"', 1, false);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."products_id_seq"', 1, false);


--
-- Name: profiles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."profiles_id_seq"', 1, false);


--
-- Name: razorpay_smart_collect_webhooks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."razorpay_smart_collect_webhooks_id_seq"', 6, true);


--
-- Name: razorpay_va_webhooks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."razorpay_va_webhooks_id_seq"', 1, false);


--
-- Name: razorpay_x_webhooks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."razorpay_x_webhooks_id_seq"', 2, true);


--
-- Name: shopper_profiles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."shopper_profiles_id_seq"', 1, false);


--
-- Name: zeptomail_webhooks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."zeptomail_webhooks_id_seq"', 1, false);


--
-- Name: zoho_books_webhooks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."zoho_books_webhooks_id_seq"', 1, false);


--
-- PostgreSQL database dump complete
--

RESET ALL;
