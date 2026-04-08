import 'package:flutter/material.dart';

class MenuTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final bool collapsed;
  final VoidCallback onTap;

  const MenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.selected,
    required this.collapsed,
    required this.onTap,
  });

  @override
  State<MenuTile> createState() => MenuTileState();
}

class MenuTileState extends State<MenuTile> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    bool active = hover || widget.selected;

    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 44,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          padding: widget.collapsed
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 16),

          decoration: BoxDecoration(
            color: widget.selected
                ? Colors.white.withOpacity(0.15)
                : hover
                ? Colors.white.withOpacity(0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),

          child: widget.collapsed
              ? Center(
                  child: Icon(
                    widget.icon,
                    color: active ? Colors.white : Colors.white70,
                  ),
                )
              : Row(
                  children: [
                    Icon(
                      widget.icon,
                      color: active ? Colors.white : Colors.white70,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        widget.title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: active ? Colors.white : Colors.white70,
                          fontWeight: widget.selected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
