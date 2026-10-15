import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/geography_models.dart';
import '../../providers/address_provider.dart';
import '../../widgets/brand_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();

  CountryModel? _selectedCountry;
  StateModel? _selectedState;
  LgaModel? _selectedLga;
  bool _isDefault = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final addressProv = context.read<AddressProvider>();
      await addressProv.fetchCountries();
      if (addressProv.countries.isNotEmpty) {
        setState(() => _selectedCountry = addressProv.countries.first);
        await addressProv.fetchStates(_selectedCountry!.id);
        if (addressProv.states.isNotEmpty) {
          // Default to Akwa Ibom if found
          final akwaIbom = addressProv.states.firstWhere(
            (s) => s.name.toLowerCase().contains('akwa ibom'),
            orElse: () => addressProv.states.first,
          );
          setState(() => _selectedState = akwaIbom);
          await addressProv.fetchLgas(_selectedState!.id);
          if (addressProv.lgas.isNotEmpty) {
            setState(() => _selectedLga = addressProv.lgas.first);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  Future<void> _submitAddress() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCountry == null || _selectedState == null || _selectedLga == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Country, State, and LGA')),
      );
      return;
    }

    final addressProv = context.read<AddressProvider>();
    final success = await addressProv.addAddress(
      contactName: _nameController.text,
      phone: _phoneController.text,
      addressLine: _addressController.text,
      landmark: _landmarkController.text,
      countryId: _selectedCountry!.id,
      stateId: _selectedState!.id,
      lgaId: _selectedLga!.id,
      isDefault: _isDefault,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Delivery address added successfully.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressProv = context.watch<AddressProvider>();

    return Scaffold(
      appBar: const BrandAppBar(
        title: 'Add New Address',
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Recipient Contact Name',
                hint: 'e.g. Victor Udo',
                prefixIcon: Icons.person_outline,
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter recipient name' : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _phoneController,
                label: 'Delivery Phone Number',
                hint: 'e.g. 08012345678',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (val) => (val == null || val.trim().length < 10) ? 'Enter a valid phone number' : null,
              ),
              const SizedBox(height: 20),

              // Canonical Geography Hierarchy Header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.map_outlined, color: AppColors.primaryPurple, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Canonical Hierarchy: Country -> State -> LGA for Directional Lanes',
                        style: TextStyle(
                          color: AppColors.primaryPurple,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Country Dropdown
              const Text('Country', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<CountryModel>(
                    isExpanded: true,
                    value: _selectedCountry,
                    hint: const Text('Select Country'),
                    items: addressProv.countries.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCountry = val;
                        _selectedState = null;
                        _selectedLga = null;
                      });
                      if (val != null) addressProv.fetchStates(val.id);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // State Dropdown
              const Text('State', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<StateModel>(
                    isExpanded: true,
                    value: _selectedState,
                    hint: const Text('Select State (e.g. Akwa Ibom)'),
                    items: addressProv.states.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedState = val;
                        _selectedLga = null;
                      });
                      if (val != null) addressProv.fetchLgas(val.id);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // LGA Dropdown
              const Text('Local Government Area (LGA)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<LgaModel>(
                    isExpanded: true,
                    value: _selectedLga,
                    hint: const Text('Select LGA (e.g. Uyo, Eket)'),
                    items: addressProv.lgas.map((l) => DropdownMenuItem(value: l, child: Text(l.name))).toList(),
                    onChanged: (val) => setState(() => _selectedLga = val),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _addressController,
                label: 'Street Address & House / Flat Number',
                hint: 'e.g. 14 Aka Road, Shelter Afrique Estate',
                prefixIcon: Icons.home_outlined,
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter street address' : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _landmarkController,
                label: 'Prominent Landmark (Optional)',
                hint: 'e.g. Opposite Champion Breweries or near Plaza',
                prefixIcon: Icons.flag_outlined,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Checkbox(
                    value: _isDefault,
                    activeColor: AppColors.primaryPurple,
                    onChanged: (val) => setState(() => _isDefault = val ?? false),
                  ),
                  const Text('Set as default delivery address', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 24),

              CustomButton(
                text: 'Save Delivery Address',
                icon: Icons.check,
                isLoading: addressProv.isLoading,
                onPressed: _submitAddress,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
