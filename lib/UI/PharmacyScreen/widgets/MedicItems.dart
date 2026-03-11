import 'package:flutter/material.dart';
import 'package:pharmago/UI/Home/Tabs/Pharma_Home/widgets/Edit_Screen.dart';
import 'package:provider/provider.dart';

import '../../../Models/Medicines.dart';
import '../../../Providers/DetailsProvider.dart';
import '../../../core/resources/ColorManger.dart';

import '../../../Providers/CartProvider.dart';

class MedicItems extends StatefulWidget {
  final Medic medic;
  final bool isOwner;
  
  const MedicItems(this.medic, {Key? key, this.isOwner = false}) : super(key: key);

  @override
  State<MedicItems> createState() => _MedicItemsState();
}

class _MedicItemsState extends State<MedicItems> {

  @override
  Widget build(BuildContext context) {
    DetailsProvider detailsProvider= Provider.of<DetailsProvider>(context);
    return InkWell(
      onTap: () {
        if (widget.isOwner) {
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.medical_services, color: Colors.teal, size: 30),
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
            if (widget.isOwner)
              const Icon(Icons.edit, color: Colors.grey)
            else
              InkWell(
                onTap: () {
                  Provider.of<CartProvider>(context, listen: false).addItem(widget.medic);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${widget.medic.name} added to cart!'),
                      duration: const Duration(seconds: 1),
                      backgroundColor: Colors.teal,
                    ),
                  );
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
