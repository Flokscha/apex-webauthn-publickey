/*************************************
  DDL to deinstall the necessary Package
**************************************/
DROP PACKAGE BODY WEBAUTHN_PK;
/
DROP PACKAGE WEBAUTHN_PK;
/*************************************
  DDL to deinstall the necessary Java
**************************************/
DROP JAVA SOURCE "WEBAUTHN_CRYPTO";
/
/*************************************
  DDL to deinstall the necessary Table
**************************************/
drop table webauthentication;
/