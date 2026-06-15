--
-- PostgreSQL database dump
--

\restrict gSWAW1Hma3wO248AqUvNSmNfO0REwKuFSyXJpNMYuIS7xegMkaR8Xre5vh8mhoM

-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.receipt_register DROP CONSTRAINT IF EXISTS receipt_register_pkey;
ALTER TABLE IF EXISTS ONLY public.receipt_adjustment_register DROP CONSTRAINT IF EXISTS receipt_adjustment_register_pkey;
ALTER TABLE IF EXISTS ONLY public.firm_master DROP CONSTRAINT IF EXISTS firm_master_pkey;
ALTER TABLE IF EXISTS ONLY public.firm_master DROP CONSTRAINT IF EXISTS firm_master_firm_name_key;
ALTER TABLE IF EXISTS ONLY public.executive_partner_master DROP CONSTRAINT IF EXISTS executive_partner_master_pkey;
ALTER TABLE IF EXISTS ONLY public.executive_partner_master DROP CONSTRAINT IF EXISTS executive_partner_master_partner_name_key;
ALTER TABLE IF EXISTS ONLY public.deleted_records_log DROP CONSTRAINT IF EXISTS deleted_records_log_pkey;
ALTER TABLE IF EXISTS ONLY public.debtor_nav_access DROP CONSTRAINT IF EXISTS debtor_nav_access_pkey;
ALTER TABLE IF EXISTS ONLY public.debtor_import_client_errors DROP CONSTRAINT IF EXISTS debtor_import_client_errors_pkey;
ALTER TABLE IF EXISTS ONLY public.crp_master DROP CONSTRAINT IF EXISTS crp_master_pkey;
ALTER TABLE IF EXISTS ONLY public.crp_master DROP CONSTRAINT IF EXISTS crp_master_crp_name_key;
ALTER TABLE IF EXISTS ONLY public.client_master DROP CONSTRAINT IF EXISTS client_master_pkey;
ALTER TABLE IF EXISTS ONLY public.client_group_master DROP CONSTRAINT IF EXISTS client_group_master_pkey;
ALTER TABLE IF EXISTS ONLY public.client_group_master DROP CONSTRAINT IF EXISTS client_group_master_group_name_key;
ALTER TABLE IF EXISTS ONLY public.cheque_bounce_register DROP CONSTRAINT IF EXISTS cheque_bounce_register_pkey;
ALTER TABLE IF EXISTS ONLY public.billing_report DROP CONSTRAINT IF EXISTS billing_report_pkey;
ALTER TABLE IF EXISTS ONLY public.app_meta DROP CONSTRAINT IF EXISTS app_meta_pkey;
ALTER TABLE IF EXISTS public.receipt_register ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.receipt_adjustment_register ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.firm_master ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.executive_partner_master ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.deleted_records_log ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.debtor_import_client_errors ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.crp_master ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.client_master ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.client_group_master ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.cheque_bounce_register ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.billing_report ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE IF EXISTS public.receipt_register_id_seq;
DROP TABLE IF EXISTS public.receipt_register;
DROP SEQUENCE IF EXISTS public.receipt_adjustment_register_id_seq;
DROP TABLE IF EXISTS public.receipt_adjustment_register;
DROP SEQUENCE IF EXISTS public.firm_master_id_seq;
DROP TABLE IF EXISTS public.firm_master;
DROP SEQUENCE IF EXISTS public.executive_partner_master_id_seq;
DROP TABLE IF EXISTS public.executive_partner_master;
DROP SEQUENCE IF EXISTS public.deleted_records_log_id_seq;
DROP TABLE IF EXISTS public.deleted_records_log;
DROP TABLE IF EXISTS public.debtor_nav_access;
DROP SEQUENCE IF EXISTS public.debtor_import_client_errors_id_seq;
DROP TABLE IF EXISTS public.debtor_import_client_errors;
DROP SEQUENCE IF EXISTS public.crp_master_id_seq;
DROP TABLE IF EXISTS public.crp_master;
DROP SEQUENCE IF EXISTS public.client_master_id_seq;
DROP TABLE IF EXISTS public.client_master;
DROP SEQUENCE IF EXISTS public.client_group_master_id_seq;
DROP TABLE IF EXISTS public.client_group_master;
DROP SEQUENCE IF EXISTS public.cheque_bounce_register_id_seq;
DROP TABLE IF EXISTS public.cheque_bounce_register;
DROP SEQUENCE IF EXISTS public.billing_report_id_seq;
DROP TABLE IF EXISTS public.billing_report;
DROP TABLE IF EXISTS public.app_meta;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: app_meta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.app_meta (
    key text NOT NULL,
    value text
);


--
-- Name: billing_report; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.billing_report (
    id integer NOT NULL,
    firm_name text,
    short_name text,
    bill_date text,
    ref_no text,
    party_name text,
    amount real,
    due_date text,
    overdue_days integer,
    import_batch_id text,
    ep_override text,
    receipt_status text DEFAULT 'open'::text,
    paid_amount real DEFAULT 0,
    closed_at text,
    group_override text,
    followup_partner text,
    deleted_at text,
    deleted_by text,
    delete_reason text
);


--
-- Name: billing_report_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.billing_report_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: billing_report_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.billing_report_id_seq OWNED BY public.billing_report.id;


--
-- Name: cheque_bounce_register; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cheque_bounce_register (
    id integer NOT NULL,
    receipt_register_id integer,
    source_bill_id integer,
    readded_bill_id integer,
    bounced_at text,
    bounce_date text,
    firm_name text,
    short_name text,
    bill_date text,
    ref_no text,
    party_name text,
    bill_amount real,
    bounced_amount real,
    receipt_date text,
    receipt_mode text,
    posted_at text,
    due_date text,
    overdue_days integer,
    client_group text,
    followup_partner text,
    final_ep text,
    crp_of_group text,
    client_category text,
    financial_year text,
    reason text
);


--
-- Name: cheque_bounce_register_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cheque_bounce_register_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cheque_bounce_register_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cheque_bounce_register_id_seq OWNED BY public.cheque_bounce_register.id;


--
-- Name: client_group_master; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.client_group_master (
    id integer NOT NULL,
    group_name text NOT NULL,
    crp_name text,
    reffered_by text,
    created_at text DEFAULT CURRENT_TIMESTAMP,
    updated_at text
);


--
-- Name: client_group_master_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.client_group_master_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: client_group_master_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.client_group_master_id_seq OWNED BY public.client_group_master.id;


--
-- Name: client_master; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.client_master (
    id integer NOT NULL,
    client_name text NOT NULL,
    phone text,
    email text,
    gstin text,
    client_group text,
    crp_of_group text,
    reffered_by text,
    whatapp_group text,
    client_category text
);


--
-- Name: client_master_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.client_master_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: client_master_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.client_master_id_seq OWNED BY public.client_master.id;


--
-- Name: crp_master; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crp_master (
    id integer NOT NULL,
    crp_name text NOT NULL,
    created_at text DEFAULT CURRENT_TIMESTAMP,
    updated_at text
);


--
-- Name: crp_master_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.crp_master_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: crp_master_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.crp_master_id_seq OWNED BY public.crp_master.id;


--
-- Name: debtor_import_client_errors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.debtor_import_client_errors (
    id integer NOT NULL,
    batch_id text NOT NULL,
    imported_at text,
    party_name text,
    firm_names text,
    bill_count integer DEFAULT 0,
    total_amount real DEFAULT 0,
    sample_ref_nos text
);


--
-- Name: debtor_import_client_errors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.debtor_import_client_errors_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: debtor_import_client_errors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.debtor_import_client_errors_id_seq OWNED BY public.debtor_import_client_errors.id;


--
-- Name: debtor_nav_access; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.debtor_nav_access (
    user_email text NOT NULL,
    access_key text NOT NULL
);


--
-- Name: deleted_records_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deleted_records_log (
    id integer NOT NULL,
    source_table text NOT NULL,
    source_pk text,
    display_type text,
    display_label text,
    display_summary text,
    payload_json text NOT NULL,
    deleted_at text,
    deleted_by text,
    restore_status text DEFAULT 'deleted'::text,
    restored_at text,
    restored_by text
);


--
-- Name: deleted_records_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deleted_records_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deleted_records_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deleted_records_log_id_seq OWNED BY public.deleted_records_log.id;


--
-- Name: executive_partner_master; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.executive_partner_master (
    id integer NOT NULL,
    partner_name text NOT NULL,
    final_ep text
);


--
-- Name: executive_partner_master_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.executive_partner_master_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: executive_partner_master_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.executive_partner_master_id_seq OWNED BY public.executive_partner_master.id;


--
-- Name: firm_master; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.firm_master (
    id integer NOT NULL,
    firm_name text NOT NULL,
    short_name text
);


--
-- Name: firm_master_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.firm_master_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: firm_master_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.firm_master_id_seq OWNED BY public.firm_master.id;


--
-- Name: receipt_adjustment_register; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.receipt_adjustment_register (
    id integer NOT NULL,
    source_bill_id integer,
    firm_name text,
    short_name text,
    bill_date text,
    ref_no text,
    party_name text,
    bill_amount real,
    adjustment_amount real,
    balance_amount real,
    due_date text,
    overdue_days integer,
    client_group text,
    followup_partner text,
    final_ep text,
    crp_of_group text,
    client_category text,
    financial_year text,
    adjustment_type text,
    adjustment_date text,
    posted_at text
);


--
-- Name: receipt_adjustment_register_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.receipt_adjustment_register_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: receipt_adjustment_register_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.receipt_adjustment_register_id_seq OWNED BY public.receipt_adjustment_register.id;


--
-- Name: receipt_register; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.receipt_register (
    id integer NOT NULL,
    source_bill_id integer,
    firm_name text,
    short_name text,
    bill_date text,
    ref_no text,
    party_name text,
    bill_amount real,
    received_amount real,
    balance_amount real,
    due_date text,
    overdue_days integer,
    client_group text,
    followup_partner text,
    final_ep text,
    crp_of_group text,
    client_category text,
    financial_year text,
    receipt_mode text,
    receipt_date text,
    posted_at text,
    import_source text,
    tally_voucher_no text,
    tally_reference_no text,
    tally_bank_name text,
    tally_excel_rows text
);


--
-- Name: receipt_register_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.receipt_register_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: receipt_register_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.receipt_register_id_seq OWNED BY public.receipt_register.id;


--
-- Name: billing_report id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_report ALTER COLUMN id SET DEFAULT nextval('public.billing_report_id_seq'::regclass);


--
-- Name: cheque_bounce_register id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cheque_bounce_register ALTER COLUMN id SET DEFAULT nextval('public.cheque_bounce_register_id_seq'::regclass);


--
-- Name: client_group_master id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_group_master ALTER COLUMN id SET DEFAULT nextval('public.client_group_master_id_seq'::regclass);


--
-- Name: client_master id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_master ALTER COLUMN id SET DEFAULT nextval('public.client_master_id_seq'::regclass);


--
-- Name: crp_master id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crp_master ALTER COLUMN id SET DEFAULT nextval('public.crp_master_id_seq'::regclass);


--
-- Name: debtor_import_client_errors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.debtor_import_client_errors ALTER COLUMN id SET DEFAULT nextval('public.debtor_import_client_errors_id_seq'::regclass);


--
-- Name: deleted_records_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deleted_records_log ALTER COLUMN id SET DEFAULT nextval('public.deleted_records_log_id_seq'::regclass);


--
-- Name: executive_partner_master id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.executive_partner_master ALTER COLUMN id SET DEFAULT nextval('public.executive_partner_master_id_seq'::regclass);


--
-- Name: firm_master id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.firm_master ALTER COLUMN id SET DEFAULT nextval('public.firm_master_id_seq'::regclass);


--
-- Name: receipt_adjustment_register id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.receipt_adjustment_register ALTER COLUMN id SET DEFAULT nextval('public.receipt_adjustment_register_id_seq'::regclass);


--
-- Name: receipt_register id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.receipt_register ALTER COLUMN id SET DEFAULT nextval('public.receipt_register_id_seq'::regclass);


--
-- Data for Name: app_meta; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.app_meta (key, value) FROM stdin;
last_followup_logic_run_at	2026-06-10 17:27:52
last_debtor_imported_at	2026-06-11
last_receipt_activity_at	2026-06-01
last_receipt_activity_type	Import
manual_last_bill_update_date	2026-06-10
manual_last_receipt_update_date	2026-06-12
manual_report_as_on_date	2026-06-12
last_debtor_import_batch_id	20260611184256112699
\.


