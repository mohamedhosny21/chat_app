import 'package:chatify/core/helpers/constants.dart';
import 'package:chatify/core/theming/colors.dart';
import 'package:chatify/core/helpers/dimensions.dart';
import 'package:chatify/core/theming/styles.dart';
import 'package:chatify/core/widgets/back_button_widget.dart';
import 'package:chatify/features/contacts/data/contact_model.dart';
import 'package:chatify/features/chats/logic/cubit/chat_cubit.dart';
import 'package:chatify/features/chats/ui/widgets/message_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/textformfield_widget.dart';
import '../../data/models/message_model.dart';

class ChatRoomScreen extends StatefulWidget {
  final ContactModel contact;
  const ChatRoomScreen({super.key, required this.contact});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController messageController = TextEditingController();
  List<Message> messages = [];
  late ChatCubit chatCubit;

  @override
  void initState() {
    super.initState();
    chatCubit = context.read<ChatCubit>();

    debugPrint('reciever id : ${widget.contact.id}');
    debugPrint('sender Id : ${chatCubit.currentUser?.uid}');
    chatCubit.initializeChatData(widget.contact.id);
  }

  // @override
  // void dispose() {
  //   chatCubit.closeListener();

  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 25.w,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButtonWidget(color: AppColors.mainBlack),
        title: _appBarTitle(),
        actions: _appBarActions(),
      ),
      body: Stack(children: [
        Positioned.fill(
          child: BlocBuilder<ChatCubit, ChatState>(
            builder: (context, state) {
              if (state is MessagesLoadedState) {
                return _buildMessageList(state.messages);
              }
              return const SizedBox();
            },
          ),
        ),
        _buildMessageInputContainer()
      ]),
    );
  }

  void _showFileSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(mainAxisSize: MainAxisSize.min, children: [
        _buildFilePickerOption(
          icon: Icons.image,
          title: 'Photo',
          onTap: () {
            Navigator.pop(context);
            chatCubit.pickAndSendImage(
              widget.contact,
            );
          },
        ),
        _buildFilePickerOption(
            icon: Icons.video_collection,
            title: 'Video',
            onTap: () {
              Navigator.pop(context);
              chatCubit.pickAndSendVideo(widget.contact);
            }),
        _buildFilePickerOption(
            icon: Icons.insert_drive_file_sharp,
            title: 'Document',
            onTap: () {
              Navigator.pop(context);
              chatCubit.pickAndSendDocument(widget.contact);
            })
      ]),
    );
  }

  Widget _buildFilePickerOption(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ListTile(
        leading: Icon(icon, size: 25.w),
        title: Text(title, style: AppStyles.font15Black500Weight),
      ),
    );
  }

  IconButton _buildAddButton() {
    return IconButton(
      onPressed: () => _showFileSourceActionSheet(),
      icon: const Icon(Icons.add),
      iconSize: 24.w,
      color: AppColors.mainGrey,
    );
  }

  AppTextFormField _buildMessageTextFormField() {
    return AppTextFormField(
        width: 279,
        height: 36,
        hintText: 'Write a message ...',
        color: AppColors.lighterGrey,
        controller: messageController);
  }

  IconButton _buildSendMessageButton() {
    return IconButton(
      onPressed: () {
        if (messageController.text.isNotEmpty) {
          chatCubit.sendMessage(
              contact: widget.contact,
              messageText: messageController.text,
              messageType: 'text');

          messageController.clear();
        }
      },
      icon: const Icon(Icons.send),
      iconSize: 24.w,
      color: AppColors.darkPink,
    );
  }

  Widget _buildMessageInputContainer() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 83.46.h,
        width: 375.w,
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Shadow color
            spreadRadius: 5, // Spread radius
            blurRadius: 10, // Blur radius
            offset: Offset(0, 2.h), // Offset in the y direction
          )
        ]),
        child: Center(
            child: Row(
          children: [
            _buildAddButton(),
            _buildMessageTextFormField(),
            _buildSendMessageButton(),
          ],
        )),
      ),
    );
  }

  List<Widget> _appBarActions() {
    return [
      IconButton(
        onPressed: () {},
        icon: const Icon(Icons.call),
        color: AppColors.mainBlack,
        iconSize: 24.w,
      ),
      IconButton(
        onPressed: () {},
        icon: const Icon(Icons.videocam_rounded),
        iconSize: 24.w,
        color: AppColors.mainBlack,
      ),
      IconButton(
        onPressed: () {},
        icon: const Icon(Icons.more_horiz),
        iconSize: 24.w,
        color: AppColors.mainBlack,
      )
    ];
  }

  Widget _appBarTitle() {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: AssetImage(widget.contact.profilePicture ??
              AppConstants
                  .defaultUserPhoto), // Replace with your contact's photo URL
          radius: 20.0.r, // Adjust as needed
        ),
        AppDimensions.horizontalSpacing8,
        Expanded(
          child: Text(
            widget.contact.name.isNotEmpty
                ? widget.contact.name
                : widget.contact.phoneNumber,
            style: AppStyles.font18Black600Weight,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _getGroupLabel(Message element) {
    if (element.status != 'uploading') {
      final DateTime dateTime = element.time!.toDate().toLocal();
      final formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
      final now = DateFormat('dd/MM/yyyy').format(DateTime.now().toLocal());
      final yesterday = DateFormat('dd/MM/yyyy').format(
          DateTime.now().toLocal().subtract(const Duration(days: 1)).toLocal());

      // final DateTime messageDate =
      //     DateTime(dateTime.year, dateTime.month, dateTime.day);
      // final currentDate =
      //     DateTime(now.year, now.month, now.day).toLocal().toString();
      // final yesterdayDate =
      //     DateTime(yesterday.year, yesterday.month, yesterday.day)
      //         .toLocal()
      //         .toString();

      // if (formattedDate == now) {
      //   return 'Today';
      // } else if (formattedDate == yesterday) {
      //   return 'Yesterday';
      // } else {
      return formattedDate;
      // }
    } else {
      return '';
    }
  }

  Widget _buildMessageList(List<Message> messages) {
    //TODO: check the order of dates with messages

    if (messages.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: GroupedListView(
          elements: messages,
          groupBy: (element) {
            return _getGroupLabel(element);
          },
          stickyHeaderBackgroundColor: Colors.white,
          order: GroupedListOrder.DESC,
          reverse: true,
          useStickyGroupSeparators: messages.length > 6 ? true : false,
          groupSeparatorBuilder: (value) => value != ''
              ? Padding(
                  padding: AppDimensions.paddingSymmetricV25H100,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      value,
                      textAlign: TextAlign.center,
                      style: AppStyles.font14Black400Weight,
                    ),
                  ),
                )
              : const SizedBox(),
          separator: AppDimensions.verticalSpacing10,
          indexedItemBuilder: (context, element, index) => MessageItem(
            contact: widget.contact,
            message: messages[index],
            isSentByMe: messages[index].senderId == chatCubit.currentUser!.uid,
          ),
        ),
      );
    }
    return Center(
      child: Text(
        'No Messages',
        style: AppStyles.font20GreyBold,
      ),
    );
  }
}
