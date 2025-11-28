import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String hintText;
  final VoidCallback? onMenuPressed;

  const CustomAppBar({
    super.key,
    this.hintText = 'Search...',
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
    elevation: 0,
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: Image.asset(
                'assets/img_1.png',
                width: 30,
                height: 30,
                color: Colors.black,
              ),
              onPressed: onMenuPressed ?? () {},
            ),
          ),
          const SizedBox(width: 25),
          Expanded(
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: hintText,
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(vertical: 7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
