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
WHERE user_name NOT in ('admin','EOLMOSGALLEGO', 'ES00529975')
;
UPDATE cmn_sec_users
SET is_ldap = 0
--,ALLOW_DIRECT_LOGIN = 0
WHERE is_ldap=1
;

--paso 9: workflow maintenance
select * from odf_ca_pro_workflow_main
;
update odf_ca_pro_workflow_main
set url = 'preclarity.prosegur.net'
,pro_url_xog = 'esdc1cshwa135.emea.prosegur.local'
,url_jasper = 'ESDC1CSHWA029.emea.prosegur.local'
,pro_ruta_cargas = '\\ESDC1CSHWA136\lectura'
,pro_remi_correo = 'clarity.preproduccion@prosegur.com'
,pro_cuenta_pmo = 'clarity.preproduccion@prosegur.com'
,pro_cuenta_dti_pmo = 'clarity.preproduccion@prosegur.com'
,email_pgi = 'clarity.preproduccion@prosegur.com'
,pro_email_seginf = 'clarity.preproduccion@prosegur.com'
,pro_email_p_mdc = 'clarity.preproduccion@prosegur.com'
,pro_correo_fv = 'clarity.preproduccion@prosegur.com'
,pro_erp_endp_report = 'https://emgy-test.fa.em4.oraclecloud.com/xmlpserver/services/PublicReportService'
,pro_erpcl_endpoint = 'https://emgy-test.fa.em4.oraclecloud.com/fscmRestApi/resources/11.13.18.05/valueSets/XX_POR_PGI_CLARITY_PROJECTS/child/values/'
where id = 5000000
;

--paso 13
-- Comprobar si dentro de gel-script hace referencia a maquinas de prod.
-- Si hay resultados hay que cambiarlo a preclarity.

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
WHERE UPPER(script_text) LIKE UPPER('%pro_clarity.%')
	AND pv.user_status_code = 'BPM_PUS_ACTIVE'
;
update cmn_custom_scripts
set script_text = replace(script_text, 'pro_clarity.','pro_clarityp.')
where UPPER(script_text) LIKE UPPER('%pro_clarity.%')
;
update cmn_custom_scripts
set script_text = replace(script_text, 'infoclarity.prosegur.','preclarity.prosegur.')
where UPPER(script_text) LIKE UPPER('%infoclarity.prosegur.%')
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
WHERE UPPER(script_text) LIKE UPPER('%/infoclarity%')
	AND pv.user_status_code = 'BPM_PUS_ACTIVE'
;
--ppm.prosegur.local
--clarity.prosegur.net
--clarity.prosegur.com
--clarity.prosegur.es
-- 3 lineas encontradas
UPDATE CMN_CUSTOM_SCRIPTS
SET SCRIPT_TEXT = REPLACE(script_text, 'https://clarity.prosegur.com', 'https://preclarity.prosegur.net')
WHERE ID IN (
		SELECT script.id
		FROM bpm_def_processes p
		JOIN bpm_def_process_versions pv ON p.id = pv.process_id
		JOIN bpm_def_stages stage ON stage.process_version_id = pv.id
		JOIN bpm_def_steps step ON step.stage_id = stage.id
		JOIN bpm_def_step_actions action ON action.step_id = step.id
		JOIN cmn_custom_scripts script ON script.id = action.script_id
		WHERE UPPER(script_text) LIKE UPPER('%https://clarity.prosegur.com%')
		)      
;
--1 linea encontrada
UPDATE CMN_CUSTOM_SCRIPTS
SET SCRIPT_TEXT = REPLACE(script_text, 'https://clarity.prosegur.net', 'https://preclarity.prosegur.net')
WHERE ID IN (
		SELECT script.id
		FROM bpm_def_processes p
		JOIN bpm_def_process_versions pv ON p.id = pv.process_id
		JOIN bpm_def_stages stage ON stage.process_version_id = pv.id
		JOIN bpm_def_steps step ON step.stage_id = stage.id
		JOIN bpm_def_step_actions action ON action.step_id = step.id
		JOIN cmn_custom_scripts script ON script.id = action.script_id
		WHERE UPPER(script_text) LIKE UPPER('%https://clarity.prosegur.net%')
		)
;
--42 lineas coincidentes
UPDATE CMN_CUSTOM_SCRIPTS
SET SCRIPT_TEXT = REPLACE(script_text, 'http://clarity.prosegur.es', 'https://preclarity.prosegur.net')
WHERE ID IN (
		SELECT script.id
		FROM bpm_def_processes p
		JOIN bpm_def_process_versions pv ON p.id = pv.process_id
		JOIN bpm_def_stages stage ON stage.process_version_id = pv.id
		JOIN bpm_def_steps step ON step.stage_id = stage.id
		JOIN bpm_def_step_actions action ON action.step_id = step.id
		JOIN cmn_custom_scripts script ON script.id = action.script_id
		WHERE UPPER(script_text) LIKE UPPER('%http://clarity.prosegur.es%')
		)
