import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phone_form_field/phone_form_field.dart';
import '../controllers/sign_in_controller.dart';

class SignInView extends GetView<SignInController> {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Masuk Dengan Nomor Telepon',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Anda akan menerima kode verifikasi.',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      const SizedBox(height: 24),
                      Obx(
                        () => PhoneFormField(
                          key: const ValueKey('phone_field'),
                          decoration: InputDecoration(
                            labelText: 'Nomor Telepon',
                            border: const OutlineInputBorder(),
                            hintText: '8123456789',
                            prefixIcon: const Icon(Icons.phone_android),
                            // Show error outline if we have a Firebase error
                            errorBorder:
                                controller.phoneError.isNotEmpty
                                    ? const OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                    )
                                    : null,
                          ),
                          initialValue: controller.phone.value,
                          validator: controller.phoneValidator,
                          autovalidateMode:
                              AutovalidateMode
                                  .onUserInteraction, // Always show validation
                          enabled: !controller.isLoading.value,
                          onChanged: controller.onPhoneChanged,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        controller.isValidAndNotLoading
                            ? controller.sendCode
                            : null,
                    child:
                        controller.isLoading.value
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              'Lanjutkan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
