import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/modules/admin/widgets/shared/admin_card_container.dart';
import 'package:frontend/modules/admin/widgets/shared/admin_dropdown_field.dart';
import 'package:frontend/modules/admin/widgets/shared/admin_page_header.dart';
import 'package:frontend/modules/admin/widgets/shared/admin_text_field.dart';
import 'package:flutter/material.dart';

class UserRegistration extends StatefulWidget {
  const UserRegistration({super.key});

  @override
  State<UserRegistration> createState() => _UserRegistrationState();
}

class _UserRegistrationState extends State<UserRegistration> {
  final _formKey = GlobalKey<FormState>();

  String? selectedRole;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AdminPageHeader(
              title: "User Registration",
              subtitle: "Create new users and assign system roles",
            ),
            const SizedBox(height: 30),
            AdminCardContainer(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AdminTextField(
                            topLabel: "Full Name",
                            hintText: "Enter full name",
                            controller: nameController,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: AdminTextField(
                            topLabel: "Email",
                            hintText: "Enter email",
                            controller: emailController,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: AdminTextField(
                            topLabel: "Phone",
                            hintText: "Enter phone number",
                            controller: phoneController,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: AdminDropdownField<String>(
                            label: "Role",
                            value: selectedRole,
                            items: const [
                              DropdownMenuItem(
                                value: "admin",
                                child: Text("Admin"),
                              ),
                              DropdownMenuItem(
                                value: "user",
                                child: Text("User"),
                              ),
                              DropdownMenuItem(
                                value: "doctor",
                                child: Text("Doctor"),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedRole = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    AdminTextField(
                      topLabel: "Password",
                      hintText: "Enter password",
                      obscureText: true,
                      controller: passwordController,
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: 500,
                      height: 45,
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.person_add_alt_1,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Register User",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            print(nameController.text);
                            print(emailController.text);
                            print(phoneController.text);
                            print(selectedRole);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
