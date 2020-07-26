
import 'package:flutter/material.dart';
import 'package:sliver_fill_remaining_box_adapter/sliver_fill_remaining_box_adapter.dart';

Widget silverProgressIndicator() {
  return SliverFillRemainingBoxAdapter(
    child: Padding(
      padding: EdgeInsets.all(8),
      child: Center(child: CircularProgressIndicator()),
    ),
  );
}