--
-- Data for Name: billing_report; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.billing_report (id, firm_name, short_name, bill_date, ref_no, party_name, amount, due_date, overdue_days, import_batch_id, ep_override, receipt_status, paid_amount, closed_at, group_override, followup_partner, deleted_at, deleted_by, delete_reason) FROM stdin;
740	Asija And Associates LLP	AAA LLP	2026-04-24	HO/26-27/KKF/021	Uttar Pradesh Gramin Bank	219737	2026-05-24 00:00:00	27	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
580	AAAFC	AAAFC	2026-03-10	AAAFC/25-26/AA/0140	Pawan Rathour	15000	2026-04-09 00:00:00	42	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
932	AAAFC	AAAFC	2026-06-10	AAAFC/26-27/AA/0020	Janardan Singh	10000	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
963	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0021	K.N. Associates	2147	2026-07-10 00:00:00	1	20260611184256112699	\N	open	0	\N	\N	\N	\N	\N	\N
964	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0005	La Martiniere College, Lucknow	21830	2026-07-10 00:00:00	1	20260611184256112699	\N	open	0	\N	\N	RohitS	\N	\N	\N
965	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0022	Murad Ventures Private Limited	1806	2026-07-10 00:00:00	1	20260611184256112699	\N	open	0	\N	\N	SahilD	\N	\N	\N
966	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0023	Pavaki Infrasolutions LLP	6302	2026-07-10 00:00:00	1	20260611184256112699	\N	open	0	\N	\N	SahilD	\N	\N	\N
974	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0028	SSCC Constructions Private Limited - UP	2644	2026-07-10 00:00:00	1	20260611184256112699	\N	open	0	\N	\N	SahilD	\N	\N	\N
975	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0011	State Health Society of Uttar Pradesh	52274	2026-07-10 00:00:00	1	20260611184256112699	\N	open	0	\N	\N	PrademnP-X	\N	\N	\N
934	AAAFC	AAAFC	2026-06-10	AAAFC/26-27/AA/0021	Sachin Shukla	12500	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
979	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0025	Suyash Bansal	2396	2026-07-10 00:00:00	1	20260611184256112699	\N	open	0	\N	\N	\N	\N	\N	\N
980	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0030	Unix Enterprises Private Limited	2306	2026-07-10 00:00:00	1	20260611184256112699	\N	open	0	\N	\N	KamalF	\N	\N	\N
981	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0031	U.P.Sainik Punarvas Nidhi	2902	2026-07-10 00:00:00	1	20260611184256112699	\N	open	0	\N	\N	\N	\N	\N	\N
618	Asija And Associates LLP	AAA LLP	2024-06-01	HO/24-25/PP/0021	Deputy CAO Zonal Account Office PVVNL-Gorakhpur	256096	2024-07-01 00:00:00	689	\N	\N	open	0	\N	\N	PrademnP-X	\N	\N	\N
758	Asija And Associates LLP	AAA LLP	2026-05-07	HO/26-27/SD/0010	Ensky Ventures Private Limited	11800	2026-06-06 00:00:00	14	\N	\N	open	0	\N	\N	SahilD	\N	\N	\N
920	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0003	Vishal Mishra	8850	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	AkashA	2026-06-11 18:29:13	arif.siddiqui@asija.in	Bulk delete from main report
923	AAAFC	AAAFC	2026-06-05	AAAFC/26-27/Corpl/0008	CNL Health LLP	3550	2026-07-05 00:00:00	4	\N	\N	open	0	\N	\N	SahilD	\N	\N	\N
632	Asija And Associates LLP	AAA LLP	2025-09-13	HO/25-26/KKF/050	Dy Fa And Cao Construction Northern Railway Charbagh	70280	2025-10-13 00:00:00	220	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
634	Asija And Associates LLP	AAA LLP	2025-10-10	HO/25-26/CL/0057	Karam Infracon LLP	1180	2025-11-09 00:00:00	193	\N	\N	full_paid	1180	2026-06-09 10:05:48	\N	KamalF	\N	\N	\N
635	Asija And Associates LLP	AAA LLP	2025-10-24	HO/25-26/KKF/074	District Horticulture Officer, Barabanki	7363	2025-11-23 00:00:00	179	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
652	Asija And Associates LLP	AAA LLP	2026-01-10	HO/25-26/RS/0190	Spacia Infra and Services	23600	2026-02-09 00:00:00	131	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
653	Asija And Associates LLP	AAA LLP	2026-01-10	HO/25-26/RS/0216	Spacia Ventures LLP	22066	2026-02-09 00:00:00	101	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
655	Asija And Associates LLP	AAA LLP	2026-02-10	HO/25-26/AA/0190	KM Particle Boards Private Limited	162250	2026-03-12 00:00:00	70	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
656	Asija And Associates LLP	AAA LLP	2026-02-10	HO/25-26/RS/0238	La Martiniere College, Lucknow	177000	2026-03-12 00:00:00	70	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
657	Asija And Associates LLP	AAA LLP	2026-02-10	HO/25-26/CL/0116	PS Global Consumer Healthcare Pvt .Ltd	13570	2026-03-12 00:00:00	70	\N	\N	full_paid	13570	2026-06-04 14:57:36	\N	AshishK	\N	\N	\N
658	Asija And Associates LLP	AAA LLP	2026-02-10	HO/25-26/RS/0228	Rogi Kalyan Samiti - Dr.S.P.M.Civil Hospital	3068	2026-03-12 00:00:00	70	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
659	Asija And Associates LLP	AAA LLP	2026-02-10	HO/25-26/CL/0119	Sanjivan Healthcare Enterprise Private Limited	22420	2026-03-12 00:00:00	100	\N	\N	full_paid	22420	2026-06-04 14:57:36	\N	AshishK	\N	\N	\N
660	Asija And Associates LLP	AAA LLP	2026-02-10	HO/25-26/AA/0199	Sarvagaya Infrapromoters LLP	590	2026-03-12 00:00:00	70	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
661	Asija And Associates LLP	AAA LLP	2026-02-10	HO/25-26/AA/0201	Soham Infrapromoters Private Limited	590	2026-03-12 00:00:00	70	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
663	Asija And Associates LLP	AAA LLP	2026-02-10	HO/25-26/RS/0235	Spacia Infra and Services	4720	2026-03-12 00:00:00	100	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
664	Asija And Associates LLP	AAA LLP	2026-02-10	HO/25-26/AA/0210	Spacia Infra and Services	1876	2026-03-12 00:00:00	100	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
665	Asija And Associates LLP	AAA LLP	2026-02-10	HO/25-26/RS/0234	Spacia Ventures LLP	4366	2026-03-12 00:00:00	70	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
666	Asija And Associates LLP	AAA LLP	2026-02-10	HO/25-26/AA/0202	Spacia Ventures LLP	1806	2026-03-12 00:00:00	70	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
667	Asija And Associates LLP	AAA LLP	2026-02-10	HO/25-26/CL/0099	S. S. Infrazone Private Limited	150	2026-03-12 00:00:00	70	\N	\N	open	0	\N	\N	ManishM	\N	\N	\N
668	Asija And Associates LLP	AAA LLP	2026-02-10	HO/25-26/AA/0215	State Health Society of Uttar Pradesh	14750	2026-03-12 00:00:00	70	\N	\N	open	0	\N	\N	PrademnP-X	\N	\N	\N
803	Asija Tech Consulting LLP	ATC	2026-03-31	ATC/25-26/AK/0018	Prateek Kumar Singh	7000	2026-04-30 00:00:00	21	\N	\N	open	0	\N	\N	AshishK	\N	\N	\N
669	Asija And Associates LLP	AAA LLP	2026-02-10	HO/25-26/RS/0241	The Pradeshiya Industrial & Investment Coporation of U.P. Ltd.	47200	2026-03-12 00:00:00	70	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
670	Asija And Associates LLP	AAA LLP	2026-02-10	HO/25-26/CL/0117	Unisel Infraservices and Trade Pvt Ltd	13570	2026-03-12 00:00:00	70	\N	\N	full_paid	13570	2026-06-04 14:57:36	\N	AshishK	\N	\N	\N
671	Asija And Associates LLP	AAA LLP	2026-02-10	HO/25-26/CL/0118	Unisel Overseas India Pvt Ltd	13570	2026-03-12 00:00:00	70	\N	\N	full_paid	13570	2026-06-04 14:57:36	\N	AshishK	\N	\N	\N
672	Asija And Associates LLP	AAA LLP	2026-02-10	HO/25-26/AA/0214	Vishal Mishra	3540	2026-03-12 00:00:00	100	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
673	Asija And Associates LLP	AAA LLP	2026-02-17	HO/25-26/KKF/0145	General Manager  (Fin) NHAI	42300	2026-03-19 00:00:00	93	\N	\N	full_paid	42300	2026-05-29 14:01:59	\N	\N	\N	\N	\N
674	Asija And Associates LLP	AAA LLP	2026-02-19	HO/25-26/RS/0243	Airports Authority of India	29500	2026-03-21 00:00:00	91	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
675	Asija And Associates LLP	AAA LLP	2026-02-24	HO/25-26/KKF/149	The Department of Information & Public Relation	59000	2026-03-26 00:00:00	56	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
676	Asija And Associates LLP	AAA LLP	2026-02-25	HO/25-26/AK/0057	BLUE BELL DR RAM TIRTH DUBE MEMORIAL SHIKSHA SANSTHAN	18959	2026-03-27 00:00:00	85	\N	\N	open	0	\N	\N	AshishK	\N	\N	\N
677	Asija And Associates LLP	AAA LLP	2026-02-26	HO/25-26/SD/0147	United Nations Development Programme- Afganistan	90907.2	2026-03-28 00:00:00	96	\N	SahilD	open	0	\N		SahilD	\N	\N	\N
678	Asija And Associates LLP	AAA LLP	2026-03-09	HO/25-26/CL/0120	Winstrux Global LLP	7670	2026-04-08 00:00:00	73	\N	\N	full_paid	7670	2026-06-09 10:05:48	\N	KamalF	\N	\N	\N
679	Asija And Associates LLP	AAA LLP	2026-03-10	HO/25-26/SD/0151	BKS MyGold Private Limited	1	2026-04-09 00:00:00	42	\N	\N	part_paid	23599	\N	\N	SahilD	\N	\N	\N
680	Asija And Associates LLP	AAA LLP	2026-03-10	HO/25-26/SD/0152	Bks Myvault Private Limited	2000	2026-04-09 00:00:00	12	\N	\N	full_paid	23600	2026-06-02 10:46:55	\N	SahilD	\N	\N	\N
681	Asija And Associates LLP	AAA LLP	2026-03-10	HO/25-26/RS/0256	Iqbal Kidwai	1298	2026-04-09 00:00:00	42	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
682	Asija And Associates LLP	AAA LLP	2026-03-10	HO/25-26/AA/0216	Karam Safety Private Limited-ISD	26550	2026-04-09 00:00:00	72	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
683	Asija And Associates LLP	AAA LLP	2026-03-10	HO/25-26/RS/0257	Rogi Kalyan Samiti - Dr.S.P.M.Civil Hospital	3186	2026-04-09 00:00:00	42	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
684	Asija And Associates LLP	AAA LLP	2026-03-10	HO/25-26/RS/0249	Spacia Infra and Services	4720	2026-04-09 00:00:00	72	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
685	Asija And Associates LLP	AAA LLP	2026-03-10	HO/25-26/RS/0248	Spacia Ventures LLP	4366	2026-04-09 00:00:00	42	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
686	Asija And Associates LLP	AAA LLP	2026-03-10	HO/25-26/RS/0246	Unix Enterprises Private Limited	2596	2026-04-09 00:00:00	42	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
687	Asija And Associates LLP	AAA LLP	2026-03-10	HO/25-26/AA/0218	Vishal Mishra	3540	2026-04-09 00:00:00	72	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
688	Asija And Associates LLP	AAA LLP	2026-03-16	HO/25-26/KKF/160	DC MGNREGA Ambedkar Nagar	14957	2026-04-15 00:00:00	66	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
689	Asija And Associates LLP	AAA LLP	2026-03-17	HO/25-26/KKF/161	UP State Construction and Infrastructure Development Corporation Ltd.	17700	2026-04-16 00:00:00	35	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
690	Asija And Associates LLP	AAA LLP	2026-03-18	HO/24-25/KKF/164	Rajat Singh	47200	2026-04-17 00:00:00	34	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
691	Asija And Associates LLP	AAA LLP	2026-03-26	HO/25-26/AK/0067	Vidit Advertising	11800	2026-04-25 00:00:00	26	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
692	Asija And Associates LLP	AAA LLP	2026-03-27	HO/25-26/KKF/169	Arif Care Foundation	5900	2026-04-26 00:00:00	25	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
693	Asija And Associates LLP	AAA LLP	2026-03-27	HO/25-26/KKF/168	SHG For Bareilly Self Employed Women Awareness	8850	2026-04-26 00:00:00	55	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
694	Asija And Associates LLP	AAA LLP	2026-03-30	HO/25-26/KKF/174	District Horticulture Officer, Barabanki	5228	2026-04-29 00:00:00	22	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
695	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/RS/0274	Airports Authority of India	53100	2026-04-30 00:00:00	51	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
696	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/SD/0159	B.K. Girijadevi Investment Private Limited	2000	2026-04-30 00:00:00	21	\N	\N	full_paid	23600	2026-06-02 10:46:55	\N	SahilD	\N	\N	\N
636	Asija And Associates LLP	AAA LLP	2025-11-03	HO/25-26/KKF/076	DC NRLM Ambedkar Nagar	16108	2025-12-03 00:00:00	199	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
697	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/SD/0158	B K Saraf Private Limited	2500	2026-04-30 00:00:00	21	\N	\N	full_paid	29500	2026-06-02 10:46:55	\N	SahilD	\N	\N	\N
698	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/AK/0069	BLUE BELL DR RAM TIRTH DUBE MEMORIAL SHIKSHA SANSTHAN	7523	2026-04-30 00:00:00	51	\N	\N	open	0	\N	\N	AshishK	\N	\N	\N
699	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/SD/0164	Chillies N Lemon Infra & Hospitality LLP	27000	2026-04-30 00:00:00	21	\N	\N	part_paid	2500	\N	\N	SahilD	\N	\N	\N
700	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/AA/0223	Indian Institute Of Management Lucknow	8260	2026-04-30 00:00:00	21	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
701	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/RS/0263	Iqbal Kidwai	10384	2026-04-30 00:00:00	21	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
704	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/SD/0167	La Martiniere College, Lucknow	20650	2026-04-30 00:00:00	21	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
705	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/KKF/193	Manjil Prerna Sankul Samiti	35400	2026-04-30 00:00:00	51	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
706	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/SD/0155	Pavaki Infrasolutions LLP	10030	2026-04-30 00:00:00	21	\N	\N	open	0	\N	\N	SahilD	\N	\N	\N
707	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/SD/0160	Pavaki Infrasolutions LLP	29500	2026-04-30 00:00:00	21	\N	\N	open	0	\N	\N	SahilD	\N	\N	\N
708	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/RS/0273	PN Safetech Private Limited-Uttar Pradesh	10620	2026-04-30 00:00:00	21	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
709	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/SD/0161	PN Safetech Private Limited-Uttar Pradesh	122662	2026-04-30 00:00:00	21	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
710	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/RS/0269	Rogi Kalyan Samiti - Dr.S.P.M.Civil Hospital	3186	2026-04-30 00:00:00	21	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
711	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/SD/0165	Shri Ramswaroop Multi Engineering Solutions Private Limited	29500	2026-04-30 00:00:00	21	\N	\N	open	0	\N	\N	SahilD	\N	\N	\N
712	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/RS/0268	Spacia Infra and Services	4720	2026-04-30 00:00:00	51	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
715	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/SD/0156	Spectrum Venture International Private Limited	1800	2026-04-30 00:00:00	21	\N	\N	full_paid	21240	2026-06-02 10:46:55	\N	SahilD	\N	\N	\N
716	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/SD/0166	SSCC Constructions Private Limited - UP	29500	2026-04-30 00:00:00	21	\N	\N	open	0	\N	\N	SahilD	\N	\N	\N
717	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/SD/0157	St Teresas Day School And College Society	70800	2026-04-30 00:00:00	21	\N	\N	open	0	\N	\N	SahilD	\N	\N	\N
718	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/RS/0282	The Pradeshiya Industrial & Investment Coporation of U.P. Ltd.	377600	2026-04-30 00:00:00	21	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
719	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/RS/0283	The Pradeshiya Industrial & Investment Coporation of U.P. Ltd.	47200	2026-04-30 00:00:00	21	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
720	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/RS/0265	Unix Enterprises Private Limited	2596	2026-04-30 00:00:00	21	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
721	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/CL/123	Unix Enterprises Private Limited	5030	2026-04-30 00:00:00	21	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
722	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/RS/0275	UP Metro Rail Corporation Ltd.	25960	2026-04-30 00:00:00	51	\N	\N	full_paid	25960	2026-06-02 10:18:34	\N	RohitS	\N	\N	\N
723	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/RS/0266	Vidit Advertising	5192	2026-04-30 00:00:00	21	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
724	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/KKF/199	Vikas Prerna Sankul Samiti	35400	2026-04-30 00:00:00	51	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
726	Asija And Associates LLP	AAA LLP	2026-04-01	HO/26-27/KKF/005	ICICI Bank Limited-Hazratganj Branch	53100	2026-05-01 00:00:00	20	\N	\N	full_paid	53100	2026-06-02 10:30:49	\N	KamalF	\N	\N	\N
727	Asija And Associates LLP	AAA LLP	2026-04-01	HO/26-27/KKF/008	ICICI Bank Limited - Mahanagar Branch	41300	2026-05-01 00:00:00	50	\N	\N	full_paid	41300	2026-06-02 10:30:49	\N	KamalF	\N	\N	\N
728	Asija And Associates LLP	AAA LLP	2026-04-01	HO/26-27/KKF/007	Northern Coalfields Limited , Dudhichua	37341	2026-05-01 00:00:00	50	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
729	Asija And Associates LLP	AAA LLP	2026-04-16	HO/26-27/KKF/010	Rogi Kalyan Samiti - Dr.S.P.M.Civil Hospital	7150	2026-05-16 00:00:00	5	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
730	Asija And Associates LLP	AAA LLP	2026-04-16	HO/26-27/KKF/011	Rogi Kalyan Samiti - Dr.S.P.M.Civil Hospital	4237	2026-05-16 00:00:00	5	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
731	Asija And Associates LLP	AAA LLP	2026-04-20	HO/26-27/RS/0001	Invest UP	295000	2026-05-20 00:00:00	31	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
732	Asija And Associates LLP	AAA LLP	2026-04-20	HO/26-27/RS/0002	Invest UP	141600	2026-05-20 00:00:00	31	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
733	Asija And Associates LLP	AAA LLP	2026-04-21	HO/26-27/RS/0003	The Pradeshiya Industrial & Investment Coporation of U.P. Ltd.	47200	2026-05-21 00:00:00	0	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
734	Asija And Associates LLP	AAA LLP	2026-04-21	HO/26-27/AK/0004	Uniform Ventures Private Limited	18290	2026-05-21 00:00:00	30	\N	\N	open	0	\N	\N	AshishK	\N	\N	\N
735	Asija And Associates LLP	AAA LLP	2026-04-22	HO/26-27/KKF/015	Northern Coalfields Limited , Dudhichua	181720	2026-05-22 00:00:00	29	\N	\N	full_paid	181720	2026-06-02 10:30:49	\N	KamalF	\N	\N	\N
736	Asija And Associates LLP	AAA LLP	2026-04-23	HO/26-27/SD/0003	GHARDA CHEMICALS LIMITED	10620	2026-05-23 00:00:00	28	\N	\N	open	0	\N	\N	SahilD	\N	\N	\N
737	Asija And Associates LLP	AAA LLP	2026-04-24	HO/26-27/KKF/019	Central Bank of India-Bhopal	180210	2026-05-24 00:00:00	27	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
738	Asija And Associates LLP	AAA LLP	2026-04-24	HO/26-27/KKF/020	Central Bank of India-Bhopal	429152	2026-05-24 00:00:00	27	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
739	Asija And Associates LLP	AAA LLP	2026-04-24	HO/26-27/KKF/018	Punjab & Sind Bank HO	31341	2026-05-24 00:00:00	27	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
741	Asija And Associates LLP	AAA LLP	2026-04-24	HO/26-27/KKF/022	Uttar Pradesh Gramin Bank	7422	2026-05-24 00:00:00	27	\N	\N	full_paid	7422	2026-05-29 18:02:19	\N	\N	\N	\N	\N
742	Asija And Associates LLP	AAA LLP	2026-04-25	HO/26-27/KKF/023	ICICI Bank Limited-Hazratganj Branch	53100	2026-05-25 00:00:00	27	\N	\N	full_paid	53100	2026-05-29 18:02:19	\N	\N	\N	\N	\N
918	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0043	U.P.Sainik Punarvas Nidhi	2784	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	AkashA	2026-06-11 18:29:13	arif.siddiqui@asija.in	Bulk delete from main report
967	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0010	Rajesh Nigam Family Private Trust	18880	2026-07-10 00:00:00	1	20260611184256112699	\N	open	0	\N	\N	RohitS	\N	\N	\N
968	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0033	Republic Motors	2396	2026-07-10 00:00:00	1	20260611184256112699	\N	open	0	\N	\N	SahilD	\N	\N	\N
969	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0024	Sarvagaya Infrapromoters LLP	1806	2026-07-10 00:00:00	1	20260611184256112699	\N	open	0	\N	\N	KamalF	\N	\N	\N
970	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0002	Saurabh Mehrotra	2950	2026-07-10 00:00:00	1	20260611184256112699	\N	open	0	\N	\N	\N	\N	\N	\N
971	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0026	Soham Infrapromoters Private Limited	2430	2026-07-10 00:00:00	1	20260611184256112699	\N	open	0	\N	\N	KamalF	\N	\N	\N
972	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0027	Spacia Ventures LLP	1806	2026-07-10 00:00:00	1	20260611184256112699	\N	open	0	\N	\N	RohitS	\N	\N	\N
973	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0008	Spectrum Venture International Private Limited	27424	2026-07-10 00:00:00	1	20260611184256112699	\N	open	0	\N	\N	SahilD	\N	\N	\N
751	Asija And Associates LLP	AAA LLP	2026-04-30	HO/26-27/KKF/030	Dy. Chief Accounts Officer, Krishna Nagar, MVVNL	47200	2026-05-30 00:00:00	22	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
752	Asija And Associates LLP	AAA LLP	2026-05-01	HO/26-27/KKF/033	GM (Internal Audit), NTPC Ltd.	259600	2026-05-31 00:00:00	20	\N	\N	full_paid	259600	2026-06-02 10:30:49	\N	KamalF	\N	\N	\N
753	Asija And Associates LLP	AAA LLP	2026-05-02	HO/26-27/KKF/034	Agriculture Insurance Company of India Limited	84370	2026-06-01 00:00:00	19	\N	\N	full_paid	84370	2026-06-02 10:30:49	\N	KamalF	\N	\N	\N
754	Asija And Associates LLP	AAA LLP	2026-05-04	HO/26-27/KKF/035	ICICI Bank Limited - Kanpur Branch	56640	2026-06-03 00:00:00	17	\N	\N	full_paid	56640	2026-06-09 10:05:48	\N	KamalF	\N	\N	\N
755	Asija And Associates LLP	AAA LLP	2026-05-04	HO/26-27/KKF/036	ICICI Bank Limited - Kanpur Branch	56640	2026-06-03 00:00:00	17	\N	\N	full_paid	56640	2026-06-09 10:05:48	\N	KamalF	\N	\N	\N
756	Asija And Associates LLP	AAA LLP	2026-05-04	HO/26-27/SD/0007	S R M Motors Private Limited	0	2026-06-03 00:00:00	29	\N	SahilD	open	0	\N		SahilD	2026-06-08 17:09:15	arif.siddiqui@asija.in	bill cancleed in tally
759	Asija And Associates LLP	AAA LLP	2026-05-07	HO/26-27/SD/0009	Pavaki Infrasolutions LLP	10030	2026-06-06 00:00:00	15	\N	\N	open	0	\N	\N	SahilD	\N	\N	\N
760	Asija And Associates LLP	AAA LLP	2026-05-07	HO/26-27/SD/0011	Sharp Technoengineers Private Limited	4130	2026-06-06 00:00:00	15	\N	\N	open	0	\N	\N	SahilD	\N	\N	\N
761	Asija And Associates LLP	AAA LLP	2026-05-08	HO/26-27/CL/0003	Apex Autosales Private Limited	1770	2026-06-07 00:00:00	14	\N	\N	open	0	\N	\N	ManishM	\N	\N	\N
762	Asija And Associates LLP	AAA LLP	2026-05-08	HO/26-27/RS/0007	Gaurav Bhandari	5192	2026-06-07 00:00:00	14	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
763	Asija And Associates LLP	AAA LLP	2026-05-08	HO/26-27/KKF/040	Green Gas Limited	169920	2026-06-07 00:00:00	14	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
764	Asija And Associates LLP	AAA LLP	2026-05-08	HO/26-27/RS/0008	Iqbal Kidwai	10384	2026-06-07 00:00:00	14	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
765	Asija And Associates LLP	AAA LLP	2026-05-08	HO/26-27/RS/0009	Karam Safety Private Limited-ISD	27877	2026-06-07 00:00:00	13	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
766	Asija And Associates LLP	AAA LLP	2026-05-08	HO/26-27/RS/0010	Karam Safety Private Limited-ISD	16331.2	2026-06-07 00:00:00	13	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
767	Asija And Associates LLP	AAA LLP	2026-05-08	HO/26-27/RS/0011	Karam Safety Private Limited - Lucknow	24161	2026-06-07 00:00:00	13	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
768	Asija And Associates LLP	AAA LLP	2026-05-08	HO/26-27/RS/0012	PN Safetech Private Limited-Uttar Pradesh	11152	2026-06-07 00:00:00	14	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
769	Asija And Associates LLP	AAA LLP	2026-05-08	HO/26-27/RS/0014	Saurabh Bhandari	5192	2026-06-07 00:00:00	14	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
770	Asija And Associates LLP	AAA LLP	2026-05-08	HO/26-27/CL/0002	Unix Enterprises Private Limited	4740	2026-06-07 00:00:00	14	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
771	Asija And Associates LLP	AAA LLP	2026-05-09	HO/26-27/RS/0026	Karam Safety Private Limited-ISD	10620	2026-06-08 00:00:00	12	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
772	Asija And Associates LLP	AAA LLP	2026-05-09	HO/26-27/RS/0031	Karam Safety Private Limited-ISD	42126	2026-06-08 00:00:00	12	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
773	Asija And Associates LLP	AAA LLP	2026-05-09	HO/26-27/RS/0027	Karam Safety Private Limited - Lucknow	23010	2026-06-08 00:00:00	12	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
774	Asija And Associates LLP	AAA LLP	2026-05-09	HO/26-27/RS/0028	Karam Safety Private Limited - Lucknow	38410	2026-06-08 00:00:00	12	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
775	Asija And Associates LLP	AAA LLP	2026-05-09	HO/26-27/RS/0029	Karam Safety Private Limited - Lucknow	40356	2026-06-08 00:00:00	12	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
776	Asija And Associates LLP	AAA LLP	2026-05-09	HO/26-27/RS/0030	Karam Safety Private Limited - Lucknow	41300	2026-06-08 00:00:00	12	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
777	Asija And Associates LLP	AAA LLP	2026-05-09	HO/26-27/RS/0021	Karam Safety Private Limited - Lucknow	11800	2026-06-08 00:00:00	12	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
778	Asija And Associates LLP	AAA LLP	2026-05-09	HO/26-27/RS/0032	Karam Safety Private Limited-Uttar Pradesh	23542	2026-06-08 00:00:00	13	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
779	Asija And Associates LLP	AAA LLP	2026-05-09	HO/26-27/AK/0006	Technomed Devices India Private Limited	38500	2026-06-08 00:00:00	12	\N	\N	open	0	\N	\N	AshishK	\N	\N	\N
780	Asija And Associates LLP	AAA LLP	2026-05-09	HO/26-27/RS/0024	UNICEF Maharashtra	41300	2026-06-08 00:00:00	12	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
781	Asija And Associates LLP	AAA LLP	2026-05-09	HO/26-27/RS/0025	UNICEF Office For New Delhi	32450	2026-06-08 00:00:00	13	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
782	Asija And Associates LLP	AAA LLP	2026-05-09	HO/26-27/RS/0020	UNICEF Office For Uttar Pradesh	7080	2026-06-08 00:00:00	13	\N	\N	full_paid	7080	2026-06-02 10:18:34	\N	RohitS	\N	\N	\N
783	Asija And Associates LLP	AAA LLP	2026-05-19	HO/26-27/SD/0012	Karam Safety Private Limited-Uttar Pradesh	8850	2026-06-18 00:00:00	3	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
784	Asija And Associates LLP	AAA LLP	2026-05-19	HO/26-27/AK/0007	Nivah Hospitality LLP	2360	2026-06-18 00:00:00	2	\N	\N	full_paid	2360	2026-06-02 10:30:49	\N	AshishK	\N	\N	\N
785	Asija and Assocaites LLP- Guwahati	AAA-LLP-GW	2024-03-01	GW/23-24/PJ/0016	NORTH EASTERN ELECTRIC POWER CORPORATION LTD-Nagaland	22670	2024-03-31 00:00:00	801	\N	\N	open	0	\N	\N	PJ	\N	\N	\N
786	Asija and Assocaites LLP- Guwahati	AAA-LLP-GW	2024-03-22	GW/23-24/PJ/0019	NORTH EASTERN ELECTRIC POWER CORPORATION LTD-Nagaland	1572	2024-04-21 00:00:00	780	\N	\N	open	0	\N	\N	PJ	\N	\N	\N
788	Asija Financial Services	AFS	2024-12-31	Dec-2024	Centricity Financial Distribution Private Limited	7589.04	2025-01-30 00:00:00	507	\N	AshishK	full_paid	7589.04	2026-06-02 12:39:47	\N	AshishK	\N	\N	\N
789	Asija Financial Services	AFS	2025-03-03	AFS/24-25/AA/0029	Ayisha Shiksha Sansthan	25000	2025-04-02 00:00:00	411	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
790	Asija Financial Services	AFS	2025-03-03	AFS/24-25/AA/0031	Ram Nath Jaiswal- Firm	25000	2025-04-02 00:00:00	411	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
791	Asija Financial Services	AFS	2025-10-10	AFS/25-26/AA/0009	Ayisha Shiksha Sansthan	25000	2025-11-09 00:00:00	190	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
792	Asija Financial Services	AFS	2025-12-31	AFS/25-26/AK (AFS)/027	Centricity Financial Distribution Private Limited	9656.14	2026-01-30 00:00:00	108	\N	\N	full_paid	9656.14	2026-06-02 12:39:47	\N	AshishK	\N	\N	\N
794	Asija Financial Services	AFS	2026-01-10	AFS/25-26/AA/0014	Dinesh Kumar Vishwakarma	7500	2026-02-09 00:00:00	98	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
795	Asija Financial Services	AFS	2026-01-10	AFS/25-26/Corpl/0007	Limen Solutions Private Limited	6600	2026-02-09 00:00:00	98	\N	\N	full_paid	6600	2026-06-13 14:17:08	\N	SahilD	\N	\N	\N
796	Asija Financial Services	AFS	2026-01-10	AFS/25-26/AA/0011	Ram Nath Jaiswal- Firm	26000	2026-02-09 00:00:00	98	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
757	Asija And Associates LLP	AAA LLP	2026-05-04	HO/26-27/SD/0008	S R M Motors Private Limited	236000	2026-06-03 00:00:00	18	\N	\N	full_paid	236000	2026-06-02 10:44:15	\N	SahilD	\N	\N	\N
797	Asija Financial Services	AFS	2026-02-10	AFS/25-26/Corpl/0008	Anant Infrazone Private Limited	7800	2026-03-12 00:00:00	67	\N	\N	open	0	\N	\N	ManishM	\N	\N	\N
798	Asija Financial Services	AFS	2026-02-10	AFS/25-26/AA/0018	Awadh Aero Adventures Association	500	2026-03-12 00:00:00	67	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
799	Asija Financial Services	AFS	2026-02-28	AFS/25-26/AK (AFS)/032	Centricity Financial Distribution Private Limited	4136.09	2026-03-30 00:00:00	49	\N	\N	full_paid	4136.09	2026-06-02 12:39:47	\N	AshishK	\N	\N	\N
800	Asija Tech Consulting LLP	ATC	2026-03-31	ATC/25-26/AK/0014	Prateek Kumar Singh	2000	2026-04-30 00:00:00	21	\N	\N	open	0	\N	\N	AshishK	\N	\N	\N
801	Asija Tech Consulting LLP	ATC	2026-03-31	ATC/25-26/AK/0015	Prateek Kumar Singh	2000	2026-04-30 00:00:00	21	\N	\N	open	0	\N	\N	AshishK	\N	\N	\N
802	Asija Tech Consulting LLP	ATC	2026-03-31	ATC/25-26/AK/0016	Prateek Kumar Singh	7000	2026-04-30 00:00:00	21	\N	\N	open	0	\N	\N	AshishK	\N	\N	\N
804	Asija Tech Consulting LLP	ATC	2026-03-31	ATC/25-26/AK/0017	PS Global Consumer Healthcare Pvt .Ltd	2000	2026-04-30 00:00:00	21	\N	\N	open	0	\N	\N	AshishK	\N	\N	\N
806	Asija Tech Consulting LLP	ATC	2026-03-31	ATC/25-26/AK/0013	Ratnawali Singh	2000	2026-04-30 00:00:00	21	\N	\N	open	0	\N	\N	AshishK	\N	\N	\N
807	Asija Tech Consulting LLP	ATC	2026-05-05	ATC/26-27/AK/0001	BLUE BELL DR RAM TIRTH DUBE MEMORIAL SHIKSHA SANSTHAN	2000	2026-06-04 00:00:00	16	\N	\N	open	0	\N	\N	AshishK	\N	\N	\N
808	Manish Mishra And Assocaites	MMAA	2025-08-10	MMA/25-26/CorpL/0014	Asija Tech Consulting LLP	200	2025-09-09 00:00:00	270	\N	\N	open	0	\N	\N	AshishK	\N	\N	\N
809	Manish Mishra And Assocaites	MMAA	2025-10-10	MMA/25-26/CorpL/0018	ASKHUNGREE ORGANIC SOLUTIONS PRIVATE LIMITED	1500	2025-11-09 00:00:00	209	\N	\N	open	0	\N	\N	ManishM	\N	\N	\N
810	Manish Mishra And Assocaites	MMAA	2025-12-10	MMA/25-26/CorpL/0029	Karam Safety Private Limited-Uttrakhand	30200	2026-01-09 00:00:00	118	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
811	Manish Mishra And Assocaites	MMAA	2026-01-10	MMA/25-26/CorpL/0033	Juno Casting Private Limited	4100	2026-02-09 00:00:00	87	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
812	Manish Mishra And Assocaites	MMAA	2026-02-10	MMA/25-26/CorpL/0035	Karam Safety Private Limited-Uttrakhand	9600	2026-03-12 00:00:00	56	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
813	Manish Mishra And Assocaites	MMAA	2026-03-10	MMA/25-26/CorpL/0038	Reflectosafe India LLP	5500	2026-04-09 00:00:00	58	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
814	Manish Mishra And Assocaites	MMAA	2026-04-01	MMA/26-27/CorpL/0001	Asija & Associates LLP	2970	2026-05-01 00:00:00	6	\N	\N	open	0	\N	\N	AshishK	\N	\N	\N
815	Manish Mishra And Assocaites	MMAA	2026-04-01	MMA/26-27/CorpL/0002	Karam Safety Private Limited-Uttrakhand	2400	2026-05-01 00:00:00	6	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
816	Manish Mishra And Assocaites	MMAA	2026-05-07	MMA/26-27/CorpL/0003	Asija & Associates LLP	2930	2026-06-06 00:00:00	15	\N	\N	open	0	\N	\N	AshishK	\N	\N	\N
817	AAAFC	AAAFC	2026-05-22	AAAFC-26-27-AK-Del-0008	Sundry Departmental Debtor - NADT Ahmadabad	2000	2026-06-21 00:00:00	11	\N	\N	part_paid	2000	\N	\N	AshishK	\N	\N	\N
818	AAAFC	AAAFC	2026-06-01	AAAFC-26-27-AK-Del-0009	Asija Financial Services	22000	2026-07-01 00:00:00	0	\N	\N	open	0	\N	\N	AshishK	\N	\N	\N
819	Asija And Associates LLP	AAA LLP	2026-05-08	HO/26-27/RS/0013	Rogi Kalyan Samiti - Dr.S.P.M.Civil Hospital	2714	2026-06-07 00:00:00	25	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
820	Asija And Associates LLP	AAA LLP	2026-05-08	HO/26-27/RS/0018	Spacia Ventures LLP	4366	2026-06-07 00:00:00	25	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
821	Asija And Associates LLP	AAA LLP	2026-05-08	HO/26-27/RS/0015	Unix Enterprises Private Limited	2596	2026-06-07 00:00:00	25	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
822	Asija And Associates LLP	AAA LLP	2026-05-08	HO/26-27/RS/0017	UP Metro Rail Corporation Ltd.	14160	2026-06-07 00:00:00	24	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
823	Asija And Associates LLP	AAA LLP	2026-05-08	HO/26-27/RS/0016	Vidit Advertising	5192	2026-06-07 00:00:00	25	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
824	Asija And Associates LLP	AAA LLP	2026-05-09	HO/26-27/RS/0022	Airports Authority of India	23600	2026-06-08 00:00:00	23	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
825	Asija And Associates LLP	AAA LLP	2026-05-09	HO/26-27/RS/0023	Invest UP	47200	2026-06-08 00:00:00	23	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
826	Asija And Associates LLP	AAA LLP	2026-05-09	HO/26-27/RS/0019	Spacia Infra and Services	4720	2026-06-08 00:00:00	23	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
827	Asija And Associates LLP	AAA LLP	2026-05-22	HO/26-27/SD/0013	SSBB Infra and Services Private Limited	5900	2026-06-21 00:00:00	11	\N	SahilD	open	0	\N		SahilD	\N	\N	\N
828	Asija And Associates LLP	AAA LLP	2026-05-22	HO/26-27/SD/0014	United Nations Children's Fund-Senegal	0.01	2026-06-21 00:00:00	13	\N	SahilD	full_paid	0.01	2026-06-04 15:13:26		SahilD	\N	\N	\N
829	Asija And Associates LLP	AAA LLP	2026-05-23	HO/26-27/SD/0015	Puneet Auto Sales  Private Limited	885000	2026-06-22 00:00:00	10	\N	SahilD	open	0	\N		SahilD	\N	\N	\N
830	Asija And Associates LLP	AAA LLP	2026-05-23	HO/26-27/SD/0018	Seven Autocorp Private Limited	177000	2026-06-22 00:00:00	10	\N	SahilD	open	0	\N		SahilD	\N	\N	\N
831	Asija And Associates LLP	AAA LLP	2026-05-29	HO/26-27/KKF/044	Bank of India- Terhi Pulia	42480	2026-06-28 00:00:00	3	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
832	Asija And Associates LLP	AAA LLP	2026-05-29	HO/26-27/AK/0008	Uniform Ventures Private Limited	18290	2026-06-28 00:00:00	3	\N	\N	open	0	\N	\N	AshishK	\N	\N	\N
833	Asija And Associates LLP	AAA LLP	2026-06-01	HO/26-27/SD/0022	BR Autoventures Private Limited	88500	2026-07-01 00:00:00	0	\N	\N	open	0	\N	\N	SahilD	\N	\N	\N
834	Asija And Associates LLP	AAA LLP	2026-06-01	HO/26-27/SD/0021	Puneet Auto Sales  Private Limited	442500	2026-07-01 00:00:00	1	\N	\N	open	0	\N	\N	SahilD	\N	\N	\N
835	Asija And Associates LLP	AAA LLP	2026-06-01	HO/26-27/SD/0023	Seven Autocorp Private Limited	88500	2026-07-01 00:00:00	1	\N	\N	open	0	\N	\N	SahilD	\N	\N	\N
836	Asija And Associates LLP	AAA LLP	2026-06-01	HO/26-27/SD/0024	S R M Motors Private Limited	354000	2026-07-01 00:00:00	1	\N	\N	open	0	\N	\N	SahilD	\N	\N	\N
837	Asija And Associates LLP	AAA LLP	2026-06-23	HO/26-27/SD/0020	S R M Motors Private Limited	708000	2026-07-23 00:00:00	-21	\N	SahilD	full_paid	708000	2026-06-02 10:44:15		\N	\N	\N	\N
838	Asija And Associates LLP	AAA LLP	2026-05-23	HO/26-27/SD/0020	S R M Motors Private Limited	0.01	2026-06-22 00:00:00	10	\N	SahilD	full_paid	0.01	2026-06-02 14:49:13		\N	\N	\N	\N
839	Asija And Associates LLP	AAA LLP	2026-06-03	HO/26-27/AK/0009	Nivah Hospitality LLP	23600	2026-07-03 00:00:00	0	\N	\N	full_paid	23600	2026-06-10 13:36:26	\N	AshishK	\N	\N	\N
840	Asija And Associates LLP	AAA LLP	2026-06-03	HO/26-27/SD/0025	United Nations Children's Fund-Senegal	95954.25	2026-07-03 00:00:00	1	\N	\N	open	0	\N	\N	SahilD	\N	\N	\N
841	Asija And Associates LLP	AAA LLP	2026-06-05	HO/26-27/CL/0007	Apex Autosales Private Limited	6900	2026-07-05 00:00:00	4	\N	\N	open	0	\N	\N	ManishM	\N	\N	\N
843	Asija And Associates LLP	AAA LLP	2026-06-05	HO/26-27/CL/0011	Brij Bhushan Ventures LLP	5360	2026-07-05 00:00:00	4	\N	\N	open	0	\N	\N	ManishM	\N	\N	\N
844	Asija And Associates LLP	AAA LLP	2026-06-05	HO/26-27/CL/0009	Chillies N Lemon Infra & Hospitality LLP	4180	2026-07-05 00:00:00	4	\N	\N	open	0	\N	\N	SahilD	\N	\N	\N
845	Asija And Associates LLP	AAA LLP	2026-06-05	HO/26-27/CL/0004	Pavaki Infrasolutions LLP	5710	2026-07-05 00:00:00	4	\N	\N	open	0	\N	\N	SahilD	\N	\N	\N
846	Asija And Associates LLP	AAA LLP	2026-06-05	HO/26-27/CL/0005	Sarvagaya Infrapromoters LLP	4180	2026-07-05 00:00:00	4	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
847	Asija And Associates LLP	AAA LLP	2026-06-05	HO/26-27/CL/0006	Shaivya Minerals And Stones Llp	3840	2026-07-05 00:00:00	4	\N	\N	open	0	\N	\N	ManishM	\N	\N	\N
848	Asija And Associates LLP	AAA LLP	2026-06-05	HO/26-27/CL/0012	Spacia Ventures LLP	5360	2026-07-05 00:00:00	4	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
927	AAAFC	AAAFC	2026-06-05	AAAFC/26-27/Corpl/0004	Wynsum Food Box LLP	3550	2026-07-05 00:00:00	4	\N	\N	open	0	\N	\N	ManishM	\N	\N	\N
849	Asija And Associates LLP	AAA LLP	2026-06-05	HO/26-27/CL/0008	SSBB Infra and Services Private Limited	7680	2026-07-05 00:00:00	4	\N	\N	open	0	\N	\N	SahilD	\N	\N	\N
850	Asija And Associates LLP	AAA LLP	2026-06-05	HO/26-27/CL/0013	Stellar Cables & Infrastructure Private Limited	3550	2026-07-05 00:00:00	4	\N	\N	open	0	\N	\N	ManishM	\N	\N	\N
851	Asija And Associates LLP	AAA LLP	2026-06-05	HO/26-27/CL/0014	Winstrux Global LLP	4530	2026-07-05 00:00:00	4	\N	\N	open	0	\N	\N	ManishM	\N	\N	\N
852	Asija And Associates LLP	AAA LLP	2026-06-06	HO/26-27/AK/0010	Sanjivan Healthcare Enterprise Private Limited	3540	2026-07-06 00:00:00	3	\N	\N	open	0	\N	\N	AshishK	\N	\N	\N
853	Asija And Associates LLP	AAA LLP	2026-06-06	HO/26-27/CL/0015	Sprinters Capital LLP	4230	2026-07-06 00:00:00	3	\N	\N	open	0	\N	\N	SahilD	\N	\N	\N
854	Asija And Associates LLP	AAA LLP	2026-06-06	HO/26-27/AK/0012	The Nirman Tirth South Point School And Vidyashram	23600	2026-07-06 00:00:00	3	\N	\N	open	0	\N	\N	AshishK	\N	\N	\N
855	Asija And Associates LLP	AAA LLP	2026-06-06	HO/26-27/AK/0011	Yogendra Samir Yadav	5900	2026-07-06 00:00:00	3	\N	\N	open	0	\N	\N	AshishK	\N	\N	\N
856	Asija And Associates LLP	AAA LLP	2026-06-08	HO/26-27/RS/0050	Airports Authority of India	23600	2026-07-08 00:00:00	1	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
857	Asija And Associates LLP	AAA LLP	2026-06-08	HO/26-27/RS/0053	Divya Khare	7080	2026-07-08 00:00:00	1	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
858	Asija And Associates LLP	AAA LLP	2026-06-08	HO/26-27/RS/0033	Gaurav Bhandari	5192	2026-07-08 00:00:00	1	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
859	Asija And Associates LLP	AAA LLP	2026-06-08	HO/26-27/KKF/046	ICICI Bank Limited - Kanpur Branch	50740	2026-07-08 00:00:00	1	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
860	Asija And Associates LLP	AAA LLP	2026-06-08	HO/26-27/RS/0034	Iqbal Kidwai	10384	2026-07-08 00:00:00	1	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
861	Asija And Associates LLP	AAA LLP	2026-06-08	HO/26-27/RS/0035	Karam Safety Private Limited-ISD	27878	2026-07-08 00:00:00	1	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
862	Asija And Associates LLP	AAA LLP	2026-06-08	HO/26-27/RS/0036	Karam Safety Private Limited-ISD	16331	2026-07-08 00:00:00	1	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
863	Asija And Associates LLP	AAA LLP	2026-06-08	HO/26-27/RS/0037	Karam Safety Private Limited-ISD	10620	2026-07-08 00:00:00	1	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
864	Asija And Associates LLP	AAA LLP	2026-06-08	HO/26-27/RS/0038	Karam Safety Private Limited - Lucknow	24161	2026-07-08 00:00:00	1	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
865	Asija And Associates LLP	AAA LLP	2026-06-08	HO/26-27/RS/0046	Karam Safety Private Limited - Lucknow	24722	2026-07-08 00:00:00	1	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
866	Asija And Associates LLP	AAA LLP	2026-06-08	HO/26-27/RS/0039	PN Safetech Private Limited-Uttar Pradesh	11152	2026-07-08 00:00:00	1	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
867	Asija And Associates LLP	AAA LLP	2026-06-08	HO/26-27/AK/0014	P.S.Enterprises	44782	2026-07-08 00:00:00	1	\N	\N	open	0	\N	\N	AshishK	\N	\N	\N
868	Asija And Associates LLP	AAA LLP	2026-06-08	HO/26-27/KKF/047	PUNJAB AND SIND BANK	23600	2026-07-08 00:00:00	1	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
869	Asija And Associates LLP	AAA LLP	2026-06-08	HO/26-27/RS/0040	Rogi Kalyan Samiti - Dr.S.P.M.Civil Hospital	3540	2026-07-08 00:00:00	1	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
870	Asija And Associates LLP	AAA LLP	2026-06-08	HO/26-27/AK/0013	Sanjivan Healthcare Enterprise Private Limited	89562	2026-07-08 00:00:00	1	\N	\N	open	0	\N	\N	AshishK	\N	\N	\N
871	Asija And Associates LLP	AAA LLP	2026-06-08	HO/26-27/RS/0041	Saurabh Bhandari	5192	2026-07-08 00:00:00	1	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
872	Asija And Associates LLP	AAA LLP	2026-06-08	HO/26-27/RS/0045	Spacia Infra and Services	4720	2026-07-08 00:00:00	1	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
873	Asija And Associates LLP	AAA LLP	2026-06-08	HO/26-27/RS/0044	Spacia Ventures LLP	4366	2026-07-08 00:00:00	1	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
874	Asija And Associates LLP	AAA LLP	2026-06-08	HO/26-27/RS/0052	Spectrum Venture International Private Limited	23600	2026-07-08 00:00:00	1	\N	\N	open	0	\N	\N	SahilD	\N	\N	\N
875	Asija And Associates LLP	AAA LLP	2026-06-08	HO/26-27/RS/0048	UNICEF Maharashtra	21830	2026-07-08 00:00:00	1	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
876	Asija And Associates LLP	AAA LLP	2026-06-08	HO/26-27/RS/0049	UNICEF Office For New Delhi	32450	2026-07-08 00:00:00	1	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
877	Asija And Associates LLP	AAA LLP	2026-06-08	HO/26-27/RS/0047	UNICEF State Office for Bihar	24190	2026-07-08 00:00:00	1	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
878	Asija And Associates LLP	AAA LLP	2026-06-08	HO/26-27/AK/0015	Unifarma Diagnostics and Research Center	60358	2026-07-08 00:00:00	1	\N	\N	open	0	\N	\N	AshishK	\N	\N	\N
879	Asija And Associates LLP	AAA LLP	2026-06-08	HO/26-27/RS/0043	UP Metro Rail Corporation Ltd.	14160	2026-07-08 00:00:00	1	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
880	Asija And Associates LLP	AAA LLP	2026-06-08	HO/26-27/RS/0051	UP Metro Rail Corporation Ltd.	29500	2026-07-08 00:00:00	1	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
881	Asija And Associates LLP	AAA LLP	2026-06-08	HO/26-27/RS/0042	Vidit Advertising	5192	2026-07-08 00:00:00	1	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
882	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/SD/0029	A B Trading	5900	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	SahilD	\N	\N	\N
883	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/SD/0026	Avadhraj Energy Private Limited	25370	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	SahilD	\N	\N	\N
884	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0013	B.K. Girijadevi Investment Private Limited	2396	2026-07-10 00:00:00	1	\N	AkashA	open	0	\N		SahilD	2026-06-11 18:29:13	arif.siddiqui@asija.in	Bulk delete from main report
885	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0012	B K Saraf Private Limited	10608	2026-07-10 00:00:00	1	\N	AkashA	open	0	\N		SahilD	2026-06-11 18:29:13	arif.siddiqui@asija.in	Bulk delete from main report
886	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0014	BKS MyGold Private Limited	5050	2026-07-10 00:00:00	1	\N	AkashA	open	0	\N		SahilD	2026-06-11 18:29:13	arif.siddiqui@asija.in	Bulk delete from main report
888	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0015	Bks Myvault Private Limited	2538	2026-07-10 00:00:00	1	\N	AkashA	open	0	\N		SahilD	2026-06-11 18:29:13	arif.siddiqui@asija.in	Bulk delete from main report
889	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0016	Chillies N Lemon Infra & Hospitality LLP	2124	2026-07-10 00:00:00	1	\N	AkashA	open	0	\N		SahilD	2026-06-11 18:29:13	arif.siddiqui@asija.in	Bulk delete from main report
890	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0025	Ensky Ventures Private Limited	7292	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	SahilD	2026-06-11 18:29:13	arif.siddiqui@asija.in	Bulk delete from main report
891	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0036	Faizane Madina Agra Society	17700	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	AkashA	2026-06-11 18:29:13	arif.siddiqui@asija.in	Bulk delete from main report
892	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0018	Girdhargopal Agencies Private Limited	1806	2026-07-10 00:00:00	1	\N	AkashA	open	0	\N		KamalF	2026-06-11 18:29:13	arif.siddiqui@asija.in	Bulk delete from main report
893	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0027	Jalsa Resorts (India) Private Limited	1948	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	AkashA	2026-06-11 18:29:13	arif.siddiqui@asija.in	Bulk delete from main report
894	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0004	Jesus & Mary Play School Balarampur	21664	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	AkashA	2026-06-11 18:29:13	arif.siddiqui@asija.in	Bulk delete from main report
895	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0020	Jyoti Exports Limited	4732	2026-07-10 00:00:00	1	\N	AkashA	open	0	\N		SahilD	2026-06-11 18:29:13	arif.siddiqui@asija.in	Bulk delete from main report
896	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0034	Karam Safety Private Limited-ISD	82600	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	RohitS	2026-06-11 18:29:13	arif.siddiqui@asija.in	Bulk delete from main report
897	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0001	Karam Safety Private Limited-Uttrakhand	47200	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	RohitS	2026-06-11 18:29:13	arif.siddiqui@asija.in	Bulk delete from main report
898	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0030	K.N. Associates	2088	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	AkashA	2026-06-11 18:29:13	arif.siddiqui@asija.in	Bulk delete from main report
899	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0005	La Martiniere College, Lucknow	21830	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	RohitS	2026-06-11 18:29:13	arif.siddiqui@asija.in	Bulk delete from main report
900	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0031	Murad Ventures Private Limited	1806	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	SahilD	2026-06-11 18:29:13	arif.siddiqui@asija.in	Bulk delete from main report
901	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0032	Pavaki Infrasolutions LLP	6302	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	SahilD	2026-06-11 18:29:13	arif.siddiqui@asija.in	Bulk delete from main report
902	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0010	Rajesh Nigam Family Private Trust	18880	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	RohitS	2026-06-11 18:29:13	arif.siddiqui@asija.in	Bulk delete from main report
903	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0046	Republic Motors	2396	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	SahilD	2026-06-11 18:29:13	arif.siddiqui@asija.in	Bulk delete from main report
904	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0035	Sarvagaya Infrapromoters LLP	1806	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	KamalF	2026-06-11 18:29:13	arif.siddiqui@asija.in	Bulk delete from main report
905	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0002	Saurabh Mehrotra	2950	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	AkashA	2026-06-11 18:29:13	arif.siddiqui@asija.in	Bulk delete from main report
906	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/SD/0028	SBSB Infratech Private Limited	5900	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	SahilD	\N	\N	\N
907	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0037	Soham Infrapromoters Private Limited	2430	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	KamalF	2026-06-11 18:29:13	arif.siddiqui@asija.in	Bulk delete from main report
908	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0038	Spacia Ventures LLP	1806	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	RohitS	2026-06-11 18:29:13	arif.siddiqui@asija.in	Bulk delete from main report
909	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0008	Spectrum Venture International Private Limited	27424	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	SahilD	2026-06-11 18:29:13	arif.siddiqui@asija.in	Bulk delete from main report
805	Asija Tech Consulting LLP	ATC	2026-03-31	ATC/25-26/AK/0012	Ratnawali Singh	7000	2026-04-30 00:00:00	21	\N	\N	open	0	\N	\N	AshishK	\N	\N	\N
910	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0040	SSCC Constructions Private Limited - UP	2644	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	SahilD	2026-06-11 18:29:13	arif.siddiqui@asija.in	Bulk delete from main report
911	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0012	State Health Society of Uttar Pradesh	55224	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	PrademnP-X	2026-06-11 18:29:13	arif.siddiqui@asija.in	Bulk delete from main report
912	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0035	State Health Society of Uttar Pradesh	92040	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	PrademnP-X	2026-06-11 18:29:13	arif.siddiqui@asija.in	Bulk delete from main report
913	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/SD/0030	Structural Insulation and Glazing Company Private Limited	221250	2026-07-10 00:00:00	-1	\N	\N	full_paid	221250	2026-06-11 16:49:41	\N	SahilD	\N	\N	\N
914	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0009	St. Teresa's Day School	5900	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	SahilD	2026-06-11 18:29:13	arif.siddiqui@asija.in	Bulk delete from main report
915	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0041	Surcoat Paints Private Limited	3268	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	KamalF	2026-06-11 18:29:13	arif.siddiqui@asija.in	Bulk delete from main report
962	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0001	Karam Safety Private Limited-Uttrakhand	47200	2026-07-10 00:00:00	1	20260611184256112699	\N	open	0	\N	\N	RohitS	\N	\N	\N
919	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0044	Vidit Advertising	2430	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	RohitS	2026-06-11 18:29:13	arif.siddiqui@asija.in	Bulk delete from main report
921	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0007	Vishesh Traders	17700	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	SahilD	2026-06-11 18:29:13	arif.siddiqui@asija.in	Bulk delete from main report
922	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0006	VS Trading Co	17700	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	SahilD	2026-06-11 18:29:13	arif.siddiqui@asija.in	Bulk delete from main report
924	AAAFC	AAAFC	2026-06-05	AAAFC/26-27/Corpl/0006	Lobo Tailors LLP	3550	2026-07-05 00:00:00	4	\N	\N	open	0	\N	\N	ManishM	\N	\N	\N
925	AAAFC	AAAFC	2026-06-05	AAAFC/26-27/Corpl/0007	SRM Agri India LLP	3550	2026-07-05 00:00:00	4	\N	\N	open	0	\N	\N	SahilD	\N	\N	\N
926	AAAFC	AAAFC	2026-06-05	AAAFC/26-27/Corpl/0005	Tirwa Farms LLP	3550	2026-07-05 00:00:00	4	\N	\N	open	0	\N	\N	ManishM	\N	\N	\N
928	AAAFC	AAAFC	2026-06-06	AAAFC-26-27-AK-Del-0010	Sundry Departmental Debtor	10000	2026-07-06 00:00:00	3	\N	\N	open	0	\N	\N	AshishK	\N	\N	\N
929	AAAFC	AAAFC	2026-06-10	AAAFC/26-27/AA/0016	Abhijeet Foundation	3500	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
930	AAAFC	AAAFC	2026-06-10	AAAFC/26-27/AA/0011	Arya Vardhan Foundation	4560	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
931	AAAFC	AAAFC	2026-06-10	AAAFC/26-27/AA/0012	Awadh Aero Adventures Association	500	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
933	AAAFC	AAAFC	2026-06-10	AAAFC/26-27/AA/0013	Rajeshwari Welfare Foundation	780	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
935	AAAFC	AAAFC	2026-06-10	AAAFC/26-27/AA/0015	Shiv Lok Dham Trust	3500	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
936	AAAFC	AAAFC	2026-06-10	AAAFC/26-27/AA/0019	Shravendra Ji	1000	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
937	AAAFC	AAAFC	2026-06-10	AAAFC/26-27/AA/0014	Subhash Bhandari Memorial Foundation	4000	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
939	AAAFC	AAAFC	2026-06-10	AAAFC/26-27/AA/0017	Vinod Sukhwani	25000	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
940	Manish Mishra And Assocaites	MMAA	2026-06-10	MMA/26-27/CL/004	Asija & Associates LLP	50	2026-07-10 00:00:00	-1	20260609185046177457	\N	open	0	\N	\N	AshishK	\N	\N	\N
941	Manish Mishra And Assocaites	MMAA	2026-06-10	MMA/26-27/CL/003	Asija & Associates LLP	2930	2026-07-10 00:00:00	-1	20260609185046177457	\N	open	0	\N	\N	AshishK	\N	\N	\N
942	Manish Mishra And Assocaites	MMAA	2026-06-10	MMA/26-27/CL/005	Asija Tech Consulting LLP	50	2026-07-10 00:00:00	-1	20260609185046177457	\N	open	0	\N	\N	AshishK	\N	\N	\N
943	Manish Mishra And Assocaites	MMAA	2026-06-10	MMA/26-27/CL/001	Karam Safety Private Limited-Uttrakhand	34102	2026-07-10 00:00:00	-1	20260609185046177457	\N	open	0	\N	\N	RohitS	\N	\N	\N
944	Manish Mishra And Assocaites	MMAA	2026-06-10	MMA/26-27/CL/002	Karam Safety Private Limited-Uttrakhand	2832	2026-07-10 00:00:00	-1	20260609185046177457	\N	open	0	\N	\N	RohitS	\N	\N	\N
945	Manish Mishra And Assocaites	MMAA	2026-06-10	MMA/26-27/CL/006	Pathjyoti Edumarg LLP	3590	2026-07-10 00:00:00	-1	20260609185046177457	\N	open	0	\N	\N	AkashA	\N	\N	\N
946	Manish Mishra And Assocaites	MMAA	2026-06-10	MMA/26-27/CL/007	Reflectosafe India LLP	7562	2026-07-10 00:00:00	-1	20260609185046177457	\N	open	0	\N	\N	RohitS	\N	\N	\N
947	Manish Mishra And Assocaites	MMAA	2026-06-10	MMA/26-27/CL/008	SN Trustees LLP	4180	2026-07-10 00:00:00	-1	20260609185046177457	\N	open	0	\N	\N	RohitS	\N	\N	\N
948	Asija And Associates LLP	AAA LLP	2026-02-10	HO/25-26/CL/0117	Unisel Infraservices and Trade Pvt Ltd	13570	2026-03-12 00:00:00	70	cheque_bounce_20260610141210	ManishM	open	0	\N	Praveen Kumar Singh	AshishK	\N	\N	\N
949	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/RS/0054	UNICEF Office For Uttar Pradesh	10620	2026-07-10 00:00:00	0		RohitS	open	0	\N		RohitS	\N	\N	\N
950	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0013	B.K. Girijadevi Investment Private Limited	2396	2026-07-10 00:00:00	1	20260611184256112699	\N	open	0	\N	\N	SahilD	\N	\N	\N
976	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0035	State Health Society of Uttar Pradesh	92040	2026-07-10 00:00:00	1	20260611184256112699	\N	open	0	\N	\N	PrademnP-X	\N	\N	\N
977	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0009	St. Teresa's Day School	5900	2026-07-10 00:00:00	1	20260611184256112699	\N	open	0	\N	\N	SahilD	\N	\N	\N
978	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0029	Surcoat Paints Private Limited	3268	2026-07-10 00:00:00	1	20260611184256112699	\N	open	0	\N	\N	KamalF	\N	\N	\N
917	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0042	Unix Enterprises Private Limited	2247	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	KamalF	2026-06-11 18:29:13	arif.siddiqui@asija.in	Bulk delete from main report
982	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0032	Vidit Advertising	2430	2026-07-10 00:00:00	1	20260611184256112699	\N	open	0	\N	\N	RohitS	\N	\N	\N
578	AAAFC	AAAFC	2026-03-10	AAAFC/25-26/AA/0144	Indian Blind And Para Judo Association	25000	2026-04-09 00:00:00	42	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
579	AAAFC	AAAFC	2026-03-10	AAAFC/25-26/AA/0138	Maa Pitambra Educational and Charitable Trust	15000	2026-04-09 00:00:00	42	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
581	AAAFC	AAAFC	2026-03-10	AAAFC/25-26/AA/0146	Ram Nath Jaiswal- Firm	15000	2026-04-09 00:00:00	42	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
582	AAAFC	AAAFC	2026-03-10	AAAFC/25-26/Corpl/0046	S and V Infrazone Private Limited	7000	2026-04-09 00:00:00	42	\N	\N	open	0	\N	\N	ManishM	\N	\N	\N
583	AAAFC	AAAFC	2026-03-10	AAAFC/25-26/AA/0139	Shri Shyam Sundar Memorial Charitable Trust	10000	2026-04-09 00:00:00	72	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
584	AAAFC	AAAFC	2026-03-10	AAAFC/25-26/SD/0010	Sri Durga Bansal Fertilizer Limited	5000	2026-04-09 00:00:00	42	\N	\N	open	0	\N	\N	SahilD	\N	\N	\N
585	AAAFC	AAAFC	2026-03-10	AAAFC/25-26/AA/0145	Vartika Raina	10000	2026-04-09 00:00:00	42	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
787	Asija Financial Services	AFS	2024-12-10	AFS/24-25/AA/0006	Ranjana Prakash	2500	2025-01-09 00:00:00	494	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
588	AAAFC	AAAFC	2026-04-01	AAAFC/26-27/AA/0006	Al Madina Trust	12500	2026-05-01 00:00:00	20	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
537	AAAFC	AAAFC	2024-10-01	AAAFC/24-25/Corpl/0048	Karam Infracon LLP	500	2024-10-31 00:00:00	567	\N	\N	full_paid	500	2026-06-09 10:00:41	\N	KamalF	\N	\N	\N
538	AAAFC	AAAFC	2024-10-01	AAAFC/24-25/Corpl/0055	Saurabh Chaudhary	2500	2024-10-31 00:00:00	597	\N	\N	open	0	\N	\N	ManishM	\N	\N	\N
539	AAAFC	AAAFC	2024-10-16	HO - Accounting - 20-21 - BOCW	Sundry Departmental Debtor	13230	2024-11-15 00:00:00	583	\N	AshishK	open	0	\N	UPBOCW	KamalF	\N	\N	\N
540	AAAFC	AAAFC	2025-03-31	AAAFC-24-25-AK-Del-0019	Asija Financial Services	218836	2025-04-30 00:00:00	416	\N	\N	open	0	\N	\N	AshishK	\N	\N	\N
541	AAAFC	AAAFC	2025-05-01	AAAFC/25-26/AA/0025	Al Madina Trust	12500	2025-05-31 00:00:00	355	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
542	AAAFC	AAAFC	2025-05-01	AAAFC/25-26/AA/0022	Arshadi Foundation	6250	2025-05-31 00:00:00	385	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
543	AAAFC	AAAFC	2025-05-01	AAAFC/25-26/AA/0029	Ramesh Traders	20000	2025-05-31 00:00:00	355	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
544	AAAFC	AAAFC	2025-05-01	AAAFC/25-26/AA/0021	Ujjwal Kapoor & Associates	7500	2025-05-31 00:00:00	355	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
545	AAAFC	AAAFC	2025-06-10	AAAFC/25-26/Corpl/0013	BBV Properties Llp	3550	2025-07-10 00:00:00	315	\N	\N	open	0	\N	\N	ManishM	\N	\N	\N
546	AAAFC	AAAFC	2025-06-10	AAAFC/25-26/Corpl/0014	DGTLJ Consultancy LLP	3050	2025-07-10 00:00:00	315	\N	\N	full_paid	3050	2026-06-09 10:31:48	\N	ManishM	\N	\N	\N
547	AAAFC	AAAFC	2025-08-10	AAAFC/25-26/Corpl/0024	Karam Infracon LLP	8950	2025-09-09 00:00:00	254	\N	\N	full_paid	8950	2026-06-09 10:00:41	\N	KamalF	\N	\N	\N
589	AAAFC	AAAFC	2026-04-01	AAAFC-26-27-AK-Del-0005	Asija Financial Services	21000	2026-05-01 00:00:00	50	\N	\N	open	0	\N	\N	AshishK	\N	\N	\N
590	AAAFC	AAAFC	2026-04-01	AAAFC/26-27/AA/0007	Jadaun Educational Trust	10000	2026-05-01 00:00:00	20	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
591	AAAFC	AAAFC	2026-04-01	AAAFC/26-27/AA/0003	Ramesh Traders	20000	2026-05-01 00:00:00	20	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
600	AAAFC	AAAFC	2026-05-07	AAAFC/26-27/Corpl/0002	Takshvi Infraprojects Private Limited	20153	2026-06-06 00:00:00	14	\N	\N	open	0	\N	\N	ManishM	\N	\N	\N
592	AAAFC	AAAFC	2026-04-01	AAAFC/26-27/AA/0005	Ramesh Traders	20000	2026-05-01 00:00:00	20	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
593	AAAFC	AAAFC	2026-04-01	AAAFC/26-27/AA/0004	Ramesh Traders	20000	2026-05-01 00:00:00	20	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
594	AAAFC	AAAFC	2026-04-01	AAAFC/26-27/AA/0010	Shamsher Bahadur Singh Memorial Trust	21000	2026-05-01 00:00:00	20	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
595	AAAFC	AAAFC	2026-04-01	AAAFC/26-27/AA/0001	Visdem Partners	32250	2026-05-01 00:00:00	20	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
596	AAAFC	AAAFC	2026-04-10	AAAFC-26-27-AK-Del-0004	Sundry Departmental Debtor	25000	2026-05-10 00:00:00	42	\N		open	0	\N	UPBOCW	KamalF	\N	\N	\N
597	AAAFC	AAAFC	2026-05-01	AAAFC-26-27-AK-Del-0006	Asija Financial Services	22000	2026-05-31 00:00:00	20	\N	\N	open	0	\N	\N	AshishK	\N	\N	\N
598	AAAFC	AAAFC	2026-05-07	AAAFC/26-27/Corpl/0001	SHREE CONSTRUCTIONS AND LEISURE PRIVATE LIMITED	3000	2026-06-06 00:00:00	14	\N	\N	open	0	\N	\N	ManishM	\N	\N	\N
604	Asija And Associates LLP	AAA LLP	2024-03-15	HO/23-24/PP/0112	DISTRICT HEALTH SOCIETY DISTRICT, BAGHPAT	29859	2024-04-14 00:00:00	797	\N	\N	open	0	\N	\N	PrademnP-X	\N	\N	\N
605	Asija And Associates LLP	AAA LLP	2024-03-15	HO/23-24/PP/0109	DISTRICT HEALTH SOCIETY DISTRICT, HAPUR	24620	2024-04-14 00:00:00	767	\N	\N	open	0	\N	\N	PrademnP-X	\N	\N	\N
606	Asija And Associates LLP	AAA LLP	2024-03-15	HO/23-24/PP/0110	DISTRICT HEALTH SOCIETY GAUTAM BUDDHA NAGAR	34060	2024-04-14 00:00:00	797	\N	\N	open	0	\N	\N	PrademnP-X	\N	\N	\N
607	Asija And Associates LLP	AAA LLP	2024-03-15	HO/23-24/PP/0114	District Health Society, Ghaziabad	39960	2024-04-14 00:00:00	767	\N	\N	open	0	\N	\N	PrademnP-X	\N	\N	\N
608	Asija And Associates LLP	AAA LLP	2024-03-15	HO/23-24/PP/0111	District Health Society- Meerut	62099	2024-04-14 00:00:00	767	\N	\N	open	0	\N	\N	PrademnP-X	\N	\N	\N
609	Asija And Associates LLP	AAA LLP	2024-04-02	HO/22-23/KKF/042_(24-25)	EXECUTIVE ENGINEER WORLD BANK DIVISION NO-1 PWD LUCKNOW	107734	2024-05-02 00:00:00	749	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
610	Asija And Associates LLP	AAA LLP	2024-04-02	HO/22-23/KKF/051_(24-25)	EXECUTIVE ENGINEER WORLD BANK DIVISION NO-1 PWD LUCKNOW	107734	2024-05-02 00:00:00	749	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
611	Asija And Associates LLP	AAA LLP	2024-04-02	HO/23-24/KKF/001_(24-25)	EXECUTIVE ENGINEER WORLD BANK DIVISION NO-1 PWD LUCKNOW	107734	2024-05-02 00:00:00	749	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
612	Asija And Associates LLP	AAA LLP	2024-04-02	HO/23-24/KKF/003_(24-25)	EXECUTIVE ENGINEER WORLD BANK DIVISION NO-1 PWD LUCKNOW	107734	2024-05-02 00:00:00	749	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
613	Asija And Associates LLP	AAA LLP	2024-04-02	HO/23-24/KKF/018_(24-25)	EXECUTIVE ENGINEER WORLD BANK DIVISION NO-1 PWD LUCKNOW	107734	2024-05-02 00:00:00	749	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
614	Asija And Associates LLP	AAA LLP	2024-04-02	HO/23-24/KKF/022_(24-25)	EXECUTIVE ENGINEER WORLD BANK DIVISION NO-1 PWD LUCKNOW	107734	2024-05-02 00:00:00	749	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
615	Asija And Associates LLP	AAA LLP	2024-04-02	HO/23-24/KKF/023_(24-25)	EXECUTIVE ENGINEER WORLD BANK DIVISION NO-1 PWD LUCKNOW	9440	2024-05-02 00:00:00	749	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
616	Asija And Associates LLP	AAA LLP	2024-04-02	HO/23-24/KKF/024_(24-25)	EXECUTIVE ENGINEER WORLD BANK DIVISION NO-1 PWD LUCKNOW	62555	2024-05-02 00:00:00	749	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
617	Asija And Associates LLP	AAA LLP	2024-05-01	HO/24-25/PP/0015	UNDP	43789	2024-05-31 00:00:00	720	\N	\N	full_paid	43789	2026-05-29 14:01:59	\N	\N	\N	\N	\N
599	AAAFC	AAAFC	2026-05-07	AAAFC/26-27/SD/0001	SSCC Constructions Private Limited - UP	15000	2026-06-06 00:00:00	15	\N	\N	open	0	\N	\N	SahilD	\N	\N	\N
601	Asija And Associates LLP	AAA LLP	2023-06-01	HO/23-24/AA/0024	The Lucknow Martin Trust	15930	2023-07-01 00:00:00	1055	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
602	Asija And Associates LLP	AAA LLP	2023-07-01	HO/23-24/PP/0028	Deputy CAO Zonal Account Office PVVNL-Gorakhpur	154319	2023-07-31 00:00:00	1025	\N	\N	open	0	\N	\N	PrademnP-X	\N	\N	\N
603	Asija And Associates LLP	AAA LLP	2024-03-15	HO/23-24/PP/0113	District Health Society, Bulandshaher	50160	2024-04-14 00:00:00	767	\N	\N	open	0	\N	\N	PrademnP-X	\N	\N	\N
619	Asija And Associates LLP	AAA LLP	2024-08-01	HO/24-25/RS/0082	The Pradeshiya Industrial & Investment Coporation of U.P. Ltd.	59000	2024-08-31 00:00:00	628	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
620	Asija And Associates LLP	AAA LLP	2024-12-10	HO/24-25/KKF/043	KANAKSH INFRA LLP	6490	2025-01-09 00:00:00	497	\N	\N	full_paid	6490	2026-06-09 10:05:48	\N	KamalF	\N	\N	\N
621	Asija And Associates LLP	AAA LLP	2025-01-25	AFS/24-25/Corpl/0007	Soham Infrapromoters Private Limited	400	2025-02-24 00:00:00	451	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
622	Asija And Associates LLP	AAA LLP	2025-03-25	ATC Bill Payment to MMA	Asija Tech Consulting LLP	11908	2025-04-24 00:00:00	423	\N	ManishM	full_paid	11908	2026-06-02 10:48:26	\N	AkashA	\N	\N	\N
623	Asija And Associates LLP	AAA LLP	2025-04-01	HO/25-26/RS/0014	The Pradeshiya Industrial & Investment Coporation of U.P. Ltd.	424800	2025-05-01 00:00:00	385	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
624	Asija And Associates LLP	AAA LLP	2025-06-10	HO/25-26/RS/0055	The Pradeshiya Industrial & Investment Coporation of U.P. Ltd.	283200	2025-07-10 00:00:00	315	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
714	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/SD/0163	Spacia Ventures LLP	29500	2026-04-30 00:00:00	21	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
625	Asija And Associates LLP	AAA LLP	2025-06-10	HO/25-26/RS/0060	The Pradeshiya Industrial & Investment Coporation of U.P. Ltd.	47200	2025-07-10 00:00:00	315	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
626	Asija And Associates LLP	AAA LLP	2025-07-02	HO/25-26/SD/0044	Bks Myvault Private Limited	54000	2025-08-01 00:00:00	263	\N	\N	open	0	\N	\N	SahilD	\N	\N	\N
627	Asija And Associates LLP	AAA LLP	2025-07-08	HO/25-26/RS/0064	The Pradeshiya Industrial & Investment Coporation of U.P. Ltd.	141600	2025-08-07 00:00:00	287	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
628	Asija And Associates LLP	AAA LLP	2025-07-09	HO/25-26/KKF/031	District Horticulture Officer, Barabanki	4307	2025-08-08 00:00:00	286	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
629	Asija And Associates LLP	AAA LLP	2025-08-10	HO/25-26/RS/0102	Karam Safety Private Limited-ISD	8850	2025-09-09 00:00:00	284	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
630	Asija And Associates LLP	AAA LLP	2025-08-10	HO/25-26/AA/0091	The Lucknow Martin Trust	8850	2025-09-09 00:00:00	254	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
631	Asija And Associates LLP	AAA LLP	2025-09-13	HO/25-26/KKF/051	Deputy Chief Signal And Telecom Engineer	111722	2025-10-13 00:00:00	220	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
633	Asija And Associates LLP	AAA LLP	2025-10-10	HO/25-26/CL/0056	KANAKSH INFRA LLP	1180	2025-11-09 00:00:00	193	\N	\N	full_paid	1180	2026-06-09 10:05:48	\N	KamalF	\N	\N	\N
637	Asija And Associates LLP	AAA LLP	2025-11-10	HO/25-26/CL/0070	BBV Properties Llp	4180	2025-12-10 00:00:00	162	\N	\N	open	0	\N	\N	ManishM	\N	\N	\N
638	Asija And Associates LLP	AAA LLP	2025-11-10	HO/25-26/SD/0102	Limen Solutions Private Limited	12980	2025-12-10 00:00:00	162	\N	\N	open	0	\N	\N	SahilD	\N	\N	\N
639	Asija And Associates LLP	AAA LLP	2025-11-10	HO/25-26/KKF/087	Mahan Brick Field	8260	2025-12-10 00:00:00	162	\N	\N	full_paid	8260	2026-05-29 14:01:59	\N	\N	\N	\N	\N
640	Asija And Associates LLP	AAA LLP	2025-11-10	HO/25-26/RS/0160	UP Metro Rail Corporation Ltd.	57820	2025-12-10 00:00:00	192	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
641	Asija And Associates LLP	AAA LLP	2025-11-18	HO/25-26/KKF/097	GIRDHARGOPAL AGENCIES PRIVATE LIMITED	6366	2025-12-18 00:00:00	154	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
642	Asija And Associates LLP	AAA LLP	2025-11-20	HO/25-26/KKF/099	Surcoat Paints Private Limited	203	2025-12-20 00:00:00	152	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
643	Asija And Associates LLP	AAA LLP	2025-11-22	HO/25-26/KKF/104	DC Drda Admin Ambedkar Nagar	2302	2025-12-22 00:00:00	180	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
644	Asija And Associates LLP	AAA LLP	2025-11-26	HO/25-26/KKF/107	S and V Infrazone Private Limited	800	2025-12-26 00:00:00	146	\N	\N	open	0	\N	\N	ManishM	\N	\N	\N
645	Asija And Associates LLP	AAA LLP	2025-12-03	HO/25-26/KKF/109	UP State Construction and Infrastructure Development Corporation Ltd.	191160	2026-01-02 00:00:00	139	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
646	Asija And Associates LLP	AAA LLP	2025-12-09	HO/25-26/RS/0186	Spacia Ventures LLP	25974	2026-01-08 00:00:00	133	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
647	Asija And Associates LLP	AAA LLP	2025-12-10	HO/25-26/SD/0134	Spacia Ventures LLP	72216	2026-01-09 00:00:00	132	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
648	Asija And Associates LLP	AAA LLP	2025-12-10	HO/25-26/SD/0120	UP Electronics Corporation Limited	37500	2026-01-09 00:00:00	162	\N	\N	open	0	\N	\N	SahilD	\N	\N	\N
649	Asija And Associates LLP	AAA LLP	2025-12-30	HO/25-26/KKF/119	Uttar Pradesh Building & Other Construction Workers Welfare Board - HO	13630	2026-01-29 00:00:00	112	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
650	Asija And Associates LLP	AAA LLP	2025-12-30	HO/25-26/KKF/120	Uttar Pradesh Building & Other Construction Workers Welfare Board - HO	77820	2026-01-29 00:00:00	112	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
651	Asija And Associates LLP	AAA LLP	2026-01-02	HO/25-26/KKF/129	Punjab and Sind Bank Vikas Nagar	7080	2026-02-01 00:00:00	109	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
654	Asija And Associates LLP	AAA LLP	2026-02-10	HO/25-26/RS/0223	Iqbal Kidwai	1298	2026-03-12 00:00:00	70	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
662	Asija And Associates LLP	AAA LLP	2026-02-10	HO/25-26/CL/0100	Soham Infrapromoters Private Limited	9260	2026-03-12 00:00:00	70	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
702	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/SD/0162	Juno Casting Private Limited	31152	2026-04-30 00:00:00	21	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
703	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/RS/0271	Karam Safety Private Limited - Lucknow	188800	2026-04-30 00:00:00	51	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
713	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/RS/0267	Spacia Ventures LLP	4366	2026-04-30 00:00:00	21	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
530	AAAFC	AAAFC	2023-04-20	AAAFC-23-24-AK-Del-0008	Sundry Departmental Debtor	42500	2023-05-20 00:00:00	1128	\N	AshishK	open	0	\N		AshishK	\N	\N	\N
531	AAAFC	AAAFC	2024-04-01	Kaushambhi- 20-21 - BOCW	Sundry Departmental Debtor	5324	2024-05-01 00:00:00	781	\N	AshishK	open	0	\N	UPBOCW	KamalF	\N	\N	\N
532	AAAFC	AAAFC	2024-04-01	Badaun- 20-21 - BOCW	Sundry Departmental Debtor	5250	2024-05-01 00:00:00	781	\N	AshishK	open	0	\N	UPBOCW	KamalF	\N	\N	\N
533	AAAFC	AAAFC	2024-04-01	Mainpuri- 20-21 - BOCW	Sundry Departmental Debtor	5250	2024-05-01 00:00:00	781	\N	AshishK	open	0	\N	UPBOCW	KamalF	\N	\N	\N
534	AAAFC	AAAFC	2024-04-01	Amroha- 20-21 - BOCW	Sundry Departmental Debtor	5348	2024-05-01 00:00:00	781	\N	AshishK	open	0	\N	UPBOCW	KamalF	\N	\N	\N
535	AAAFC	AAAFC	2024-06-01	AAAFC/24-25/Corpl/0017	DGTLJ Consultancy LLP	3054.13	2024-07-01 00:00:00	689	\N	\N	full_paid	3054.13	2026-06-09 10:31:48	\N	ManishM	\N	\N	\N
536	AAAFC	AAAFC	2024-10-01	AAAFC/24-25/Corpl/0045	KANAKSH INFRA LLP	1000	2024-10-31 00:00:00	567	\N	\N	full_paid	1000	2026-06-09 09:59:59	\N	KamalF	\N	\N	\N
743	Asija And Associates LLP	AAA LLP	2026-04-25	HO/26-27/KKF/024	ICICI Bank Limited - Mahanagar Branch	41300	2026-05-25 00:00:00	26	\N	\N	full_paid	41300	2026-05-29 18:02:19	\N	\N	\N	\N	\N
744	Asija And Associates LLP	AAA LLP	2026-04-28	HO/26-27/KKF/027	Indian Institute Of Management Lucknow	59000	2026-05-28 00:00:00	24	\N	\N	full_paid	59000	2026-05-29 18:02:19	\N	\N	\N	\N	\N
745	Asija And Associates LLP	AAA LLP	2026-04-28	HO/26-27/KKF/025	Northern Coalfields Limited , Dudhichua	12426	2026-05-28 00:00:00	23	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
746	Asija And Associates LLP	AAA LLP	2026-04-29	HO/26-27/KKF/029	Gobind Industries Pvt.Ltd.	19942	2026-05-29 00:00:00	22	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
747	Asija And Associates LLP	AAA LLP	2026-04-29	HO/26-27/AK/0005	KM Vyapar Limited	140125	2026-05-29 00:00:00	34	\N	AshishK	full_paid	280250	2026-06-13 11:07:15		AkashA	\N	\N	\N
748	Asija And Associates LLP	AAA LLP	2026-04-30	HO/26-27/SD/0004	BR Autoventures Private Limited	118000	2026-05-30 00:00:00	21	\N	\N	open	0	\N	\N	SahilD	\N	\N	\N
749	Asija And Associates LLP	AAA LLP	2026-04-30	HO/26-27/KKF/031	Central Bank of India-Bhopal	5905	2026-05-30 00:00:00	21	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
750	Asija And Associates LLP	AAA LLP	2026-04-30	HO/26-27/KKF/032	Central Bank of India-Bhopal	33709	2026-05-30 00:00:00	21	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
725	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/AA/0222	Vishal Mishra	3540	2026-04-30 00:00:00	51	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
887	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/SD/0027	BKS MYJEWELS PRIVATE LIMITED	5900	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	SahilD	\N	\N	\N
983	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0003	Vishal Mishra	8850	2026-07-10 00:00:00	1	20260611184256112699	\N	open	0	\N	\N	AkashA	\N	\N	\N
984	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0007	Vishesh Traders	17700	2026-07-10 00:00:00	1	20260611184256112699	\N	open	0	\N	\N	SahilD	\N	\N	\N
985	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0006	VS Trading Co	17700	2026-07-10 00:00:00	1	20260611184256112699	\N	open	0	\N	\N	SahilD	\N	\N	\N
986	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/KKF/050	Tiranga Prerna Clf	20650	2026-07-10 00:00:00	3		KamalF	full_paid	20650	2026-06-13 14:16:11		KamalF	\N	\N	\N
988	AAAFC	AAAFC	2006-06-10	AAAFC-26-27-RS-Del-0001	Sundry Departmental Debtor- UP State Tax	200000	2006-07-10 00:00:00	7308		RohitS	full_paid	500000	2026-06-13 15:34:07		RohitS	\N	\N	\N
570	AAAFC	AAAFC	2026-02-10	AAAFC-25-26-RS-Del-0016	Sundry Departmental Debtor - NADT Lucknow	4000	2026-03-12 00:00:00	70	\N	\N	open	0	\N	\N	AshishK	\N	\N	\N
571	AAAFC	AAAFC	2026-02-26	AAAFC-25-26-AA-Del-0024	Sundry Departmental Debtor	30000	2026-03-28 00:00:00	85	\N	AkashA	open	0	\N	Chandra Shekhar Yadav	AkashA	\N	\N	\N
572	AAAFC	AAAFC	2026-02-26	AAAFC-25-26-AA-Del-0027	Sundry Departmental Debtor	7000	2026-03-28 00:00:00	85	\N	AkashA	open	0	\N	Nitin Singh MVVNL	AkashA	\N	\N	\N
573	AAAFC	AAAFC	2026-02-26	AAAFC-25-26-AK-Del-0024	Sundry Departmental Debtor - NADT Lucknow	4000	2026-03-28 00:00:00	54	\N	\N	open	0	\N	\N	AshishK	\N	\N	\N
574	AAAFC	AAAFC	2026-03-01	AAAFC-25-26-AK-Del-0026	Asija Financial Services	21000	2026-03-31 00:00:00	81	\N	\N	open	0	\N	\N	AshishK	\N	\N	\N
575	AAAFC	AAAFC	2026-03-10	AAAFC/25-26/AA/0148	Dinesh Kumar Vishwakarma	15000	2026-04-09 00:00:00	72	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
576	AAAFC	AAAFC	2026-03-10	AAAFC/25-26/Corpl/0044	Dream De Tourz LLP	22893	2026-04-09 00:00:00	42	\N	\N	full_paid	22893	2026-06-04 14:56:14	\N	AshishK	\N	\N	\N
548	AAAFC	AAAFC	2025-08-10	AAAFC/25-26/AA/0055	Ritwik Patra	3000	2025-09-09 00:00:00	254	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
549	AAAFC	AAAFC	2025-09-09	AAAFC/25-26/AA/0076	Vandana Singh	6000	2025-10-09 00:00:00	224	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
550	AAAFC	AAAFC	2025-09-19	AAAFC/25-26/KKF/0005	Raj Kishore Pasi	4000	2025-10-19 00:00:00	214	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
551	AAAFC	AAAFC	2025-09-19	AAAFC/25-26/KKF/0009	Suyog Singhal HUF	30000	2025-10-19 00:00:00	214	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
552	AAAFC	AAAFC	2025-10-01	AAAFC/25-26/AA/0101	Pawan Rathour	3000	2025-10-31 00:00:00	202	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
553	AAAFC	AAAFC	2025-10-10	AAAFC/25-26/Corpl/0028	Wynsum Food Box LLP	500	2025-11-09 00:00:00	193	\N	\N	open	0	\N	\N	ManishM	\N	\N	\N
554	AAAFC	AAAFC	2025-10-14	AAAFC/25-26/RS/0002	M/s Lucky Jewellery	10000	2025-11-13 00:00:00	219	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
555	AAAFC	AAAFC	2025-11-10	AAAFC/25-26/Corpl/0033	KANAKSH INFRA LLP	5200	2025-12-10 00:00:00	162	\N	\N	full_paid	5200	2026-06-09 09:59:59	\N	KamalF	\N	\N	\N
556	AAAFC	AAAFC	2025-11-10	AAAFC/25-26/Corpl/0038	Karam Infracon LLP	2550	2025-12-10 00:00:00	162	\N	\N	full_paid	2550	2026-06-09 09:55:30	\N	KamalF	\N	\N	\N
557	AAAFC	AAAFC	2025-11-10	AAAFC/25-26/Corpl/0036	Limen Solutions Private Limited	2800	2025-12-10 00:00:00	162	\N	\N	full_paid	2800	2026-06-13 15:26:26	\N	SahilD	\N	\N	\N
563	AAAFC	AAAFC	2025-11-11	AAAFC/25-26/AA/0127	Pawan Rathour	25000	2025-12-11 00:00:00	161	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
793	Asija Financial Services	AFS	2026-01-10	AFS/25-26/AA/0016	Al Madina Trust	10000	2026-02-09 00:00:00	98	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
842	Asija And Associates LLP	AAA LLP	2026-06-05	HO/26-27/CL/0010	BBV Properties Llp	4180	2026-07-05 00:00:00	4	\N	\N	open	0	\N	\N	ManishM	\N	\N	\N
916	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0036	Suyash Bansal	2396	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	AkashA	2026-06-11 18:29:13	arif.siddiqui@asija.in	Bulk delete from main report
586	AAAFC	AAAFC	2026-03-31	AAAFC/25-26/Corpl/0047	Unix Enterprises Private Limited	2500	2026-04-30 00:00:00	21	\N	\N	open	0	\N	\N	KamalF	\N	\N	\N
587	AAAFC	AAAFC	2026-04-01	AAAFC/26-27/AA/0002	Aashirwad Welfare Society	10000	2026-05-01 00:00:00	20	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
577	AAAFC	AAAFC	2026-03-10	AAAFC/25-26/AA/0141	Faizane Madina Agra Society	40000	2026-04-09 00:00:00	42	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
951	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0012	B K Saraf Private Limited	10608	2026-07-10 00:00:00	1	20260611184256112699	\N	open	0	\N	\N	SahilD	\N	\N	\N
952	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0014	BKS MyGold Private Limited	5050	2026-07-10 00:00:00	1	20260611184256112699	\N	open	0	\N	\N	SahilD	\N	\N	\N
953	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0015	Bks Myvault Private Limited	2538	2026-07-10 00:00:00	1	20260611184256112699	\N	open	0	\N	\N	SahilD	\N	\N	\N
961	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0034	Karam Safety Private Limited-ISD	82600	2026-07-10 00:00:00	1	20260611184256112699	\N	open	0	\N	\N	RohitS	\N	\N	\N
558	AAAFC	AAAFC	2025-11-10	AAAFC/25-26/Corpl/0030	Wynsum Food Box LLP	6050	2025-12-10 00:00:00	162	\N	\N	open	0	\N	\N	ManishM	\N	\N	\N
559	AAAFC	AAAFC	2025-11-11	AAAFC/25-26/AA/0119	Aashirwad Welfare Society	15000	2025-12-11 00:00:00	161	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
560	AAAFC	AAAFC	2025-11-11	AAAFC/25-26/AA/0123	Jadaun Educational Trust	15000	2025-12-11 00:00:00	161	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
561	AAAFC	AAAFC	2025-11-11	AAAFC/25-26/AA/0120	Jai Maa Vaishno Educational Trust	15000	2025-12-11 00:00:00	161	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
562	AAAFC	AAAFC	2025-11-11	AAAFC/25-26/AA/0121	Maa Pitambra Educational and Charitable Trust	15000	2025-12-11 00:00:00	161	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
564	AAAFC	AAAFC	2025-11-11	AAAFC/25-26/AA/0122	Shri Shyam Sundar Memorial Charitable Trust	15000	2025-12-11 00:00:00	161	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
565	AAAFC	AAAFC	2025-12-10	AAAFC/25-26/Corpl/0042	Winstrux Global LLP	8500	2026-01-09 00:00:00	132	\N	\N	full_paid	8500	2026-06-09 09:55:30	\N	KamalF	\N	\N	\N
566	AAAFC	AAAFC	2026-01-08	AAAFC-25-26-AA-Del-0016	Clive Richard Butterfield	25000	2026-02-07 00:00:00	103	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
567	AAAFC	AAAFC	2026-02-01	AAAFC-25-26-AK-Del-0019	Asija Financial Services	2500	2026-03-03 00:00:00	109	\N	\N	open	0	\N	\N	AshishK	\N	\N	\N
568	AAAFC	AAAFC	2026-02-10	AAAFC/25-26/RS/0003	Divya Khare	2750	2026-03-12 00:00:00	70	\N	\N	open	0	\N	\N	RohitS	\N	\N	\N
569	AAAFC	AAAFC	2026-02-10	AAAFC-25-26-AA-Del-0021	Sundry Departmental Debtor	8000	2026-03-12 00:00:00	101	\N	AkashA	open	0	\N	Dinesh Vishwakarma	AkashA	\N	\N	\N
938	AAAFC	AAAFC	2026-06-10	AAAFC/26-27/AA/0018	Supriya Choudhary	3000	2026-07-10 00:00:00	-1	\N	\N	open	0	\N	\N	AkashA	\N	\N	\N
954	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0016	Chillies N Lemon Infra & Hospitality LLP	2124	2026-07-10 00:00:00	1	20260611184256112699	\N	open	0	\N	\N	SahilD	\N	\N	\N
955	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0017	Ensky Ventures Private Limited	7292	2026-07-10 00:00:00	1	20260611184256112699	\N	open	0	\N	\N	SahilD	\N	\N	\N
956	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0036	Faizane Madina Agra Society	17700	2026-07-10 00:00:00	1	20260611184256112699	\N	open	0	\N	\N	AkashA	\N	\N	\N
957	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0018	Girdhargopal Agencies Private Limited	1806	2026-07-10 00:00:00	1	20260611184256112699	\N	open	0	\N	\N	KamalF	\N	\N	\N
958	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0019	Jalsa Resorts (India) Private Limited	1948	2026-07-10 00:00:00	1	20260611184256112699	\N	open	0	\N	\N	AkashA	\N	\N	\N
959	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0004	Jesus & Mary Play School Balarampur	21664	2026-07-10 00:00:00	1	20260611184256112699	\N	open	0	\N	\N	AkashA	\N	\N	\N
960	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/AA/0020	Jyoti Exports Limited	4732	2026-07-10 00:00:00	1	20260611184256112699	\N	open	0	\N	\N	SahilD	\N	\N	\N
\.


