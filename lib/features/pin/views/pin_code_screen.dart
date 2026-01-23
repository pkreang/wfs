import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wfs/features/pin/viewmodels/pin_viewmodel.dart';
import 'package:wfs/core/base_provider.dart';

class PinCodeScreen extends ConsumerStatefulWidget {
  final PinMode mode;
  final String? title;
  final String? subtitle;
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;

  const PinCodeScreen({super.key, this.mode = PinMode.create, this.title, this.subtitle, this.onSuccess, this.onCancel});

  @override
  ConsumerState<PinCodeScreen> createState() => _PinCodeScreenState();
}

class _PinCodeScreenState extends ConsumerState<PinCodeScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isUploading = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(WidgetRef ref, int index, String value) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _submitPin(ref);
      }
    }
  }

  void _onBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _submitPin(WidgetRef ref) async {
    final pin = _controllers.map((c) => c.text).join();
    if (pin.length == 6) {
      final viewModel = ref.read(pinViewModelProvider.notifier);

      setState(() => _isUploading = true);

      switch (widget.mode) {
        case PinMode.create:
          final success = await viewModel.createPin(ref, pin);
          setState(() => _isUploading = false);
          if (success) {
            widget.onSuccess?.call();
          } else {
            _showError('Failed to create PIN. Please try again.');
            _clearPin();
          }
          break;
        case PinMode.verify:
          final isValid = await viewModel.verifyPinAsync(ref, pin);
          setState(() => _isUploading = false);
          if (isValid) {
            widget.onSuccess?.call();
          } else {
            _showError('Invalid PIN. Please try again.');
            _clearPin();
          }
          break;
        case PinMode.change:
          final success = await viewModel.setPin(pin);
          setState(() => _isUploading = false);
          if (success) {
            widget.onSuccess?.call();
          } else {
            _showError('Failed to change PIN. Please try again.');
            _clearPin();
          }
          break;
      }
    }
  }

  void _clearPin() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red, duration: const Duration(seconds: 2)));
    }
  }

  String _getTitle() {
    if (widget.title != null) return widget.title!;
    switch (widget.mode) {
      case PinMode.create:
        return 'Create PIN';
      case PinMode.verify:
        return 'Enter PIN';
      case PinMode.change:
        return 'Change PIN';
    }
  }

  String _getSubtitle() {
    if (widget.subtitle != null) return widget.subtitle!;
    switch (widget.mode) {
      case PinMode.create:
        return 'Create a 6-digit PIN for security';
      case PinMode.verify:
        return 'Enter your 6-digit PIN';
      case PinMode.change:
        return 'Enter your new 6-digit PIN';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: widget.onCancel != null
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.black87),
                  onPressed: widget.onCancel,
                )
              : null,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Title
                Text(
                  _getTitle(),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 12),

                // Subtitle
                Text(
                  _getSubtitle(),
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // PIN Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 50,
                      height: 60,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        obscureText: true,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE27980), width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (value) => _onDigitChanged(ref, index, value),
                        onTap: () {
                          if (_controllers[index].text.isNotEmpty) {
                            _controllers[index].selection = TextSelection.fromPosition(TextPosition(offset: _controllers[index].text.length));
                          }
                        },
                        onSubmitted: (_) {
                          if (index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          }
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                // Clear button
                TextButton(
                  onPressed: _isUploading ? null : _clearPin,
                  child: Text('Clear', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                ),

                const Spacer(),

                // Loading indicator
                if (_isUploading)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(color: Color(0xFFE27980)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
