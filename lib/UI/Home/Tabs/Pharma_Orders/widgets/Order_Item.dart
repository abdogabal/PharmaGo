import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
        final itemsFuture = SupabaseHandler.getMedicinesForOrder(widget.order.id ?? '');
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) {
            return FutureBuilder(
              future: itemsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 80, color: Colors.teal.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text(
                          'No items found',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This might be an older order.',
                          style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Details',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: ColorManger.black),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person, color: Colors.grey.shade600, size: 18),
                              const SizedBox(width: 8),
                              Expanded(child: Text('Customer: ${widget.order.userName ?? "Unknown"}', style: TextStyle(fontSize: 16, color: Colors.grey.shade800), overflow: TextOverflow.ellipsis, maxLines: 1)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.local_pharmacy, color: Colors.teal.shade400, size: 18),
                              const SizedBox(width: 8),
                              Expanded(child: Text('Pharmacy: ${widget.order.pharmaName ?? "Unknown"}', style: TextStyle(fontSize: 16, color: Colors.grey.shade800, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 1)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      if (widget.order.latitude != null && widget.order.longitude != null)
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: AbsorbPointer(
                              absorbing: true,
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(widget.order.latitude!, widget.order.longitude!),
                                  zoom: 14,
                                ),
                                markers: {
                                  Marker(
                                    markerId: const MarkerId('orderLoc'),
                                    position: LatLng(widget.order.latitude!, widget.order.longitude!),
                                  )
                                },
                                zoomControlsEnabled: false,
                                scrollGesturesEnabled: false,
                                tiltGesturesEnabled: false,
                                rotateGesturesEnabled: false,
                                zoomGesturesEnabled: false,
                                mapToolbarEnabled: false,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 15),
                      const Divider(),
                      Expanded(
                        child: ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final medic = items[index];
                            return ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.teal.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.medical_services, color: Colors.teal)
                              ),
                              title: Text(medic.name ?? 'Unknown Medicine', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              subtitle: Text('Qty: ${medic.quantity?.toInt() ?? 1}', style: TextStyle(color: Colors.grey.shade600)),
                              trailing: Text('\$${medic.price ?? 0.0}', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 18)),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
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
                      if (widget.order.time != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 12, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('MMM d, yyyy - h:mm a').format(widget.order.time!),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                decoration: widget.order.finish == true ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Checkbox(
                  activeColor: ColorManger.green,
                  value: widget.order.finish ?? false, 
                  onChanged: (value) {
                    setState(() {
                      widget.order.finish = value;
                    });
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
                    
                    final geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
                    final webUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
                    
                    if (await canLaunchUrl(geoUri)) {
                      await launchUrl(geoUri);
                    } else if (await canLaunchUrl(webUri)) {
                      await launchUrl(webUri, mode: LaunchMode.externalApplication);
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
