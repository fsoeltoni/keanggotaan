import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/create_account_controller.dart';

class CreateAccountView extends GetView<CreateAccountController> {
  const CreateAccountView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CreateAccountView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'CreateAccountView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
