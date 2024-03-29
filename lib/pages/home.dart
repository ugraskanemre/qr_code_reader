import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hex/hex.dart';

import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<HomePage> {
  Size _size;
  String barcode = "";
  bool _done = false;
  List<String> data = [];
  List<int> encodedUrl;
  String decodedUrl;
  String token;
  List<Map> _pushData = List();

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _size = Size(MediaQuery.of(context).size.width, 35);
    return Scaffold(
      appBar: new AppBar(
        title: new Text('QR Kod Okuyucu'),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 10.0, bottom: 30.0),
              width: _size.width + 150,
              height: _size.height + 120,
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: new AssetImage("assets/img/qr_code.jpeg"),
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
            barcode == ""
                ? Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 50.0, vertical: 8.0),
                    child: RaisedButton(
                        color: Colors.blue,
                        textColor: Colors.white,
                        splashColor: Colors.blueGrey,
                        onPressed: scan,
                        child: Text('QR Kod Taramaya Başla')))
                : Container(),
            barcode != "" && _done == true
                ? Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      "Adres: ${decodedUrl}\nToken: ${token}",
                      textAlign: TextAlign.center,
                    ),
                  )
                : Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.0, vertical: 20.0),
                    child: Text(
                      "${barcode}",
                      textAlign: TextAlign.center,
                    ),
                  ),
            barcode != ""
                ? Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RaisedButton(
                          color: Colors.grey,
                          textColor: Colors.white,
                          splashColor: Colors.blueGrey,
                          onPressed: () => SystemChannels.platform
                              .invokeMethod('SystemNavigator.pop'),
                          child: Text('Çıkış Yap'),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        RaisedButton(
                          color: Colors.blue,
                          textColor: Colors.white,
                          splashColor: Colors.blueGrey,
                          onPressed: scan,
                          child: Text('Tekrar Tara'),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        _done == true
                            ? RaisedButton(
                                color: Colors.green,
                                textColor: Colors.white,
                                splashColor: Colors.blueGrey,
                                onPressed: () => Navigator.of(context)
                                    .pushNamed('/photo', arguments: _pushData),
                                child: Text('Devam Et'),
                              )
                            : Container(),
                      ],
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      data = barcode.split(":");
      token = data[1];
      print(data[0]);
      print(ascii.decode(HEX.decode(data[0])));

      setState(() {
        this.barcode = barcode;
        decodedUrl = ascii.decode(HEX.decode(data[0]));
        _done = true;
        _pushData.add({"token": token, "decodedUrl": decodedUrl});
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'Kamera kullanımına izin vermediniz!';
        });
      } else {
        setState(() => this.barcode = 'Bilinmeyen Hata: $e');
      }
    } on FormatException {
      setState(() =>
          this.barcode = '(Herhangi bir şey taramadan geri tuşuna bastınız.)');
    } catch (e) {
      setState(() => this.barcode = 'Bilinmeyen Hata: $e');
    }
  }
}
