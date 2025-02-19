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
00000000-0000-0000-0000-000000000000	62d02f8d-7740-466a-828a-c3dfdc680bdf	{"action":"user_signedup","actor_id":"0d535dca-5466-4bd6-8f44-2c5c6fc74464","actor_username":"shivam@sharksmarketing.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-02-18 00:23:16.887677+00	
00000000-0000-0000-0000-000000000000	8f7e421a-8f25-44f9-b8d3-250f72ab48b3	{"action":"login","actor_id":"0d535dca-5466-4bd6-8f44-2c5c6fc74464","actor_username":"shivam@sharksmarketing.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-02-18 00:23:16.909115+00	
00000000-0000-0000-0000-000000000000	1094d331-3f35-42f8-9673-71f7b192bdd3	{"action":"logout","actor_id":"0d535dca-5466-4bd6-8f44-2c5c6fc74464","actor_username":"shivam@sharksmarketing.com","actor_via_sso":false,"log_type":"account"}	2025-02-18 00:23:23.68765+00	
00000000-0000-0000-0000-000000000000	f5f90069-86cb-438c-8246-07145074175b	{"action":"login","actor_id":"0d535dca-5466-4bd6-8f44-2c5c6fc74464","actor_username":"shivam@sharksmarketing.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-02-18 12:49:46.33007+00	
00000000-0000-0000-0000-000000000000	9695ad29-948b-4f3f-8b70-3eb7e45dfc26	{"action":"logout","actor_id":"0d535dca-5466-4bd6-8f44-2c5c6fc74464","actor_username":"shivam@sharksmarketing.com","actor_via_sso":false,"log_type":"account"}	2025-02-18 12:50:27.904868+00	
00000000-0000-0000-0000-000000000000	302cb38e-0a47-4a63-b5ae-220584ec9e45	{"action":"user_signedup","actor_id":"d49d26dc-ed4f-451a-83f5-8bed9ff336cf","actor_username":"9.shivamgupta.6@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-02-18 15:37:21.133911+00	
00000000-0000-0000-0000-000000000000	4e4b1e2f-3c33-45bd-ae48-281d53e5eea1	{"action":"login","actor_id":"d49d26dc-ed4f-451a-83f5-8bed9ff336cf","actor_username":"9.shivamgupta.6@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-02-18 15:37:21.139899+00	
00000000-0000-0000-0000-000000000000	ad97c39f-9a61-4bf6-9ae3-bd0905a3820f	{"action":"user_repeated_signup","actor_id":"d49d26dc-ed4f-451a-83f5-8bed9ff336cf","actor_username":"9.shivamgupta.6@gmail.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-02-18 15:37:26.97322+00	
00000000-0000-0000-0000-000000000000	a38496ac-4482-47a5-ae11-f75e414b1173	{"action":"logout","actor_id":"d49d26dc-ed4f-451a-83f5-8bed9ff336cf","actor_username":"9.shivamgupta.6@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-02-18 15:37:46.668667+00	
00000000-0000-0000-0000-000000000000	3a1460f3-bf3e-479c-8bd5-2b0511ac90bc	{"action":"login","actor_id":"0d535dca-5466-4bd6-8f44-2c5c6fc74464","actor_username":"shivam@sharksmarketing.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-02-18 15:47:20.761155+00	
00000000-0000-0000-0000-000000000000	7ede5436-3fe8-4466-9242-61e396898de8	{"action":"login","actor_id":"0d535dca-5466-4bd6-8f44-2c5c6fc74464","actor_username":"shivam@sharksmarketing.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-02-18 15:58:45.376114+00	
00000000-0000-0000-0000-000000000000	0cc83643-5e00-422a-b921-4004908d075b	{"action":"logout","actor_id":"0d535dca-5466-4bd6-8f44-2c5c6fc74464","actor_username":"shivam@sharksmarketing.com","actor_via_sso":false,"log_type":"account"}	2025-02-18 16:27:15.566185+00	
00000000-0000-0000-0000-000000000000	82fa4928-7949-4367-b514-51628c47a99b	{"action":"user_signedup","actor_id":"0ff5e996-5811-481b-be81-fe3338dfaab6","actor_username":"hoola123@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-02-18 16:46:29.351112+00	
00000000-0000-0000-0000-000000000000	b704e75b-bf38-4aff-a986-a1e5f61f1ecb	{"action":"login","actor_id":"0ff5e996-5811-481b-be81-fe3338dfaab6","actor_username":"hoola123@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-02-18 16:46:29.357665+00	
00000000-0000-0000-0000-000000000000	43427c96-4ec4-4375-b43c-39d7f68a0378	{"action":"logout","actor_id":"0ff5e996-5811-481b-be81-fe3338dfaab6","actor_username":"hoola123@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-02-18 16:46:39.442589+00	
00000000-0000-0000-0000-000000000000	a1045d14-b896-46a9-a29c-5f45e3d6b3cb	{"action":"login","actor_id":"0ff5e996-5811-481b-be81-fe3338dfaab6","actor_username":"hoola123@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-02-18 16:47:14.753933+00	
00000000-0000-0000-0000-000000000000	5b31ba94-d57f-4cff-89e9-2a5998f538ad	{"action":"logout","actor_id":"0ff5e996-5811-481b-be81-fe3338dfaab6","actor_username":"hoola123@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-02-18 16:48:38.675797+00	
00000000-0000-0000-0000-000000000000	224f1349-054a-40e9-9d61-d55e07b1df96	{"action":"user_signedup","actor_id":"24c65c17-c785-43ba-9f1e-806f1e509a28","actor_username":"hula123@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-02-18 16:50:10.900308+00	
00000000-0000-0000-0000-000000000000	2a434031-c227-4a19-8f89-1217216f3a62	{"action":"login","actor_id":"24c65c17-c785-43ba-9f1e-806f1e509a28","actor_username":"hula123@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-02-18 16:50:10.904313+00	
00000000-0000-0000-0000-000000000000	243ad60f-4220-416d-94cd-08d49527e945	{"action":"user_signedup","actor_id":"e9b94f74-5084-43b8-996c-3ce68d96290b","actor_username":"guppa123@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-02-18 16:55:17.10023+00	
00000000-0000-0000-0000-000000000000	1eeac0c8-df31-4753-8c2a-aa5e999fa12a	{"action":"login","actor_id":"e9b94f74-5084-43b8-996c-3ce68d96290b","actor_username":"guppa123@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-02-18 16:55:17.107939+00	
00000000-0000-0000-0000-000000000000	4176cef9-80d8-4a03-97a8-0d0008399299	{"action":"token_refreshed","actor_id":"24c65c17-c785-43ba-9f1e-806f1e509a28","actor_username":"hula123@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-02-18 20:08:59.278082+00	
00000000-0000-0000-0000-000000000000	9c8ff73d-5598-4951-a7ba-f2d750e8c7de	{"action":"token_revoked","actor_id":"24c65c17-c785-43ba-9f1e-806f1e509a28","actor_username":"hula123@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-02-18 20:08:59.293364+00	
00000000-0000-0000-0000-000000000000	00131b84-51ec-4699-a2eb-b7ae6e5da40b	{"action":"token_refreshed","actor_id":"24c65c17-c785-43ba-9f1e-806f1e509a28","actor_username":"hula123@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-02-18 20:09:36.991265+00	
00000000-0000-0000-0000-000000000000	1bd1fb22-d736-4b5c-9a0d-ae82afad6a82	{"action":"token_refreshed","actor_id":"24c65c17-c785-43ba-9f1e-806f1e509a28","actor_username":"hula123@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-02-18 20:09:38.937985+00	
00000000-0000-0000-0000-000000000000	443d6505-ef40-46a0-9f11-5ca60d016fd9	{"action":"token_refreshed","actor_id":"24c65c17-c785-43ba-9f1e-806f1e509a28","actor_username":"hula123@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-02-18 20:10:07.031518+00	
00000000-0000-0000-0000-000000000000	05747d40-7eb6-450a-80c1-f0c25ea6c0c4	{"action":"user_signedup","actor_id":"e6c33c07-c230-4920-9bfc-28b17a03b654","actor_username":"brand@brand.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-02-18 20:11:30.452721+00	
00000000-0000-0000-0000-000000000000	f12490e6-1b78-40f6-afd9-d1d40ce63988	{"action":"login","actor_id":"e6c33c07-c230-4920-9bfc-28b17a03b654","actor_username":"brand@brand.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-02-18 20:11:30.462291+00	
00000000-0000-0000-0000-000000000000	e603bb54-0965-4cdb-ba34-72e5775b4b59	{"action":"logout","actor_id":"e6c33c07-c230-4920-9bfc-28b17a03b654","actor_username":"brand@brand.com","actor_via_sso":false,"log_type":"account"}	2025-02-18 20:11:30.751442+00	
00000000-0000-0000-0000-000000000000	4605e231-6f14-474c-8756-c4b78d2b4f4f	{"action":"user_repeated_signup","actor_id":"e6c33c07-c230-4920-9bfc-28b17a03b654","actor_username":"brand@brand.com","actor_via_sso":false,"log_type":"user","traits":{"provider":"email"}}	2025-02-18 20:14:05.153942+00	
00000000-0000-0000-0000-000000000000	c0efaced-f672-4427-bb5a-e4ac4bb69c39	{"action":"login","actor_id":"e6c33c07-c230-4920-9bfc-28b17a03b654","actor_username":"brand@brand.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-02-18 20:14:43.338531+00	
00000000-0000-0000-0000-000000000000	62158e7f-ed6e-4445-bca0-0352d35c1008	{"action":"logout","actor_id":"e6c33c07-c230-4920-9bfc-28b17a03b654","actor_username":"brand@brand.com","actor_via_sso":false,"log_type":"account"}	2025-02-18 20:46:16.044711+00	
00000000-0000-0000-0000-000000000000	ed61e7ac-d4ea-4e1b-b11a-4defc2cf4501	{"action":"user_signedup","actor_id":"cc8a6220-2840-4d86-bf7a-4d87ea93fbb8","actor_username":"buba@buba.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"email"}}	2025-02-18 20:49:09.324625+00	
00000000-0000-0000-0000-000000000000	5208bf7f-f7f9-4ddb-964a-74cdcc571b24	{"action":"login","actor_id":"cc8a6220-2840-4d86-bf7a-4d87ea93fbb8","actor_username":"buba@buba.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-02-18 20:49:09.331714+00	
00000000-0000-0000-0000-000000000000	6c7b2638-57d3-478c-984c-55a6ce834064	{"action":"logout","actor_id":"cc8a6220-2840-4d86-bf7a-4d87ea93fbb8","actor_username":"buba@buba.com","actor_via_sso":false,"log_type":"account"}	2025-02-18 20:50:03.287086+00	
00000000-0000-0000-0000-000000000000	8ab64cb5-5961-4390-b67b-ebf1e4a7afbb	{"action":"login","actor_id":"e6c33c07-c230-4920-9bfc-28b17a03b654","actor_username":"brand@brand.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"email"}}	2025-02-18 20:50:15.989874+00	
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
00000000-0000-0000-0000-000000000000	0ff5e996-5811-481b-be81-fe3338dfaab6	authenticated	brand	hoola123@gmail.com	$2a$10$D1/q8SwiJsSmylMInB4LZ.BTByij0G/gOi6yq3ynfd18ksd08txj.	2025-02-18 16:46:29.352582+00	\N		\N		\N			\N	2025-02-18 16:47:14.754701+00	{"provider": "email", "providers": ["email"]}	{"sub": "0ff5e996-5811-481b-be81-fe3338dfaab6", "email": "hoola123@gmail.com", "brand_name": "Hoola", "email_verified": true, "phone_verified": false}	\N	2025-02-18 16:46:29.338875+00	2025-02-18 16:47:14.756372+00	\N	\N			\N		0	\N		\N	f	\N	f	f
00000000-0000-0000-0000-000000000000	e9b94f74-5084-43b8-996c-3ce68d96290b	authenticated	brand	guppa123@gmail.com	$2a$10$4LiH7pjkdV4vr939d4ISC.uZ87D.BTvxGGSOuJhb6.P.GT.66FQdO	2025-02-18 16:55:17.104351+00	\N		\N		\N			\N	2025-02-18 16:55:17.108522+00	{"provider": "email", "providers": ["email"]}	{"sub": "e9b94f74-5084-43b8-996c-3ce68d96290b", "email": "guppa123@gmail.com", "brand_name": "guppa", "email_verified": true, "phone_verified": false}	\N	2025-02-18 16:55:17.089737+00	2025-02-18 16:55:17.111912+00	\N	\N			\N		0	\N		\N	f	\N	f	f
00000000-0000-0000-0000-000000000000	cc8a6220-2840-4d86-bf7a-4d87ea93fbb8	authenticated	authenticated	buba@buba.com	$2a$10$8o/cxXBCW1wClWYg4mrPuOX97t.jW/Tt2Xfbj2HpIX7qiiJ6CYozi	2025-02-18 20:49:09.328492+00	\N		\N		\N			\N	2025-02-18 20:49:09.332285+00	{"provider": "email", "providers": ["email"]}	{"sub": "cc8a6220-2840-4d86-bf7a-4d87ea93fbb8", "email": "buba@buba.com", "user_type": "brand", "brand_name": "buba.com", "email_verified": true, "phone_verified": false}	\N	2025-02-18 20:49:09.308763+00	2025-02-18 20:49:09.336754+00	\N	\N			\N		0	\N		\N	f	\N	f	f
00000000-0000-0000-0000-000000000000	e6c33c07-c230-4920-9bfc-28b17a03b654	authenticated	brand	brand@brand.com	$2a$10$S4aE1Q05ZqUCYgZw/FkW7.ZDIQFZWIn4uvYkfQZS5lKC1XF0r/FI6	2025-02-18 20:11:30.453403+00	\N		\N		\N			\N	2025-02-18 20:50:15.990741+00	{"provider": "email", "providers": ["email"]}	{"sub": "e6c33c07-c230-4920-9bfc-28b17a03b654", "email": "brand@brand.com", "user_type": "brand", "brand_name": "brand", "email_verified": true, "phone_verified": false}	\N	2025-02-18 20:11:30.441402+00	2025-02-18 20:50:15.992616+00	\N	\N			\N		0	\N		\N	f	\N	f	f
00000000-0000-0000-0000-000000000000	24c65c17-c785-43ba-9f1e-806f1e509a28	authenticated	brand	hula123@gmail.com	$2a$10$7rFgleXv3G3K3EYnqZk6fO4lmBQJJuaO1lpFygAmXrxM9vdfY1Pgu	2025-02-18 16:50:10.901068+00	\N		\N		\N			\N	2025-02-18 16:50:10.904821+00	{"provider": "email", "providers": ["email"]}	{"sub": "24c65c17-c785-43ba-9f1e-806f1e509a28", "email": "hula123@gmail.com", "brand_name": "hoola baby", "email_verified": true, "phone_verified": false}	\N	2025-02-18 16:50:10.893409+00	2025-02-18 20:08:59.316582+00	\N	\N			\N		0	\N		\N	f	\N	f	f
00000000-0000-0000-0000-000000000000	d49d26dc-ed4f-451a-83f5-8bed9ff336cf	authenticated	brand	9.shivamgupta.6@gmail.com	$2a$10$lCgbN9s.JiWgRrHpEdr/8edlIWQjCftCgf1mEnmmBOzHFuDrzpIRG	2025-02-18 15:37:21.13524+00	\N		\N		\N			\N	2025-02-18 15:37:21.140462+00	{"provider": "email", "providers": ["email"]}	{"sub": "d49d26dc-ed4f-451a-83f5-8bed9ff336cf", "email": "9.shivamgupta.6@gmail.com", "brand_name": "Shivam Gupta", "email_verified": true, "phone_verified": false}	\N	2025-02-18 15:37:21.113213+00	2025-02-18 15:37:21.144701+00	\N	\N			\N		0	\N		\N	f	\N	f	f
00000000-0000-0000-0000-000000000000	0d535dca-5466-4bd6-8f44-2c5c6fc74464	authenticated	brand	shivam@sharksmarketing.com	$2a$10$y.NKsGgTu7qE5.IY/UGphOATC1VSl6FBBkprrDOMrq1tKSvo5QjRa	2025-02-18 00:23:16.895782+00	\N		\N		\N			\N	2025-02-18 15:58:45.377178+00	{"provider": "email", "providers": ["email"]}	{"sub": "0d535dca-5466-4bd6-8f44-2c5c6fc74464", "email": "shivam@sharksmarketing.com", "email_verified": true, "phone_verified": false}	\N	2025-02-18 00:23:16.837143+00	2025-02-18 15:58:45.379781+00	\N	\N			\N		0	\N		\N	f	\N	f	f
\.


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."identities" ("provider_id", "user_id", "identity_data", "provider", "last_sign_in_at", "created_at", "updated_at", "id") FROM stdin;
0d535dca-5466-4bd6-8f44-2c5c6fc74464	0d535dca-5466-4bd6-8f44-2c5c6fc74464	{"sub": "0d535dca-5466-4bd6-8f44-2c5c6fc74464", "email": "shivam@sharksmarketing.com", "email_verified": false, "phone_verified": false}	email	2025-02-18 00:23:16.873841+00	2025-02-18 00:23:16.873893+00	2025-02-18 00:23:16.873893+00	58089d3c-6c7a-4f30-91f5-8255f08d2879
d49d26dc-ed4f-451a-83f5-8bed9ff336cf	d49d26dc-ed4f-451a-83f5-8bed9ff336cf	{"sub": "d49d26dc-ed4f-451a-83f5-8bed9ff336cf", "email": "9.shivamgupta.6@gmail.com", "brand_name": "Shivam Gupta", "email_verified": false, "phone_verified": false}	email	2025-02-18 15:37:21.12645+00	2025-02-18 15:37:21.126515+00	2025-02-18 15:37:21.126515+00	f2328291-fd1d-431d-88b6-725aab01ab05
0ff5e996-5811-481b-be81-fe3338dfaab6	0ff5e996-5811-481b-be81-fe3338dfaab6	{"sub": "0ff5e996-5811-481b-be81-fe3338dfaab6", "email": "hoola123@gmail.com", "brand_name": "Hoola", "email_verified": false, "phone_verified": false}	email	2025-02-18 16:46:29.347763+00	2025-02-18 16:46:29.347827+00	2025-02-18 16:46:29.347827+00	39ab29a5-61e2-4f9e-a25d-6c3ff894fd5f
24c65c17-c785-43ba-9f1e-806f1e509a28	24c65c17-c785-43ba-9f1e-806f1e509a28	{"sub": "24c65c17-c785-43ba-9f1e-806f1e509a28", "email": "hula123@gmail.com", "brand_name": "hoola baby", "email_verified": false, "phone_verified": false}	email	2025-02-18 16:50:10.897617+00	2025-02-18 16:50:10.897665+00	2025-02-18 16:50:10.897665+00	6848b298-ea98-424a-b970-3f0b2b2d5b87
e9b94f74-5084-43b8-996c-3ce68d96290b	e9b94f74-5084-43b8-996c-3ce68d96290b	{"sub": "e9b94f74-5084-43b8-996c-3ce68d96290b", "email": "guppa123@gmail.com", "brand_name": "guppa", "email_verified": false, "phone_verified": false}	email	2025-02-18 16:55:17.097156+00	2025-02-18 16:55:17.097217+00	2025-02-18 16:55:17.097217+00	81c089cd-4c11-42a4-871c-9cede0326905
e6c33c07-c230-4920-9bfc-28b17a03b654	e6c33c07-c230-4920-9bfc-28b17a03b654	{"sub": "e6c33c07-c230-4920-9bfc-28b17a03b654", "email": "brand@brand.com", "user_type": "brand", "brand_name": "brand", "email_verified": false, "phone_verified": false}	email	2025-02-18 20:11:30.44923+00	2025-02-18 20:11:30.44928+00	2025-02-18 20:11:30.44928+00	6c68568c-7a8d-4301-8e21-eff42f68ee25
cc8a6220-2840-4d86-bf7a-4d87ea93fbb8	cc8a6220-2840-4d86-bf7a-4d87ea93fbb8	{"sub": "cc8a6220-2840-4d86-bf7a-4d87ea93fbb8", "email": "buba@buba.com", "user_type": "brand", "brand_name": "buba.com", "email_verified": false, "phone_verified": false}	email	2025-02-18 20:49:09.319326+00	2025-02-18 20:49:09.319375+00	2025-02-18 20:49:09.319375+00	1a8b6f08-e86c-420d-8a14-b35e1b2147a9
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
54cabd2c-c117-455d-9af3-3d81b84d1479	e9b94f74-5084-43b8-996c-3ce68d96290b	2025-02-18 16:55:17.108612+00	2025-02-18 16:55:17.108612+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36	171.50.233.161	\N
0389d37d-d503-4dab-a7f4-372e629c1b80	24c65c17-c785-43ba-9f1e-806f1e509a28	2025-02-18 16:50:10.904889+00	2025-02-18 20:10:07.032728+00	\N	aal1	\N	2025-02-18 20:10:07.032652	node	171.50.233.161	\N
c9824ff6-578c-4dc3-b01e-e1a6bc402d7a	e6c33c07-c230-4920-9bfc-28b17a03b654	2025-02-18 20:50:15.990818+00	2025-02-18 20:50:15.990818+00	\N	aal1	\N	\N	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36	171.50.233.161	\N
\.


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY "auth"."mfa_amr_claims" ("session_id", "created_at", "updated_at", "authentication_method", "id") FROM stdin;
0389d37d-d503-4dab-a7f4-372e629c1b80	2025-02-18 16:50:10.908368+00	2025-02-18 16:50:10.908368+00	password	1368d028-f790-4873-93ea-ceffd70112a5
54cabd2c-c117-455d-9af3-3d81b84d1479	2025-02-18 16:55:17.112424+00	2025-02-18 16:55:17.112424+00	password	3029e9ab-54b8-4282-8cab-e09bfc71ad3d
c9824ff6-578c-4dc3-b01e-e1a6bc402d7a	2025-02-18 20:50:15.992942+00	2025-02-18 20:50:15.992942+00	password	97f0d057-ac8d-45a2-b0ea-50df3f98d8d4
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
00000000-0000-0000-0000-000000000000	9	mPXB6qIuEYGYNcdk0UjC_w	e9b94f74-5084-43b8-996c-3ce68d96290b	f	2025-02-18 16:55:17.110585+00	2025-02-18 16:55:17.110585+00	\N	54cabd2c-c117-455d-9af3-3d81b84d1479
00000000-0000-0000-0000-000000000000	8	j1p2s8vIGH8kJHa2wbC0Ug	24c65c17-c785-43ba-9f1e-806f1e509a28	t	2025-02-18 16:50:10.905865+00	2025-02-18 20:08:59.293956+00	\N	0389d37d-d503-4dab-a7f4-372e629c1b80
00000000-0000-0000-0000-000000000000	10	Ky4wbO_OfZbaEeqevDCXXw	24c65c17-c785-43ba-9f1e-806f1e509a28	f	2025-02-18 20:08:59.311516+00	2025-02-18 20:08:59.311516+00	j1p2s8vIGH8kJHa2wbC0Ug	0389d37d-d503-4dab-a7f4-372e629c1b80
00000000-0000-0000-0000-000000000000	14	FeRE_8GyjbdWBaCK9Zm7SA	e6c33c07-c230-4920-9bfc-28b17a03b654	f	2025-02-18 20:50:15.991674+00	2025-02-18 20:50:15.991674+00	\N	c9824ff6-578c-4dc3-b01e-e1a6bc402d7a
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
40243e61-3b41-4761-8f3c-4747412598e7	valid	2025-02-14 16:48:34.231832+00	\N	aead-det	2	\\x7067736f6469756d	\N		\N	\N	\N	\N	\N
04e143bc-1934-4ee0-8bee-180a871dd1d1	valid	2025-02-14 16:48:34.231832+00	\N	aead-det	3	\\x7067736f6469756d	\N		\N	\N	\N	\N	\N
a7bd3759-9194-4ab0-b2fb-102a4a54006d	valid	2025-02-14 16:48:34.231832+00	\N	aead-det	4	\\x7067736f6469756d	\N		\N	\N	\N	\N	\N
c35a125b-0f3e-497f-beb0-48f0ea217e05	valid	2025-02-14 16:48:34.231832+00	\N	aead-det	5	\\x7067736f6469756d	\N		\N	\N	\N	\N	\N
a8a31ed2-a6dd-4231-b57b-9f1fe73b0243	valid	2025-02-14 16:48:34.231832+00	\N	aead-det	6	\\x7067736f6469756d	\N		\N	\N	\N	\N	\N
dc182bc5-7001-48e6-8dbb-75ac910c64fd	valid	2025-02-14 16:48:34.231832+00	\N	aead-det	7	\\x7067736f6469756d	\N		\N	\N	\N	\N	\N
b59c417e-a40c-4734-910c-cb5adb2d9c23	valid	2025-02-14 16:48:34.231832+00	\N	aead-det	8	\\x7067736f6469756d	\N		\N	\N	\N	\N	\N
6be9ced4-9c7c-4bce-b055-801fb9799039	valid	2025-02-14 16:48:34.231832+00	\N	aead-det	9	\\x7067736f6469756d	\N		\N	\N	\N	\N	\N
4e40aa52-d092-40b5-8f3d-113c4f60263c	valid	2025-02-14 16:48:34.231832+00	\N	aead-det	10	\\x7067736f6469756d	\N		\N	\N	\N	\N	\N
51905cd1-51cf-465b-a138-1551fd207129	valid	2025-02-14 16:48:34.231832+00	\N	aead-det	11	\\x7067736f6469756d	\N		\N	\N	\N	\N	\N
91e43e66-67df-44d6-a874-6549ea798b68	valid	2025-02-14 16:48:34.231832+00	\N	aead-det	12	\\x7067736f6469756d	\N		\N	\N	\N	\N	\N
cca297d9-36f7-461d-b189-579716ebe774	valid	2025-02-14 16:48:34.231832+00	\N	aead-det	13	\\x7067736f6469756d	\N		\N	\N	\N	\N	\N
f9393bce-e616-461c-a9d5-edc38870ee9b	valid	2025-02-14 16:48:34.231832+00	\N	aead-det	14	\\x7067736f6469756d	\N		\N	\N	\N	\N	\N
48a361b5-4aa8-4efd-9794-805c6ebe95d6	valid	2025-02-14 16:48:34.231832+00	\N	aead-det	15	\\x7067736f6469756d	\N		\N	\N	\N	\N	\N
e2989faf-5ca0-48cd-8a65-ad4f0c484c7f	valid	2025-02-14 16:48:34.231832+00	\N	aead-det	16	\\x7067736f6469756d	\N		\N	\N	\N	\N	\N
fbb94ab6-7ce3-42e8-899b-4413f8077418	valid	2025-02-14 16:48:34.231832+00	\N	aead-det	17	\\x7067736f6469756d	\N		\N	\N	\N	\N	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."users" ("id", "auth_user_id", "user_type", "created_at", "status", "onboarding_completed") FROM stdin;
2	e6c33c07-c230-4920-9bfc-28b17a03b654	brand	2025-02-18 20:16:22.863195+00	active	t
3	cc8a6220-2840-4d86-bf7a-4d87ea93fbb8	brand	2025-02-18 20:49:09.477685+00	active	f
\.


--
-- Data for Name: admin_profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."admin_profiles" ("id", "first_name", "last_name", "phone_number", "email", "profile_picture_url", "role", "created_at", "profile_id") FROM stdin;
\.


--
-- Data for Name: brand_profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."brand_profiles" ("id", "brand_name", "company_name", "contact_person", "phone_number", "email", "accounts_email", "website", "gst_number", "business_address", "city", "state", "postal_code", "brand_logo_url", "payment_terms", "razorpay_va_id", "razorpay_va_number", "razorpay_va_ifsc", "razorpay_va_upi_id", "zoho_books_id", "created_at", "profile_id", "admin_approved", "tds_rate") FROM stdin;
6	brand	@brand.com	PErson	8699699866	vhjs@hdhd.com	tutu@jfdkd.vom	https://dffd.vid	10BSDPG0911J1ZF	fhgfgfg	fdhfhhfd	fdhfdh	454454	\N	net_30	\N	\N	\N	\N	\N	2025-02-18 20:26:44.564326	2	f	0.00
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
-- Data for Name: enrollments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."enrollments" ("id", "campaign_id", "shopper_id", "order_id", "rebate_amount", "bonus_amount", "coupon_adjustment", "incentive_amount", "deduction_amount", "platform_profit", "approval_remarks", "created_at", "coupon_id", "is_invoiced", "status", "rejection_count", "brand_id") FROM stdin;
\.


--
-- Data for Name: shopper_profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."shopper_profiles" ("id", "first_name", "last_name", "phone_number", "address", "city", "state", "postal_code", "dob", "profile_picture_url", "payment_method", "bank_account_number", "ifsc_code", "upi_id", "created_at", "profile_id") FROM stdin;
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
-- Data for Name: items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY "public"."items" ("id", "name", "description", "price", "gst_rate", "created_at") FROM stdin;
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
3	payout.initiated	pout_Pv9KiGwT0ZOrV8	\N	{"payout": {"entity": {"id": "pout_Pv9KiGwT0ZOrV8", "tax": 0, "utr": null, "fees": 0, "mode": "UPI", "notes": [], "amount": 107909, "entity": "payout", "status": "processing", "purpose": "refund", "batch_id": null, "currency": "INR", "narration": "404 5085881 1124368", "created_at": 1739439821, "fund_account": {"id": "fa_Pv9KhdPV8oYK95", "vpa": {"handle": "ibl", "address": "9014519229@ibl", "username": "9014519229"}, "active": true, "entity": "fund_account", "batch_id": null, "contact_id": "cont_PBSAPTBCSsqAoE", "created_at": 1739439820, "account_type": "vpa"}, "reference_id": "", "failure_reason": null, "status_details": {"reason": null, "source": null, "description": null}, "fund_account_id": "fa_Pv9KhdPV8oYK95"}}}	2025-02-14 09:21:06.101	f	\N
4	payout.updated	pout_Pv9KiGwT0ZOrV8	\N	{"payout": {"entity": {"id": "pout_Pv9KiGwT0ZOrV8", "tax": 0, "utr": "504422115322", "fees": 0, "mode": "UPI", "notes": [], "amount": 107909, "entity": "payout", "status": "processing", "purpose": "refund", "batch_id": null, "currency": "INR", "narration": "404 5085881 1124368", "created_at": 1739439821, "fund_account": {"id": "fa_Pv9KhdPV8oYK95", "vpa": {"handle": "ibl", "address": "9014519229@ibl", "username": "9014519229"}, "active": true, "entity": "fund_account", "batch_id": null, "contact_id": "cont_PBSAPTBCSsqAoE", "created_at": 1739439820, "account_type": "vpa"}, "reference_id": "", "failure_reason": null, "status_details": {"reason": null, "source": null, "description": null}, "fund_account_id": "fa_Pv9KhdPV8oYK95"}}}	2025-02-14 09:21:09.751	f	\N
5	payout.processed	pout_Pv9KiGwT0ZOrV8	\N	{"payout": {"entity": {"id": "pout_Pv9KiGwT0ZOrV8", "tax": 0, "utr": "504422115322", "fees": 0, "mode": "UPI", "notes": [], "amount": 107909, "entity": "payout", "status": "processed", "purpose": "refund", "batch_id": null, "currency": "INR", "narration": "404 5085881 1124368", "created_at": 1739439821, "fund_account": {"id": "fa_Pv9KhdPV8oYK95", "vpa": {"handle": "ibl", "address": "9014519229@ibl", "username": "9014519229"}, "active": true, "entity": "fund_account", "batch_id": null, "contact_id": "cont_PBSAPTBCSsqAoE", "created_at": 1739439820, "account_type": "vpa"}, "reference_id": "", "failure_reason": null, "status_details": {"reason": "payout_processed", "source": "beneficiary_bank", "description": "Payout is processed and the money has been credited into the beneficiary account."}, "fund_account_id": "fa_Pv9KhdPV8oYK95"}}}	2025-02-14 09:21:09.772	f	\N
6	payout.initiated	pout_Pv9wx4Kr3p2zmo	\N	{"payout": {"entity": {"id": "pout_Pv9wx4Kr3p2zmo", "tax": 0, "utr": null, "fees": 0, "mode": "UPI", "notes": [], "amount": 119840, "entity": "payout", "status": "processing", "purpose": "refund", "batch_id": null, "currency": "INR", "narration": "408 9088347 6821103", "created_at": 1739441993, "fund_account": {"id": "fa_Pv9wwADfvutpN1", "vpa": {"handle": "oksbi", "address": "nilesh2004baviskar@oksbi", "username": "nilesh2004baviskar"}, "active": true, "entity": "fund_account", "batch_id": null, "contact_id": "cont_Pqh3Skuxfsuxju", "created_at": 1739441991, "account_type": "vpa"}, "reference_id": "", "failure_reason": null, "status_details": {"reason": null, "source": null, "description": null}, "fund_account_id": "fa_Pv9wwADfvutpN1"}}}	2025-02-14 09:46:36.131	f	\N
7	payout.updated	pout_Pv9wx4Kr3p2zmo	\N	{"payout": {"entity": {"id": "pout_Pv9wx4Kr3p2zmo", "tax": 0, "utr": "504423129322", "fees": 0, "mode": "UPI", "notes": [], "amount": 119840, "entity": "payout", "status": "processing", "purpose": "refund", "batch_id": null, "currency": "INR", "narration": "408 9088347 6821103", "created_at": 1739441993, "fund_account": {"id": "fa_Pv9wwADfvutpN1", "vpa": {"handle": "oksbi", "address": "nilesh2004baviskar@oksbi", "username": "nilesh2004baviskar"}, "active": true, "entity": "fund_account", "batch_id": null, "contact_id": "cont_Pqh3Skuxfsuxju", "created_at": 1739441991, "account_type": "vpa"}, "reference_id": "", "failure_reason": null, "status_details": {"reason": null, "source": null, "description": null}, "fund_account_id": "fa_Pv9wwADfvutpN1"}}}	2025-02-14 09:46:48.971	f	\N
8	payout.processed	pout_Pv9wx4Kr3p2zmo	\N	{"payout": {"entity": {"id": "pout_Pv9wx4Kr3p2zmo", "tax": 0, "utr": "504423129322", "fees": 0, "mode": "UPI", "notes": [], "amount": 119840, "entity": "payout", "status": "processed", "purpose": "refund", "batch_id": null, "currency": "INR", "narration": "408 9088347 6821103", "created_at": 1739441993, "fund_account": {"id": "fa_Pv9wwADfvutpN1", "vpa": {"handle": "oksbi", "address": "nilesh2004baviskar@oksbi", "username": "nilesh2004baviskar"}, "active": true, "entity": "fund_account", "batch_id": null, "contact_id": "cont_Pqh3Skuxfsuxju", "created_at": 1739441991, "account_type": "vpa"}, "reference_id": "", "failure_reason": null, "status_details": {"reason": "payout_processed", "source": "beneficiary_bank", "description": "Payout is processed and the money has been credited into the beneficiary account."}, "fund_account_id": "fa_Pv9wwADfvutpN1"}}}	2025-02-14 09:46:49.386	f	\N
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
2	Tax Invoice	{"date": "2024-11-15", "type": "invoice", "email": "", "notes": "A/C Holder Name: SHARKS MARKETING \\nAccount No : 50200077326673 \\nIFSC Code: HDFC0002851", "taxes": [{"tax_name": "IGST18", "tax_amount": 78037.87, "tax_amount_formatted": "₹78,037.87"}], "terms": "", "total": 511581.57, "gst_no": "33AAQFG7027B1ZM", "status": "paid", "balance": 0, "contact": {"credit_limit": 0, "customer_balance": 2858149.19, "credit_limit_formatted": "₹0.00", "unused_customer_credits": 0, "customer_balance_formatted": "₹28,58,149.19", "unused_customer_credits_formatted": "₹0.00", "is_credit_limit_migration_completed": true}, "qr_code": {"qr_value": "8699699866@pz", "qr_source": "upi_id", "is_qr_enabled": true, "qr_description": "Scan the QR code to make payment"}, "discount": 0, "due_date": "2024-11-15", "bcy_total": 511581.57, "documents": [], "ewaybills": [], "sub_total": 433543.7, "tax_total": 78037.87, "adjustment": 0, "color_code": "", "invoice_id": "915306000001198001", "is_emailed": true, "is_pre_gst": false, "is_taxable": true, "line_items": [{"name": "Product Marketing and Promotion Services", "rate": 424991.7, "tags": [], "unit": "", "tax_id": "915306000000014233", "bill_id": "", "item_id": "915306000000033003", "bcy_rate": 424991.7, "discount": 0, "quantity": 1, "tax_name": "IGST18", "tax_type": "tax", "discounts": [], "documents": [], "header_id": "", "item_type": "sales", "account_id": "915306000000000486", "expense_id": "", "hsn_or_sac": "", "item_order": 1, "item_total": 424991.7, "project_id": "", "sales_rate": 0, "tds_tax_id": "", "cost_amount": 0, "description": "", "header_name": "", "account_name": "Sales", "bill_item_id": "", "line_item_id": "915306000001198003", "pricebook_id": "", "product_type": "service", "tds_tax_name": "", "internal_name": "", "line_item_tds": [], "markup_percent": 0, "pricing_scheme": "unit", "rate_formatted": "₹4,24,991.70", "tax_percentage": 18, "tds_tax_amount": 0, "time_entry_ids": [], "discount_amount": 0, "has_invalid_hsn": false, "line_item_taxes": [{"tax_id": "915306000000014233", "tax_name": "IGST18 (18%)", "tax_amount": 76498.51, "tax_percentage": 18, "tax_specific_type": "igst", "tax_amount_formatted": "₹76,498.51"}], "image_document_id": "", "bcy_rate_formatted": "₹4,24,991.70", "gst_treatment_code": "", "item_custom_fields": [], "salesorder_item_id": "", "tds_tax_percentage": "", "discount_account_id": "", "item_type_formatted": "Sales Items (Service)", "expense_receipt_name": "", "item_total_formatted": "₹4,24,991.70", "sales_rate_formatted": "₹0.00", "cost_amount_formatted": "₹0.00", "discount_account_name": "", "reverse_charge_tax_id": "", "markup_percent_formatted": "0.00%", "tds_tax_amount_formatted": "₹0.00", "discount_amount_formatted": "₹0.00", "has_product_type_mismatch": false}, {"name": "Product Content Creation and Distribution", "rate": 8552, "tags": [], "unit": "", "tax_id": "915306000000014233", "bill_id": "", "item_id": "915306000000020060", "bcy_rate": 8552, "discount": 0, "quantity": 1, "tax_name": "IGST18", "tax_type": "tax", "discounts": [], "documents": [], "header_id": "", "item_type": "sales", "account_id": "915306000000000486", "expense_id": "", "hsn_or_sac": "998314", "item_order": 2, "item_total": 8552, "project_id": "", "sales_rate": 0, "tds_tax_id": "", "cost_amount": 0, "description": "", "header_name": "", "account_name": "Sales", "bill_item_id": "", "line_item_id": "915306000001198005", "pricebook_id": "", "product_type": "service", "tds_tax_name": "", "internal_name": "", "line_item_tds": [], "markup_percent": 0, "pricing_scheme": "unit", "rate_formatted": "₹8,552.00", "tax_percentage": 18, "tds_tax_amount": 0, "time_entry_ids": [], "discount_amount": 0, "has_invalid_hsn": false, "line_item_taxes": [{"tax_id": "915306000000014233", "tax_name": "IGST18 (18%)", "tax_amount": 1539.36, "tax_percentage": 18, "tax_specific_type": "igst", "tax_amount_formatted": "₹1,539.36"}], "image_document_id": "", "bcy_rate_formatted": "₹8,552.00", "gst_treatment_code": "", "item_custom_fields": [], "salesorder_item_id": "", "tds_tax_percentage": "", "discount_account_id": "", "item_type_formatted": "Sales Items (Service)", "expense_receipt_name": "", "item_total_formatted": "₹8,552.00", "sales_rate_formatted": "₹0.00", "cost_amount_formatted": "₹0.00", "discount_account_name": "", "reverse_charge_tax_id": "", "markup_percent_formatted": "0.00%", "tds_tax_amount_formatted": "₹0.00", "discount_amount_formatted": "₹0.00", "has_product_type_mismatch": false}], "page_width": "8.27in", "tax_reg_no": "33AAQFG7027B1ZM", "approver_id": "", "currency_id": "915306000000000064", "customer_id": "915306000000032001", "debit_notes": [], "estimate_id": "", "invoice_url": "https://zohosecurepay.in/books/sharksmarketinginvoice/secure?CInvoiceID=2-1d4380e501f4f6df2614845b5f4fa395a19c8712400c26b99b7961d7f5419afb8e3c50fa6c54786469463388bac37df4f8a12e785cb6f1ded0c13fa781fd9fffbf3544960638377d ", "merchant_id": "", "orientation": "portrait", "page_height": "11.69in", "salesorders": [], "tds_summary": [], "template_id": "915306000000014440", "created_date": "2024-11-15", "created_time": "2024-11-15T13:30:55+0530", "is_backorder": "", "lock_details": {}, "no_of_copies": 1, "payment_made": 511581.57, "sub_statuses": [], "submitted_by": "", "submitter_id": "", "tax_rounding": "entity_level", "ach_supported": false, "bcy_sub_total": 433543.7, "bcy_tax_total": 78037.87, "created_by_id": "915306000000014001", "currency_code": "INR", "custom_fields": [], "customer_name": "Galaxy Incorporation", "discount_type": "item_level", "exchange_rate": 1, "gst_treatment": "business_gst", "merchant_name": "", "payment_terms": 0, "sales_channel": "direct_sales", "salesorder_id": "", "schedule_time": "", "tax_treatment": "business_gst", "template_name": "Pro", "template_type": "grand", "approvers_list": [], "bcy_adjustment": 0, "contact_number": "CUS-2", "date_formatted": "15/11/2024", "discount_total": 0, "invoice_number": "INV-SM-000154", "invoice_source": "Api", "reminders_sent": 0, "roundoff_value": 0, "salesperson_id": "", "shipping_bills": [], "submitted_date": "", "type_formatted": "Tax Invoice", "attachment_name": "", "billing_address": {"fax": "", "zip": "600060", "city": "Chennai", "phone": "", "state": "Tamil Nadu", "street": "10,11,12 Vishnu Nagar, Annex Grand Layon Village", "address": "10,11,12 Vishnu Nagar, Annex Grand Layon Village", "country": "India", "street2": "Vadaperumbakkam", "attention": "Galaxy Incorporation"}, "contact_persons": [], "created_by_name": "Shivam Gupta", "credits_applied": 0, "currency_symbol": "₹", "merchant_gst_no": "", "payment_options": {"payment_gateways": []}, "place_of_supply": "TN", "price_precision": 2, "shipping_charge": 0, "subject_content": "", "total_formatted": "₹5,11,581.57", "can_send_in_mail": false, "computation_type": "basic", "contact_category": "business_gst", "deliverychallans": [], "discount_percent": 0, "is_inclusive_tax": false, "payment_discount": 0, "reference_number": "", "salesperson_name": "", "shipping_address": {"fax": "", "zip": "", "city": "", "phone": "", "state": "", "street": "", "address": "", "country": "", "street2": "", "attention": ""}, "status_formatted": "Paid", "write_off_amount": 0, "balance_formatted": "₹0.00", "custom_field_hash": {}, "ecomm_operator_id": "", "is_viewed_in_mail": false, "last_payment_date": "2024-11-15", "reference_invoice": {"reference_invoice_id": ""}, "salesorder_number": "", "show_no_of_copies": true, "submitted_by_name": "", "tax_specification": "inter", "zcrm_potential_id": "", "bcy_discount_total": 0, "client_viewed_time": "", "current_sub_status": "paid", "due_date_formatted": "15/11/2024", "gst_return_details": {"status": "PUSH_PROC", "return_period": "11-2024", "status_formatted": "Pushed and Processed", "return_period_formatted": "November - 2024"}, "last_modified_time": "2024-11-21T16:24:34+0530", "submitted_by_email": "", "bcy_shipping_charge": 0, "discount_account_id": "", "ecomm_operator_name": "", "is_autobill_enabled": false, "is_progress_invoice": false, "is_viewed_by_client": false, "last_modified_by_id": "915306000000014001", "payment_terms_label": "Due On Receipt", "shipping_charge_tax": "", "sub_total_formatted": "₹4,33,543.70", "tax_amount_withheld": 0, "tax_total_formatted": "₹78,037.87", "zcrm_potential_name": "", "adjustment_formatted": "₹0.00", "can_send_invoice_sms": true, "recurring_invoice_id": "", "tds_calculation_type": "tds_item_level", "ach_payment_initiated": false, "current_sub_status_id": "", "discount_account_name": "", "dispatch_from_address": {}, "ecomm_operator_gst_no": "", "is_eway_bill_required": false, "is_last_child_invoice": false, "mail_last_viewed_time": "", "payment_expected_date": "", "reason_for_debit_note": "others", "adjustment_description": "", "allow_partial_payments": false, "created_date_formatted": "15/11/2024", "customer_custom_fields": [], "filed_in_vat_return_id": "915306000001256023", "is_discount_before_tax": true, "mail_first_viewed_time": "", "payment_made_formatted": "₹5,11,581.57", "reference_invoice_type": "", "shipping_charge_tax_id": "", "submitted_by_photo_url": "", "bcy_shipping_charge_tax": "", "contact_persons_details": [], "currency_name_formatted": "INR- Indian Rupee", "gst_treatment_formatted": "Registered Business - Regular", "last_reminder_sent_date": "", "schedule_time_formatted": "", "tax_treatment_formatted": "Registered Business - Regular", "tds_override_preference": "no_override", "template_type_formatted": "Grand", "discount_total_formatted": "₹0.00", "filed_in_vat_return_name": "November - 2024", "filed_in_vat_return_type": "in_gst_return", "invoice_source_formatted": "Api", "payment_reminder_enabled": true, "reverse_charge_tax_total": 0, "roundoff_value_formatted": "₹0.00", "shipping_charge_sac_code": "", "shipping_charge_tax_name": "", "shipping_charge_tax_type": "", "submitted_date_formatted": "", "unused_retainer_payments": 0, "credits_applied_formatted": "₹0.00", "is_reverse_charge_applied": false, "place_of_supply_formatted": "Tamil Nadu", "shipping_charge_formatted": "₹0.00", "transaction_rounding_type": "no_rounding", "contact_persons_associated": [], "customer_custom_field_hash": {}, "discount_applied_on_amount": 0, "payment_discount_formatted": "₹0.00", "shipping_charge_account_id": "", "sub_total_inclusive_of_tax": 0, "unprocessed_payment_amount": 0, "write_off_amount_formatted": "₹0.00", "last_payment_date_formatted": "15/11/2024", "client_viewed_time_formatted": "", "current_sub_status_formatted": "Paid", "next_reminder_date_formatted": "", "shipping_charge_account_name": "", "inprocess_transaction_present": false, "shipping_charge_tax_formatted": "", "tax_amount_withheld_formatted": "₹0.00", "includes_package_tracking_info": false, "offline_created_date_with_time": "", "shipping_charge_tax_percentage": "", "can_generate_ewaybill_using_irn": true, "mail_last_viewed_time_formatted": "", "payment_expected_date_formatted": "", "reason_for_debit_note_formatted": "Others", "customer_default_billing_address": {"fax": "", "zip": "600060", "city": "Chennai", "phone": "", "state": "Tamil Nadu", "address": "10,11,12 Vishnu Nagar, Annex Grand Layon Village", "country": "India", "street2": "Vadaperumbakkam", "state_code": ""}, "mail_first_viewed_time_formatted": "", "reader_offline_payment_initiated": false, "shipping_charge_exclusive_of_tax": 0, "shipping_charge_inclusive_of_tax": 0, "shipping_charge_tax_exemption_id": "", "is_client_review_settings_enabled": false, "last_reminder_sent_date_formatted": "", "reverse_charge_tax_total_formatted": "₹0.00", "shipping_charge_tax_exemption_code": "", "unused_retainer_payments_formatted": "₹0.00", "sub_total_inclusive_of_tax_formatted": "₹0.00", "unprocessed_payment_amount_formatted": "₹0.00", "stop_reminder_until_payment_expected_date": false, "shipping_charge_exclusive_of_tax_formatted": "₹0.00", "shipping_charge_inclusive_of_tax_formatted": "₹0.00"}	2025-02-14 12:14:44.43	f	\N
\.


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY "storage"."buckets" ("id", "name", "owner", "created_at", "updated_at", "public", "avif_autodetection", "file_size_limit", "allowed_mime_types", "owner_id") FROM stdin;
user_uploads	user_uploads	\N	2025-02-16 09:41:57.167749+00	2025-02-16 09:41:57.167749+00	t	f	\N	\N	\N
brand_assets	brand_assets	\N	2025-02-16 09:41:57.167749+00	2025-02-16 09:41:57.167749+00	t	f	\N	\N	\N
invoice_documents	invoice_documents	\N	2025-02-16 09:41:57.167749+00	2025-02-16 09:41:57.167749+00	t	f	\N	\N	\N
notification_attachments	notification_attachments	\N	2025-02-16 09:41:57.167749+00	2025-02-16 09:41:57.167749+00	t	f	\N	\N	\N
campaign_assets	campaign_assets	\N	2025-02-16 09:43:46.282804+00	2025-02-16 09:43:46.282804+00	t	f	\N	\N	\N
deliverable_submissions	deliverable_submissions	\N	2025-02-16 09:43:46.282804+00	2025-02-16 09:43:46.282804+00	t	f	\N	\N	\N
coupon_images	coupon_images	\N	2025-02-16 09:43:46.282804+00	2025-02-16 09:43:46.282804+00	t	f	\N	\N	\N
profile_pictures	profile_pictures	\N	2025-02-16 09:44:16.674252+00	2025-02-16 09:44:16.674252+00	t	f	\N	\N	\N
brand_marketing_materials	brand_marketing_materials	\N	2025-02-16 09:44:16.674252+00	2025-02-16 09:44:16.674252+00	t	f	\N	\N	\N
invoice_archive	invoice_archive	\N	2025-02-16 09:44:16.674252+00	2025-02-16 09:44:16.674252+00	t	f	\N	\N	\N
campaign_reports	campaign_reports	\N	2025-02-16 09:44:16.674252+00	2025-02-16 09:44:16.674252+00	t	f	\N	\N	\N
user_documents	user_documents	\N	2025-02-16 09:44:16.674252+00	2025-02-16 09:44:16.674252+00	t	f	\N	\N	\N
feedback_and_reviews	feedback_and_reviews	\N	2025-02-16 09:44:16.674252+00	2025-02-16 09:44:16.674252+00	t	f	\N	\N	\N
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
a92d573a-0b29-42b9-a6d5-3f26dc3bf3b8	RAZORPAY_API_KEY	Dummy Razorpay API Key	SN5QKubfY1QilYWt4y0l8lWOQmsvpCG94zSaaYbVa1jo5Tk4iXn02mwXJ646VfBgi0CouROz	40243e61-3b41-4761-8f3c-4747412598e7	\\xd998b61b0f045afa011fba951b591984	2025-02-14 16:48:34.231832+00	2025-02-14 16:48:34.231832+00
8a289e75-7d99-49f3-aa8a-b7c77ade732d	RAZORPAY_ACCOUNT_NUMBER	Dummy Razorpay Account Number	uFpD0gmvGnjU4QdFUxIMeQiry1tfdmUSpWK7YYaJ+IqIhBly0K4/OOL9IrlKqsDTMdCXuF9u/Ran\n8574Yg==	04e143bc-1934-4ee0-8bee-180a871dd1d1	\\x05281a0feca8a38140b86fb5b5d4554d	2025-02-14 16:48:34.231832+00	2025-02-14 16:48:34.231832+00
402ab7e2-f096-4328-ace5-6fc61e0c757b	RAZORPAYX_API_KEY	Dummy RazorpayX API Key	DaXVIoWN0cyaUaypvlFJjicBjqLo0Sh0lv2lTMRXy2fYSfuWdP32m2Q8yUg/n4qHQ7GyYWtr1g==	a7bd3759-9194-4ab0-b2fb-102a4a54006d	\\x328abf0f8cb51bcd8ffcf579411a69da	2025-02-14 16:48:34.231832+00	2025-02-14 16:48:34.231832+00
ff03a9e0-1925-4dfc-a300-70c9a7208559	ZEPTOMAIL_API_KEY	Dummy ZeptoMail API Key	9OE0/XV3ACugvPpleSH2085xsjgB7H7BXU/fjqZ+nylmQYeQ+OqZPZ7FwNyLrOn6dLPdR+YKOQ==	c35a125b-0f3e-497f-beb0-48f0ea217e05	\\x955c358cf2848f0cfb70f407dc2f65e7	2025-02-14 16:48:34.231832+00	2025-02-14 16:48:34.231832+00
0bbd0dff-1c79-4af9-a616-a0c2a01982b3	ZOHO_BOOKS_API_KEY	Dummy Zoho Books API Key	encpr3nhxM0rYhKYaUmgRtG+KIBH4TGNKN8MeN5iLLykBFJoUcZY1X4ieHxGC8EEPvY8WQw4QFE=	a8a31ed2-a6dd-4231-b57b-9f1fe73b0243	\\x1edb4f2d62d7265bcee5e35c3980b145	2025-02-14 16:48:34.231832+00	2025-02-14 16:48:34.231832+00
13fa44e2-dbbb-4a85-b1ba-b90b6865ecd2	SUPABASE_SERVICE_ROLE_KEY	Dummy Supabase Service Role Key	3ED7bW3/8vOJDanD51lHaYrHzZebHS1oKYTUr74z1L3f/zdsZD02HRrhLDpUF+IZoySu/yQPVuhW\nhTmC7T0q	dc182bc5-7001-48e6-8dbb-75ac910c64fd	\\x715b13260b878122476d1511520e03f1	2025-02-14 16:48:34.231832+00	2025-02-14 16:48:34.231832+00
281d94b8-4291-4f7d-9a26-601da507a323	RAZORPAY_WEBHOOK_SECRET	Dummy Razorpay Webhook Secret	xq80Q+VhRTdUc7EBJ6XXGya8daer+AkjNT+9lOoevt4wV4WfmOVc7Ow4nc4KbXJLBTGCwQt3VExh\noq0T8A==	b59c417e-a40c-4734-910c-cb5adb2d9c23	\\xf3cfd373c83539a90da1971204fb4155	2025-02-14 16:48:34.231832+00	2025-02-14 16:48:34.231832+00
3c7c716a-667c-470d-854f-421149621c57	RAZORPAYX_WEBHOOK_SECRET	Dummy RazorpayX Webhook Secret	6gWXu5Z5j0VohlFEJRQpjYffugeJPwvqbIREiYdf94c6n/mngIHwwXdlmJ7KPP/w9o17eQ3GMeMB\nMQVSL/U=	6be9ced4-9c7c-4bce-b055-801fb9799039	\\x0d173923b30d349c059c1eef86bdee2d	2025-02-14 16:48:34.231832+00	2025-02-14 16:48:34.231832+00
c6a45482-5f62-45c6-b563-87026649e872	ZOHO_BOOKS_WEBHOOK_SECRET	Dummy Zoho Books Webhook Secret	UJUQyTv9MeOABHut/OPTcjr/M65SxbT/w75n4XRwGzUFodrqd6lnPU/DmHLGZiUKx/U9QcwHaZWY\nuBuPCjk2	4e40aa52-d092-40b5-8f3d-113c4f60263c	\\xddb73c5bfceeed7f0c62ab30ba81d13e	2025-02-14 16:48:34.231832+00	2025-02-14 16:48:34.231832+00
0c91b3f0-a669-4daa-967c-ca9842a1239f	ZEPTOMAIL_WEBHOOK_SECRET	Dummy ZeptoMail Webhook Secret	pzpczl6vowKjZxbiThs/CpD3ENHG752NTXsXUdw98RS1tTahYcDQEK2ilJVXwlq4J3EhxbZ76tiz\nAxbqPw0=	51905cd1-51cf-465b-a138-1551fd207129	\\x1d79309ff824035ba906f27bcb87b846	2025-02-14 16:48:34.231832+00	2025-02-14 16:48:34.231832+00
164cf17c-5223-4593-95c4-5ec608ea8e8c	RAZORPAY_VA_IFSC	Dummy Razorpay Virtual Account IFSC	yADy47vmP6U3GcUxYbxIYUlZrzBH/3ZmQVa0YWumHLPFkyqk1Kb92AmQHZV2MBM/xevuWdKaDZsO\nWxeOoYJP8RPO+g==	91e43e66-67df-44d6-a874-6549ea798b68	\\x80aead784accbb2cc756f6eb9a742757	2025-02-14 16:48:34.231832+00	2025-02-14 16:48:34.231832+00
a83af29e-0de1-4a9c-b8c0-6b33c562dfcb	RAZORPAY_VA_UPI_ID	Dummy Razorpay Virtual Account UPI ID	VF02jAfNtxBmOMPkGWJj3wtBPUeaSQok4vx85ZIm+8xT0CGGgYFsbqdIpoTG+D70m59sBFAxoUIa\n21eZxyeBLA8j	cca297d9-36f7-461d-b189-579716ebe774	\\xf4b07fcf7ea1ae265a5fdbe09e44d803	2025-02-14 16:48:34.231832+00	2025-02-14 16:48:34.231832+00
df16a67a-b4d7-47e5-b95b-b60a0bf26c33	NOTIFICATION_EMAIL_SENDER	Dummy Email Sender	BAeLjh5TyIR04myLuf1vQ3BWySMcuvBgphQ+ia7yHAsMupTS25AMnHoanzmA5Jrzc3Ce8WNPX5/R\nGPSGW+gi	f9393bce-e616-461c-a9d5-edc38870ee9b	\\x5fe3309e69a32745dbc1597bab403a3b	2025-02-14 16:48:34.231832+00	2025-02-14 16:48:34.231832+00
53dcc9a8-0fb2-40a2-9877-01f90cc119f3	NOTIFICATION_WHATSAPP_API_KEY	Dummy WhatsApp API Key	MdQL57bzgXHbjC23+eJtYw5v/A99f6bnFVUm+4YKiLH2FU4nAiYOMr4uPaCAPpUYF2X9omtWZljI\nAQcwuawRAllxlA==	48a361b5-4aa8-4efd-9794-805c6ebe95d6	\\x4a9ad380adf603776e7bbf9c24e47ab8	2025-02-14 16:48:34.231832+00	2025-02-14 16:48:34.231832+00
447b0980-7f38-4f5f-b190-14b1cb3be767	SUPABASE_STORAGE_BUCKET	Dummy Storage Bucket Name	KtBApftXkazneHWMP8w2HvyNX6k85GuFDFtaU1dUvEnyqY8EGO99CwqXwqNhoDXFahfLjoODqoBi\nX+nW4g==	e2989faf-5ca0-48cd-8a65-ad4f0c484c7f	\\x5cf71b7c3a97b227bd56863696fce1a8	2025-02-14 16:48:34.231832+00	2025-02-14 16:48:34.231832+00
e44b0bef-78cf-460b-8dc9-e3c84ca0c4bd	SUPABASE_EDGE_FUNCTION_URL	Dummy Edge Function Base URL	+fLDHtUohldVWvFDhRr5XNVFM0nkVWhWFqIEhkhcBQd0QxxeLaEIMB5TcvyvxnP0HWwCqNVcxw1k\nkCu2de6NOw==	fbb94ab6-7ce3-42e8-899b-4413f8077418	\\x88a1e7e868f78725df3c73251a4d8356	2025-02-14 16:48:34.231832+00	2025-02-14 16:48:34.231832+00
\.


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: supabase_auth_admin
--

SELECT pg_catalog.setval('"auth"."refresh_tokens_id_seq"', 14, true);


--
-- Name: key_key_id_seq; Type: SEQUENCE SET; Schema: pgsodium; Owner: supabase_admin
--

SELECT pg_catalog.setval('"pgsodium"."key_key_id_seq"', 17, true);


--
-- Name: admin_profiles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."admin_profiles_id_seq"', 1, false);


--
-- Name: brand_profiles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."brand_profiles_id_seq"', 6, true);


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
-- Name: items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."items_id_seq"', 1, false);


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

SELECT pg_catalog.setval('"public"."profiles_id_seq"', 3, true);


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

SELECT pg_catalog.setval('"public"."razorpay_x_webhooks_id_seq"', 8, true);


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

SELECT pg_catalog.setval('"public"."zoho_books_webhooks_id_seq"', 2, true);


--
-- PostgreSQL database dump complete
--

RESET ALL;
