# Flutter Word-by-Word Text Reader

This repository contains a Flutter widget that highlights text word by word, scrolls automatically to keep the highlighted word visible, and allows interaction such as tapping on a word to continue reading from that point.

## Demo

Watch the demo video to see the text reader in action:

[![Video](https://raw.githubusercontent.com/callmephil/flutter_text_reader_prototype/demo/text_reader_highlight_demo.jpg)](https://raw.githubusercontent.com/callmephil/flutter_text_reader_prototype/demo/text_reader_highlight_demo.mp4)

## Motivation

I was looking for a text reader in Flutter and couldn't find one, so I built it and decided to share it with the community. The goal was to create a user-friendly text reader that highlights words sequentially at a configurable speed, making it easier for users to follow along. This can be particularly useful for speed reading practice, aiding those with reading difficulties, or simply providing a better reading experience.

> This is a prototype please do not expect it to work perfectly

## Features

- **Word-by-word highlighting**: Each word is highlighted one at a time based on a user-defined speed.
- **Customizable reading speed**: Choose a reading speed in words per minute (WPM) with a simple slider.
- **Tap interaction**: Tap any word to jump directly to that position and continue reading from there.
- **Auto-scrolling**: If the text overflows, the widget smoothly scrolls to keep the highlighted word in view.
- **Pause and restart**: Easily pause or restart the reading process.

## Capabilities

**Play with the controls**:

- Tap **Play** to begin highlighting words.
- Adjust the **Slider** to change the reading speed (WPM).
- Tap **Pause** to temporarily stop reading.
- Tap **Restart** to reset the text highlighting.
- Tap **any word** to jump to that position and continue reading.

## Code Overview

- **`TextReaderPrototype`**: A `StatefulWidget` that manages reading logic (play, pause, restart, word index, etc.).
- **`HighlightedText`**: A `StatelessWidget` that displays the text and applies highlights to the currently read words.
- **`_scrollToNextSentenceIfNeeded()`**: A function to calculate overflow and scroll if the highlighted word goes beyond the visible area.

## Customizing

- **Text**: Change the sample text in the `TextReaderPrototype` constructor.
- **Speed Range**: Adjust the minimum and maximum values of the speed slider in the `Slider` widget.
- **Highlight Style**: Modify the `backgroundColor` or `TextStyle` in the `HighlightedText` widget.
- **Scrolling Behavior**: Tweak the logic in `_scrollToNextSentenceIfNeeded()` to fit your layout needs.

## Contributing

Contributions are welcome! If you have any improvements, suggestions, or bug fixes, feel free to open an issue or submit a pull request. Please follow the typical GitHub workflow:

1. Fork the repository.
2. Create a new branch for your feature/bugfix.
3. Commit your changes.
4. Open a pull request, explaining your changes.
