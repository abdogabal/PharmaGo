import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../../Core/resources/StringsManger.dart';
import '../../../../../Models/Medicines.dart';
import '../../../../../Providers/UserProvider.dart';
import '../../../../../core/DialogUtils.dart';
import '../../../../../core/SupabaseHandler.dart';
import '../../../../../core/Reusable_component/CustomButton.dart';
import '../../../../../core/Reusable_component/CustomTextField.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditScreen extends StatefulWidget {
  static const String routeName = 'edit';

  const EditScreen({super.key});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late Medic medic;
  late TextEditingController nameController;
  late TextEditingController activeIngredientController;
  late TextEditingController priceController;
  late TextEditingController quantityController;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController = TextEditingController();
    activeIngredientController = TextEditingController();
    priceController = TextEditingController();
    quantityController = TextEditingController();

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameController.dispose();
    activeIngredientController.dispose();
    priceController.dispose();
    quantityController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    medic = ModalRoute.of(context)!.settings.arguments as Medic;
    UserProvider userProvider = Provider.of<UserProvider>(context);
    nameController.text = medic.name ?? '';
    activeIngredientController.text = medic.activeIngredient ?? '';
    priceController.text = medic.price.toString();
    quantityController.text = medic.quantity.toString();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          StringsManger.edit.tr(),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.all(24),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  SizedBox(height: 24.h),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 120.h,
                      width: 120.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.file(_selectedImage!, fit: BoxFit.cover),
                            )
                          : (medic.imageUrl != null && medic.imageUrl!.isNotEmpty)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(medic.imageUrl!, fit: BoxFit.cover),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, color: Colors.grey.shade500, size: 40),
                                    SizedBox(height: 8.h),
                                    Text('Change Image', style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp)),
                                  ],
                                ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  CustomTextField(
                    validate: (value) {
                      if (value == null || value.isEmpty) {
                        return StringsManger.wrong.tr();
                      }
                      return null;
                    },
                    controller: nameController,
                    hint: StringsManger.medName.tr(),
                    prefixIcon: '',
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: 16.h),
                  CustomTextField(
                    validate: (value) {
                      if (value == null || value.isEmpty) {
                        return StringsManger.wrong.tr();
                      }
                      return null;
                    },
                    controller: activeIngredientController,
                    hint: 'Active Ingredient',
                    prefixIcon: '',
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: 16.h),
                  CustomTextField(
                    validate: (value) {
                      if (value == null || value.isEmpty) {
                        return StringsManger.wrong.tr();
                      }
                      return null;
                    },
                    controller: priceController,
                    hint: StringsManger.price.tr(),
                    prefixIcon: '',
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16.h),
                  CustomTextField(
                    validate: (value) {
                      if (value == null || value.isEmpty) {
                        return StringsManger.wrong.tr();
                      }
                      return null;
                    },
                    controller: quantityController,
                    hint: StringsManger.quantity.tr(),
                    prefixIcon: '',
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    width: double.infinity,
                    child: CustomButton(
                      title: StringsManger.edit.tr(),
                      onClick: () async {
                        if (formKey.currentState?.validate() ?? false) {
                          try {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (c) => const Center(child: CircularProgressIndicator()),
                            );

                            String? uploadedUrl = medic.imageUrl;
                            if (_selectedImage != null) {
                              String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
                              uploadedUrl = await SupabaseHandler.uploadMedicineImage(_selectedImage!, fileName);
                            }

                            await SupabaseHandler.editMedic(
                              Medic(
                                id: medic.id,
                                name: nameController.text,
                                activeIngredient: activeIngredientController.text,
                                price: double.tryParse(
                                  priceController.text ?? '',
                                ),
                                quantity: double.tryParse(
                                  quantityController.text ?? '',
                                ),
                                imageUrl: uploadedUrl,
                              ),
                              userProvider.myUser?.pharma ?? '',
                            );

                            Navigator.pop(context); // close loading
                            DialogUtils.showSnackBar(
                              StringsManger.success.tr(),
                            );
                            Navigator.pop(context); // close screen
                          } catch (error) {
                            Navigator.pop(context);
                            DialogUtils.showSnackBar(error.toString());
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
