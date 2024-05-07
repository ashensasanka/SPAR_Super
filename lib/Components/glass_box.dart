import 'dart:ui';

import 'package:flutter/material.dart';

class GlassBox extends StatelessWidget {
  final Widget child;
  final double height;
  final double width;

  const GlassBox({Key? key, required this.child, required this.height, required this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5), // Set border radius to 5
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
        ),
        width: width,
        height: height,
        // color: Colors.white,
        child: Stack(
          children: [
            //blur effect
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 5,
                sigmaY: 5,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),

            //gradient effect
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1),
                borderRadius: BorderRadius.circular(5),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.5),
                    Colors.white.withOpacity(0.25),
                  ],
                ),
              ),
            ),
            //child
            child,
          ],
        ),
      ),
    );
  }
}
