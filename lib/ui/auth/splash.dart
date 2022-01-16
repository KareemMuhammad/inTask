import 'package:flutter/material.dart';
import 'package:taskaty/utils/constants.dart';
import '../../utils/shared.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        body: Stack(alignment: Alignment.center,
          children: [
            Positioned.fill(child: Image.asset(Utils.splashes.first,fit: BoxFit.cover,)),
          ],
        )
    );
  }
}
