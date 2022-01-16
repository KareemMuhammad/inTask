import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:taskaty/utils/shared.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPolicy extends StatefulWidget {
  @override
  _PrivacyPolicyState createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            color: white,
            fontFamily: 'OrelegaOne',
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: white,
      body: Builder(builder: (BuildContext context) {
        return connectivityResult == ConnectivityResult.wifi ||
            connectivityResult == ConnectivityResult.mobile ?
            WebView(
          initialUrl: PRIVACY_POLICY,
          javascriptMode: JavascriptMode.unrestricted,
        ) : Center(child: Text('No Internet Connection!',style: TextStyle(fontSize: 20,color: black),));
      }),
    );
  }
}
