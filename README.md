--**********************************************************************************
-- BUSCAR CONCIDENCIAS DENTRO DE GELSCRIPTS
--**********************************************************************************
-- PARA EJECUTAR EN nsql sERVER HAY QUE HACER UPPER(CAST(<<campo>> AS NVARCHAR(MAX))) 
SELECT * FROM cmn_attributes
;
select * from odf_custom_attributes
;
--procesos
select p.process_code
       , p.name
       , p.description
       , s.name
       , st.name
       , sta.name
       , sc.id
       , sc.script_text
       , pv.internal_status_code
       , pv.user_status_code
from 
       bpm_def_processes_v p
       , bpm_def_process_versions pv
       , bpm_def_stages_v s
       , bpm_def_steps_v st
       , bpm_def_step_actions_v sta
       , cmn_custom_scripts sc
where 
       p.language_code = 'es'
       and s.language_code = 'es'
       and st.language_code = 'es'
       and sta.LANGUAGE_CODE = 'es'
       and pv.user_status_code = 'BPM_PUS_ACTIVE'
       and p.id = pv.process_id
       and pv.id = s.process_version_id
       and s.id = st.stage_id
       and st.id = sta.step_id
       and sta.script_id = sc.id
       --Filtrar aqui por el texto que buscamos en los gelscripts
       and UPPER(sc.script_text) like UPPER('%THH%')
       --and lower(sta.name) not like '%wf%'
    order by 1,2
;
--par�metros de proceso
select * from cmn_custom_script_params where upper(param_value) like upper('%pro_proveedor%');
--expresiones en proceso
select bdp.id, cc.name, bdp.process_code, ofe.expression 
	from bpm_def_processes bdp, cmn_captions_nls cc,
	bpm_def_process_versions bdpv, odf_filter_expressions ofe
	where cc.table_name = 'BPM_DEF_PROCESSES'
	AND bdp.id = cc.pk_id
	AND cc.language_code = 'en'
	AND bdpv.process_id = bdp.id
	AND ofe.object_code = 'BPM_DEF_PROCESS_VERSIONS'
	AND ofe.object_instance_id = bdpv.id
	AND bdpv.user_status_code = 'BPM_PUS_ACTIVE'
	AND upper(ofe.expression) like upper('%pro_proveedor%');
--lookups
select a.id 
,a.name
,a.lookup_type
,q.nsql_text
from cmn_lookup_types_v a
left join cmn_list_of_values b on a.lookup_type = b.lookup_type_code
left join cmn_nsql_queries q on q.id=b.sql_text_id
where a.language_code = 'en'
and upper(q.nsql_text) like upper('%pro_proveedor%')
;
--consultas
select * from cmn_nsql_queries N where upper(N.nsql_text) like upper('%pro_proveedor%')
;
--portlets
select query_code from CMN_GG_NSQL_QUERIES GG
INNER JOIN cmn_nsql_queries N ON N.ID = GG.CMN_NSQL_QUERIES_ID 
AND  upper(N.nsql_text) like upper('%pro_proveedor%')
;


select W.url, W.xog_user, W.xog_pass, W.email_server, W.pro_remi_correo, W.pro_cuenta_pmo, w.pro_url_jira, w.pro_url_xog
        from odf_ca_pro_workflow_main W 
        where W.name='WM_01'  
--Enviar Correo Alta de Recurso V3.3
--Enviar Informe de logros y pr�ximos hitos V1
--Generaci�n Autom�tica de Proyectos V11_D
--Enviar Correo Alta de Recurso V3.3
--Generar Documento Fin V2
--Finalizaci�n/Cancelaci�n de proyecto v37.2
--Actualizar Informe de Estado V2
--Cambio Gestor y Asignado por cambio en la PT V8
--Cambio Usuarios Negocio por cambio en la PT_Negocio_DTI V8
--Envio email a JP/DP V4
;
select obsu.id, obsu.name 
											from prj_obs_units obsu 
											inner join departments d on d.departcode = obsu.unique_name and obsu.type_id = 5000002
											inner join odf_ca_department odfd on odfd.id = d.id 
											where upper(odfd.pro_id_nuevoceco) = upper('C100')
;                                            
select d.id
													from prj_obs_units obsu 
													inner join departments d on d.departcode = obsu.unique_name and obsu.type_id = 5000002
													inner join odf_ca_department odfd on odfd.id = d.id and DPT_IS_PROVIDER_DEPT_FCT(d.ID) = 1 
													where 'C100' in d.departcode
