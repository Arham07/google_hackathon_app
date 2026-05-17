import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_hackathon_app/core/api/api_exception.dart';
import 'package:google_hackathon_app/core/api/user_reports_api.dart';
import 'package:google_hackathon_app/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';

class SubmitIncidentScreen extends StatefulWidget {
  const SubmitIncidentScreen({super.key});

  static const double demoLat = 24.8923;
  static const double demoLng = 67.1984;

  @override
  State<SubmitIncidentScreen> createState() => _SubmitIncidentScreenState();
}

class _SubmitIncidentScreenState extends State<SubmitIncidentScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _cityController = TextEditingController(text: 'Karachi');
  final TextEditingController _areaController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final UserReportsApi _reportsApi = UserReportsApi();

  XFile? _photo;
  bool _submitting = false;

  @override
  void dispose() {
    _textController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _photo = file);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      final UserReportSubmitResponse result = await _reportsApi.submitReport(
        text: _textController.text.trim(),
        lat: SubmitIncidentScreen.demoLat,
        lng: SubmitIncidentScreen.demoLng,
        city: _cityController.text.trim(),
        area: _areaController.text.trim(),
        photoPath: _photo?.path,
      );

      if (!mounted) return;
      setState(() => _submitting = false);

      final String message = result.isDuplicate
          ? 'A similar report already exists nearby.'
          : result.eventId != null
              ? 'Thank you. Report submitted (ID: ${result.eventId!.substring(0, 24)}…).'
              : 'Thank you. Your incident report was received.';

      await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(result.isDuplicate ? 'Duplicate report' : 'Report received'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (!result.isDuplicate) {
                    _textController.clear();
                    _areaController.clear();
                    setState(() => _photo = null);
                  }
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submit failed. Check server and try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report incident')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppColors.radius),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.pin_drop, color: AppColors.mapAccent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Demo location (fixed)',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.mutedForeground,
                                ),
                          ),
                          Text(
                            '${SubmitIncidentScreen.demoLat}, ${SubmitIncidentScreen.demoLng}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontFamily: 'monospace',
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _textController,
                maxLines: 5,
                maxLength: 4000,
                decoration: const InputDecoration(
                  labelText: 'What happened? *',
                  hintText: 'Describe the hazard, location landmarks, and urgency…',
                  alignLabelWithHint: true,
                ),
                validator: (String? value) {
                  if (value == null || value.trim().length < 10) {
                    return 'Please provide at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  prefixIcon: Icon(Icons.location_city_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _areaController,
                decoration: const InputDecoration(
                  labelText: 'Area / neighbourhood',
                  prefixIcon: Icon(Icons.map_outlined),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _pickPhoto,
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(_photo == null ? 'Add photo (optional)' : 'Change photo'),
              ),
              if (_photo != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppColors.radius),
                  child: Image.file(
                    File(_photo!.path),
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
