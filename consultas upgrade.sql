/***************** PRE REQUISITOS *********************/
--Espacio BBDD   (NIKU) 
Select Df.Tablespace_Name "Tablespace",  Totalusedspace "Used MB",  (Df.Totalspace - Tu.Totalusedspace) "Free MB",  Df.Totalspace "Total MB",  Round(100 * ( (Df.Totalspace - Tu.Totalusedspace)/ Df.Totalspace))  "Pct. Free", Autoextensible  From  (Select Tablespace_Name,  Round(Sum(Bytes) / 1048576) Totalspace, Autoextensible  From Dba_Data_Files  Group By Tablespace_Name, Autoextensible) Df,  (Select Round(Sum(Bytes)/(1024*1024)) Totalusedspace, Tablespace_Name  From Dba_Segments  Group By Tablespace_Name) Tu  Where Df.Tablespace_Name = Tu.Tablespace_Name
;   
-- parametros (NIKU) y PPM_DWH
SELECT LOWER(parameter) "Parámetro", value "Valor" FROM nls_database_parameters WHERE parameter IN ('NLS_CHARACTERSET', 'NLS_NCHAR_CHARACTERSET', 'NLS_DATE_FORMAT', 'NLS_SORT', 'NLS_COMP') UNION SELECT name "Parámetro", value "Valor" FROM v$parameter WHERE name IN ('query_rewrite_enabled', 'cursor_sharing')
;
--permisos niku (NIKU)
SELECT * FROM USER_SYS_PRIVS where username = 'NIKU'
;
--(PPM_DWH)
SELECT * FROM USER_SYS_PRIVS where username = 'PPM_DWH'
;

-- COMPROBACIÓN DBLINK (PPM_DWH)
SELECT count(1) FROM srm_resources@PPMDBLINK
;
-- COMPROBACION DE ESPACIO (niku)
select SLC.owner, SLC.table_name, SLC.TABLESPACE_NAME, SLC.MB MB_NEEDED, TBSPC.MB_FREE MB_FREE, SIZING.MAX_MB, SIZING.MB_USED,EXT.AUTOEXTENSIBLE
FROM (select owner, table_name, NVL(round((num_rows*avg_row_len)/(1024*1024)),0) MB, TABLESPACE_NAME
from all_tables 
where owner = 'NIKU'
and table_name = 'PRJ_BLB_SLICES') SLC
INNER JOIN (select df.tablespace_name,
(df.totalspace - tu.totalusedspace) "MB_FREE"
from
(select tablespace_name, 
round(sum(bytes) / 1048576) TotalSpace
from dba_data_files
group by tablespace_name) df,
(select round(sum(bytes)/(1024*1024)) totalusedspace, tablespace_name
from dba_segments
group by tablespace_name) tu
where df.tablespace_name = tu.tablespace_name) TBSPC ON (SLC.TABLESPACE_NAME = TBSPC.TABLESPACE_NAME)
INNER JOIN (select distinct(autoextensible), tablespace_name from dba_data_files) EXT on (slc.tablespace_name = ext.tablespace_name)
INNER JOIN (select tablespace_name
, sum(MAXBYTES)/(1024*1024) as MAX_MB
, sum(user_bytes)/(1024*1024) MB_USED
, round((sum(user_bytes)/(1024*1024))/(sum(MAXBYTES)/(1024*1024))*100,2) PERCENT_USED
from dba_data_files
group by tablespace_name) SIZING ON (SLC.TABLESPACE_NAME = SIZING.TABLESPACE_NAME)
;
-- Verificar espacio(NIKU)
SELECT ESTIMATED_DWH_SIZE_IN_GB FROM DWH_ESTIMATE_SIZE_V;

--Comprobar objetos invalidos:
select OWNER,OBJECT_NAME,OBJECT_TYPE,STATUS from dba_objects
where OWNER not in ('SYS','SYSTEM') and status = 'INVALID'
order by OWNER,OBJECT_TYPE,OBJECT_NAME;

/**************
NIKU
**************/
-- Comprobar si existen múltiples planes de presupuesto para una misma inversión
SELECT i.name inversion, i.code inversion_code, f.id plan_id, f.created_date plan_f_creacion
FROM inv_investments i, fin_plans f
WHERE i.id = f.object_id
AND f.plan_type_code = 'FORECAST'
AND f.is_plan_of_record = 1
AND i.code IN (SELECT i.code
FROM inv_investments i, fin_plans f
WHERE i.id = f.object_id
AND f.plan_type_code = 'FORECAST'
AND f.is_plan_of_record = 1
GROUP BY i.name, i.code
HAVING COUNT(f.is_plan_of_record) > 1)
ORDER BY i.name, i.code, f.created_date DESC;

