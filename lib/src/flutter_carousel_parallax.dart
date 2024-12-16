import 'package:flutter/material.dart';

/// A comprehensive and customizable horizontal parallax carousel widget.
///
/// The [FlutterCarouselParallax] provides a flexible and visually appealing
/// carousel implementation with the following features:
/// - Generic type support for various list types
/// - Customizable image extraction
/// - Adjustable carousel height and item width
/// - Optional next item preview
/// - Optional page indicators
/// - Parallax scrolling effect
///
/// Example usage:
/// ```dart
/// HorizontalParallaxCarousel<Location>(
///   items: locations,
///   imageExtractor: (location) => location.imageUrl,
///   height: 260,
///   showIndicator: true,
///   showNextItem: false,
/// )
/// ```
class FlutterCarouselParallax<T> extends StatefulWidget {
  /// The list of items to be displayed in the carousel.
  ///
  /// This list can be of any type, and images will be extracted using [imageExtractor].
  final List<T> items;

  /// A function that extracts the image URL from each item in the list.
  ///
  /// This allows for flexible image extraction from different data models.
  /// Example: `(location) => location.imageUrl`
  final String Function(T item) imageExtractor;

  /// The height of the carousel container.
  ///
  /// Defaults to 260 pixels. Can be customized to fit different design requirements.
  final double height;

  /// The width of each carousel item.
  ///
  /// Defaults to 300 pixels. Adjust to control the size of individual items.
  final double itemWidth;

  /// Padding around each carousel item.
  ///
  /// Defaults to EdgeInsets.all(16.0), providing a standard spacing between items.
  final EdgeInsets padding;

  /// Border radius for carousel items.
  ///
  /// Defaults to 20, creating rounded corners for a modern look.
  final double borderRadius;

  /// Enables or disables shadow effect on carousel items.
  ///
  /// Defaults to true, adding depth to the carousel items.
  final bool shadowEnable;

  /// Shows a preview of the next item in the carousel.
  ///
  /// When true, displays a partial view of the next item.
  /// When false, focuses on a full-page carousel.
  final bool showNextItem;

  /// Shows page indicators at the bottom of the carousel.
  ///
  /// Defaults to true, displays dots representing the current page.
  final bool showIndicator;

  /// Constructs a [FlutterCarouselParallax] with the given parameters.
  ///
  /// [items] and [imageExtractor] are required. Other parameters have sensible defaults.
  const FlutterCarouselParallax({
    super.key,
    required this.items,
    required this.imageExtractor,
    this.height = 260,
    this.itemWidth = 300,
    this.padding = const EdgeInsets.all(16.0),
    this.borderRadius = 20,
    this.shadowEnable = true,
    this.showNextItem = false,
    this.showIndicator = true,
  });

  @override
  State<FlutterCarouselParallax<T>> createState() =>
      _FlutterCarouselParallaxState<T>();
}

/// The state management class for [FlutterCarouselParallax].
///
/// Handles the internal logic of page tracking and carousel rendering.
class _FlutterCarouselParallaxState<T>
    extends State<FlutterCarouselParallax<T>> {
  /// Tracks the current page/index in the carousel.
  late int _currentPage;

  @override
  void initState() {
    _currentPage = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          /// Chooses between ListView (show next item) or PageView (full page focus)
          widget.showNextItem
              ? ListView.builder(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => _buildCarouselItem(index),
            itemCount: widget.items.length,
          )
              : PageView.builder(
            scrollDirection: Axis.horizontal,
            onPageChanged: (int page) =>
                setState(() => _currentPage = page),
            itemBuilder: (context, index) => _buildCarouselItem(index),
            itemCount: widget.items.length,
          ),

          /// Optional page indicator
          Visibility(
            visible: widget.showIndicator,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 28.0),
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      widget.items.length,
                          (index) => AnimatedIndicator(
                        isSelected: index == _currentPage,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  /// Builds individual carousel items with parallax effect.
  ///
  /// Creates a [CarouselItem] for each index in the carousel.
  Widget _buildCarouselItem(int index) {
    return CarouselItem(
      padding: widget.padding,
      borderRadius: widget.borderRadius,
      shadowEnable: widget.shadowEnable,
      itemWidth: widget.itemWidth,
      imagePath: widget.imageExtractor(widget.items[index]),
      items: widget.items,
    );
  }
}

/// Represents a single item in the horizontal parallax carousel.
///
/// Provides a customizable container for each carousel item with
/// optional shadow and specific styling.
class CarouselItem extends StatelessWidget {
  /// Padding around the carousel item
  final EdgeInsets padding;

  /// Border radius of the carousel item
  final double borderRadius;

  /// Enables or disables shadow effect
  final bool shadowEnable;

  /// Width of the carousel item
  final double itemWidth;

  /// Path or URL of the image to display
  final String imagePath;

  /// List of all items in the carousel
  final List items;

  /// Constructs a [CarouselItem] with the given styling and image parameters
  const CarouselItem({
    super.key,
    required this.padding,
    required this.borderRadius,
    required this.shadowEnable,
    required this.itemWidth,
    required this.imagePath,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: Colors.white,
          boxShadow: shadowEnable
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
        ),
        width: itemWidth,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: ParallaxImage(imagePath: imagePath),
        ),
      ),
    );
  }
}

