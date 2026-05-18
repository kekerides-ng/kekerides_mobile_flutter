import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vehicle.dart';
import '../stores/vehicle_store.dart';

class VehicleFormScreen extends ConsumerStatefulWidget {
  final Vehicle? vehicle;
  const VehicleFormScreen({super.key, this.vehicle});

  @override
  ConsumerState<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends ConsumerState<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedType;
  late TextEditingController _plateController;
  late TextEditingController _colorController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;

  final List<String> _vehicleTypes = ['keke', 'bike'];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.vehicle?.type;
    _plateController = TextEditingController(text: widget.vehicle?.plateNumber ?? '');
    _colorController = TextEditingController(text: widget.vehicle?.color ?? '');
    _modelController = TextEditingController(text: widget.vehicle?.model ?? '');
    _yearController = TextEditingController(
        text: widget.vehicle != null ? widget.vehicle!.year.toString() : '');
  }

  @override
  void dispose() {
    _plateController.dispose();
    _colorController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType == null) return;

    final notifier = ref.read(vehicleProvider.notifier);
    final success = widget.vehicle == null
        ? await notifier.createVehicle(
            type: _selectedType!,
            plateNumber: _plateController.text,
            color: _colorController.text,
            model: _modelController.text,
            year: int.tryParse(_yearController.text) ?? 0,
          )
        : await notifier.updateVehicle(
            widget.vehicle!.id!,
            {
              'type': _selectedType!,
              'plateNumber': _plateController.text,
              'color': _colorController.text,
              'model': _modelController.text,
              'year': int.tryParse(_yearController.text) ?? 0,
            },
          );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.vehicle == null
              ? 'Vehicle added successfully'
              : 'Vehicle updated successfully'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(vehicleProvider).isLoading;
    final errorMessage = ref.watch(vehicleProvider).errorMessage;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vehicle == null ? 'Add Vehicle' : 'Edit Vehicle'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(errorMessage, style: const TextStyle(color: Colors.red)),
                ),
              _buildDropdownField('Vehicle Type', _selectedType, _vehicleTypes, (val) {
                setState(() => _selectedType = val);
              }),
              const SizedBox(height: 16),
              _buildTextField('Plate Number', _plateController, capitalization: TextCapitalization.characters),
              const SizedBox(height: 16),
              _buildTextField('Color', _colorController),
              const SizedBox(height: 16),
              _buildTextField('Model', _modelController),
              const SizedBox(height: 16),
              _buildTextField('Year', _yearController, keyboardType: TextInputType.number),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBF5102),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(widget.vehicle == null ? 'ADD VEHICLE' : 'UPDATE VEHICLE',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType? keyboardType, TextCapitalization capitalization = TextCapitalization.none}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: capitalization,
          inputFormatters: capitalization == TextCapitalization.characters
              ? [UpperCaseTextFormatter()]
              : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (value) => value == null || value.isEmpty ? 'This field is required' : null,
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type[0].toUpperCase() + type.substring(1)),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (value) => value == null || value.isEmpty ? 'Please select a vehicle type' : null,
        ),
      ],
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
