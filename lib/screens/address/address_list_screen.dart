import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/address_provider.dart';
import '../../widgets/brand_app_bar.dart';
import '../../widgets/custom_button.dart';
import 'add_address_screen.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressProvider>().fetchAddresses();
    });
  }

  void _confirmDeleteAddress(BuildContext context, int id, String contactName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text('Are you sure you want to remove "$contactName" from your saved delivery addresses?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              final addressProv = context.read<AddressProvider>();
              final success = await addressProv.deleteAddress(id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Address removed.' : (addressProv.errorMessage ?? 'Failed to delete address.')),
                    backgroundColor: success ? AppColors.success : AppColors.danger,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addressProv = context.watch<AddressProvider>();

    return Scaffold(
      appBar: const BrandAppBar(
        title: 'Saved Delivery Addresses',
        showBack: true,
      ),
      body: RefreshIndicator(
        color: AppColors.primaryPurple,
        onRefresh: () => addressProv.fetchAddresses(),
        child: addressProv.isLoading && addressProv.addresses.isEmpty
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple))
            : addressProv.addresses.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_off, size: 60, color: AppColors.textMuted),
                          const SizedBox(height: 16),
                          const Text('No Addresses Saved', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text(
                            'Add your home, office, or branch address in Akwa Ibom State to enable fast delivery lane routing.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            text: 'Add New Address',
                            icon: Icons.add_location_alt,
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddAddressScreen()));
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: addressProv.addresses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final addr = addressProv.addresses[index];
                      final isSelected = addressProv.selectedAddress?.id == addr.id;

                      return GestureDetector(
                        onTap: () => addressProv.selectAddress(addr),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryPurple : AppColors.border,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: AppColors.cardShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                    color: isSelected ? AppColors.primaryPurple : AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    addr.contactName,
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                  ),
                                  const Spacer(),
                                  if (addr.isDefault) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryPurple.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'DEFAULT',
                                        style: TextStyle(
                                          color: AppColors.primaryPurple,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    tooltip: 'Delete address',
                                    onPressed: () => _confirmDeleteAddress(context, addr.id, addr.contactName),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                addr.fullAddressText,
                                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.phone, size: 14, color: AppColors.textSecondary),
                                  const SizedBox(width: 6),
                                  Text(addr.phone, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: SafeArea(
          child: CustomButton(
            text: 'Add New Address',
            icon: Icons.add,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddAddressScreen()));
            },
          ),
        ),
      ),
    );
  }
}
