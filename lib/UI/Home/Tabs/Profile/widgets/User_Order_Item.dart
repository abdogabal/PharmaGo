import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../../Models/Order.dart';
import '../../../../../Providers/DetailsProvider.dart';
import '../../../../../core/SupabaseHandler.dart';
import '../../../../../core/resources/ColorManger.dart';

class UserOrderItem extends StatefulWidget {
  final Order order;

  UserOrderItem(this.order);

  @override
  State<UserOrderItem> createState() => _UserOrderItemState();
}

class _UserOrderItemState extends State<UserOrderItem> {
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: ColorManger.white,
            ),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Order #${widget.order.id?.substring(0, 8) ?? '...'}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: ColorManger.black,
                        ),
                      ),
                    ),
                  ],
                ),
                if (widget.order.time != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM d, yyyy - h:mm a').format(widget.order.time!),
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