--Verificar si existen planes de costes duplicados
SELECT p1.id, p1.code, p1.name
FROM fin_plans p1, fin_plans p2
WHERE p1.id != p2.id
AND p1.object_id = p2.object_id
AND p1.code = p2.code
AND p1.plan_type_code = p2.plan_type_code;

--Comprobar si hay recursos con la información financiera incompleta
SELECT mr.resource_code
FROM odf_resource_v2 r, pac_mnt_resources mr
WHERE r.odf_pk = mr.id
AND r.prisrole = 0
AND (mr.resource_class IS null OR mr.transclass IS null);

--Verificar la existencia de OBS con caracteres especiales
SELECT name obsname
FROM prj_obs_units
WHERE name LIKE '%/%'
OR name LIKE '%:%'
OR name LIKE '%"%'
OR LOWER(name) LIKE '%&' || 'amp;' || 'quot;%'
OR LOWER(name) LIKE '%&' || 'amp;' || 'gt;%'
OR LOWER(name) LIKE '%&' || 'amp;' || 'lt;%'
OR name LIKE '%&' || 'gt;%'
OR name LIKE '%&' || 'lt;%'
OR LOWER(name) LIKE '%&' || '’%'
OR LOWER(name) LIKE '%&' || '>%'
OR LOWER(name) LIKE '%& ' || '<%'
OR name LIKE '%>%'
OR name LIKE '%<%';

--Poner procesos ACTIVOS como ON-HOLD
SELECT p.id "ID proceso", nom.name "Proceso", est.name "Estado", mod.name "Modo"
FROM bpm_def_process_versions p, cmn_captions_nls nom, cmn_lookups_v est, cmn_lookups_v mod
WHERE p.process_id = nom.pk_id
AND p.user_status_code = 'BPM_PUS_ACTIVE'
AND nom.table_name = 'BPM_DEF_PROCESSES'
AND nom.language_code = 'en'
AND p.internal_status_code = est.lookup_code
AND est.lookup_type = 'BPM_PROCESS_INTERNAL_STATUS'
AND est.language_code = 'en'
AND p.user_status_code = mod.lookup_code
AND mod.lookup_type = 'BPM_PROCESS_USER_STATUS'
AND mod.language_code = 'en'
ORDER BY nom.name ASC;


-- Pausar jobs programados
SELECT j.id "ID trabajo", j.name "Trabajo", est.name "Estado", j.start_date "Fecha inicio", j.end_date "Repetir hasta", j.schedule_date "Programado", j.
recurrence_type "Repetición", j.minutes "Minutos", j.hours "Horas", j.months "Meses", j.days_of_month "Días del mes", j.days_of_week "Días de
semana"
FROM cmn_sch_jobs j, cmn_lookups_v est
WHERE j.status_code = est.lookup_code
AND j.status_code IN ('SCHEDULED', 'PROCESSING', 'WAITING')
AND j.recurrence_type != 0
AND est.lookup_type = 'SCH_JOB_STATUS'
AND est.language_code = 'en'
ORDER BY j.name;

--Comprobar job DWH
SELECT JL.* FROM CMN_SCH_JOB_RUNS JR
INNER JOIN CMN_SCH_JOBS J ON J.ID = JR.JOB_ID AND J.JOB_DEFINITION_ID = 5000902--5000249--5000180
INNER JOIN CMN_SCH_JOB_LOGS JL ON JL.JOB_RUN_ID = JR.ID
WHERE JR.START_DATE = (SELECT MAX(JR.START_DATE) FROM CMN_SCH_JOB_RUNS JR
INNER JOIN CMN_SCH_JOBS J ON J.ID = JR.JOB_ID AND J.JOB_DEFINITION_ID = 5000902)--5000249--5000180
order by jl.created_date;

--
exec NBI_Clean_Datamart_sp;
TRUNCATE TABLE prlock;
--
drop view odfsec_odf_ui_actions_v2;
drop view odf_odf_ui_actions_v2;

-- Clean orphaned process engines
 DELETE FROM bpm_run_process_engines WHERE end_date != NULL OR end_date <= sysdate
;
-- Clean orphaned process instances
DELETE FROM bpm_run_processes WHERE process_version_id NOT IN (SELECT id FROM bpm_def_process_versions)
;
-- Change status of process instances "stuck"
UPDATE bpm_run_processes SET status_code = 'BPM_PIS_ABORTED' WHERE status_code = 'BPM_PIS_ABORTING' 
;
--
select * from INF_EST_PROY_OM_V WHERE CODIGO_PROYECTO = 'PR9816'




