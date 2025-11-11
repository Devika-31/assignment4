import 'package:flutter/material.dart';

import 'dart:math';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:confetti/confetti.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const EmojiTapperApp());
}

class EmojiTapperApp extends StatelessWidget {
  const EmojiTapperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animated Emoji Tapper',
      debugShowCheckedModeBanner: false,
      home: const EmojiTapperScreen(),
    );
  }
}

class EmojiTapperScreen extends StatefulWidget {
  const EmojiTapperScreen({super.key});

  @override
  State<EmojiTapperScreen> createState() => _EmojiTapperScreenState();
}

class _EmojiTapperScreenState extends State<EmojiTapperScreen> {
  final List<String> emojis = [
    '👍','😄','🤩','😂','😎','😍','🤖','👽','😴','😇','😜','🥳','😆','🤠','😺','🐶',
  ];

  // Keeps track of total taps
  int totalTaps = 0;

  // Used to animate confetti when an emoji is tapped
  late ConfettiController _confettiController;

  // Which index was last tapped (used to animate briefly)
  int? lastTappedIndex;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(milliseconds: 700));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void onEmojiTap(int index) {
    setState(() {
      totalTaps++;
      lastTappedIndex = index;
    });

    _confettiController.play();

    // clear lastTappedIndex after a short delay so animation returns to normal
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          lastTappedIndex = null;
        });
      }
    });
  }

  // Pick a lively background color based on totalTaps
  Color dynamicBackground() {
    final Random r = Random(totalTaps + 123);
    return Color.fromRGBO(150 + r.nextInt(106), 150 + r.nextInt(106),
        150 + r.nextInt(106), 1); // pastel-ish brighter colors
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: dynamicBackground(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Animated Emoji Tapper',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 6,
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            children: [
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14.0, horizontal: 18.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total taps',
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        Row(
                          children: [
                            Icon(Icons.touch_app, color: Colors.deepPurple),
                            const SizedBox(width: 8),
                            Text(
                              '$totalTaps',
                              style: GoogleFonts.poppins(
                                  fontSize: 20, fontWeight: FontWeight.w700),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Instruction text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Text(
                  'Tap an emoji to celebrate! Each tap triggers confetti and a little bounce.',
                  style: GoogleFonts.poppins(fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 18),

              // Animated staggered grid of emojis
              Expanded(
                child: AnimationLimiter(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemCount: emojis.length,
                    itemBuilder: (context, index) {
                      // Determine if this is the last tapped one
                      final isTapped = lastTappedIndex == index;

                      // Size adjustments for tapped effect
                      final double baseSize = 36;
                      final double tappedScale = isTapped ? 1.6 : 1.0;

                      return AnimationConfiguration.staggeredGrid(
                        position: index,
                        duration: const Duration(milliseconds: 500),
                        columnCount: 4,
                        child: ScaleAnimation(
                          curve: Curves.easeOutBack,
                          child: FadeInAnimation(
                            child: GestureDetector(
                              onTap: () => onEmojiTap(index),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: Center(
                                  child: AnimatedScale(
                                    scale: tappedScale,
                                    duration:
                                    const Duration(milliseconds: 220),
                                    curve: Curves.easeOutBack,
                                    child: Text(
                                      emojis[index],
                                      style: TextStyle(
                                        fontSize: baseSize,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 18),
              // Fun footer
              Padding(
                padding: const EdgeInsets.only(bottom: 18.0),
                child: Text(
                  'Made with confetti 🎉 and Flutter ✨',
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
              ),
            ],
          ),

          // Confetti widget positioned at the top center
          Positioned(
            top: size.height * 0.08,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              emissionFrequency: 0.02,
              numberOfParticles: 25,
              maxBlastForce: 25,
              minBlastForce: 7,
              gravity: 0.25,
              // choose varied colors
              colors: const [
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.orange,
                Colors.purple
              ],
            ),
          ),
        ],
      ),
    );
  }
}

