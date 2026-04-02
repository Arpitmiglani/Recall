import 'package:flutter/material.dart';

class RecallLogo extends StatefulWidget {
  const RecallLogo({super.key});

  @override
  State<RecallLogo> createState() => _RecallLogoState();
}

class _RecallLogoState extends State<RecallLogo>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 60, end: 90).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: _animation.value,
          width: _animation.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Colors.blue,
                Colors.purple,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.6),
                blurRadius: 25,
                spreadRadius: 5,
              )
            ],
          ),
          child: Icon(
            Icons.graphic_eq,
            color: Colors.white,
            size: 40,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}