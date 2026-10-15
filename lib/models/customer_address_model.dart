import 'geography_models.dart';

class CustomerAddressModel {
  final int id;
  final String contactName;
  final String phone;
  final String addressLine;
  final String? landmark;
  final int countryId;
  final int stateId;
  final int lgaId;
  final bool isDefault;
  final CountryModel? country;
  final StateModel? state;
  final LgaModel? lga;

  CustomerAddressModel({
    required this.id,
    required this.contactName,
    required this.phone,
    required this.addressLine,
    this.landmark,
    required this.countryId,
    required this.stateId,
    required this.lgaId,
    this.isDefault = false,
    this.country,
    this.state,
    this.lga,
  });

  factory CustomerAddressModel.fromJson(Map<String, dynamic> json) {
    return CustomerAddressModel(
      id: json['id'] as int,
      contactName: json['contact_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      addressLine: json['address_line'] as String? ?? '',
      landmark: json['landmark'] as String?,
      countryId: json['country_id'] as int? ?? 1,
      stateId: json['state_id'] as int? ?? 1,
      lgaId: json['lga_id'] as int? ?? 1,
      isDefault: json['is_default'] == 1 || json['is_default'] == true,
      country: json['country'] != null ? CountryModel.fromJson(json['country']) : null,
      state: json['state'] != null ? StateModel.fromJson(json['state']) : null,
      lga: json['lga'] != null ? LgaModel.fromJson(json['lga']) : null,
    );
  }

  String get fullAddressText {
    final buffer = StringBuffer(addressLine);
    if (landmark != null && landmark!.isNotEmpty) {
      buffer.write(' (near $landmark)');
    }
    if (lga != null) {
      buffer.write(', ${lga!.name}');
    }
    if (state != null) {
      buffer.write(', ${state!.name}');
    }
    return buffer.toString();
  }
}
