select * from all_tab_cols
--Procedimiento Refresco BBDD
--paso 3
UPDATE cmn_sec_users
SET email_address = 'clarity.preproduccion@prosegur.com'
WHERE user_name NOT IN ('EOLMOSGALLEGO', 'ES00529975'); -- Añadir a Javier Septiem
UPDATE srm_resources
SET email = 'clarity.preproduccion@prosegur.com'
WHERE unique_name NOT IN ('EOLMOSGALLEGO', 'ES00529975');
;
select distinct email_address from cmn_sec_users;
select distinct email from srm_resources;
--paso 4
UPDATE odf_ca_incident
SET telefono_trabajo='clarity.preproduccion@prosegur.com'
WHERE telefono_trabajo is not null
;
--paso 5
UPDATE cmn_sec_users
SET pwd = 'b42405b42403363643138303638e2c88b5fba6a344802b52483cf12f5bf',
salt = '[B@3cd18068'
WHERE user_name NOT LIKE 'admin'
;
UPDATE cmn_sec_users
SET is_ldap=0
WHERE is_ldap=1
;
--paso 6
-- INICIAR SERVICIO APP
service deploy beacon nsa app
service start beacon nsa
service start app
;
--paso 9: workflow maintenance
select * from odf_ca_pro_workflow_main
;
update odf_ca_pro_workflow_main
set url = 'preclarity.prosegur.net'
,pro_url_xog = 'esdc1cshwa135.emea.prosegur.local'
,url_jasper = ''
,pro_ruta_cargas = '\\ESDC1CSHWA136\lectura'
,pro_remi_correo = 'clarity.preproduccion@prosegur.com'
,pro_cuenta_pmo = 'clarity.preproduccion@prosegur.com'
,pro_cuenta_dti_pmo = 'clarity.preproduccion@prosegur.com'
,email_pgi = 'clarity.preproduccion@prosegur.com'
,pro_email_seginf = 'clarity.preproduccion@prosegur.com'
,pro_email_p_mdc = 'clarity.preproduccion@prosegur.com'
,pro_correo_fv = 'clarity.preproduccion@prosegur.com'
where id = 5000000
;
--paso 13
SELECT p.process_code
	,(
		SELECT name
		FROM CMN_CAPTIONS_NLS trad
		WHERE trad.table_name = 'BPM_DEF_PROCESSES'
			AND trad.language_code = 'en'
			AND trad.pk_id = p.id
		) AS NombreProceso
	,step.step_code
	,(
		SELECT name
		FROM CMN_CAPTIONS_NLS trad
		WHERE trad.table_name = 'BPM_DEF_STEPS'
			AND trad.language_code = 'en'
			AND trad.pk_id = step.id
		) AS NombrePaso
	,action.action_code
	,(
		SELECT name
		FROM CMN_CAPTIONS_NLS trad
		WHERE trad.table_name = 'BPM_DEF_STEP_ACTIONS'
			AND trad.language_code = 'en'
			AND trad.pk_id = action.id
		) AS NombreAccion
	,script.script_text
FROM bpm_def_processes p
JOIN bpm_def_process_versions pv ON p.id = pv.process_id
JOIN bpm_def_stages stage ON stage.process_version_id = pv.id
JOIN bpm_def_steps step ON step.stage_id = stage.id
JOIN bpm_def_step_actions action ON action.step_id = step.id
JOIN cmn_custom_scripts script ON script.id = action.script_id
WHERE UPPER(script_text) LIKE UPPER('%preclarity.prosegur.com%')
	AND pv.user_status_code = 'BPM_PUS_ACTIVE'
;
SELECT p.process_code
	,(
		SELECT name
		FROM CMN_CAPTIONS_NLS trad
		WHERE trad.table_name = 'BPM_DEF_PROCESSES'
			AND trad.language_code = 'en'
			AND trad.pk_id = p.id
		) AS NombreProceso
	,step.step_code
	,(
		SELECT name
		FROM CMN_CAPTIONS_NLS trad
		WHERE trad.table_name = 'BPM_DEF_STEPS'
			AND trad.language_code = 'en'
			AND trad.pk_id = step.id
		) AS NombrePaso
	,action.action_code
	,(
		SELECT name
		FROM CMN_CAPTIONS_NLS trad
		WHERE trad.table_name = 'BPM_DEF_STEP_ACTIONS'
			AND trad.language_code = 'en'
			AND trad.pk_id = action.id
		) AS NombreAccion
	,script.script_text
