import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_hackathon_app/core/api/api_exception.dart';
import 'package:google_hackathon_app/core/api/user_reports_api.dart';
import 'package:google_hackathon_app/theme/app_colors.dart';
import 'package:google_hackathon_app/theme/app_dimens.dart';
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
        padding: EdgeInsets.all(AppDimens.space16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(AppDimens.space14),
                decoration: BoxDecoration(
                  color: AppColors.glassPanel,
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.pin_drop, color: AppColors.mapAccent),
                    SizedBox(width: AppDimens.space12),
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
              SizedBox(height: AppDimens.space20),
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
              SizedBox(height: AppDimens.space16),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  prefixIcon: Icon(Icons.location_city_outlined),
                ),
              ),
              SizedBox(height: AppDimens.space16),
              TextFormField(
                controller: _areaController,
                decoration: const InputDecoration(
                  labelText: 'Area / neighbourhood',
                  prefixIcon: Icon(Icons.map_outlined),
                ),
              ),
              SizedBox(height: AppDimens.space20),
              OutlinedButton.icon(
                onPressed: _pickPhoto,
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(_photo == null ? 'Add photo (optional)' : 'Change photo'),
              ),
              if (_photo != null) ...[
                SizedBox(height: AppDimens.space12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  child: Image.file(
                    File(_photo!.path),
                    height: AppDimens.photoPreviewHeight,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              SizedBox(height: AppDimens.space28),
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? SizedBox(
                        height: 22.w,
                        width: 22.w,
                        child: const CircularProgressIndicator(strokeWidth: 2),
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
