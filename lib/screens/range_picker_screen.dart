import 'package:flutter/material.dart';
import '../widgets/range_picker.dart';

class RangePickerScreen extends StatelessWidget {
  const RangePickerScreen({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onDaySelected,
  });

  final DateTime startDate;
  final DateTime endDate;
  final void Function(DateTime) onDaySelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Date Range'),
      ),
      body: YearRangePicker(
        startDate: startDate,
        endDate: endDate,
        onDaySelected: onDaySelected,
      ),
    );
  }
}

class YearRangePicker extends StatefulWidget {
  const YearRangePicker({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onDaySelected,
  });

  final DateTime startDate;
  final DateTime endDate;
  final void Function(DateTime) onDaySelected;

  @override
  State<StatefulWidget> createState() => _YearRangePickerState();
}

class _YearRangePickerState extends State<YearRangePicker> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return ListView.builder(
      itemCount: 12,
      itemBuilder: (BuildContext context, int index) {
        final targetDate = DateTime(now.year, now.month + index, now.day);

        return RangePicker(
          now: targetDate,
          startDate: widget.startDate,
          endDate: widget.endDate,
          onDaySelected: widget.onDaySelected,
        );
      },
    );
  }
}