class CountryModel {
  final int id;
  final String name;
  final String isoCode;
  final String? phoneCode;

  CountryModel({
    required this.id,
    required this.name,
    required this.isoCode,
    this.phoneCode,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Nigeria',
      isoCode: json['iso_code'] as String? ?? 'NGA',
      phoneCode: json['phone_code'] as String?,
    );
  }
}

class StateModel {
  final int id;
  final int countryId;
  final String name;
  final String? stateCode;

  StateModel({
    required this.id,
    required this.countryId,
    required this.name,
    this.stateCode,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id'] as int,
      countryId: json['country_id'] as int? ?? 1,
      name: json['name'] as String? ?? '',
      stateCode: json['state_code'] as String?,
    );
  }
}

class LgaModel {
  final int id;
  final int stateId;
  final String name;

  LgaModel({
    required this.id,
    required this.stateId,
    required this.name,
  });

  factory LgaModel.fromJson(Map<String, dynamic> json) {
    return LgaModel(
      id: json['id'] as int,
      stateId: json['state_id'] as int? ?? 1,
      name: json['name'] as String? ?? '',
    );
  }
}
