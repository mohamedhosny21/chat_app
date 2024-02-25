import 'package:chatify/widgets/shared_preferences.dart';

import '../../../../constants/colors.dart';
import '../../../../constants/dimensions.dart';
import '../../../../constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../app_router/routes.dart';
import '../../../widgets/circular_progress_indicator.dart';
import '../../../widgets/snackbar.dart';
import '../logic/authentication_cubit/authentication_cubit.dart';

// ignore: must_be_immutable
class OtpScreen extends StatelessWidget {
  final PhoneNumber phoneNumber;
  final String verificationId;
  String smsCode = '';
  OtpScreen(
      {super.key, required this.phoneNumber, required this.verificationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
          child: Padding(
        padding: AppDimensions.paddingSymmetricV50H50,
        child: _buildOtpBlocListener(
          child: Column(
            children: [
              _buildHeaderText(),
              AppDimensions.verticalSpacing50,
              _buildPinCodeTextField(context),
              AppDimensions.verticalSpacing50,
              MaterialButton(
                onPressed: () {
                  final formKey =
                      context.read<AuthenticationCubit>().pinFormKey;
                  if (formKey.currentState!.validate()) {
                    context
                        .read<AuthenticationCubit>()
                        .submitPhoneOtp(smsCode, verificationId);
                  }
                },
                color: AppColors.lightPink,
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
      )),
    );
  }

  Widget _buildHeaderText() {
    return Column(
      children: [
        Text(
          'Verify Your Number',
          style: AppStyles.font25BlackBold,
        ),
        AppDimensions.verticalSpacing50,
        RichText(
            text: TextSpan(children: [
          TextSpan(
              text: 'Enter your 6 digits code numbers sent to ',
              style: AppStyles.font25BlackBold),
          TextSpan(
              text: phoneNumber.completeNumber, style: AppStyles.font20GreyBold)
        ])),
      ],
    );
  }

  Widget _buildPinCodeTextField(BuildContext context) {
    return Form(
      key: context.read<AuthenticationCubit>().pinFormKey,
      child: PinCodeTextField(
        validator: (value) {
          if (value!.isEmpty || value.length < 6) {
            return 'Please Complete Your Code !';
          } else {
            return null;
          }
        },
        onCompleted: (code) {
          smsCode = code;
        },
        appContext: context,
        length: 6,
        autoFocus: true,
        cursorColor: AppColors.mainBlack,
        keyboardType: TextInputType.number,
        pinTheme: PinTheme(
          fieldWidth: 40.w,
          fieldHeight: 50.h,
          activeColor: Colors.green,
          inactiveColor: AppColors.lightPink,
          selectedColor: Colors.blue,
          shape: PinCodeFieldShape.box,
        ),
      ),
    );
  }

  BlocListener _buildOtpBlocListener({required Widget child}) {
    return BlocListener<AuthenticationCubit, AuthenticationState>(
      listener: (context, state) {
        if (state is LoginLoadingState) {
          showCircularProgressIndicator(context);
        } else if (state is LoginSuccessState) {
          Navigator.pop(context);

          AppSharedPreferences.savePhoneNumber(phoneNumber.completeNumber);
          context
              .read<AuthenticationCubit>()
              .createNewUser(phoneNumber: phoneNumber.completeNumber);
          Navigator.of(context)
              .pushNamedAndRemoveUntil(Routes.homeScreen, (route) => false);
        } else if (state is LoginFailedState) {
          Navigator.pop(context);
          showErrorSnackBar(context, state.errorMsg);
        }
      },
      child: child,
    );
  }
}