;
--36 lineas coincidentes
UPDATE CMN_CUSTOM_SCRIPTS
SET SCRIPT_TEXT = REPLACE(script_text, 'http://ppm.prosegur.local', 'https://preclarity.prosegur.net')
WHERE ID IN (
		SELECT script.id
		FROM bpm_def_processes p
		JOIN bpm_def_process_versions pv ON p.id = pv.process_id
		JOIN bpm_def_stages stage ON stage.process_version_id = pv.id
		JOIN bpm_def_steps step ON step.stage_id = stage.id
		JOIN bpm_def_step_actions action ON action.step_id = step.id
		JOIN cmn_custom_scripts script ON script.id = action.script_id
		WHERE UPPER(script_text) LIKE UPPER('%http://ppm.prosegur.local%')
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
/* estos campos ya no estan disponibles
update odf_ca_project
set new_iu = replace(new_iu, '//clarity.prosegur.es', '//preclarity.prosegur.com')
,new_iu_sr = replace(new_iu_sr, '//clarity.prosegur.es', '//preclarity.prosegur.com')
where 1=1
;
update odf_ca_project
set new_iu = replace(new_iu, '//clarity.prosegur.com', '//preclarity.prosegur.com')
,new_iu_sr = replace(new_iu_sr, '//clarity.prosegur.com', '//preclarity.prosegur.com')
where 1=1
;
update odf_ca_project
set new_iu = replace(new_iu, '//ppm.prosegur.local', '//preclarity.prosegur.com')
,new_iu_sr = replace(new_iu_sr, '//ppm.prosegur.local', '//preclarity.prosegur.com')
where 1=1
;
*/
--select distinct substr(pro_enlace_cuest_ben,0,28) from odf_ca_incident
update odf_ca_incident
set pro_enlace_cuest_ben = replace(pro_enlace_cuest_ben, '//clarity.prosegur.net', '//preclarity.prosegur.net')
where pro_enlace_cuest_ben like '%//clarity.prosegur.net%'
;
update odf_ca_incident
set pro_enlace_cuest_ben = replace(pro_enlace_cuest_ben, '//clarity.prosegur.com', '//preclarity.prosegur.net')
where pro_enlace_cuest_ben like '%//clarity.prosegur.com%'
;
update odf_ca_incident
set pro_enlace_cuest_ben = replace(pro_enlace_cuest_ben, '//ppm.prosegur.local', '//preclarity.prosegur.net')
where pro_enlace_cuest_ben like '%//ppm.prosegur.local%'
;
update odf_ca_incident
set pro_enlace_cuest_ben = replace(pro_enlace_cuest_ben, '//clarity.prosegur.es', '//preclarity.prosegur.net')
where pro_enlace_cuest_ben like '%//clarity.prosegur.es%'
;
--select distinct substr(url,0,28) from odf_ca_pet_asociacion
update odf_ca_pet_asociacion
set URL = replace(url, '//ppm.prosegur.local', '//preclarity.prosegur.net')
where URL like '%//ppm.prosegur.local%'
;
update odf_ca_pet_asociacion
set URL = replace(url, '//clarity.prosegur.com', '//preclarity.prosegur.net')
where URL like '%//clarity.prosegur.com%'
;
update odf_ca_pet_asociacion
set URL = replace(url, '//clarity.prosegur.net', '//preclarity.prosegur.net')
where URL like '%//clarity.prosegur.net%'
;
-- paso 18 ------------------------------- solo ejecutar el update con resultados.
select * from cmn_captions_nls where upper(description) like upper('%//ppm.prosegur.local%') --0
select * from cmn_captions_nls where upper(description) like upper('%//clarity.prosegur.net%') --0
select * from cmn_captions_nls where upper(description) like upper('%//clarity.prosegur.com%') --35
;
update cmn_captions_nls set description = replace(description, '//ppm.prosegur.local','//preclarity.prosegur.net') where upper(description) like upper('%//ppm.prosegur.local%');
update cmn_captions_nls set description = replace(description, '//clarity.prosegur.net','//preclarity.prosegur.net') where upper(description) like upper('%//clarity.prosegur.net%');
update cmn_captions_nls set description = replace(description, '//clarity.prosegur.com','//preclarity.prosegur.net') where upper(description) like upper('%//clarity.prosegur.com%');

--paso 19 ----------------------------------------------------
select trigger_name from all_triggers;

--------------------------------------------------------------------------

-- paso 2
admin db compile
admin search recreate-index-data
admin search recreate-index-files

--paso 6
-- INICIAR SERVICIO APP
service deploy beacon nsa app
service start beacon nsa
service start app
;
-- paso 7: Heatlh report
--paso 8: cambiar theme
-- cambiar enlaces: Admin/Objetos/proyecto/acciones
--		Enlace a la nueva interfaz
--		Hojas de tiempo

-- paso 20. realizar con bg iniciado
SELECT * FROM BPM_RUN_PROCESSES WHERE PROCESS_VERSION_ID NOT IN (SELECT ID FROM BPM_DEF_PROCESS_VERSIONS);
DELETE FROM BPM_RUN_PROCESSES WHERE PROCESS_VERSION_ID NOT IN (SELECT ID FROM BPM_DEF_PROCESS_VERSIONS)
SELECT * FROM BPM_RUN_PROCESS_ENGINES WHERE END_DATE != NULL OR END_DATE <= SYSDATE;
DELETE FROM BPM_RUN_PROCESS_ENGINES WHERE END_DATE != NULL or END_DATE <= SYSDATE

--reiniciar bg
--paso 10
select * from cmn_sessions



