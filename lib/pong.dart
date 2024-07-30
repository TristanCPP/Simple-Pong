import 'package:flutter/material.dart';
import 'ball.dart';
import 'bat.dart';
import 'dart:math';

enum Direction { up, down, left, right }

class Pong extends StatefulWidget {
  const Pong({super.key});

  @override
  State<Pong> createState() => _PongState();
}

class _PongState extends State<Pong> with SingleTickerProviderStateMixin {
  double width = 0;
  double height = 0;
  double posX = 0;
  double posY = 0;
  double batWidth = 0;
  double batHeight = 0;
  double batLeftPosition = 0;
  double batRightPosition = 0;
  late Animation<double> animation;
  late AnimationController controller;
  Direction vDir = Direction.down;
  Direction hDir = Direction.right;
  double increment = 5;
  double ballDiameter = 50;
  double randX = 1;
  double randY = 1;
  int score = 0;

  @override
  void initState() {
    posY = 0;
    controller = AnimationController(
      duration: const Duration(seconds: 10000),
      vsync: this,
    );

    // Delay the start of the controller by 100 milliseconds
    Future.delayed(Duration(milliseconds: 100), () {
      controller.forward();
    });

    super.initState();
    animation = Tween<double>(begin: 0, end: 60).animate(controller);
    animation.addListener(() {
      setState(() {
        (hDir == Direction.right)
            ? posX += (increment * randX).round()
            : posX -= (increment * randX).round();
        (vDir == Direction.down)
            ? posY += (increment * randY).round()
            : posY -= (increment * randY).round();
      });
      checkBorders();
    });
  }


  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          height = constraints.maxHeight;
          width = constraints.maxWidth;
          batWidth = width / 20;
          batHeight = height / 7;
          if (posX == 0) {
            posX = width / 8;  // Set the ball's initial position to 1/8th of the screen width
          }
          return Stack(children: <Widget>[
            Positioned(top: 0, right: 24, child: Text("Score: " + score.toString())),
            Positioned(child: Ball(), top: posY, left: posX),
            Positioned(
              top: batLeftPosition,
              left: 0,
              child: GestureDetector(
                onVerticalDragUpdate: (DragUpdateDetails update) => moveLeftBat(update),
                child: Bat(batWidth, batHeight),
              ),
            ),
            Positioned(
              top: batRightPosition,
              right: 0,
              child: GestureDetector(
                onVerticalDragUpdate: (DragUpdateDetails update) => moveRightBat(update),
                child: Bat(batWidth, batHeight),
              ),
            )
          ]);
        });
  }

  void checkBorders() {
    // Ball hits left or right
    if (posX <= 0 || posX >= width - ballDiameter) {
      controller.stop();
      showMessage(context);
      return;
    }

    // Ball hits top or bottom
    if (posY <= 0 && vDir == Direction.up) {
      vDir = Direction.down;
      randY = randomNumber();
    }
    if (posY >= height - ballDiameter && vDir == Direction.down) {
      vDir = Direction.up;
      randY = randomNumber();
    }

    // Ball hits left bat
    if (posX <= batWidth && posY + ballDiameter >= batLeftPosition && posY <= batLeftPosition + batHeight && hDir == Direction.left) {
      hDir = Direction.right;
      randX = randomNumber();
      score++;
    }


    // Ball hits right bat
    if (posX + ballDiameter >= width - batWidth && posY + ballDiameter >= batRightPosition && posY <= batRightPosition + batHeight && hDir == Direction.right) {
      hDir = Direction.left;
      randX = randomNumber();
      score++;
    }

  }

  void moveLeftBat(DragUpdateDetails update) {
    setState(() {
      batLeftPosition += update.delta.dy;
      if (batLeftPosition < 0) batLeftPosition = 0;
      if (batLeftPosition + batHeight > height) batLeftPosition = height - batHeight;
    });
  }

  void moveRightBat(DragUpdateDetails update) {
    setState(() {
      batRightPosition += update.delta.dy;
      if (batRightPosition < 0) batRightPosition = 0;
      if (batRightPosition + batHeight > height) batRightPosition = height - batHeight;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  double randomNumber() {
    var ran = new Random();
    int myNum = ran.nextInt(101);
    return (myNum + 50) / 100;
  }

  void showMessage(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Game Over"),
            content: Text('Would you like to play again?'),
            actions: [
              TextButton(
                child: Text('Yes'),
                onPressed: () {
                  setState(() {
                    posX = 50;
                    posY = 0;
                    score = 0;
                  });
                  Navigator.of(context).pop();
                  controller.repeat();
                },
              ),
              TextButton(
                child: Text('No'),
                onPressed: (){
                  Navigator.of(context).pop();
                  dispose();
                },
              ),
            ],
          );
        });
  }
}
