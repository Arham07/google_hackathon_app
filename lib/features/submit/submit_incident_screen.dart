import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_hackathon_app/core/api/api_exception.dart';
import 'package:google_hackathon_app/core/api/user_reports_api.dart';
import 'package:google_hackathon_app/features/submit/location_picker_screen.dart';
import 'package:google_hackathon_app/theme/app_colors.dart';
import 'package:google_hackathon_app/theme/app_dimens.dart';
import 'package:google_hackathon_app/theme/app_text_styles.dart';
import 'package:image_picker/image_picker.dart';

class SubmitIncidentScreen extends StatefulWidget {
  const SubmitIncidentScreen({super.key});

  @override
  State<SubmitIncidentScreen> createState() => _SubmitIncidentScreenState();
}

class _SubmitIncidentScreenState extends State<SubmitIncidentScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final UserReportsApi _reportsApi = UserReportsApi();

  XFile? _photo;
  bool _submitting = false;

  /// Selected location from the map picker.
  PickedLocation? _pickedLocation;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // ── Photo picking (gallery or camera) ─────────────────────────────────

  Future<void> _pickPhoto() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusXl),
        ),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: AppDimens.space16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: AppDimens.space16),
                  decoration: BoxDecoration(
                    color: AppColors.glassBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Add Photo',
                  style: AppTextStyles.sectionTitle,
                ),
                SizedBox(height: AppDimens.space16),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(AppDimens.space10),
                    decoration: BoxDecoration(
                      color: AppColors.mapAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        color: AppColors.mapAccent),
                  ),
                  title: const Text('Take a photo'),
                  subtitle: Text(
                    'Use your camera to capture the incident',
                    style: AppTextStyles.caption,
                  ),
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                ),
                SizedBox(height: AppDimens.space4),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(AppDimens.space10),
                    decoration: BoxDecoration(
                      color: AppColors.chart4.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    ),
                    child: const Icon(Icons.photo_library_rounded,
                        color: AppColors.chart4),
                  ),
                  title: const Text('Choose from gallery'),
                  subtitle: Text(
                    'Select an existing photo from your device',
                    style: AppTextStyles.caption,
                  ),
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                ),
                SizedBox(height: AppDimens.space8),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;

    final XFile? file = await _picker.pickImage(source: source);
    if (file != null) {
      setState(() => _photo = file);
    }
  }

  // ── Location picker ───────────────────────────────────────────────────

  Future<void> _openLocationPicker() async {
    final PickedLocation? result = await Navigator.of(context).push<PickedLocation>(
      MaterialPageRoute<PickedLocation>(
        builder: (_) => LocationPickerScreen(
          initialLocation: _pickedLocation,
        ),
      ),
    );

    if (result != null) {
      setState(() => _pickedLocation = result);
    }
  }

  // ── Submit ────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pickedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location on the map first.'),
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final UserReportSubmitResponse result = await _reportsApi.submitReport(
        text: _textController.text.trim(),
        lat: _pickedLocation!.latitude,
        lng: _pickedLocation!.longitude,
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
            title: Text(
                result.isDuplicate ? 'Duplicate report' : 'Report received'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (!result.isDuplicate) {
                    _textController.clear();
                    setState(() {
                      _photo = null;
                      _pickedLocation = null;
                    });
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
        const SnackBar(
            content: Text('Submit failed. Check server and try again.')),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────

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
              // ── Location selector ──
              _buildLocationCard(),
              SizedBox(height: AppDimens.space20),

              // ── Description ──
              TextFormField(
                controller: _textController,
                maxLines: 5,
                maxLength: 4000,
                decoration: const InputDecoration(
                  labelText: 'What happened? *',
                  hintText:
                      'Describe the hazard, location landmarks, and urgency…',
                  alignLabelWithHint: true,
                ),
                validator: (String? value) {
                  if (value == null || value.trim().length < 10) {
                    return 'Please provide at least 10 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppDimens.space20),

              // ── Photo ──
              _buildPhotoSection(),
              SizedBox(height: AppDimens.space28),

              // ── Submit button ──
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? SizedBox(
                        height: 22.w,
                        width: 22.w,
                        child:
                            const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit report'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    final bool hasLocation = _pickedLocation != null;

    return GestureDetector(
      onTap: _openLocationPicker,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.all(AppDimens.space14),
        decoration: BoxDecoration(
          color: hasLocation
              ? AppColors.mapAccent.withValues(alpha: 0.08)
              : AppColors.glassPanel,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(
            color: hasLocation
                ? AppColors.mapAccent.withValues(alpha: 0.4)
                : AppColors.glassBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppDimens.space10),
              decoration: BoxDecoration(
                color: hasLocation
                    ? AppColors.mapAccent.withValues(alpha: 0.15)
                    : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              ),
              child: Icon(
                hasLocation ? Icons.pin_drop : Icons.add_location_alt_outlined,
                color: hasLocation
                    ? AppColors.mapAccent
                    : AppColors.textSecondary,
                size: 22,
              ),
            ),
            SizedBox(width: AppDimens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: hasLocation
                    ? [
                        if (_pickedLocation!.address != null)
                          Text(
                            _pickedLocation!.address!,
                            style: AppTextStyles.bodySecondary,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        Text(
                          '${_pickedLocation!.latitude.toStringAsFixed(6)}, ${_pickedLocation!.longitude.toStringAsFixed(6)}',
                          style: AppTextStyles.mono,
                        ),
                        SizedBox(height: AppDimens.space4),
                        Text(
                          'Tap to change',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.mapAccent,
                          ),
                        ),
                      ]
                    : [
                        const Text(
                          'Select location *',
                          style: AppTextStyles.body,
                        ),
                        SizedBox(height: AppDimens.space4),
                        Text(
                          'Tap to open map and pick the incident location',
                          style: AppTextStyles.caption,
                        ),
                      ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: hasLocation
                  ? AppColors.mapAccent
                  : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: _pickPhoto,
          icon: const Icon(Icons.photo_camera_outlined),
          label:
              Text(_photo == null ? 'Add photo (optional)' : 'Change photo'),
        ),
        if (_photo != null) ...[
          SizedBox(height: AppDimens.space12),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                child: Image.file(
                  File(_photo!.path),
                  height: AppDimens.photoPreviewHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: AppDimens.space6,
                right: AppDimens.space6,
                child: GestureDetector(
                  onTap: () => setState(() => _photo = null),
                  child: Container(
                    padding: EdgeInsets.all(AppDimens.space4),
                    decoration: BoxDecoration(
                      color: AppColors.background.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close,
                        color: AppColors.textPrimary, size: 18),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
