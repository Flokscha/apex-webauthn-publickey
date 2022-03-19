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
--   Date and Time:   10:00 Samstag März 19, 2022
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
,p_execution_function=>'WEBAUTHN_PK.login_process'
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
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(49242101012846498429)
,p_plugin_id=>wwv_flow_api.id(40243499165895683198)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'User Verification'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'discouraged'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'A WebAuthn Relying Party may require user verification for some of its operations but not for others, and may use this type to express its needs.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(49242190016408116075)
,p_plugin_attribute_id=>wwv_flow_api.id(49242101012846498429)
,p_display_sequence=>10
,p_display_value=>'discouraged'
,p_return_value=>'discouraged'
,p_help_text=>'This value indicates that the Relying Party does not want user verification employed during the operation (e.g., in the interest of minimizing disruption to the user interaction flow).'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(49242192615210117971)
,p_plugin_attribute_id=>wwv_flow_api.id(49242101012846498429)
,p_display_sequence=>20
,p_display_value=>'preferred'
,p_return_value=>'preferred'
,p_help_text=>'This value indicates that the Relying Party prefers user verification for the operation if possible, but will not fail the operation if the response does not have the UV flag set.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(49242194222006119050)
,p_plugin_attribute_id=>wwv_flow_api.id(49242101012846498429)
,p_display_sequence=>30
,p_display_value=>'required'
,p_return_value=>'required'
,p_help_text=>'This value indicates that the Relying Party requires user verification for the operation and will fail the operation if the response does not have the UV flag set.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(49251132934386717490)
,p_plugin_id=>wwv_flow_api.id(40243499165895683198)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Stop on Cloned Risk'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'If authData.signCount is',
'greater than storedSignCount:',
'Update storedSignCount to be the value of authData.signCount.',
'less than or equal to storedSignCount:',
'This is a signal that the authenticator may be cloned, i.e. at least two copies of the credential private key may exist and are being used in parallel. Relying Parties should incorporate this information into their risk scoring. Whether the Relying P'
||'arty updates storedSignCount in this case, or not, or fails the authentication ceremony or not, is Relying Party-specific.'))
,p_attribute_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'If authData.signCount is',
'greater than storedSignCount:',
'Update storedSignCount to be the value of authData.signCount.',
'less than or equal to storedSignCount:',
'This is a signal that the authenticator may be cloned, i.e. at least two copies of the credential private key may exist and are being used in parallel. Relying Parties should incorporate this information into their risk scoring. Whether the Relying P'
||'arty updates storedSignCount in this case, or not, or fails the authentication ceremony or not, is Relying Party-specific.'))
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