--
-- Data for Name: cheque_bounce_register; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cheque_bounce_register (id, receipt_register_id, source_bill_id, readded_bill_id, bounced_at, bounce_date, firm_name, short_name, bill_date, ref_no, party_name, bill_amount, bounced_amount, receipt_date, receipt_mode, posted_at, due_date, overdue_days, client_group, followup_partner, final_ep, crp_of_group, client_category, financial_year, reason) FROM stdin;
1	38	670	948	2026-06-10 14:12:10	\N	Asija And Associates LLP	AAA LLP	2026-02-10	HO/25-26/CL/0117	Unisel Infraservices and Trade Pvt Ltd	13570	13570	2026-06-03	Bank	2026-06-04 14:57:36	2026-03-12	70	Praveen Kumar Singh	AshishK	ManishM	AshishK	Private	02.04.2025 - 01.04.2026	Fund Insufficent
\.


--
-- Data for Name: client_group_master; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.client_group_master (id, group_name, crp_name, reffered_by, created_at, updated_at) FROM stdin;
1	Abhishek Sarraf	SahilD	CA Ashish Kapoor	2026-06-09 11:41:25	\N
2	Abhishek Singh	ManishM	CS Manish Mishra	2026-06-09 11:41:25	\N
3	Aditya Jhunjhunwala group	AkashA	CA Ashish Kapoor	2026-06-09 11:41:25	\N
4	AICIL	KamalF	CA Kamal Ferwani	2026-06-09 11:41:25	\N
5	Airports Authority of India	RohitS	CA Rohit Singh	2026-06-09 11:41:25	\N
6	Amol Bansal	SahilD	CA Ashish Kapoor	2026-06-09 11:41:25	\N
7	Anand Gupta	ManishM	CA Ashish Kapoor	2026-06-09 11:41:25	\N
8	Anuja Sharma	KamalF	Iqbal Qidwai - Ashish Kapoor	2026-06-09 11:41:25	\N
9	Arif Group	SahilD	CA Ashish Kapoor	2026-06-09 11:41:25	\N
10	Arun Singh	ManishM	CS Manish Mishra	2026-06-09 11:41:25	\N
11	Ashish Kapoor	RuchiK	CA Ashish Kapoor	2026-06-09 11:41:25	\N
12	Ashish Raina	AkashA	CA Ashish Kapoor	2026-06-09 11:41:25	\N
13	Ashish Tondon	KamalF	CA Ashish Kapoor	2026-06-09 11:41:25	\N
14	Ashwani Mishra	ManishM	CA Ruchi Kapoor	2026-06-09 11:41:25	\N
15	Bank of India	KamalF	CA Kamal Ferwani	2026-06-09 11:41:25	\N
16	BHUSHAN LAL MIDHA	RohitS	CA Rohit Singh	2026-06-09 11:41:25	\N
17	Bivash Sarcar	AkashA	CA Akash Agarwal	2026-06-09 11:41:25	\N
18	Blue Bell	AshishK	Ashish Kapoor- CA Naeem Khan	2026-06-09 11:41:25	\N
19	Brijesh	AshishK	CA Ashish Kapoor	2026-06-09 11:41:25	\N
20	Butterfield	SahilD	Amit Ghai - Ashish Kapoor	2026-06-09 11:41:25	\N
21	CA Harish Shah	AkashA	CA Gaurav Shah - Ashish Kapoor	2026-06-09 11:41:25	\N
22	Central Bank of India	KamalF	CA Ashish Kapoor	2026-06-09 11:41:25	\N
23	Centricity Financial Distribution Private Limited	RuchiK	CA Ashish Kapoor	2026-06-09 11:41:25	\N
24	Chandra Shekhar Yadav	KamalF	CA Ashish Kapoor	2026-06-09 11:41:25	\N
25	Devesh Manjar	KamalF	CA Kamal Ferwani	2026-06-09 11:41:25	\N
26	Dhaon	AkashA	CA Ashish Kapoor	2026-06-09 11:41:25	\N
27	Dinesh Vishwakarma	AkashA	CA Ashish Kapoor	2026-06-09 11:41:25	\N
28	Dr. Rahul Srivastava	KamalF	CA Kamal Ferwani	2026-06-09 11:41:25	\N
29	Dr. S.P.M. Civil Hospital	KamalF	CA Kamal Ferwani	2026-06-09 11:41:25	\N
30	DRDA Ambedkar Nagar	KamalF	CA Kamal Ferwani	2026-06-09 11:41:25	\N
31	DRDA Chitrakoot	KamalF	CA Kamal Ferwani	2026-06-09 11:41:25	\N
32	Film Bandhu	KamalF	CA Kamal Ferwani	2026-06-09 11:41:25	\N
33	Gharda Group	RohitS	CA. Rohit Singh	2026-06-09 11:41:25	\N
34	Gobind Industries	KamalF	CA Kamal Ferwani	2026-06-09 11:41:25	\N
35	Green Gas Limited	KamalF	CA Kamal Ferwani	2026-06-09 11:41:25	\N
36	Horticulture	KamalF	CA Kamal Ferwani	2026-06-09 11:41:25	\N
37	ICICI Bank	KamalF	CA Ashish	2026-06-09 11:41:25	\N
38	IIM-L	KamalF	CA Ashish Kapoor	2026-06-09 11:41:25	\N
39	Invest UP	RohitS	CA Rohit Singh	2026-06-09 11:41:25	\N
40	Iqbal Kidwai	RohitS	CA Ashish Kapoor	2026-06-09 11:41:25	\N
41	Jadaun Educational Trust	AkashA	CA Akash Agarwal	2026-06-09 11:41:25	\N
42	Jai Shanker Mishra	KamalF	CA Ashish Kapoor	2026-06-09 11:41:25	\N
43	K.N Associates	AkashA	CA Ashish Kapoor	2026-06-09 11:41:25	\N
44	KV Singh	AshishK	CA Ashish Kapoor	2026-06-09 11:41:25	\N
45	La Mart	AshishK	CA Ashish Kapoor	2026-06-09 11:41:25	\N
46	Lobo	ManishM	CS Manish Mishra	2026-06-09 11:41:25	\N
47	Lucknow Martin Trust	AshishK	CA Ashish Kapoor	2026-06-09 11:41:25	\N
48	Manoj Singh	KamalF	CA Kamal Ferwani	2026-06-09 11:41:25	\N
49	Minhaz	AkashA	CA Musheer Alam Khan - Ashish	2026-06-09 11:41:25	\N
50	Mohammad Ahmad	CRP-SahilD	CA Ashish Kapoor	2026-06-09 11:41:25	\N
51	Mohd. Islam	KamalF	CA Kamal Ferwani	2026-06-09 11:41:25	\N
52	Munawar Anzar	SahilD	CA Ashish Kapoor	2026-06-09 11:41:25	\N
53	MVVNL	KamalF	CA Ashish Kapoor	2026-06-09 11:41:25	\N
54	NADT	AshishK		2026-06-09 11:41:25	\N
55	Neepco Ltd	KamalF	CA Kamal Kumar Ferwani	2026-06-09 11:41:25	\N
56	NHAI	KamalF	CA Kamal Kumar Ferwani	2026-06-09 11:41:25	\N
57	Nirman Tirth	CRP- AshishK	CA Ashish Kapoor	2026-06-09 11:41:25	\N
58	Nitin Singh MVVNL	KamalF	CA Ashish Kapoor	2026-06-09 11:41:25	\N
59	Nivah Hospitality LLP	AshishK	Ashish Kapoor	2026-06-09 11:41:25	\N
60	Northern Coalfields Limited , Dudhichua	KamalF	CA Kamal Ferwani	2026-06-09 11:41:25	\N
61	Northern Railway	KamalF	CA Kamal Ferwani	2026-06-09 11:41:25	\N
62	NTPC-IA	KamalF	CA Kamal Kumar Ferwani	2026-06-09 11:41:25	\N
63	Peter Fanthome	AshishK	CA Ashish Kapoor	2026-06-09 11:41:25	\N
64	Pickup bhawan	RohitS	CA Kamal Ferwani	2026-06-09 11:41:25	\N
65	Piyush Kumar Singh	RohitS	CA Ashish Kapoor	2026-06-09 11:41:25	\N
66	Praveen Kumar Singh	AshishK	CA Ashish Kapoor	2026-06-09 11:41:25	\N
67	Praveen Singh	SahilD	CA Ashish Kapoor	2026-06-09 11:41:25	\N
68	Punjab & Sind Bank	KamalF	CA Kamal Kumar Ferwani	2026-06-09 11:41:25	\N
69	PVVNL	KamalF	CA Kamal Ferwani	2026-06-09 11:41:25	\N
70	Rahul Pawah CA	AshishK	CA Ashish Kapoor	2026-06-09 11:41:25	\N
71	Raj Kishore Pasi	KamalF	CA Kamal Ferwani	2026-06-09 11:41:25	\N
72	Rajeev Bansal	KamalF	CA Ashish Kapoor	2026-06-09 11:41:25	\N
73	Rajendra Singh	KamalF	CA Ashish Kapoor	2026-06-09 11:41:25	\N
74	Rajesh Nigam - Business Group	AshishK	CA Ashish Kapoor	2026-06-09 11:41:25	\N
75	Ram Nath Jaiswal	AkashA	CA Ashish Kapoor	2026-06-09 11:41:25	\N
76	Ranjana Prakash	AshishK	CA Ashish Kapoor	2026-06-09 11:41:25	\N
77	Rishi Agarwal Yi	AshishK	CA Ashish Kapoor	2026-06-09 11:41:25	\N
78	Ritesh Agarwal Grp	KamalF	CA Ashish Kapoor	2026-06-09 11:41:25	\N
79	Ritwik Patra	AkashA	CA Ashish Kapoor	2026-06-09 11:41:25	\N
80	Rohit Agarwal	AshishK	CA Ashish Kapoor	2026-06-09 11:41:25	\N
81	Sachin Shukla	CRP-AkashA	CA Akash Agarwal	2026-06-09 11:41:25	\N
82	Saurabh Bhandari	RohitS	CA Ashish Kapoor	2026-06-09 11:41:25	\N
83	Saurabh Chaudhary	AkashA	CA Akash Agarwal	2026-06-09 11:41:25	\N
84	Saurabh Mehrotra	AshishK	CA Ashish Kapoor	2026-06-09 11:41:25	\N
85	Shardul Singh	AkashA	CA Akash Agarwal	2026-06-09 11:41:25	\N
86	Sharp	SahilD	CA Ashish Kapoor	2026-06-09 11:41:25	\N
87	Shravendra Ji	AshishK	CA Ashish Kapoor	2026-06-09 11:41:25	\N
88	Shrawan Bhargava	RohitS	CA Ashish Kapoor	2026-06-09 11:41:25	\N
89	Shree Constructions And Leisure Private Limited	ManishM	CS Manish Mishra	2026-06-09 11:41:25	\N
90	Shri Shyam Sundar Memorial Charitable Trust	AkashA	CA Akash Agarwal	2026-06-09 11:41:25	\N
91	SRM Group	SahilD	CA Ashish Kapoor	2026-06-09 11:41:25	\N
92	State Health Society of Uttar Pradesh	KamalF	CA Ashish Kapoor	2026-06-09 11:41:25	\N
93	Supriya Choudhary	AkashA	CA Ashish Kapoor	2026-06-09 11:41:25	\N
94	SUYOG SINGHAL	KamalF	CA Ashish Kapoor	2026-06-09 11:41:25	\N
95	T Ram	KamalF	CA Ashish Kapoor	2026-06-09 11:41:25	\N
96	Tamanna Raza	AkashA	CA Ashish Kapoor	2026-06-09 11:41:25	\N
97	Tariq Sheikh	SahilD	CA Ashish Kapoor	2026-06-09 11:41:25	\N
98	TATA Motors Passenger Vehicle Limited	AshishK		2026-06-09 11:41:25	\N
99	Tirwa	ManishM	CA Ashish Kapoor	2026-06-09 11:41:25	\N
100	Ujjwal Kapoor	AshishK	CA Ashish Kapoor	2026-06-09 11:41:25	\N
101	UNDP	RohitS	Ashish Kapoor-RM	2026-06-09 11:41:25	\N
102	UNDP - Afghanistan	SahilD	CA Ashish Kapoor	2026-06-09 11:41:25	\N
103	UNICEF	RohitS	Ashish Kapoor-RM	2026-06-09 11:41:25	\N
104	Uniform Venture	AshishK	CA Ashish Kapoor	2026-06-09 11:41:25	\N
105	United Nation - Global	SahilD	Ashish Kapoor	2026-06-09 11:41:25	\N
106	UP Electronics Corporation Limited	SahilD	Kamal & Rohit	2026-06-09 11:41:25	\N
107	UP Metro Rail Corporation Ltd.	RohitS	CA Sunil Agarwal	2026-06-09 11:41:25	\N
108	UP PWD	KamalF	CA Kamal Ferwani	2026-06-09 11:41:25	\N
109	UP Skill	AshishK	CA Ashish Kapoor	2026-06-09 11:41:25	\N
110	UPBOCW	KamalF	CA Ashish Kapoor	2026-06-09 11:41:25	\N
111	UPSCIDCO	KamalF	CA Ashish Kapoor	2026-06-09 11:41:25	\N
112	UPSPN	AkashA	CA Kamal Ferwani	2026-06-09 11:41:25	\N
113	UPSRLM	KamalF	Kamal Kumar Ferwani	2026-06-09 11:41:25	\N
114	Uttar Pradesh Gramin Bank	KamalF	CA Kamal Kumar Ferwani	2026-06-09 11:41:25	\N
115	Vandana Singh	AkashA	CA Ashish Kapoor	2026-06-09 11:41:25	\N
116	Vikram Behari Kaushal	AkashA	CA Ashish Kapoor	2026-06-09 11:41:25	\N
117	Vinod Sukhwani_01-Apr-2019	CRP-AshishK	CA Ashish Kapoor	2026-06-09 11:41:25	\N
118	Virendra Ojha IRS	AshishK	CA Ashish Kapoor	2026-06-09 11:41:25	\N
119	Vishal Mishra	AshishK	CA Ashish Kapoor	2026-06-09 11:41:25	\N
120	Vivek Jaiswal	SahilD	CA Ashish Kapoor	2026-06-09 11:41:25	\N
121	Yogendra Samir Yadav	AshishK	CA Ashish Kapoor	2026-06-09 11:41:25	\N
122	Yogesh Bhatia	SahilD	CA Sahil Dua	2026-06-09 11:41:25	\N
8663	Naman Kapoor	AshishK		2026-06-09 13:37:18	2026-06-09 19:07:18
17814	UP State Tax	RohitS	CA Rohit Singh	2026-06-11 09:30:30	2026-06-11 15:00:30
\.


