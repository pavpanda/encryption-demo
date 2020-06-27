import 'package:flutter/material.dart';
import 'package:encryptiondemo/util/rsa_key_helper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/api.dart' as crypto;
import 'package:encryptiondemo/util/dependency_provider.dart';
import 'dart:math';





void main() => runApp(MyApp());

class MyApp extends StatelessWidget {


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  _MyHomePageState();

  TextEditingController controller = new TextEditingController();

  String displayText = "Your keys are here";

  String message;

  RSAPublicKey pubKey;

  RSAPrivateKey priKey;


  // need to cite.
  /// With the helper [RsaKeyHelper] this method generates a
  /// new [crypto.AsymmetricKeyPair<crypto.PublicKey, crypto.PrivateKey>
  Future<crypto.AsymmetricKeyPair<crypto.PublicKey, crypto.PrivateKey>>
  getKeyPair() {
    var keyHelper = RsaKeyHelper();
    return keyHelper.computeRSAKeyPair(keyHelper.getSecureRandom());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Encryption Demo"),
        ),

      body: SafeArea(
          child: Center(
            child: ListView(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(40),
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(labelText: 'String to encrypt'),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton(
                      child: Text("AES encrypt"),
                      color: Color(0xFF4B9DFE),
                      textColor: Colors.white,
                      padding: EdgeInsets.only(
                          left: 20, right: 20, top: 10, bottom: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      onPressed: (){
                        aesfunc(controller.text, true);
                      },
                    ),

                    FlatButton(
                      child: Text("AES decrypt"),
                      color: Colors.blue,
                      textColor: Colors.white,
                      padding: EdgeInsets.only(
                          left: 20, right: 20, top: 10, bottom: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                        onPressed: (){
                          aesfunc(controller.text, false);
                        }
                    )
                  ],
                ),

                SizedBox(
                  height: 40,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton(
                      child: Text("RSA encrypt"),
                      color: Color(0xFF4B9DFE),
                      textColor: Colors.white,
                      padding: EdgeInsets.only(
                          left: 20, right: 20, top: 10, bottom: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      onPressed: (){
                        rsa(controller.text, true);
                      },
                    ),

                    FlatButton(
                        child: Text("RSA decrypt"),
                        color: Colors.blue,
                        textColor: Colors.white,
                        padding: EdgeInsets.only(
                            left: 20, right: 20, top: 10, bottom: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        onPressed: (){
                          rsa(controller.text, false);

                        }
                    )
                  ],

                ),

                Center(
                  child: Container(
                    padding: EdgeInsets.only(top: 40),
                    child: Text(
                        displayText
                    ),
                  )
                )
              ],
            )
          ),
      ),
    );
  }

  String aesfunc(String message, bool isEncrypt) {
    final symmetricFamilyKey = encrypt.Key.fromUtf8(getRandomString(32));
    final iv = encrypt.IV.fromLength(16);

    // iv can be generated from base16 form using: encrypt.IV.fromBase16()
    final aesEncrypter = encrypt.Encrypter(encrypt.AES(symmetricFamilyKey));



    final aesEncrypted = aesEncrypter.encrypt(message, iv: iv);
    final aesDecrypted = aesEncrypter.decrypt(aesEncrypted, iv: iv);

    // generate AES Key
    // return encrypted message

    setState(() {
        if (isEncrypt) {
          displayText = aesEncrypted.base16;
        }
        else {
          displayText = aesDecrypted;
        }
    });
  }

  void decryptMessageAES(encrypt.Encrypted encryptedMessage) {
    // use previous AES key to decrypt message
    // return decrypted  message
  }

  Future<List> rsa(String message, bool isEncrypt) {
        // generate RSA pair
        getKeyPair().then((crypto.AsymmetricKeyPair pair) async {
          RSAPublicKey userPublicKey = pair.publicKey;
          RSAPrivateKey userPrivateKey = pair.privateKey;

          final rsaEncrypter = encrypt.Encrypter(encrypt.RSA(publicKey: userPublicKey, privateKey: userPrivateKey));
          final rsaEncrypted = rsaEncrypter.encrypt(message);
          final rsaDecrypted = rsaEncrypter.decrypt(rsaEncrypted);

          print(rsaEncrypted.base16);
          print(rsaDecrypted);
          // return encrypted message

          setState(() {
            if (isEncrypt) {
              displayText = rsaEncrypted.base16;
            }
            else {
              displayText = rsaDecrypted;
            }

          });

          return [rsaEncrypted.base16, rsaDecrypted];


        });
  }

  String decryptMessageRSA(String encryptedMessage, RSAPublicKey pubk, RSAPrivateKey prik) {
    // use generated RSA pair to decrypt message
    final rsaEncrypter = encrypt.Encrypter(encrypt.RSA(
        publicKey: pubk, privateKey: prik));
    final rsaEncrypted = encrypt.Encrypted.fromBase16(encryptedMessage);
    
    return rsaEncrypter.decrypt(rsaEncrypted);
    
    // return decrypted message


  }

  String getRandomString(int strlen) {
    const chars = "abcdefghijklmnopqrstuvwxyz0123456789";

    Random rnd = new Random(new DateTime.now().millisecondsSinceEpoch);
    String result = "";
    for (var i = 0; i < strlen; i++) {
      result += chars[rnd.nextInt(chars.length)];
    }
    return result;
  }
}
