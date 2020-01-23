-- Database: wonder

-- DROP DATABASE wonder;

CREATE DATABASE wonder
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'C'
    LC_CTYPE = 'C'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;




-- Table: public."raw"

-- DROP TABLE public."raw";

CREATE TABLE public."raw"
(
    event_occurred_at timestamp without time zone,
    analyst_id character varying(50) COLLATE pg_catalog."default",
    quality_score_sourcing real,
    quality_score_writing real,
    action_ character varying(20) COLLATE pg_catalog."default",
    request_id character varying(50) COLLATE pg_catalog."default" NOT NULL,
    request_created_at timestamp without time zone,
    job character varying(20) COLLATE pg_catalog."default",
    wait_time_min smallint,
    waiting_for character varying(60) COLLATE pg_catalog."default",
    analysts_available smallint,
    analysts_occupied smallint,
    total_jobs_available smallint,
    review_jobs_available smallint,
    vetting_jobs_available smallint,
    planning_jobs_available smallint,
    editing_jobs_available smallint,
    sourcing_jobs_available smallint,
    writing_jobs_available smallint
)

TABLESPACE pg_default;

ALTER TABLE public."raw"
    OWNER to postgres;