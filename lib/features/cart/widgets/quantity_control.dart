import 'package:flutter/material.dart';

class QuantityControl extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final Color? primaryColor;

  const QuantityControl({super.key, required this.quantity, required this.onIncrement, required this.onDecrement, this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIconButton(icon: Icons.remove, onTap: onDecrement),
          SizedBox(width: 32, child: Text('$quantity', textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Gilroy', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
          _buildIconButton(icon: Icons.add, color: primaryColor ?? Theme.of(context).primaryColor, onTap: onIncrement),
        ],
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onTap, Color? color}) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(8), child: Padding(padding: const EdgeInsets.all(8.0), child: Icon(icon, size: 16, color: color ?? Colors.white70)));
  }
}
