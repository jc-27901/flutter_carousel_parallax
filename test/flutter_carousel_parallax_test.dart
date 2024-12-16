import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_carousel_parallax/flutter_carousel_parallax.dart';

// Sample data model for testing
class TestLocation {
  final String imageUrl;
  final String name;

  TestLocation({required this.imageUrl, required this.name});
}

void main() {
  group('FlutterCarouselParallax Widget Tests', () {
    // Sample test data
    final testLocations = [
      TestLocation(
          imageUrl: 'https://example.com/image1.jpg',
          name: 'Location 1'
      ),
      TestLocation(
          imageUrl: 'https://example.com/image2.jpg',
          name: 'Location 2'
      ),
      TestLocation(
          imageUrl: 'https://example.com/image3.jpg',
          name: 'Location 3'
      ),
    ];

    testWidgets('Renders carousel with default parameters', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterCarouselParallax<TestLocation>(
              items: testLocations,
              imageExtractor: (location) => location.imageUrl,
            ),
          ),
        ),
      );

      // Verify the carousel is rendered
      expect(find.byType(FlutterCarouselParallax), findsOneWidget);

      // Check default height
      final containerFinder = find.byType(SizedBox);
      final containerWidget = tester.widget<SizedBox>(containerFinder);
      expect(containerWidget.height, 260);
    });

    testWidgets('Renders with custom parameters', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterCarouselParallax<TestLocation>(
              items: testLocations,
              imageExtractor: (location) => location.imageUrl,
              height: 300,
              itemWidth: 250,
              borderRadius: 10,
              showNextItem: true,
              showIndicator: false,
            ),
          ),
        ),
      );

      // Verify custom parameters
      final containerFinder = find.byType(SizedBox);
      final containerWidget = tester.widget<SizedBox>(containerFinder);
      expect(containerWidget.height, 300);

      // Verify indicator is not shown
      expect(find.byType(AnimatedIndicator), findsNothing);
    });

    testWidgets('Carousel items are created correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterCarouselParallax<TestLocation>(
              items: testLocations,
              imageExtractor: (location) => location.imageUrl,
            ),
          ),
        ),
      );

      // Verify correct number of carousel items
      final carouselItemFinder = find.byType(CarouselItem);
      expect(carouselItemFinder, findsNWidgets(testLocations.length));
    });

    testWidgets('Page indicators are created when showIndicator is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterCarouselParallax<TestLocation>(
              items: testLocations,
              imageExtractor: (location) => location.imageUrl,
              showIndicator: true,
            ),
          ),
        ),
      );

      // Verify indicators are created
      final indicatorFinder = find.byType(AnimatedIndicator);
      expect(indicatorFinder, findsNWidgets(testLocations.length));
    });

    testWidgets('ParallaxImage handles network image loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ParallaxImage(
              imagePath: 'https://example.com/test-image.jpg',
            ),
          ),
        ),
      );

      // Verify image loading widget is present
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('AnimatedIndicator changes appearance when selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                AnimatedIndicator(isSelected: true),
                AnimatedIndicator(isSelected: false),
              ],
            ),
          ),
        ),
      );

      // Find the animated containers
      final animatedContainersFinder = find.byType(AnimatedContainer);
      expect(animatedContainersFinder, findsNWidgets(2));

      // Verify the selected indicator has different properties
      final selectedContainer = tester.widget<AnimatedContainer>(
        find.descendant(
          of: animatedContainersFinder,
          matching: find.byWidgetPredicate(
                (widget) => widget is AnimatedContainer &&
                widget.decoration is BoxDecoration &&
                (widget.decoration as BoxDecoration).color == Colors.white,
          ),
        ),
      );

      expect(selectedContainer.decoration, isNotNull);
      expect(
          (selectedContainer.decoration as BoxDecoration).borderRadius,
          BorderRadius.circular(16.0)
      );
    });
  });
}