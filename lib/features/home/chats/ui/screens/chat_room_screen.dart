import '../../../../../core/helpers/constants/app_constants.dart';
import '../../../../../core/theming/colors.dart';
import '../../../../../core/helpers/dimensions.dart';
import '../../../../../core/theming/styles.dart';
import '../../../../../core/widgets/back_button_widget.dart';
import '../../../../contacts/data/contact_model.dart';
import '../../logic/cubit/chat_cubit.dart';
import '../widgets/messages_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/widgets/textformfield_widget.dart';
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
                return MessagesList(
                  messages: state.messages,
                  contact: widget.contact,
                );
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
}
