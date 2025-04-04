import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:movie_app/global/constants/app_static_data.dart';
import 'package:movie_app/global/constants/image_routes.dart';
import 'package:movie_app/home/widgets/UserInfoPage.dart';
import 'package:movie_app/theme/app_colors.dart';
import 'package:movie_app/theme/app_theme.dart';

import '../../../theme_notifier.dart';

class ProfileOptionItem extends StatelessWidget {
  final int index;
  final ThemeNotifier themeNotifier;
  const ProfileOptionItem({
    super.key,
    required this.index,
    required this.themeNotifier,
  });


  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return ListTile(
      title: Text(
        AppStaticData.profileOptionsData[index][0],
        style: theme.textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.w600,
          color: AppDynamicColorBuilder.getGrey900AndWhite(context),
        ),
      ),
      minLeadingWidth: 20,
      contentPadding: const EdgeInsets.all(0),
      visualDensity: VisualDensity(vertical: -2.w),
      trailing: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (index == 1)
            Switch(
              activeColor: AppColors.white,
              inactiveThumbColor: theme.primaryColor,
              activeTrackColor: theme.primaryColor,
              value: themeNotifier.isDark,
              onChanged: (value) {
                themeNotifier.isDark
                    ? themeNotifier.isDark = false
                    : themeNotifier.isDark = true;
              },
            ),
          if (index != 1) ...[
            SvgPicture.asset(
              AppImagesRoute.iconArrowRight,
              color: AppDynamicColorBuilder.getGrey900AndWhite(context),
            ),
          ],
        ],
      ),
      leading: SvgPicture.asset(
        AppStaticData.profileOptionsData[index][1],
        color: AppDynamicColorBuilder.getGrey900AndWhite(context),
      ),
      onTap: () {
        if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserInfoPage(),
            ),
          );
        }
      },
    );
  }
}
