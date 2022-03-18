prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_210200 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2021.10.15'
,p_release=>'21.2.5'
,p_default_workspace_id=>23838716055288612897
,p_default_application_id=>52927
,p_default_id_offset=>10923549946542564863
,p_default_owner=>'FGROTE'
);
end;
/
 
prompt APPLICATION 52927 - Web Auth
--
-- Application Export:
--   Application:     52927
--   Name:            Web Auth
--   Date and Time:   20:34 Freitag März 18, 2022
--   Exported By:     GERMANBEVER@GMAIL.COM
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 40243499165895683198
--   Manifest End
--   Version:         21.2.5
--   Instance ID:     63113759365424
--

begin
  -- replace components
  wwv_flow_api.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/process_type/de_fgrote_webauthn_publickey_login
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(40243499165895683198)
,p_plugin_type=>'PROCESS TYPE'
,p_name=>'DE.FGROTE.WEBAUTHN.PUBLICKEY.LOGIN'
,p_display_name=>'Web Authentication Public Key Login'
,p_supported_ui_types=>'DESKTOP'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_PROC:APEX_APPLICATION_PAGE_ITEMS'
,p_api_version=>2
,p_execution_function=>'WEBAUTHN_PK_DEV.login_process'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'Uses Custom Java RSHA256 Veryfication Procedures:',
'- verify_rsha256',
'- hash_sha256 -- https://dzone.com/articles/hashing-with-sha-256-in-oracle-11g-r2',
'ALSO check this http://jakub.wartak.pl/blog/?m=201704'))
,p_version_identifier=>'1.0'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(40288079455988969604)
,p_plugin_id=>wwv_flow_api.id(40243499165895683198)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Challenge holding Item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>true
,p_is_translatable=>false
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(40290697163777104446)
,p_plugin_id=>wwv_flow_api.id(40243499165895683198)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Assertion holding Item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>true
,p_is_translatable=>false
);
end;
/
prompt --application/end_environment
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done
