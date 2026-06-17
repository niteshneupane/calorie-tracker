part of '../../../../app.dart';

class SettingsListTile extends StatelessWidget {
  const SettingsListTile({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon),
          title: Text(label),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: onTap,
        ),
      ),
    );
  }
}
