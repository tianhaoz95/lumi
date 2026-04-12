import 'dart:async';

import 'package:flutter/material.dart';
import '../../core/lumi_animations.dart';

class LoadingScreen extends StatefulWidget {
  final Stream<double> progressStream;
  final Duration transitionDelay;
  final VoidCallback? onComplete;

  const LoadingScreen({
    Key? key,
    required this.progressStream,
    this.transitionDelay = LumiAnimations.driftDuration,
    this.onComplete,
  }) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  double progress = 0.0;
  StreamSubscription<double>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = widget.progressStream.listen((p) {
      final clamped = p.clamp(0.0, 1.0);
      setState(() => progress = clamped);
      if (clamped >= 1.0) {
        Future.delayed(widget.transitionDelay, () {
          widget.onComplete?.call();
          // If the caller provided an onComplete handler, let it manage navigation.
          if (widget.onComplete == null && mounted) {
            try {
              Navigator.of(context).pushReplacementNamed('/login');
            } catch (_) {
              // Fallback for tests and apps that didn't register a named route.
              Navigator.of(context).pushReplacement(PageRouteBuilder(
                pageBuilder: (_, __, ___) => const Scaffold(body: Center(child: Text('Login'))),
                transitionDuration: LumiAnimations.noTransition,
                reverseTransitionDuration: LumiAnimations.noTransition,
              ));
            }
          }
        });
      }
    }, onError: (_) {});
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.ac_unit,
                size: 96,
                color: Theme.of(context).primaryColor.withOpacity(0.7), // ignore: deprecated_member_use
              ),
              const SizedBox(height: 20),
              Text(
                'Lumi is preparing your sanctuary…',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 300,
                child: LinearProgressIndicator(value: progress),
              ),
              const SizedBox(height: 8),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
