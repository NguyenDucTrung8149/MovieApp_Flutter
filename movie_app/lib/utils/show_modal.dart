import 'package:flutter/material.dart';
import 'package:movie_app/global/widgets/modal/app_modal_actions.dart';
import 'package:movie_app/global/widgets/modal/app_modal_title.dart';

import '../../theme/app_theme.dart';

showAppModal({
  required BuildContext context,
  required String modalTitle,
  required String primaryButtonTitle,
  required String secondaryButtonTitle,
  required Widget mainModalContent,
  required double initChildSize,
  required double minChildSize,
  required double maxChildSize,
}) =>
    showModalBottomSheet(
      isDismissible: true,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0xff09101D).withOpacity(0.7),
      builder: (context) => Padding(
        padding:
        EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: DraggableScrollableSheet(
          initialChildSize: initChildSize,
          minChildSize: minChildSize,
          maxChildSize: maxChildSize,
          builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: AppDynamicColorBuilder.getWhiteAndDark2(context),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            child: CustomScrollView(
              physics: const NeverScrollableScrollPhysics(),
              controller: scrollController,
              slivers: [
                 AppModalTitle(modalTitle: modalTitle),
                SliverToBoxAdapter(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      mainModalContent,
                       AppModalActions(
                        primaryButtonTitle: primaryButtonTitle,
                        secondaryButtonTitle: secondaryButtonTitle, onPrimaryButtonTap: () {  },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );