import 'package:flutter/material.dart';
import 'package:pharmago/UI/Home/Tabs/Pharma_Home/widgets/Edit_Screen.dart';
import 'package:provider/provider.dart';

import '../../../Models/Medicines.dart';
import '../../../Providers/DetailsProvider.dart';
import '../../../core/resources/ColorManger.dart';
import '../../../Providers/UserProvider.dart';
import '../../../Providers/CartProvider.dart';

class MedicItems extends StatefulWidget {
  final Medic medic;
  final bool isOwner;
  final String? pharmaId;
  
  const MedicItems(this.medic, {Key? key, this.isOwner = false, this.pharmaId}) : super(key: key);

  @override
  State<MedicItems> createState() => _MedicItemsState();
}

class _MedicItemsState extends State<MedicItems> {

  @override
  Widget build(BuildContext context) {
    DetailsProvider detailsProvider = Provider.of<DetailsProvider>(context);
    UserProvider userProvider = Provider.of<UserProvider>(context);
    
    // Explicitly check if the logged in user is a pharmacy owner
    bool isPharmaOwner = userProvider.myUser?.pharmacy == true;

    return InkWell(
      onTap: () {
        if (isPharmaOwner || widget.isOwner) {
          Navigator.pushNamed(context, EditScreen.routeName, arguments: widget.medic);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 5,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: widget.medic.imageUrl != null && widget.medic.imageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.medic.imageUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.medical_services, color: Colors.teal, size: 30)),
                      ),
                    )
                  : const Center(child: Icon(Icons.medical_services, color: Colors.teal, size: 30)),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.medic.name ?? "",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.medic.activeIngredient != null && widget.medic.activeIngredient!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.medic.activeIngredient!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 5),
                  Text(
                    "\$${widget.medic.price ?? 0.0}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.teal,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            if (isPharmaOwner || widget.isOwner)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, EditScreen.routeName, arguments: widget.medic);
                },
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade50,
                  foregroundColor: Colors.teal,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              )
            else
              InkWell(
                onTap: () {
                  bool added = Provider.of<CartProvider>(context, listen: false).addItem(widget.medic, pharmaId: widget.pharmaId);
                  
                  if (added) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${widget.medic.name} added to cart!'),
                        duration: const Duration(seconds: 1),
                        backgroundColor: Colors.teal,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Cannot add more. Max stock reached for ${widget.medic.name}'),
                        duration: const Duration(seconds: 2),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 24),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
