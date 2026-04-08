// lib/modules/admin/screens/doctor_registration/steps/basic_information_page.dart
//
// Syncs picked profile photo path to controller.profilePhotoPath.

import 'dart:io';
import 'package:frontend/modules/admin/controllers/registration_controller.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:frontend/modules/admin/widgets/shared/admin_text_field.dart';

class BasicInformationStep extends StatefulWidget {
  final RegistrationController controller;

  const BasicInformationStep({super.key, required this.controller});

  @override
  State<BasicInformationStep> createState() => _BasicInformationStepState();
}

class _BasicInformationStepState extends State<BasicInformationStep> {
  File? _profileImage;
  String _selectedGender = '';
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _profileImage = File(image.path));
      widget.controller.profilePhotoPath = image.path;
    }
  }

  Future<void> _pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      widget.controller.dob.text = DateFormat('dd MMM yyyy').format(date);
      setState(() {});
    }
  }

  Widget _genderTabs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gender', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              _genderOption('Male', Icons.male),
              _genderOption('Female', Icons.female),
            ],
          ),
        ),
      ],
    );
  }

  Widget _genderOption(String value, IconData icon) {
    final selected = _selectedGender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedGender = value);
          widget.controller.gender.text = value;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: selected ? Colors.white : Colors.black54),
              const SizedBox(width: 6),
              Text(
                value,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Basic Information',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Provide general personal information of the doctor.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // Profile Photo
          const Text('Profile Photo'),
          const SizedBox(height: 10),
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : null,
                child: _profileImage == null
                    ? const Icon(Icons.camera_alt, size: 30)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 25),

          // Full Name + Email
          Row(
            children: [
              Expanded(
                child: AdminTextField(
                  controller: widget.controller.fullName,
                  label: 'Full Name',
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: AdminTextField(
                  controller: widget.controller.email,
                  label: 'Email',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Phone + Password
          Row(
            children: [
              Expanded(
                child: AdminTextField(
                  controller: widget.controller.phone,
                  label: 'Phone Number',
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: AdminTextField(
                  controller: widget.controller.password,
                  obscureText: true,
                  label: 'Password',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Gender + DOB
          Row(
            children: [
              Expanded(child: _genderTabs()),
              const SizedBox(width: 20),
              Expanded(
                child: AdminTextField(
                  controller: widget.controller.dob,
                  readOnly: true,
                  label: 'Date of Birth',
                  suffixIcon: const Icon(Icons.calendar_today),
                  onTap: _pickDate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Address
          AdminTextField(
            controller: widget.controller.address,
            label: 'Address',
          ),
          const SizedBox(height: 20),

          // City + State
          Row(
            children: [
              Expanded(
                child: AdminTextField(
                  controller: widget.controller.city,
                  label: 'City',
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: AdminTextField(
                  controller: widget.controller.state,
                  label: 'State',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Country + Pincode
          Row(
            children: [
              Expanded(
                child: AdminTextField(
                  controller: widget.controller.country,
                  label: 'Country',
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: AdminTextField(
                  controller: widget.controller.pincode,
                  label: 'Pincode',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