--
-- Data for Name: client_master; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.client_master (id, client_name, phone, email, gstin, client_group, crp_of_group, reffered_by, whatapp_group, client_category) FROM stdin;
1	Sundry Departmental Debtor - UP Skill				UP Skill	AshishK	CA Ashish Kapoor		Government
2	The Lucknow Martin Trust				Lucknow Martin Trust	AshishK	CA Ashish Kapoor	WhtAppGrp_Lucknow Martin Charity	Government
3	Deputy CAO Zonal Account Office PVVNL-Gorakhpur				PVVNL	KamalF	CA Kamal Ferwani		Government
4	NORTH EASTERN ELECTRIC POWER CORPORATION LTD-Nagaland				Neepco Ltd	KamalF	CA Kamal Kumar Ferwani		Government
5	District Health Society District, Baghpat				State Health Society of Uttar Pradesh	KamalF	CA Ashish Kapoor		Government
6	District Health Society District, Hapur				State Health Society of Uttar Pradesh	KamalF	CA Ashish Kapoor		Government
7	District Health Society Gautam Buddha Nagar				State Health Society of Uttar Pradesh	KamalF	CA Ashish Kapoor		Government
8	District Health Society- Meerut				State Health Society of Uttar Pradesh	KamalF	CA Ashish Kapoor		Government
9	District Health Society, Bulandshaher				State Health Society of Uttar Pradesh	KamalF	CA Ashish Kapoor		Government
10	District Health Society, Ghaziabad				State Health Society of Uttar Pradesh	KamalF	CA Ashish Kapoor		Government
11	Sundry Departmental Debtor				UP Skill	AshishK	CA Ashish Kapoor		Private
12	EXECUTIVE ENGINEER WORLD BANK DIVISION NO-1 PWD LUCKNOW				UP PWD	KamalF	CA Kamal Ferwani		Government
13	UNDP				UNDP	RohitS	Ashish Kapoor-RM		Government
14	DGTLJ Consultancy LLP				Anuja Sharma	KamalF	Iqbal Qidwai - Ashish Kapoor		Private
15	The Pradeshiya Industrial & Investment Coporation of U.P. Ltd.				Pickup bhawan	RohitS	CA Kamal Ferwani		Government
16	Kanaksh Infra LLP				Ritesh Agarwal Grp	KamalF	CA Ashish Kapoor	Ritesh Agarwal Grp @Asija	Private
17	Karam Infracon LLP				Ritesh Agarwal Grp	KamalF	CA Ashish Kapoor	Ritesh Agarwal Grp @Asija	Private
18	Saurabh Chaudhary				Saurabh Chaudhary	AkashA	CA Akash Agarwal		Private
19	Ranjana Prakash				Ranjana Prakash	AshishK	CA Ashish Kapoor	Ms R Prakash Grp @ Asija	Private
20	Centricity Financial Distribution Private Limited				Centricity Financial Distribution Private Limited	RuchiK	CA Ashish Kapoor		Private
21	Ram Nath Jaiswal- Firm				Ram Nath Jaiswal	AkashA	CA Ashish Kapoor		Private
22	Ayisha Shiksha Sansthan				Tamanna Raza	AkashA	CA Ashish Kapoor		Private
23	Asija Tech Consulting LLP				Ashish Kapoor	RuchiK	CA Ashish Kapoor		Private
24	Asija Financial Services				Ashish Kapoor	RuchiK	CA Ashish Kapoor		Private
25	Al Madina Trust				Minhaz	AkashA	CA Musheer Alam Khan - Ashish	WhtAppGrp_CA Tahseen Hussain	Private
26	Arshadi Foundation				Minhaz	AkashA	CA Musheer Alam Khan - Ashish	WhtAppGrp_CA Tahseen Hussain	Private
27	Ramesh Traders				Rahul Pawah CA	AshishK	CA Ashish Kapoor	Grp Rahul Pahwa CA @ Asija	Private
28	Ujjwal Kapoor & Associates				Ujjwal Kapoor	AshishK	CA Ashish Kapoor	Ujjwal Kapoor Grp @ Asija	Private
29	BBV Properties Llp				Rohit Agarwal	AshishK	CA Ashish Kapoor	Rohit A Grp@Team Asija	Private
30	Bks Myvault Private Limited				Amol Bansal	SahilD	CA Ashish Kapoor	Amol Bansal Grp	Private
31	District Horticulture Officer, Barabanki				Horticulture	KamalF	CA Kamal Ferwani		Government
32	Karam Safety Private Limited-ISD				Rajesh Nigam - Business Group	AshishK	CA Ashish Kapoor	Karam Group @ Asija	Private
33	Ritwik Patra				Ritwik Patra	AkashA	CA Ashish Kapoor		Private
34	Vandana Singh				Vandana Singh	AkashA	CA Ashish Kapoor		Private
35	Deputy Chief Signal And Telecom Engineer				Northern Railway	KamalF	CA Kamal Ferwani		Government
36	Dy Fa And Cao Construction Northern Railway Charbagh				Northern Railway	KamalF	CA Kamal Ferwani		Government
37	Raj Kishore Pasi				Raj Kishore Pasi	KamalF	CA Kamal Ferwani		Private
38	Suyog Singhal HUF				SUYOG SINGHAL	KamalF	CA Ashish Kapoor	WhtAppGrp_Suyog Singhal Grp@asija	Private
39	Pawan Rathour				CA Harish Shah	AkashA	CA Gaurav Shah - Ashish Kapoor		Private
40	ASKHUNGREE ORGANIC SOLUTIONS PRIVATE LIMITED				Ashwani Mishra	ManishM	CA Ruchi Kapoor		Private
41	Wynsum Food Box LLP				Manoj Singh	KamalF	CA Kamal Ferwani	WhtAppGrp_ManojSingh GRP@Team Asija	Private
42	DC NRLM Ambedkar Nagar				DRDA Chitrakoot	KamalF	CA Kamal Ferwani		Government
43	Mahan Brick Field				Devesh Manjar	KamalF	CA Kamal Ferwani	Devesh Group@asija	Private
44	Limen Solutions Private Limited				Praveen Singh	SahilD	CA Ashish Kapoor	Praveen S GRP@Team Asija	Private
45	UP Metro Rail Corporation Ltd.				UP Metro Rail Corporation Ltd.	RohitS	CA Sunil Agarwal		Government
46	Aashirwad Welfare Society				Dinesh Vishwakarma	AkashA	CA Ashish Kapoor	CA Dinesh Vishwakarma Grp@ Team Asija	Private
47	Jai Maa Vaishno Educational Trust				Dinesh Vishwakarma	AkashA	CA Ashish Kapoor	CA Dinesh Vishwakarma Grp@ Team Asija	Private
48	Maa Pitambra Educational and Charitable Trust				Dinesh Vishwakarma	AkashA	CA Ashish Kapoor	CA Dinesh Vishwakarma Grp@ Team Asija	Private
49	Jadaun Educational Trust				Jadaun Educational Trust	AkashA	CA Akash Agarwal		Private
50	Shri Shyam Sundar Memorial Charitable Trust				Shri Shyam Sundar Memorial Charitable Trust	AkashA	CA Akash Agarwal		Private
51	Girdhargopal Agencies Private Limited				Ashish Tondon	KamalF	CA Ashish Kapoor	Girdhar Group @ Asija	Private
52	DC Drda Admin Ambedkar Nagar				DRDA Ambedkar Nagar	KamalF	CA Kamal Ferwani		Government
53	S and V Infrazone Private Limited				Arun Singh	ManishM	CS Manish Mishra		Private
54	UP State Construction and Infrastructure Development Corporation Ltd.				UPSCIDCO	KamalF	CA Ashish Kapoor		Government
55	Winstrux Global LLP				Ritesh Agarwal Grp	KamalF	CA Ashish Kapoor	Ritesh Agarwal Grp @Asija	Private
56	Spacia Ventures LLP				Piyush Kumar Singh	RohitS	CA Ashish Kapoor	WhtAppGrp_Spacia Group @ Asija	Private
57	Karam Safety Private Limited-Uttrakhand				Rajesh Nigam - Business Group	AshishK	CA Ashish Kapoor	Karam Group @ Asija	Private
58	UP Electronics Corporation Limited				UP Electronics Corporation Limited	SahilD	Kamal & Rohit		Government
59	Uttar Pradesh Building & Other Construction Workers Welfare Board - HO				UPBOCW	KamalF	CA Ashish Kapoor		Government
60	Punjab and Sind Bank Vikas Nagar				Punjab & Sind Bank	KamalF	CA Kamal Kumar Ferwani		Bank
190	SRM Agri India LLP				SRM Group	SahilD	CA Ashish Kapoor		Private
61	Clive Richard Butterfield				Butterfield	SahilD	Amit Ghai - Ashish Kapoor	Butterfield Grp @ Asija	Private
62	M/s Lucky Jewellery				BHUSHAN LAL MIDHA	RohitS	CA Rohit Singh		Private
63	Dinesh Kumar Vishwakarma				Dinesh Vishwakarma	AkashA	CA Ashish Kapoor	CA Dinesh Vishwakarma Grp@ Team Asija	Private
64	Spacia Infra and Services				Piyush Kumar Singh	RohitS	CA Ashish Kapoor	WhtAppGrp_Spacia Group @ Asija	Private
65	Juno Casting Private Limited				Rajesh Nigam - Business Group	AshishK	CA Ashish Kapoor	Karam Group @ Asija	Private
66	S. S. Infrazone Private Limited				Abhishek Singh	ManishM	CS Manish Mishra	SS_Asija	Private
67	KM Particle Boards Private Limited				Aditya Jhunjhunwala group	AkashA	CA Ashish Kapoor	Subsidy Jhunjhunwala @ Asija	Private
68	Divya Khare				Dr. Rahul Srivastava	KamalF	CA Kamal Ferwani	CA Dinesh Vishwakarma Grp@ Team Asija	Private
69	Rogi Kalyan Samiti - Dr.S.P.M.Civil Hospital				Dr. S.P.M. Civil Hospital	KamalF	CA Kamal Ferwani		Government
70	Iqbal Kidwai				Iqbal Kidwai	RohitS	CA Ashish Kapoor	Grp Iqbal Kidwai @Asija	Private
71	Awadh Aero Adventures Association				KV Singh	AshishK	CA Ashish Kapoor	WhtAppGrp_Kirti V Singh Grp @Asija	Private
72	La Martiniere College, Lucknow				La Mart	AshishK	CA Ashish Kapoor	La Martiniere Grp @ Asija	Private
73	Anant Infrazone Private Limited				Manoj Singh	KamalF	CA Kamal Ferwani	WhtAppGrp_ManojSingh GRP@Team Asija	Private
74	PS Global Consumer Healthcare Pvt .Ltd				Praveen Kumar Singh	AshishK	CA Ashish Kapoor		Private
75	Sanjivan Healthcare Enterprise Private Limited				Praveen Kumar Singh	AshishK	CA Ashish Kapoor		Private
76	Unisel Infraservices and Trade Pvt Ltd				Praveen Kumar Singh	AshishK	CA Ashish Kapoor		Private
77	Unisel Overseas India Pvt Ltd				Praveen Kumar Singh	AshishK	CA Ashish Kapoor		Private
78	State Health Society of Uttar Pradesh				State Health Society of Uttar Pradesh	KamalF	CA Ashish Kapoor		Government
79	Sarvagaya Infrapromoters LLP				SUYOG SINGHAL	KamalF	CA Ashish Kapoor	WhtAppGrp_Suyog Singhal Grp@asija	Private
80	Soham Infrapromoters Private Limited				SUYOG SINGHAL	KamalF	CA Ashish Kapoor	WhtAppGrp_Suyog Singhal Grp@asija	Private
81	Vishal Mishra				Vishal Mishra	AshishK	CA Ashish Kapoor	Grp Vishal Mishra @ Asija	Private
82	General Manager  (Fin) NHAI				NHAI	KamalF	CA Kamal Kumar Ferwani		Government
83	Airports Authority of India				Airports Authority of India	RohitS	CA Rohit Singh		Government
84	The Department of Information & Public Relation				Film Bandhu	KamalF	CA Kamal Ferwani		Government
85	BLUE BELL DR RAM TIRTH DUBE MEMORIAL SHIKSHA SANSTHAN				Blue Bell	AshishK	Ashish Kapoor- CA Naeem Khan	Grp CA Salman Akhtar @ Asija	Private
86	Sundry Departmental Debtor-Chandra Shekhar Yadav				Chandra Shekhar Yadav	KamalF	CA Ashish Kapoor	ChandraSYadav Grp @ Asija	Private
87	-Sundry Departmental Debtor-Dinesh Kumar Vishwakarma				Dinesh Vishwakarma	AkashA	CA Ashish Kapoor	CA Dinesh Vishwakarma Grp@ Team Asija	Private
88	Sundry Departmental Debtor - NADT Lucknow				NADT	AshishK			Government
89	Sundry Departmental Debtor-Nitin Singh				Nitin Singh MVVNL	KamalF	CA Ashish Kapoor		Private
90	United Nations Development Programme- Afganistan				UNDP - Afghanistan	SahilD	CA Ashish Kapoor		Government
91	BKS MyGold Private Limited				Amol Bansal	SahilD	CA Ashish Kapoor	Amol Bansal Grp	Private
92	Sri Durga Bansal Fertilizer Limited				Amol Bansal	SahilD	CA Ashish Kapoor	Amol Bansal Grp	Private
93	Vartika Raina				Ashish Raina	AkashA	CA Ashish Kapoor	Ashish Raina Group @ Asija	Private
94	Faizane Madina Agra Society				Minhaz	AkashA	CA Musheer Alam Khan - Ashish	WhtAppGrp_CA Tahseen Hussain	Private
95	Indian Blind and Para Judo Association				Munawar Anzar	SahilD	CA Ashish Kapoor	Munawar Sir Clt Grp @ Asija	Private
96	Dream De Tourz LLP				Praveen Kumar Singh	AshishK	CA Ashish Kapoor		Private
97	Punjab And Sind Bank				Punjab & Sind Bank	KamalF	CA Kamal Kumar Ferwani		Bank
98	Reflectosafe India LLP				Rajesh Nigam - Business Group	AshishK	CA Ashish Kapoor	Karam Group @ Asija	Private
99	Unix Enterprises Private Limited				T Ram	KamalF	CA Ashish Kapoor	Ct. T. Ram Grp @ Asija	Private
100	DC MGNREGA Ambedkar Nagar				DRDA Ambedkar Nagar	KamalF	CA Kamal Ferwani		Government
101	Rajat Singh				T Ram	KamalF	CA Ashish Kapoor	Ct. T. Ram Grp @ Asija	Private
102	Vidit Advertising				Shrawan Bhargava	RohitS	CA Ashish Kapoor	Vidit Advertising @Asija	Private
103	Arif Care Foundation				Arif Group	SahilD	CA Ashish Kapoor		Private
104	SHG For Bareilly Self Employed Women Awareness				Raj Kishore Pasi	KamalF	CA Kamal Ferwani		Private
105	B K Saraf Private Limited				Amol Bansal	SahilD	CA Ashish Kapoor	Amol Bansal Grp	Private
106	B.K. Girijadevi Investment Private Limited				Amol Bansal	SahilD	CA Ashish Kapoor	Amol Bansal Grp	Private
107	Chillies N Lemon Infra & Hospitality LLP				Amol Bansal	SahilD	CA Ashish Kapoor	Amol Bansal Grp	Private
108	Spectrum Venture International Private Limited				Amol Bansal	SahilD	CA Ashish Kapoor	Amol Bansal Grp	Private
109	Indian Institute Of Management Lucknow				IIM-L	KamalF	CA Ashish Kapoor		Government
110	St Teresas Day School And College Society				Peter Fanthome	AshishK	CA Ashish Kapoor	Peter Fanthom Grp @ Asija	Private
111	Prateek Kumar Singh				Praveen Kumar Singh	AshishK	CA Ashish Kapoor		Private
112	Ratnawali Singh				Praveen Kumar Singh	AshishK	CA Ashish Kapoor		Private
113	Pavaki Infrasolutions LLP				Praveen Singh	SahilD	CA Ashish Kapoor	Praveen S GRP@Team Asija	Private
114	Karam Safety Private Limited - Lucknow				Rajesh Nigam - Business Group	AshishK	CA Ashish Kapoor	Karam Group @ Asija	Private
115	PN Safetech Private Limited-Uttar Pradesh				Rajesh Nigam - Business Group	AshishK	CA Ashish Kapoor	Karam Group @ Asija	Private
116	Shri Ramswaroop Multi Engineering Solutions Private Limited				SRM Group	SahilD	CA Ashish Kapoor	SRM Grp @ Team Asija	Private
117	UNICEF Office For Uttar Pradesh				UNICEF	RohitS	Ashish Kapoor-RM		Government
118	Manjil Prerna Sankul Samiti				UPSRLM	KamalF	Kamal Kumar Ferwani		Government
119	Vikas Prerna Sankul Samiti				UPSRLM	KamalF	Kamal Kumar Ferwani		Government
120	SSCC Constructions Private Limited - UP				Vivek Jaiswal	SahilD	CA Ashish Kapoor	WhtAppGrp_Vivek Jaiswal Grp @Asija	Private
121	Asija & Associates LLP				Ashish Kapoor	RuchiK	CA Ashish Kapoor		Private
122	ICICI Bank Limited - Mahanagar Branch				ICICI Bank	KamalF	CA Ashish		Bank
123	ICICI Bank Limited-Hazratganj Branch				ICICI Bank	KamalF	CA Ashish		Bank
124	Northern Coalfields Limited , Dudhichua				Northern Coalfields Limited , Dudhichua	KamalF	CA Kamal Ferwani		Government
125	Sundry Departmental Debtor - Jalsa Resort				Rajendra Singh	KamalF	CA Ashish Kapoor	Jalsa Group @ Asija	Private
126	Visdem Partners				Vikram Behari Kaushal	AkashA	CA Ashish Kapoor		Private
127	Shamsher Bahadur Singh Memorial Trust				Virendra Ojha IRS	AshishK	CA Ashish Kapoor	KP Singh Grp @ Asija	Private
128	Sundry Departmental Debtor - Brijesh Kumar				Brijesh	AshishK	CA Ashish Kapoor		Private
129	Invest UP				Invest UP	RohitS	CA Rohit Singh		Government
130	Uniform Ventures Private Limited				Uniform Venture	AshishK	CA Ashish Kapoor		Private
131	Gharda Chemicals Limited				Gharda Group	RohitS	CA. Rohit Singh		Private
132	Central Bank of India-Bhopal				Central Bank of India	KamalF	CA Ashish Kapoor		Bank
133	Punjab & Sind Bank HO				Punjab & Sind Bank	KamalF	CA Kamal Kumar Ferwani		Bank
134	Uttar Pradesh Gramin Bank				Uttar Pradesh Gramin Bank	KamalF	CA Kamal Kumar Ferwani		Bank
135	KM Vyapar Limited				Aditya Jhunjhunwala group	AkashA	CA Ashish Kapoor	Subsidy Jhunjhunwala @ Asija	Private
136	Gobind Industries Pvt.Ltd.				Gobind Industries	KamalF	CA Kamal Ferwani		Private
137	UNICEF State Office for Bihar				UNICEF	RohitS	Ashish Kapoor-RM		Government
138	Dy. Chief Accounts Officer, Krishna Nagar, MVVNL				MVVNL	KamalF	CA Ashish Kapoor		Government
139	BR Autoventures Private Limited				TATA Motors Passenger Vehicle Limited	AshishK			Private
140	GM (Internal Audit), NTPC Ltd.				NTPC-IA	KamalF	CA Kamal Kumar Ferwani		Government
141	Agriculture Insurance Company of India Limited				AICIL	KamalF	CA Kamal Ferwani		Government
142	Bank of India- Terhi Pulia				Bank of India	KamalF	CA Kamal Ferwani		Bank
143	ICICI Bank Limited - Kanpur Branch				ICICI Bank	KamalF	CA Ashish		Bank
144	S R M Motors Private Limited				TATA Motors Passenger Vehicle Limited	AshishK			Private
145	Shree Constructions And Leisure Private Limited				Shree Constructions And Leisure Private Limited	ManishM	CS Manish Mishra		Private
146	Takshvi Infraprojects Private Limited				Ritesh Agarwal Grp	KamalF	CA Ashish Kapoor	Ritesh Agarwal Grp @Asija	Private
147	Sharp Technoengineers Private Limited				Sharp	SahilD	CA Ashish Kapoor		Private
148	Ensky Ventures Private Limited				Tariq Sheikh	SahilD	CA Ashish Kapoor		Private
149	Green Gas Limited				Green Gas Limited	KamalF	CA Kamal Ferwani		Government
150	Apex Autosales Private Limited				Mohd. Islam	KamalF	CA Kamal Ferwani		Private
151	Saurabh Bhandari				Saurabh Bhandari	RohitS	CA Ashish Kapoor	Bhandari Group @ Asija	Private
152	Gaurav Bhandari				Saurabh Bhandari	RohitS	CA Ashish Kapoor	Bhandari Group @ Asija	Private
153	Karam Safety Private Limited-Uttar Pradesh				Rajesh Nigam - Business Group	AshishK	CA Ashish Kapoor	Karam Group @ Asija	Private
154	Technomed Devices India Private Limited				Rishi Agarwal Yi	AshishK	CA Ashish Kapoor		Private
155	UNICEF Maharashtra				UNICEF	RohitS	Ashish Kapoor-RM		Government
156	UNICEF Office For New Delhi				UNICEF	RohitS	Ashish Kapoor-RM		Government
157	Surcoat Paints Private Limited				SUYOG SINGHAL	KamalF	CA Ashish Kapoor		Private
158	Nivah Hospitality LLP				Nivah Hospitality LLP	AshishK	Ashish Kapoor		Private
159	Sundry Departmental Debtor - NADT Ahmadabad				NADT	AshishK			Government
160	Puneet Auto Sales Private Limited				TATA Motors Passenger Vehicle Limited	AshishK			Private
161	Puneet Auto Sales  Private Limited				TATA Motors Passenger Vehicle Limited	AshishK			Private
162	Seven Autocorp Private Limited				TATA Motors Passenger Vehicle Limited	AshishK			Private
163	SSBB Infra and Services Private Limited				Praveen Singh	SahilD	CA Ashish Kapoor		Private
164	United Nations Children's Fund-Senegal				United Nation - Global	SahilD	Ashish Kapoor		Government
165	A B Trading				Yogesh Bhatia	SahilD	CA Sahil Dua		Private
166	Abhijeet Foundation				Bivash Sarcar	AkashA	CA Akash Agarwal		Private
167	Arya Vardhan Foundation				Rajendra Singh	KamalF	CA Ashish Kapoor		Private
168	Avadhraj Energy Private Limited				Abhishek Sarraf	SahilD	CA Ashish Kapoor		Private
169	BKS MYJEWELS PRIVATE LIMITED				Amol Bansal	SahilD	CA Ashish Kapoor		Private
170	Brij Bhushan Ventures LLP				Rohit Agarwal	AshishK	CA Ashish Kapoor		Private
171	CNL Health LLP				Amol Bansal	SahilD	CA Ashish Kapoor		Private
172	Jalsa Resorts (India) Private Limited				Rajendra Singh	KamalF	CA Ashish Kapoor		Private
173	Janardan Singh				Shardul Singh	AkashA	CA Akash Agarwal		Private
174	Jesus & Mary Play School Balarampur				Butterfield	SahilD	Amit Ghai - Ashish Kapoor		Private
175	Jyoti Exports Limited				Amol Bansal	SahilD	CA Ashish Kapoor		Private
176	K.N. Associates				K.N Associates	AkashA	CA Ashish Kapoor		Private
177	Lobo Tailors LLP				Lobo	ManishM	CS Manish Mishra		Private
178	Murad Ventures Private Limited				Tariq Sheikh	SahilD	CA Ashish Kapoor		Private
179	P.S.Enterprises				Praveen Kumar Singh	AshishK	CA Ashish Kapoor		Private
180	Rajesh Nigam Family Private Trust				Rajesh Nigam - Business Group	AshishK	CA Ashish Kapoor		Private
181	Rajeshwari Welfare Foundation				Jai Shanker Mishra	KamalF	CA Ashish Kapoor		Private
182	Republic Motors				Tariq Sheikh	SahilD	CA Ashish Kapoor		Private
183	Sachin Shukla				Sachin Shukla	CRP-AkashA	CA Akash Agarwal		Private
184	Saurabh Mehrotra				Saurabh Mehrotra	AshishK	CA Ashish Kapoor		Private
185	SBSB Infratech Private Limited				Amol Bansal	SahilD	CA Ashish Kapoor		Private
186	Shaivya Minerals And Stones Llp				Abhishek Singh	ManishM	CS Manish Mishra		Private
187	Shiv Lok Dham Trust				Dhaon	AkashA	CA Ashish Kapoor		Private
188	Shravendra Ji				Shravendra Ji	AshishK	CA Ashish Kapoor		Private
189	Sprinters Capital LLP				SRM Group	SahilD	CA Ashish Kapoor		Private
191	St. Teresa's Day School				Peter Fanthome	AshishK	CA Ashish Kapoor		Private
192	Stellar Cables & Infrastructure Private Limited				Anand Gupta	ManishM	CA Ashish Kapoor		Private
193	Structural Insulation and Glazing Company Private Limited				Mohammad Ahmad	CRP-SahilD	CA Ashish Kapoor		Private
194	Subhash Bhandari Memorial Foundation				Saurabh Bhandari	RohitS	CA Ashish Kapoor		Private
195	Supriya Choudhary				Supriya Choudhary	AkashA	CA Ashish Kapoor		Private
196	Suyash Bansal				Rajeev Bansal	KamalF	CA Ashish Kapoor		Private
197	The Nirman Tirth South Point School And Vidyashram				Nirman Tirth	CRP- AshishK	CA Ashish Kapoor		Private
198	Tirwa Farms LLP				Tirwa	ManishM	CA Ashish Kapoor		Private
199	U.P.Sainik Punarvas Nidhi				UPSPN	AkashA	CA Kamal Ferwani		Private
200	Unifarma Diagnostics and Research Center				Praveen Kumar Singh	AshishK	CA Ashish Kapoor		Private
201	Vinod Sukhwani				Vinod Sukhwani_01-Apr-2019	CRP-AshishK	CA Ashish Kapoor		Private
202	Vishesh Traders				Vivek Jaiswal	SahilD	CA Ashish Kapoor		Private
203	VS Trading Co				Vivek Jaiswal	SahilD	CA Ashish Kapoor		Private
204	Yogendra Samir Yadav				Yogendra Samir Yadav	AshishK	CA Ashish Kapoor		Private
205	Pathjyoti Edumarg LLP				Virendra Ojha IRS	AshishK	CA Ashish Kapoor		Private
206	SN Trustees LLP				Rajesh Nigam - Business Group	AshishK	CA Ashish Kapoor		Private
207	Tiranga Prerna Clf				UPSRLM	KamalF	Kamal Kumar Ferwani		Government
208	Sundry Departmental Debtor- UP State Tax				UP State Tax	RohitS	CA Rohit Singh		Government
209	aaaaa								
210	abcd								
\.


