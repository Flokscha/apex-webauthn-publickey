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