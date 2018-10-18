content = '''
WITH Timesheets AS (
	SELECT d.DEVICEID, d.COMPONENTID, d.STATE, d.STATEBIT,
	CASE WHEN d.STARTED < TO_DATE(START_DATE_STATIC, 'YYYY-MM-DD') THEN TO_DATE(START_DATE_STATIC, 'YYYY-MM-DD') ELSE d.STARTED END AS start_time,
	CASE WHEN d.ended < least(TO_DATE(END_DATE_STATIC, 'YYYY-MM-DD')+1,sysdate) THEN d.ended ELSE least(TO_DATE(END_DATE_STATIC, 'YYYY-MM-DD')+1,sysdate) END AS end_time
	FROM deviceFAIL d
	WHERE
	(
		( d.started between TO_DATE(START_DATE_STATIC, 'YYYY-MM-DD') and least(TO_DATE(END_DATE_STATIC, 'YYYY-MM-DD')+1,sysdate) )
		OR
		( nvl(d.ended,sysdate) between TO_DATE(START_DATE_STATIC, 'YYYY-MM-DD') and TO_DATE(END_DATE_STATIC, 'YYYY-MM-DD')+1 )
	)
)
select dv.deviceid, round(total_time) total_time,
	round(total_stop_int*mi,0) as shutdown_time,
	round((total_time-total_stop_int*mi)/total_time,4)*10000 as ok_rate,
	round(total_oper_int*mi,0) as operate_time,
	round((total_time-total_oper_int*mi)/total_time,4)*10000 as operate_rate,
	round(total_device_int*mi,0) as device_time,
	round((total_time-total_device_int*mi)/total_time,4)*10000 as device_rate,
	round(total_resource_int*mi,0) as resource_time,
	round((total_time-total_resource_int*mi)/total_time,4)*10000 as resource_rate,
	round(total_host_int*mi,0) as host_time,
	round((total_time-total_host_int*mi)/total_time,4)*10000 as host_rate
from device dv,
(
	select deviceid,
		sum(case when category='oos' then (end_time-start_time) else 0 end ) AS total_stop_int,
		sum(case when category='oos_sop' then (end_time-start_time) else 0 end ) AS total_oper_int,
		sum(case when category='host' then (end_time-start_time) else 0 end ) AS total_host_int,
		sum(case when category='hardware' then (end_time-start_time) else 0 end ) AS total_device_int,
		sum(case when category='resource' then (end_time-start_time) else 0 end ) AS total_resource_int,
		sum(case when category='proview' then (end_time-start_time) else 0 end ) AS total_proview_int,
		sum(case when category='nocash' then (end_time-start_time) else 0 end ) AS total_nocash_int
	from
	(
		select DEVICEID
			,      category
			,      min(start_time) start_time, max(max_end_by_now) end_time
		FROM
		(
			select pps.*
				 ,      sum(start_new_period) over ( partition by DEVICEID, category
													 order by start_time) period
			FROM
			(
				select DEVICEID, category, start_time, end_time, max_end_by_now
					,      case when start_time > lag(max_end_by_now) over ( partition by DEVICEID, category
																			order by start_time
																			)
											then 1
											else 0
											end start_new_period
				FROM (
					SELECT DEVICEID, category, start_time, end_time,
						max (end_time) over ( partition by DEVICEID, category order by start_time) max_end_by_now
					FROM
					(
						SELECT DEVICEID, start_time, end_time,
							CASE WHEN componentid in ( 8,19,20,21 ) THEN 'resource'
							ELSE 'hardware' END AS category
						FROM timesheets
						WHERE componentid IN ( 8,19,20,21, 1,2,3,6 )
						UNION ALL
						SELECT DEVICEID, start_time, end_time, 'nocash' AS category
						FROM timesheets
						WHERE statebit = 11 or componentid in (20,1)
						UNION ALL
						select DEVICEID,  start_time, end_time, 'oos' as category
						from Timesheets where statebit = 11 and componentid = 0
						UNION ALL
						select DEVICEID, start_time, end_time, 'oos_sop' as category
						FROM Timesheets where bitand(state, 5120) = 5120 and statebit = 11 and componentid = 0
						UNION ALL
						select DEVICEID, start_time, end_time, 'host' as category
						from Timesheets where componentid = 7
						UNION ALL
						select DEVICEID, start_time, end_time, 'proview' as category
						from Timesheets where componentid = 22
					)
				)
			) pps
		)
		GROUP BY DEVICEID, category, period
		UNION ALL
		SELECT deviceid, 'filler', null, null FROM DEVICE
	)
	WHERE (end_time-start_time)*24*60 > 5 OR start_time is null
	GROUP BY deviceid
) sstop,
( SELECT (least(TO_DATE(END_DATE_STATIC, 'YYYY-MM-DD')+1,sysdate)-TO_DATE(START_DATE_STATIC, 'YYYY-MM-DD'))*24*60 AS total_time, 24*60 AS mi FROM DUAL) c
WHERE dv.deviceid = sstop.deviceid;
'''

