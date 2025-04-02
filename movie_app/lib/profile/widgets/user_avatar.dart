import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:movie_app/global/constants/image_routes.dart';

class UserAvatar extends StatelessWidget {
  final String? Avatar;
  UserAvatar({
    super.key,
    required this.Avatar,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: [
        CircleAvatar(
          backgroundColor: Colors.red,
          foregroundImage: Avatar != null && Avatar!.isNotEmpty
              ? NetworkImage(
                  'http://192.168.0.100:8080${Avatar}',
                )
              : AssetImage(AppImagesRoute.userProfileImage),
          radius: 60,
        ),
        Positioned(child: SvgPicture.asset(AppImagesRoute.iconEditProfile)),
      ],
    );
  }
}
