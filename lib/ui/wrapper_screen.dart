import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskaty/blocs/auth_bloc/auth_cubit.dart';
import 'package:taskaty/blocs/auth_bloc/auth_state.dart';
import 'package:taskaty/ui/auth/setup_screen.dart';
import 'package:taskaty/ui/auth/splash.dart';
import 'package:taskaty/ui/auth/otp_screen.dart';
import 'package:taskaty/widgets/stateful/splash_delayed.dart';
import 'auth/login_screen.dart';
import 'auth/otp_screen.dart';

class WrapperScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit,AuthState>(
      builder: (context, state) {
        if (state is AuthInitial) {
          return SplashScreen();
        }else if (state is AuthFailure){
          return LoginScreen();
        }else if (state is AuthSuccessful){
          return DelayedSplashScreen();
        }else if (state is AuthOTP){
          return OTPTestScreen(phone: state.phone,codeDigits: state.codeDigits,);
        }else if (state is AuthSetup){
          return SetupScreen();
        }
        else{
          return SplashScreen();
        }
      },
    );
  }
}
