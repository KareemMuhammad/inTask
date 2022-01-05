import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskaty/blocs/auth_bloc/auth_cubit.dart';
import 'package:taskaty/blocs/auth_bloc/auth_state.dart';
import 'package:taskaty/utils/shared.dart';
import 'package:taskaty/widgets/shared/custom_button.dart';
import 'package:taskaty/widgets/shared/shared_widgets.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = new TextEditingController();
  String codeDigits = '+20';
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: SizeConfig.screenHeight * 0.2,
                    width: SizeConfig.screenWidth,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(bottomRight: Radius.circular(20),bottomLeft: Radius.circular(20)),
                      gradient: myGradient(),
                    ),
                    child: Stack(alignment: Alignment.center,
                      children: [
                        Positioned(
                          child: Image.asset('assets/free_app_icon.png',height: 60,width: 60,),
                          top: 15,
                        ),
                        Positioned(
                          top: SizeConfig.screenHeight * 0.13,
                          child: Text('Welcome to inTask', style: TextStyle(
                              fontSize: 23,
                              color: white,
                              shadows: [
                                Shadow(
                                  offset: const Offset(0.0, 3.0),
                                  blurRadius: 2.0,
                                  color: const Color.fromARGB(100, 0, 0, 0),
                                ),
                              ]
                          ),textAlign: TextAlign.center,),),

                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                Center(child: Text('Enter your phone to login',
                  style: TextStyle(fontSize: 16,color: darkNavy,fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,)),
                const SizedBox(height: 5,),

                CountryCodePicker(
                  onChanged: (val){
                    setState(() {
                      codeDigits = val.dialCode;
                    });
                  },
                  initialSelection: 'EG',
                  showCountryOnly: false,
                  showOnlyCountryWhenClosed: false,
                  alignLeft: false,
                  textStyle: TextStyle(fontSize: 19,color: darkNavy,)),

                Form(
                  key: formKey,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18,vertical: 10),
                  child: TextFormField(
                     maxLength: 10,
                    style: TextStyle(color: black,fontSize: 18,),
                    decoration: textInputDecorationSign('Phone',Icons.phone_android),
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (val) {
                      return val.isEmpty || val.length < 10 ? 'Phone number is not correct!' : null;
                    },
                  ),
                ),),
                const SizedBox(height: 10,),
                Center(
                  child: RaisedGradientButton(
                    radius: 20,
                      width: SizeConfig.screenWidth * 0.35,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Next',style: TextStyle(fontSize: 22,color: white),),
                      ),
                      gradient: myGradient(),
                      onPressed: (){
                        if(formKey.currentState.validate()) {
                          BlocProvider.of<AuthCubit>(context).emit(AuthOTP(phoneController.text, codeDigits));
                        }
                      }
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}
