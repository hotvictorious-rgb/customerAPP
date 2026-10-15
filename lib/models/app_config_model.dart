import 'geography_models.dart';

class AppConfigModel {
  final String appName;
  final String appSlogan;
  final String supportPhone;
  final String supportEmail;
  final String callToOrderPhone;
  final String currencySymbol;
  final String currencyCode;
  final double cashbackPercentage;
  final List<LgaModel> activeCorridors;
  final VersionControlModel versionControl;
  final MaintenanceModeModel maintenanceMode;

  AppConfigModel({
    required this.appName,
    required this.appSlogan,
    required this.supportPhone,
    required this.supportEmail,
    required this.callToOrderPhone,
    required this.currencySymbol,
    required this.currencyCode,
    required this.cashbackPercentage,
    required this.activeCorridors,
    required this.versionControl,
    required this.maintenanceMode,
  });

  factory AppConfigModel.fromJson(Map<String, dynamic> json) {
    final corridorsRaw = json['active_corridors'] as List? ?? [];
    return AppConfigModel(
      appName: json['app_name'] as String? ?? 'Victorious MARKET',
      appSlogan: json['app_slogan'] as String? ?? 'Akwa Ibom Sovereign Marketplace',
      supportPhone: json['support_phone'] as String? ?? '09118949035',
      supportEmail: json['support_email'] as String? ?? 'support@victoriousmarket.com.ng',
      callToOrderPhone: json['call_to_order_phone'] as String? ?? '+2349118949035',
      currencySymbol: json['currency_symbol'] as String? ?? '₦',
      currencyCode: json['currency_code'] as String? ?? 'NGN',
      cashbackPercentage: (json['cashback_percentage'] as num?)?.toDouble() ?? 5.0,
      activeCorridors: corridorsRaw.map((e) => LgaModel.fromJson(e as Map<String, dynamic>)).toList(),
      versionControl: VersionControlModel.fromJson(json['version_control'] as Map<String, dynamic>? ?? {}),
      maintenanceMode: MaintenanceModeModel.fromJson(json['maintenance_mode'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class VersionControlModel {
  final String minVersion;
  final String latestVersion;
  final bool forceUpdate;
  final String updateUrl;

  VersionControlModel({
    required this.minVersion,
    required this.latestVersion,
    required this.forceUpdate,
    required this.updateUrl,
  });

  factory VersionControlModel.fromJson(Map<String, dynamic> json) {
    return VersionControlModel(
      minVersion: json['min_version'] as String? ?? '1.0.0',
      latestVersion: json['latest_version'] as String? ?? '1.0.0',
      forceUpdate: json['force_update'] as bool? ?? false,
      updateUrl: json['update_url'] as String? ?? 'https://shop.victoriousmarket.com.ng/download',
    );
  }
}

class MaintenanceModeModel {
  final bool isActive;
  final String? message;

  MaintenanceModeModel({
    required this.isActive,
    this.message,
  });

  factory MaintenanceModeModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceModeModel(
      isActive: json['is_active'] as bool? ?? false,
      message: json['message'] as String?,
    );
  }
}
