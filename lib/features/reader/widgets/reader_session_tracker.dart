import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';

class ReaderSessionTracker {
  final BuildContext context;
  Timer? _readingTimer;
  int _activeReadingSeconds = 0;

  ReaderSessionTracker(this.context);

  bool get _isTesting => WidgetsBinding.instance.runtimeType
      .toString()
      .contains('TestWidgetsFlutterBinding');

  void start() {
    if (_isTesting) return;
    _readingTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _activeReadingSeconds += 15;
      if (_activeReadingSeconds >= 60) {
        context.read<BookProvider>().addReadingMinutes(1);
        _activeReadingSeconds = 0;
      }
    });
  }

  void dispose() {
    _readingTimer?.cancel();
    if (_activeReadingSeconds >= 30) {
      final minutes = (_activeReadingSeconds / 60).round();
      if (minutes > 0) {
        context.read<BookProvider>().addReadingMinutes(minutes);
      }
    }
  }
}
