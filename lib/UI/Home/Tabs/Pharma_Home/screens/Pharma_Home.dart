import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pharmago/core/resources/ColorManger.dart';
import 'package:provider/provider.dart';

import '../../../../../Core/resources/StringsManger.dart';
import '../../../../../Providers/UserProvider.dart';
import '../../../../../core/SupabaseHandler.dart';
import '../../../../PharmacyScreen/widgets/MedicItems.dart';
import '../../Home/widget/Pharmaitems.dart';
import '../widgets/Add_Screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class PharmaHome extends StatefulWidget {
  const PharmaHome({super.key});

  @override
  State<PharmaHome> createState() => _PharmaHomeState();
}

class _PharmaHomeState extends State<PharmaHome> {
  String searchQuery = '';
  bool isSearching = false;

  Future<void> _uploadPharmaImage(BuildContext context, String pharmaId) async {
    // Show loading while fetching current image
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    String? currentImageUrl;
    try {
      final data = await SupabaseHandler.supabase.from('pharmacies').select('image_url').eq('id', pharmaId).maybeSingle();
      currentImageUrl = data?['image_url'];
    } catch (e) {
      debugPrint('Error fetching pharmacy image: $e');
    }

    if (context.mounted) Navigator.pop(context); // Close loading

    File? selectedFile;

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (c) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Pharmacy Profile Image'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: selectedFile != null
                        ? Image.file(selectedFile!, height: 200, width: 300, fit: BoxFit.cover)
                        : (currentImageUrl != null && currentImageUrl!.isNotEmpty)
                            ? Image.network(currentImageUrl!, height: 200, width: 300, fit: BoxFit.cover)
                            : Container(
                                height: 200,
                                width: 300,
                                color: Colors.grey.shade200,
                                child: Icon(Icons.store, size: 80, color: Colors.grey.shade400),
                              ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setState(() {
                          selectedFile = File(image.path);
                        });
                      }
                    },
                    icon: const Icon(Icons.image),
                    label: const Text('Choose New Image'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(c, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selectedFile != null ? () => Navigator.pop(c, true) : null,
                  style: ElevatedButton.styleFrom(backgroundColor: ColorManger.green, foregroundColor: Colors.white),
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirm != true || selectedFile == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    try {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_$pharmaId.jpg';
      String url = await SupabaseHandler.uploadPharmacyImage(selectedFile!, fileName);
      
      // Update pharmacy in DB
      final response = await SupabaseHandler.supabase.from('pharmacies').update({'image_url': url}).eq('id', pharmaId).select();
      if (response.isEmpty) {
        throw Exception("Update blocked by Supabase! Please enable UPDATE policy for 'pharmacies' table in SQL editor.");
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile image updated successfully!')));
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update image: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: isSearching
            ? TextField(
          onChanged: (value) {
            setState(() {
              searchQuery = value.toLowerCase();  // Update query (case-insensitive)
            });
          },
          decoration: InputDecoration(
            hintText: StringsManger.searchMedic.tr(),  // Localize if needed
            border: InputBorder.none,
            hintStyle: TextStyle(color: ColorManger.green),
          ),
          style: TextStyle(color: ColorManger.green),
          autofocus: true,  // Auto-focus for better UX
        )
            : Text(
          StringsManger.pharmacies.tr(),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        actions: [
          IconButton(
            onPressed: () => _uploadPharmaImage(context, userProvider.myUser?.pharma ?? ''),
            icon: Icon(Icons.add_a_photo, color: ColorManger.green),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AddScreen.routeName);
            },
            icon: Icon(Icons.add, color: ColorManger.green),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  searchQuery = '';
                }
              });
            },
            icon: isSearching
                ? Icon(Icons.close, color: ColorManger.green)
                : Icon(Icons.search, color: ColorManger.green),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: SupabaseHandler.getAllMedicStream(
          userProvider.myUser?.pharma ?? '',
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Column(
              children: [
                Text(snapshot.error.toString()),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  child: Text(StringsManger.wrong),
                ),
              ],
            );
          }
          var medic = snapshot.data ?? [];
          if (medic.isEmpty) {
            return Center(
              child: Text(
                StringsManger.noPharma,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          }
          final filteredMedicines = medic.where((m) {
            final name = m.name?.toLowerCase() ?? '';
            final ingredient = m.activeIngredient?.toLowerCase() ?? '';
            return name.contains(searchQuery) || ingredient.contains(searchQuery);
          }).toList();

          if (filteredMedicines.isEmpty && searchQuery.isNotEmpty) {
            return Center(
              child: Text(
                StringsManger.noMedic.tr(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          }

          final lowStockMedics = filteredMedicines.where((m) => (m.quantity ?? 0) <= 5).toList();
          bool showStockAlert = lowStockMedics.isNotEmpty;
          
          String alertMessage = '';
          if (showStockAlert) {
            if (lowStockMedics.length == 1) {
              alertMessage = 'Warning: ${lowStockMedics.first.name} is running out! Only ${lowStockMedics.first.quantity} left in stock.';
            } else {
              alertMessage = 'Warning: ${lowStockMedics.length} medicines are running out! (${lowStockMedics.map((m) => m.name).join(', ')})';
            }
          }

          return Column(
            children: [
              if (showStockAlert)
                Container(
                  color: Colors.red.shade100,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          alertMessage,
                          style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ListView.separated(
                    itemBuilder: (context, index) => MedicItems(filteredMedicines[index]),
                    separatorBuilder: (context, index) => SizedBox(height: 16),
                    itemCount: filteredMedicines.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