;

select W.URL, W.XOG_USER, W.XOG_PASS, W.EMAIL_SERVER, PRO_URL_XOG
			from ODF_CA_PRO_WORKFLOW_MAIN W 
			where W.NAME='WM_01'
;            
select * from odf_ca_cyii_contrato
;
;

--5136003
;

;
SELECT
clt.lookup_type "Lookup ID",
CASE clt.is_active WHEN 1 THEN 'Yes' ELSE 'No' End "Active",
cnq.created_date "Created Date",
sr.full_name "Created By",
cnq.nsql_text "Query NSQL"
FROM
cmn_list_of_values clov, cmn_lookup_types clt, cmn_nsql_queries cnq, srm_resources sr
WHERE clt.lookup_type=clov.lookup_type_code
and cnq.id=clov.sql_text_id
and sr.user_id=cnq.created_by
;

;
/*
	   Trying to find hard coded schema names by chance?

 For GEL scripts you'll primarily want to be looking here:
 select script_text from cmn_custom_scripts;

 In case it's been put into a process script's parameters, that could be here:
 select param_value from cmn_custom_script_params;

 If you're unlucky to have used such terms in your pre/post conditions somehow, check here:
 select expression from odf_filter_expressions;

 And one other likely place to find this term if it is a schema name, will be in NSQL queries, which you can check here:
 select nsql_text from cmn_nsql_queries;

 Hope that was what you were after. If you need to stitch together the cmn_custom_scripts (gel scripts) back to a process design, it would go something like this (but I won't get to double-check this until the morning so consider this an attempt on the fly):

 select p.process_code, step.step_code, action.action_code, script.script_text
 from bpm_def_processes p
 join bpm_def_process_versions pv on p.id = pv.process_id
 join bpm_def_stages stage on stage.process_version_id = pv.id
 join bpm_def_steps step on step.stage_id = stage.id
 join bpm_def_step_actions action on action.step_id = step.id
 join cmn_custom_scripts script on script.id = action.script_id
 -- where ... add your filters here to find what you're after */
 --procesos
