import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';

class OtpInput extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;
  final TextEditingController? controller;

  const OtpInput({
    super.key,
    this.length = 6,
    required this.onCompleted,
    this.controller,
  });

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onChanged);
  }

  void _onChanged() {
    setState(() {});
    if (_controller.text.length == widget.length) {
      widget.onCompleted(_controller.text);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Hidden text field for input
        SizedBox(
          height: 0,
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            maxLength: widget.length,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(counterText: ''),
            autofocus: true,
          ),
        ),
        // Visible OTP boxes
        GestureDetector(
          onTap: () {
            // Focus the hidden text field
            FocusScope.of(context).requestFocus(FocusNode());
            Future.delayed(const Duration(milliseconds: 100), () {
              FocusScope.of(context).requestFocus(FocusNode());
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.length, (index) {
              final hasValue = index < _controller.text.length;
              final isActive = index == _controller.text.length;
              return Container(
                width: 46,
                height: 52,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: hasValue ? Colors.white : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive
                        ? FairGoTheme.primaryCyan
                        : hasValue
                            ? FairGoTheme.primaryCyan
                            : const Color(0xFFE5E7EB),
                    width: isActive ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    hasValue ? _controller.text[index] : '',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: FairGoTheme.textPrimary,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
