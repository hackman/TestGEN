--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: 2009-2010; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA "2009-2010";


ALTER SCHEMA "2009-2010" OWNER TO postgres;

SET search_path = "2009-2010", pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: questions; Type: TABLE; Schema: 2009-2010; Owner: postgres; Tablespace: 
--

CREATE TABLE questions (
    id integer NOT NULL,
    date_added timestamp without time zone DEFAULT now() NOT NULL,
    question text NOT NULL,
    first_test boolean DEFAULT true NOT NULL
);


ALTER TABLE "2009-2010".questions OWNER TO postgres;

--
-- Name: questions_id_seq; Type: SEQUENCE; Schema: 2009-2010; Owner: postgres
--

CREATE SEQUENCE questions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "2009-2010".questions_id_seq OWNER TO postgres;

--
-- Name: questions_id_seq; Type: SEQUENCE OWNED BY; Schema: 2009-2010; Owner: postgres
--

ALTER SEQUENCE questions_id_seq OWNED BY questions.id;


--
-- Name: results; Type: TABLE; Schema: 2009-2010; Owner: postgres; Tablespace: 
--

CREATE TABLE results (
    id integer NOT NULL,
    fn integer NOT NULL,
    e1 integer,
    e2 integer,
    v1 integer,
    v2 integer,
    gender boolean DEFAULT true NOT NULL,
    kurs integer
);


ALTER TABLE "2009-2010".results OWNER TO postgres;

--
-- Name: results_e1; Type: VIEW; Schema: 2009-2010; Owner: postgres
--

CREATE VIEW results_e1 AS
    SELECT results.fn, results.e1, results.v1 FROM results ORDER BY results.fn, results.v1;


ALTER TABLE "2009-2010".results_e1 OWNER TO postgres;

--
-- Name: VIEW results_e1; Type: COMMENT; Schema: 2009-2010; Owner: postgres
--

COMMENT ON VIEW results_e1 IS 'Show results from the first test';


--
-- Name: results_e2; Type: VIEW; Schema: 2009-2010; Owner: postgres
--

CREATE VIEW results_e2 AS
    SELECT results.fn, results.e2, results.v2, CASE WHEN ((results.e1 + results.e2) >= 90) THEN 6 WHEN ((results.e1 + results.e2) >= 80) THEN 5 WHEN ((results.e1 + results.e2) >= 70) THEN 4 WHEN ((results.e1 + results.e2) >= 60) THEN 3 WHEN ((results.e1 + results.e2) <= 60) THEN 2 ELSE NULL::integer END AS grade FROM results WHERE ((results.e2 > 0) AND (results.e1 > 0)) ORDER BY results.fn, results.v2;


ALTER TABLE "2009-2010".results_e2 OWNER TO postgres;

--
-- Name: VIEW results_e2; Type: COMMENT; Schema: 2009-2010; Owner: postgres
--

COMMENT ON VIEW results_e2 IS 'Show results from the second test';


--
-- Name: results_id_seq; Type: SEQUENCE; Schema: 2009-2010; Owner: postgres
--

CREATE SEQUENCE results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "2009-2010".results_id_seq OWNER TO postgres;

--
-- Name: results_id_seq; Type: SEQUENCE OWNED BY; Schema: 2009-2010; Owner: postgres
--

ALTER SEQUENCE results_id_seq OWNED BY results.id;


--
-- Name: right_answers; Type: TABLE; Schema: 2009-2010; Owner: postgres; Tablespace: 
--

CREATE TABLE right_answers (
    id integer NOT NULL,
    q_id integer NOT NULL,
    date_added timestamp without time zone DEFAULT now() NOT NULL,
    answer text NOT NULL
);


ALTER TABLE "2009-2010".right_answers OWNER TO postgres;

--
-- Name: right_answares_id_seq; Type: SEQUENCE; Schema: 2009-2010; Owner: postgres
--

CREATE SEQUENCE right_answares_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "2009-2010".right_answares_id_seq OWNER TO postgres;

--
-- Name: right_answares_id_seq; Type: SEQUENCE OWNED BY; Schema: 2009-2010; Owner: postgres
--

ALTER SEQUENCE right_answares_id_seq OWNED BY right_answers.id;


--
-- Name: show_grades; Type: VIEW; Schema: 2009-2010; Owner: postgres
--

