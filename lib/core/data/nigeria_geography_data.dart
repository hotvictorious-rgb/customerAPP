import '../../models/geography_models.dart';

/// Authoritative Canonical Geography Dataset for Nigeria
/// Supporting all 36 States + FCT and primary commercial Local Government Areas.
class NigeriaGeographyData {
  static final List<StateModel> states = [
    StateModel(id: 1, countryId: 1, name: 'Abia', stateCode: 'AB'),
    StateModel(id: 2, countryId: 1, name: 'Adamawa', stateCode: 'AD'),
    StateModel(id: 3, countryId: 1, name: 'Akwa Ibom', stateCode: 'AK'),
    StateModel(id: 4, countryId: 1, name: 'Anambra', stateCode: 'AN'),
    StateModel(id: 5, countryId: 1, name: 'Bauchi', stateCode: 'BA'),
    StateModel(id: 6, countryId: 1, name: 'Bayelsa', stateCode: 'BY'),
    StateModel(id: 7, countryId: 1, name: 'Benue', stateCode: 'BE'),
    StateModel(id: 8, countryId: 1, name: 'Borno', stateCode: 'BO'),
    StateModel(id: 9, countryId: 1, name: 'Cross River', stateCode: 'CR'),
    StateModel(id: 10, countryId: 1, name: 'Delta', stateCode: 'DE'),
    StateModel(id: 11, countryId: 1, name: 'Ebonyi', stateCode: 'EB'),
    StateModel(id: 12, countryId: 1, name: 'Edo', stateCode: 'ED'),
    StateModel(id: 13, countryId: 1, name: 'Ekiti', stateCode: 'EK'),
    StateModel(id: 14, countryId: 1, name: 'Enugu', stateCode: 'EN'),
    StateModel(id: 15, countryId: 1, name: 'FCT Abuja', stateCode: 'FC'),
    StateModel(id: 16, countryId: 1, name: 'Gombe', stateCode: 'GO'),
    StateModel(id: 17, countryId: 1, name: 'Imo', stateCode: 'IM'),
    StateModel(id: 18, countryId: 1, name: 'Jigawa', stateCode: 'JI'),
    StateModel(id: 19, countryId: 1, name: 'Kaduna', stateCode: 'KD'),
    StateModel(id: 20, countryId: 1, name: 'Kano', stateCode: 'KN'),
    StateModel(id: 21, countryId: 1, name: 'Katsina', stateCode: 'KT'),
    StateModel(id: 22, countryId: 1, name: 'Kebbi', stateCode: 'KB'),
    StateModel(id: 23, countryId: 1, name: 'Kogi', stateCode: 'KO'),
    StateModel(id: 24, countryId: 1, name: 'Kwara', stateCode: 'KW'),
    StateModel(id: 25, countryId: 1, name: 'Lagos', stateCode: 'LA'),
    StateModel(id: 26, countryId: 1, name: 'Nasarawa', stateCode: 'NA'),
    StateModel(id: 27, countryId: 1, name: 'Niger', stateCode: 'NI'),
    StateModel(id: 28, countryId: 1, name: 'Ogun', stateCode: 'OG'),
    StateModel(id: 29, countryId: 1, name: 'Ondo', stateCode: 'ON'),
    StateModel(id: 30, countryId: 1, name: 'Osun', stateCode: 'OS'),
    StateModel(id: 31, countryId: 1, name: 'Oyo', stateCode: 'OY'),
    StateModel(id: 32, countryId: 1, name: 'Plateau', stateCode: 'PL'),
    StateModel(id: 33, countryId: 1, name: 'Rivers', stateCode: 'RI'),
    StateModel(id: 34, countryId: 1, name: 'Sokoto', stateCode: 'SO'),
    StateModel(id: 35, countryId: 1, name: 'Taraba', stateCode: 'TA'),
    StateModel(id: 36, countryId: 1, name: 'Yobe', stateCode: 'YO'),
    StateModel(id: 37, countryId: 1, name: 'Zamfara', stateCode: 'ZA'),
  ];

