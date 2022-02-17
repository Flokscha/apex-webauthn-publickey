/**
 * Convert a hex string to an ArrayBuffer.
 *
 * @param {string} hexString - hex representation of bytes
 * @return {ArrayBuffer} - The bytes in an ArrayBuffer.
 */
function _webauthn_hexStringToArrayBuffer(hexString) {
  // remove the leading 0x
  hexString = hexString.replace(/^0x/, '')

  // ensure even number of characters
  if (hexString.length % 2 != 0) {
    console.log(
      'WARNING: expecting an even number of characters in the hexString'
    )
  }

  // check for some non-hex characters
  var bad = hexString.match(/[G-Z\s]/i)
  if (bad) {
    console.log('WARNING: found non-hex characters', bad)
  }

  // split the string into pairs of octets
  var pairs = hexString.match(/[\dA-F]{2}/gi)

  // convert the octets to integers
  var integers = pairs.map(function (s) {
    return parseInt(s, 16)
  })

  var array = new Uint8Array(integers)
  // console.log(array);

  return array.buffer
}

function _webauthn_buf2hex(buffer) {
  // buffer is an ArrayBuffer
  return [...new Uint8Array(buffer)]
    .map((x) => x.toString(16).padStart(2, '0'))
    .join('')
}

function _webauthn_publickey_credentials(pAjaxIdent) {
  apex.debug.trace(
    'calling Plugin Web Authentication Public Key Region Ajax Process...'
  )
  // Ajax call um User Credentials abzufragen
  apex.server
    .plugin(pAjaxIdent, {
      // Hier könnte man noch Client Seitige Userdaten hochladen
    })
    .then((data) => {
      apex.debug.info(data)

      if (data.isAuthenticated) {
        apex.debug.info('already logged in. stopping Web Authentication.')
        // window.location.replace("f?p=&APP_ID.:HOME:&SESSION_ID."); //funktioniert irgendwie nicht
        return
      }
      const enc = new TextEncoder()
      data.challenge = enc.encode(data.challenge).buffer

      if (data.hasOwnProperty('allowCredentials')) {
        apex.debug.info(
          'found ' + data.allowCredentials.length + ' credential(s)'
        )
        for (let idx of data.allowCredentials.keys()) {
          data.allowCredentials[idx].id = _webauthn_hexStringToArrayBuffer(
            data.allowCredentials[idx].id
          )
        }

        // Nur Wenn Credentials bereits Vorhanden sind Einlogbar machen
        window[pAjaxIdent + 'credentials'] = data

        apex.debug.trace(window[pAjaxIdent + 'credentials'])
      }
    })
    .catch((err) => {
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

function _webauthn_publickey_login(pAjaxIdent, pAssertionItem) {
  if (!window[pAjaxIdent + 'credentials']) {
    apex.debug.error('No Credentials found')
    // No Credentials found.
    return
  }

  apex.debug.trace('Logging in with Web Auth...')
  navigator.credentials
    .get({
      publicKey: window[pAjaxIdent + 'credentials'],
    })
    .then((resp) => {
      if (!resp) {
        apex.debug.error('Credentials Response is empty!')
        throw "No Credentials found. Can't use Web Authentication."
      }
      window.CredentialResp = resp

      let decoder = new TextDecoder()
      const serverAssertion = {}

      // USER HANDLE = ID
      if (resp.response.userHandle) {
        apex.debug.trace('decoding userhandle...')
        serverAssertion.userId = decoder.decode(resp.response.userHandle) // USER_ID
      }

      // clientDataJSON
      apex.debug.trace('decoding clientDataJSON...')
      serverAssertion.clientData = JSON.parse(
        decoder.decode(resp.response.clientDataJSON)
      )
      serverAssertion.clientDataJSON = decoder.decode(
        resp.response.clientDataJSON
      )
      serverAssertion.clientDataJSONHex = _webauthn_buf2hex(
        resp.response.clientDataJSON
      )

      // authenticatorData
      apex.debug.trace('destructering AuthenticatorData...')
      let rpIdHash = new DataView(resp.response.authenticatorData, 0, 32)
      let flags = new DataView(resp.response.authenticatorData, 32, 1)
      let signCount = new DataView(resp.response.authenticatorData, 33, 4)
      serverAssertion.authenticatorData = {
        rpIdHashHex: _webauthn_buf2hex(rpIdHash.buffer.slice(0, 32)),
        flags: flags.getUint8(),
        signCount: signCount.getUint32(),
      }
      serverAssertion.authenticatorDataHex = _webauthn_buf2hex(
        resp.response.authenticatorData
      )

      // signature
      apex.debug.trace('working on Signature...')
      serverAssertion.signatureHex = _webauthn_buf2hex(resp.response.signature)
      serverAssertion.signature = resp.response.signature

      // getClientExtensionResults
      apex.debug.trace('working on getClientExtensionResults...')
      serverAssertion.getClientExtensionResultsHex = _webauthn_buf2hex(
        resp.getClientExtensionResults()
      )

      // Credential ID
      apex.debug.trace('working on CredentialID...')
      serverAssertion.id = resp.id

      apex.debug.trace('Final Assertion:', serverAssertion)

      // Weiterer Call zum login.
      const onConfirmSet = {}
      onConfirmSet[pAssertionItem] = JSON.stringify(serverAssertion)
      apex.page.submit({
        request: 'LOGIN_WEBAUTH',
        set: onConfirmSet,
        showWait: true,
        validate: true,
        ignoreChange: true,
      })
    })
    .catch((err) => {
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