select distinct
caption.name process_name,
defn.process_code,
step.step_code,
to_char(ofe.expression)
from
BPM_DEF_PROCESSES defn 
inner join BPM_DEF_PROCESS_VERSIONS ver on ver.process_id=defn.id
inner join BPM_DEF_STAGES stg on stg.process_version_id=ver.id 
inner join BPM_DEF_STEPS step on step.stage_id=stg.id
left join BPM_DEF_STEP_ACTIONS action on action.step_id=step.id
left join BPM_DEF_STEP_ACTION_PARAMS parm on parm.step_action_id=action.id
left join BPM_DEF_STEP_AI_ACTIONS aiaction on aiaction.step_action_id=action.id
left join BPM_DEF_ASSIGNEES assignee on (assignee.table_name='BPM_DEF_STEP_ACTIONS' and assignee.pk_id=action.id)
left join BPM_DEF_STEP_CONDITIONS cnd on cnd.step_id=step.id
left join BPM_DEF_STEP_TRANSITIONS trnstn on trnstn.step_condition_id=cnd.id
left join CMN_CUSTOM_SCRIPTS scripts on scripts.id=action.script_id
left join CMN_CUSTOM_SCRIPT_PARAMS par on par.script_id=scripts.id
left join BPM_DEF_OBJECTS obj on (obj.pk_id=ver.id and obj.table_name='BPM_DEF_PROCESS_VERSIONS')
inner join CMN_CAPTIONS_NLS caption on (caption.table_name='BPM_DEF_PROCESSES' AND caption.language_code ='en' AND caption.pk_id=defn.id)
inner join odf_filter_expressions ofe on ofe.OBJECT_INSTANCE_ID = cnd.id
where
upper(ofe.expression) like upper('%AND x.pro_erp_project = l.pro_pgiline_erpproj%');
--procesos
select distinct
caption.name process_name,
defn.process_code,
step.step_code,
to_char(ofe.expression)
from
BPM_DEF_PROCESSES defn 
inner join BPM_DEF_PROCESS_VERSIONS ver on ver.process_id=defn.id
inner join BPM_DEF_STAGES stg on stg.process_version_id=ver.id 
inner join BPM_DEF_STEPS step on step.stage_id=stg.id
left join BPM_DEF_STEP_ACTIONS action on action.step_id=step.id
left join BPM_DEF_STEP_ACTION_PARAMS parm on parm.step_action_id=action.id
left join BPM_DEF_STEP_AI_ACTIONS aiaction on aiaction.step_action_id=action.id
left join BPM_DEF_ASSIGNEES assignee on (assignee.table_name='BPM_DEF_STEP_ACTIONS' and assignee.pk_id=action.id)
left join BPM_DEF_STEP_CONDITIONS cnd on cnd.step_id=step.id
left join BPM_DEF_STEP_TRANSITIONS trnstn on trnstn.step_condition_id=cnd.id
left join CMN_CUSTOM_SCRIPTS scripts on scripts.id=action.script_id
left join CMN_CUSTOM_SCRIPT_PARAMS par on par.script_id=scripts.id
left join BPM_DEF_OBJECTS obj on (obj.pk_id=ver.id and obj.table_name='BPM_DEF_PROCESS_VERSIONS')
inner join CMN_CAPTIONS_NLS caption on (caption.table_name='BPM_DEF_PROCESSES' AND caption.language_code ='en' AND caption.pk_id=defn.id)
inner join odf_filter_expressions ofe on ofe.OBJECT_INSTANCE_ID = ver.id
where
upper(ofe.expression) like upper('%svdesk%');
-- portlets
select p.portlet_code as portlet_code, 
n.name as portlet_name, 
gg.query_code as nsql_code, 
'grid' as portlet_type 
from cmn_portlets p 
join cmn_captions_nls n 
on n.language_code = 'en' 
and n.table_name = 'CMN_PORTLETS' 
and n.pk_id = p.id 
join cmn_grids g 
on p.id = g.portlet_id 
join cmn_gg_nsql_queries gg 
on gg.cmn_nsql_queries_id = g.dal_id 
and g.dal_type = 'nsql' 
and g.principal_type = 'SYSTEM' 
join cmn_nsql_queries q 
on gg.cmn_nsql_queries_id = q.id 
--and upper(q.nsql_text) like upper('%AND x.pro_erp_project = l.pro_pgiline_erpproj%')
union all 
select p.portlet_code as portlet_code, 
n.name as portlet_name, 
gg.query_code as nsql_code, 
'graph' as portlet_type 
from cmn_portlets p 
join cmn_captions_nls n 
on n.language_code = 'en' 
and n.table_name = 'CMN_PORTLETS' 
and n.pk_id = p.id 
join cmn_graphs g 
on p.id = g.portlet_id 
join cmn_gg_nsql_queries gg 
on gg.cmn_nsql_queries_id = g.dal_id 
and g.dal_type = 'nsql' 
and g.principal_type = 'SYSTEM' 
join cmn_nsql_queries q 
on gg.cmn_nsql_queries_id = q.id 
--and upper(q.nsql_text) like upper('%pro_liquidation_trx_%')
;
select
lookup_type "Lookup ID",
object_name "Object ID",
column_name "Attribute ID",
data_type "Data Type",
CASE is_active WHEN 1 THEN 'Yes' WHEN 0 THEN 'No' END "Active?"
FROM
ODF_CUSTOM_ATTRIBUTES
WHERE
lookup_type='SLC_DOMFUNCIONAL'
ORDER BY object_name, column_name;
select * from cmn_lookups
;
Expediente 494458299 - Adjuntar denuncia.

