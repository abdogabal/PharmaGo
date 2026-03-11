import 'package:flutter/material.dart';
import 'package:pharmago/Models/Order.dart';
import 'package:pharmago/core/SupabaseHandler.dart';
import 'package:provider/provider.dart';

import '../../../../../Providers/DetailsProvider.dart';
import '../../../../../core/resources/ColorManger.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderItem extends StatefulWidget {
  final Order order;

  OrderItem(this.order);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  @override
  Widget build(BuildContext context) {
    DetailsProvider detailsProvider = Provider.of<DetailsProvider>(context);
    return InkWell(
      onTap: () {
        //detailsProvider.getPharmaLocation(widget.pharma.latitude!, widget.pharma.longitude!);
        //Navigator.pushNamed(context, PharmacyScreen.routeName,arguments: widget.pharma);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ]
        ),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Order #${widget.order.id?.substring(0, 8) ?? '...'}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ColorManger.black,
                      decoration: widget.order.finish == true ? TextDecoration.lineThrough : null,
                      decorationColor: ColorManger.black,
                      decorationThickness: 2.0,
                    ),
                  ),
                ),
                Checkbox(
                  activeColor: ColorManger.green,
                  value: widget.order.finish ?? false, 
                  onChanged: (value) {
                    SupabaseHandler.checkOrder(value ?? false, widget.order.id ?? '');
                  },
                )
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Text(widget.order.userName ?? 'Unknown User', style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Text(widget.order.userNum ?? 'No phone number', style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.attach_money, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text("\$${widget.order.fullPrice ?? 0.0}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManger.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  if (widget.order.latitude != null && widget.order.longitude != null) {
                    final lat = widget.order.latitude;
                    final lng = widget.order.longitude;
                    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open map.')));
                      }
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No location provided for this order.')));
                    }
                  }
                },
                icon: const Icon(Icons.map),
                label: const Text('View Delivery Location on Maps'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
