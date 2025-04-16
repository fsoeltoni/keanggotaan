import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keanggotaan/initial_binding.dart';

import 'app/routes/app_pages.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Keanggotaan",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
      initialBinding: InitialBinding(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