fixcontent = '''
WITH Timesheets AS (
	SELECT d.DEVICEID, d.COMPONENTID, d.STATE, d.STATEBIT,
	CASE WHEN d.STARTED < TO_DATE(START_DATE_STATIC, 'YYYY-MM-DD') THEN TO_DATE(START_DATE_STATIC, 'YYYY-MM-DD') ELSE d.STARTED END AS start_time,
	CASE WHEN d.ended < least(TO_DATE(END_DATE_STATIC, 'YYYY-MM-DD')+1,sysdate) THEN d.ended ELSE least(TO_DATE(END_DATE_STATIC, 'YYYY-MM-DD')+1,sysdate) END AS end_time
	FROM deviceFAIL d
	WHERE d.started < TO_DATE(END_DATE_STATIC, 'YYYY-MM-DD')+1 AND (nvl(d.ended, TO_DATE(END_DATE_STATIC, 'YYYY-MM-DD')+1) > TO_DATE(START_DATE_STATIC, 'YYYY-MM-DD'))
)
select dv.deviceid, round(total_time) total_time,
	round(total_stop_int*mi,0) as shutdown_time,
	round((total_time-total_stop_int*mi)/total_time,4)*10000 as ok_rate,
	round(total_oper_int*mi,0) as operate_time,
	round((total_time-total_oper_int*mi)/total_time,4)*10000 as operate_rate,
	round(total_device_int*mi,0) as device_time,
	round((total_time-total_device_int*mi)/total_time,4)*10000 as device_rate,
	round(total_resource_int*mi,0) as resource_time,
	round((total_time-total_resource_int*mi)/total_time,4)*10000 as resource_rate,
	round(total_host_int*mi,0) as host_time,
	round((total_time-total_host_int*mi)/total_time,4)*10000 as host_rate
from device dv,
(
	select deviceid,
		sum(case when category='oos' then (end_time-start_time) else 0 end ) AS total_stop_int,
		sum(case when category='oos_sop' then (end_time-start_time) else 0 end ) AS total_oper_int,
		sum(case when category='host' then (end_time-start_time) else 0 end ) AS total_host_int,
		sum(case when category='hardware' then (end_time-start_time) else 0 end ) AS total_device_int,
		sum(case when category='resource' then (end_time-start_time) else 0 end ) AS total_resource_int,
		sum(case when category='proview' then (end_time-start_time) else 0 end ) AS total_proview_int,
		sum(case when category='nocash' then (end_time-start_time) else 0 end ) AS total_nocash_int
	from
	(
		select DEVICEID
			,      category
			,      min(start_time) start_time, max(max_end_by_now) end_time
		FROM
		(
			select pps.*
				 ,      sum(start_new_period) over ( partition by DEVICEID, category
													 order by start_time) period
			FROM
			(
				select DEVICEID, category, start_time, end_time, max_end_by_now
					,      case when start_time > lag(max_end_by_now) over ( partition by DEVICEID, category
																			order by start_time
																			)
											then 1
											else 0
											end start_new_period
				FROM (
					SELECT DEVICEID, category, start_time, end_time,
						max (end_time) over ( partition by DEVICEID, category order by start_time) max_end_by_now
					FROM
					(
						SELECT DEVICEID, start_time, end_time,
							CASE WHEN componentid in ( 8,19,20,21 ) THEN 'resource'
							ELSE 'hardware' END AS category
						FROM timesheets
						WHERE componentid IN ( 8,19,20,21, 1,2,3,6 )
						UNION ALL
						SELECT DEVICEID, start_time, end_time, 'nocash' AS category
						FROM timesheets
						WHERE statebit = 11 or componentid in (20,1)
						UNION ALL
						select DEVICEID,  start_time, end_time, 'oos' as category
						from Timesheets where statebit = 11 and componentid = 0
						UNION ALL
						select DEVICEID, start_time, end_time, 'oos_sop' as category
						FROM Timesheets where bitand(state, 5120) = 5120 and statebit = 11 and componentid = 0
						UNION ALL
						select DEVICEID, start_time, end_time, 'host' as category
						from Timesheets where componentid = 7
						UNION ALL
						select DEVICEID, start_time, end_time, 'proview' as category
						from Timesheets where componentid = 22
					)
				)
			) pps
		)
		GROUP BY DEVICEID, category, period
		UNION ALL
		SELECT deviceid, 'filler', null, null FROM DEVICE
	)
	WHERE (end_time-start_time)*24*60 > 5 OR start_time is null
	GROUP BY deviceid
) sstop,
( SELECT (least(TO_DATE(END_DATE_STATIC, 'YYYY-MM-DD')+1,sysdate)-TO_DATE(START_DATE_STATIC, 'YYYY-MM-DD'))*24*60 AS total_time, 24*60 AS mi FROM DUAL) c
WHERE dv.deviceid = sstop.deviceid;
'''

print(content.replace('START_DATE_STATIC', "'2017-09-09'").replace('END_DATE_STATIC', "'2017-09-09'"))
# print(fixcontent.replace('START_DATE_STATIC', "'2017-09-09'").replace('END_DATE_STATIC', "'2017-09-09'"))

print("done!!!")
