import 'package:chatify/constants/colors.dart';
import 'package:chatify/constants/dimensions.dart';
import 'package:chatify/constants/styles.dart';
import 'package:chatify/widgets/circular_progress_indicator.dart';
import 'package:chatify/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../logic/contacts_cubit/cubit/contacts_cubit.dart';
import 'widgets/contacts_item_widget.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  @override
  void initState() {
    super.initState();

    context.read<ContactsCubit>().showFilteredContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: AppColors.mainPink,
          title: Text(
            'My Contacts',
            style: AppStyles.font18Black600Weight,
          )),
      body: RefreshIndicator(
          onRefresh: () => context.read<ContactsCubit>().showFilteredContacts(),
          child: _buildContactsBlocConsumer()),
    );
  }

  BlocConsumer _buildContactsBlocConsumer() {
    return BlocConsumer<ContactsCubit, ContactsState>(
      builder: (context, state) {
        if (state is ContactsLoadedState) {
          Navigator.pop(context);

          return Padding(
            padding: AppDimensions.paddingSymmetricV12H12,
            child: ListView.separated(
              separatorBuilder: (context, index) =>
                  AppDimensions.verticalSpacing16,
              itemBuilder: (context, index) {
                if (state.contacts.isNotEmpty) {
                  return ContactItem(contact: state.contacts[index]);
                } else {
                  return Center(
                    child: Text(
                      'No Contacts !',
                      style: AppStyles.font20GreyBold,
                    ),
                  );
                }
              },
              itemCount: state.contacts.length,
            ),
          );
        } else {
          return const SizedBox();
        }
      },
      listener: (context, state) {
        if (state is ContactsLoadingState) {
          showCircularProgressIndicator(context);
        } else if (state is ContactsErrorState) {
          Navigator.pop(context);
          showErrorSnackBar(context, state.errorMsg);
        }
      },
    );
  }
}