select id, pro_liquidation_trx_ from odf_ca_pro_pgi_fintrx_erpcl where pro_liquidation_trx_ is not null
;
UPDATE odf_ca_pro_pgi_line pl 
 SET PL.PRO_DISP_INT_DIV = CASE PL.PRO_NATURALEZA WHEN 'Personal Interno (G)' THEN NVL(NVL(PL.pro_pa_bud_am_div,0) - (NVL(PL.PRO_IMPORTE_FACT_DIV,0) + NVL(PL.PRO_IMPORT_GASTO_DIV,0)) - NVL(PL.PRO_IMPORT_PED_DIV,0),0) ELSE 0 END
 , PL.PRO_DISP_INT_EUR = CASE PL.PRO_NATURALEZA WHEN 'Personal Interno (G)' THEN NVL(NVL(PL.pro_pa_bud_am_eur,0) - (NVL(PL.PRO_IMPORT_FACTURADO,0) + NVL(PL.PRO_IMPORTE_GASTO,0)) - NVL(PL.PRO_IMPORTE_PEDIDO,0),0) ELSE 0 END
 , PL.PRO_DISPONIBLE_EUR = CASE PL.PRO_NATURALEZA WHEN 'Personal Interno (G)' THEN 0 ELSE NVL(NVL(PL.pro_pa_bud_am_eur,0) - (NVL(PL.PRO_IMPORT_FACTURADO,0) + NVL(PL.PRO_IMPORTE_GASTO,0)) - NVL(PL.PRO_IMPORTE_PEDIDO,0),0) END
 , PL.PRO_DISPONIBLE_DIV = CASE PL.PRO_NATURALEZA WHEN 'Personal Interno (G)' THEN 0 ELSE NVL(NVL(PL.pro_pa_bud_am_div,0) - (NVL(PL.PRO_IMPORTE_FACT_DIV,0) + NVL(PL.PRO_IMPORT_GASTO_DIV,0)) - NVL(PL.PRO_IMPORT_PED_DIV,0),0) END 
 WHERE PL.PRO_PGI_LINE_ID = 2286842 
 AND 
 (SELECT PGI.PRO_IS_APPROVED 
 FROM odf_ca_pro_pgi pgi 
 WHERE pgi.pro_pgi_header_id=pl.PRO_PGI_HEADER_ID AND PGI.CREATED_DATE = (SELECT MAX(X.CREATED_DATE) FROM odf_ca_pro_pgi X WHERE X.pro_pgi=pgi.pro_pgi) ) = '*'
;
select distinct i.id,
                i.code,
                i.name,
                p.s_inicio_ep,
                to_char(add_months(p.s_fin_pro_inf_exp_ep, 48), 'YYYY-MM-DD') || 'T00:00:00' s_f_est_fin_en,
                (SELECT to_char(max(t.prfinish), 'YYYY-MM-DD') || 'T01:00:00'
                      FROM odf_project_v2 p
                      INNER JOIN odf_task_v2 t ON t.prprojectid=p.odf_pk
                      WHERE t.s_tar_principal='Si'
                      AND p.odf_pk=i.id ) p_con_ajuste
				,upper(p.s_crear_linea_base)
                from inv_investments i
                inner join odf_ca_project p on p.id=i.id
                inner join prtask t on t.prprojectid = i.id
                inner join odf_ca_task t2 on t2.id = t.prid
                where i.odf_blueprint_id = 5000000
                and t2.s_tar_principal = 'Si'
;
select distinct fl.id, fl.parent_folder_id, fl.name, fl.path_name ,count(f.name)
		from clb_dms_folders fl
		left join clb_dms_files f on f.parent_folder_id = fl.id
		connect by prior fl.id = fl.parent_folder_id
		start with fl.name in (select code from inv_investments where is_active = 1)
		group by fl.id, fl.parent_folder_id, fl.name, fl.path_name
		having count(f.name) > 0
		and path_name like '%PMO-00001790%'
;
select obsu.id, obsu.name,odfd.pro_id_nuevoceco
from prj_obs_units obsu 
inner join departments d on d.departcode = obsu.unique_name and obsu.type_id = 5000002
inner join odf_ca_department odfd on odfd.id = d.id 
where upper(odfd.pro_id_nuevoceco) = upper('${v_CSP_ID_CENTRO_CC}')
;
select PA_TASK_BUDGET_AMOUNT_EUR from apps.XGP_PGI_COSTS_TO_CLARITY_V where line_id = 2309089 --task_number like '%202409689%'
;
select pro_pa_bud_am_eur from odf_ca_pro_pgi_line where pro_pgi_line_id = '2309089'
;
SELECT PGI_LINE_ID
						,PGI_HEADER_ID
						,UFC_GET_REPLACE(LINE_DESCRIPTION)
						,nvl(PGI_LINE_AMT, 0)
						,nvl(PGI_LINE_AMT_EUR, 0)
						,LINE_TYPE
						,CASE 
							WHEN ID_CLARITY = - 1
								THEN NULL
							ELSE ID_CLARITY
							END
						,PLATAFORMA
						,PLATAFORMA_MEANING
						,COUNTRY_CODE
						,COUNTRY_NAME
						,NATURALEZA
						,PGI
						,SUBSTR(PGI_TITLE, 0, 229)
						,CASE 
							WHEN CURRENCY_CODE = 'UYP'
								THEN 'UYU'
							ELSE CURRENCY_CODE
							END CURRENCY_CODE
						,nvl(LINE_BUDGETED_AMOUNT, 0)
						,nvl(LINE_BUDGETED_AMOUNT_EUR, 0)
						,rownum
						,CAPEX_PROJECT
						,LINE_TYPE_MEANING
						,STATUS
						,APPROVAL_STATUS_MEANING
						,NON_BUDGETED_LINE
						,NVL(PGI_HEADER_AMOUNT, 0)
						,CASE 
							WHEN HEADER_CURRENCY_CODE = 'UYP'
								THEN 'UYU'
							ELSE NVL(HEADER_CURRENCY_CODE, '-')
							END HEADER_CURRENCY_CODE
						,NVL(RATE, 0)
						,NVL(to_char(RATE_DATE, 'YYYY-MM-DD') || 'T' || to_char(sysdate, 'hh:mm:ss'), 0)
						,nvl(PA_TASK_BUDGET_AMOUNT, 0)
						,nvl(PA_TASK_BUDGET_AMOUNT_EUR, 0)
						,AREA_MEANING
						,DEPARTMENT_MEANING
						,case when PROJECT_COMPLETION_DATE is null then ''
							else
								to_char(PROJECT_COMPLETION_DATE, 'YYYY-MM-DD"T"HH24:mm:ss')
							end
						,ID_PRESUPUESTO
					select * FROM XGP_PGI_COSTS_TO_CLARITY--XGP_PGI_LINES_TO_CLARITY_TEMP
                    where pgi_line_id = 2309089
