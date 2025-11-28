
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class HtmlWrapper extends StatelessWidget {
  final String htmlContent;

  const HtmlWrapper({super.key, required this.htmlContent});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(padding: const EdgeInsets.all(8.0), child: Html(data: htmlContent)),
    );
  }
}