CREATE VIEW show_grades AS
    SELECT results.fn, results.e1, results.e2, CASE WHEN ((results.e1 + results.e2) >= 90) THEN 6 WHEN ((results.e1 + results.e2) >= 80) THEN 5 WHEN ((results.e1 + results.e2) >= 70) THEN 4 WHEN ((results.e1 + results.e2) >= 60) THEN 3 WHEN ((results.e1 + results.e2) <= 60) THEN 2 ELSE NULL::integer END AS grade FROM results WHERE ((results.e2 > 0) AND (results.e1 > 0)) ORDER BY results.fn, CASE WHEN ((results.e1 + results.e2) >= 90) THEN 6 WHEN ((results.e1 + results.e2) >= 80) THEN 5 WHEN ((results.e1 + results.e2) >= 70) THEN 4 WHEN ((results.e1 + results.e2) >= 60) THEN 3 WHEN ((results.e1 + results.e2) <= 60) THEN 2 ELSE NULL::integer END;


ALTER TABLE "2009-2010".show_grades OWNER TO postgres;

--
-- Name: VIEW show_grades; Type: COMMENT; Schema: 2009-2010; Owner: postgres
--

COMMENT ON VIEW show_grades IS 'Show results from both tests and final grades';


--
-- Name: wrong_answers; Type: TABLE; Schema: 2009-2010; Owner: postgres; Tablespace: 
--

CREATE TABLE wrong_answers (
    id integer NOT NULL,
    q_id integer NOT NULL,
    date_added timestamp without time zone DEFAULT now() NOT NULL,
    answer text NOT NULL
);


ALTER TABLE "2009-2010".wrong_answers OWNER TO postgres;

--
-- Name: wrong_answares_id_seq; Type: SEQUENCE; Schema: 2009-2010; Owner: postgres
--

CREATE SEQUENCE wrong_answares_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE "2009-2010".wrong_answares_id_seq OWNER TO postgres;

--
-- Name: wrong_answares_id_seq; Type: SEQUENCE OWNED BY; Schema: 2009-2010; Owner: postgres
--

ALTER SEQUENCE wrong_answares_id_seq OWNED BY wrong_answers.id;


--
-- Name: id; Type: DEFAULT; Schema: 2009-2010; Owner: postgres
--

ALTER TABLE ONLY questions ALTER COLUMN id SET DEFAULT nextval('questions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: 2009-2010; Owner: postgres
--

ALTER TABLE ONLY results ALTER COLUMN id SET DEFAULT nextval('results_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: 2009-2010; Owner: postgres
--

ALTER TABLE ONLY right_answers ALTER COLUMN id SET DEFAULT nextval('right_answares_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: 2009-2010; Owner: postgres
--

ALTER TABLE ONLY wrong_answers ALTER COLUMN id SET DEFAULT nextval('wrong_answares_id_seq'::regclass);


--
-- Name: questions_pkey; Type: CONSTRAINT; Schema: 2009-2010; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY questions
    ADD CONSTRAINT questions_pkey PRIMARY KEY (id);


--
-- Name: results_id_key; Type: CONSTRAINT; Schema: 2009-2010; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY results
    ADD CONSTRAINT results_id_key UNIQUE (id);


--
-- Name: results_pkey; Type: CONSTRAINT; Schema: 2009-2010; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY results
    ADD CONSTRAINT results_pkey PRIMARY KEY (fn);


--
-- Name: right_answares_pkey; Type: CONSTRAINT; Schema: 2009-2010; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY right_answers
    ADD CONSTRAINT right_answares_pkey PRIMARY KEY (id);


--
-- Name: wrong_answares_pkey; Type: CONSTRAINT; Schema: 2009-2010; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY wrong_answers
    ADD CONSTRAINT wrong_answares_pkey PRIMARY KEY (id);


--
-- Name: right_answares_q_id_fkey; Type: FK CONSTRAINT; Schema: 2009-2010; Owner: postgres
--

ALTER TABLE ONLY right_answers
    ADD CONSTRAINT right_answares_q_id_fkey FOREIGN KEY (q_id) REFERENCES questions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: wrong_answares_q_id_fkey; Type: FK CONSTRAINT; Schema: 2009-2010; Owner: postgres
--

ALTER TABLE ONLY wrong_answers
    ADD CONSTRAINT wrong_answares_q_id_fkey FOREIGN KEY (q_id) REFERENCES questions(id) ON UPDATE CASCADE ON DELETE CASCADE;

