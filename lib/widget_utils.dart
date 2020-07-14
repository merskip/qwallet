
import 'package:flutter/material.dart';
import 'package:sliver_fill_remaining_box_adapter/sliver_fill_remaining_box_adapter.dart';

Widget silverProgressIndicator() {
  return SliverPadding(
    padding: EdgeInsets.all(8),
    sliver: SliverFillRemainingBoxAdapter(
      child: Center(child: CircularProgressIndicator()),
    ),
  );
}
