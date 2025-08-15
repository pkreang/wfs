import 'package:flutter/material.dart';

class AppointmentFormPage extends StatefulWidget {
  const AppointmentFormPage({super.key});

  @override
  State<AppointmentFormPage> createState() => _AppointmentFormPageState();
}

class _AppointmentFormPageState extends State<AppointmentFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final appointmentTitleController = TextEditingController();
  final notedController = TextEditingController();

  // Dropdown selections
  String? appointmentTypeID;
  String? appointmentStatusID;
  String? purposeTypeID;

  // DateTime selections
  DateTime? dateTimeFrom;
  DateTime? dateTimeTo;

  // Checkbox
  bool isActive = false;

  // Product selection (multi-choice)
  List<String> allProducts = ["Product A", "Product B", "Product C"];
  List<String> selectedProducts = [];

  // Function to pick date & time
  Future<void> _pickDateTime(bool isFrom) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 9, minute: 0),
      );
      if (pickedTime != null) {
        DateTime fullDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          if (isFrom) {
            dateTimeFrom = fullDateTime;
          } else {
            dateTimeTo = fullDateTime;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Appointment Form")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title
              TextFormField(
                controller: appointmentTitleController,
                decoration: const InputDecoration(
                  labelText: "Appointment Title",
                ),
                validator: (v) => v!.isEmpty ? "กรุณากรอกชื่อ" : null,
              ),

              // Appointment Type
              DropdownButtonFormField<String>(
                value: appointmentTypeID,
                decoration: const InputDecoration(
                  labelText: "Appointment Type",
                ),
                items: ["Meeting", "Call", "Visit"].map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) => setState(() => appointmentTypeID = value),
              ),

              // Status
              DropdownButtonFormField<String>(
                value: appointmentStatusID,
                decoration: const InputDecoration(labelText: "Status"),
                items: ["Pending", "Confirmed", "Completed", "Cancelled"]
                    .map(
                      (status) =>
                          DropdownMenuItem(value: status, child: Text(status)),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => appointmentStatusID = value),
              ),

              // // Purpose Type
              DropdownButtonFormField<String>(
                value: purposeTypeID,
                decoration: const InputDecoration(labelText: "Purpose"),
                items: ["Sales", "Support", "Other"].map((purpose) {
                  return DropdownMenuItem(value: purpose, child: Text(purpose));
                }).toList(),
                onChanged: (value) => setState(() => purposeTypeID = value),
              ),

              // DateTime From
              ListTile(
                title: Text(
                  dateTimeFrom == null
                      ? "Select Start Date & Time"
                      : "From: ${dateTimeFrom.toString()}",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDateTime(true),
              ),

              // DateTime To
              ListTile(
                title: Text(
                  dateTimeTo == null
                      ? "Select End Date & Time"
                      : "To: ${dateTimeTo.toString()}",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDateTime(false),
              ),

              // Noted
              TextFormField(
                controller: notedController,
                decoration: const InputDecoration(labelText: "Notes"),
                maxLines: 3,
              ),

              // Product selection
              const SizedBox(height: 10),
              const Text("Select Products"),
              Wrap(
                spacing: 8,
                children: allProducts.map((product) {
                  return FilterChip(
                    label: Text(product),
                    selected: selectedProducts.contains(product),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedProducts.add(product);
                        } else {
                          selectedProducts.remove(product);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              // Active status
              SwitchListTile(
                title: const Text("Active"),
                value: isActive,
                onChanged: (val) => setState(() => isActive = val),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Save data here
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Saved successfully")),
                    );
                  }
                },
                child: const Text("Save Appointment"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
