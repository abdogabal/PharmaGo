import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../../Core/resources/StringsManger.dart';
import '../../../../../Models/Medicines.dart';
import '../../../../../Providers/UserProvider.dart';
import '../../../../../core/DialogUtils.dart';
import '../../../../../core/FirestoreHandler.dart';
import '../../../../../core/Reusable_component/CustomButton.dart';
import '../../../../../core/Reusable_component/CustomTextField.dart';

class EditScreen extends StatefulWidget {
  static const String routeName = 'edit';

  const EditScreen({super.key});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late Medic medic;
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController quantityController;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController = TextEditingController();
    priceController = TextEditingController();
    quantityController = TextEditingController();

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameController.dispose();
    priceController.dispose();
    quantityController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    medic = ModalRoute.of(context)!.settings.arguments as Medic;
    UserProvider userProvider = Provider.of<UserProvider>(context);
    nameController.text = medic.name ?? '';
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
                            await FirestoreHandler.editMedic(
                              Medic(
                                id: medic.id,
                                name: nameController.text,
                                price: double.tryParse(
                                  priceController.text ?? '',
                                ),
                                quantity: double.tryParse(
                                  quantityController.text ?? '',
                                ),
                              ),
                              userProvider.myUser?.pharma ?? '',
                            );

                            DialogUtils.showSnackBar(
                              StringsManger.success.tr(),
                            );
                            Navigator.pop(context);
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
