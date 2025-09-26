import 'package:flutter/material.dart';
import 'package:kaz_bd/custom_widgets/custom_card.dart';

import '../widgets/svp_documents_tab_form_field.dart';

class SvpDocumentationTab extends StatelessWidget {
  const SvpDocumentationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: SingleChildScrollView(
        child: Column(children: [SvpDocumentsTabFormField()]),
      ),
    );
  }
}
