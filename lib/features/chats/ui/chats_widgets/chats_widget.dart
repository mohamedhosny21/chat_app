import '../../../../constants/colors.dart';
import '../../../../constants/dimensions.dart';
import '../../../../constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatsWidget extends StatelessWidget {
  const ChatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        child: ListView.separated(
          itemBuilder: (context, index) => const ChatItem(),
          separatorBuilder: (context, index) => AppDimensions.verticalSpacing16,
          itemCount: 15,
        ),
      ),
    );
  }
}

class ChatItem extends StatelessWidget {
  const ChatItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              height: 56.h,
              width: 56.5,
              decoration: BoxDecoration(
                image: const DecorationImage(
                    image: NetworkImage(
                        'https://th.bing.com/th/id/OIP.k-TUHLRQtLCOFssPsmNgRwHaJP?w=143&h=180&c=7&r=0&o=5&dpr=1.4&pid=1.7')),
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            Positioned(
              right: 0,
              child: Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    color: AppColors.green,
                    shape: BoxShape.circle),
              ),
            )
          ],
        ),
        AppDimensions.horizontalSpacing8,
        const ChatComponents()
      ],
    );
  }
}

class ChatComponents extends StatelessWidget {
  const ChatComponents({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.6.w),
                child: Text(
                  'Adham Hosny',
                  style: AppStyles.font14Black400Weight,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              AppDimensions.horizontalSpacing8,
              Text(
                '10.00 PM',
                style: AppStyles.font10Grey400Weight,
              )
            ],
          ),
          AppDimensions.verticalSpacing5,
          Text(
            'Hello Mohamed,How are you ?',
            style: AppStyles.font11Grey400Weight,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }
}
