import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snapconnect/core/blocs/reactions_cubit.dart';
import 'package:snapconnect/core/blocs/session_cubit.dart';
import 'package:snapconnect/widgets/identity_bottom_sheet.dart';
import 'package:snapconnect/widgets/reaction_arc_picker.dart';
import 'package:snapconnect/widgets/reaction_bar.dart';

/// Drives a Snapchat/iMessage-style long-press reaction picker (see
/// [ReactionArcPicker]) for a screen showing many photos at once (a grid),
/// where the picker floats at the touch point rather than living in a
/// per-photo widget.
///
/// Mix into a [State] whose `build()` sits at the screen root — the arc
/// picker returned by [buildReactionOverlay] must be stacked above
/// everything else, and long-press coordinates are tracked in global screen
/// space so it lines up regardless of which grid tile the gesture started on.
mixin ReactionPickerController<T extends StatefulWidget> on State<T> {
  Offset? _reactionOrigin;
  int? _reactionHoverIndex;
  String? _reactionPhotoId;

  void onReactionLongPressStart(String photoId, LongPressStartDetails details) {
    HapticFeedback.mediumImpact();
    setState(() {
      _reactionPhotoId = photoId;
      _reactionOrigin = details.globalPosition;
      _reactionHoverIndex = null;
    });
  }

  void onReactionLongPressMove(LongPressMoveUpdateDetails details) {
    final origin = _reactionOrigin;
    if (origin == null) return;

    final index = ReactionArcPicker.hitTest(
      origin,
      details.globalPosition,
      ReactionBar.emojis.length,
      MediaQuery.sizeOf(context),
    );
    if (index != _reactionHoverIndex) {
      if (index != null) HapticFeedback.selectionClick();
      setState(() => _reactionHoverIndex = index);
    }
  }

  Future<void> onReactionLongPressEnd(LongPressEndDetails details) async {
    final photoId = _reactionPhotoId;
    final selectedIndex = _reactionHoverIndex;
    setState(() {
      _reactionOrigin = null;
      _reactionHoverIndex = null;
      _reactionPhotoId = null;
    });
    if (photoId == null || selectedIndex == null) return;

    final emoji = ReactionBar.emojis[selectedIndex];
    final sessionCubit = context.read<SessionCubit>();
    var user = sessionCubit.state;
    if (user == null) {
      await IdentityBottomSheet.show(
        context,
        title: 'Add your identity',
        subtitle: 'React as yourself so friends can see who responded.',
      );
      if (!mounted) return;
      user = sessionCubit.state;
    }
    if (user == null) return;

    final cubit = ReactionsCubit(photoId: photoId);
    await cubit.toggle(emoji, user);
    await cubit.close();
  }

  void onReactionLongPressCancel() {
    setState(() {
      _reactionOrigin = null;
      _reactionHoverIndex = null;
      _reactionPhotoId = null;
    });
  }

  /// Stack this above the rest of the screen's content.
  Widget buildReactionOverlay() {
    final origin = _reactionOrigin;
    if (origin == null) return const SizedBox.shrink();

    return ReactionArcPicker(
      origin: origin,
      emojis: ReactionBar.emojis,
      hoverIndex: _reactionHoverIndex,
      screenSize: MediaQuery.sizeOf(context),
    );
  }
}
