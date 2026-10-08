import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:berichtsheft_merker/core/profile_storage.dart';

void main() {
  group('ProfileStorage.load', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Leere Preferences geben nur Nullen/false zurück', () async {
      final profile = await ProfileStorage.load();
      expect(profile.name, isNull);
      expect(profile.company, isNull);
      expect(profile.occupation, isNull);
      expect(profile.trainingYear, isNull);
      expect(profile.onboardingCompleted, isFalse);
      expect(profile.vertiefungswahlqualifikationen, isEmpty);
    });

    test('altes Verkäuferprofil wird ohne Vertiefungsmigration geladen', () async {
      SharedPreferences.setMockInitialValues({
        'training_occupation': 'verkaeufer',
        'training_year': 2,
        'wahlqualifikation': 'beratungVonKunden',
        'onboarding_completed': true,
      });

      final profile = await ProfileStorage.load();

      expect(profile.occupation, 'verkaeufer');
      expect(profile.trainingYear, 2);
      expect(profile.wahlqualifikation, 'beratungVonKunden');
      expect(profile.vertiefungswahlqualifikationen, isEmpty);
      expect(ProfileStorage.isOnboardingComplete(profile), isTrue);
    });
  });

  group('ProfileStorage.save/load Roundtrip', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Vollständige Profildaten bleiben erhalten', () async {
      await ProfileStorage.save(
        name: 'Anna',
        company: 'ACME',
        occupation: 'fachlagerist',
        trainingYear: 1,
      );
      final profile = await ProfileStorage.load();
      expect(profile.name, 'Anna');
      expect(profile.company, 'ACME');
      expect(profile.occupation, 'fachlagerist');
      expect(profile.trainingYear, 1);
    });

    test('completeOnboarding=true setzt den Flag', () async {
      await ProfileStorage.save(
        occupation: 'fachlagerist',
        trainingYear: 1,
        completeOnboarding: true,
      );
      expect((await ProfileStorage.load()).onboardingCompleted, isTrue);
    });

    test('Ohne completeOnboarding wird vorhandener Flag nicht überschrieben',
        () async {
      SharedPreferences.setMockInitialValues({'onboarding_completed': true});
      await ProfileStorage.save(
        occupation: 'fachlagerist',
        trainingYear: 1,
      );
      expect((await ProfileStorage.load()).onboardingCompleted, isTrue);
    });

    test('Null-Optionale Felder entfernen den Schlüssel', () async {
      await ProfileStorage.save(
        name: 'Anna',
        company: 'ACME',
        occupation: 'fachlagerist',
        trainingYear: 1,
      );
      expect((await ProfileStorage.load()).name, 'Anna');

      await ProfileStorage.save(
        name: null,
        company: null,
        occupation: 'fachlagerist',
        trainingYear: 1,
      );
      final profile = await ProfileStorage.load();
      expect(profile.name, isNull);
      expect(profile.company, isNull);
    });
  });

  group('ProfileStorage.save Validierung', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Gültige Beruf/Jahr-Kombinationen werden akzeptiert', () async {
      // Fachlagerist: 1–2
      await ProfileStorage.save(occupation: 'fachlagerist', trainingYear: 1);
      await ProfileStorage.save(occupation: 'fachlagerist', trainingYear: 2);
      // Fachkraft für Lagerlogistik: 1–3
      await ProfileStorage.save(
          occupation: 'fachkraft_lagerlogistik', trainingYear: 1);
      await ProfileStorage.save(
          occupation: 'fachkraft_lagerlogistik', trainingYear: 2);
      await ProfileStorage.save(
          occupation: 'fachkraft_lagerlogistik', trainingYear: 3);
      // Kein Wurf bis hierher = Test bestanden.
      expect(
          (await ProfileStorage.load()).occupation, 'fachkraft_lagerlogistik');
    });

    test('Verkäufer akzeptiert nur Ausbildungsjahr 1 und 2', () async {
      await ProfileStorage.save(
        occupation: 'verkaeufer',
        trainingYear: 1,
        wahlqualifikation: 'beratungVonKunden',
      );
      await ProfileStorage.save(
        occupation: 'verkaeufer',
        trainingYear: 2,
        wahlqualifikation: 'kassensystemdatenKundenservice',
      );
      expect(
        () => ProfileStorage.save(
          occupation: 'verkaeufer',
          trainingYear: 3,
          wahlqualifikation: 'beratungVonKunden',
        ),
        throwsArgumentError,
      );
      expect(
        (await ProfileStorage.load()).wahlqualifikation,
        'kassensystemdatenKundenservice',
      );
    });

    test('Verkäufer benötigt genau eine gültige Wahlqualifikation', () async {
      expect(
        () => ProfileStorage.save(occupation: 'verkaeufer', trainingYear: 1),
        throwsArgumentError,
      );
      expect(
        () => ProfileStorage.save(
          occupation: 'verkaeufer',
          trainingYear: 1,
          wahlqualifikation: 'unbekannt',
        ),
        throwsArgumentError,
      );
    });

    test('Kaufmann akzeptiert Jahr 1–3 und speichert die Vertiefungen',
        () async {
      final vertiefungen = [
        'beratungVonKundenInKomplexenSituationen',
        'marketingmassnahmen',
        'onlinehandel',
      ];
      await ProfileStorage.save(
        occupation: 'kaufmann_einzelhandel',
        trainingYear: 3,
        wahlqualifikation: 'beratungVonKunden',
        vertiefungswahlqualifikationen: vertiefungen,
        completeOnboarding: true,
      );
      final profile = await ProfileStorage.load();
      expect(profile.trainingYear, 3);
      expect(profile.vertiefungswahlqualifikationen, vertiefungen);
      expect(ProfileStorage.isOnboardingComplete(profile), isTrue);
    });

    test('Kaufmann verlangt drei Vertiefungen mit einer aus den ersten drei',
        () async {
      expect(
        () => ProfileStorage.save(
          occupation: 'kaufmann_einzelhandel',
          trainingYear: 1,
          wahlqualifikation: 'beratungVonKunden',
          vertiefungswahlqualifikationen: const [
            'marketingmassnahmen',
            'onlinehandel',
            'mitarbeiterfuehrungUndEntwicklung',
          ],
        ),
        throwsArgumentError,
      );
      expect(
        () => ProfileStorage.save(
          occupation: 'kaufmann_einzelhandel',
          trainingYear: 1,
          wahlqualifikation: 'beratungVonKunden',
          vertiefungswahlqualifikationen: const [
            'beschaffungVonWaren',
            'beschaffungVonWaren',
            'onlinehandel',
          ],
        ),
        throwsArgumentError,
      );
    });

    test('Kaufmann benötigt eine gültige Grund-Wahlqualifikation', () async {
      expect(
        () => ProfileStorage.save(
          occupation: 'kaufmann_einzelhandel',
          trainingYear: 1,
          vertiefungswahlqualifikationen: const [
            'beratungVonKundenInKomplexenSituationen',
            'marketingmassnahmen',
            'onlinehandel',
          ],
        ),
        throwsArgumentError,
      );
    });

    test('Fachlagerist mit 3. Jahr wirft ArgumentError', () async {
      expect(
        () => ProfileStorage.save(occupation: 'fachlagerist', trainingYear: 3),
        throwsArgumentError,
      );
    });

    test('Ungültiges Jahr (0) wirft ArgumentError', () async {
      expect(
        () => ProfileStorage.save(
            occupation: 'fachkraft_lagerlogistik', trainingYear: 0),
        throwsArgumentError,
      );
    });
  });

  group('ProfileStorage.clearAll', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('clearAll entfernt alle Profildaten', () async {
      await ProfileStorage.save(
        name: 'Anna',
        company: 'ACME',
        occupation: 'fachlagerist',
        trainingYear: 1,
        completeOnboarding: true,
      );
      await ProfileStorage.clearAll();
      final profile = await ProfileStorage.load();
      expect(profile.name, isNull);
      expect(profile.company, isNull);
      expect(profile.occupation, isNull);
      expect(profile.trainingYear, isNull);
      expect(profile.onboardingCompleted, isFalse);
    });
  });

  group('ProfileStorage.isOnboardingComplete', () {
    StoredProfile profile({
      bool onboardingCompleted = true,
      String? occupation = 'fachlagerist',
      int? trainingYear = 1,
      String? wahlqualifikation,
      List<String> vertiefungswahlqualifikationen = const [],
    }) {
      return (
        name: 'Anna',
        company: 'ACME',
        occupation: occupation,
        trainingYear: trainingYear,
        wahlqualifikation: wahlqualifikation,
        vertiefungswahlqualifikationen: vertiefungswahlqualifikationen,
        onboardingCompleted: onboardingCompleted,
      );
    }

    test('true bei abgeschlossenem Onboarding mit gültigem Beruf und Jahr', () {
      expect(ProfileStorage.isOnboardingComplete(profile()), isTrue);
    });

    test('false, wenn Onboarding noch nicht abgeschlossen', () {
      expect(
        ProfileStorage.isOnboardingComplete(
            profile(onboardingCompleted: false)),
        isFalse,
      );
    });

    test('false bei ungültigem Beruf', () {
      expect(
        ProfileStorage.isOnboardingComplete(profile(occupation: 'koch')),
        isFalse,
      );
    });

    test('false bei Jahr, das nicht zum Beruf passt', () {
      // Fachlagerist erlaubt nur 1–2.
      expect(
        ProfileStorage.isOnboardingComplete(
          profile(occupation: 'fachlagerist', trainingYear: 3),
        ),
        isFalse,
      );
    });

    test('Kaufmann-Onboarding erfordert gültige Grund- und Vertiefungswahl',
        () {
      expect(
        ProfileStorage.isOnboardingComplete(
          profile(
            occupation: 'kaufmann_einzelhandel',
            trainingYear: 2,
            wahlqualifikation: 'beratungVonKunden',
            vertiefungswahlqualifikationen: const [
              'beratungVonKundenInKomplexenSituationen',
              'marketingmassnahmen',
              'onlinehandel',
            ],
          ),
        ),
        isTrue,
      );
      expect(
        ProfileStorage.isOnboardingComplete(
          profile(
            occupation: 'kaufmann_einzelhandel',
            trainingYear: 2,
            wahlqualifikation: 'beratungVonKunden',
          ),
        ),
        isFalse,
      );
    });

    test('false bei fehlendem Jahr', () {
      expect(
        ProfileStorage.isOnboardingComplete(profile(trainingYear: null)),
        isFalse,
      );
    });
  });
}
