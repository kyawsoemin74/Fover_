import 'package:flutter/material.dart';
import 'package:fover/features/team/models/team_model.dart';

class TeamFactsTab extends StatelessWidget {
  const TeamFactsTab({super.key, required this.team});

  final TeamModel team;

  String _displayText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '-';
    }
    return value;
  }

  String _displayFounded(int? founded) {
    return founded?.toString() ?? '-';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1220),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(label: 'Country', value: _displayText(team.country)),
          const SizedBox(height: 12),
          _InfoRow(label: 'Founded', value: _displayFounded(team.founded)),
          const SizedBox(height: 12),
          _InfoRow(label: 'Stadium', value: _displayText(team.stadium)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 78,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
