import 'dart:ui';

// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TopToolbar extends StatelessWidget {
  final Function()? onClose;
  // final Function()? onPictureInPicture;

  const TopToolbar({
    super.key,
    required this.onClose,
    // required this.onPictureInPicture,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (onClose != null) {
              onClose!();
            }
          },
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Container(
                width: 50,
                height: 50,
                padding: const EdgeInsets.all(10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.2),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
        const Spacer(),
        // GestureDetector(
        //   onTap: () {
        //     if (onPictureInPicture != null) {
        //       onPictureInPicture!();
        //     }
        //   },
        //   child: ClipOval(
        //     child: BackdropFilter(
        //       filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        //       child: Container(
        //         width: 50,
        //         height: 50,
        //         padding: const EdgeInsets.all(10),
        //         alignment: Alignment.center,
        //         decoration: BoxDecoration(
        //           shape: BoxShape.circle,
        //           color: Colors.black.withOpacity(0.2),
        //           border: Border.all(
        //             color: Colors.white.withOpacity(0.1),
        //             width: 1,
        //           ),
        //         ),
        //         child: const Icon(
        //           CupertinoIcons.rectangle_on_rectangle,
        //           color: Colors.white,
        //           size: 20,
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
