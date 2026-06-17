import 'package:flutter/material.dart';
import '../../core/constants.dart';

typedef ProfileSubmitCallback = Future<void> Function({
  String? name,
  String? company,
  required String occupation,
  required int trainingYear,
});

class ProfileForm extends StatefulWidget {
  final String? initialName;
  final String? initialCompany;
  final String? initialOccupation;
  final int? initialTrainingYear;
  final String submitLabel;
  final IconData submitIcon;
  final String? successMessage;
  final ProfileSubmitCallback onSubmit;

  const ProfileForm({
    super.key,
    this.initialName,
    this.initialCompany,
    this.initialOccupation,
    this.initialTrainingYear,
    required this.submitLabel,
    required this.submitIcon,
    this.successMessage,
    required this.onSubmit,
  });

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _companyController;
  String? _selectedOccupation;
  int? _selectedTrainingYear;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _companyController = TextEditingController(text: widget.initialCompany);
    _selectedOccupation = widget.initialOccupation;
    _selectedTrainingYear = widget.initialTrainingYear;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedOccupation == null ||
        _selectedTrainingYear == null ||
        _isSaving) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      await widget.onSubmit(
        name: _optionalText(_nameController.text),
        company: _optionalText(_companyController.text),
        occupation: _selectedOccupation!,
        trainingYear: _selectedTrainingYear!,
      );

      if (mounted) {
        setState(() => _isSaving = false);
        if (widget.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.successMessage!)),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Deine Angaben konnten nicht gespeichert werden. Bitte versuche es erneut.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allowedTrainingYears =
        TrainingYearValues.forOccupation(_selectedOccupation);
    final hasInvalidTrainingYear = _selectedTrainingYear != null &&
        !allowedTrainingYears.contains(_selectedTrainingYear);
    final canSubmit = _selectedOccupation != null &&
        TrainingYearValues.isValidForOccupation(
          _selectedTrainingYear,
          _selectedOccupation,
        ) &&
        !_isSaving;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Persönliche Angaben',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Name und Betrieb sind optional.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          key: const ValueKey('profile_name_field'),
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          autofillHints: const [AutofillHints.name],
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Dein Name (optional)',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Welche Ausbildung machst du?',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        _OccupationOption(
          title: 'Fachlagerist/in',
          value: TrainingOccupationValues.fachlagerist,
          selectedValue: _selectedOccupation,
          onSelected: _selectOccupation,
        ),
        const SizedBox(height: 12),
        _OccupationOption(
          title: 'Fachkraft für Lagerlogistik',
          value: TrainingOccupationValues.fachkraftLagerlogistik,
          selectedValue: _selectedOccupation,
          onSelected: _selectOccupation,
        ),
        const SizedBox(height: 24),
        Text(
          'In welchem Ausbildungsjahr bist du?',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allowedTrainingYears.map((year) {
            return ChoiceChip(
              key: ValueKey('training_year_$year'),
              label: Text('$year. Jahr'),
              selected: _selectedTrainingYear == year,
              onSelected: (_) => _selectTrainingYear(year),
            );
          }).toList(),
        ),
        if (hasInvalidTrainingYear) ...[
          const SizedBox(height: 12),
          Text(
            'Das gespeicherte Ausbildungsjahr passt nicht zu diesem Beruf. '
            'Bitte wähle ein gültiges Jahr.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: 24),
        TextField(
          key: const ValueKey('profile_company_field'),
          controller: _companyController,
          textCapitalization: TextCapitalization.words,
          autofillHints: const [AutofillHints.organizationName],
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Dein Betrieb (optional)',
            prefixIcon: Icon(Icons.business_outlined),
          ),
        ),
        const SizedBox(height: 28),
        FilledButton.icon(
          key: const ValueKey('profile_submit_button'),
          onPressed: canSubmit ? _submit : null,
          icon: _isSaving
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(widget.submitIcon),
          label: Text(widget.submitLabel),
        ),
        const SizedBox(height: 16),
        Text(
          'Deine Angaben bleiben auf diesem Gerät.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _selectOccupation(String occupation) {
    setState(() => _selectedOccupation = occupation);
  }

  void _selectTrainingYear(int trainingYear) {
    setState(() => _selectedTrainingYear = trainingYear);
  }

  String? _optionalText(String value) {
    final trimmedValue = value.trim();
    return trimmedValue.isEmpty ? null : trimmedValue;
  }
}

class _OccupationOption extends StatelessWidget {
  final String title;
  final String value;
  final String? selectedValue;
  final ValueChanged<String> onSelected;

  const _OccupationOption({
    required this.title,
    required this.value,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = value == selectedValue;

    return Material(
      color: isSelected
          ? theme.colorScheme.secondaryContainer
          : theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        key: ValueKey(value),
        borderRadius: BorderRadius.circular(14),
        onTap: () => onSelected(value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
