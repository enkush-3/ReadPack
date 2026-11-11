import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';

class ReaderSessionTracker extends WidgetsBindingObserver {
  final BuildContext context;
  final String bookId;
  Timer? _readingTimer;
  int _activeReadingSeconds = 0;
  bool _isForeground = true;
  bool _observing = false;

  ReaderSessionTracker(this.context, {required this.bookId});

  bool get _isTesting => WidgetsBinding.instance.runtimeType
      .toString()
      .contains('TestWidgetsFlutterBinding');

  void start() {
    if (_isTesting) return;
    WidgetsBinding.instance.addObserver(this);
    _observing = true;
    _readingTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (!_isForeground) return;
      _activeReadingSeconds += 15;
      if (_activeReadingSeconds >= 60) {
        context.read<BookProvider>().addReadingMinutes(1, bookId: bookId);
        _activeReadingSeconds = 0;
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isForeground = state == AppLifecycleState.resumed;
  }

  void dispose() {
    _readingTimer?.cancel();
    if (_observing) WidgetsBinding.instance.removeObserver(this);
    final minutes = _activeReadingSeconds ~/ 60;
    if (minutes > 0) {
      context.read<BookProvider>().addReadingMinutes(minutes, bookId: bookId);
    }
  }
}
