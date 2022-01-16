import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskaty/blocs/auth_bloc/auth_cubit.dart';
import 'package:taskaty/blocs/user_bloc/user_cubit.dart';
import 'package:taskaty/blocs/user_bloc/user_state.dart';
import 'package:taskaty/models/user_model.dart';
import 'package:taskaty/utils/constants.dart';
import 'package:taskaty/utils/shared.dart';
import 'package:taskaty/widgets/shared/shared_widgets.dart';

class SetupScreen extends StatefulWidget {
  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _textController = new TextEditingController();
  final TextEditingController _emailController = new TextEditingController();
  String _brand = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50,),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text('Lets setup your profile',style: TextStyle(fontSize: 20,color: black,fontWeight: FontWeight.bold)
                ,textAlign: TextAlign.center,),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset('assets/tasks.jpg',height: 100,width: 200,),
            ),
            customEditBrand('Email','Name', TextInputType.emailAddress),
            const SizedBox(height: 20,),
            BlocConsumer<UserCubit,UserState>(
              listener:  (context,state){
                if(state is UserLoaded){
                  BlocProvider.of<AuthCubit>(context).loadUserData();
                }
              },
              builder: (context,state) {
                return state is UserLoading ? spinKit : nextButton(checkValidation);
              }
            ),
          ],
        ),
      ),
    );
  }

  void checkValidation()async{
    if(_formKey.currentState.validate()){
      bool result = await BlocProvider.of<UserCubit>(context).authUserEmail(_emailController.text);
      if(result) {
        BlocProvider.of<UserCubit>(context).updateUserInfo(_textController.text, AppUser.NAME);
        BlocProvider.of<UserCubit>(context).updateUserInfo(_emailController.text, AppUser.EMAIL);
        BlocProvider.of<UserCubit>(context).loadUserData();
      }else{
        Utils.showSnack('This email is already existed', '', context, lightNavy);
      }
    }
  }

  Widget customEditBrand(String emailText,String nameText,TextInputType inputType){
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
            child: Material(
              borderRadius: BorderRadius.circular(10.0),
              color: lightNavy,
              elevation: 2,
              child: MaterialButton(
                minWidth: SizeConfig.screenWidth,
                onPressed: () {

                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    keyboardType: inputType,
                    style: TextStyle(color: black,fontSize: 18,),
                    textDirection: Utils.isRTL(_brand.isNotEmpty ? _brand : _textController.text) ? TextDirection.rtl : TextDirection.ltr,
                    onChanged: (value){
                      setState(() {
                        _brand = value;
                      });
                    },
                    decoration: textInputDecoration2(nameText),
                    controller: _textController,
                    validator: (val) {
                      return val.isEmpty ? 'name cannot be empty!' : null;
                    },
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
            child: Material(
              borderRadius: BorderRadius.circular(10.0),
              color: lightNavy,
              elevation: 2,
              child: MaterialButton(
                minWidth: SizeConfig.screenWidth,
                onPressed: () {

                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    keyboardType: inputType,
                    style: TextStyle(color: black,fontSize: 18,),
                    decoration: textInputDecoration2(emailText),
                    controller: _emailController,
                    validator: (val){
                      return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(val)
                          ? null : 'enter a valid email!';
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget nextButton(Function func){
    return GestureDetector(
      onTap: func,
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          color: lightNavy,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Save',style: TextStyle(fontSize: 19,color: white,),
                textAlign: TextAlign.center,),
              const SizedBox(width: 5,),
              const Icon(Icons.arrow_forward_ios,color: white,size: 19,),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
  }

}
