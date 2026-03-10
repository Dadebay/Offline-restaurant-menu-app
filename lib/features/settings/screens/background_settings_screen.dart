import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restaurant_menu_app/core/localization/app_localizations.dart';
import 'package:restaurant_menu_app/features/settings/bloc/background_cubit.dart';
import 'package:restaurant_menu_app/features/settings/services/background_settings_service.dart';

class BackgroundSettingsScreen extends StatelessWidget {
  const BackgroundSettingsScreen({super.key});

  static const List<Color> _palette = [
    Color(0xFF121212),
    Color(0xFF1C1C1C),
    Color(0xFF0F2A3F),
    Color(0xFF243B2E),
    Color(0xFF3A2A1E),
    Color(0xFF2B213A),
    Color(0xFF4A1E1E),
    Color(0xFF1E3A5F),
  ];

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (image == null) return;

    if (!context.mounted) return;
    await context.read<BackgroundCubit>().setImage(image.path);
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(tr.translate('background_settings'))),
      body: BlocBuilder<BackgroundCubit, BackgroundSettings>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(tr.translate('background_preview'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: state.type == BackgroundType.color && state.colorValue != null ? Color(state.colorValue!) : Theme.of(context).colorScheme.surface,
                  image: state.type == BackgroundType.image && state.imagePath != null ? DecorationImage(image: FileImage(File(state.imagePath!)), fit: BoxFit.cover) : null,
                ),
                child: state.type == BackgroundType.none ? Center(child: Text(tr.translate('background_not_set'))) : const SizedBox.shrink(),
              ),
              const SizedBox(height: 20),
              Text(tr.translate('background_color'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _palette
                    .map(
                      (color) => InkWell(
                        onTap: () => context.read<BackgroundCubit>().setColor(color.value),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: state.type == BackgroundType.color && state.colorValue == color.value ? Colors.white : Colors.white24,
                              width: state.type == BackgroundType.color && state.colorValue == color.value ? 3 : 1,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _pickImage(context),
                icon: const Icon(Icons.image),
                label: Text(tr.translate('background_image')),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.read<BackgroundCubit>().clear(),
                icon: const Icon(Icons.delete_outline),
                label: Text(tr.translate('background_clear')),
              ),
            ],
          );
        },
      ),
    );
  }
}
