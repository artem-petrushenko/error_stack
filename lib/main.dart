import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

void main() {
  runZonedGuarded(
    () {
      FlutterError.onError = (details) => ErrorManager().addError(details.exception);
      runApp(const MyApp());
    },
    (error, stackTrace) {
      ErrorManager().addError(error);
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ErrorListener(
        child: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Локальная ошибка
            Future.delayed(Duration.zero, () {
              throw const SocketException("Ошибка сети");
            });
          },
          child: const Text("Создать ошибку"),
        ),
      ),
    );
  }
}

class ErrorListener extends StatefulWidget {
  final Widget child;

  const ErrorListener({super.key, required this.child});

  @override
  State<ErrorListener> createState() => _ErrorListenerState();
}

class _ErrorListenerState extends State<ErrorListener> {
  late final StreamSubscription<Object> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = ErrorManager().errorStream.listen((errorMessage) {
      _showError(errorMessage);
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ErrorDecoder.decodeError(error, context))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class ErrorManager {
  static final ErrorManager _instance = ErrorManager._internal();

  final _errorStreamController = StreamController<Object>.broadcast();

  factory ErrorManager() => _instance;

  ErrorManager._internal();

  Stream<Object> get errorStream => _errorStreamController.stream;

  void addError(Object error) {
    _errorStreamController.sink.add(error);
  }

  void dispose() {
    _errorStreamController.close();
  }
}

class ErrorDecoder {
  static String decodeError(Object error, BuildContext context) {
    return "Неизвестная ошибка";
  }
}
