import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_hackathon_app/core/api/api_exception.dart';
import 'package:google_hackathon_app/core/api/user_reports_api.dart';
import 'package:google_hackathon_app/features/submit/location_picker_screen.dart';
import 'package:google_hackathon_app/services/location_service.dart';
import 'package:google_hackathon_app/theme/app_colors.dart';
import 'package:google_hackathon_app/theme/app_dimens.dart';
import 'package:google_hackathon_app/theme/app_map_style.dart';
import 'package:google_hackathon_app/theme/app_text_styles.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

class SubmitIncidentScreen extends StatefulWidget {
  const SubmitIncidentScreen({super.key});

  @override
  State<SubmitIncidentScreen> createState() => _SubmitIncidentScreenState();
}

class _SubmitIncidentScreenState extends State<SubmitIncidentScreen> {
  static final CameraPosition _fallbackCamera = CameraPosition(
    target: LocationService.fallbackCenter,
    zoom: 13,
  );

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final UserReportsApi _reportsApi = UserReportsApi();

  XFile? _photo;
  bool _submitting = false;
  bool _locationLoading = true;
  bool _myLocationEnabled = false;

  PickedLocation? _pickedLocation;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onFormChanged);
    _bootstrapLocation();
  }

  @override
  void dispose() {
    _textController.removeListener(_onFormChanged);
    _textController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _bootstrapLocation() async {
    final LatLng? position = await LocationService.getCurrentLatLng();
    if (!mounted) return;

    setState(() {
      _myLocationEnabled = position != null;
      if (position != null) {
        _pickedLocation = PickedLocation(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }
      _locationLoading = false;
    });

    if (position != null) {
      await _moveMapTo(position.latitude, position.longitude);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location not set — enable GPS or tap the map to pick a point.',
          ),
        ),
      );
    }
  }

  Future<void> _moveMapTo(double lat, double lng) async {
    if (!_mapController.isCompleted) return;
    final GoogleMapController controller = await _mapController.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 15),
      ),
    );
  }

  bool get _canSubmit {
    if (_pickedLocation == null || _photo == null || _submitting) return false;
    final String text = _textController.text.trim();
    return text.length >= 10;
  }

  CameraPosition get _mapCamera {
    if (_pickedLocation != null) {
      return CameraPosition(
        target: LatLng(_pickedLocation!.latitude, _pickedLocation!.longitude),
        zoom: 15,
      );
    }
    return _fallbackCamera;
  }

  Set<Marker> get _mapMarkers {
    if (_pickedLocation == null) return {};
    return {
      Marker(
        markerId: const MarkerId('incident'),
        position: LatLng(_pickedLocation!.latitude, _pickedLocation!.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };
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
    final PickedLocation? result =
        await Navigator.of(context).push<PickedLocation>(
      MaterialPageRoute<PickedLocation>(
        builder: (_) => LocationPickerScreen(
          initialLocation: _pickedLocation,
        ),
      ),
    );

    if (result != null) {
      setState(() => _pickedLocation = result);
      await _moveMapTo(result.latitude, result.longitude);
    }
  }

  // ── Submit ────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pickedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location on the map.'),
        ),
      );
      return;
    }

    if (_photo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a photo of the incident.'),
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
        photoPath: _photo!.path,
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
            content: Text('Thank you for your submission.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (!result.isDuplicate) {
                    _textController.clear();
                    setState(() => _photo = null);
                    _bootstrapLocation();
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
              _buildLocationSection(),
              SizedBox(height: AppDimens.space20),

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
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  if (value.trim().length < 10) {
                    return 'Please provide at least 10 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppDimens.space20),

              _buildPhotoSection(),
              SizedBox(height: AppDimens.space28),

              ElevatedButton(
                onPressed: _canSubmit ? _submit : null,
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

  Widget _buildLocationSection() {
    final bool hasLocation = _pickedLocation != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Location *',
          style: AppTextStyles.sectionTitle,
        ),
        SizedBox(height: AppDimens.space8),
        GestureDetector(
          onTap: _openLocationPicker,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            child: Container(
              height: AppDimens.mapPreviewHeight,
              decoration: BoxDecoration(
                border: Border.all(
                  color: hasLocation
                      ? AppColors.mapAccent.withValues(alpha: 0.4)
                      : AppColors.glassBorder,
                ),
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: _mapCamera,
                    markers: _mapMarkers,
                    myLocationEnabled: _myLocationEnabled,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    scrollGesturesEnabled: false,
                    zoomGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                    rotateGesturesEnabled: false,
                    style: AppMapStyle.dark,
                    gestureRecognizers:
                        <Factory<OneSequenceGestureRecognizer>>{
                      Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                      ),
                    },
                    onMapCreated: (GoogleMapController controller) {
                      if (!_mapController.isCompleted) {
                        _mapController.complete(controller);
                      }
                      if (_pickedLocation != null) {
                        controller.moveCamera(
                          CameraUpdate.newCameraPosition(_mapCamera),
                        );
                      }
                    },
                  ),
                  if (_locationLoading)
                    ColoredBox(
                      color: AppColors.surfaceElevated,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            SizedBox(height: AppDimens.space12),
                            Text(
                              'Getting your location…',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimens.space12,
                        vertical: AppDimens.space10,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.background.withValues(alpha: 0.85),
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.pin_drop,
                              color: AppColors.mapAccent, size: 18),
                          SizedBox(width: AppDimens.space8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: hasLocation
                                  ? [
                                      if (_pickedLocation!.address != null)
                                        Text(
                                          _pickedLocation!.address!,
                                          style: AppTextStyles.bodySecondary,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ]
                                  : [
                                      const Text(
                                        'Tap to pick location on map',
                                        style: AppTextStyles.caption,
                                      ),
                                    ],
                            ),
                          ),
                          Icon(
                            Icons.edit_location_alt_outlined,
                            color: AppColors.mapAccent,
                            size: 20.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (hasLocation && !_locationLoading) ...[
          SizedBox(height: AppDimens.space6),
          Text(
            _myLocationEnabled
                ? 'Blue dot is your current position. Tap the map to adjust.'
                : 'Tap the map to change this location',
            style: AppTextStyles.caption,
          ),
        ] else if (!hasLocation && !_locationLoading) ...[
          SizedBox(height: AppDimens.space6),
          Text(
            'Location is required — enable GPS or tap the map to pick a point',
            style: AppTextStyles.caption.copyWith(color: AppColors.chart1),
          ),
        ],
      ],
    );
  }

  Widget _buildPhotoSection() {
    final bool hasPhoto = _photo != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Text(
              'Photo *',
              style: AppTextStyles.sectionTitle,
            ),
            if (!hasPhoto) ...[
              const Spacer(),
              Text(
                'Required',
                style: AppTextStyles.caption.copyWith(color: AppColors.chart1),
              ),
            ],
          ],
        ),
        SizedBox(height: AppDimens.space8),
        OutlinedButton.icon(
          onPressed: _pickPhoto,
          icon: const Icon(Icons.photo_camera_outlined),
          label: Text(hasPhoto ? 'Change photo' : 'Add photo'),
        ),
        if (hasPhoto) ...[
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
        ] else ...[
          SizedBox(height: AppDimens.space6),
          Text(
            'A photo is required before you can submit',
            style: AppTextStyles.caption.copyWith(color: AppColors.chart1),
          ),
        ],
      ],
    );
  }
}