FROM bpm_def_processes p
JOIN bpm_def_process_versions pv ON p.id = pv.process_id
JOIN bpm_def_stages stage ON stage.process_version_id = pv.id
JOIN bpm_def_steps step ON step.stage_id = stage.id
JOIN bpm_def_step_actions action ON action.step_id = step.id
JOIN cmn_custom_scripts script ON script.id = action.script_id
WHERE UPPER(script_text) LIKE UPPER('%/preclarity.prosegur.net%')
	AND pv.user_status_code = 'BPM_PUS_ACTIVE'
;
--preppm.prosegur.local
--preclarity.prosegur.net
--preclarity.prosegur.com
UPDATE CMN_CUSTOM_SCRIPTS
SET SCRIPT_TEXT = REPLACE(script_text, 'http://preclarity.prosegur.com', 'https://preclarity.prosegur.net')
WHERE ID IN (
		SELECT script.id
		FROM bpm_def_processes p
		JOIN bpm_def_process_versions pv ON p.id = pv.process_id
		JOIN bpm_def_stages stage ON stage.process_version_id = pv.id
		JOIN bpm_def_steps step ON step.stage_id = stage.id
		JOIN bpm_def_step_actions action ON action.step_id = step.id
		JOIN cmn_custom_scripts script ON script.id = action.script_id
		WHERE UPPER(script_text) LIKE UPPER('%http://preclarity.prosegur.com%')
		)      
;
UPDATE 
CMN_CUSTOM_SCRIPTS
SET SCRIPT_TEXT = REPLACE(script_text, 'http://preclarity.', 'https://preclarity.')
WHERE ID IN (
		SELECT script.id
		FROM bpm_def_processes p
		JOIN bpm_def_process_versions pv ON p.id = pv.process_id
		JOIN bpm_def_stages stage ON stage.process_version_id = pv.id
		JOIN bpm_def_steps step ON step.stage_id = stage.id
		JOIN bpm_def_step_actions action ON action.step_id = step.id
		JOIN cmn_custom_scripts script ON script.id = action.script_id
		WHERE UPPER(script_text) LIKE UPPER('%http://preclarity.%')
		)
;
UPDATE CMN_CUSTOM_SCRIPTS
SET SCRIPT_TEXT = REPLACE(script_text, 'http://preclarity.prosegur.es', 'https://preclarity.prosegur.net')
WHERE ID IN (
		SELECT script.id
		FROM bpm_def_processes p
		JOIN bpm_def_process_versions pv ON p.id = pv.process_id
		JOIN bpm_def_stages stage ON stage.process_version_id = pv.id
		JOIN bpm_def_steps step ON step.stage_id = stage.id
		JOIN bpm_def_step_actions action ON action.step_id = step.id
		JOIN cmn_custom_scripts script ON script.id = action.script_id
		WHERE UPPER(script_text) LIKE UPPER('%http://preclarity.prosegur.es%')
		)
;
UPDATE CMN_CUSTOM_SCRIPTS
SET SCRIPT_TEXT = REPLACE(script_text, 'http://preppm.prosegur.local', 'https://preclarity.prosegur.net')
WHERE ID IN (
		SELECT script.id
		FROM bpm_def_processes p
		JOIN bpm_def_process_versions pv ON p.id = pv.process_id
		JOIN bpm_def_stages stage ON stage.process_version_id = pv.id
		JOIN bpm_def_steps step ON step.stage_id = stage.id
		JOIN bpm_def_step_actions action ON action.step_id = step.id
		JOIN cmn_custom_scripts script ON script.id = action.script_id
		WHERE UPPER(script_text) LIKE UPPER('%http://preppm.prosegur.local%')
		)
;


