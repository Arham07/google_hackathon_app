import 'dart:async';

import 'package:flutter/material.dart';

import 'package:google_hackathon_app/config/maps_config.dart';
import 'package:google_hackathon_app/models/place_suggestion.dart';
import 'package:google_hackathon_app/services/places_search_service.dart';

class MapSearchBar extends StatefulWidget {
  const MapSearchBar({
    super.key,
    required this.onPlaceSelected,
    this.placesService,
  });

  final ValueChanged<SelectedPlace> onPlaceSelected;
  final PlacesSearchService? placesService;

  @override
  State<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late final PlacesSearchService _places =
      widget.placesService ?? PlacesSearchService();

  Timer? _debounce;
  List<PlaceSuggestion> _suggestions = [];
  bool _isSearching = false;
  bool _isLoadingDetails = false;
  String? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    if (value.trim().length < 2) {
      setState(() {
        _suggestions = [];
        _error = null;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 350), () => _runSearch(value));
  }

  Future<void> _runSearch(String query) async {
    if (!MapsConfig.hasApiKey) {
      setState(() {
        _suggestions = [];
        _error = 'Google Maps API key is not configured';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _error = null;
    });

    try {
      final List<PlaceSuggestion> results = await _places.search(query);
      if (!mounted) return;
      setState(() {
        _suggestions = results;
        _isSearching = false;
        if (results.isEmpty) {
          _error = 'No places found';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _suggestions = [];
        _isSearching = false;
        _error = 'Search failed. Check internet and API key.';
      });
    }
  }

  Future<void> _selectSuggestion(PlaceSuggestion suggestion) async {
    setState(() {
      _isLoadingDetails = true;
      _suggestions = [];
      _error = null;
    });
    _focusNode.unfocus();

    try {
      final SelectedPlace? place =
          await _places.getPlaceDetails(suggestion.placeId);
      if (!mounted) return;

      if (place == null) {
        setState(() {
          _isLoadingDetails = false;
          _error = 'Could not load place details';
        });
        return;
      }

      _controller.text = place.name.isNotEmpty ? place.name : place.address;
      setState(() => _isLoadingDetails = false);
      widget.onPlaceSelected(place);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingDetails = false;
        _error = 'Could not load place details';
      });
    }
  }

  void _clear() {
    _debounce?.cancel();
    _places.resetSession();
    _controller.clear();
    setState(() {
      _suggestions = [];
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool showList =
        _suggestions.isNotEmpty || _isSearching || _error != null;

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: !_isLoadingDetails,
            decoration: InputDecoration(
              hintText: 'Search location in Karachi…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _isLoadingDetails
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : (_controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: _clear,
                        )
                      : null),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            onChanged: _onQueryChanged,
            textInputAction: TextInputAction.search,
            onSubmitted: (String value) {
              if (_suggestions.isNotEmpty) {
                _selectSuggestion(_suggestions.first);
              } else {
                _runSearch(value);
              }
            },
          ),
          if (showList)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: _isSearching
                  ? const LinearProgressIndicator(minHeight: 2)
                  : _error != null
                      ? ListTile(
                          dense: true,
                          leading: const Icon(Icons.info_outline),
                          title: Text(
                            _error!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: _suggestions.length,
                          separatorBuilder: (BuildContext context, int index) =>
                              const Divider(height: 1),
                          itemBuilder: (BuildContext context, int index) {
                            final PlaceSuggestion item = _suggestions[index];
                            return ListTile(
                              dense: true,
                              leading: const Icon(Icons.place_outlined),
                              title: Text(
                                item.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () => _selectSuggestion(item),
                            );
                          },
                        ),
            ),
        ],
      ),
    );
  }
}
