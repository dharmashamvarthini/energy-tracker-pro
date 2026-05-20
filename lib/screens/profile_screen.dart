import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  final Function(bool) onDarkModeToggle;
  final Function(bool) onNotificationToggle;
  final bool isDarkMode;
  final bool notificationsEnabled;
  
  const ProfileScreen({
    super.key,
    required this.onDarkModeToggle,
    required this.onNotificationToggle,
    required this.isDarkMode,
    required this.notificationsEnabled,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _fullName = '';
  String _meterNumber = '';
  String _mobileNumber = '';
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  
  // Editing controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _meterController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fullName = prefs.getString('userName') ?? 'User';
      _meterNumber = prefs.getString('meterNumber') ?? '';
      _mobileNumber = prefs.getString('userMobile') ?? '';
      
      _nameController.text = _fullName;
      _meterController.text = _meterNumber;
      _mobileController.text = _mobileNumber;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _fullName = _nameController.text.trim().isEmpty ? 'User' : _nameController.text.trim();
      _meterNumber = _meterController.text.trim();
      _mobileNumber = _mobileController.text.trim();
      _isEditing = false;
    });
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _fullName);
    await prefs.setString('meterNumber', _meterNumber);
    await prefs.setString('userMobile', _mobileNumber);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved successfully!')),
    );
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = true;
      _nameController.text = _fullName;
      _meterController.text = _meterNumber;
      _mobileController.text = _mobileNumber;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _nameController.text = _fullName;
      _meterController.text = _meterNumber;
      _mobileController.text = _mobileNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Image Section
            GestureDetector(
              onTap: _pickImage,
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.shade100,
                      border: Border.all(color: Colors.green, width: 3),
                    ),
                    child: ClipOval(
                      child: _profileImage != null
                          ? Image.file(_profileImage!, fit: BoxFit.cover)
                          : Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.green.shade700,
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to change profile photo',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Profile Details Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full Name
                  const Text(
                    'Full Name',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (_isEditing)
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter your full name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.green, width: 2),
                        ),
                        prefixIcon: const Icon(Icons.person, color: Colors.green),
                      ),
                    )
                  else
                    Text(
                      _fullName.isEmpty ? 'Not set' : _fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  
                  const SizedBox(height: 20),
                  
                  // Meter Number
                  const Text(
                    'Meter Number',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (_isEditing)
                    TextField(
                      controller: _meterController,
                      decoration: InputDecoration(
                        hintText: 'Enter your meter number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.green, width: 2),
                        ),
                        prefixIcon: const Icon(Icons.speed, color: Colors.green),
                      ),
                    )
                  else
                    Text(
                      _meterNumber.isEmpty ? 'Not set' : _meterNumber,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  
                  const SizedBox(height: 20),
                  
                  // Mobile Number
                  const Text(
                    'Mobile Number',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (_isEditing)
                    TextField(
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'Enter your mobile number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.green, width: 2),
                        ),
                        prefixIcon: const Icon(Icons.phone, color: Colors.green),
                      ),
                    )
                  else
                    Text(
                      _mobileNumber.isEmpty ? 'Not set' : _mobileNumber,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 25),
            
            // Action Buttons
            if (_isEditing)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _cancelEditing,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey,
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Save Profile'),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _toggleEditing,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            
            const SizedBox(height: 20),
            
            // Settings Section (Dark Mode and Notifications)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.dark_mode, color: Colors.green.shade700),
                          const SizedBox(width: 12),
                          const Text('Dark Mode'),
                        ],
                      ),
                      Switch(
                        value: widget.isDarkMode,
                        onChanged: widget.onDarkModeToggle,
                        activeColor: Colors.green,
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.notifications, color: Colors.green.shade700),
                          const SizedBox(width: 12),
                          const Text('Notifications'),
                        ],
                      ),
                      Switch(
                        value: widget.notificationsEnabled,
                        onChanged: widget.onNotificationToggle,
                        activeColor: Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}