--
-- Data for Name: crp_master; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.crp_master (id, crp_name, created_at, updated_at) FROM stdin;
1	SahilD	2026-06-11 09:41:18	\N
2	ManishM	2026-06-11 09:41:18	\N
3	AkashA	2026-06-11 09:41:18	\N
4	KamalF	2026-06-11 09:41:18	\N
5	RohitS	2026-06-11 09:41:18	\N
6	RuchiK	2026-06-11 09:41:18	\N
7	AshishK	2026-06-11 09:41:18	\N
8	CRP-SahilD	2026-06-11 09:41:18	\N
9	CRP- AshishK	2026-06-11 09:41:18	\N
10	CRP-AkashA	2026-06-11 09:41:18	\N
11	CRP-AshishK	2026-06-11 09:41:18	\N
\.


--
-- Data for Name: debtor_import_client_errors; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.debtor_import_client_errors (id, batch_id, imported_at, party_name, firm_names, bill_count, total_amount, sample_ref_nos) FROM stdin;
1	20260609161707818720	2026-06-09 16:17:07	CNL Health LLP	AAAFC	1	3550	AAAFC/26-27/Corpl/0008
2	20260609161707818720	2026-06-09 16:17:07	Lobo Tailors LLP	AAAFC	1	3550	AAAFC/26-27/Corpl/0006
3	20260609161707818720	2026-06-09 16:17:07	SRM Agri India LLP	AAAFC	1	3550	AAAFC/26-27/Corpl/0007
4	20260609161707818720	2026-06-09 16:17:07	Tirwa Farms LLP	AAAFC	1	3550	AAAFC/26-27/Corpl/0005
5	20260609161707818720	2026-06-09 16:17:07	Abhijeet Foundation	AAAFC	1	3500	AAAFC/26-27/AA/0016
6	20260609161707818720	2026-06-09 16:17:07	Arya Vardhan Foundation	AAAFC	1	4560	AAAFC/26-27/AA/0011
7	20260609161707818720	2026-06-09 16:17:07	Janardan Singh	AAAFC	1	10000	AAAFC/26-27/AA/0020
8	20260609161707818720	2026-06-09 16:17:07	Rajeshwari Welfare Foundation	AAAFC	1	780	AAAFC/26-27/AA/0013
9	20260609161707818720	2026-06-09 16:17:07	Sachin Shukla	AAAFC	1	12500	AAAFC/26-27/AA/0021
10	20260609161707818720	2026-06-09 16:17:07	Shiv Lok Dham Trust	AAAFC	1	3500	AAAFC/26-27/AA/0015
11	20260609161707818720	2026-06-09 16:17:07	Shravendra Ji	AAAFC	1	1000	AAAFC/26-27/AA/0019
12	20260609161707818720	2026-06-09 16:17:07	Subhash Bhandari Memorial Foundation	AAAFC	1	4000	AAAFC/26-27/AA/0014
13	20260609161707818720	2026-06-09 16:17:07	Supriya Choudhary	AAAFC	1	3000	AAAFC/26-27/AA/0018
14	20260609161707818720	2026-06-09 16:17:07	Vinod Sukhwani	AAAFC	1	25000	AAAFC/26-27/AA/0017
15	20260609185046177457	2026-06-09 18:50:46	Pathjyoti Edumarg LLP	Manish Mishra And Assocaites	1	3590	MMA/26-27/CL/006
16	20260609185046177457	2026-06-09 18:50:46	SN Trustees LLP	Manish Mishra And Assocaites	1	4180	MMA/26-27/CL/008
\.


