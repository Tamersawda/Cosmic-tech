import 'package:frontend/modules/admin/models/support_ticket.dart';
import 'package:frontend/core/utils/colors.dart';
import 'package:frontend/core/utils/responsive_data.dart';
import 'package:frontend/modules/admin/widgets/shared/admin_card_container.dart';
import 'package:frontend/modules/admin/widgets/shared/admin_page_header.dart';
import 'package:frontend/modules/admin/widgets/shared/admin_text_field.dart';
import 'package:flutter/material.dart';

class SupportAndComplaintsPage extends StatefulWidget {
  const SupportAndComplaintsPage({super.key});

  @override
  State<SupportAndComplaintsPage> createState() =>
      _SupportAndComplaintsPageState();
}

class _SupportAndComplaintsPageState extends State<SupportAndComplaintsPage> {
  SupportTicket? selectedTicket;

  final ScrollController _tableController = ScrollController();

  final TextEditingController responseController = TextEditingController();

  final List<SupportTicket> tickets = [
    SupportTicket(
      id: "TKT-001",
      user: "Anjali Rao",
      type: "Appointment Issue",
      issue: "Doctor did not show up for session.",
      date: "11 Mar",
      status: "Open",
      description: "Doctor missed scheduled consultation.",
    ),
    SupportTicket(
      id: "TKT-002",
      user: "Rohan Gupta",
      type: "Refund Request",
      issue: "Cancelled appointment but no refund received.",
      date: "10 Mar",
      status: "Pending",
      description: "Refund requested after cancellation.",
    ),
    SupportTicket(
      id: "TKT-003",
      user: "Meena Iyer",
      type: "Technical Issue",
      issue: "Cannot book appointment. Page keeps refreshing.",
      date: "09 Mar",
      status: "Resolved",
      description: "Page refresh bug while booking.",
    ),
  ];

  int get openCount => tickets.where((t) => t.status == "Open").length;
  int get pendingCount => tickets.where((t) => t.status == "Pending").length;
  int get resolvedCount => tickets.where((t) => t.status == "Resolved").length;

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context) && selectedTicket != null) {
      return ticketDetailsPanel();
    }

    return Padding(
      padding: const EdgeInsets.all(24),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const AdminPageHeader(
            title: "Support & Complaints",
            subtitle: "Manage support tickets, refunds, and user complaints",
          ),

          const SizedBox(height: 20),

          statsSection(),

          const SizedBox(height: 20),

          Expanded(
            child: Responsive.isDesktop(context)
                ? Row(
                    children: [
                      Expanded(flex: 3, child: ticketTable()),

                      const SizedBox(width: 20),

                      Expanded(
                        flex: 2,
                        child: selectedTicket == null
                            ? emptyPanel()
                            : ticketDetailsPanel(),
                      ),
                    ],
                  )
                : selectedTicket == null
                ? ticketTable()
                : ticketDetailsPanel(),
          ),
        ],
      ),
    );
  }

  /// STATS SECTION
  Widget statsSection() {
    return Row(
      children: [
        statCard(Icons.error_outline, "Open Tickets", openCount, Colors.red),

        const SizedBox(width: 16),

        statCard(Icons.sync, "Pending", pendingCount, Colors.orange),

        const SizedBox(width: 16),

        statCard(
          Icons.check_circle_outline,
          "Resolved",
          resolvedCount,
          Colors.green,
        ),
      ],
    );
  }

  Widget statCard(IconData icon, String title, int value, Color color) {
    return Expanded(
      child: AdminCardContainer(
        padding: const EdgeInsets.all(18),

        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),

              decoration: BoxDecoration(
                color: color.withOpacity(.12),
                shape: BoxShape.circle,
              ),

              child: Icon(icon, color: color),
            ),

            const SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  "$value",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(title, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// TABLE
  Widget ticketTable() {
    return AdminCardContainer(
      padding: EdgeInsets.zero,

      child: Scrollbar(
        controller: _tableController,
        thumbVisibility: true,

        child: SingleChildScrollView(
          controller: _tableController,
          scrollDirection: Axis.horizontal,

          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 900),

            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),

                  child: Row(
                    children: [
                      SizedBox(width: 120, child: Text("TICKET ID")),
                      SizedBox(width: 150, child: Text("USER")),
                      SizedBox(width: 180, child: Text("TYPE")),
                      SizedBox(width: 260, child: Text("ISSUE")),
                      SizedBox(width: 100, child: Text("DATE")),
                      SizedBox(width: 120, child: Text("STATUS")),
                    ],
                  ),
                ),

                const Divider(height: 1),

                ...tickets.map((ticket) {
                  final selected = selectedTicket == ticket;

                  return Column(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            selectedTicket = ticket;
                          });
                        },

                        child: Container(
                          color: selected
                              ? const Color(0xffe6f4f1)
                              : Colors.transparent,

                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),

                          child: Row(
                            children: [
                              SizedBox(
                                width: 120,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),

                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),

                                  child: Text(ticket.id),
                                ),
                              ),

                              SizedBox(
                                width: 150,
                                child: Text(
                                  ticket.user,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                              SizedBox(width: 180, child: Text(ticket.type)),

                              SizedBox(
                                width: 260,
                                child: Text(
                                  ticket.issue,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              SizedBox(width: 100, child: Text(ticket.date)),

                              SizedBox(
                                width: 120,
                                child: statusBadge(ticket.status),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Divider(height: 1),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// STATUS BADGE
  Widget statusBadge(String status) {
    Color textColor;
    Color bg;

    switch (status) {
      case "Open":
        textColor = const Color(0xffb45309);
        bg = const Color(0xfffef3c7);
        break;

      case "Pending":
        textColor = const Color(0xff0369a1);
        bg = const Color(0xffe0f2fe);
        break;

      case "Resolved":
        textColor = const Color(0xff15803d);
        bg = const Color(0xffdcfce7);
        break;

      default:
        textColor = Colors.grey;
        bg = Colors.grey.shade200;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        status,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      ),
    );
  }

  /// EMPTY PANEL
  Widget emptyPanel() {
    return AdminCardContainer(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 40,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 10),

            const Text(
              "Select a ticket",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),

            const SizedBox(height: 6),

            const Text(
              "Click a ticket to view details and respond",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// DETAILS PANEL
  Widget ticketDetailsPanel() {
    final ticket = selectedTicket;

    if (ticket == null) return const SizedBox();

    return AdminCardContainer(
      padding: const EdgeInsets.all(24),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Text(
                ticket.id,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Spacer(),
              IconButton(icon: Icon(Icons.close), onPressed: () {}),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            ticket.type,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          Text(ticket.user, style: const TextStyle(color: Colors.grey)),

          const SizedBox(height: 20),

          Text(ticket.description),

          const SizedBox(height: 20),

          const Text(
            "Admin Response",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          AdminTextField(
            controller: responseController,
            maxLines: 4,
            hintText: "Type your response...",
          ),

          const Spacer(),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),

                  onPressed: () {
                    ticket.status = "Pending";
                    setState(() {});
                  },

                  child: const Text("Reply"),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),

                  onPressed: () {
                    ticket.status = "Resolved";
                    setState(() {});
                  },

                  child: const Text("Resolve"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
