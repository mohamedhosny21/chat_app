import '../../../../constants/colors.dart';
import '../../../../constants/dimensions.dart';
import '../../../../constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

import '../../../../app_router/routes.dart';
import '../../../widgets/circular_progress_indicator.dart';
import '../../../widgets/snackbar.dart';
import '../logic/authentication_cubit/authentication_cubit.dart';

// ignore: must_be_immutable
class LoginScreen extends StatelessWidget {
  PhoneNumber phoneNumber = PhoneNumber.fromCompleteNumber(completeNumber: '');
  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: AppDimensions.paddingSymmetricV50H50,
          child: SingleChildScrollView(
            child: loginBlocListener(
              child: Column(
                children: [
                  Text(
                    'Please Enter Your Phone Number To Verify Your Account',
                    style: AppStyles.font20GreyBold,
                  ),
                  AppDimensions.verticalSpacing100,
                  Form(
                      key: context.read<AuthenticationCubit>().phoneAuthFormKey,
                      child: buildPhoneFormField()),
                  AppDimensions.verticalSpacing100,
                  MaterialButton(
                    onPressed: () {
                      final formKey =
                          context.read<AuthenticationCubit>().phoneAuthFormKey;
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        context
                            .read<AuthenticationCubit>()
                            .loginWithPhoneNumber(phoneNumber.completeNumber);
                      }
                    },
                    color: AppColors.mainPink,
                    minWidth: double.infinity,
                    height: 40.h,
                    child: Text(
                      'Next',
                      style: AppStyles.font18Black600Weight,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPhoneFormField() {
    return IntlPhoneField(
      style: AppStyles.font14Black400Weight
          .copyWith(letterSpacing: 3, fontWeight: FontWeight.bold),
      decoration: const InputDecoration(
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.mainBlack))),
      initialCountryCode: 'EG',
      autofocus: true,
      keyboardType: TextInputType.phone,
      onSaved: (value) {
        phoneNumber = value!;
      },
      autovalidateMode: AutovalidateMode.disabled,
    );
  }

  BlocListener loginBlocListener({required Widget child}) {
    return BlocListener<AuthenticationCubit, AuthenticationState>(
      listener: (context, state) {
        if (state is LoginLoadingState) {
          showCircularProgressIndicator(context);
        } else if (state is PhoneNumberSubmittedState) {
          Navigator.pop(context);
          Navigator.of(context).pushNamed(Routes.otpScreen, arguments: {
            'phone_number': phoneNumber,
            'verification_ID': state.verificationId
          });
        } else if (state is LoginFailedState) {
          Navigator.pop(context);
          showErrorSnackBar(context, state.errorMsg);
        }
      },
      child: child,
    );
  }
}