UPDATE cmn_nsql_queries
SET nsql_text = REPLACE (nsql_text, 'niku.', 'nikup.')
WHERE nsql_text LIKE '%niku.%'
;
UPDATE cmn_nsql_queries
SET nsql_text = REPLACE (nsql_text, 'PRO_CLARITY.', 'PRO_CLARITYP.')
WHERE nsql_text LIKE '%PRO_CLARITY.%'
;
UPDATE cmn_nsql_queries
SET nsql_text = REPLACE (nsql_text, 'NIKU.', 'NIKUP.')
WHERE nsql_text LIKE '%NIKU.%'
;
UPDATE cmn_nsql_queries
SET nsql_text = REPLACE (nsql_text, 'pro_clarity.', 'pro_clarityp.')
WHERE nsql_text LIKE '%pro_clarity.%'
;
--select distinct substr(new_iu,0,28) from odf_ca_project
--select distinct substr(new_iu_sr,0,28) from odf_ca_project
update odf_ca_project
set new_iu = replace(new_iu, 'http://preppm.prosegur.local', 'https://preclarity.prosegur.net')
,new_iu_sr = replace(new_iu_sr, 'http://preppm.prosegur.local', 'https://preclarity.prosegur.net')
where 1=1
;
update odf_ca_project
set new_iu = replace(new_iu, '//clarity.prosegur.com', '//preclarity.prosegur.net')
,new_iu_sr = replace(new_iu_sr, '//clarity.prosegur.com', '//preclarity.prosegur.net')
where 1=1
;
update odf_ca_project
set new_iu = replace(new_iu, '//ppm.prosegur.local', '//preclarity.prosegur.net')
,new_iu_sr = replace(new_iu_sr, '//ppm.prosegur.local', '//preclarity.prosegur.net')
where 1=1
;
update odf_ca_project
set new_iu = replace(new_iu, '//preclarity.prosegur.com', '//preclarity.prosegur.net')
,new_iu_sr = replace(new_iu_sr, '//preclarity.prosegur.com', '//preclarity.prosegur.net')
where 1=1
;
--select distinct substr(pro_enlace_cuest_ben,0,28) from odf_ca_incident
update odf_ca_incident
set pro_enlace_cuest_ben = replace(pro_enlace_cuest_ben, 'http://preclarity.prosegur.com', 'https://preclarity.prosegur.net')
where 1=1
;
update odf_ca_incident
set pro_enlace_cuest_ben = replace(pro_enlace_cuest_ben, 'http://preclarity.prosegur.net', 'https://preclarity.prosegur.net')
where 1=1
;
update odf_ca_incident
set pro_enlace_cuest_ben = replace(pro_enlace_cuest_ben, 'http://preppm.prosegur.local', 'https://preclarity.prosegur.net')
where 1=1
;
update odf_ca_incident
set pro_enlace_cuest_ben = replace(pro_enlace_cuest_ben, 'https://preclarity.prosegur.com', 'https://preclarity.prosegur.net')
where 1=1
;
--select distinct substr(url,0,28) from odf_ca_pet_asociacion
update odf_ca_pet_asociacion
set URL = replace(url, 'http://preppm.prosegur.local', 'https://preclarity.prosegur.net')
where 1=1
;
update odf_ca_pet_asociacion
set URL = replace(url, 'http://preclarity.prosegur.com', 'https://preclarity.prosegur.net')
where 1=1
;
update odf_ca_pet_asociacion
set URL = replace(url, 'http://preclarity.prosegur.net', 'https://preclarity.prosegur.com')
where 1=1
;
update odf_ca_pet_asociacion
set URL = replace(url, 'https://preclarity.prosegur.com', 'https://preclarity.prosegur.net')
where 1=1
;
-- paso 18 -------------------------------
select * from cmn_captions_nls where upper(description) like upper('%//preppm.prosegur.local%') --28
select * from cmn_captions_nls where upper(description) like upper('%//preclarity.prosegur.net%') --7
select * from cmn_captions_nls where upper(description) like upper('%//preclarity.prosegur.com%') --7
;
update cmn_captions_nls set description = replace(description, 'http://preppm.prosegur.local','https://preclarity.prosegur.com') where upper(description) like upper('%http://preppm.prosegur.local%');
update cmn_captions_nls set description = replace(description, 'http://clarity.prosegur.net','https://preclarity.prosegur.com') where upper(description) like upper('%http://preclarity.prosegur.net%');
--update cmn_captions_nls set description = replace(description, 'http://clarity.prosegur.com','https://preclarity.prosegur.net') where upper(description) like upper('%http://preclarity.prosegur.com%');
update cmn_captions_nls set description = replace(description, 'https://clarity.prosegur.net','https://preclarity.prosegur.com') where upper(description) like upper('%https://preclarity.prosegur.net%');

--paso 19 ----------------------------------------------------
select trigger_name from all_triggers;

-- paso 20
SELECT * FROM BPM_RUN_PROCESSES WHERE PROCESS_VERSION_ID NOT IN (SELECT ID FROM BPM_DEF_PROCESS_VERSIONS);
DELETE FROM BPM_RUN_PROCESSES WHERE PROCESS_VERSION_ID NOT IN (SELECT ID FROM BPM_DEF_PROCESS_VERSIONS)
SELECT * FROM BPM_RUN_PROCESS_ENGINES WHERE END_DATE != NULL OR END_DATE <= SYSDATE;
DELETE FROM BPM_RUN_PROCESS_ENGINES WHERE END_DATE != NULL or END_DATE <= SYSDATE

--------------------------------------------------------------------------
-- paso 2
admin db compile
admin search recreate-index-data
admin search recreate-index-files
--paso 7: Heatlh report
--paso 8: cambiar theme
--paso 10
select * from cmn_sessions



