import 'package:flutter/material.dart';

/// A FAB that can expand to a full-width button on hover (desktop/web) or when
/// in an "expanded" state.
///
/// The button will animate between a circular button and a wider button with a
/// label.
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.expandOnHover = true,
    this.expandOnTap = true,
    this.backgroundColor = const Color(0xFF1E5EFE),
    this.width = 200,
    this.height = 56,
  }) : super(key: key);

  final Widget icon;
  final String label;
  final VoidCallback onTap;
  final bool expandOnHover;
  final bool expandOnTap;
  final Color backgroundColor;
  final double width;
  final double height;

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  bool _hovering = false;
  bool _pressed = false;

  void _setHover(bool hover) {
    if (!widget.expandOnHover) return;
    if (_hovering == hover) return;
    setState(() => _hovering = hover);
  }

  void _onTap() {
    if (widget.expandOnTap) {
      setState(() => _pressed = true);
      Future.delayed(const Duration(milliseconds: 250), () {
        widget.onTap();
        setState(() => _pressed = false);
      });
    } else {
      widget.onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    final expanded = _hovering || _pressed;

    return MouseRegion(
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      child: GestureDetector(
        onTap: _onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: expanded ? widget.width : widget.height,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.height / 2),
            boxShadow: [
              BoxShadow(
                color: widget.backgroundColor.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: expanded ? 20 : 0),
          child: Row(
            mainAxisAlignment: expanded ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
            children: [
              widget.icon,
              if (expanded) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
