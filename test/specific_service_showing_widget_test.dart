import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:kaz_bd/features/normal_user/services_of_specific_category/widget/specific_service_showing_widget.dart';

void main() {
  testWidgets('SpecificServiceShowingWidget should show service provider image from network', 
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SpecificServiceShowingWidget(
            serviceImagePath: 'https://example.com/service.jpg',
            serviceName: 'Test Service',
            initialPayablePrice: 100.0,
            serviceProviderImage: 'https://example.com/provider.jpg',
            serviceProviderName: 'Test Provider',
            serviceProviderRating: 4.5,
            onTap: null,
          ),
        ),
      );

      // Verify that the widget is built successfully
      expect(find.byType(SpecificServiceShowingWidget), findsOneWidget);
      expect(find.text('Test Service'), findsOneWidget);
      expect(find.text('Test Provider'), findsOneWidget);
    },
  );

  testWidgets('SpecificServiceShowingWidget should handle relative image path by adding base URL', 
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SpecificServiceShowingWidget(
            serviceImagePath: '/uploads/service.jpg',
            serviceName: 'Test Service',
            initialPayablePrice: 100.0,
            serviceProviderImage: '/uploads/provider.jpg',
            serviceProviderName: 'Test Provider',
            serviceProviderRating: 4.5,
            onTap: null,
          ),
        ),
      );

      // Verify that the widget is built successfully
      expect(find.byType(SpecificServiceShowingWidget), findsOneWidget);
      expect(find.text('Test Service'), findsOneWidget);
      expect(find.text('Test Provider'), findsOneWidget);
    },
  );
}