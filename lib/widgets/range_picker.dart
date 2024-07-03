import 'package:flutter/material.dart';
import 'package:ggh_fe_valdation/extension/partition.dart';
import 'package:intl/intl.dart';

class RangePicker extends StatefulWidget {
  const RangePicker({super.key, required this.now});

  final DateTime now;

  @override
  State<RangePicker> createState() => _RangePickerState();
}

class _RangePickerState extends State<RangePicker> {
  @override
  Widget build(BuildContext context) {
    final now = widget.now;

    final days = _getMonthDays(now);
    final weeks = days.partition(7).toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 10
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            YearMonthHeader(currentDate: now),
            const WeekHeader(),
            ...weeks.map((week) => Week(
              weekDays: week,
              onDaySelected: (day) {
                print(day);
              }
            ))
          ],
        ),
      ),
    );
  }

  List<DateTime> _getMonthDays(DateTime date) {
    final lastDay = DateTime(date.year, date.month + 1, 0);

    return List.generate(lastDay.day, (index) => DateTime(date.year, date.month, index + 1));
  }
}

class YearMonthHeader extends StatelessWidget {
  const YearMonthHeader({
    super.key,
    required this.currentDate
  });

  final currentDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Text(DateFormat.yMMMM().format(currentDate))
    );
  }
}

class WeekHeader extends StatelessWidget {
  const WeekHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: List.generate(7, (index) {
        final day = DateTime.now().subtract(Duration(days: 6 - index));
        return Container(
          alignment: Alignment.center,
          width: 50,
          height: 48,
          child: Text(DateFormat.E().format(day))
        );
      }),
    );
  }
}

class Week extends StatelessWidget {
  final List<DateTime> weekDays;
  final Function(DateTime) onDaySelected;

  const Week({
    super.key,
    required this.weekDays,
    required this.onDaySelected
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: List.generate(7, (index) {
        if (index < weekDays.length) {
          final day = weekDays[index];
          return Container(
              alignment: Alignment.center,
              width: 50,
              height: 48,
              child: Day(day: day, onDaySelected: onDaySelected)
          );
        } else {
          return const SizedBox(
            width: 50,
            height: 48,
          );
        }
      }),
    );
  }
}

class Day extends StatelessWidget {
  final DateTime day;
  final Function(DateTime) onDaySelected;

  const Day({
    super.key,
    required this.day,
    required this.onDaySelected
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(day.day.toString()),
    );
  }
}