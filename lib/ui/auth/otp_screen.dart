import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:taskaty/blocs/auth_bloc/auth_cubit.dart';
import 'package:taskaty/models/user_model.dart';
import 'package:taskaty/repo/user_repository.dart';
import 'package:taskaty/utils/shared.dart';

class OTPTestScreen extends StatefulWidget {
  final String phone;
  final String codeDigits;

  const OTPTestScreen({Key key, this.phone, this.codeDigits}) : super(key: key);

  @override
  _OTPTestScreenState createState() => _OTPTestScreenState();
}

class _OTPTestScreenState extends State<OTPTestScreen> {
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  String _verificationCode;
  final TextEditingController _pinPutController = TextEditingController();
  final UserRepository userRepository = UserRepository();
  final FocusNode _pinPutFocusNode = FocusNode();
  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: lightNavy),
      borderRadius: BorderRadius.circular(15.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      appBar: AppBar(
        backgroundColor: darkNavy,
        title: Text('OTP Verification'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 60,),
          Text('Verifying ${widget.codeDigits + widget.phone} ...',
            style: TextStyle(fontSize: 22,color: black,),),
          const SizedBox(height: 10,),
          Center(
            child: Text('Please wait',
              style: TextStyle(fontSize: 17,color: black,),),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: PinPut(
              fieldsCount: 6,
              textStyle: const TextStyle(fontSize: 25.0, color: black),
              eachFieldWidth: 40.0,
              eachFieldHeight: 55.0,
              focusNode: _pinPutFocusNode,
              controller: _pinPutController,
              submittedFieldDecoration: _pinPutDecoration.copyWith(
                borderRadius: BorderRadius.circular(20.0),
              ),
              selectedFieldDecoration: _pinPutDecoration,
              followingFieldDecoration: _pinPutDecoration.copyWith(
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(
                  color: darkNavy,
                ),
              ),
              pinAnimationType: PinAnimationType.rotation,
              onSubmit: (pin) async {
                try {
                  await FirebaseAuth.instance
                      .signInWithCredential(PhoneAuthProvider.credential(
                      verificationId: _verificationCode, smsCode: pin))
                      .then((value) async {
                    if (value.user != null) {
                      bool isNew = await userRepository.authenticateUser(value.user);
                     if(isNew){
                       AppUser appUser = AppUser(id: value.user.uid,phone: value.user.phoneNumber,name: '',token: '');
                       await userRepository.saveUserToDb(appUser.toMap(), value.user.uid);
                     }
                      BlocProvider.of<AuthCubit>(context).loadUserData();
                    }
                  });
                } catch (e) {
                  FocusScope.of(context).unfocus();
                  _scaffoldkey.currentState
                      .showSnackBar(SnackBar(content: Text('invalid OTP')));
                }
              },
            ),
          )
        ],
      ),
    );
  }

  _verifyPhone() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: "${widget.codeDigits + widget.phone}",
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance
              .signInWithCredential(credential)
              .then((value) async {
            if (value.user != null) {
               bool isNew = await userRepository.authenticateUser(value.user);
              if(isNew){
                AppUser appUser = AppUser(id: value.user.uid,phone: value.user.phoneNumber,name: '',token: '');
                await userRepository.saveUserToDb(appUser.toMap(), value.user.uid);
              }
              BlocProvider.of<AuthCubit>(context).loadUserData();
            }
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          print(e.message);
        },
        codeSent: (String verficationID, int resendToken) {
            _verificationCode = verficationID;
        },
        codeAutoRetrievalTimeout: (String verificationID) {
            _verificationCode = verificationID;
        },
        timeout: const Duration(seconds: 120));
  }

  @override
  void initState() {
    super.initState();
    _verifyPhone();
  }
}