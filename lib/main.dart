import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const PongApp());
}

class PongApp extends StatelessWidget {
  const PongApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Pong Game',
      theme: ThemeData.dark(),
      home: const PongGameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PongGameScreen extends StatefulWidget {
  const PongGameScreen({super.key});

  @override
  State<PongGameScreen> createState() => _PongGameScreenState();
}

class _PongGameScreenState extends State<PongGameScreen> {
  // Ball coordinates (-1.0 to 1.0 range)
  double ballX = 0;
  double ballY = 0;
  double ballXDirection = 0.02;
  double ballYDirection = 0.02;

  // Paddle coordinates and size
  double paddleX = -0.2;
  double paddleWidth = 0.4;

  bool gameHasStarted = false;
  int score = 0;

  // Game loop timer
  void startGame() {
    gameHasStarted = true;
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      // Update ball position
      setState(() {
        ballX += ballXDirection;
        ballY += ballYDirection;
      });

      // Wall collision: Left & Right
      if (ballX < -1.0) {
        ballXDirection = ballXDirection.abs();
      } else if (ballX > 1.0) {
        ballXDirection = -ballXDirection.abs();
      }

      // Wall collision: Top
      if (ballY < -1.0) {
        ballYDirection = ballYDirection.abs();
      }

      // Paddle collision check (bottom of screen)
      if (ballY >= 0.85 && ballY <= 0.9) {
        if (ballX >= paddleX && ballX <= paddleX + paddleWidth) {
          ballYDirection = -ballYDirection.abs();
          score++;
        }
      }

      // Game Over check (ball drops below paddle)
      if (ballY > 1.0) {
        timer.cancel();
        gameHasStarted = false;
        _showGameOverDialog();
      }
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('Your Score: $score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              resetGame();
            },
            child: const Text('Play Again', style: TextStyle(color: Colors.cyanAccent)),
          ),
        ],
      ),
    );
  }

  void resetGame() {
    setState(() {
      ballX = 0;
      ballY = 0;
      score = 0;
      gameHasStarted = false;
      paddleX = -0.2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        // Allow dragging the paddle left and right across the screen
        onHorizontalDragUpdate: (details) {
          setState(() {
            paddleX += details.delta.dx / 300;
            if (paddleX < -1.0) paddleX = -1.0;
            if (paddleX + paddleWidth > 1.0) paddleX = 1.0 - paddleWidth;
          });
        },
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 650),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              border: Border.all(color: Colors.cyanAccent, width: 3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                // Score Display in Background
                Center(
                  child: Text(
                    gameHasStarted ? '$score' : 'PONG',
                    style: TextStyle(
                      fontSize: 80,
                      color: Colors.white.withOpacity(0.08),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Game Ball
                Align(
                  alignment: Alignment(ballX, ballY),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.cyanAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Player Paddle
                Align(
                  alignment: Alignment(paddleX + paddleWidth / 2, 0.9),
                  child: Container(
                    width: 100,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.deepOrangeAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                // Tap to Start overlay
                if (!gameHasStarted)
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: startGame,
                        child: const Center(
                          child: Text(
                            'Tap or Click to Start',
                            style: TextStyle(
                              color: Colors.cyanAccent,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}