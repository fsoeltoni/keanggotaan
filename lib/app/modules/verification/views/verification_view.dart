import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/verification_controller.dart';

class VerificationView extends GetView<VerificationController> {
  const VerificationView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VerificationView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'VerificationView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
