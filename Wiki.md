# How to go Passwordless
1. For first time Users


### Registration
https://www.w3.org/TR/webauthn-2/#sctn-sample-registration
1. Credential ID in Local Storage speichern.
2. Der Registrierung einen Namen vom User geben.
3. Exclude User Credentials on Register
4. User Verification specific: https://www.w3.org/TR/webauthn-2/#sctn-sample-registration-with-platform-authenticator

Wegen E-Mail aufpassen
Nur IDs und Usernames verwenden
https://www.w3.org/TR/webauthn-2/#sctn-username-enumeration


### Authentication
https://www.w3.org/TR/webauthn-2/#sctn-sample-authentication
1. Credentials auslesen. LOCALSTORAGE. 1. APP ONLY 2. INSTANCE-WIDE
2. USERNAME COOKIE.
3. USERNAME FRAGEN

Backwards Compatibility:
User Handle is null
https://www.w3.org/TR/webauthn-2/#sctn-conforming-authenticators-u2f


### Abort
https://www.w3.org/TR/webauthn-2/#sctn-sample-aborting


### Decomissioning (Stilllegung)
1. Credentials Löschbar machen
2. Inactivity

### Informationen speichern
1. Last Used Date for Credential.
2. Userspecific Name
3. Created. Updated.
4. Sign Counter for Duplication Detection


Kapitel 5 Nochmal in Ruhe durchlesen


### Verfification:
https://www.w3.org/TR/webauthn-2/#sctn-registering-a-new-credential