  static final List<LgaModel> canonicalLgas = [
    // Akwa Ibom State (State ID 3)
    LgaModel(id: 69, stateId: 3, name: 'Uyo'),
    LgaModel(id: 70, stateId: 3, name: 'Eket'),
    LgaModel(id: 71, stateId: 3, name: 'Ikot Ekpene'),
    LgaModel(id: 72, stateId: 3, name: 'Oron'),
    LgaModel(id: 65, stateId: 3, name: 'Abak'),
    LgaModel(id: 66, stateId: 3, name: 'Ikot Abasi'),
    LgaModel(id: 67, stateId: 3, name: 'Etinan'),
    LgaModel(id: 68, stateId: 3, name: 'Ibiono Ibom'),
    LgaModel(id: 73, stateId: 3, name: 'Itu'),
    LgaModel(id: 74, stateId: 3, name: 'Nsit Ubium'),
    LgaModel(id: 75, stateId: 3, name: 'Onna'),
    LgaModel(id: 76, stateId: 3, name: 'Ukanafun'),
    LgaModel(id: 77, stateId: 3, name: 'Esit Eket'),
    LgaModel(id: 78, stateId: 3, name: 'Ibesikpo Asutan'),
    LgaModel(id: 79, stateId: 3, name: 'Mbo'),

    // Lagos State (State ID 25)
    LgaModel(id: 101, stateId: 25, name: 'Ikeja'),
    LgaModel(id: 102, stateId: 25, name: 'Eti-Osa / Lekki'),
    LgaModel(id: 103, stateId: 25, name: 'Surulere'),
    LgaModel(id: 104, stateId: 25, name: 'Alimosho'),
    LgaModel(id: 105, stateId: 25, name: 'Lagos Island'),
    LgaModel(id: 106, stateId: 25, name: 'Kosofe'),
    LgaModel(id: 107, stateId: 25, name: 'Oshodi-Isolo'),
    LgaModel(id: 108, stateId: 25, name: 'Ikorodu'),
    LgaModel(id: 109, stateId: 25, name: 'Agege'),
    LgaModel(id: 110, stateId: 25, name: 'Amuwo-Odofin'),

    // Rivers State (State ID 33)
    LgaModel(id: 201, stateId: 33, name: 'Port Harcourt'),
    LgaModel(id: 202, stateId: 33, name: 'Obio-Akpor'),
    LgaModel(id: 203, stateId: 33, name: 'Eleme'),
    LgaModel(id: 204, stateId: 33, name: 'Oyigbo'),
    LgaModel(id: 205, stateId: 33, name: 'Ikwerre'),

    // FCT Abuja (State ID 15)
    LgaModel(id: 301, stateId: 15, name: 'Abuja Municipal (AMAC)'),
    LgaModel(id: 302, stateId: 15, name: 'Bwari'),
    LgaModel(id: 303, stateId: 15, name: 'Gwagwalada'),
    LgaModel(id: 304, stateId: 15, name: 'Kuje'),

    // Cross River State (State ID 9)
    LgaModel(id: 401, stateId: 9, name: 'Calabar Municipal'),
    LgaModel(id: 402, stateId: 9, name: 'Calabar South'),
    LgaModel(id: 403, stateId: 9, name: 'Ikom'),
    LgaModel(id: 404, stateId: 9, name: 'Ogoja'),

    // Delta State (State ID 10)
    LgaModel(id: 501, stateId: 10, name: 'Warri South'),
    LgaModel(id: 502, stateId: 10, name: 'Oshimili South (Asaba)'),
    LgaModel(id: 503, stateId: 10, name: 'Uvwie (Effurun)'),
    LgaModel(id: 504, stateId: 10, name: 'Sapele'),

    // Edo State (State ID 12)
    LgaModel(id: 601, stateId: 12, name: 'Oredo (Benin City)'),
    LgaModel(id: 602, stateId: 12, name: 'Ikpoba-Okha'),
    LgaModel(id: 603, stateId: 12, name: 'Egor'),

    // Enugu State (State ID 14)
    LgaModel(id: 701, stateId: 14, name: 'Enugu North'),
    LgaModel(id: 702, stateId: 14, name: 'Enugu South'),
    LgaModel(id: 703, stateId: 14, name: 'Nsukka'),

    // Anambra State (State ID 4)
    LgaModel(id: 801, stateId: 4, name: 'Onitsha North'),
    LgaModel(id: 802, stateId: 4, name: 'Onitsha South'),
    LgaModel(id: 803, stateId: 4, name: 'Awka South'),
    LgaModel(id: 804, stateId: 4, name: 'Nnewi North'),

    // Oyo State (State ID 31)
    LgaModel(id: 901, stateId: 31, name: 'Ibadan North'),
    LgaModel(id: 902, stateId: 31, name: 'Ibadan South-West'),
    LgaModel(id: 903, stateId: 31, name: 'Ogbomosho North'),

    // Kano State (State ID 20)
    LgaModel(id: 1001, stateId: 20, name: 'Kano Municipal'),
    LgaModel(id: 1002, stateId: 20, name: 'Nassarawa'),
    LgaModel(id: 1003, stateId: 20, name: 'Fagge'),
    LgaModel(id: 1004, stateId: 20, name: 'Dala'),

    // Kaduna State (State ID 19)
    LgaModel(id: 1101, stateId: 19, name: 'Kaduna North'),
    LgaModel(id: 1102, stateId: 19, name: 'Kaduna South'),
    LgaModel(id: 1103, stateId: 19, name: 'Zaria'),

    // Imo State (State ID 17)
    LgaModel(id: 1201, stateId: 17, name: 'Owerri Municipal'),
    LgaModel(id: 1202, stateId: 17, name: 'Owerri North'),
    LgaModel(id: 1203, stateId: 17, name: 'Owerri West'),

    // Abia State (State ID 1)
    LgaModel(id: 1301, stateId: 1, name: 'Aba North'),
    LgaModel(id: 1302, stateId: 1, name: 'Aba South'),
    LgaModel(id: 1303, stateId: 1, name: 'Umuahia North'),

    // Ogun State (State ID 28)
    LgaModel(id: 1401, stateId: 28, name: 'Abeokuta South'),
    LgaModel(id: 1402, stateId: 28, name: 'Ado-Odo/Ota'),

    // Plateau State (State ID 32)
    LgaModel(id: 1501, stateId: 32, name: 'Jos North'),
    LgaModel(id: 1502, stateId: 32, name: 'Jos South'),
  ];

