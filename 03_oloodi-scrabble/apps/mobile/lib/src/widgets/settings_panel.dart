// lib/src/widgets/settings_panel.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../themes/app_themes.dart';

class SettingsPanel extends StatelessWidget {
  final VoidCallback onClose;

  const SettingsPanel({
    super.key,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
      ),
      child: Container(
        width: 400,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLanguageModelSection(context),
                    const SizedBox(height: 32),
                    _buildVoiceSynthesisSection(context),
                    const SizedBox(height: 32),
                    _buildThemeSection(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Settings',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageModelSection(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Language Model'),
        const SizedBox(height: 16),
        _buildSettingCard(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Provider',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              ...LLMProvider.values.map((provider) => RadioListTile<LLMProvider>(
                value: provider,
                groupValue: settings.llmProvider,
                onChanged: (value) => settings.setLLMProvider(value!),
                title: Text(
                  settings.getLLMProviderName(provider),
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
                activeColor: theme.colorScheme.tertiary,
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceSynthesisSection(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Voice Synthesis'),
        const SizedBox(height: 16),
        _buildSettingCard(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Provider',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              ...VoiceSynthesisProvider.values.map((provider) => RadioListTile<VoiceSynthesisProvider>(
                value: provider,
                groupValue: settings.voiceProvider,
                onChanged: (value) => settings.setVoiceProvider(value!),
                title: Text(
                  settings.getVoiceProviderName(provider),
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
                activeColor: theme.colorScheme.tertiary,
              )),
              Divider(color: theme.dividerColor),
              const SizedBox(height: 8),
              Text(
                'Voice Selection',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: settings.selectedVoice,
                dropdownColor: theme.cardColor,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: theme.dividerColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: theme.dividerColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: settings.getAvailableVoices().map((voice) {
                  return DropdownMenuItem(
                    value: voice,
                    child: Text(
                      voice,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                  );
                }).toList(),
                onChanged: (value) => settings.setSelectedVoice(value!),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSection(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Theme'),
        const SizedBox(height: 16),
        _buildSettingCard(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Color Scheme',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: AppThemeMode.values.map((mode) {
                  final isSelected = settings.themeMode == mode;
                  final themeData = AppTheme.getThemeData(mode);
                  final color = themeData.primaryColor;
                  
                  return InkWell(
                    onTap: () => settings.setThemeMode(mode),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? theme.colorScheme.tertiary : color.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                            child: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: theme.colorScheme.tertiary,
                                  size: 20,
                                )
                              : null,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getThemeName(mode),
                            style: TextStyle(
                              color: isSelected 
                                ? theme.colorScheme.tertiary 
                                : theme.colorScheme.onSurface,
                              fontSize: 12,
                              fontWeight: isSelected 
                                ? FontWeight.bold 
                                : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingCard(BuildContext context, {required Widget child}) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor,
        ),
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: theme.colorScheme.onSurface.withOpacity(0.6),
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }

  String _getThemeName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.nature:
        return 'Nature';
    }
  }
}