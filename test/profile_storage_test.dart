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

    test('Kaufmann akzeptiert drei Wahlqualifikationen und Branchenprofil',
        () async {
      await ProfileStorage.save(
        occupation: 'kaufmann_einzelhandel',
        trainingYear: 3,
        wahlqualifikationen: const [
          'beratungKomplexeSituationen',
          'onlinehandel',
          'marketingmassnahmen',
        ],
        industryProfile: 'moebel_einrichtung',
      );
      final profile = await ProfileStorage.load();
      expect(profile.wahlqualifikationen, const [
        'beratungKomplexeSituationen',
        'marketingmassnahmen',
        'onlinehandel',
      ]);
      expect(profile.industryProfile, 'moebel_einrichtung');
    });

    test('Kaufmann benötigt genau drei gültige Wahlqualifikationen', () async {
      expect(
        () => ProfileStorage.save(
          occupation: 'kaufmann_einzelhandel',
          trainingYear: 1,
          wahlqualifikationen: const ['onlinehandel'],
        ),
        throwsArgumentError,
      );
      expect(
        () => ProfileStorage.save(
          occupation: 'kaufmann_einzelhandel',
          trainingYear: 1,
          wahlqualifikationen: const [
            'onlinehandel',
            'marketingmassnahmen',
            'mitarbeiterfuehrungEntwicklung',
          ],
        ),
        throwsArgumentError,
      );
    });

    test('Möbelprofil wird für Verkäufer abgelehnt', () async {
      expect(
        () => ProfileStorage.save(
          occupation: 'verkaeufer',
          trainingYear: 1,
          wahlqualifikation: 'beratungVonKunden',
          industryProfile: 'moebel_einrichtung',
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
    }) {
      return (
        name: 'Anna',
        company: 'ACME',
        occupation: occupation,
        trainingYear: trainingYear,
        wahlqualifikation: null,
        wahlqualifikationen: const [],
        industryProfile: null,
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

    test('false bei fehlendem Jahr', () {
      expect(
        ProfileStorage.isOnboardingComplete(profile(trainingYear: null)),
        isFalse,
      );
    });
  });
}
