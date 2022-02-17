function _webauthn_buf2hex(buffer) {
  // buffer is an ArrayBuffer
  return [...new Uint8Array(buffer)]
    .map((x) => x.toString(16).padStart(2, '0'))
    .join('')
}
function _webauthn_register(pAjaxIdent) {
  apex.debug.trace('Register new User Device for Web Authentication...')
  if (navigator.credentials) {
    var lSpinner$ = apex.util.showSpinner($('.t-Body'))
    apex.server
      .plugin(pAjaxIdent, {
        x01: 'GET_CHALLENGE',
      })
      .then((data) => {
        const enc = new TextEncoder()
        data.challenge = enc.encode(data.challenge)
        data.user.id = enc.encode(data.user.id)
        apex.debug.trace(data)
        navigator.credentials
          .create({ publicKey: data })
          .then((credential) => {
            apex.debug.trace(credential)
            const dec = new TextDecoder()
            const credentialJSON = {
              rawId: _webauthn_buf2hex(credential.rawId),
              id: credential.id,
              type: credential.type,
              response: {
                clientDataJSON: JSON.parse(
                  dec.decode(credential.response.clientDataJSON)
                ),
                attestationObject: _webauthn_buf2hex(
                  credential.response.getAuthenticatorData()
                ),
                publicKey: _webauthn_buf2hex(
                  credential.response.getPublicKey()
                ),
                publicKeyAlg: credential.response.getPublicKeyAlgorithm(),
                transports: credential.response.getTransports(),
                // attestationObject: credential.response.attestationObject
              },
              clientExtensionResults: credential.getClientExtensionResults(),
            }
            apex.debug.trace(credentialJSON)

            // Weiterer Call zum registrieren.
            apex.server
              .plugin(pAjaxIdent, {
                x01: 'REGISTER',
                x02: JSON.stringify(credentialJSON),
              })
              .then((resp) => {
                lSpinner$.remove()
                apex.debug.trace(resp)
                if (resp.hasOwnProperty('success')) {
                  apex.message.showPageSuccess(
                    'Ihr Gerät ist nun Registriert.<br> Benutzen Sie die "Remember Me" Funktion beim Einloggen um sich einfacher anzumelden.'
                  )
                }
                apex.debug.trace(resp)
              })
              .catch((err) => {
                lSpinner$.remove()
                apex.debug.error(err)
                apex.message.clearErrors()
                apex.message.showErrors([
                  {
                    type: 'error',
                    location: 'page',
                    message: err,
                    unsafe: true,
                  },
                ])
              })
          })
          .catch((err) => {
            lSpinner$.remove()
            apex.debug.error(err)
            apex.message.clearErrors()
            apex.message.showErrors({
              type: 'error',
              location: 'page',
              message: err,
              unsafe: true,
            })
          })
      })
      .catch((err) => {
        lSpinner$.remove()
        apex.debug.error(err)
        apex.message.clearErrors()
        apex.message.showErrors({
          type: 'error',
          location: 'page',
          message: err,
          unsafe: true,
        })
      })
  } else {
    apex.debug.error('Web Authentication API ist nicht vorhanden... Skip!')
    apex.message.alert('Web Authentication API ist nicht vorhanden... Skip!')
  }
}