--
-- Data for Name: debtor_nav_access; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.debtor_nav_access (user_email, access_key) FROM stdin;
pratibha@asija.in	import_tally_debtors
pratibha@asija.in	executive_partner_master_view
pratibha@asija.in	import_tally_receipts
pratibha@asija.in	firm_master_view
pratibha@asija.in	executive_partner_master_edit
pratibha@asija.in	import_tally_receipts_view
pratibha@asija.in	download_report_excel
pratibha@asija.in	run_followup_logic
pratibha@asija.in	client_master_view
pratibha@asija.in	client_master_edit
\.


--
-- Data for Name: deleted_records_log; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.deleted_records_log (id, source_table, source_pk, display_type, display_label, display_summary, payload_json, deleted_at, deleted_by, restore_status, restored_at, restored_by) FROM stdin;
1	billing_report	885	Billing Report	B K Saraf Private Limited	AAA LLP | 2026-06-10 | HO/26-27/AA/0012 | Rs 10,608	{"id": 885, "firm_name": "Asija And Associates LLP", "short_name": "AAA LLP", "bill_date": "2026-06-10", "ref_no": "HO/26-27/AA/0012", "party_name": "B K Saraf Private Limited", "amount": 10608.0, "due_date": "2026-07-10", "overdue_days": 1, "ep_override": "AkashA", "receipt_status": "open", "paid_amount": 0.0, "closed_at": null, "group_override": "", "followup_partner": "SahilD", "deleted_at": null, "deleted_by": null, "delete_reason": null, "import_batch_id": null}	2026-06-11 18:29:13	arif.siddiqui@asija.in	deleted	\N	\N
2	billing_report	884	Billing Report	B.K. Girijadevi Investment Private Limited	AAA LLP | 2026-06-10 | HO/26-27/AA/0013 | Rs 2,396	{"id": 884, "firm_name": "Asija And Associates LLP", "short_name": "AAA LLP", "bill_date": "2026-06-10", "ref_no": "HO/26-27/AA/0013", "party_name": "B.K. Girijadevi Investment Private Limited", "amount": 2396.0, "due_date": "2026-07-10", "overdue_days": 1, "ep_override": "AkashA", "receipt_status": "open", "paid_amount": 0.0, "closed_at": null, "group_override": "", "followup_partner": "SahilD", "deleted_at": null, "deleted_by": null, "delete_reason": null, "import_batch_id": null}	2026-06-11 18:29:13	arif.siddiqui@asija.in	deleted	\N	\N
3	billing_report	886	Billing Report	BKS MyGold Private Limited	AAA LLP | 2026-06-10 | HO/26-27/AA/0014 | Rs 5,050	{"id": 886, "firm_name": "Asija And Associates LLP", "short_name": "AAA LLP", "bill_date": "2026-06-10", "ref_no": "HO/26-27/AA/0014", "party_name": "BKS MyGold Private Limited", "amount": 5050.0, "due_date": "2026-07-10", "overdue_days": 1, "ep_override": "AkashA", "receipt_status": "open", "paid_amount": 0.0, "closed_at": null, "group_override": "", "followup_partner": "SahilD", "deleted_at": null, "deleted_by": null, "delete_reason": null, "import_batch_id": null}	2026-06-11 18:29:13	arif.siddiqui@asija.in	deleted	\N	\N
4	billing_report	888	Billing Report	Bks Myvault Private Limited	AAA LLP | 2026-06-10 | HO/26-27/AA/0015 | Rs 2,538	{"id": 888, "firm_name": "Asija And Associates LLP", "short_name": "AAA LLP", "bill_date": "2026-06-10", "ref_no": "HO/26-27/AA/0015", "party_name": "Bks Myvault Private Limited", "amount": 2538.0, "due_date": "2026-07-10", "overdue_days": 1, "ep_override": "AkashA", "receipt_status": "open", "paid_amount": 0.0, "closed_at": null, "group_override": "", "followup_partner": "SahilD", "deleted_at": null, "deleted_by": null, "delete_reason": null, "import_batch_id": null}	2026-06-11 18:29:13	arif.siddiqui@asija.in	deleted	\N	\N
5	billing_report	889	Billing Report	Chillies N Lemon Infra & Hospitality LLP	AAA LLP | 2026-06-10 | HO/26-27/AA/0016 | Rs 2,124	{"id": 889, "firm_name": "Asija And Associates LLP", "short_name": "AAA LLP", "bill_date": "2026-06-10", "ref_no": "HO/26-27/AA/0016", "party_name": "Chillies N Lemon Infra & Hospitality LLP", "amount": 2124.0, "due_date": "2026-07-10", "overdue_days": 1, "ep_override": "AkashA", "receipt_status": "open", "paid_amount": 0.0, "closed_at": null, "group_override": "", "followup_partner": "SahilD", "deleted_at": null, "deleted_by": null, "delete_reason": null, "import_batch_id": null}	2026-06-11 18:29:13	arif.siddiqui@asija.in	deleted	\N	\N
6	billing_report	895	Billing Report	Jyoti Exports Limited	AAA LLP | 2026-06-10 | HO/26-27/AA/0020 | Rs 4,732	{"id": 895, "firm_name": "Asija And Associates LLP", "short_name": "AAA LLP", "bill_date": "2026-06-10", "ref_no": "HO/26-27/AA/0020", "party_name": "Jyoti Exports Limited", "amount": 4732.0, "due_date": "2026-07-10", "overdue_days": 1, "ep_override": "AkashA", "receipt_status": "open", "paid_amount": 0.0, "closed_at": null, "group_override": "", "followup_partner": "SahilD", "deleted_at": null, "deleted_by": null, "delete_reason": null, "import_batch_id": null}	2026-06-11 18:29:13	arif.siddiqui@asija.in	deleted	\N	\N
7	billing_report	909	Billing Report	Spectrum Venture International Private Limited	AAA LLP | 2026-06-10 | HO/26-27/AA/0008 | Rs 27,424	{"id": 909, "firm_name": "Asija And Associates LLP", "short_name": "AAA LLP", "bill_date": "2026-06-10", "ref_no": "HO/26-27/AA/0008", "party_name": "Spectrum Venture International Private Limited", "amount": 27424.0, "due_date": "2026-07-10", "overdue_days": -1, "ep_override": null, "receipt_status": "open", "paid_amount": 0.0, "closed_at": null, "group_override": null, "followup_partner": "SahilD", "deleted_at": null, "deleted_by": null, "delete_reason": null, "import_batch_id": null}	2026-06-11 18:29:13	arif.siddiqui@asija.in	deleted	\N	\N
8	billing_report	892	Billing Report	Girdhargopal Agencies Private Limited	AAA LLP | 2026-06-10 | HO/26-27/AA/0018 | Rs 1,806	{"id": 892, "firm_name": "Asija And Associates LLP", "short_name": "AAA LLP", "bill_date": "2026-06-10", "ref_no": "HO/26-27/AA/0018", "party_name": "Girdhargopal Agencies Private Limited", "amount": 1806.0, "due_date": "2026-07-10", "overdue_days": 1, "ep_override": "AkashA", "receipt_status": "open", "paid_amount": 0.0, "closed_at": null, "group_override": "", "followup_partner": "KamalF", "deleted_at": null, "deleted_by": null, "delete_reason": null, "import_batch_id": null}	2026-06-11 18:29:13	arif.siddiqui@asija.in	deleted	\N	\N
9	billing_report	894	Billing Report	Jesus & Mary Play School Balarampur	AAA LLP | 2026-06-10 | HO/26-27/AA/0004 | Rs 21,664	{"id": 894, "firm_name": "Asija And Associates LLP", "short_name": "AAA LLP", "bill_date": "2026-06-10", "ref_no": "HO/26-27/AA/0004", "party_name": "Jesus & Mary Play School Balarampur", "amount": 21664.0, "due_date": "2026-07-10", "overdue_days": -1, "ep_override": null, "receipt_status": "open", "paid_amount": 0.0, "closed_at": null, "group_override": null, "followup_partner": "AkashA", "deleted_at": null, "deleted_by": null, "delete_reason": null, "import_batch_id": null}	2026-06-11 18:29:13	arif.siddiqui@asija.in	deleted	\N	\N
10	billing_report	898	Billing Report	K.N. Associates	AAA LLP | 2026-06-10 | HO/26-27/AA/0030 | Rs 2,088	{"id": 898, "firm_name": "Asija And Associates LLP", "short_name": "AAA LLP", "bill_date": "2026-06-10", "ref_no": "HO/26-27/AA/0030", "party_name": "K.N. Associates", "amount": 2088.0, "due_date": "2026-07-10", "overdue_days": -1, "ep_override": null, "receipt_status": "open", "paid_amount": 0.0, "closed_at": null, "group_override": null, "followup_partner": "AkashA", "deleted_at": null, "deleted_by": null, "delete_reason": null, "import_batch_id": null}	2026-06-11 18:29:13	arif.siddiqui@asija.in	deleted	\N	\N
11	billing_report	899	Billing Report	La Martiniere College, Lucknow	AAA LLP | 2026-06-10 | HO/26-27/AA/0005 | Rs 21,830	{"id": 899, "firm_name": "Asija And Associates LLP", "short_name": "AAA LLP", "bill_date": "2026-06-10", "ref_no": "HO/26-27/AA/0005", "party_name": "La Martiniere College, Lucknow", "amount": 21830.0, "due_date": "2026-07-10", "overdue_days": -1, "ep_override": null, "receipt_status": "open", "paid_amount": 0.0, "closed_at": null, "group_override": null, "followup_partner": "RohitS", "deleted_at": null, "deleted_by": null, "delete_reason": null, "import_batch_id": null}	2026-06-11 18:29:13	arif.siddiqui@asija.in	deleted	\N	\N
12	billing_report	891	Billing Report	Faizane Madina Agra Society	AAA LLP | 2026-06-10 | HO/26-27/AA/0036 | Rs 17,700	{"id": 891, "firm_name": "Asija And Associates LLP", "short_name": "AAA LLP", "bill_date": "2026-06-10", "ref_no": "HO/26-27/AA/0036", "party_name": "Faizane Madina Agra Society", "amount": 17700.0, "due_date": "2026-07-10", "overdue_days": -1, "ep_override": null, "receipt_status": "open", "paid_amount": 0.0, "closed_at": null, "group_override": null, "followup_partner": "AkashA", "deleted_at": null, "deleted_by": null, "delete_reason": null, "import_batch_id": null}	2026-06-11 18:29:13	arif.siddiqui@asija.in	deleted	\N	\N
13	billing_report	914	Billing Report	St. Teresa's Day School	AAA LLP | 2026-06-10 | HO/26-27/AA/0009 | Rs 5,900	{"id": 914, "firm_name": "Asija And Associates LLP", "short_name": "AAA LLP", "bill_date": "2026-06-10", "ref_no": "HO/26-27/AA/0009", "party_name": "St. Teresa's Day School", "amount": 5900.0, "due_date": "2026-07-10", "overdue_days": -1, "ep_override": null, "receipt_status": "open", "paid_amount": 0.0, "closed_at": null, "group_override": null, "followup_partner": "SahilD", "deleted_at": null, "deleted_by": null, "delete_reason": null, "import_batch_id": null}	2026-06-11 18:29:13	arif.siddiqui@asija.in	deleted	\N	\N
14	billing_report	908	Billing Report	Spacia Ventures LLP	AAA LLP | 2026-06-10 | HO/26-27/AA/0038 | Rs 1,806	{"id": 908, "firm_name": "Asija And Associates LLP", "short_name": "AAA LLP", "bill_date": "2026-06-10", "ref_no": "HO/26-27/AA/0038", "party_name": "Spacia Ventures LLP", "amount": 1806.0, "due_date": "2026-07-10", "overdue_days": -1, "ep_override": null, "receipt_status": "open", "paid_amount": 0.0, "closed_at": null, "group_override": null, "followup_partner": "RohitS", "deleted_at": null, "deleted_by": null, "delete_reason": null, "import_batch_id": null}	2026-06-11 18:29:13	arif.siddiqui@asija.in	deleted	\N	\N
15	billing_report	901	Billing Report	Pavaki Infrasolutions LLP	AAA LLP | 2026-06-10 | HO/26-27/AA/0032 | Rs 6,302	{"id": 901, "firm_name": "Asija And Associates LLP", "short_name": "AAA LLP", "bill_date": "2026-06-10", "ref_no": "HO/26-27/AA/0032", "party_name": "Pavaki Infrasolutions LLP", "amount": 6302.0, "due_date": "2026-07-10", "overdue_days": -1, "ep_override": null, "receipt_status": "open", "paid_amount": 0.0, "closed_at": null, "group_override": null, "followup_partner": "SahilD", "deleted_at": null, "deleted_by": null, "delete_reason": null, "import_batch_id": null}	2026-06-11 18:29:13	arif.siddiqui@asija.in	deleted	\N	\N
16	billing_report	916	Billing Report	Suyash Bansal	AAA LLP | 2026-06-10 | HO/26-27/AA/0036 | Rs 2,396	{"id": 916, "firm_name": "Asija And Associates LLP", "short_name": "AAA LLP", "bill_date": "2026-06-10", "ref_no": "HO/26-27/AA/0036", "party_name": "Suyash Bansal", "amount": 2396.0, "due_date": "2026-07-10", "overdue_days": -1, "ep_override": null, "receipt_status": "open", "paid_amount": 0.0, "closed_at": null, "group_override": null, "followup_partner": "AkashA", "deleted_at": null, "deleted_by": null, "delete_reason": null, "import_batch_id": null}	2026-06-11 18:29:13	arif.siddiqui@asija.in	deleted	\N	\N
17	billing_report	893	Billing Report	Jalsa Resorts (India) Private Limited	AAA LLP | 2026-06-10 | HO/26-27/AA/0027 | Rs 1,948	{"id": 893, "firm_name": "Asija And Associates LLP", "short_name": "AAA LLP", "bill_date": "2026-06-10", "ref_no": "HO/26-27/AA/0027", "party_name": "Jalsa Resorts (India) Private Limited", "amount": 1948.0, "due_date": "2026-07-10", "overdue_days": -1, "ep_override": null, "receipt_status": "open", "paid_amount": 0.0, "closed_at": null, "group_override": null, "followup_partner": "AkashA", "deleted_at": null, "deleted_by": null, "delete_reason": null, "import_batch_id": null}	2026-06-11 18:29:13	arif.siddiqui@asija.in	deleted	\N	\N
18	billing_report	896	Billing Report	Karam Safety Private Limited-ISD	AAA LLP | 2026-06-10 | HO/26-27/AA/0034 | Rs 82,600	{"id": 896, "firm_name": "Asija And Associates LLP", "short_name": "AAA LLP", "bill_date": "2026-06-10", "ref_no": "HO/26-27/AA/0034", "party_name": "Karam Safety Private Limited-ISD", "amount": 82600.0, "due_date": "2026-07-10", "overdue_days": -1, "ep_override": null, "receipt_status": "open", "paid_amount": 0.0, "closed_at": null, "group_override": null, "followup_partner": "RohitS", "deleted_at": null, "deleted_by": null, "delete_reason": null, "import_batch_id": null}	2026-06-11 18:29:13	arif.siddiqui@asija.in	deleted	\N	\N
19	billing_report	897	Billing Report	Karam Safety Private Limited-Uttrakhand	AAA LLP | 2026-06-10 | HO/26-27/AA/0001 | Rs 47,200	{"id": 897, "firm_name": "Asija And Associates LLP", "short_name": "AAA LLP", "bill_date": "2026-06-10", "ref_no": "HO/26-27/AA/0001", "party_name": "Karam Safety Private Limited-Uttrakhand", "amount": 47200.0, "due_date": "2026-07-10", "overdue_days": -1, "ep_override": null, "receipt_status": "open", "paid_amount": 0.0, "closed_at": null, "group_override": null, "followup_partner": "RohitS", "deleted_at": null, "deleted_by": null, "delete_reason": null, "import_batch_id": null}	2026-06-11 18:29:13	arif.siddiqui@asija.in	deleted	\N	\N
20	billing_report	902	Billing Report	Rajesh Nigam Family Private Trust	AAA LLP | 2026-06-10 | HO/26-27/AA/0010 | Rs 18,880	{"id": 902, "firm_name": "Asija And Associates LLP", "short_name": "AAA LLP", "bill_date": "2026-06-10", "ref_no": "HO/26-27/AA/0010", "party_name": "Rajesh Nigam Family Private Trust", "amount": 18880.0, "due_date": "2026-07-10", "overdue_days": -1, "ep_override": null, "receipt_status": "open", "paid_amount": 0.0, "closed_at": null, "group_override": null, "followup_partner": "RohitS", "deleted_at": null, "deleted_by": null, "delete_reason": null, "import_batch_id": null}	2026-06-11 18:29:13	arif.siddiqui@asija.in	deleted	\N	\N
21	billing_report	905	Billing Report	Saurabh Mehrotra	AAA LLP | 2026-06-10 | HO/26-27/AA/0002 | Rs 2,950	{"id": 905, "firm_name": "Asija And Associates LLP", "short_name": "AAA LLP", "bill_date": "2026-06-10", "ref_no": "HO/26-27/AA/0002", "party_name": "Saurabh Mehrotra", "amount": 2950.0, "due_date": "2026-07-10", "overdue_days": -1, "ep_override": null, "receipt_status": "open", "paid_amount": 0.0, "closed_at": null, "group_override": null, "followup_partner": "AkashA", "deleted_at": null, "deleted_by": null, "delete_reason": null, "import_batch_id": null}	2026-06-11 18:29:13	arif.siddiqui@asija.in	deleted	\N	\N
22	billing_report	919	Billing Report	Vidit Advertising	AAA LLP | 2026-06-10 | HO/26-27/AA/0044 | Rs 2,430	{"id": 919, "firm_name": "Asija And Associates LLP", "short_name": "AAA LLP", "bill_date": "2026-06-10", "ref_no": "HO/26-27/AA/0044", "party_name": "Vidit Advertising", "amount": 2430.0, "due_date": "2026-07-10", "overdue_days": -1, "ep_override": null, "receipt_status": "open", "paid_amount": 0.0, "closed_at": null, "group_override": null, "followup_partner": "RohitS", "deleted_at": null, "deleted_by": null, "delete_reason": null, "import_batch_id": null}	2026-06-11 18:29:13	arif.siddiqui@asija.in	deleted	\N	\N
23	billing_report	911	Billing Report	State Health Society of Uttar Pradesh	AAA LLP | 2026-06-10 | HO/26-27/AA/0012 | Rs 55,224	{"id": 911, "firm_name": "Asija And Associates LLP", "short_name": "AAA LLP", "bill_date": "2026-06-10", "ref_no": "HO/26-27/AA/0012", "party_name": "State Health Society of Uttar Pradesh", "amount": 55224.0, "due_date": "2026-07-10", "overdue_days": -1, "ep_override": null, "receipt_status": "open", "paid_amount": 0.0, "closed_at": null, "group_override": null, "followup_partner": "PrademnP-X", "deleted_at": null, "deleted_by": null, "delete_reason": null, "import_batch_id": null}	2026-06-11 18:29:13	arif.siddiqui@asija.in	deleted	\N	\N
24	billing_report	912	Billing Report	State Health Society of Uttar Pradesh	AAA LLP | 2026-06-10 | HO/26-27/AA/0035 | Rs 92,040	{"id": 912, "firm_name": "Asija And Associates LLP", "short_name": "AAA LLP", "bill_date": "2026-06-10", "ref_no": "HO/26-27/AA/0035", "party_name": "State Health Society of Uttar Pradesh", "amount": 92040.0, "due_date": "2026-07-10", "overdue_days": -1, "ep_override": null, "receipt_status": "open", "paid_amount": 0.0, "closed_at": null, "group_override": null, "followup_partner": "PrademnP-X", "deleted_at": null, "deleted_by": null, "delete_reason": null, "import_batch_id": null}	2026-06-11 18:29:13	arif.siddiqui@asija.in	deleted	\N	\N
25	billing_report	904	Billing Report	Sarvagaya Infrapromoters LLP	AAA LLP | 2026-06-10 | HO/26-27/AA/0035 | Rs 1,806	{"id": 904, "firm_name": "Asija And Associates LLP", "short_name": "AAA LLP", "bill_date": "2026-06-10", "ref_no": "HO/26-27/AA/0035", "party_name": "Sarvagaya Infrapromoters LLP", "amount": 1806.0, "due_date": "2026-07-10", "overdue_days": -1, "ep_override": null, "receipt_status": "open", "paid_amount": 0.0, "closed_at": null, "group_override": null, "followup_partner": "KamalF", "deleted_at": null, "deleted_by": null, "delete_reason": null, "import_batch_id": null}	2026-06-11 18:29:13	arif.siddiqui@asija.in	deleted	\N	\N
26	billing_report	907	Billing Report	Soham Infrapromoters Private Limited	AAA LLP | 2026-06-10 | HO/26-27/AA/0037 | Rs 2,430	{"id": 907, "firm_name": "Asija And Associates LLP", "short_name": "AAA LLP", "bill_date": "2026-06-10", "ref_no": "HO/26-27/AA/0037", "party_name": "Soham Infrapromoters Private Limited", "amount": 2430.0, "due_date": "2026-07-10", "overdue_days": -1, "ep_override": null, "receipt_status": "open", "paid_amount": 0.0, "closed_at": null, "group_override": null, "followup_partner": "KamalF", "deleted_at": null, "deleted_by": null, "delete_reason": null, "import_batch_id": null}	2026-06-11 18:29:13	arif.siddiqui@asija.in	deleted	\N	\N
27	billing_report	915	Billing Report	Surcoat Paints Private Limited	AAA LLP | 2026-06-10 | HO/26-27/AA/0041 | Rs 3,268	{"id": 915, "firm_name": "Asija And Associates LLP", "short_name": "AAA LLP", "bill_date": "2026-06-10", "ref_no": "HO/26-27/AA/0041", "party_name": "Surcoat Paints Private Limited", "amount": 3268.0, "due_date": "2026-07-10", "overdue_days": -1, "ep_override": null, "receipt_status": "open", "paid_amount": 0.0, "closed_at": null, "group_override": null, "followup_partner": "KamalF", "deleted_at": null, "deleted_by": null, "delete_reason": null, "import_batch_id": null}	2026-06-11 18:29:13	arif.siddiqui@asija.in	deleted	\N	\N
28	billing_report	917	Billing Report	Unix Enterprises Private Limited	AAA LLP | 2026-06-10 | HO/26-27/AA/0042 | Rs 2,247	{"id": 917, "firm_name": "Asija And Associates LLP", "short_name": "AAA LLP", "bill_date": "2026-06-10", "ref_no": "HO/26-27/AA/0042", "party_name": "Unix Enterprises Private Limited", "amount": 2247.0, "due_date": "2026-07-10", "overdue_days": -1, "ep_override": null, "receipt_status": "open", "paid_amount": 0.0, "closed_at": null, "group_override": null, "followup_partner": "KamalF", "deleted_at": null, "deleted_by": null, "delete_reason": null, "import_batch_id": null}	2026-06-11 18:29:13	arif.siddiqui@asija.in	deleted	\N	\N
29	billing_report	890	Billing Report	Ensky Ventures Private Limited	AAA LLP | 2026-06-10 | HO/26-27/AA/0025 | Rs 7,292	{"id": 890, "firm_name": "Asija And Associates LLP", "short_name": "AAA LLP", "bill_date": "2026-06-10", "ref_no": "HO/26-27/AA/0025", "party_name": "Ensky Ventures Private Limited", "amount": 7292.0, "due_date": "2026-07-10", "overdue_days": -1, "ep_override": null, "receipt_status": "open", "paid_amount": 0.0, "closed_at": null, "group_override": null, "followup_partner": "SahilD", "deleted_at": null, "deleted_by": null, "delete_reason": null, "import_batch_id": null}	2026-06-11 18:29:13	arif.siddiqui@asija.in	deleted	\N	\N
30	billing_report	900	Billing Report	Murad Ventures Private Limited	AAA LLP | 2026-06-10 | HO/26-27/AA/0031 | Rs 1,806	{"id": 900, "firm_name": "Asija And Associates LLP", "short_name": "AAA LLP", "bill_date": "2026-06-10", "ref_no": "HO/26-27/AA/0031", "party_name": "Murad Ventures Private Limited", "amount": 1806.0, "due_date": "2026-07-10", "overdue_days": -1, "ep_override": null, "receipt_status": "open", "paid_amount": 0.0, "closed_at": null, "group_override": null, "followup_partner": "SahilD", "deleted_at": null, "deleted_by": null, "delete_reason": null, "import_batch_id": null}	2026-06-11 18:29:13	arif.siddiqui@asija.in	deleted	\N	\N
31	billing_report	903	Billing Report	Republic Motors	AAA LLP | 2026-06-10 | HO/26-27/AA/0046 | Rs 2,396	{"id": 903, "firm_name": "Asija And Associates LLP", "short_name": "AAA LLP", "bill_date": "2026-06-10", "ref_no": "HO/26-27/AA/0046", "party_name": "Republic Motors", "amount": 2396.0, "due_date": "2026-07-10", "overdue_days": -1, "ep_override": null, "receipt_status": "open", "paid_amount": 0.0, "closed_at": null, "group_override": null, "followup_partner": "SahilD", "deleted_at": null, "deleted_by": null, "delete_reason": null, "import_batch_id": null}	2026-06-11 18:29:13	arif.siddiqui@asija.in	deleted	\N	\N
32	billing_report	918	Billing Report	U.P.Sainik Punarvas Nidhi	AAA LLP | 2026-06-10 | HO/26-27/AA/0043 | Rs 2,784	{"id": 918, "firm_name": "Asija And Associates LLP", "short_name": "AAA LLP", "bill_date": "2026-06-10", "ref_no": "HO/26-27/AA/0043", "party_name": "U.P.Sainik Punarvas Nidhi", "amount": 2784.0, "due_date": "2026-07-10", "overdue_days": -1, "ep_override": null, "receipt_status": "open", "paid_amount": 0.0, "closed_at": null, "group_override": null, "followup_partner": "AkashA", "deleted_at": null, "deleted_by": null, "delete_reason": null, "import_batch_id": null}	2026-06-11 18:29:13	arif.siddiqui@asija.in	deleted	\N	\N
33	billing_report	920	Billing Report	Vishal Mishra	AAA LLP | 2026-06-10 | HO/26-27/AA/0003 | Rs 8,850	{"id": 920, "firm_name": "Asija And Associates LLP", "short_name": "AAA LLP", "bill_date": "2026-06-10", "ref_no": "HO/26-27/AA/0003", "party_name": "Vishal Mishra", "amount": 8850.0, "due_date": "2026-07-10", "overdue_days": -1, "ep_override": null, "receipt_status": "open", "paid_amount": 0.0, "closed_at": null, "group_override": null, "followup_partner": "AkashA", "deleted_at": null, "deleted_by": null, "delete_reason": null, "import_batch_id": null}	2026-06-11 18:29:13	arif.siddiqui@asija.in	deleted	\N	\N
34	billing_report	910	Billing Report	SSCC Constructions Private Limited - UP	AAA LLP | 2026-06-10 | HO/26-27/AA/0040 | Rs 2,644	{"id": 910, "firm_name": "Asija And Associates LLP", "short_name": "AAA LLP", "bill_date": "2026-06-10", "ref_no": "HO/26-27/AA/0040", "party_name": "SSCC Constructions Private Limited - UP", "amount": 2644.0, "due_date": "2026-07-10", "overdue_days": -1, "ep_override": null, "receipt_status": "open", "paid_amount": 0.0, "closed_at": null, "group_override": null, "followup_partner": "SahilD", "deleted_at": null, "deleted_by": null, "delete_reason": null, "import_batch_id": null}	2026-06-11 18:29:13	arif.siddiqui@asija.in	deleted	\N	\N
35	billing_report	921	Billing Report	Vishesh Traders	AAA LLP | 2026-06-10 | HO/26-27/AA/0007 | Rs 17,700	{"id": 921, "firm_name": "Asija And Associates LLP", "short_name": "AAA LLP", "bill_date": "2026-06-10", "ref_no": "HO/26-27/AA/0007", "party_name": "Vishesh Traders", "amount": 17700.0, "due_date": "2026-07-10", "overdue_days": -1, "ep_override": null, "receipt_status": "open", "paid_amount": 0.0, "closed_at": null, "group_override": null, "followup_partner": "SahilD", "deleted_at": null, "deleted_by": null, "delete_reason": null, "import_batch_id": null}	2026-06-11 18:29:13	arif.siddiqui@asija.in	deleted	\N	\N
36	billing_report	922	Billing Report	VS Trading Co	AAA LLP | 2026-06-10 | HO/26-27/AA/0006 | Rs 17,700	{"id": 922, "firm_name": "Asija And Associates LLP", "short_name": "AAA LLP", "bill_date": "2026-06-10", "ref_no": "HO/26-27/AA/0006", "party_name": "VS Trading Co", "amount": 17700.0, "due_date": "2026-07-10", "overdue_days": -1, "ep_override": null, "receipt_status": "open", "paid_amount": 0.0, "closed_at": null, "group_override": null, "followup_partner": "SahilD", "deleted_at": null, "deleted_by": null, "delete_reason": null, "import_batch_id": null}	2026-06-11 18:29:13	arif.siddiqui@asija.in	deleted	\N	\N
\.


