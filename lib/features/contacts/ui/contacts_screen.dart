import 'package:chatify/core/helpers/dimensions.dart';
import 'package:chatify/core/theming/colors.dart';
import 'package:chatify/core/theming/styles.dart';
import 'package:chatify/core/helpers/snackbar.dart';
import 'package:chatify/core/widgets/back_button_widget.dart';
import 'package:chatify/features/contacts/data/contact_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../logic/cubit/contacts_cubit.dart';
import 'widgets/contacts_item_widget.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  late ContactsCubit _contactsCubit;
  @override
  void initState() {
    super.initState();
    _contactsCubit = context.read<ContactsCubit>();
    _contactsCubit.showFilteredContacts();
    _contactsCubit.listenChangedContacts();
  }

  @override
  // void dispose() {
  //   _contactsCubit.closeListeners();

  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          leading: const BackButtonWidget(
            color: AppColors.mainBlack,
          ),
          title: Text(
            'My Contacts',
            style: AppStyles.font18Black600Weight,
          )),
      body: RefreshIndicator(
          onRefresh: () => _contactsCubit.showFilteredContacts(),
          child: _buildContactsBlocConsumer()),
    );
  }

  BlocConsumer _buildContactsBlocConsumer() {
    return BlocConsumer<ContactsCubit, ContactsState>(
      builder: (context, state) {
        if (state is ContactsLoadedState) {
          return Padding(
              padding: AppDimensions.paddingTop12,
              child: _buildContactsListView(state.filteredContacts));
        }
        return const SizedBox();
      },
      listener: (context, state) {
        if (state is ContactsErrorState) {
          Navigator.pop(context);
          showErrorSnackBar(context, state.errorMsg);
        }
      },
    );
  }

  Widget _buildContactsListView(List<ContactModel> filteredContacts) {
    if (filteredContacts.isEmpty) {
      return ListWheelScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        itemExtent: 30,
        children: [
          Center(
            child: Text(
              'No Contacts !',
              style: AppStyles.font20GreyBold,
            ),
          ),
        ],
      );
    }
    return ListView.separated(
      separatorBuilder: (context, index) => AppDimensions.verticalSpacing16,
      itemBuilder: (context, index) {
        return ContactItem(
          contact: filteredContacts[index],
        );
      },
      itemCount: filteredContacts.length,
    );
  }
}
