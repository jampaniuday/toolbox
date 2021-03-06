-- gives an historical overview of the backups for all the databases in the past year (whether or not they are still available)
-- the reported sizes and timings are for the entire (original) set and may not reflect the real status
--
-- needs to be executed against the rman catalog schema

set linesize 300
set pages 50000

column time_taken_display format a15
column GB format 999G999D99
column db_unique_name format a15
column start_time format a18
column end_time format a18

break on db_unique_name skip 1 on dbid

with
  rman_history as
  ( select
    distinct
    rs.session_key,
    rs.db_key,
    rs.site_key
  from
    rc_rman_status rs
  )
select
  site.db_unique_name,
  db.dbid,
  jobd.session_key,
  to_char(jobd.start_time,'DD/MM/YYYY HH24:MI') start_time ,
  to_char(jobd.end_time,'DD/MM/YYYY HH24:MI') end_time,
  jobd.time_taken_display,
  jobd.input_type,
  jobd.status,
  jobd.output_device_type,
  (jobd.output_bytes/1024/1024/1024) GB
from
  rman_history                  rh,
  rc_site                       site,
  rc_database                   db,
  rc_rman_backup_job_details    jobd
where
  site.site_key = rh.site_key
  and db.db_key = rh.db_key
  and rh.session_key = jobd.session_key
  and jobd.start_time >= add_months(trunc(sysdate),-12)
order by
  site.db_unique_name,
  jobd.start_time
;

clear breaks;
