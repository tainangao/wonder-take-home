-- what job has the longest average wait time
SELECT job.job_id, AVG(event.wait_time_min) avg_wait_time
FROM job 
RIGHT JOIN event
ON job.event_event_id=event.event_id
GROUP BY 1
ORDER BY 2 DESC;

-- which requests have the longest average wait time
-- (with more related data, we can identify what kind of request has longer wait time)
WITH request_info AS
	(
		SELECT request_id, AVG(wait_time_min) avg_wait_time
		FROM event
		LEFT JOIN job ON job.event_event_id=event.event_id
		LEFT JOIN request ON request.request_id=job.request_request_iD
	)
SELECT *
FROM request_info
GROUP BY 1
ORDER BY 2 DESC;

-- average wait time per request
WITH request_info AS
	(
		SELECT request_id, AVG(wait_time_min) avg_wait_time
		FROM event
		LEFT JOIN job ON job.event_event_id=event.event_id
		LEFT JOIN request ON request.request_id=job.request_request_iD
		GROUP BY 1
	)
SELECT AVG(avg_wait_time)
FROM request_info;


-- what time of the day has a longer wait time per request
SELECT EXTRACT(HOUR FROM event_occurred_at) hour, AVG(wait_time_min) avg_wait_time
FROM event
GROUP BY 1
ORDER BY 2 DESC;

-- what time of the day has more requests being placed
SELECT EXTRACT(HOUR FROM request_creat_at) hour, COUNT(request_id)
FROM request
GROUP BY 1
ORDER BY 2 DESC;


-- what time of the day has more events happen
SELECT EXTRACT(HOUR FROM event_creat_at) hour, COUNT(event_id)
FROM event
GROUP BY hour
ORDER BY 2;


-- who are the top performing analysts
SELECT 
	analyst_id, 
	AVG(quality_score_sourcing) quality_score_sourcing, 
	AVG(quality_score_writing) quality_score_writing,
	COUNT(rquest_id) n_request
FROM analyst a 
LEFT JOIN analyst_has_request ar ON a.analyst_id = ar.analyst_analyst_id
LEFT JOIN request r ON ar.request_request_id = r.request_id
GROUP BY 1
ORDER BY 2 DESC;









