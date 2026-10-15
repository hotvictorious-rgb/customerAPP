import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/data/nigeria_geography_data.dart';
import '../models/geography_models.dart';
import '../providers/address_provider.dart';
import '../providers/catalog_provider.dart';

/// Interactive Location Selection Modal
/// Allows customers across Nigeria to accurately choose any State and LGA
/// with real-time 3-tier coverage evaluation (In-Shop, Transit Corridor, Nationwide Dispatch).
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
  StateModel? _filterState;

  @override
  void initState() {
    super.initState();
    final catalog = context.read<CatalogProvider>();
    _tempCity = catalog.selectedCity;
    _tempState = catalog.selectedState;
    _tempLgaId = catalog.selectedLgaId ?? 69;

    // Initialize filtered state matching current selection
    _filterState = NigeriaGeographyData.states.firstWhere(
      (s) => s.name.toLowerCase() == _tempState.toLowerCase(),
      orElse: () => NigeriaGeographyData.states.firstWhere((s) => s.id == 3),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.read<CatalogProvider>();

    // Instant search results across all Nigerian LGAs
    final searchResults = _searchQuery.isNotEmpty
        ? NigeriaGeographyData.search(_searchQuery)
        : <Map<String, dynamic>>[];

    // Current state's LGAs for hierarchical selection
    final stateLgas = _filterState != null
        ? NigeriaGeographyData.getLgasByStateId(_filterState!.id)
        : <LgaModel>[];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
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
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose Delivery Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'All 36 States & FCT Corridors Available',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Search Box (Type Any LGA or State)
            TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: InputDecoration(
                hintText: 'Type any city, LGA, or State (e.g. Ikeja, Port Harcourt, Uyo)...',
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
            const SizedBox(height: 12),

            // If user is searching, display instant matching suggestions
            if (_searchQuery.isNotEmpty) ...[
              const Text(
                'SEARCH RESULTS:',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              if (searchResults.isEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: AppColors.textSecondary),
                      SizedBox(width: 8),
                      Text(
                        'No matching LGA found. Try selecting your State below.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: searchResults.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = searchResults[index];
                    final lgaId = item['id'] as int;
                    final isSelected = _tempLgaId == lgaId;
                    final badge = NigeriaGeographyData.evaluateCoverageBadge(lgaId);

                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      leading: Icon(
                        Icons.place,
                        color: isSelected ? AppColors.primaryPurple : AppColors.secondaryGold,
                        size: 20,
                      ),
                      title: Text(
                        '${item['name']} LGA',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                          color: isSelected ? AppColors.primaryPurple : AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        '${item['state_name']} State • $badge',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: AppColors.success, size: 20)
                          : const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
                      onTap: () {
                        setState(() {
                          _tempLgaId = lgaId;
                          _tempCity = item['name'] as String;
                          _tempState = item['state_name'] as String;
                          _searchQuery = '';
                          _searchController.clear();
                        });
                      },
                    );
                  },
                ),
              const SizedBox(height: 14),
            ],

            // State Selector Dropdown (Allows customers to choose any of Nigeria's 36 States + FCT)
            const Text(
              'SELECT STATE IN NIGERIA:',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<StateModel>(
                  isExpanded: true,
                  value: _filterState,
                  hint: const Text('Choose State', style: TextStyle(fontSize: 13)),
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryPurple),
                  items: NigeriaGeographyData.states.map((st) {
                    return DropdownMenuItem<StateModel>(
                      value: st,
                      child: Text(
                        '${st.name} State',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    );
                  }).toList(),
                  onChanged: (st) {
                    if (st != null) {
                      setState(() {
                        _filterState = st;
                        final lgas = NigeriaGeographyData.getLgasByStateId(st.id);
                        if (lgas.isNotEmpty) {
                          _tempLgaId = lgas.first.id;
                          _tempCity = lgas.first.name;
                          _tempState = st.name;
                        } else {
                          _tempState = st.name;
                          _tempCity = st.name;
                        }
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),

            // LGAs for Selected State
            Text(
              'LOCAL GOVERNMENTS IN ${_filterState?.name.toUpperCase() ?? 'SELECTED STATE'}:',
              style: const TextStyle(
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
              children: stateLgas.map((lga) {
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
                      _tempState = _filterState?.name ?? 'Akwa Ibom';
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Popular National Commercial Hubs
            const Text(
              'POPULAR COMMERCIAL HUBS:',
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
              children: [
                _buildQuickHubChip(id: 69, city: 'Uyo', state: 'Akwa Ibom'),
                _buildQuickHubChip(id: 70, city: 'Eket', state: 'Akwa Ibom'),
                _buildQuickHubChip(id: 71, city: 'Ikot Ekpene', state: 'Akwa Ibom'),
                _buildQuickHubChip(id: 101, city: 'Ikeja', state: 'Lagos'),
                _buildQuickHubChip(id: 102, city: 'Eti-Osa / Lekki', state: 'Lagos'),
                _buildQuickHubChip(id: 201, city: 'Port Harcourt', state: 'Rivers'),
                _buildQuickHubChip(id: 301, city: 'Abuja Municipal', state: 'FCT Abuja'),
              ],
            ),
            const SizedBox(height: 18),

            // Selected Location Feedback Card (Live Real-time Proximity Engine)
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
                          '$_tempCity, $_tempState State',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          NigeriaGeographyData.evaluateCoverageBadge(_tempLgaId),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                        Text(
                          NigeriaGeographyData.evaluateCoverageDesc(_tempLgaId),
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
                  final badge = NigeriaGeographyData.evaluateCoverageBadge(_tempLgaId);
                  catalog.setLocation(
                    city: _tempCity,
                    state: _tempState,
                    lgaId: _tempLgaId,
                    badge: badge,
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

  Widget _buildQuickHubChip({
    required int id,
    required String city,
    required String state,
  }) {
    final isSelected = _tempLgaId == id;
    return ChoiceChip(
      avatar: Icon(
        Icons.flash_on,
        size: 14,
        color: isSelected ? Colors.white : AppColors.secondaryGold,
      ),
      label: Text('$city ($state)'),
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
          _tempLgaId = id;
          _tempCity = city;
          _tempState = state;
          _filterState = NigeriaGeographyData.states.firstWhere(
            (s) => s.name.toLowerCase() == state.toLowerCase(),
            orElse: () => _filterState!,
          );
        });
      },
    );
  }
}
