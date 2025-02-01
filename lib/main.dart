import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Natural TTS Reader')),
        body: const TextReaderWithTTS(
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

class TextReaderWithTTS extends StatefulWidget {
  const TextReaderWithTTS({super.key, required this.text});
  final String text;

  @override
  State<TextReaderWithTTS> createState() => _TextReaderWithTTSState();
}

class _TextReaderWithTTSState extends State<TextReaderWithTTS> {
  int _currentWordIndex = 0;
  double _readingSpeed = 100; // Words per minute
  late List<WordInfo> _words;
  bool _isPlaying = false;
  bool _isProcessingWord = false;
  final ScrollController _scrollController = ScrollController();
  final FlutterTts flutterTts = FlutterTts();
  Timer? _punctuationTimer;

  @override
  void initState() {
    super.initState();
    _words = _processText(widget.text);
    _initTTS();
  }

  List<WordInfo> _processText(String text) {
    // Split text while preserving punctuation
    final wordInfos = <WordInfo>[];
    final wordPattern = RegExp(r"[\w']+|[.,!?;]");
    final matches = wordPattern.allMatches(text);

    for (final match in matches) {
      final word = match.group(0)!;
      final isPunctuation = RegExp('[.,!?;]').hasMatch(word);
      wordInfos.add(
        WordInfo(
          word: word,
          isPunctuation: isPunctuation,
          pauseDuration: _getPauseDuration(word),
        ),
      );
    }
    return wordInfos;
  }

  int _getPauseDuration(String word) {
    // Define pause durations for different punctuation marks (in milliseconds)
    switch (word) {
      case '.':
      case '!':
      case '?':
        return 1000; // Longer pause for sentence endings
      case ',':
      case ';':
        return 500; // Medium pause for mid-sentence breaks
      default:
        return 0; // No extra pause for regular words
    }
  }

  Future<void> _initTTS() async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1);
    await flutterTts.setPitch(1);

    flutterTts.setCompletionHandler(() {
      if (_isPlaying && !_isProcessingWord) {
        _processNextWord();
      }
    });
  }

  Future<void> _processNextWord() async {
    if (!_isPlaying || _isProcessingWord) return;

    setState(() {
      _isProcessingWord = true;
    });

    if (_currentWordIndex < _words.length) {
      final currentWord = _words[_currentWordIndex];

      if (!currentWord.isPunctuation) {
        await flutterTts.speak(currentWord.word);
      }

      // add pause based on punctuation
      if (currentWord.pauseDuration > 0) {
        _punctuationTimer?.cancel();
        _punctuationTimer = Timer(
          Duration(milliseconds: currentWord.pauseDuration),
          () {
            setState(() {
              _currentWordIndex++;
              _isProcessingWord = false;
            });
            _scrollToNextSentenceIfNeeded();
            if (_isPlaying) _processNextWord();
          },
        );
      } else {
        setState(() {
          _currentWordIndex++;
          _isProcessingWord = false;
        });
        _scrollToNextSentenceIfNeeded();
      }
    } else {
      setState(() {
        _isPlaying = false;
        _isProcessingWord = false;
      });
    }
  }

  Future<void> _play() async {
    setState(() {
      _isPlaying = true;
      _isProcessingWord = false;
    });
    _processNextWord();
  }

  Future<void> _pause() async {
    setState(() {
      _isPlaying = false;
    });
    _punctuationTimer?.cancel();
    await flutterTts.stop();
  }

  Future<void> _restart() async {
    await _pause();
    setState(() {
      _currentWordIndex = 0;
      _isProcessingWord = false;
    });
    _scrollToNextSentenceIfNeeded();
  }

  Future<void> _onWordTap(int index) async {
    await _pause();
    setState(() {
      _currentWordIndex = index;
      _isPlaying = true;
      _isProcessingWord = false;
    });
    _processNextWord();
    _scrollToNextSentenceIfNeeded();
  }

  void _scrollToNextSentenceIfNeeded() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: _words
              .take(_currentWordIndex + 1)
              .map((w) => '${w.word} ')
              .join(),
          style: const TextStyle(
            backgroundColor: Colors.yellow,
            color: Colors.black,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: _scrollController.position.viewportDimension);

      final twoLinesHeight = textPainter.preferredLineHeight * 2;
      final scrollPosition = textPainter.size.height - 24;

      if (scrollPosition > twoLinesHeight) {
        final maxScrollExtent = _scrollController.position.maxScrollExtent;
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

  Future<void> _updateSpeed(double value) async {
    setState(() {
      _readingSpeed = value;
    });

    // Map reading speed (50-400 WPM) to TTS rate (0.1-2.0)
    final ttsRate = (value - 50) / (400 - 50) * (2.0 - 0.1) + 0.1;
    await flutterTts.setSpeechRate(ttsRate);
  }

  @override
  void dispose() {
    _punctuationTimer?.cancel();
    flutterTts.stop();
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: HighlightedText(
                words: _words,
                currentWordIndex: _currentWordIndex,
                onWordTap: _onWordTap,
              ),
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
              IconButton(
                icon: const Icon(Icons.pause),
                onPressed: _pause,
              ),
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
          onChanged: _updateSpeed,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text('Speed: ${_readingSpeed.round()} WPM'),
        ),
      ],
    );
  }
}

class WordInfo {
  WordInfo({
    required this.word,
    required this.isPunctuation,
    required this.pauseDuration,
  });
  final String word;
  final bool isPunctuation;
  final int pauseDuration;
}

class HighlightedText extends StatelessWidget {
  const HighlightedText({
    super.key,
    required this.words,
    required this.currentWordIndex,
    required this.onWordTap,
  });

  final List<WordInfo> words;
  final int currentWordIndex;
  final void Function(int) onWordTap;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: words.mapIndexed((i, wordInfo) {
          final gestureRecognizer = TapGestureRecognizer()
            ..onTap = () => onWordTap(i);
          return TextSpan(
            text: '${wordInfo.word}${wordInfo.isPunctuation ? '' : ' '}',
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
