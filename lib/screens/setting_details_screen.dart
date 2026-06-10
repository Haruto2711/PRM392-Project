import 'package:flutter/material.dart';
import '../utils/settings_manager.dart';

class SettingDetailsScreen extends StatefulWidget {
  final String settingType;

  const SettingDetailsScreen({Key? key, required this.settingType}) : super(key: key);

  @override
  _SettingDetailsScreenState createState() => _SettingDetailsScreenState();
}

class _SettingDetailsScreenState extends State<SettingDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final isLanguage = widget.settingType == 'Ngôn ngữ';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isLanguage ? SettingsManager.translate('select_language') : SettingsManager.translate('theme_config'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: isLanguage ? _buildLanguageSettings() : _buildThemeSettings(),
        ),
      ),
    );
  }

  Widget _buildLanguageSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          SettingsManager.translate('select_language_desc'),
          style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          color: Theme.of(context).cardColor,
          child: Column(
            children: [
              _buildLanguageRow('Tiếng Việt', 'vi'),
              const Divider(height: 1, indent: 20),
              _buildLanguageRow('English', 'en'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageRow(String languageName, String code) {
    final currentLanguage = SettingsManager.language.value;
    final isSelected = currentLanguage == code;

    return ListTile(
      title: Text(
        languageName,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? Colors.indigo : Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: Colors.indigo) : null,
      onTap: () {
        setState(() {
          SettingsManager.language.value = code;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${SettingsManager.translate('language_changed_to')} $languageName!'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
    );
  }

  Widget _buildThemeSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          SettingsManager.translate('dark_mode_setting_desc'),
          style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          color: Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SwitchListTile(
              title: Text(
                SettingsManager.translate('dark_mode_title'),
                style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
              subtitle: Text(SettingsManager.translate('dark_mode_desc')),
              value: SettingsManager.isDarkMode.value,
              activeThumbColor: Colors.indigo,
              onChanged: (value) {
                setState(() {
                  SettingsManager.isDarkMode.value = value;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(value ? SettingsManager.translate('dark_mode_on') : SettingsManager.translate('dark_mode_off')),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
