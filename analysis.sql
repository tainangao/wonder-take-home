-- 1. what type of jobs need more resources

-- 1.1 what jobs are more common and what jobs tend to be declined
/* 
The most common job is sourcing, and it also tends to be declined the most.
Review job is quite common but only 11% of the time people decline the job.
*/
WITH job_action AS 
	(
	SELECT job,
		   SUM(CASE WHEN action_ = 'Assigned Job' THEN actions ELSE 0 END) AS assigned_job,
		   SUM(CASE WHEN action_ = 'Accepted Job' THEN actions ELSE 0 END) AS accepted_job,
		   SUM(CASE WHEN action_ = 'Declined Job' THEN actions ELSE 0 END) AS declined_job
	  FROM (
			SELECT job,
				   action_,
				   COUNT(request_id) actions
			  FROM raw
			 GROUP BY 1,2
		   ) sub
	 GROUP BY 1
	 ORDER BY 2 DESC
	)
SELECT *, ROUND(CAST(declined_job AS FLOAT )/CAST(assigned_job AS FLOAT)*100) decline_percent
FROM job_action;

-- 1.2 what job has longer wait time
/*
Sourcing and editing have the longest wait time.
Although writing has a high decline rate, the wait time is short.
Editing is the least common type of job with only 14% of decline rate, but the wait time is long.
*/
SELECT job, ROUND(AVG(wait_time_min),2) avg_wait_time
FROM raw
GROUP BY job
ORDER BY 2 DESC;

-- 1.3 average # of jobs available for a given time
/* 
The reason why sourcing and editing have the longest wait times is because, 
on average, they have the least amount of job available at a given time. 

Potential action point: have more analysts to do sourcing and editing. 
*/
SELECT 
	ROUND(AVG(review_jobs_available), 2) avg_review, 
	ROUND(AVG(vetting_jobs_available), 2) avg_vetting, 
	ROUND(AVG(planning_jobs_available), 2) avg_planning, 
	ROUND(AVG(editing_jobs_available), 2) avg_editing, 
	ROUND(AVG(sourcing_jobs_available), 2) avg_sourcing, 
	ROUND(AVG(writing_jobs_available), 2) avg_writing
FROM raw;



-- 2.1 what time of the day has more event occur
-- 	(organize code in another way)
/*
Since people who place requests/initiate events are from all around the world, 
there's no significant pattern. 
But generally speaking, less people initiate events during rush hours and lunch time.
Many people initiate events at late night (21:00, 22:00, 23:00) and mid-day (15:00, 13:00).
*/
WITH event_action_1 AS
	(
		SELECT extract(hour from event_occurred_at) event_hour,
				action_,
				COUNT(request_id) actions
		FROM raw
		GROUP BY 1,2
	),
	event_action_2 AS 
	(
		SELECT event_hour,
			   SUM(CASE WHEN action_ = 'Assigned Job' THEN actions ELSE 0 END) AS assigned_job,
			   SUM(CASE WHEN action_ = 'Accepted Job' THEN actions ELSE 0 END) AS accepted_job,
			   SUM(CASE WHEN action_ = 'Declined Job' THEN actions ELSE 0 END) AS declined_job
		FROM event_action_1
		GROUP BY 1
		ORDER BY 2 DESC
	),
	event_action_3 AS
	(
		SELECT *,
				ROUND(CAST(declined_job AS FLOAT )/CAST(assigned_job AS FLOAT)*100) decline_percent
		FROM event_action_2
	)
	
SELECT *
FROM event_action_3
ORDER BY 2 DESC;



