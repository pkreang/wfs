// lib/screens/create_appointment_screen.dart

import 'package:flutter/material.dart';

class CreateAppointmentScreen extends StatefulWidget {
  const CreateAppointmentScreen({super.key});

  @override
  State<CreateAppointmentScreen> createState() => _CreateAppointmentScreenState();
}

class _CreateAppointmentScreenState extends State<CreateAppointmentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ใช้สีพื้นหลังที่ใกล้เคียงกับ iOS Form
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F7),
        elevation: 0,
 
        leading: TextButton(
          onPressed: () {
            Navigator.of(context).pop(); 
          },
          child: const Text('Cancel', style: TextStyle(color: Colors.blue, fontSize: 16)),
        ),
        leadingWidth: 80,
       
        title: const Text(
          'Create Appointment',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
   
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Implement logic to save the appointment
              Navigator.of(context).pop(); 
            },
            child: const Text('Add', style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Section: CLIENT INFO
          _buildSectionHeader('CLIENT INFO'),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                _buildInfoRow('Client Name', 'John Doe'),
                _buildTappableRow('Purpose', 'Initial Visit'),
                _buildTappableRow('Territory', 'North East US', showDivider: false),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Section: Date & Time
          Container(
            color: Colors.white,
            child: Column(
              children: [
                _buildDateTimePickerRow('Starts', 'Jul 21, 2023', '9:00 AM'),
                _buildDateTimePickerRow('Ends', 'Jul 21, 2023', '10:00 AM', showDivider: false),
              ],
            ),
          ),
          const SizedBox(height: 30),
          
          // Section: Address
          Container(
            color: Colors.white,
            child: _buildAddressSection(),
          ),
          const SizedBox(height: 30),

          // Section: CONTACT
          _buildSectionHeader('CONTACT'),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                _buildContactRow('Mobile', '319-555-0115'),
                _buildContactRow('Email', 'adam.erickson@example.com'),
                _buildContactRow('Company', 'Happy Happy', showDivider: false),
              ],
            ),
          ),
           const SizedBox(height: 30),
        ],
      ),
    );
  }

  // --- Helper Widgets for building UI sections ---

  // Widget สำหรับหัวข้อของแต่ละ Section (เช่น CLIENT INFO)
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      ),
    );
  }

  // Widget สำหรับแถวข้อมูลธรรมดา (Label: Value)
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 16)),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(value, style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
              ),
            ],
          ),
          const Divider(height: 1, indent: 0, thickness: 0.5),
        ],
      ),
    );
  }

  // Widget สำหรับแถวที่กดได้ (มีลูกศร >)
  Widget _buildTappableRow(String label, String value, {bool showDivider = true}) {
    return InkWell(
      onTap: () {
        // TODO: Implement navigation or show picker for this row
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Column(
          children: [
            SizedBox(
              height: 44, // ความสูงมาตรฐานของ iOS list item
              child: Row(
                children: [
                  Text(label, style: const TextStyle(fontSize: 16)),
                  const Spacer(),
                  Text(value, style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                   const SizedBox(width: 16),
                ],
              ),
            ),
             if (showDivider) const Divider(height: 1, indent: 0, thickness: 0.5),
          ],
        ),
      ),
    );
  }

  // Widget สำหรับแถวเลือกวันที่และเวลา
  Widget _buildDateTimePickerRow(String label, String date, String time, {bool showDivider = true}) {
    return Padding(
       padding: const EdgeInsets.fromLTRB(16.0, 4, 16, 4),
      child: Column(
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 16)),
              const Spacer(),
              _buildDateTimeChip(date),
              const SizedBox(width: 8),
              _buildDateTimeChip(time),
            ],
          ),
          if (showDivider) const Divider(height: 1, indent: 0, thickness: 0.5),
        ],
      ),
    );
  }

  // Chip แสดงวันที่/เวลา
  Widget _buildDateTimeChip(String text) {
    return GestureDetector(
      onTap: () {
        // TODO: Implement date/time picker logic
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text, style: const TextStyle(fontSize: 15)),
      ),
    );
  }

  // Widget สำหรับ Section ที่อยู่
  Widget _buildAddressSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16.0, top: 12.0),
          child: Text('Address', style: TextStyle(fontSize: 16, color: Colors.blue)),
        ),
        Expanded(
          child: Column(
            children: [
              _buildAddressTextField('2118 Thornridge'),
              const Divider(height: 1, indent: 0, thickness: 0.5),
              _buildAddressTextField('Street'),
              const Divider(height: 1, indent: 0, thickness: 0.5),
              _buildAddressTextField('Cir. Syracuse'),
              const Divider(height: 1, indent: 0, thickness: 0.5),
              Row(
                children: [
                  Expanded(child: _buildAddressTextField('Connecticut')),
                  Container(width: 0.5, height: 44, color: Colors.grey.shade300),
                  SizedBox(
                    width: 100,
                    child: _buildAddressTextField('35624'),
                  ),
                ],
              ),
              const Divider(height: 1, indent: 0, thickness: 0.5),
              _buildAddressTextField('USA'),
            ],
          ),
        ),
      ],
    );
  }

  // TextField สำหรับกรอกที่อยู่
  Widget _buildAddressTextField(String hint) {
    return SizedBox(
      height: 44,
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
  
  // Widget สำหรับแถวข้อมูล Contact (มีปุ่ม x)
  Widget _buildContactRow(String label, String value, {bool showDivider = true}) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Column(
        children: [
           SizedBox(
              height: 44,
              child: Row(
                children: [
                  Text(label, style: const TextStyle(fontSize: 16)),
                  const Spacer(),
                  Text(value, style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
                  IconButton(
                    onPressed: () {
                      // TODO: Implement remove contact logic
                    },
                    icon: Icon(Icons.cancel, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
          if (showDivider) const Divider(height: 1, indent: 0, thickness: 0.5),
        ],
      ),
    );
  }
}