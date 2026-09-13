import 'package:flutter/material.dart';
import 'activity_category.dart';

/// Ausbildungsbereiche. Bestehende Werte und ihre Reihenfolge sind persistent.
enum TrainingArea {
  wareneingang,
  lager,
  transport,
  kommissionierung,
  verpackung,
  versand,
  inventur,
  retouren,
  verkaufsflaeche,
  kundenberatung,
  kasse,
  warenpraesentation,
  wareneingangVerkauf,
  lagerBestand,
  reklamationService,
  werbungVerkaufsfoerderung,
}

extension TrainingAreaDetails on TrainingArea {
  String get label => switch (this) {
        TrainingArea.wareneingang => 'Wareneingang',
        TrainingArea.lager => 'Lager',
        TrainingArea.transport => 'Transport',
        TrainingArea.kommissionierung => 'Kommissionierung',
        TrainingArea.verpackung => 'Verpackung',
        TrainingArea.versand => 'Versand',
        TrainingArea.inventur => 'Inventur',
        TrainingArea.retouren => 'Retoure',
        TrainingArea.verkaufsflaeche => 'Verkaufsfläche',
        TrainingArea.kundenberatung => 'Kundenberatung',
        TrainingArea.kasse => 'Kasse',
        TrainingArea.warenpraesentation => 'Warenpräsentation',
        TrainingArea.wareneingangVerkauf => 'Warenannahme',
        TrainingArea.lagerBestand => 'Lager / Bestand',
        TrainingArea.reklamationService => 'Reklamation / Service',
        TrainingArea.werbungVerkaufsfoerderung => 'Werbung / Verkaufsförderung',
      };

  ActivityCategory get activityCategory => switch (this) {
        TrainingArea.wareneingang => ActivityCategory.wareneingang,
        TrainingArea.lager => ActivityCategory.einlagerung,
        TrainingArea.transport => ActivityCategory.transport,
        TrainingArea.kommissionierung => ActivityCategory.kommissionierung,
        TrainingArea.verpackung => ActivityCategory.verpackung,
        TrainingArea.versand => ActivityCategory.versand,
        TrainingArea.inventur => ActivityCategory.inventur,
        TrainingArea.retouren => ActivityCategory.retouren,
        TrainingArea.verkaufsflaeche => ActivityCategory.verkaufsflaeche,
        TrainingArea.kundenberatung => ActivityCategory.kundenberatung,
        TrainingArea.kasse => ActivityCategory.kasse,
        TrainingArea.warenpraesentation => ActivityCategory.warenpraesentation,
        TrainingArea.wareneingangVerkauf => ActivityCategory.wareneingangVerkauf,
        TrainingArea.lagerBestand => ActivityCategory.lagerBestand,
        TrainingArea.reklamationService => ActivityCategory.reklamationService,
        TrainingArea.werbungVerkaufsfoerderung =>
          ActivityCategory.werbungVerkaufsfoerderung,
      };

  IconData get icon => switch (this) {
        TrainingArea.wareneingang => Icons.move_to_inbox_outlined,
        TrainingArea.lager => Icons.inventory_2_outlined,
        TrainingArea.transport => Icons.local_shipping_outlined,
        TrainingArea.kommissionierung => Icons.checklist_outlined,
        TrainingArea.verpackung => Icons.inventory_outlined,
        TrainingArea.versand => Icons.send_outlined,
        TrainingArea.inventur => Icons.fact_check_outlined,
        TrainingArea.retouren => Icons.assignment_return_outlined,
        TrainingArea.verkaufsflaeche => Icons.storefront_outlined,
        TrainingArea.kundenberatung => Icons.support_agent_outlined,
        TrainingArea.kasse => Icons.point_of_sale_outlined,
        TrainingArea.warenpraesentation => Icons.auto_awesome_mosaic_outlined,
        TrainingArea.wareneingangVerkauf => Icons.move_to_inbox_outlined,
        TrainingArea.lagerBestand => Icons.inventory_2_outlined,
        TrainingArea.reklamationService => Icons.assignment_return_outlined,
        TrainingArea.werbungVerkaufsfoerderung => Icons.campaign_outlined,
      };

  String get subtitle => switch (this) {
        TrainingArea.wareneingang => 'Annehmen & prüfen',
        TrainingArea.lager => 'Einlagern & sortieren',
        TrainingArea.transport => 'Bewegen & fahren',
        TrainingArea.kommissionierung => 'Artikel zusammenstellen',
        TrainingArea.verpackung => 'Verpacken & vorbereiten',
        TrainingArea.versand => 'Versenden',
        TrainingArea.inventur => 'Zählen & prüfen',
        TrainingArea.retouren => 'Rücksendungen',
        TrainingArea.verkaufsflaeche => 'Auffüllen, ordnen & kontrollieren',
        TrainingArea.kundenberatung => 'Beraten & verkaufen',
        TrainingArea.kasse => 'Kassieren & Kundenservice',
        TrainingArea.warenpraesentation => 'Präsentieren & Aktionen',
        TrainingArea.wareneingangVerkauf => 'Lieferungen annehmen & prüfen',
        TrainingArea.lagerBestand => 'Bestände prüfen & pflegen',
        TrainingArea.reklamationService => 'Umtausch & Kundenanliegen',
        TrainingArea.werbungVerkaufsfoerderung => 'Werben & Verkauf fördern',
      };
}