;
SELECT PGI_HEADER_ID, PGI_LINE_ID, PGI, 
						       replace(PGI_TITLE,'''',''''''), 
							   replace(SOLICITANTE,'''',''''''), 
							   replace(PGI_DESCRIPTION,'''',''''''), 
						       replace(LINE_DESCRIPTION,'''',''''''), 
							   CAPEX_PROJECT, 
							   NVL(PGI_TOTAL_AMT,0), CURRENCY_CODE, 
							   NVL(PGI_TOTAL_AMT_EUR,0), 
							   NVL(PGI_LINE_AMT,0), NVL(PGI_LINE_AMT_EUR,0), 
							   TO_CHAR(START_DATE, 'DD-MM-YYYY'), 
							   TO_CHAR(END_DATE, 'DD-MM-YYYY'), CORPORATIVE, LINE_TYPE, 
							   replace(LINE_TYPE_MEANING,'''',''''''), 
							   replace(AREA,'''',''''''), 
							   replace(AREA_MEANING,'''',''''''), 
							   replace(ACTIVITY,'''',''''''), 
							   replace(STATUS,'''',''''''), 
							   replace(APPROVAL_STATUS_MEANING,'''',''''''), 
							   ID_CLARITY, 
							   TO_CHAR(FECHA_CANCELACION, 'DD-MM-YYYY'), 
							   TO_CHAR(FECHA_ULTIMA_ACCION, 'DD-MM-YYYY'), IS_CANCELED, IS_APPROVED, 
							   replace(PLATAFORMA,'''',''''''), 
							   replace(PLATAFORMA_MEANING,'''',''''''), NATURALEZA, 
							   replace(COUNTRY_CODE,'''',''''''), 
							   replace(COUNTRY_NAME,'''',''''''), 
							   NVL(BUDGETED_AMOUNT,0), 
							   NVL(BUDGETED_AMOUNT_EUR,0), 
							   NVL(LINE_BUDGETED_AMOUNT,0), 
							   NVL(LINE_BUDGETED_AMOUNT_EUR,0), 
							   replace(DEPARTMENT,'''',''''''), 
							   replace(DEPARTMENT_MEANING,'''',''''''), NON_BUDGETED_LINE, 
							   NVL(PGI_HEADER_AMOUNT,0), 
							   HEADER_CURRENCY_CODE, 
							   TO_CHAR(RATE_DATE, 'DD-MM-YYYY HH24:MI:SS'), 
							   NVL(RATE,0), 
							   TO_CHAR(LAST_UPDATE_DATE, 'DD-MM-YYYY HH24:MI:SS'), 
							   NVL(PA_TASK_BUDGET_AMOUNT,0), 
							   NVL(PA_TASK_BUDGET_AMOUNT_EUR,0)
							   , TO_CHAR(PROJECT_COMPLETION_DATE,'DD-MM-YYYY HH24:MI:SS')
							   , ID_PRESUPUESTO
						FROM apps.XGP_PGI_LINES_TO_CLARITY_V
                        where pgi_line_id = 2309089
;
select * from odf_ca_project
