 import 'package:flutter/widgets.dart';
import '/core/utils/device_dimension.dart';

extension SizeProperties on BuildContext {
  // Responsive font sizes
  double get fontSizeSmall => responsive(mobile: 12, tablet: 13, desktop: 14);
  double get fontSizeNormal => responsive(mobile: 14, tablet: 16, desktop: 18);
  double get fontSizeLarge => responsive(mobile: 16, tablet: 18, desktop: 20);
  double get fontSizeXL => responsive(mobile: 20, tablet: 22, desktop: 24);
  // double get sizedBoxsm => responsive(mobile: 8, tablet: 12, desktop: 16);
  double get sizedBoxsm => responsive(mobile: 8, tablet: 12, desktop: 16);
  double get sizedBoxNormal => responsive(mobile: 18, tablet: 24, desktop: 32);
  double get sizedBoxLarge => responsive(mobile: 24, tablet: 32, desktop: 40);

  // Button heights
  double get buttonHeight => responsive(mobile: 40, tablet: 45, desktop: 50);
  double get buttonMinWidth =>
      responsive(mobile: 120, tablet: 150, desktop: 180);

  // Padding & margins
  double get horizontalPadding =>
      responsive(mobile: 16, tablet: 20, desktop: 24);
  double get verticalPadding => responsive(mobile: 12, tablet: 16, desktop: 20);
  double get smallMargin => responsive(mobile: 8, tablet: 10, desktop: 12);
  double get mediumMargin => responsive(mobile: 12, tablet: 16, desktop: 20);
  double get largeMargin => responsive(mobile: 16, tablet: 20, desktop: 24);
  double get smallPadding => responsive(mobile: 8, tablet: 10, desktop: 12);
  double get mediumPadding => responsive(mobile: 12, tablet: 16, desktop: 20);
  double get largePadding => responsive(mobile: 16, tablet: 20, desktop: 24);

  // Widget sizes
  double get iconSize => responsive(mobile: 20, tablet: 24, desktop: 28);
  double get avatarSize => responsive(mobile: 40, tablet: 50, desktop: 60);
  double get chartHeight => responsive(mobile: 200, tablet: 300, desktop: 400);
  double get chartWidth => responsive(
    mobile: double.infinity,
    tablet: double.infinity,
    desktop: double.infinity,
  );

  // Example: specific for dropdowns, textfields, etc.
  double get textFieldHeight => responsive(mobile: 50, tablet: 55, desktop: 60);
  double get dropdownPadding => responsive(mobile: 8, tablet: 10, desktop: 12);

  // Responsive SizedBox dimensions
  double get sizedBoxWidth => responsive(mobile: 80, tablet: 100, desktop: 120);
  double get sizedBoxHeight =>
      responsive(mobile: 80, tablet: 100, desktop: 120);

  double get containerHightSm =>
      responsive(mobile: 12, tablet: 16, desktop: 24);
  double get containerwidthSm =>
      responsive(mobile: 14, tablet: 18, desktop: 26);
  double get containerHight24 =>
      responsive(mobile: 24, tablet: 30, desktop: 36);

  double get containerwidth24 =>
      responsive(mobile: 14, tablet: 18, desktop: 26);
  double get containerHightmd =>
      responsive(mobile: 32, tablet: 48, desktop: 64);
  double get containerwidthmd =>
      responsive(mobile: 32, tablet: 48, desktop: 64);
  double get containerHightlg =>
      responsive(mobile: 140, tablet: 180, desktop: 220);
  double get containerwidthlg =>
      responsive(mobile: 140, tablet: 180, desktop: 220);
}
