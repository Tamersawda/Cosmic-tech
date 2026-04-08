import 'package:frontend/modules/admin/widgets/training/module_card.dart';
import 'package:flutter/material.dart';

class ModuleGrid extends StatelessWidget {
  final List modules;
  final Function(int index) onRemove;

  const ModuleGrid({super.key, required this.modules, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 2.8,
      ),

      itemCount: modules.length,

      itemBuilder: (context, index) {
        return ModuleCard(
          module: modules[index],
          onRemove: () => onRemove(index),
        );
      },
    );
  }
}
