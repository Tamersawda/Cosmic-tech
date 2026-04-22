class Patient {
  final String name;
  final String id;
  final String phone;
  final String email;
  final String lastAppointment;
  final int totalAppointments;

  Patient({
    required this.name,
    required this.id,
    required this.phone,
    required this.email,
    required this.lastAppointment,
    required this.totalAppointments,
  });
}
