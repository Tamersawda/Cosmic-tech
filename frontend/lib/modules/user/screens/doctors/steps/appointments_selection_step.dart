import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:intl/intl.dart';

class AppointmentsSelectionStep extends StatefulWidget {
  final String? selectedService;
  final DateTime? selectedDate;
  final String? selectedTime;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<String> onTimeChanged;

  // Available time slots — can later be fetched from the API per doctor
  static const List<String> defaultTimeSlots = [
    '3:00 PM - 4:30 PM',
    '4:30 PM - 6:00 PM',
    '6:00 PM - 7:30 PM',
    '7:30 PM - 9:00 PM',
    '9:00 PM - 10:30 PM',
    '10:30 PM - 12:00 AM',
  ];

  const AppointmentsSelectionStep({
    super.key,
    required this.selectedService,
    required this.selectedDate,
    required this.selectedTime,
    required this.onDateChanged,
    required this.onTimeChanged,
  });

  @override
  State<AppointmentsSelectionStep> createState() =>
      _AppointmentsSelectionStepState();
}

class _AppointmentsSelectionStepState extends State<AppointmentsSelectionStep> {
  late DateTime _focusedMonth;
  final DateTime _today = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Default focus to selected date or current month
    DateTime initial = widget.selectedDate ?? _today;
    _focusedMonth = DateTime(initial.year, initial.month, 1);
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  List<DateTime> _generateCalendarDays() {
    final firstDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    );

    // Get prefix days (Sunday = 7 modifier to keep Monday as start or Sunday as start)
    // Let's use Sunday as start of the week: weekday % 7
    final int prefixDays = firstDayOfMonth.weekday % 7;

    List<DateTime> days = [];
    for (int i = 0; i < prefixDays; i++) {
      days.add(firstDayOfMonth.subtract(Duration(days: prefixDays - i)));
    }
    for (int i = 1; i <= lastDayOfMonth.day; i++) {
      days.add(DateTime(_focusedMonth.year, _focusedMonth.month, i));
    }

    // Fill the remainder of the 5-row or 6-row grid
    int remaining = 35 - days.length;
    if (remaining < 0) remaining = 42 - days.length;
    for (int i = 1; i <= remaining; i++) {
      days.add(lastDayOfMonth.add(Duration(days: i)));
    }

    return days;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> displayDays = _generateCalendarDays();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main white container
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Calendar Month Navigation
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.chevron_left,
                        color: AppColors.darkText,
                      ),
                      onPressed: _previousMonth,
                    ),
                    Text(
                      DateFormat('MMMM yyyy').format(_focusedMonth),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.darkText,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.chevron_right,
                        color: AppColors.darkText,
                      ),
                      onPressed: _nextMonth,
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: AppColors.borderColor),
              const SizedBox(height: 16),

              // Calendar Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.2,
                ),
                itemCount: displayDays.length,
                itemBuilder: (context, index) {
                  final dateObj = displayDays[index];

                  final bool isSelected =
                      widget.selectedDate != null &&
                      _isSameDay(widget.selectedDate!, dateObj);
                  final bool isToday = _isSameDay(_today, dateObj);

                  // Disable past dates
                  final bool isPast = dateObj.isBefore(
                    DateTime(_today.year, _today.month, _today.day),
                  );
                  // In this implementation, any future day is bookable
                  final bool isBookable = !isPast;

                  // Determine if the day is in the currently focused month to dim overflow days
                  final bool isOutsideMonth =
                      dateObj.month != _focusedMonth.month;

                  return GestureDetector(
                    onTap: () {
                      if (isBookable) {
                        widget.onDateChanged(dateObj);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryColor
                            : (isBookable
                                  ? Colors.transparent
                                  : Colors.grey.shade50),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryColor
                              : (isBookable && !isOutsideMonth
                                    ? AppColors.primaryColor.withOpacity(0.4)
                                    : Colors.transparent),
                          width: isBookable && !isSelected && !isOutsideMonth
                              ? 1.5
                              : 1,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            '${dateObj.day}',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isBookable && !isOutsideMonth
                                        ? AppColors.darkText
                                        : AppColors.mutedText.withOpacity(0.5)),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          if (isToday && !isSelected)
                            const Positioned(
                              top: 2,
                              right: 2,
                              child: Icon(
                                Icons.circle,
                                size: 4,
                                color: AppColors.darkText,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Divider
              Container(height: 1, color: AppColors.borderColor),
              const SizedBox(height: 16),

              // Time Slots (If Date selected)
              if (widget.selectedDate != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${DateFormat('MMMM d, yyyy').format(widget.selectedDate!)} ${widget.selectedTime != null ? '- ${widget.selectedTime}' : ''}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // 2-column grid for time slots
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                                  2, // 2 columns exactly matching image
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 3.0, // adjusted for larger font
                            ),
                        itemCount:
                            AppointmentsSelectionStep.defaultTimeSlots.length,
                        itemBuilder: (context, index) {
                          final time =
                              AppointmentsSelectionStep.defaultTimeSlots[index];
                          final isSlotSelected = widget.selectedTime == time;

                          // Matches the alternating shades in the image
                          return GestureDetector(
                            onTap: () => widget.onTimeChanged(time),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSlotSelected
                                    ? AppColors.primaryColor
                                    : const Color(0xFFFFF9E6),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isSlotSelected
                                      ? AppColors.primaryColor
                                      : AppColors.primaryColor.withOpacity(0.4),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  time,
                                  style: TextStyle(
                                    color: isSlotSelected
                                        ? Colors.white
                                        : AppColors.darkText,
                                    fontWeight: isSlotSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
