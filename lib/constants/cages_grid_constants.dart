class CagesGridConstants {
  // Existing search type constants
  static const String searchTypeAnimalTag = 'Animal Tag';
  static const String searchTypeCageTag = 'Cage Tag';

  // Zoom levels
  static const double defaultZoomLevel = 0.6;
  static const double compactViewZoomLevel = 0.39;
  static const double minScale = 0.1;
  static const double maxScale = 4.0;

  // Grid dimensions
  static const double cageWidth = 400; // Individual cage width
  static const double gridViewHeight = 8000.0;
  static const double gridTopPadding = 16.0;

  // Grid spacing
  static const double crossAxisSpacing = 16.0;
  static const double mainAxisSpacing = 16.0;

  // Calculate grid view width based on rack width
  static double getGridViewWidth(int rackWidth) {
    return (cageWidth * rackWidth) + (crossAxisSpacing * (rackWidth - 1));
  }

  static const double childAspectRatio = 0.8; // Taller cells to fit 5 animals
  static const double maxCageHeight = 800.0; // Maximum height for a cage
  static const double zoomFitPaddingMargin = 40.0;

  // FAB and floating bar margins
  static const double fabMenuMargin = 24.0;
  static const double floatingBarMargin = 16.0;

  // Timer durations (milliseconds)
  static const int rebuildTimerMs = 50;
  static const int saveMatrixTimerMs = 300;

  // Default rack dimensions
  static const int defaultRackWidth = 5;
  static const int defaultRackHeight = 1;

  // Loading overlay
  static const double loadingOverlayOpacity = 0.8;
}
