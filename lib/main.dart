import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Dollar Amount Entry'),
        ),
        body: const Center(
          child: DollarAmountInput(),
        ),
      ),
    );
  }
}

class DollarAmountInput extends StatefulWidget {
  const DollarAmountInput({super.key});

  @override
  _DollarAmountInputState createState() => _DollarAmountInputState();
}

class _DollarAmountInputState extends State<DollarAmountInput> {
  final TextEditingController _controller = CustomTextController();
  String formattedText = '0.00';

  @override
  void initState() {
    super.initState();
    _controller.text = '0.00';
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    String newText = _controller.text;
    // Optionally, you can perform additional formatting here if needed
    setState(() {
      formattedText = newText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        inputFormatters: [DollarAmountFormatter()],
        textAlign: TextAlign.start,
        enableInteractiveSelection: false,
        style: TextStyle(
          color: formattedText.startsWith('0.0') ? Colors.grey : Colors.black,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class DollarAmountFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return const TextEditingValue();
    }

    // Remove non-numeric characters
    String newText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Remove leading zeros
    newText = newText.replaceFirst(RegExp(r'^0+(?=\d)'), '');

    // Ensure there are at most two digits after the decimal point
    final String formattedText = newText.length == 1
        ? '0.0$newText'
        : newText.length == 2
            ? '0.$newText'
            : '${newText.substring(0, newText.length - 2)}.${newText.substring(newText.length - 2)}';

    // Separate integer and decimal parts
    final int cursorPosition = formattedText.length;

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

class CustomTextController extends TextEditingController {
  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    final String textValue = text ?? ''; // Ensure non-null value
    final List<TextSpan> spans = [];
    if (textValue == '0.00') {
      spans.add(const TextSpan(text: '0.00', style: TextStyle(color: Colors.grey,fontSize: 16.0)));
    }
    else if (textValue.startsWith('0.0')) {
      // Apply grey color to '0.0'
      spans.add(const TextSpan(text: '0.0', style: TextStyle(color: Colors.grey,fontSize: 16.0)));
      spans.add(TextSpan(
          text: textValue.substring(3), style: const TextStyle(color: Colors.black,fontSize: 16.0)));
    }
    else if (textValue.startsWith('0.')) {
      // Apply grey color to '0.0'
      spans.add(const TextSpan(text: '0.', style: TextStyle(color: Colors.grey,fontSize: 16.0)));
      spans.add(TextSpan(
          text: textValue.substring(2), style: const TextStyle(color: Colors.black,fontSize: 16.0)));
    }
     else {
      // If '0.0' is not found, apply black color to the entire text
      spans.add(TextSpan(text: textValue, style: style));
    }

    return TextSpan(style: DefaultTextStyle.of(context).style, children: spans);
  }
}
