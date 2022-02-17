/*************************************
  DDL to install the necessary Table
**************************************/
drop table webauthentication;

create table webauthentication (
    id                             number generated by default on null as identity 
                                   constraint webauthentication_id_pk primary key,
    username                       varchar2(255 char),
    userid                         varchar2(255 char),
    responsejson                   clob check (responsejson is json)
)
;
/
/*************************************
  DDL to install the necessary Java
**************************************/
CREATE OR REPLACE JAVA SOURCE NAMED "WEBAUTHN_CRYPTO" AS
import java.security.KeyFactory;
import java.security.MessageDigest;
import java.security.PublicKey;
import java.security.Signature;
import java.security.spec.X509EncodedKeySpec;
   public class WebauthnCrypto {
    
    //Hash String with SHA-256
    public static String fncsha(String inputVal) throws Exception {
      MessageDigest myDigest = MessageDigest.getInstance("SHA-256");
      myDigest.update(inputVal.getBytes());
      byte[] dataBytes = myDigest.digest();
      StringBuffer sb = new StringBuffer();
      for (int i = 0; i < dataBytes.length; i++) {
        sb.append(Integer.toString((dataBytes[i])).substring(1));
      }

      StringBuffer hexString = new StringBuffer();
      for (int i = 0; i < dataBytes.length; i++) {
        String hex = Integer.toHexString(0xff & dataBytes[i]);
        if (hex.length() == 1) hexString.append('0');
        hexString.append(hex);
      }
      String retParam = hexString.toString();
      return retParam;
    }

    //RSA Encryption with SHA-256
    public static String fnchmacsha(
      String inputVal,
      String key,
      String signature
    )
      throws Exception {
      X509EncodedKeySpec myKey = new X509EncodedKeySpec(
        hexStringToByteArray(key)
      );
      KeyFactory keyFactory = KeyFactory.getInstance("RSA");
      PublicKey pubKey = keyFactory.generatePublic(myKey);
      Signature sig = Signature.getInstance("SHA256withRSA");
      sig.initVerify(pubKey);
      byte[] combined = hexStringToByteArray(inputVal);
      sig.update(combined);
      return String.valueOf(sig.verify(hexStringToByteArray(signature)));
    }

    // ECDSA Encryption with SHA-256
    public static String fncecsha(
      String inputVal,
      String key,
      String signature
    )
      throws Exception {
      X509EncodedKeySpec myKey = new X509EncodedKeySpec(
        hexStringToByteArray(key)
      );
      KeyFactory keyFactory = KeyFactory.getInstance("EC");
      PublicKey pubKey = keyFactory.generatePublic(myKey);
      Signature sig = Signature.getInstance("SHA256withECDSA");
      sig.initVerify(pubKey);
      byte[] combined = hexStringToByteArray(inputVal);
      sig.update(combined);
      return String.valueOf(sig.verify(hexStringToByteArray(signature)));
    }

    //Helper Function
    public static byte[] hexStringToByteArray(String s) {
      int len = s.length();
      byte[] data = new byte[len / 2];
      for (int i = 0; i < len; i += 2) {
        data[i / 2] =
          (byte) (
            (Character.digit(s.charAt(i), 16) << 4) +
            Character.digit(s.charAt(i + 1), 16)
          );
      }
      return data;
    }
  }
/
/*************************************
  DDL to install the necessary Package
**************************************/
CREATE OR REPLACE PACKAGE WEBAUTHN_PK AS

  -- Java Stored Functions to hash and verify
  FUNCTION hash_sha256 (
    txt in varchar2 )
  RETURN VARCHAR2;

  FUNCTION verify_rsha256 (
    txt       in varchar2,
    keySpec   in varchar2,
    Signature in varchar2 )
  RETURN VARCHAR2;

  FUNCTION verify_ecsha256 (txt varchar2,
    keySpec   in varchar2,
    Signature in varchar2 )
  RETURN VARCHAR2;
  
  -- Login Plugin Process
  function login_process (
    p_process in apex_plugin.t_process,
    p_plugin  in apex_plugin.t_plugin )
  return apex_plugin.t_process_exec_result;

  -- Login Plugin Region
  function login_region_render (
    p_region              in apex_plugin.t_region,
    p_plugin              in apex_plugin.t_plugin,
    p_is_printer_friendly in boolean )
  return apex_plugin.t_region_render_result;

  function login_region_ajax (
    p_region in apex_plugin.t_region,
    p_plugin in apex_plugin.t_plugin )
  return apex_plugin.t_region_ajax_result;

  -- Register Plugin Dynamic Action
  function register_da_render (
    p_dynamic_action in apex_plugin.t_dynamic_action,
    p_plugin         in apex_plugin.t_plugin )
  return apex_plugin.t_dynamic_action_render_result;
  
  function register_da_ajax (
    p_dynamic_action in apex_plugin.t_dynamic_action,
    p_plugin         in apex_plugin.t_plugin )
  return apex_plugin.t_dynamic_action_ajax_result;

