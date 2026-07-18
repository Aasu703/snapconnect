import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:snapconnect/common/common.dart';

/// Pinterest-style staggered photo collage shown behind the welcome step,
/// fading into the screen background near the bottom so the logo and
/// sign-up/login actions read clearly on top of it.
///
/// Swapping or adding collage photos later only means editing
/// [AppImageAssets.welcomeCollageTiles] — this widget just lays out whatever
/// is registered there.
class WelcomeCollageBackground extends StatelessWidget {
  const WelcomeCollageBackground({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRect(
            child: MasonryGridView.count(
              padding: const EdgeInsets.all(AppDimens.space16),
              crossAxisCount: 3,
              mainAxisSpacing: AppDimens.space10,
              crossAxisSpacing: AppDimens.space10,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: AppImageAssets.welcomeCollageTiles.length,
              itemBuilder: (context, index) => ClipRRect(
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                child: Image.asset(
                  AppImageAssets.welcomeCollageTiles[index],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: height * 0.7,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.appColors.screenBackground.withValues(alpha: 0),
                    context.appColors.screenBackground,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
