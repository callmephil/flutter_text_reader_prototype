import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Text Reader')),
        body: const TextReaderPrototype(
          text: 'This is a long paragraph used to test the text reader widget. '
              'The text will be highlighted word by word based on the selected '
              'reading speed. If the paragraph overflows its parent container, '
              'it will handle the scrolling behavior by gradually scrolling to '
              'the next line as more words are highlighted. This ensures that '
              'all the highlighted text remains visible to the user.',
        ),
      ),
    ),
  );
}

// ignore: prefer-match-file-name
class TextReaderPrototype extends StatefulWidget {
  const TextReaderPrototype({super.key, required this.text});
  final String text;

  @override
  State<TextReaderPrototype> createState() => _TextReaderPrototypeState();
}

class _TextReaderPrototypeState extends State<TextReaderPrototype> {
  int _currentWordIndex = 0;
  double _readingSpeed = 100; // Words per minute
  Timer? _timer;
  late List<String> _words;
  bool _isPlaying = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _words = widget.text.split(' ');
  }

  void _startReading() {
    _timer?.cancel();
    if (_isPlaying) {
      _timer = Timer.periodic(
        Duration(milliseconds: (60000 / _readingSpeed).round()),
        (timer) {
          setState(() {
            if (_currentWordIndex < _words.length) {
              _currentWordIndex++;
              _scrollToNextSentenceIfNeeded();
            } else {
              _isPlaying = false;
              timer.cancel();
            }
          });
        },
      );
    }
  }

  void _onWordTap(int index) {
    setState(() {
      _currentWordIndex = index;
      _isPlaying = true;
      _startReading();
      _scrollToNextSentenceIfNeeded();
    });
  }

  void _play() {
    setState(() {
      _isPlaying = true;
      _startReading();
    });
  }

  void _pause() {
    setState(() {
      _isPlaying = false;
      _timer?.cancel();
    });
  }

  void _restart() {
    _pause();
    setState(() {
      _currentWordIndex = 0;
      _scrollToNextSentenceIfNeeded();
    });
  }

  void _scrollToNextSentenceIfNeeded() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${_words.take(_currentWordIndex + 1).join(' ')} ',
          style: const TextStyle(
            backgroundColor: Colors.yellow,
            color: Colors.black,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: _scrollController.position.viewportDimension);

      // Calculate the height of two lines of text
      final twoLinesHeight = textPainter.preferredLineHeight;
      final scrollPosition = textPainter.size.height - 24;

      // Only scroll if the scrollPosition is greater than the height of two lines
      if (scrollPosition > twoLinesHeight) {
        final maxScrollExtent = _scrollController.position.maxScrollExtent;
        // Adjust scrollPosition if it overflows maxScrollExtent
        final adjustedScrollPosition =
            scrollPosition > maxScrollExtent ? maxScrollExtent : scrollPosition;
        _scrollController.animateTo(
          adjustedScrollPosition,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: HighlightedText(
              words: _words,
              currentWordIndex: _currentWordIndex,
              onWordTap: _onWordTap,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isPlaying)
              IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: _play,
              ),
            if (_isPlaying)
              IconButton(icon: const Icon(Icons.pause), onPressed: _pause),
            IconButton(
              icon: const Icon(Icons.restart_alt),
              onPressed: _restart,
            ),
          ],
        ),
        Slider(
          value: _readingSpeed,
          min: 50,
          max: 400,
          divisions: 16,
          label: '${_readingSpeed.round()} WPM',
          onChanged: (value) {
            setState(() {
              _readingSpeed = value;
              if (_isPlaying) {
                _startReading();
              }
            });
          },
        ),
        Text('Speed: ${_readingSpeed.round()} WPM'),
      ],
    );
  }
}

// ignore: prefer-single-widget-per-file
class HighlightedText extends StatelessWidget {
  const HighlightedText({
    super.key,
    required this.words,
    required this.currentWordIndex,
    required this.onWordTap,
  });
  final List<String> words;
  final int currentWordIndex;
  final void Function(int) onWordTap;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: words.mapIndexed((i, e) {
          final gestureRecognizer = TapGestureRecognizer()
            ..onTap = () => onWordTap(i);
          return TextSpan(
            text: '$e ',
            style: TextStyle(
              backgroundColor:
                  i < currentWordIndex ? Colors.yellow : Colors.transparent,
              color: Colors.black,
              fontSize: 24,
            ),
            recognizer: gestureRecognizer,
          );
        }).toList(growable: false),
      ),
    );
  }
}
