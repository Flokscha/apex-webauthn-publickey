// Helper Function
function _webauthn_buf2hex(buffer) {
  // buffer is an ArrayBuffer
  return [...new Uint8Array(buffer)]
    .map((x) => x.toString(16).padStart(2, '0'))
    .join('')
}

function _register_webauth(pAjaxIdent, lSpinner$, credentialJSON) {
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
          'Your device is now registered.<br> Use the "Remember Me" checkbox on Sign In for 1-Click Sign Ins'
          // 'Ihr Gerät ist nun Registriert.<br> Benutzen Sie die "Remember Me" Funktion beim Einloggen um sich einfacher anzumelden.'
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
}

function _get_challenge(pAjaxIdent, lSpinner$) {
  apex.server
  .plugin(pAjaxIdent, {
    x01: 'GET_CHALLENGE',
  })
  .then((data) => {
    // Encode Challenge and User ID
    const enc = new TextEncoder()
    data.challenge = enc.encode(data.challenge)
    data.user.id = enc.encode(data.user.id)
    apex.debug.trace(data)

    navigator.credentials
      .create({ publicKey: data })
      .then((credential) => {
        apex.debug.trace(credential)

        // Create a Decoded JSON Object
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
        _register_webauth(pAjaxIdent, lSpinner$, credentialJSON)
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
}

function _webauthn_register(pAjaxIdent) {
  apex.debug.trace('Register new User Device for Web Authentication...')
  if (navigator.credentials) {
    // Show Spinner
    var lSpinner$ = apex.util.showSpinner($('.t-Body'))

    // Call Plugin GET_CHALLENGE to get Credential Options Object
    _get_challenge(pAjaxIdent, lSpinner$)
  } else {
    apex.debug.error('Web Authentication API ist nicht vorhanden... Skip!')
    apex.message.alert('Web Authentication API ist nicht vorhanden... Skip!')
  }
}
