import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:taskaty/ui/main_screen.dart';
import 'package:taskaty/utils/constants.dart';
import '../../utils/shared.dart';

class DelayedSplashScreen extends StatefulWidget {
  @override
  State<DelayedSplashScreen> createState() => _DelayedSplashScreenState();
}

class _DelayedSplashScreenState extends State<DelayedSplashScreen> {
  @override
  void initState() {
    new Future.delayed(
        const Duration(seconds: 1),
            () =>  Navigator.push(context, MaterialPageRoute(builder: (_) => MainScreen()))
    );
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Stack(alignment: Alignment.center,
        children: [
          Positioned.fill(child: Image.asset(Utils.splashes.first,fit: BoxFit.cover,)),
          Positioned(
            bottom: SizeConfig.screenHeight * 0.2,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(
                  height: SizeConfig.screenHeight * 0.2,
                  width: SizeConfig.screenWidth ,
                  child: Center(
                    child: Text('Lost in Sticky Notes?',style: TextStyle(fontWeight: FontWeight.bold,
                        color: white,letterSpacing: 1,fontSize: 50),textAlign: TextAlign.center,),
                  ),
                ),
              ),
            ),
          )
        ],
      )
    );
  }
}