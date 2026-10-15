import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../models/geography_models.dart';
import '../providers/address_provider.dart';
import '../providers/catalog_provider.dart';

class LocationSelectionModal extends StatefulWidget {
  const LocationSelectionModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LocationSelectionModal(),
    );
  }

  @override
  State<LocationSelectionModal> createState() => _LocationSelectionModalState();
}

class _LocationSelectionModalState extends State<LocationSelectionModal> {
  final _searchController = TextEditingController();
  late String _tempCity;
  late String _tempState;
  late int _tempLgaId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final catalog = context.read<CatalogProvider>();
    _tempCity = catalog.selectedCity;
    _tempState = catalog.selectedState;
    _tempLgaId = catalog.selectedLgaId ?? 69;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getCoverageBadge(int lgaId) {
    if ([69, 70, 71, 72].contains(lgaId)) {
      return '⚡ In-Shop Pickup & Same-Day Active';
    } else if ([65, 66, 101, 102].contains(lgaId)) {
      return '🚚 Transit Delivery Corridor Active';
    } else {
      return '📦 Nationwide Park Dispatch';
    }
  }

  String _getCoverageDesc(int lgaId) {
    if ([69, 70, 71, 72].contains(lgaId)) {
      return 'Physical in-shop inspection and fast local dispatch available.';
    } else if ([65, 66, 101, 102].contains(lgaId)) {
      return 'Connected via scheduled interstate delivery corridor (12-24 hrs).';
    } else {
      return 'Regional courier dispatch with delivery times varying by distance.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressProv = context.watch<AddressProvider>();
    final catalog = context.read<CatalogProvider>();

    final allLgas = addressProv.lgas.isNotEmpty
        ? addressProv.lgas
        : [
            LgaModel(id: 69, stateId: 3, name: 'Uyo'),
            LgaModel(id: 70, stateId: 3, name: 'Eket'),
            LgaModel(id: 71, stateId: 3, name: 'Ikot Ekpene'),
            LgaModel(id: 72, stateId: 3, name: 'Oron'),
            LgaModel(id: 65, stateId: 3, name: 'Abak'),
            LgaModel(id: 66, stateId: 3, name: 'Ikot Abasi'),
          ];

    final filteredLgas = _searchQuery.isEmpty
        ? allLgas
        : allLgas.where((l) => l.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Container(
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Modal Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_on, color: AppColors.primaryPurple, size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Choose Delivery Location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Select your residential LGA in Nigeria to see real-time in-shop pickup merchants and directional delivery corridors.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
            ),
            const SizedBox(height: 16),

            // Search Box
            TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: InputDecoration(
                hintText: 'Type your residential LGA (e.g. Uyo, Eket, Ikeja)...',
                hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryPurple, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                filled: true,
                fillColor: AppColors.surfaceMuted,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Popular Local Governments Chips
            const Text(
              'POPULAR LOCAL GOVERNMENTS:',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: filteredLgas.map((lga) {
                final isSelected = _tempLgaId == lga.id;
                return ChoiceChip(
                  label: Text('${lga.name} LGA'),
                  selected: isSelected,
                  selectedColor: AppColors.primaryPurple,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 11,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? AppColors.primaryPurple : AppColors.border,
                    ),
                  ),
                  onSelected: (_) {
                    setState(() {
                      _tempLgaId = lga.id;
                      _tempCity = lga.name;
                      _tempState = 'Akwa Ibom';
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Selected Location Feedback Card (Matching newVmarket vmSelectedLocCard)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_outline, color: AppColors.success, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_tempCity, $_tempState',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getCoverageBadge(_tempLgaId),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                        Text(
                          _getCoverageDesc(_tempLgaId),
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Submit Done Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  catalog.setLocation(
                    city: _tempCity,
                    state: _tempState,
                    lgaId: _tempLgaId,
                    badge: _getCoverageBadge(_tempLgaId),
                  );
                  Navigator.pop(context);
                },
                child: const Text(
                  'Done (Apply Location)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
