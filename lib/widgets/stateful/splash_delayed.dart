import 'package:delayed_display/delayed_display.dart';
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
        const Duration(seconds: 2),
            () =>  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainScreen()))
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
            child: DelayedDisplay(
              delay: const Duration(seconds: 1),
              child: Container(
                    height: SizeConfig.screenHeight * 0.28,
                    width: SizeConfig.screenWidth ,
                    child: Center(
                      child: Text('Lost in Sticky Notes?',style: TextStyle(fontWeight: FontWeight.bold,
                          color: white,letterSpacing: 1,fontSize: 55,fontFamily: 'OrelegaOne',
                          shadows: [
                            Shadow(
                              offset: const Offset(0.0, 3.0),
                              blurRadius: 2.0,
                              color: const Color.fromARGB(100, 0, 0, 0),
                            ),
                          ]),textAlign: TextAlign.center,),
                    ),
              ),
            ),
          )
        ],
      )
    );
  }
}