-- 2.2 what time of the day has the highest decline rate
-- 	(order by decline rate)
/*
15:00 has the largest # of people initiate events, and also the highest decline rate.
Rush hours (18:00,17:00, 9:00) have high decline rates.
Decline rate and # of events are positively correlated.
*/
WITH event_action_1 AS
	(
		SELECT extract(hour from event_occurred_at) event_hour,
				action_,
				COUNT(request_id) actions
		FROM raw
		GROUP BY 1,2
	),
	event_action_2 AS 
	(
		SELECT event_hour,
			   SUM(CASE WHEN action_ = 'Assigned Job' THEN actions ELSE 0 END) AS assigned_job,
			   SUM(CASE WHEN action_ = 'Accepted Job' THEN actions ELSE 0 END) AS accepted_job,
			   SUM(CASE WHEN action_ = 'Declined Job' THEN actions ELSE 0 END) AS declined_job
		FROM event_action_1
		GROUP BY 1
		ORDER BY 2 DESC
	),
	event_action_3 AS
	(
		SELECT *,
				ROUND(CAST(declined_job AS FLOAT )/CAST(assigned_job AS FLOAT)*100) decline_percent
		FROM event_action_2
	)
	
SELECT *
FROM event_action_3
ORDER BY 5 DESC;



-- 3. what time of the day has more requests
/*
12:00 and 21:00 have the largest # of requests, 
we need to make sure the system is at its optimum during that time.
*/
SELECT EXTRACT(HOUR FROM request_created_at) request_hour, COUNT(request_id) n_request
FROM raw
GROUP BY 1
ORDER BY 2 DESC;



-- 4. most complicated/least favorable requests
/*
Wait time, decline rate, and # of actions are positively correlated.
Further investigating if there's any causation relationship 
could help minize wait time, decline rate, or # of actions.
*/
WITH request_action_1 AS
	(
		SELECT request_id,
				action_,
				SUM(wait_time_min) wait_time,
				COUNT(request_id) actions
		FROM raw
		GROUP BY 1,2
	),
	request_action_2 AS 
	(
		SELECT request_id,
				SUM(wait_time) total_wait_time,
				ROUND(AVG(wait_time),2) avg_wait_time,
				SUM(actions) n_action,
			   SUM(CASE WHEN action_ = 'Assigned Job' THEN actions ELSE 0 END) AS assigned_job,
			   SUM(CASE WHEN action_ = 'Accepted Job' THEN actions ELSE 0 END) AS accepted_job,
			   SUM(CASE WHEN action_ = 'Declined Job' THEN actions ELSE 0 END) AS declined_job
		FROM request_action_1
		GROUP BY 1
	),
	request_action_3 AS
	(
		SELECT *,
				ROUND(CAST(declined_job AS FLOAT )/CAST(assigned_job AS FLOAT)*100) decline_percent
		FROM request_action_2
	)
	
SELECT *
FROM request_action_3
ORDER BY 2 DESC;




-- 5. who were assigned more jobs and who decline more jobs
WITH analyst_action AS 
	(
	SELECT analyst_id,
		   SUM(CASE WHEN action_ = 'Assigned Job' THEN actions ELSE 0 END) AS assigned_job,
		   SUM(CASE WHEN action_ = 'Accepted Job' THEN actions ELSE 0 END) AS accepted_job,
		   SUM(CASE WHEN action_ = 'Declined Job' THEN actions ELSE 0 END) AS declined_job
	  FROM (
			SELECT analyst_id,
				   action_,
				   COUNT(request_id) actions
			  FROM raw
			 GROUP BY 1,2
		   ) sub
	 GROUP BY 1
	 ORDER BY 2 DESC
	)
SELECT *, ROUND(CAST(declined_job AS FLOAT )/CAST(assigned_job AS FLOAT)*100) decline_percent
FROM analyst_action

-- 5.1 which analysts receive higher scores and more requests
/*
Higher score and # of requests are positively correlated.
*/
SELECT analyst_id, 
	AVG(quality_score_sourcing) avg_score_sourcing, 
	AVG(quality_score_writing) avg_score_writing,
	COUNT(request_id) num_request
FROM raw
GROUP BY analyst_id
ORDER BY avg_score_sourcing DESC;

-- 5.2 which analyst has low quality and long wait time
/*
Perhaps they are new analysts.
Potential action item: provide better training.
*/
SELECT analyst_id, quality_score_sourcing, quality_score_writing, wait_time_min
FROM raw
WHERE quality_score_sourcing<4
AND wait_time_min>30
ORDER BY 4 DESC;



