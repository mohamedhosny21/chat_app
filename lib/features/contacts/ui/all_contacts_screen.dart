import 'package:chatify/constants/colors.dart';
import 'package:chatify/constants/styles.dart';
import 'package:chatify/features/contacts/logic/cubit/contacts_cubit.dart';
import 'package:chatify/features/contacts/ui/widgets/contact_item_widget.dart';
import 'package:chatify/widgets/circular_progress_indicator.dart';
import 'package:chatify/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  @override
  void initState() {
    super.initState();

    context.read<ContactsCubit>().getContactsFromPhone();
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
      body: _buildContactsBlocConsumer(),
    );
  }

  BlocConsumer _buildContactsBlocConsumer() {
    return BlocConsumer<ContactsCubit, ContactsState>(
      builder: (context, state) {
        if (state is ContactsLoadedState) {
          return ListView.builder(
            itemBuilder: (context, index) =>
                ContactItem(contact: state.contacts[index]),
            itemCount: state.contacts.length,
          );
        } else {
          return const SizedBox();
        }
      },
      listener: (context, state) {
        if (state is ContactsLoadingState) {
          showCircularProgressIndicator(context);
        } else if (state is ContactsErrorState) {
          showErrorSnackBar(context, state.errorMsg);
        }
      },
    );
  }
}
