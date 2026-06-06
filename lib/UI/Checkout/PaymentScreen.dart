import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../Providers/CartProvider.dart';
import '../../../Models/Order.dart' as pharmaOrder;
import '../../../Models/Medicines.dart';
import '../../../core/SupabaseHandler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../Providers/MapPickerProvider.dart';

class PaymentScreen extends StatefulWidget {
  static const String routeName = "payment-screen";

  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool isPayOnDelivery = false;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          "checkout".tr(),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ChoiceChip(
                            label: Text("Credit Card"),
                            selected: !isPayOnDelivery,
                            onSelected: (val) => setState(() => isPayOnDelivery = false),
                            selectedColor: Colors.teal.shade200,
                          ),
                          const SizedBox(width: 20),
                          ChoiceChip(
                            label: Text("Pay on Delivery"),
                            selected: isPayOnDelivery,
                            onSelected: (val) => setState(() => isPayOnDelivery = true),
                            selectedColor: Colors.teal.shade200,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (!isPayOnDelivery) ...[
                        _buildCreditCardPreview(),
                      const SizedBox(height: 30),
                      Text(
                        "cardDetails".tr(),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        label: "cardNumber".tr(),
                        hint: "XXXX XXXX XXXX XXXX",
                        icon: Icons.credit_card,
                        keyboardType: TextInputType.number,
                        onChanged: (value) => setState(() => cardNumber = value),
                        maxLength: 16,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        label: "cardHolderName".tr(),
                        hint: "John Doe",
                        icon: Icons.person_outline,
                        onChanged: (value) => setState(() => cardHolderName = value),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              label: "expiryDate".tr(),
                              hint: "MM/YY",
                              icon: Icons.calendar_today_outlined,
                              keyboardType: TextInputType.datetime,
                              onChanged: (value) => setState(() => expiryDate = value),
                              maxLength: 5,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildTextField(
                              label: "cvv".tr(),
                              hint: "XXX",
                              icon: Icons.lock_outline,
                              keyboardType: TextInputType.number,
                              onChanged: (value) => setState(() => cvvCode = value),
                              maxLength: 3,
                              obscureText: true,
                            ),
                          ),
                        ],
                      ),
                      ],
                      if (isPayOnDelivery) 
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40.0),
                            child: Column(
                              children: [
                                Icon(Icons.delivery_dining, size: 80, color: Colors.teal),
                                SizedBox(height: 20),
                                Text(
                                  "You will pay when the order arrives at your location.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "totalPayable".tr(),
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        Text(
                          "\$${cart.totalAmount.toStringAsFixed(2)}",
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          if (isPayOnDelivery || formKey.currentState!.validate()) {
                            _processPayment(context, cart);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "payNow".tr(),
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCardPreview() {
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF004D40), Color(0xFF009688)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.payment, color: Colors.white, size: 40),
              Text(
                "PharmaGo",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          Text(
            cardNumber.isEmpty ? "XXXX XXXX XXXX XXXX" : cardNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              letterSpacing: 2,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "CARDHOLDER",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    cardHolderName.isEmpty ? "JOHN DOE" : cardHolderName.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "EXPIRES",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    expiryDate.isEmpty ? "MM/YY" : expiryDate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    int? maxLength,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        counterText: "",
        prefixIcon: Icon(icon, color: Colors.teal),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLength: maxLength,
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'requiredField'.tr();
        }
        return null;
      },
    );
  }

  void _processPayment(BuildContext context, CartProvider cart) async {
    // Show a loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.teal),
      ),
    );

    try {
      final userAuth = Supabase.instance.client.auth.currentUser;
      if (userAuth == null) throw Exception("User not logged in");

      // Verify and fetch explicit location
      final mapProvider = Provider.of<MapPickerProvider>(context, listen: false);
      
      // Attempt to enforce location fetch
      await mapProvider.getLocation();

       // Verify we actually have a valid location before proceeding
      if (mapProvider.cameraPosition.target.latitude == 0 && mapProvider.cameraPosition.target.longitude == 0 || 
          mapProvider.cameraPosition.target.latitude == 37.42796133580664) {
        throw Exception("Please grant location permissions to place an order.");
      }

      final userData = await SupabaseHandler.getUser(userAuth.id);
      
      String currentPharmaId = cart.currentPharmaId ?? "";
      final pharmaData = await Supabase.instance.client
          .from('pharmacies')
          .select()
          .eq('id', currentPharmaId)
          .maybeSingle();

      String pName = pharmaData?['title'] ?? "Unknown Pharmacy";
      String pNum = pharmaData?['phone'] ?? "";

      final newOrder = pharmaOrder.Order(
        userID: userAuth.id,
        userName: userData?.name ?? "Unknown",
        userNum: userData?.number ?? "",
        pharmaID: currentPharmaId,
        pharmaName: pName,
        pharmaNum: pNum,
        latitude: mapProvider.cameraPosition.target.latitude,
        longitude: mapProvider.cameraPosition.target.longitude,
        fullPrice: cart.totalAmount,
        finish: false,
        time: DateTime.now(),
        isPrescription: false,
      );

      // Create a list of Medic items from cart
      List<Medic> itemsToOrder = [];
      cart.items.forEach((key, cartItem) {
        // Build a Medic object mapped from cart properties
        itemsToOrder.add(
          Medic(
            id: cartItem.medic.id,
            name: cartItem.medic.name,
            price: cartItem.medic.price,
            quantity: cartItem.quantity.toDouble(), // store ordered quantity here temporarily
          )
        );
      });

      // Submit to Supabase
      await SupabaseHandler.makeOrder(newOrder, itemsToOrder);

      Navigator.pop(context); // Close loading dialog
      
      // Clear cart
      cart.clearCart();

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.teal, size: 80),
              const SizedBox(height: 20),
              Text(
                "paymentSuccess".tr(),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "orderPlacedSuccess".tr(),
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // pop dialog
                    Navigator.pop(context); // pop Payment screen back to Cart
                    Navigator.pop(context); // pop Cart screen back to Home
                  },
                  child: Text("done".tr(), style: const TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // pop loader
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error placing order: $e")));
    }
  }
}
