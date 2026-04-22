class SupportTicket {
  final String id;
  final String user;
  final String type;
  final String issue;
  final String date;
  String status;
  final String description;

  SupportTicket({
    required this.id,
    required this.user,
    required this.type,
    required this.issue,
    required this.date,
    required this.status,
    required this.description,
  });
}
