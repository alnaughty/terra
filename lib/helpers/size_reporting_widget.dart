import 'package:flutter/material.dart';

class SizeReportingWidget extends StatefulWidget {
  final Widget child;
  final ValueChanged<Size?> onSizeChange;

  const SizeReportingWidget({
    Key? key,
    required this.child,
    required this.onSizeChange,
  }) : super(key: key);

  @override
  _SizeReportingWidgetState createState() => _SizeReportingWidgetState();
}

class _SizeReportingWidgetState extends State<SizeReportingWidget> {
  Size? _oldSize;
  // WidgetsBindingObserver _obs;
  @override
  void initState() {
    WidgetsBinding.instance.addTimingsCallback((_) => _notifySize());
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeTimingsCallback((_) => _notifySize());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _notifySize() {
    try {
      if (!mounted) {
        return;
      }
      final size = context.size;
      if (_oldSize != size) {
        setState(() {
          _oldSize = size;
        });
        widget.onSizeChange(size!);
      }
      return;
    } catch (e) {
      return;
    }
  }
}
