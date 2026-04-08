class Appointment {
  final String name;
  final String initials;
  final String gender;
  final int age;
  final String date;
  final String time;
  final String type;
  final String fee;
  final String status;
  final String reason;
  final List<String> history;

  const Appointment({
    required this.name,
    required this.initials,
    required this.gender,
    required this.age,
    required this.date,
    required this.time,
    required this.type,
    required this.fee,
    required this.status,
    required this.reason,
    required this.history,
  });
}