/// A widget that creates a parallax scrolling effect for images.
///
/// Provides a visually dynamic image display with horizontal parallax movement.
class ParallaxImage extends StatelessWidget {
  /// Path or URL of the image to be displayed
  final String imagePath;

  /// Constructs a [ParallaxImage] with the given image path
  const ParallaxImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final backgroundImageKey = GlobalKey();
    return Flow(
      delegate: HorizontalParallaxFlowDelegate(
        scrollable: Scrollable.of(context),
        listItemContext: context,
        backgroundImageKey: backgroundImageKey,
        widthFactor: 1.15,
      ),
      clipBehavior: Clip.antiAlias,
      children: [
        Image.network(
          imagePath,
          key: backgroundImageKey,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.error, color: Colors.red),
            );
          },
        ),
      ],
    );
  }
}

/// Custom Flow Delegate to create horizontal parallax scrolling effect.
///
/// Calculates and applies the parallax transformation for smooth image scrolling.
class HorizontalParallaxFlowDelegate extends FlowDelegate {
  /// The current scrollable state
  final ScrollableState scrollable;

  /// Build context of the list item
  final BuildContext listItemContext;

  /// Global key for the background image
  final GlobalKey backgroundImageKey;

  /// Factor to control the width of the parallax effect
  final double widthFactor;

  /// Constructs a [HorizontalParallaxFlowDelegate] with the required parameters
  HorizontalParallaxFlowDelegate({
    required this.scrollable,
    required this.listItemContext,
    required this.backgroundImageKey,
    this.widthFactor = 1.2,
  }) : super(repaint: scrollable.position);

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    return BoxConstraints.tightFor(
      height: constraints.maxHeight,
      width: constraints.maxWidth * widthFactor,
    );
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    final scrollableBox = scrollable.context.findRenderObject()! as RenderBox;
    final listItemBox = listItemContext.findRenderObject()! as RenderBox;
    final listItemOffset = listItemBox.localToGlobal(
      listItemBox.size.centerLeft(Offset.zero),
      ancestor: scrollableBox,
    );

    final viewportDimension = scrollable.position.viewportDimension;
    final scrollFraction =
    (listItemOffset.dx / viewportDimension).clamp(0.0, 1.0);

    final horizontalAlignment = Alignment(scrollFraction * 2 - 1, 0.0);

    final backgroundSize =
        (backgroundImageKey.currentContext!.findRenderObject()! as RenderBox)
            .size;
    final listItemSize = context.size;
    final childRect = horizontalAlignment.inscribe(
      backgroundSize,
      Offset.zero & listItemSize,
    );

    context.paintChild(
      0,
      transform:
      Transform.translate(offset: Offset(childRect.left, 0.0)).transform,
    );
  }

  @override
  bool shouldRepaint(HorizontalParallaxFlowDelegate oldDelegate) {
    return scrollable != oldDelegate.scrollable ||
        listItemContext != oldDelegate.listItemContext ||
        backgroundImageKey != oldDelegate.backgroundImageKey;
  }
}

/// An animated page indicator with smooth transition effects.
///
/// Provides a visually appealing dot indicator for carousel navigation.
class AnimatedIndicator extends StatelessWidget {
  /// Indicates whether this indicator is currently selected
  final bool isSelected;

  /// Constructs an [AnimatedIndicator] with selection state
  const AnimatedIndicator({super.key, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 8,
        width: isSelected ? 36 : 8.0,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey,
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
    );
  }
}