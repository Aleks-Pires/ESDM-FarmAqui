import 'package:flutter/material.dart';

import '../../../medication/presentation/pages/home_page.dart';
import '../controllers/auth_controller.dart';

final class AuthenticatedView extends StatelessWidget {
  const AuthenticatedView({required this.controller, super.key});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return HomePage(onLogout: controller.logout);
  }
}
