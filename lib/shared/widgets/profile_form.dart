import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/domain/domain.dart';

typedef ProfileSubmitCallback = Future<void> Function({
  String? name,
  String? company,
  required String occupation,
  required int trainingYear,
  String? wahlqualifikation,
});

typedef ExtendedProfileSubmitCallback = Future<void> Function({
  String? name,
  String? company,
  required String occupation,
  required int trainingYear,
  String? wahlqualifikation,
  required List<String> wahlqualifikationen,
  String? industryProfile,
});

class ProfileForm extends StatefulWidget {
  final String? initialName;
  final String? initialCompany;
  final String? initialOccupation;
  final int? initialTrainingYear;
  final String? initialWahlqualifikation;
  final List<String> initialWahlqualifikationen;
  final String? initialIndustryProfile;
  final ExtendedProfileSubmitCallback? onSubmitExtended;
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
    this.initialWahlqualifikation,
    this.initialWahlqualifikationen = const [],
    this.initialIndustryProfile,
    this.onSubmitExtended,
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
  String? _selectedWahlqualifikation;
  late Set<String> _selectedWahlqualifikationen;
  String? _selectedIndustryProfile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _companyController = TextEditingController(text: widget.initialCompany);
    _selectedOccupation = widget.initialOccupation;
    _selectedTrainingYear = widget.initialTrainingYear;
    _selectedWahlqualifikation = widget.initialWahlqualifikation;
    _selectedWahlqualifikationen = widget.initialWahlqualifikationen.toSet();
    _selectedIndustryProfile = widget.initialIndustryProfile;
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
      final name = _optionalText(_nameController.text);
      final company = _optionalText(_companyController.text);
      final extended = widget.onSubmitExtended;
      if (extended != null) {
        await extended(
          name: name,
          company: company,
          occupation: _selectedOccupation!,
          trainingYear: _selectedTrainingYear!,
          wahlqualifikation: _selectedWahlqualifikation,
          wahlqualifikationen: _selectedWahlqualifikationen.toList(),
          industryProfile: _selectedIndustryProfile,
        );
      } else {
        await widget.onSubmit(
          name: name,
          company: company,
          occupation: _selectedOccupation!,
          trainingYear: _selectedTrainingYear!,
          wahlqualifikation: _selectedWahlqualifikation,
        );
      }

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
    final isVerkaeufer =
        _selectedOccupation == TrainingOccupationValues.verkaeufer;
    final isKaufmann =
        _selectedOccupation == TrainingOccupationValues.kaufmannEinzelhandel;
    final hasValidKaufmannWahlqualifikationen =
        _selectedWahlqualifikationen.length == 3 &&
            _selectedWahlqualifikationen.any(_isCoreKaufmannWahlqualifikation);
    final canSubmit = _selectedOccupation != null &&
        TrainingYearValues.isValidForOccupation(
          _selectedTrainingYear,
          _selectedOccupation,
        ) &&
        (!isVerkaeufer ||
            WahlqualifikationDetails.fromStorageKey(
                  _selectedWahlqualifikation ?? '',
                ) !=
                null) &&
        (!isKaufmann || hasValidKaufmannWahlqualifikationen) &&
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
        const SizedBox(height: 12),
        _OccupationOption(
          title: 'Verkäufer/in',
          value: TrainingOccupationValues.verkaeufer,
          selectedValue: _selectedOccupation,
          onSelected: _selectOccupation,
        ),
        _OccupationOption(
          title: 'Kaufmann/-frau im Einzelhandel',
          value: TrainingOccupationValues.kaufmannEinzelhandel,
          selectedValue: _selectedOccupation,
          onSelected: _selectOccupation,
        ),
        if (isKaufmann) ...[
          const SizedBox(height: 20),
          Text(
            'Branche (optional)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Brancheninhalte werden nur zusätzlich vorgeschlagen und können später geändert werden.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          FilterChip(
            key: const ValueKey('industry_profile_moebel_einrichtung'),
            label: Text(IndustryProfile.moebelEinrichtung.label),
            selected: _selectedIndustryProfile ==
                IndustryProfile.moebelEinrichtung.storageKey,
            onSelected: (selected) => setState(
              () => _selectedIndustryProfile = selected
                  ? IndustryProfile.moebelEinrichtung.storageKey
                  : null,
            ),
          ),
        ],
        if (isVerkaeufer) ...[
          const SizedBox(height: 24),
          Text(
            'Welche Wahlqualifikation hast du?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Die Auswahl priorisiert passende Tätigkeiten, blendet andere aber nicht aus.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          ...Wahlqualifikation.values.map(
            (value) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RadioListTile<String>(
                key: ValueKey('wahlqualifikation_${value.storageKey}'),
                contentPadding: EdgeInsets.zero,
                title: Text(value.label),
                value: value.storageKey,
                groupValue: _selectedWahlqualifikation,
                onChanged: (selected) => setState(
                  () => _selectedWahlqualifikation = selected,
                ),
              ),
            ),
          ),
        ],
        if (isKaufmann) ...[
          const SizedBox(height: 24),
          Text(
            'Welche Wahlqualifikationen hast du?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Wähle genau drei aus deinem Ausbildungsvertrag. Mindestens eine der ersten drei muss dabei sein.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          ...EinzelhandelWahlqualifikation.values.map(
            (value) => CheckboxListTile(
              key: ValueKey('einzelhandel_wahlqualifikation_${value.storageKey}'),
              contentPadding: EdgeInsets.zero,
              title: Text(value.label),
              value: _selectedWahlqualifikationen.contains(value.storageKey),
              onChanged: _selectedWahlqualifikationen.contains(value.storageKey) ||
                      _selectedWahlqualifikationen.length < 3
                  ? (selected) => setState(() {
                      if (selected == true) {
                        _selectedWahlqualifikationen.add(value.storageKey);
                      } else {
                        _selectedWahlqualifikationen.remove(value.storageKey);
                      }
                    })
                  : null,
            ),
          ),
          Text(
            '${_selectedWahlqualifikationen.length} von 3 ausgewählt',
            style: theme.textTheme.bodySmall?.copyWith(
              color: hasValidKaufmannWahlqualifikationen
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
            ),
          ),
        ],
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
    setState(() {
      _selectedOccupation = occupation;
      if (occupation != TrainingOccupationValues.verkaeufer) {
        _selectedWahlqualifikation = null;
      }
      if (occupation != TrainingOccupationValues.kaufmannEinzelhandel) {
        _selectedWahlqualifikationen.clear();
        _selectedIndustryProfile = null;
      }
    });
  }

  bool _isCoreKaufmannWahlqualifikation(String key) {
    return key ==
            EinzelhandelWahlqualifikation.beratungKomplexeSituationen.storageKey ||
        key == EinzelhandelWahlqualifikation.beschaffungWaren.storageKey ||
        key == EinzelhandelWahlqualifikation.warenbestandssteuerung.storageKey;
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
