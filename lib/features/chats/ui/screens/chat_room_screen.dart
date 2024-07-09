import 'package:chatify/core/helpers/constants/app_constants.dart';
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

  IconButton _buildAddFileButton() {
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
        prefixIconColor: AppColors.lighterGrey,
        controller: messageController);
  }

  Widget _buildSendMessageButton() {
    return Flexible(
      child: IconButton(
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
      ),
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
            _buildAddFileButton(),
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
          backgroundImage: widget.contact.profilePicture == null
              ? const AssetImage(AppConstants.defaultUserPhoto)
              : NetworkImage(widget.contact.profilePicture!) as ImageProvider,
          radius: 20.0.r,
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

  String _showGroupLabel(Message message) {
    if (message.status != 'uploading') {
      final DateTime dateTime = message.time!.toDate().toLocal();
      final DateTime now = DateTime.now().toLocal();
      final DateTime startOfToday = DateTime(now.year, now.month, now.day);
      final DateTime startOfYesterday =
          startOfToday.subtract(const Duration(days: 1));

      if (dateTime.isAfter(startOfToday)) {
        return 'Today';
      } else if (dateTime.isAfter(startOfYesterday)) {
        return 'Yesterday';
      } else {
        return DateFormat('dd/MM/yyyy').format(dateTime);
      }
    } else {
      return '';
    }
  }

  Widget _buildMessageList(List<Message> messages) {
    if (messages.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: GroupedListView<Message, String>(
          elements: messages,
          groupBy: (message) => _showGroupLabel(message),
          //to ensure that "Today" and "Yesterday" appear at the top, followed by other dates in descending order.
          groupComparator: (group1, group2) => _sortMessagesGroupLabels(group1,
              group2), //the order of items within each group are ordered in descending order of their timestamps (newest first)
          itemComparator: (item1, item2) => item2.time!.compareTo(item1.time!),
          reverse: true,
          stickyHeaderBackgroundColor: Colors.white,
          useStickyGroupSeparators: messages.length > 6 ? true : false,
          groupSeparatorBuilder: (messageDate) =>
              _buildGroupHeaderLabel(messageDate),
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

  int _sortMessagesGroupLabels(String group1, String group2) {
    if (group1 == 'Today') return -1;
    if (group2 == 'Today') return 1;
    if (group1 == 'Yesterday') return -1;
    if (group2 == 'Yesterday') return 1;
    if (group1.isEmpty || group2.isEmpty) {
      return group2.isEmpty
          ? -1
          : 1; // empty groups should be placed at the bottom
    }

    final DateTime date1 = DateFormat('dd/MM/yyyy').parse(group1);
    final DateTime date2 = DateFormat('dd/MM/yyyy').parse(group2);

    return date2.compareTo(date1);
  }

  Widget _buildGroupHeaderLabel(String messageDate) {
    if (messageDate.isNotEmpty) {
      return Padding(
        padding: AppDimensions.paddingSymmetricV25H100,
        child: Container(
          decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20.r)),
          child: Text(
            messageDate,
            textAlign: TextAlign.center,
            style: AppStyles.font14Black400Weight,
          ),
        ),
      );
    }
    return const SizedBox();
  }
}