--
-- Data for Name: executive_partner_master; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.executive_partner_master (id, partner_name, final_ep) FROM stdin;
1	AA	AkashA
2	AK	AshishK
3	SD	SahilD
4	KKF	KamalF
5	KF	KamalF
6	CorpL	ManishM
7	CL	ManishM
8	RS	RohitS
9	PP	PrademnP-X
10	PJ	PJ
\.


--
-- Data for Name: firm_master; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.firm_master (id, firm_name, short_name) FROM stdin;
1	Asija Financial Services	AFS
15	Asija and Assocaites LLP- Guwahati	AAA-LLP-GW
16	Manish Mishra And Assocaites	MMAA
631	AAAFC	AAAFC
632	Asija And Associates LLP	AAA LLP
843	Asija Tech Consulting LLP	ATC
\.


--
-- Data for Name: receipt_adjustment_register; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.receipt_adjustment_register (id, source_bill_id, firm_name, short_name, bill_date, ref_no, party_name, bill_amount, adjustment_amount, balance_amount, due_date, overdue_days, client_group, followup_partner, final_ep, crp_of_group, client_category, financial_year, adjustment_type, adjustment_date, posted_at) FROM stdin;
1	535	AAAFC	AAAFC	2024-06-01	AAAFC/24-25/Corpl/0017	DGTLJ Consultancy LLP	3054.13	3054.13	0	2024-07-01	689	Anuja Sharma	ManishM	ManishM	KamalF	Private	02.04.2024 - 01.04.2025	Bad Debt	2026-06-03	2026-06-09 10:31:48
2	546	AAAFC	AAAFC	2025-06-10	AAAFC/25-26/Corpl/0014	DGTLJ Consultancy LLP	3050	3050	0	2025-07-10	315	Anuja Sharma	ManishM	ManishM	KamalF	Private	02.04.2025 - 01.04.2026	Bad Debt	2026-06-03	2026-06-09 10:31:48
\.