  /// Get state by state ID
  static StateModel? getStateById(int stateId) {
    try {
      return states.firstWhere((s) => s.id == stateId);
    } catch (_) {
      return null;
    }
  }

  /// Get state name for any LGA ID
  static String getStateNameForLga(int lgaId) {
    try {
      final lga = canonicalLgas.firstWhere((l) => l.id == lgaId);
      final st = states.firstWhere((s) => s.id == lga.stateId);
      return st.name;
    } catch (_) {
      return 'Akwa Ibom';
    }
  }

  /// Get all LGAs for a given state ID
  static List<LgaModel> getLgasByStateId(int stateId) {
    return canonicalLgas.where((l) => l.stateId == stateId).toList();
  }

  /// Instant search across all LGAs and States in Nigeria
  static List<Map<String, dynamic>> search(String query) {
    if (query.trim().isEmpty) return [];
    final q = query.trim().toLowerCase();

    final results = <Map<String, dynamic>>[];

    for (final lga in canonicalLgas) {
      final state = getStateById(lga.stateId);
      final stateName = state?.name ?? 'Nigeria';

      if (lga.name.toLowerCase().contains(q) || stateName.toLowerCase().contains(q)) {
        results.add({
          'id': lga.id,
          'name': lga.name,
          'state_id': lga.stateId,
          'state_name': stateName,
        });
      }
    }

    return results;
  }

  /// Evaluate 3-tier sovereign coverage tier based on LGA ID
  static String evaluateCoverageBadge(int lgaId) {
    if ([69, 70, 71, 72].contains(lgaId)) {
      return '⚡ In-Shop Pickup & Same-Day Active';
    } else if ([65, 66, 67, 101, 102, 201, 301].contains(lgaId)) {
      return '🚚 Transit Delivery Corridor Active';
    } else {
      return '📦 Nationwide Park Dispatch';
    }
  }

  /// Evaluate detailed coverage description for feedback banner
  static String evaluateCoverageDesc(int lgaId) {
    if ([69, 70, 71, 72].contains(lgaId)) {
      return 'Physical in-shop inspection and fast local dispatch available.';
    } else if ([65, 66, 67, 101, 102, 201, 301].contains(lgaId)) {
      return 'Connected via scheduled interstate delivery corridor (12-24 hrs).';
    } else {
      return 'Regional courier dispatch with delivery times varying by distance.';
    }
  }
}
