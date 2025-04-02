import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../theme/app_theme.dart';
import '../constants/image_routes.dart';

class ProjectAppBar extends StatelessWidget {
  final String appBarTitle;
  const ProjectAppBar({
    super.key,
    required this.appBarTitle,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return AppBar(
      elevation: 0,
      title: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Text(
          appBarTitle,
          style: theme.textTheme.headlineMedium!.copyWith(
              color: AppDynamicColorBuilder.getGrey900AndWhite(context)),
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(top: 24, left: 24),
        child: SvgPicture.asset(
          AppImagesRoute.appLogo,
          height: 32,
          width: 32,
        ),
      ),
    );
  }
}
