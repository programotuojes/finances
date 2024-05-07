import 'package:flutter/material.dart';

const scaffoldPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 24);

/// Use this with a [SizedBox] to prevent the FAB
/// from overlapping other widgets.
///
/// 56 is the base height, 16 is the padding on
/// one side. Values are taken from Material 3 guidelines.
const double fabHeight = 56 + 16 * 2;
