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
,p_release=>'21.2.0'
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
--   Date and Time:   12:22 Thursday February 17, 2022
--   Exported By:     GERMANBEVER@GMAIL.COM
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 80686634885303608821
--   Manifest End
--   Version:         21.2.0
--   Instance ID:     63113759365424
--

begin
  -- replace components
  wwv_flow_api.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/dynamic_action/de_fgrote_webauthn_publickey_register
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(80686634885303608821)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'DE.FGROTE.WEBAUTHN.PUBLICKEY.REGISTER'
,p_display_name=>'Web Authentication Public Key Register'
,p_category=>'EXECUTE'
,p_supported_ui_types=>'DESKTOP'
,p_api_version=>2
,p_render_function=>'WEBAUTHN_PK.register_da_render'
,p_ajax_function=>'WEBAUTHN_PK.register_da_ajax'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'This Process presumes the following table is available:',
'<pre>',
'create table webauthentication (',
'    id                             number generated by default on null as identity ',
'                                   constraint webauthentication_id_pk primary key,',
'    username                       varchar2(255 char),',
'    userid                         varchar2(4000 char),',
'    responsejson                   clob check (responsejson is json)',
');',
'</pre>'))
,p_version_identifier=>'1.0'
,p_files_version=>23
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(80730963136669439935)
,p_plugin_id=>wwv_flow_api.id(80686634885303608821)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Challenge holding Item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>true
,p_is_translatable=>false
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(80847783321305854428)
,p_plugin_id=>wwv_flow_api.id(80686634885303608821)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Online Service / Relying Party'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_is_translatable=>false
,p_examples=>'apex.oracle.com web-authentication'
,p_help_text=>'With WebAuthn (also known as FIDO2), public-key cryptography is used to authenticate end-users to an online service, also known as a Relying Party (RP). When the end-user registers for an online service, an RP-specific credential key pair - i.e., a p'
||'rivate key and a public key - is generated on the authenticator and the public key is sent to the RP (the private key never leaves the authenticator).'
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '66756E6374696F6E205F776562617574686E5F627566326865782865297B72657475726E5B2E2E2E6E65772055696E743841727261792865295D2E6D61702828653D3E652E746F537472696E67283136292E706164537461727428322C2230222929292E';
wwv_flow_api.g_varchar2_table(2) := '6A6F696E282222297D66756E6374696F6E205F776562617574686E5F72656769737465722865297B696628617065782E64656275672E747261636528225265676973746572206E657720557365722044657669636520666F72205765622041757468656E';
wwv_flow_api.g_varchar2_table(3) := '7469636174696F6E2E2E2E22292C6E6176696761746F722E63726564656E7469616C73297B76617220723D617065782E7574696C2E73686F775370696E6E6572282428222E742D426F64792229293B617065782E7365727665722E706C7567696E28652C';
wwv_flow_api.g_varchar2_table(4) := '7B7830313A224745545F4348414C4C454E4745227D292E7468656E2828613D3E7B636F6E737420743D6E65772054657874456E636F6465723B612E6368616C6C656E67653D742E656E636F646528612E6368616C6C656E6765292C612E757365722E6964';
wwv_flow_api.g_varchar2_table(5) := '3D742E656E636F646528612E757365722E6964292C617065782E64656275672E74726163652861292C6E6176696761746F722E63726564656E7469616C732E637265617465287B7075626C69634B65793A617D292E7468656E2828613D3E7B617065782E';
wwv_flow_api.g_varchar2_table(6) := '64656275672E74726163652861293B636F6E737420743D6E657720546578744465636F6465722C733D7B72617749643A5F776562617574686E5F6275663268657828612E7261774964292C69643A612E69642C747970653A612E747970652C726573706F';
wwv_flow_api.g_varchar2_table(7) := '6E73653A7B636C69656E74446174614A534F4E3A4A534F4E2E706172736528742E6465636F646528612E726573706F6E73652E636C69656E74446174614A534F4E29292C6174746573746174696F6E4F626A6563743A5F776562617574686E5F62756632';
wwv_flow_api.g_varchar2_table(8) := '68657828612E726573706F6E73652E67657441757468656E74696361746F72446174612829292C7075626C69634B65793A5F776562617574686E5F6275663268657828612E726573706F6E73652E6765745075626C69634B65792829292C7075626C6963';
wwv_flow_api.g_varchar2_table(9) := '4B6579416C673A612E726573706F6E73652E6765745075626C69634B6579416C676F726974686D28292C7472616E73706F7274733A612E726573706F6E73652E6765745472616E73706F72747328297D2C636C69656E74457874656E73696F6E52657375';
wwv_flow_api.g_varchar2_table(10) := '6C74733A612E676574436C69656E74457874656E73696F6E526573756C747328297D3B617065782E64656275672E74726163652873292C617065782E7365727665722E706C7567696E28652C7B7830313A225245474953544552222C7830323A4A534F4E';
wwv_flow_api.g_varchar2_table(11) := '2E737472696E676966792873297D292E7468656E2828653D3E7B722E72656D6F766528292C617065782E64656275672E74726163652865292C652E6861734F776E50726F706572747928227375636365737322292626617065782E6D6573736167652E73';
wwv_flow_api.g_varchar2_table(12) := '686F7750616765537563636573732827596F757220646576696365206973206E6F7720726567697374657265642E3C62723E2055736520746865202252656D656D626572204D652220636865636B626F78206F6E205369676E20496E20666F7220312D43';
wwv_flow_api.g_varchar2_table(13) := '6C69636B205369676E20496E7327292C617065782E64656275672E74726163652865297D29292E63617463682828653D3E7B722E72656D6F766528292C617065782E64656275672E6572726F722865292C617065782E6D6573736167652E636C65617245';
wwv_flow_api.g_varchar2_table(14) := '72726F727328292C617065782E6D6573736167652E73686F774572726F7273285B7B747970653A226572726F72222C6C6F636174696F6E3A2270616765222C6D6573736167653A652C756E736166653A21307D5D297D29297D29292E6361746368282865';
wwv_flow_api.g_varchar2_table(15) := '3D3E7B722E72656D6F766528292C617065782E64656275672E6572726F722865292C617065782E6D6573736167652E636C6561724572726F727328292C617065782E6D6573736167652E73686F774572726F7273287B747970653A226572726F72222C6C';
wwv_flow_api.g_varchar2_table(16) := '6F636174696F6E3A2270616765222C6D6573736167653A652C756E736166653A21307D297D29297D29292E63617463682828653D3E7B722E72656D6F766528292C617065782E64656275672E6572726F722865292C617065782E6D6573736167652E636C';
wwv_flow_api.g_varchar2_table(17) := '6561724572726F727328292C617065782E6D6573736167652E73686F774572726F7273287B747970653A226572726F72222C6C6F636174696F6E3A2270616765222C6D6573736167653A652C756E736166653A21307D297D29297D656C73652061706578';
wwv_flow_api.g_varchar2_table(18) := '2E64656275672E6572726F7228225765622041757468656E7469636174696F6E2041504920697374206E6963687420766F7268616E64656E2E2E2E20536B69702122292C617065782E6D6573736167652E616C65727428225765622041757468656E7469';
wwv_flow_api.g_varchar2_table(19) := '636174696F6E2041504920697374206E6963687420766F7268616E64656E2E2E2E20536B69702122297D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(40445358962276218954)
,p_plugin_id=>wwv_flow_api.id(80686634885303608821)
,p_file_name=>'webauthn_register.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '66756E6374696F6E205F776562617574686E5F627566326865782862756666657229207B0D0A20202F2F2062756666657220697320616E2041727261794275666665720D0A202072657475726E205B2E2E2E6E65772055696E7438417272617928627566';
wwv_flow_api.g_varchar2_table(2) := '666572295D0D0A202020202E6D617028287829203D3E20782E746F537472696E67283136292E706164537461727428322C2027302729290D0A202020202E6A6F696E282727290D0A7D0D0A66756E6374696F6E205F776562617574686E5F726567697374';
wwv_flow_api.g_varchar2_table(3) := '65722870416A61784964656E7429207B0D0A2020617065782E64656275672E747261636528275265676973746572206E657720557365722044657669636520666F72205765622041757468656E7469636174696F6E2E2E2E27290D0A2020696620286E61';
wwv_flow_api.g_varchar2_table(4) := '76696761746F722E63726564656E7469616C7329207B0D0A20202020766172206C5370696E6E657224203D20617065782E7574696C2E73686F775370696E6E6572282428272E742D426F64792729290D0A20202020617065782E7365727665720D0A2020';
wwv_flow_api.g_varchar2_table(5) := '202020202E706C7567696E2870416A61784964656E742C207B0D0A20202020202020207830313A20274745545F4348414C4C454E4745272C0D0A2020202020207D290D0A2020202020202E7468656E28286461746129203D3E207B0D0A20202020202020';
wwv_flow_api.g_varchar2_table(6) := '20636F6E737420656E63203D206E65772054657874456E636F64657228290D0A2020202020202020646174612E6368616C6C656E6765203D20656E632E656E636F646528646174612E6368616C6C656E6765290D0A2020202020202020646174612E7573';
wwv_flow_api.g_varchar2_table(7) := '65722E6964203D20656E632E656E636F646528646174612E757365722E6964290D0A2020202020202020617065782E64656275672E74726163652864617461290D0A20202020202020206E6176696761746F722E63726564656E7469616C730D0A202020';
wwv_flow_api.g_varchar2_table(8) := '202020202020202E637265617465287B207075626C69634B65793A2064617461207D290D0A202020202020202020202E7468656E282863726564656E7469616C29203D3E207B0D0A202020202020202020202020617065782E64656275672E7472616365';
wwv_flow_api.g_varchar2_table(9) := '2863726564656E7469616C290D0A202020202020202020202020636F6E737420646563203D206E657720546578744465636F64657228290D0A202020202020202020202020636F6E73742063726564656E7469616C4A534F4E203D207B0D0A2020202020';
wwv_flow_api.g_varchar2_table(10) := '20202020202020202072617749643A205F776562617574686E5F627566326865782863726564656E7469616C2E7261774964292C0D0A202020202020202020202020202069643A2063726564656E7469616C2E69642C0D0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(11) := '2020747970653A2063726564656E7469616C2E747970652C0D0A2020202020202020202020202020726573706F6E73653A207B0D0A20202020202020202020202020202020636C69656E74446174614A534F4E3A204A534F4E2E7061727365280D0A2020';
wwv_flow_api.g_varchar2_table(12) := '202020202020202020202020202020206465632E6465636F64652863726564656E7469616C2E726573706F6E73652E636C69656E74446174614A534F4E290D0A20202020202020202020202020202020292C0D0A20202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(13) := '6174746573746174696F6E4F626A6563743A205F776562617574686E5F62756632686578280D0A20202020202020202020202020202020202063726564656E7469616C2E726573706F6E73652E67657441757468656E74696361746F724461746128290D';
wwv_flow_api.g_varchar2_table(14) := '0A20202020202020202020202020202020292C0D0A202020202020202020202020202020207075626C69634B65793A205F776562617574686E5F62756632686578280D0A20202020202020202020202020202020202063726564656E7469616C2E726573';
wwv_flow_api.g_varchar2_table(15) := '706F6E73652E6765745075626C69634B657928290D0A20202020202020202020202020202020292C0D0A202020202020202020202020202020207075626C69634B6579416C673A2063726564656E7469616C2E726573706F6E73652E6765745075626C69';
wwv_flow_api.g_varchar2_table(16) := '634B6579416C676F726974686D28292C0D0A202020202020202020202020202020207472616E73706F7274733A2063726564656E7469616C2E726573706F6E73652E6765745472616E73706F72747328292C0D0A20202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(17) := '2F2F206174746573746174696F6E4F626A6563743A2063726564656E7469616C2E726573706F6E73652E6174746573746174696F6E4F626A6563740D0A20202020202020202020202020207D2C0D0A2020202020202020202020202020636C69656E7445';
wwv_flow_api.g_varchar2_table(18) := '7874656E73696F6E526573756C74733A2063726564656E7469616C2E676574436C69656E74457874656E73696F6E526573756C747328292C0D0A2020202020202020202020207D0D0A202020202020202020202020617065782E64656275672E74726163';
wwv_flow_api.g_varchar2_table(19) := '652863726564656E7469616C4A534F4E290D0A0D0A2020202020202020202020202F2F2057656974657265722043616C6C207A756D2072656769737472696572656E2E0D0A202020202020202020202020617065782E7365727665720D0A202020202020';
wwv_flow_api.g_varchar2_table(20) := '20202020202020202E706C7567696E2870416A61784964656E742C207B0D0A202020202020202020202020202020207830313A20275245474953544552272C0D0A202020202020202020202020202020207830323A204A534F4E2E737472696E67696679';
wwv_flow_api.g_varchar2_table(21) := '2863726564656E7469616C4A534F4E292C0D0A20202020202020202020202020207D290D0A20202020202020202020202020202E7468656E28287265737029203D3E207B0D0A202020202020202020202020202020206C5370696E6E6572242E72656D6F';
wwv_flow_api.g_varchar2_table(22) := '766528290D0A20202020202020202020202020202020617065782E64656275672E74726163652872657370290D0A2020202020202020202020202020202069662028726573702E6861734F776E50726F7065727479282773756363657373272929207B0D';
wwv_flow_api.g_varchar2_table(23) := '0A202020202020202020202020202020202020617065782E6D6573736167652E73686F775061676553756363657373280D0A202020202020202020202020202020202020202027596F757220646576696365206973206E6F772072656769737465726564';
wwv_flow_api.g_varchar2_table(24) := '2E3C62723E2055736520746865202252656D656D626572204D652220636865636B626F78206F6E205369676E20496E20666F7220312D436C69636B205369676E20496E73270D0A20202020202020202020202020202020202020202F2F20274968722047';
wwv_flow_api.g_varchar2_table(25) := '6572C3A47420697374206E756E2052656769737472696572742E3C62723E2042656E75747A656E2053696520646965202252656D656D626572204D65222046756E6B74696F6E206265696D2045696E6C6F6767656E20756D20736963682065696E666163';
wwv_flow_api.g_varchar2_table(26) := '68657220616E7A756D656C64656E2E270D0A202020202020202020202020202020202020290D0A202020202020202020202020202020207D0D0A20202020202020202020202020202020617065782E64656275672E74726163652872657370290D0A2020';
wwv_flow_api.g_varchar2_table(27) := '2020202020202020202020207D290D0A20202020202020202020202020202E6361746368282865727229203D3E207B0D0A202020202020202020202020202020206C5370696E6E6572242E72656D6F766528290D0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(28) := '20617065782E64656275672E6572726F7228657272290D0A20202020202020202020202020202020617065782E6D6573736167652E636C6561724572726F727328290D0A20202020202020202020202020202020617065782E6D6573736167652E73686F';
wwv_flow_api.g_varchar2_table(29) := '774572726F7273285B0D0A2020202020202020202020202020202020207B0D0A2020202020202020202020202020202020202020747970653A20276572726F72272C0D0A20202020202020202020202020202020202020206C6F636174696F6E3A202770';
wwv_flow_api.g_varchar2_table(30) := '616765272C0D0A20202020202020202020202020202020202020206D6573736167653A206572722C0D0A2020202020202020202020202020202020202020756E736166653A20747275652C0D0A2020202020202020202020202020202020207D2C0D0A20';
wwv_flow_api.g_varchar2_table(31) := '2020202020202020202020202020205D290D0A20202020202020202020202020207D290D0A202020202020202020207D290D0A202020202020202020202E6361746368282865727229203D3E207B0D0A2020202020202020202020206C5370696E6E6572';
wwv_flow_api.g_varchar2_table(32) := '242E72656D6F766528290D0A202020202020202020202020617065782E64656275672E6572726F7228657272290D0A202020202020202020202020617065782E6D6573736167652E636C6561724572726F727328290D0A20202020202020202020202061';
wwv_flow_api.g_varchar2_table(33) := '7065782E6D6573736167652E73686F774572726F7273287B0D0A2020202020202020202020202020747970653A20276572726F72272C0D0A20202020202020202020202020206C6F636174696F6E3A202770616765272C0D0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(34) := '2020206D6573736167653A206572722C0D0A2020202020202020202020202020756E736166653A20747275652C0D0A2020202020202020202020207D290D0A202020202020202020207D290D0A2020202020207D290D0A2020202020202E636174636828';
wwv_flow_api.g_varchar2_table(35) := '2865727229203D3E207B0D0A20202020202020206C5370696E6E6572242E72656D6F766528290D0A2020202020202020617065782E64656275672E6572726F7228657272290D0A2020202020202020617065782E6D6573736167652E636C656172457272';
wwv_flow_api.g_varchar2_table(36) := '6F727328290D0A2020202020202020617065782E6D6573736167652E73686F774572726F7273287B0D0A20202020202020202020747970653A20276572726F72272C0D0A202020202020202020206C6F636174696F6E3A202770616765272C0D0A202020';
wwv_flow_api.g_varchar2_table(37) := '202020202020206D6573736167653A206572722C0D0A20202020202020202020756E736166653A20747275652C0D0A20202020202020207D290D0A2020202020207D290D0A20207D20656C7365207B0D0A20202020617065782E64656275672E6572726F';
wwv_flow_api.g_varchar2_table(38) := '7228275765622041757468656E7469636174696F6E2041504920697374206E6963687420766F7268616E64656E2E2E2E20536B69702127290D0A20202020617065782E6D6573736167652E616C65727428275765622041757468656E7469636174696F6E';
wwv_flow_api.g_varchar2_table(39) := '2041504920697374206E6963687420766F7268616E64656E2E2E2E20536B69702127290D0A20207D0D0A7D0D0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(80731235237961485292)
,p_plugin_id=>wwv_flow_api.id(80686634885303608821)
,p_file_name=>'webauthn_register.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
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
