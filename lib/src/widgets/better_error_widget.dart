import 'dart:ui';

import 'package:flutter/material.dart';

class BetterErrorWidget extends StatelessWidget {
  final String errorMessage;
  final Function() onRefresh;

  const BetterErrorWidget({
    super.key,
    required this.errorMessage,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            errorMessage,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: onRefresh,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Refresh", style: TextStyle(color: Colors.black)),
                      SizedBox(width: 5),
                      Icon(Icons.refresh, color: Colors.black, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