end WEBAUTHN_PK;
/
CREATE OR REPLACE PACKAGE BODY WEBAUTHN_PK AS

  -- Java Stored Functions to hash and verify
  FUNCTION hash_sha256 (txt varchar2)
    RETURN VARCHAR2
  AS
  LANGUAGE JAVA
  NAME 'WebauthnCrypto.fncsha(java.lang.String) return String';

  FUNCTION verify_rsha256 (txt varchar2,keySpec varchar2,Signature varchar2)
    RETURN VARCHAR2
  AS
  LANGUAGE JAVA
  NAME 'WebauthnCrypto.fnchmacsha(java.lang.String,java.lang.String,java.lang.String) return String';

  FUNCTION verify_ecsha256 (txt varchar2,keySpec varchar2,Signature varchar2)
    RETURN VARCHAR2
  AS
  LANGUAGE JAVA
  NAME 'WebauthnCrypto.fncecsha(java.lang.String,java.lang.String,java.lang.String) return String';

  -- Login Plugin Process
  function login_process (
    p_process in apex_plugin.t_process,
    p_plugin  in apex_plugin.t_plugin )
  return apex_plugin.t_process_exec_result as
    l_plugin apex_plugin.t_process_exec_result;

    verification_error EXCEPTION;
    PRAGMA exception_init(verification_error, -20111);

    challenge           VARCHAR(128) := v(p_process.attribute_01);
    flag                number;
    hash                RAW(4000);
    sig                 RAW(4000);
    combined            RAW(4000);
    userid              Varchar2(255);

    lerrors             Varchar2(4000);

    credentialID        Varchar2(2000);
    credentialPublicKey RAW(2000);
    publicKeyAlg        varchar2(128);

    verified            Varchar2(32) := 'false';

    arg1                Varchar2(4000)  := v(p_process.attribute_02);

    function to_base64(t in varchar2) return varchar2 is
    begin
        return utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(t)));
    end to_base64;
  begin
    -- Debug
    IF apex_application.g_debug THEN
      apex_plugin_util.debug_process(p_plugin, p_process);
    END IF;

    apex_debug.trace('JSON from Assertion: %s', arg1);
    apex_debug.trace('challenge from WEB_AUTH_CHALLENGE: %s', challenge);

    apex_json.parse(arg1);

    -- Verify
    if (challenge is null) then
        raise_application_error(-20111,'Keine Challenge erhalten.');
    end if;
    apex_debug.trace('JSON clientData.type: %s', apex_json.GET_VARCHAR2('clientData.type'));
    if (apex_json.GET_VARCHAR2('clientData.type') != 'webauthn.get') then
        raise_application_error(-20111,'Fehler bei der verifizierung von TYPE');
    end if;
    apex_debug.trace('JSON clientData.challenge: %s, base64 Challenge: %s', apex_json.GET_VARCHAR2('clientData.challenge') || '=', to_base64(challenge));
    if (apex_json.GET_VARCHAR2('clientData.challenge')||'=' != to_base64(challenge)) then
        raise_application_error(-20111,'Fehler bei der verifizierung von CHALLENGE');
    end if;
    --TODO MIT PROTOKOLL
    apex_debug.trace('JSON clientData.origin: %s', apex_json.GET_VARCHAR2('clientData.origin'));
    if (INSTR(apex_json.GET_VARCHAR2('clientData.origin'),OWA_UTIL.GET_CGI_ENV('HTTP_HOST')) <1 ) then
        raise_application_error(-20111,'Fehler bei der verifizierung von ORIGIN');
    end if;

    -- Credential ID
    credentialID := apex_json.GET_VARCHAR2('id');
    apex_debug.trace('Credential ID from JSON %s', credentialID);
    if ( credentialID is null ) then
        raise_application_error(-20111,'Keine Credential ID gefunden!');
    end if;

    select
      JSON_VALUE(responsejson, '$.response.publicKey' RETURNING VARCHAR2(2000)) as publicKey
    , JSON_VALUE(responsejson, '$.response.publicKeyAlg' RETURNING VARCHAR2(128)) as publicKeyAlg
    , USERID
    into credentialPublicKey, publicKeyAlg, userid
    from webauthentication
    where JSON_VALUE(responsejson, '$.id' RETURNING VARCHAR2(255)) = credentialID
    ;

    apex_debug.trace('PublicKey HEX: %s', credentialPublicKey);
    apex_debug.trace('PublicKey ALG: %s', publicKeyAlg);

    --TODO Fixme later
    if (publicKeyAlg not in (-7, -257)) then
        raise_application_error(-20111,'Ungültige Key Algorthm angegeben');
    end if;

      /*Verify that the rpIdHash in authData is the SHA-256 hash of the RP ID expected by the Relying Party.
    Note: If using the appid extension, this step needs some special logic. See §¿10.1 FIDO AppID Extension (appid) for details.*/
    apex_debug.trace('JSON authenticatorData.rpIdHashHex: %s, HTTP_HOST_HASH: %s', apex_json.GET_VARCHAR2('authenticatorData.rpIdHashHex'), WEBAUTHN_PK.hash_sha256(OWA_UTIL.GET_CGI_ENV('HTTP_HOST')));
    if (WEBAUTHN_PK.hash_sha256(OWA_UTIL.GET_CGI_ENV('HTTP_HOST')) != apex_json.get_varchar2('authenticatorData.rpIdHashHex') ) then
        raise_application_error(-20111,'Fehler bei der verifizierung von rpID');
    end if;

    --Flags User presence testen
    --TODO Flags werden gar nicht gefüllt???
    apex_debug.trace('User Presence Flag: %n. should be 1', MOD(flag,2));
    if ( MOD(flag,2) != 1 ) then
        raise_application_error(-20111,'Fehler bei der verifizierung von USER PRESENCE FLAG');
    end if;
    --Flags User Verification testen
    apex_debug.trace('User Verification Flag: %n. should be 1', MOD(flag,4));
    if ( MOD(flag,4) != 1 ) then
        raise_application_error(-20111,'Fehler bei der verifizierung von USER VERIFICATION FLAG');
    end if;

    -- NOTE: USERHANDLE can be Null.
    apex_debug.trace('JSON userID: %s, Username: %s', apex_json.GET_Varchar2('userId'), APEX_UTIL.GET_USERNAME(apex_json.GET_Varchar2('userId')));
    -- if (APEX_UTIL.GET_USERNAME(apex_json.GET_Varchar2('userId')) is null) then
    --   -- In that case search for the USERID saved in the Authentications Table.


    --     raise_application_error(-20111,'Fehler bei der verifizierung von UserID');
    -- end if;

    --Let hash be the result of computing a hash over the cData using SHA-256.
    hash        := WEBAUTHN_PK.hash_sha256(apex_json.get_varchar2('clientDataJSON'));
    apex_debug.trace('ClientDataJSON Hash: %s', hash);
    sig         := HEXTORAW(apex_json.get_varchar2('signatureHex'));
    apex_debug.trace('Signature: %s', sig);
    combined    := UTL_RAW.CONCAT(HEXTORAW(apex_json.get_varchar2('authenticatorDataHex')), hash);
    apex_debug.trace('combined: %s', combined);

    CASE publicKeyAlg
      WHEN '-7' then verified := WEBAUTHN_PK.verify_ecsha256(combined, credentialPublicKey, sig);
      WHEN '-257' then verified := WEBAUTHN_PK.verify_rsha256(combined, credentialPublicKey, sig);
    END CASE;

    IF (verified = 'true') THEN
        -- apex_debug.trace('Redirect after login to page: '||apex_string.split(v('FSP_AFTER_LOGIN_URL'), ':')(2)); --Not working with Friendly URLS
        apex_debug.trace('Redirect after login to page: '||v('FSP_AFTER_LOGIN_URL'));
        -- APEX_AUTHENTICATION.POST_LOGIN ( 
        apex_debug.trace('Verfication successful!');
        APEX_CUSTOM_AUTH.POST_LOGIN ( 
            APEX_UTIL.GET_USERNAME(userid), 
            p_session_id  => V('APP_SESSION'),
            p_app_page    => V('APP_ID')||':'||'home'); --Currently redirecting to Home --FIXME
            -- p_password => '');
    else
        apex_debug.error('Verfication not successful!');
        raise_application_error(-20111,'Verification fehlgeschlagen');
    END IF;

    return l_plugin;
    
    exception
    when others then
        apex_debug.error('Error in LOGIN_WEBAUTH! %s', sqlerrm);
        RAISE;
  end;

  -- Login Plugin Region
  function login_region_render (
    p_region              in apex_plugin.t_region,
    p_plugin              in apex_plugin.t_plugin,
    p_is_printer_friendly in boolean )
  return apex_plugin.t_region_render_result as
    l_plugin apex_plugin.t_region_render_result;
  begin
    -- Debug
    IF apex_application.g_debug THEN
      apex_plugin_util.debug_region(p_plugin, p_region);
    END IF;

    apex_javascript.add_library(
      p_name                    => 'webauthn_publickey#MIN#',
      p_directory               => p_plugin.file_prefix);
    APEX_JAVASCRIPT.ADD_ONLOAD_CODE (
      p_code                    => '_webauthn_publickey_credentials("' || apex_plugin.get_ajax_identifier || '")',
      p_key                     => 'DE.FGROTE.WEBAUTHN.PUBLICKEY.REGION.ONLOAD');


    -- Subsitute the Region Source
    htp.p(APEX_PLUGIN_UTIL.REPLACE_SUBSTITUTIONS (
      p_value    => p_region.source,
      p_escape   => TRUE ));
    --Create own Sign-In-Button
    htp.p('<div class="t-Login-buttons">');
    htp.p(apex_string.format(
      q'[<button onclick="_webauthn_publickey_login('%s', '%s')" class="t-Button t-Button--hot" type="button" id="LOGIN_WEBAUTH"><span class="t-Button-label">%s</span></button>]'
      , apex_plugin.get_ajax_identifier
      , p_region.attribute_03
      , p_region.attribute_01
    ));
    htp.p('</div>');

    return l_plugin;
  end;

  function login_region_ajax (
    p_region in apex_plugin.t_region,
    p_plugin in apex_plugin.t_plugin )
  return apex_plugin.t_region_ajax_result as
    l_plugin apex_plugin.t_region_ajax_result;

    challenge     RAW(32) := SYS_GUID();
    lusername     Varchar2(255);

    procedure jsonCredentialRequestOptions as
        l_transports    apex_json.t_values := apex_json.t_values();

    begin
      APEX_JSON.OPEN_OBJECT();
      APEX_JSON.WRITE('challenge', RAWTOHEX(challenge) ); --RANDOM CHALLENGE
      APEX_JSON.WRITE('isAuthenticated', APEX_AUTHENTICATION.IS_AUTHENTICATED);
      APEX_JSON.WRITE('rpId', OWA_UTIL.GET_CGI_ENV('HTTP_HOST') ); -- Website Info
      APEX_JSON.OPEN_ARRAY('allowCredentials');
      for rec in (
        select username, userid
        , JSON_VALUE(responsejson, '$.rawId' RETURNING VARCHAR2(2000)) as clientId
        , JSON_VALUE(responsejson, '$.type' RETURNING VARCHAR2(100)) as type
        , JSON_VALUE(responsejson, '$.response.transports[*]' RETURNING VARCHAR2(255)) as transports
        from webauthentication
        where UPPER(USERNAME) = lusername
      ) loop
        if (rec.clientId is not null or rec.clientId != '') then
        -- TODO FIX transports. multiple. or none
          APEX_JSON.OPEN_OBJECT();
            apex_json.open_array('transports');
              APEX_JSON.WRITE(NVL(rec.transports, 'internal'));
            APEX_JSON.CLOSE_ARRAY();
            APEX_JSON.WRITE('type', rec.type);
            APEX_JSON.WRITE('id', rec.clientId);
          APEX_JSON.CLOSE_OBJECT();
        end if;
      end loop;
      APEX_JSON.CLOSE_ARRAY();
      APEX_JSON.WRITE('userVerification', 'discouraged');
      APEX_JSON.WRITE('timeout', 60000);
      APEX_JSON.CLOSE_ALL();
    end jsonCredentialRequestOptions;
  begin
    -- Debug
    IF apex_application.g_debug THEN
      apex_plugin_util.debug_region(p_plugin, p_region);
    END IF;

    --Set Username. Can be Different Approaches --FIXME
    lusername := UPPER(apex_authentication.get_login_username_cookie());

    apex_util.set_session_state(p_region.attribute_02,challenge);

    jsonCredentialRequestOptions();

    return l_plugin;
  end;

  -- Register Plugin Dynamic Action
  function register_da_render (
    p_dynamic_action in apex_plugin.t_dynamic_action,
    p_plugin         in apex_plugin.t_plugin )
  return apex_plugin.t_dynamic_action_render_result AS
    l_plugin apex_plugin.t_dynamic_action_render_result;
  begin
    -- Debug
    IF apex_application.g_debug THEN
      apex_plugin_util.debug_dynamic_action(p_plugin         => p_plugin,
                                            p_dynamic_action => p_dynamic_action);
    END IF;

    APEX_JAVASCRIPT.ADD_LIBRARY (
      p_name                    => 'webauthn_register#MIN#',
      p_directory               => p_plugin.file_prefix);

    -- DA javascript function call
    l_plugin.javascript_function := 'function() { _webauthn_register(' || 
      apex_javascript.add_value(sys.htf.escape_sc(apex_plugin.get_ajax_identifier())) ||
      '); }';
    return l_plugin;
  end;


  procedure get_challenge(pChallengeItem in Varchar2, pRelyingParty in Varchar2) as
    challenge   RAW(32) := SYS_GUID();

    procedure jsonWebAuthCreateOptions as
      -- List of COSE Algorithms
      -- see for more information https://www.iana.org/assignments/cose/cose.xhtml#algorithms
      cose_alg    apex_t_number := apex_t_number (
        -257, --Oracle DB with Java 1.8 does not Allow for much.
        -7
        -- All WEBAUTHN COSE Algorithms
        /*-257, -258, -259, --RSASSA-PKCS1-v1_5 using SHA-256, ..384, ..512
        -44, -43, --SHA-384, SHA-512
        -14, -15, -16, -17, --SHA-1, SHA-256/64, SHA-256, SHA-512/256
        -6, -7, -8, -- direct, ES256, EdDSA
        -3, -4, -5, -- A128KW, A192KW, A256KW
        1, 2, 3, -- A128GCM, A192GCM, A256GCM
        4, 5, 6, 7, --HMAC 256/64, SHA-HMAC 256, HMAC 384, HMAC 512
        10, 11, 12, 13, 14, 15, --AES-CCM-16-64-128, AES-CCM-16-64-256, AES-CCM-64-64-128, AES-CCM-64-64-256, AES-MAC 128/64, AES-MAC 256/64
        24, 25, 26, -- ChaCha20/Poly1305, AES-MAC 128/128, AES-MAC 256/128
        30, 31, 32, 33, 34 -- AES-CCM-16-128-128, AES-CCM-16-128-256, AES-CCM-64-128-128, AES-CCM-64-128-256, IV-GENERATION
      */);
    begin
      APEX_JSON.OPEN_OBJECT();

      APEX_JSON.WRITE('challenge', RAWTOHEX(challenge) ); --RANDOM CHALLENGE

      APEX_JSON.OPEN_OBJECT('rp');
          APEX_JSON.WRITE('name', pRelyingParty); -- Website Info
          APEX_JSON.WRITE('id', OWA_UTIL.GET_CGI_ENV('HTTP_HOST') ); -- Website Info
      APEX_JSON.CLOSE_OBJECT();

      APEX_JSON.OPEN_OBJECT('user');
          APEX_JSON.WRITE('name', APEX_UTIL.GET_EMAIL(p_username => UPPER(v('APP_USER'))) ); -- User Mail
          APEX_JSON.WRITE('displayName', UPPER(v('APP_USER')) ); -- Username
          APEX_JSON.WRITE('id', to_char(APEX_UTIL.GET_CURRENT_USER_ID()) ); -- Apex User ID
      APEX_JSON.CLOSE_OBJECT();

      APEX_JSON.OPEN_ARRAY('pubKeyCredParams');
          -- loop COSE Algorithms
          for idx in cose_alg.first..cose_alg.last loop
              APEX_JSON.OPEN_OBJECT();
                  APEX_JSON.WRITE('type', 'public-key' ); 
                  APEX_JSON.WRITE('alg', cose_alg(idx) );
              APEX_JSON.CLOSE_OBJECT();
          end loop;
      APEX_JSON.CLOSE_ARRAY();

      APEX_JSON.OPEN_OBJECT('authenticatorSelection');
          APEX_JSON.WRITE('authenticatorAttachment', 'platform');
          APEX_JSON.WRITE('residentKey', 'preferred');
          APEX_JSON.WRITE('userVerification','discouraged');
      APEX_JSON.CLOSE_OBJECT();

      APEX_JSON.WRITE('timeout', 60000);
      APEX_JSON.WRITE('attestation', 'direct');
      APEX_JSON.CLOSE_ALL();
    end jsonWebAuthCreateOptions;
  begin
      APEX_UTIL.SET_SESSION_STATE(pChallengeItem, RAWTOHEX(challenge));
      
      jsonWebAuthCreateOptions();
  end get_challenge;

  procedure register(pChallengeItem in Varchar2) as
    identical_credentialID_error EXCEPTION;
    PRAGMA exception_init(identical_credentialID_error, -20112);

    challenge           VARCHAR(64);
    rawId               apex_t_number;
    attestationObject   VARCHAR(8000);
    publicKey           apex_t_number;
    publicKeyAlg        number;

    arg1                Varchar2(4000)  := apex_application.g_x02;

    function to_base64(t in varchar2) return varchar2 is
    begin
      return utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(t)));
    end to_base64;
  begin
    challenge := APEX_UTIL.GET_SESSION_STATE(pChallengeItem);

    apex_json.parse(arg1);

    apex_json.open_object();
    -- Verify stuff
    if (apex_json.GET_VARCHAR2('response.clientDataJSON.type') != 'webauthn.create') then
        apex_json.write('error', 'Fehler bei der verifizierung von TYPE');
    end if;
    if (apex_json.GET_VARCHAR2('response.clientDataJSON.challenge')||'=' != to_base64(challenge)) then
        apex_json.write('error', 'Fehler bei der verifizierung von CHALLENGE');
    end if;
    --TODO MIT PROTOKOLL
    if (INSTR(apex_json.GET_VARCHAR2('response.clientDataJSON.origin'),OWA_UTIL.GET_CGI_ENV('HTTP_HOST')) <1 ) then
        apex_json.write('error', 'Fehler bei der verifizierung von ORIGIN');
    end if;

    --Check attestationObject
    -- attestationObject   := apex_json.GET_VARCHAR2('response.attestationObject');

    --TODO DMBS_UTILITY.IS_BIT_SET for FLAG

    -- Save to Table.
    insert into WEBAUTHENTICATION
    (username, userid, RESPONSEJSON)
    values
    (v('APP_USER'), APEX_UTIL.GET_USER_ID(UPPER(v('APP_USER'))), arg1);

    apex_json.write('success', 'User has Successfully Registered');
    apex_json.close_all();
  end register;

  function register_da_ajax (
    p_dynamic_action in apex_plugin.t_dynamic_action,
    p_plugin         in apex_plugin.t_plugin )
  return apex_plugin.t_dynamic_action_ajax_result as
    l_plugin apex_plugin.t_dynamic_action_ajax_result;
  begin
    if (apex_application.g_x01 = 'GET_CHALLENGE') then
      get_challenge(p_dynamic_action.attribute_01, p_dynamic_action.attribute_02);
    elsif (apex_application.g_x01 = 'REGISTER') then
      register(p_dynamic_action.attribute_01);
    end if;
    return l_plugin;
  end register_da_ajax;

end WEBAUTHN_PK;