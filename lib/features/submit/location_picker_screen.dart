import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_hackathon_app/config/maps_config.dart';
import 'package:google_hackathon_app/models/place_suggestion.dart';
import 'package:google_hackathon_app/services/location_service.dart';
import 'package:google_hackathon_app/services/places_search_service.dart';
import 'package:google_hackathon_app/theme/app_colors.dart';
import 'package:google_hackathon_app/theme/app_dimens.dart';
import 'package:google_hackathon_app/theme/app_map_style.dart';
import 'package:google_hackathon_app/theme/app_text_styles.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Result returned from the location picker.
class PickedLocation {
  const PickedLocation({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  final double latitude;
  final double longitude;
  final String? address;
}

/// Full-screen Google Maps location picker.
///
/// Shows the user's current location, allows tapping the map or searching
/// for a place, and returns a [PickedLocation] on confirm.
class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key, this.initialLocation});

  /// If provided, the map opens centred on this location with a marker.
  final PickedLocation? initialLocation;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  final PlacesSearchService _places = PlacesSearchService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  static final CameraPosition _fallbackCamera = CameraPosition(
    target: LocationService.fallbackCenter,
    zoom: 13,
  );

  CameraPosition? _initialCamera;
  LatLng? _selectedLatLng;
  String? _selectedAddress;
  bool _loadingLocation = true;
  bool _myLocationEnabled = false;

  // Search state
  Timer? _debounce;
  List<PlaceSuggestion> _suggestions = [];
  bool _isSearching = false;
  bool _isLoadingDetails = false;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    // If we already have a location, use it as initial position.
    if (widget.initialLocation != null) {
      final PickedLocation loc = widget.initialLocation!;
      setState(() {
        _selectedLatLng = LatLng(loc.latitude, loc.longitude);
        _selectedAddress = loc.address;
        _initialCamera = CameraPosition(
          target: LatLng(loc.latitude, loc.longitude),
          zoom: 15,
        );
        _loadingLocation = false;
      });
      // Still try to enable my-location blue dot.
      final LatLng? pos =
          await LocationService.obtainCurrentLocation(context);
      if (mounted && pos != null) {
        setState(() => _myLocationEnabled = true);
      }
      return;
    }

    // Otherwise, centre on the user's current GPS position.
    final LatLng? position =
        await LocationService.obtainCurrentLocation(context);
    if (!mounted) return;

    if (position != null) {
      setState(() {
        _selectedLatLng = position;
        _initialCamera = CameraPosition(target: position, zoom: 15);
        _myLocationEnabled = true;
        _loadingLocation = false;
      });
    } else {
      setState(() {
        _initialCamera = _fallbackCamera;
        _myLocationEnabled = false;
        _loadingLocation = false;
      });
    }
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedLatLng = position;
      _selectedAddress = null;
      _showSuggestions = false;
    });
    _searchFocus.unfocus();
  }

  Future<void> _goToMyLocation() async {
    final LatLng? position =
        await LocationService.obtainCurrentLocation(context);
    if (position == null) return;

    setState(() {
      _selectedLatLng = position;
      _selectedAddress = null;
      _myLocationEnabled = true;
    });

    if (_mapController.isCompleted) {
      final GoogleMapController controller = await _mapController.future;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: position, zoom: 16),
        ),
      );
    }
  }

  // ── Search ────────────────────────────────────────────────────────────

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    if (value.trim().length < 2) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }
    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => _runSearch(value),
    );
  }

  Future<void> _runSearch(String query) async {
    if (!MapsConfig.hasApiKey) return;

    setState(() {
      _isSearching = true;
      _showSuggestions = true;
    });

    try {
      final List<PlaceSuggestion> results = await _places.search(query);
      if (!mounted) return;
      setState(() {
        _suggestions = results;
        _isSearching = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _suggestions = [];
        _isSearching = false;
      });
    }
  }

  Future<void> _selectSuggestion(PlaceSuggestion suggestion) async {
    setState(() {
      _isLoadingDetails = true;
      _suggestions = [];
      _showSuggestions = false;
    });
    _searchFocus.unfocus();

    try {
      final SelectedPlace? place =
          await _places.getPlaceDetails(suggestion.placeId);
      if (!mounted) return;

      if (place == null) {
        setState(() => _isLoadingDetails = false);
        return;
      }

      final LatLng target = LatLng(place.latitude, place.longitude);
      _searchController.text =
          place.name.isNotEmpty ? place.name : place.address;

      setState(() {
        _selectedLatLng = target;
        _selectedAddress = place.address;
        _isLoadingDetails = false;
      });

      if (_mapController.isCompleted) {
        final GoogleMapController controller = await _mapController.future;
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: target, zoom: 16),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingDetails = false);
    }
  }

  void _clearSearch() {
    _debounce?.cancel();
    _places.resetSession();
    _searchController.clear();
    setState(() {
      _suggestions = [];
      _showSuggestions = false;
    });
  }

  // ── Confirm ───────────────────────────────────────────────────────────

  void _confirmLocation() {
    if (_selectedLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tap the map or search to select a location first.'),
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      PickedLocation(
        latitude: _selectedLatLng!.latitude,
        longitude: _selectedLatLng!.longitude,
        address: _selectedAddress,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────

  Set<Marker> get _markers {
    if (_selectedLatLng == null) return {};
    return {
      Marker(
        markerId: const MarkerId('selected'),
        position: _selectedLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingLocation || _initialCamera == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pick location')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // ── Map ──
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialCamera!,
            markers: _markers,
            myLocationEnabled: _myLocationEnabled,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            style: AppMapStyle.dark,
            onTap: _onMapTap,
            onMapCreated: (GoogleMapController controller) {
              if (!_mapController.isCompleted) {
                _mapController.complete(controller);
              }
            },
          ),

          // ── Centre cross-hair (visible when no marker selected) ──
          if (_selectedLatLng == null)
            const Center(
              child: Icon(
                Icons.add,
                color: AppColors.mapAccent,
                size: 32,
              ),
            ),

          // ── Top bar: back + search ──
          Positioned(
            top: MediaQuery.paddingOf(context).top + AppDimens.space8,
            left: AppDimens.space12,
            right: AppDimens.space12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search bar
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                  clipBehavior: Clip.antiAlias,
                  color: AppColors.surfaceElevated,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocus,
                              enabled: !_isLoadingDetails,
                              decoration: InputDecoration(
                                hintText: 'Search location…',
                                suffixIcon: _isLoadingDetails
                                    ? Padding(
                                        padding:
                                            EdgeInsets.all(AppDimens.space12),
                                        child: SizedBox(
                                          width: 20.w,
                                          height: 20.w,
                                          child:
                                              const CircularProgressIndicator(
                                                  strokeWidth: 2),
                                        ),
                                      )
                                    : (_searchController.text.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.clear),
                                            onPressed: _clearSearch,
                                          )
                                        : null),
                                filled: true,
                                fillColor: Colors.transparent,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: AppDimens.space8,
                                  vertical: AppDimens.space14,
                                ),
                              ),
                              onChanged: _onSearchChanged,
                              textInputAction: TextInputAction.search,
                              onSubmitted: (String value) {
                                if (_suggestions.isNotEmpty) {
                                  _selectSuggestion(_suggestions.first);
                                } else {
                                  _runSearch(value);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      // Suggestions list
                      if (_showSuggestions)
                        ConstrainedBox(
                          constraints: BoxConstraints(
                              maxHeight: AppDimens.searchListMaxHeight),
                          child: _isSearching
                              ? LinearProgressIndicator(minHeight: 2.h)
                              : _suggestions.isEmpty
                                  ? ListTile(
                                      dense: true,
                                      leading:
                                          const Icon(Icons.info_outline),
                                      title: Text(
                                        'No places found',
                                        style: AppTextStyles.bodyMuted,
                                      ),
                                    )
                                  : ListView.separated(
                                      shrinkWrap: true,
                                      itemCount: _suggestions.length,
                                      separatorBuilder:
                                          (BuildContext context, int index) =>
                                              Divider(height: 1.h),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final PlaceSuggestion item =
                                            _suggestions[index];
                                        return ListTile(
                                          dense: true,
                                          leading: const Icon(
                                              Icons.place_outlined),
                                          title: Text(
                                            item.description,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                AppTextStyles.bodySecondary,
                                          ),
                                          onTap: () =>
                                              _selectSuggestion(item),
                                        );
                                      },
                                    ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Selected location info bar ──
          if (_selectedLatLng != null)
            Positioned(
              left: AppDimens.space12,
              right: AppDimens.space12,
              bottom: 80.h + MediaQuery.paddingOf(context).bottom,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimens.space14,
                  vertical: AppDimens.space12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.pin_drop,
                        color: AppColors.mapAccent, size: 20),
                    SizedBox(width: AppDimens.space10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_selectedAddress != null)
                            Text(
                              _selectedAddress!,
                              style: AppTextStyles.bodySecondary,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          Text(
                            '${_selectedLatLng!.latitude.toStringAsFixed(6)}, ${_selectedLatLng!.longitude.toStringAsFixed(6)}',
                            style: AppTextStyles.mono,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Bottom: Confirm button ──
          Positioned(
            left: AppDimens.space16,
            right: AppDimens.space16,
            bottom: AppDimens.space16 + MediaQuery.paddingOf(context).bottom,
            child: ElevatedButton.icon(
              onPressed: _selectedLatLng != null ? _confirmLocation : null,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Confirm location'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: AppDimens.space14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                ),
              ),
            ),
          ),

          // ── My-location FAB ──
          Positioned(
            right: AppDimens.space16,
            bottom: 140.h + MediaQuery.paddingOf(context).bottom,
            child: FloatingActionButton(
              heroTag: 'picker_my_location',
              mini: true,
              tooltip: 'My location',
              onPressed: _goToMyLocation,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }

}
