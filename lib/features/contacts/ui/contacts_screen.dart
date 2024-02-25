import 'package:chatify/constants/colors.dart';
import 'package:chatify/constants/dimensions.dart';
import 'package:chatify/constants/styles.dart';
import 'package:chatify/widgets/circular_progress_indicator.dart';
import 'package:chatify/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_sharp,
            ),
            iconSize: 24.w,
          ),
          backgroundColor: AppColors.lightPink,
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
          return Padding(
            padding: AppDimensions.paddingTop12,
            child: ListView.separated(
              separatorBuilder: (context, index) =>
                  AppDimensions.verticalSpacing16,
              itemBuilder: (context, index) {
                if (state.filteredContacts.isNotEmpty) {
                  return ContactItem(
                    contact: state.filteredContacts[index],
                    contactId: state.filteredContactsId[index],
                  );
                } else {
                  return Center(
                    child: Text(
                      'No Contacts !',
                      style: AppStyles.font20GreyBold,
                    ),
                  );
                }
              },
              itemCount: state.filteredContacts.length,
            ),
          );
        } else {
          return const SizedBox();
        }
      },
      listener: (context, state) {
        if (state is ContactsLoadingState) {
          showCircularProgressIndicator(context);
        } else if (state is ContactsLoadedState) {
          Navigator.pop(context);
        } else if (state is ContactsErrorState) {
          Navigator.pop(context);
          showErrorSnackBar(context, state.errorMsg);
        }
      },
    );
  }
}
