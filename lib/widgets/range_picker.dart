import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:ggh_fe_valdation/extension/partition.dart';
import 'package:intl/intl.dart';

class RangePicker extends StatelessWidget {
  const RangePicker({
    super.key,
    required this.now,
    required this.startDate,
    required this.endDate,
    required this.onDaySelected,
  });

  final DateTime now;
  final DateTime? startDate;
  final DateTime? endDate;
  final void Function(DateTime) onDaySelected;

  @override
  Widget build(BuildContext context) {
    final days = _getMonthDays(now);
    final weeks = getNumberOfWeeksInMonth(now);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            YearMonthHeader(currentDate: now),
            const WeekHeader(),
            ...weeks.map((week) => Week(
              weekDays: week,
              onDaySelected: onDaySelected,
              startDate: startDate,
              endDate: endDate,
            )),
          ],
        ),
      ),
    );
  }

  List<List<DateTime?>> getNumberOfWeeksInMonth(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);

    List<DateTime?> days = [];
    int daysInMonth = lastDayOfMonth.day;

    for (int i = 0; i < firstDayOfMonth.weekday - 1; i++) {
      days.add(null);
    }

    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(date.year, date.month, i));
    }

    while (days.length % 7 != 0) {
      days.add(null);
    }

    List<List<DateTime?>> weeks = [];
    for (int i = 0; i < days.length; i += 7) {
      weeks.add(days.sublist(i, i + 7));
    }

    return weeks;
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

  final DateTime currentDate;

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
    final weekdays = ['일', '월', '화', '수', '목', '금',' 토'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: weekdays.map((day) {
        final textColor = day == '일'
            ? Colors.red
            : day == "토"
              ? Colors.blue
              : Colors.black;

        return Expanded(
          flex: 1,
          child: Container(
            alignment: Alignment.center,
            height: 48,
            child: Text(
              day,
              style: TextStyle(
                color: textColor
              )
            )
          ),
        );
      }).toList()
    );
  }
}

class Week extends StatelessWidget {
  final List<DateTime?> weekDays;
  final Function(DateTime) onDaySelected;
  final DateTime? startDate;
  final DateTime? endDate;

  const Week({
    super.key,
    required this.weekDays,
    required this.onDaySelected,
    required this.startDate,
    required this.endDate
  });

  @override
  Widget build(BuildContext context) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: weekDays.map((day) {
        if (day == null) {
          return const Expanded(
              flex: 1,
              child: SizedBox(height: 48)
          );
        } else {
          return Day(
            day: day,
            onDaySelected: onDaySelected,
            startDate: startDate,
            endDate: endDate,
          );
        }
      }).toList(),
    );
  }
}

class Day extends StatelessWidget {
  final DateTime day;
  final Function(DateTime) onDaySelected;
  final DateTime? startDate;
  final DateTime? endDate;

  const Day({
    super.key,
    required this.day,
    required this.onDaySelected,
    required this.startDate,
    required this.endDate
  });

  @override
  Widget build(BuildContext context) {
    log('startDate: $startDate');
    log('endDate: $endDate');

    bool isSelected = startDate != null &&
        endDate != null &&
        day.isAfter(startDate!.subtract(const Duration(hours: 6))) &&
        day.isBefore(endDate!.add(const Duration(hours: 6)));

    bool isStartDay = startDate != null &&
        startDate!.year == day.year &&
        startDate!.month == day.month &&
        startDate!.day == day.day;
    bool isEndDay = endDate != null &&
        endDate!.year == day.year &&
        endDate!.month == day.month &&
        endDate!.day == day.day;

    log('isStartDay: $isStartDay');
    log('isEndDay: $isEndDay');

    final borderRadius = BorderRadius.only(
      topLeft: isStartDay ? const Radius.circular(30) : Radius.zero,
      bottomLeft: isStartDay ? const Radius.circular(30) : Radius.zero,
      topRight: isEndDay ? const Radius.circular(30) : Radius.zero,
      bottomRight: isEndDay ? const Radius.circular(30) : Radius.zero,
    );

    return Expanded(
      flex: 1,
      child: GestureDetector(
        onTap: () => onDaySelected(day),
        child: Container(
        height: 48,
          padding: const EdgeInsets.symmetric(vertical: 3.5),
          alignment: Alignment.center,
          child: Container(
            constraints: const BoxConstraints.expand(),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
            ),
            child: Text(
              day.day.toString(),
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.black
              )
            ),
          ),
        ),
      ),
    );
  }
}