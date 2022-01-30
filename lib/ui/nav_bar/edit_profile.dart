import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskaty/blocs/user_bloc/user_cubit.dart';
import 'package:taskaty/blocs/user_bloc/user_state.dart';
import 'package:taskaty/models/user_model.dart';
import 'package:taskaty/utils/constants.dart';
import 'package:taskaty/utils/shared.dart';
import 'package:taskaty/widgets/shared/custom_button.dart';
import 'package:taskaty/widgets/shared/shared_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  final AppUser appUser;

  const EditProfileScreen({Key key, this.appUser}) : super(key: key);
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _name = '';

  @override
  void initState() {
    super.initState();
    if(widget.appUser.name.isNotEmpty) {
      this._nameController.text = widget.appUser.name ?? '';
    }
    if(widget.appUser.email.isNotEmpty) {
      this._emailController.text = widget.appUser.email ?? '';
    }
    this._phoneController.text = widget.appUser.phone ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final UserCubit userCubit = BlocProvider.of<UserCubit>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: white,
            fontFamily: 'OrelegaOne',
          ),
        ),
      ),
      backgroundColor: white,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                const SizedBox(height: 25,),
                TextFormField(
                  controller: this._nameController,
                  textDirection: Utils.isRTL(_name.isNotEmpty ? _name : _nameController.text) ? TextDirection.rtl : TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    alignLabelWithHint: true,
                    contentPadding: EdgeInsets.all(15.0),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                    ),
                  ),
                  onChanged: (val){
                    setState(() {
                      _name = val;
                    });
                  },
                ),
                const SizedBox(height: 30,),
                TextFormField(
                  controller: this._emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    alignLabelWithHint: true,
                    contentPadding: EdgeInsets.all(15.0),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                    ),
                  ),
                ),
                const SizedBox(height: 30,),
                TextFormField(
                  enabled: false,
                  controller: this._phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    alignLabelWithHint: true,
                    contentPadding: EdgeInsets.all(15.0),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                    ),
                  ),
                ),
                const SizedBox(height: 30,),
                BlocConsumer<UserCubit,UserState>(
                  listener: (context,state){
                    if(state is UserLoaded){
                      setState(() {
                        this._nameController.text = state.appUser.name;
                        this._emailController.text = state.appUser.email;
                      });
                      Scaffold.of(context)
                          .showSnackBar(SnackBar(content: Text('Profile Updated')));
                    }
                  },
                  builder: (context,state) {
                    return state is UserLoading ? spinKit
                    :Center(
                      child: RaisedGradientButton(
                          radius: 20,
                          width: SizeConfig.screenWidth * 0.3,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Save',style: TextStyle(fontSize: 20,color: white),),
                          ),
                          gradient: myGradient(),
                          onPressed: (){
                            if(_formKey.currentState.validate()){
                                userCubit.updateUserInfo(_nameController.text, AppUser.NAME);
                                userCubit.updateUserInfo(_emailController.text, AppUser.EMAIL);
                                userCubit.loadUserData();
                            }
                          }
                      ),
                    );
                  }
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