--
-- Data for Name: receipt_register; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.receipt_register (id, source_bill_id, firm_name, short_name, bill_date, ref_no, party_name, bill_amount, received_amount, balance_amount, due_date, overdue_days, client_group, followup_partner, final_ep, crp_of_group, client_category, financial_year, receipt_mode, receipt_date, posted_at, import_source, tally_voucher_no, tally_reference_no, tally_bank_name, tally_excel_rows) FROM stdin;
1	639	Asija And Associates LLP	AAA LLP	2025-11-10	HO/25-26/KKF/087	Mahan Brick Field	8260	8260	0	2025-12-10	162	Devesh Manjar	KamalF	KamalF	KamalF	Private	02.04.2025 - 01.04.2026	Bank	2026-05-25	2026-05-29 14:01:59	Tally	129	HO/25-26/KKF/087	Kotak Mahindra Bank Limited	12, 13, 14
2	617	Asija And Associates LLP	AAA LLP	2024-05-01	HO/24-25/PP/0015	UNDP	43789	43789	0	2024-05-31	720	UNDP	PrademnP-X	PrademnP-X	RohitS	Government	02.04.2024 - 01.04.2025	Bank	2026-05-25	2026-05-29 14:01:59	Tally	130	HO/24-25/PP/0015	Kotak Mahindra Bank Limited	15, 16, 17
3	673	Asija And Associates LLP	AAA LLP	2026-02-17	HO/25-26/KKF/0145	General Manager  (Fin) NHAI	42300	42300	0	2026-03-19	93	NHAI	KamalF	KamalF	KamalF	Government	02.04.2025 - 01.04.2026	Bank	2026-05-25	2026-05-29 14:01:59	Tally	131	HO/25-26/KKF/0145	Kotak Mahindra Bank Limited	18, 19, 20
4	696	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/SD/0159	B.K. Girijadevi Investment Private Limited	23600	21600	2000	2026-04-30	21	Amol Bansal	SahilD	SahilD	SahilD	Private	02.04.2025 - 01.04.2026	Bank	2026-05-25	2026-05-29 14:01:59	Tally	132	HO/25-26/SD/0159	Kotak Mahindra Bank Limited	21, 22, 23
5	744	Asija And Associates LLP	AAA LLP	2026-04-28	HO/26-27/KKF/027	Indian Institute Of Management Lucknow	59000	59000	0	2026-05-28	24	IIM-L	KamalF	KamalF	KamalF	Government	02.04.2026 - 01.04.2027	Bank	2026-05-26	2026-05-29 18:02:19	Tally	134	HO/26-27/KKF/027	Kotak Mahindra Bank Limited	29, 30, 31, 32
6	742	Asija And Associates LLP	AAA LLP	2026-04-25	HO/26-27/KKF/023	ICICI Bank Limited-Hazratganj Branch	53100	53100	0	2026-05-25	27	ICICI Bank	KamalF	KamalF	KamalF	Bank	02.04.2026 - 01.04.2027	Bank	2026-05-26	2026-05-29 18:02:19	Tally	135	HO/26-27/KKF/023	Kotak Mahindra Bank Limited	33, 34, 35, 36
7	743	Asija And Associates LLP	AAA LLP	2026-04-25	HO/26-27/KKF/024	ICICI Bank Limited - Mahanagar Branch	41300	41300	0	2026-05-25	26	ICICI Bank	KamalF	KamalF	KamalF	Bank	02.04.2026 - 01.04.2027	Bank	2026-05-26	2026-05-29 18:02:19	Tally	136	HO/26-27/KKF/024	Kotak Mahindra Bank Limited	37, 38, 39, 40
8	741	Asija And Associates LLP	AAA LLP	2026-04-24	HO/26-27/KKF/022	Uttar Pradesh Gramin Bank	7422	7422	0	2026-05-24	27	Uttar Pradesh Gramin Bank	KamalF	KamalF	KamalF	Bank	02.04.2026 - 01.04.2027	Bank	2026-05-26	2026-05-29 18:02:19	Tally	137	HO/26-27/KKF/022	Kotak Mahindra Bank Limited	41, 42, 43, 44
9	722	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/RS/0275	UP Metro Rail Corporation Ltd.	25960	25960	0	2026-04-30	51	UP Metro Rail Corporation Ltd.	RohitS	RohitS	RohitS	Government	02.04.2025 - 01.04.2026	Bank	2026-05-29	2026-06-02 10:18:34	Tally	140	HO/25-26/RS/0275	Kotak Mahindra Bank Limited	48, 49, 50, 51
10	782	Asija And Associates LLP	AAA LLP	2026-05-09	HO/26-27/RS/0020	UNICEF Office For Uttar Pradesh	7080	7080	0	2026-06-08	13	UNICEF	RohitS	RohitS	RohitS	Government	02.04.2026 - 01.04.2027	Bank	2026-06-01	2026-06-02 10:18:34	Tally	143	HO/26-27/RS/0020	Kotak Mahindra Bank Limited	52, 53, 54
11	784	Asija And Associates LLP	AAA LLP	2026-05-19	HO/26-27/AK/0007	Nivah Hospitality LLP	2360	2360	0	2026-06-18	2	Nivah Hospitality LLP	AshishK	AshishK	AshishK	Private	02.04.2026 - 01.04.2027	Bank	2026-05-19	2026-06-02 10:30:49	Tally	116	HO/26-27/AK/0007	Kotak Mahindra Bank Limited	115, 116, 117
12	753	Asija And Associates LLP	AAA LLP	2026-05-02	HO/26-27/KKF/034	Agriculture Insurance Company of India Limited	84370	84370	0	2026-06-01	19	AICIL	KamalF	KamalF	KamalF	Government	02.04.2026 - 01.04.2027	Bank	2026-05-19	2026-06-02 10:30:49	Tally	117	HO/26-27/KKF/034	TDS (Assets) FY 2026-27	118, 119, 120, 121
13	735	Asija And Associates LLP	AAA LLP	2026-04-22	HO/26-27/KKF/015	Northern Coalfields Limited , Dudhichua	181720	181720	0	2026-05-22	29	Northern Coalfields Limited , Dudhichua	KamalF	KamalF	KamalF	Government	02.04.2026 - 01.04.2027	Bank	2026-05-20	2026-06-02 10:30:49	Tally	118	HO/26-27/KKF/015	New Ref	122, 123, 124, 125, 126, 127, 128, 129
14	715	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/SD/0156	Spectrum Venture International Private Limited	21240	19440	1800	2026-04-30	21	Amol Bansal	SahilD	SahilD	SahilD	Private	02.04.2025 - 01.04.2026	Bank	2026-05-21	2026-06-02 10:30:49	Tally	119	HO/25-26/SD/0156	Kotak Mahindra Bank Limited	130, 131, 132
15	697	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/SD/0158	B K Saraf Private Limited	29500	27000	2500	2026-04-30	21	Amol Bansal	SahilD	SahilD	SahilD	Private	02.04.2025 - 01.04.2026	Bank	2026-05-21	2026-06-02 10:30:49	Tally	120	HO/25-26/SD/0158	Kotak Mahindra Bank Limited	133, 134, 135
16	752	Asija And Associates LLP	AAA LLP	2026-05-01	HO/26-27/KKF/033	GM (Internal Audit), NTPC Ltd.	259600	259600	0	2026-05-31	20	NTPC-IA	KamalF	KamalF	KamalF	Government	02.04.2026 - 01.04.2027	Bank	2026-05-21	2026-06-02 10:30:49	Tally	128	HO/26-27/KKF/033	New Ref	136, 137, 138, 139, 140, 141, 142, 143
17	680	Asija And Associates LLP	AAA LLP	2026-03-10	HO/25-26/SD/0152	Bks Myvault Private Limited	23600	21600	2000	2026-04-09	12	Amol Bansal	SahilD	SahilD	SahilD	Private	02.04.2025 - 01.04.2026	Bank	2026-05-22	2026-06-02 10:30:49	Tally	124	HO/25-26/SD/0152	Kotak Mahindra Bank Limited	150, 151, 152
18	679	Asija And Associates LLP	AAA LLP	2026-03-10	HO/25-26/SD/0151	BKS MyGold Private Limited	23600	21599	2001	2026-04-09	42	Amol Bansal	SahilD	SahilD	SahilD	Private	02.04.2025 - 01.04.2026	Bank	2026-05-22	2026-06-02 10:30:49	Tally	125	HO/25-26/SD/0151	Kotak Mahindra Bank Limited	153, 154, 155
19	726	Asija And Associates LLP	AAA LLP	2026-04-01	HO/26-27/KKF/005	ICICI Bank Limited-Hazratganj Branch	53100	53100	0	2026-05-01	20	ICICI Bank	KamalF	KamalF	KamalF	Bank	02.04.2025 - 01.04.2026	Bank	2026-05-22	2026-06-02 10:30:49	Tally	126	HO/26-27/KKF/005	TDS (Assets) FY 2026-27	156, 157, 158, 159
20	727	Asija And Associates LLP	AAA LLP	2026-04-01	HO/26-27/KKF/008	ICICI Bank Limited - Mahanagar Branch	41300	41300	0	2026-05-01	50	ICICI Bank	KamalF	KamalF	KamalF	Bank	02.04.2025 - 01.04.2026	Bank	2026-05-22	2026-06-02 10:30:49	Tally	127	HO/26-27/KKF/008	TDS (Assets) FY 2026-27	160, 161, 162, 163
21	747	Asija And Associates LLP	AAA LLP	2026-04-29	HO/26-27/AK/0005	KM Vyapar Limited	280250	140125	140125	2026-05-29	34	Aditya Jhunjhunwala group	AkashA	AshishK	AkashA	Private	02.04.2026 - 01.04.2027	Bank	2026-05-16	2026-06-02 10:32:04	Tally	113	HO/26-27/AK/0005	TDS (Assets) FY 2026-27	104, 105, 106, 107
22	757	Asija And Associates LLP	AAA LLP	2026-05-04	HO/26-27/SD/0008	S R M Motors Private Limited	236000	236000	0	2026-06-03	18	TATA Motors Passenger Vehicle Limited	SahilD	SahilD	AshishK	Private	02.04.2026 - 01.04.2027	Bank	2026-05-26	2026-06-02 10:44:15					
23	837	Asija And Associates LLP	AAA LLP	2026-06-23	HO/26-27/SD/0020	S R M Motors Private Limited	708000	708000	0	2026-07-23	-21	TATA Motors Passenger Vehicle Limited		SahilD	AshishK	Private	02.04.2026 - 01.04.2027	Bank	2026-05-26	2026-06-02 10:44:15					
24	697	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/SD/0158	B K Saraf Private Limited	2500	2500	0	2026-04-30	21	Amol Bansal	SahilD	SahilD	SahilD	Private	02.04.2025 - 01.04.2026	Cash	2026-03-31	2026-06-02 10:46:55					
25	696	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/SD/0159	B.K. Girijadevi Investment Private Limited	2000	2000	0	2026-04-30	21	Amol Bansal	SahilD	SahilD	SahilD	Private	02.04.2025 - 01.04.2026	Cash	2026-03-31	2026-06-02 10:46:55					
26	680	Asija And Associates LLP	AAA LLP	2026-03-10	HO/25-26/SD/0152	Bks Myvault Private Limited	2000	2000	0	2026-04-09	12	Amol Bansal	SahilD	SahilD	SahilD	Private	02.04.2025 - 01.04.2026	Cash	2026-03-31	2026-06-02 10:46:55					
27	715	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/SD/0156	Spectrum Venture International Private Limited	1800	1800	0	2026-04-30	21	Amol Bansal	SahilD	SahilD	SahilD	Private	02.04.2025 - 01.04.2026	Cash	2026-03-31	2026-06-02 10:46:55					
28	622	Asija And Associates LLP	AAA LLP	2025-03-25	ATC Bill Payment to MMA	Asija Tech Consulting LLP	11908	11908	0	2025-04-24	423	Ashish Kapoor	AkashA	ManishM	RuchiK	Private	02.04.2024 - 01.04.2025	Cash	2026-04-30	2026-06-02 10:48:26					
29	699	Asija And Associates LLP	AAA LLP	2026-03-31	HO/25-26/SD/0164	Chillies N Lemon Infra & Hospitality LLP	29500	2500	27000	2026-04-30	21	Amol Bansal	SahilD	SahilD	SahilD	Private	02.04.2025 - 01.04.2026	Cash	2026-03-31	2026-06-02 10:50:30					
30	679	Asija And Associates LLP	AAA LLP	2026-03-10	HO/25-26/SD/0151	BKS MyGold Private Limited	2001	2000	1	2026-04-09	42	Amol Bansal	SahilD	SahilD	SahilD	Private	02.04.2025 - 01.04.2026	Cash	2026-03-31	2026-06-02 10:53:09					
31	788	Asija Financial Services	AFS	2024-12-31	Dec-2024	Centricity Financial Distribution Private Limited	7589.04	7589.04	0	2025-01-30	507	Centricity Financial Distribution Private Limited	AshishK	AshishK	RuchiK	Private	02.04.2024 - 01.04.2025	Cash	2026-03-31	2026-06-02 12:39:47					
32	792	Asija Financial Services	AFS	2025-12-31	AFS/25-26/AK (AFS)/027	Centricity Financial Distribution Private Limited	9656.14	9656.14	0	2026-01-30	108	Centricity Financial Distribution Private Limited	AshishK	AshishK	RuchiK	Private	02.04.2025 - 01.04.2026	Cash	2026-03-31	2026-06-02 12:39:47					
33	799	Asija Financial Services	AFS	2026-02-28	AFS/25-26/AK (AFS)/032	Centricity Financial Distribution Private Limited	4136.09	4136.09	0	2026-03-30	49	Centricity Financial Distribution Private Limited	AshishK	AshishK	RuchiK	Private	02.04.2025 - 01.04.2026	Cash	2026-03-31	2026-06-02 12:39:47					
34	838	Asija And Associates LLP	AAA LLP	2026-05-23	HO/26-27/SD/0020	S R M Motors Private Limited	0.01	0.01	0	2026-06-22	10	TATA Motors Passenger Vehicle Limited		SahilD	AshishK	Private	02.04.2026 - 01.04.2027	Cash	2026-06-02	2026-06-02 14:49:13					
35	576	AAAFC	AAAFC	2026-03-10	AAAFC/25-26/Corpl/0044	Dream De Tourz LLP	22893	22893	0	2026-04-09	42	Praveen Kumar Singh	AshishK	ManishM	AshishK	Private	02.04.2025 - 01.04.2026	Bank	2026-06-03	2026-06-04 14:56:14	Tally	12	AAAFC/25-26/Corpl/0044	HDFC Bank A/c - 8788	12, 13, 14
36	659	Asija And Associates LLP	AAA LLP	2026-02-10	HO/25-26/CL/0119	Sanjivan Healthcare Enterprise Private Limited	22420	22420	0	2026-03-12	100	Praveen Kumar Singh	AshishK	ManishM	AshishK	Private	02.04.2025 - 01.04.2026	Bank	2026-06-03	2026-06-04 14:57:36	Tally	145	HO/25-26/CL/0119	Kotak Mahindra Bank Limited	15, 16, 17
37	657	Asija And Associates LLP	AAA LLP	2026-02-10	HO/25-26/CL/0116	PS Global Consumer Healthcare Pvt .Ltd	13570	13570	0	2026-03-12	70	Praveen Kumar Singh	AshishK	ManishM	AshishK	Private	02.04.2025 - 01.04.2026	Bank	2026-06-03	2026-06-04 14:57:36	Tally	146	HO/25-26/CL/0116	Kotak Mahindra Bank Limited	18, 19, 20
38	670	Asija And Associates LLP	AAA LLP	2026-02-10	HO/25-26/CL/0117	Unisel Infraservices and Trade Pvt Ltd	13570	13570	0	2026-03-12	70	Praveen Kumar Singh	AshishK	ManishM	AshishK	Private	02.04.2025 - 01.04.2026	Bank	2026-06-03	2026-06-04 14:57:36	Tally	147	HO/25-26/CL/0117	Kotak Mahindra Bank Limited	21, 22, 23
39	671	Asija And Associates LLP	AAA LLP	2026-02-10	HO/25-26/CL/0118	Unisel Overseas India Pvt Ltd	13570	13570	0	2026-03-12	70	Praveen Kumar Singh	AshishK	ManishM	AshishK	Private	02.04.2025 - 01.04.2026	Bank	2026-06-03	2026-06-04 14:57:36	Tally	148	HO/25-26/CL/0118	Kotak Mahindra Bank Limited	24, 25, 26
40	828	Asija And Associates LLP	AAA LLP	2026-05-22	HO/26-27/SD/0014	United Nations Children's Fund-Senegal	0.01	0.01	0	2026-06-21	13	United Nation - Global	SahilD	SahilD	SahilD	Government	02.04.2026 - 01.04.2027	Cash	2026-06-04	2026-06-04 15:13:26					
41	817	AAAFC	AAAFC	2026-05-22	AAAFC-26-27-AK-Del-0008	Sundry Departmental Debtor - NADT Ahmadabad	4000	2000	2000	2026-06-21	11	NADT	AkashA	AkashA	AshishK	Government	02.04.2026 - 01.04.2027	Bank	2026-06-05	2026-06-09 09:55:30	Tally	35	AAAFC-26-27-AK-Del-0008	Pratibha Pandey-Cash Imprest	15, 16, 17
42	565	AAAFC	AAAFC	2025-12-10	AAAFC/25-26/Corpl/0042	Winstrux Global LLP	8500	8500	0	2026-01-09	132	Ritesh Agarwal Grp	KamalF	ManishM	KamalF	Private	02.04.2025 - 01.04.2026	Bank	2026-06-08	2026-06-09 09:55:30	Tally	13	AAAFC/25-26/Corpl/0042	HDFC Bank A/c - 8788	18, 19, 20
43	556	AAAFC	AAAFC	2025-11-10	AAAFC/25-26/Corpl/0038	Karam Infracon LLP	2550	2550	0	2025-12-10	162	Ritesh Agarwal Grp	KamalF	ManishM	KamalF	Private	02.04.2025 - 01.04.2026	Bank	2026-06-08	2026-06-09 09:55:30	Tally	14	AAAFC/25-26/Corpl/0038	Pratibha Pandey-Cash Imprest	21, 22, 23, 24, 25, 26, 27, 28
44	536	AAAFC	AAAFC	2024-10-01	AAAFC/24-25/Corpl/0045	KANAKSH INFRA LLP	1000	1000	0	2024-10-31	567	Ritesh Agarwal Grp	KamalF	ManishM	KamalF	Private	02.04.2024 - 01.04.2025	Cash	2026-06-08	2026-06-09 09:59:59					
45	555	AAAFC	AAAFC	2025-11-10	AAAFC/25-26/Corpl/0033	KANAKSH INFRA LLP	5200	5200	0	2025-12-10	162	Ritesh Agarwal Grp	KamalF	ManishM	KamalF	Private	02.04.2025 - 01.04.2026	Cash	2026-06-08	2026-06-09 09:59:59					
46	537	AAAFC	AAAFC	2024-10-01	AAAFC/24-25/Corpl/0048	Karam Infracon LLP	500	500	0	2024-10-31	567	Ritesh Agarwal Grp	KamalF	ManishM	KamalF	Private	02.04.2024 - 01.04.2025	Cash	2026-06-08	2026-06-09 10:00:41					
47	547	AAAFC	AAAFC	2025-08-10	AAAFC/25-26/Corpl/0024	Karam Infracon LLP	8950	8950	0	2025-09-09	254	Ritesh Agarwal Grp	KamalF	ManishM	KamalF	Private	02.04.2025 - 01.04.2026	Cash	2026-06-08	2026-06-09 10:00:41					
48	754	Asija And Associates LLP	AAA LLP	2026-05-04	HO/26-27/KKF/035	ICICI Bank Limited - Kanpur Branch	56640	56640	0	2026-06-03	17	ICICI Bank	KamalF	KamalF	KamalF	Bank	02.04.2026 - 01.04.2027	Bank	2026-06-04	2026-06-09 10:05:48	Tally	150	HO/26-27/KKF/035	Kotak Mahindra Bank Limited	27, 28, 29, 30
49	755	Asija And Associates LLP	AAA LLP	2026-05-04	HO/26-27/KKF/036	ICICI Bank Limited - Kanpur Branch	56640	56640	0	2026-06-03	17	ICICI Bank	KamalF	KamalF	KamalF	Bank	02.04.2026 - 01.04.2027	Bank	2026-06-04	2026-06-09 10:05:48	Tally	151	HO/26-27/KKF/036	Kotak Mahindra Bank Limited	31, 32, 33, 34
50	620	Asija And Associates LLP	AAA LLP	2024-12-10	HO/24-25/KKF/043	KANAKSH INFRA LLP	6490	6490	0	2025-01-09	497	Ritesh Agarwal Grp	KamalF	KamalF	KamalF	Private	02.04.2024 - 01.04.2025	Bank	2026-06-08	2026-06-09 10:05:48	Tally	172	HO/24-25/KKF/043		35, 36
51	633	Asija And Associates LLP	AAA LLP	2025-10-10	HO/25-26/CL/0056	KANAKSH INFRA LLP	1180	1180	0	2025-11-09	193	Ritesh Agarwal Grp	KamalF	ManishM	KamalF	Private	02.04.2025 - 01.04.2026	Bank	2026-06-08	2026-06-09 10:05:48	Tally	172	HO/25-26/CL/0056		37, 38
52	634	Asija And Associates LLP	AAA LLP	2025-10-10	HO/25-26/CL/0057	Karam Infracon LLP	1180	1180	0	2025-11-09	193	Ritesh Agarwal Grp	KamalF	ManishM	KamalF	Private	02.04.2025 - 01.04.2026	Bank	2026-06-08	2026-06-09 10:05:48	Tally	173	HO/25-26/CL/0057		42, 43
53	678	Asija And Associates LLP	AAA LLP	2026-03-09	HO/25-26/CL/0120	Winstrux Global LLP	7670	7670	0	2026-04-08	73	Ritesh Agarwal Grp	KamalF	ManishM	KamalF	Private	02.04.2025 - 01.04.2026	Bank	2026-06-08	2026-06-09 10:05:48	Tally	174	HO/25-26/CL/0120	Kotak Mahindra Bank Limited	47, 48, 49
54	839	Asija And Associates LLP	AAA LLP	2026-06-03	HO/26-27/AK/0009	Nivah Hospitality LLP	23600	23600	0	2026-07-03	0	Nivah Hospitality LLP	AshishK	AshishK	AshishK	Private	02.04.2026 - 01.04.2027	Online	2026-06-09	2026-06-10 13:36:26					
55	913	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/SD/0030	Structural Insulation and Glazing Company Private Limited	221250	221250	0	2026-07-10	-1	Mohammad Ahmad	SahilD	SahilD	CRP-SahilD	Private	02.04.2026 - 01.04.2027	Cash	2026-06-11	2026-06-11 16:49:41					
56	747	Asija And Associates LLP	AAA LLP	2026-04-29	HO/26-27/AK/0005	KM Vyapar Limited	140125	140125	0	2026-05-29	34	Aditya Jhunjhunwala group	AkashA	AshishK	AkashA	Private	02.04.2026 - 01.04.2027	Bank	2026-06-12	2026-06-13 11:07:15	Tally	140125	HO/26-27/AK/0005	NEFT PUNBS26163057241 RTGS  INTERBANK ACCOUNT PUN	17, 18, 19, 20, 21
57	986	Asija And Associates LLP	AAA LLP	2026-06-10	HO/26-27/KKF/050	Tiranga Prerna Clf	20650	20650	0	2026-07-10	3	UPSRLM	KamalF	KamalF	KamalF	Government	02.04.2026 - 01.04.2027	Bank	2026-06-08	2026-06-13 14:16:11	Tally	176	HO/26-27/KKF/050	Kotak Mahindra Bank Limited	49, 50, 51
58	795	Asija Financial Services	AFS	2026-01-10	AFS/25-26/Corpl/0007	Limen Solutions Private Limited	6600	6600	0	2026-02-09	98	Praveen Singh	SahilD	ManishM	SahilD	Private	02.04.2025 - 01.04.2026	Bank	2026-06-13	2026-06-13 14:17:08	Tally	13	AFS/25-26/Corpl/0007	Pratibha Pandey-Cash Imprest	9, 10, 11
59	988	AAAFC	AAAFC	2006-06-10	AAAFC-26-27-RS-Del-0001	Sundry Departmental Debtor- UP State Tax	500000	300000	200000	2006-07-10	7308	UP State Tax	RohitS	RohitS	RohitS	Government	02.04.2006 - 01.04.2007	Bank	2026-06-10	2026-06-13 15:26:26	Tally	37	AAAFC-26-27-RS-Del-0001	CA Rohit Singh - Cash Imprest	29, 30, 31
60	557	AAAFC	AAAFC	2025-11-10	AAAFC/25-26/Corpl/0036	Limen Solutions Private Limited	2800	2800	0	2025-12-10	162	Praveen Singh	SahilD	ManishM	SahilD	Private	02.04.2025 - 01.04.2026	Bank	2026-06-13	2026-06-13 15:26:26	Tally	15	AAAFC/25-26/Corpl/0036	Pratibha Pandey-Cash Imprest	32, 33, 34
61	988	AAAFC	AAAFC	2006-06-10	AAAFC-26-27-RS-Del-0001	Sundry Departmental Debtor- UP State Tax	200000	200000	0	2006-07-10	7308	UP State Tax	RohitS	RohitS	RohitS	Government	02.04.2006 - 01.04.2007	Bank	2026-06-01	2026-06-13 15:34:07	Tally	24	AAAFC-26-27-RS-Del-0001	Cash - OFF	9, 10, 11
\.


--
-- Name: billing_report_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.billing_report_id_seq', 988, true);


--
-- Name: cheque_bounce_register_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cheque_bounce_register_id_seq', 1, true);


--
-- Name: client_group_master_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.client_group_master_id_seq', 20028, true);


--
-- Name: client_master_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.client_master_id_seq', 210, true);


--
-- Name: crp_master_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.crp_master_id_seq', 341, true);


--
-- Name: debtor_import_client_errors_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.debtor_import_client_errors_id_seq', 16, true);


--
-- Name: deleted_records_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.deleted_records_log_id_seq', 36, true);


--
-- Name: executive_partner_master_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.executive_partner_master_id_seq', 10, true);


--
-- Name: firm_master_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.firm_master_id_seq', 927, true);


--
-- Name: receipt_adjustment_register_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.receipt_adjustment_register_id_seq', 2, true);


--
-- Name: receipt_register_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.receipt_register_id_seq', 61, true);


--
-- Name: app_meta app_meta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_meta
    ADD CONSTRAINT app_meta_pkey PRIMARY KEY (key);


--
-- Name: billing_report billing_report_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_report
    ADD CONSTRAINT billing_report_pkey PRIMARY KEY (id);


--
-- Name: cheque_bounce_register cheque_bounce_register_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cheque_bounce_register
    ADD CONSTRAINT cheque_bounce_register_pkey PRIMARY KEY (id);


--
-- Name: client_group_master client_group_master_group_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_group_master
    ADD CONSTRAINT client_group_master_group_name_key UNIQUE (group_name);


--
-- Name: client_group_master client_group_master_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_group_master
    ADD CONSTRAINT client_group_master_pkey PRIMARY KEY (id);


--
-- Name: client_master client_master_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_master
    ADD CONSTRAINT client_master_pkey PRIMARY KEY (id);


--
-- Name: crp_master crp_master_crp_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crp_master
    ADD CONSTRAINT crp_master_crp_name_key UNIQUE (crp_name);


--
-- Name: crp_master crp_master_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crp_master
    ADD CONSTRAINT crp_master_pkey PRIMARY KEY (id);


--
-- Name: debtor_import_client_errors debtor_import_client_errors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.debtor_import_client_errors
    ADD CONSTRAINT debtor_import_client_errors_pkey PRIMARY KEY (id);


--
-- Name: debtor_nav_access debtor_nav_access_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.debtor_nav_access
    ADD CONSTRAINT debtor_nav_access_pkey PRIMARY KEY (user_email, access_key);


--
-- Name: deleted_records_log deleted_records_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deleted_records_log
    ADD CONSTRAINT deleted_records_log_pkey PRIMARY KEY (id);


--
-- Name: executive_partner_master executive_partner_master_partner_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.executive_partner_master
    ADD CONSTRAINT executive_partner_master_partner_name_key UNIQUE (partner_name);


--
-- Name: executive_partner_master executive_partner_master_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.executive_partner_master
    ADD CONSTRAINT executive_partner_master_pkey PRIMARY KEY (id);


--
-- Name: firm_master firm_master_firm_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.firm_master
    ADD CONSTRAINT firm_master_firm_name_key UNIQUE (firm_name);


--
-- Name: firm_master firm_master_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.firm_master
    ADD CONSTRAINT firm_master_pkey PRIMARY KEY (id);


--
-- Name: receipt_adjustment_register receipt_adjustment_register_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.receipt_adjustment_register
    ADD CONSTRAINT receipt_adjustment_register_pkey PRIMARY KEY (id);


--
-- Name: receipt_register receipt_register_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.receipt_register
    ADD CONSTRAINT receipt_register_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

\unrestrict gSWAW1Hma3wO248AqUvNSmNfO0REwKuFSyXJpNMYuIS7xegMkaR8Xre5vh8mhoM

