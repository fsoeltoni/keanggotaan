import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../controllers/otp_controller.dart';

class OtpView extends GetView<OtpController> {
  const OtpView({super.key});

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
              // Header and PIN input section
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Verifikasi OTP',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Masukkan kode verifikasi yang telah dikirim ke nomor ${controller.phoneNumber}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Center(
                        child: Obx(
                          () => Pinput(
                            length: 6,
                            defaultPinTheme: PinTheme(
                              width: 56,
                              height: 56,
                              textStyle: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                            ),
                            focusedPinTheme: PinTheme(
                              width: 56,
                              height: 56,
                              textStyle: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                              ),
                            ),
                            submittedPinTheme: PinTheme(
                              width: 56,
                              height: 56,
                              textStyle: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                            ),
                            errorPinTheme: PinTheme(
                              width: 56,
                              height: 56,
                              textStyle: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red, width: 2),
                              ),
                            ),
                            // Disable PIN input during loading state or timeout
                            enabled:
                                !controller.isLoading.value &&
                                !controller.isTimeout.value,
                            onCompleted:
                                (pin) => controller.onOtpCompleted(pin),
                            onChanged: controller.onOtpChanged,
                            controller: controller.pinController,
                            focusNode: controller.focusNode,
                            onTap: () {
                              // Reset error when tapped
                              if (controller.hasError.value) {
                                controller.hasError.value = false;
                                controller.errorText.value = '';
                              }
                            },
                            autofocus: true,
                            forceErrorState: controller.hasError.value,
                            errorText:
                                controller.errorText.value.isEmpty
                                    ? null
                                    : controller.errorText.value,
                            errorTextStyle: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                            pinputAutovalidateMode:
                                PinputAutovalidateMode.onSubmit,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // "Tidak menerima kode" section or loading indicator at bottom
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Center(
                  child: Obx(
                    () =>
                        controller.isLoading.value
                            // Show circular progress indicator when loading
                            ? Text(
                              'Processing...',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            )
                            // Show "Tidak menerima kode" section when not loading
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Tidak menerima kode?',
                                  style: TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 8),
                                controller.canResend.value
                                    ? TextButton(
                                      onPressed: controller.resendOtp,
                                      child: const Text('Kirim Ulang'),
                                    )
                                    : Text(
                                      'Kirim ulang dalam ${controller.remainingTime.value}s',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                              ],
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
