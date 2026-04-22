import 'package:flutter/material.dart';

class SidebarTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool collapsed;
  final bool selected;
  final VoidCallback onTap;

  const SidebarTile({
    super.key,
    required this.icon,
    required this.title,
    required this.collapsed,
    required this.selected,
    required this.onTap,
  });

  @override
  State<SidebarTile> createState() => _SidebarTileState();
}

class _SidebarTileState extends State<SidebarTile> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    final bool highlight = widget.selected || isHover;

    return MouseRegion(
      onEnter: (_) => setState(() => isHover = true),
      onExit: (_) => setState(() => isHover = false),

      child: GestureDetector(
        onTap: widget.onTap,

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),

          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12),

          child: Row(
            children: [
              /// ACTIVE INDICATOR
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: widget.selected ? 4 : 0,
                height: 30,
                color: Colors.blue,
              ),

              const SizedBox(width: 12),

              Icon(
                widget.icon,
                color: highlight ? Colors.white : Colors.white70,
              ),

              if (!widget.collapsed) ...[
                const SizedBox(width: 12),

                Text(
                  widget.title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: highlight ? Colors.white : Colors.white70,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
