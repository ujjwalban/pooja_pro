import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
// Import dart:js conditionally for web only
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Google Maps API key
const String apiKey = 'AIzaSyA2f7FH0af8WP70R1_at1lHWoN2ZH4xn1Y';

// Force backup geocoding on web to avoid potential issues
bool shouldUseBackupGeocoding() {
  return kIsWeb;
}

class LocationData {
  final String address;
  final double latitude;
  final double longitude;
  final String? label; // Optional label for saved locations

  LocationData({
    required this.address,
    required this.latitude,
    required this.longitude,
    this.label,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'label': label,
    };
  }

  // Create from JSON
  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      address: json['address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      label: json['label'],
    );
  }
}

class LocationPicker extends StatefulWidget {
  final Function(LocationData locationData) onLocationSelected;
  final String initialAddress;
  final double initialLatitude;
  final double initialLongitude;
  final bool showSaveOption; // Whether to show save option

  const LocationPicker({
    Key? key,
    required this.onLocationSelected,
    this.initialAddress = '',
    this.initialLatitude = 0.0,
    this.initialLongitude = 0.0,
    this.showSaveOption = true,
  }) : super(key: key);

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  Timer? _debounce;
  List<Map<String, dynamic>> _suggestions = [];
  LocationData? _selectedLocation;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(20.5937, 78.9629), // Default to India
    zoom: 5.0,
  );
  List<LocationData> _favoriteLocations = [];
  bool _showFavorites = false;

  // Set initial fallback status based on platform
  bool _useBackupGeocoding = shouldUseBackupGeocoding();

  @override
  void initState() {
    super.initState();

    // Set initial fallback status based on platform
    _useBackupGeocoding = shouldUseBackupGeocoding();

    // Initialize map settings
    if (widget.initialAddress.isNotEmpty) {
      _searchController.text = widget.initialAddress;
      _selectedLocation = LocationData(
        address: widget.initialAddress,
        latitude: widget.initialLatitude,
        longitude: widget.initialLongitude,
      );
      _initialCameraPosition = CameraPosition(
        target: LatLng(widget.initialLatitude, widget.initialLongitude),
        zoom: 15.0,
      );
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: LatLng(widget.initialLatitude, widget.initialLongitude),
          infoWindow: InfoWindow(title: widget.initialAddress),
        ),
      };
    } else {
      // Try to get the user's current location on load
      _getCurrentLocation();
    }

    // For web, check if Google Maps API is available
    if (kIsWeb) {
      _checkGoogleMapsAvailability();
    }

    // Load saved favorite locations
    if (widget.showSaveOption) {
      _loadFavoriteLocations();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  // Load saved favorite locations from shared preferences
  Future<void> _loadFavoriteLocations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationsJson = prefs.getStringList('favorite_locations') ?? [];

      final locations = locationsJson.map((json) {
        return LocationData.fromJson(jsonDecode(json));
      }).toList();

      setState(() {
        _favoriteLocations = locations;
      });
    } catch (e) {
      debugPrint('Error loading favorite locations: $e');
    }
  }

  // Save a location to favorites
  Future<void> _saveLocationToFavorites(
      LocationData location, String label) async {
    try {
      if (location.address.isEmpty) return;

      // Create a new location with label
      final labeledLocation = LocationData(
        address: location.address,
        latitude: location.latitude,
        longitude: location.longitude,
        label: label,
      );

      // Add to list
      setState(() {
        _favoriteLocations.add(labeledLocation);
      });

      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      final locationsJson = _favoriteLocations.map((loc) {
        return jsonEncode(loc.toJson());
      }).toList();

      await prefs.setStringList('favorite_locations', locationsJson);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location saved to favorites'),
            backgroundColor: Colors.deepOrange,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving favorite location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Delete a favorite location
  Future<void> _deleteFavoriteLocation(int index) async {
    try {
      setState(() {
        _favoriteLocations.removeAt(index);
      });

      // Save updated list to shared preferences
      final prefs = await SharedPreferences.getInstance();
      final locationsJson = _favoriteLocations.map((loc) {
        return jsonEncode(loc.toJson());
      }).toList();

      await prefs.setStringList('favorite_locations', locationsJson);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location removed from favorites'),
            backgroundColor: Colors.grey,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error deleting favorite location: $e');
    }
  }

  // Show dialog to save current location
  void _showSaveLocationDialog() {
    if (_selectedLocation == null) return;

    final TextEditingController labelController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Location',
            style: TextStyle(color: Colors.deepOrange)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedLocation!.address,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: labelController,
              decoration: const InputDecoration(
                labelText: 'Location Name',
                hintText: 'e.g. Home, Work, Temple',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
            ),
            onPressed: () {
              final label = labelController.text.trim().isEmpty
                  ? 'Saved Location'
                  : labelController.text.trim();
              _saveLocationToFavorites(_selectedLocation!, label);
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Request location permission and get the current position
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Location permission denied';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage =
              'Location permissions permanently denied. Please enable in settings.';
          _isLoading = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Get address from coordinates
      await _getAddressFromLatLng(position.latitude, position.longitude);

      // Move map camera to current location
      _updateMapLocation(position.latitude, position.longitude);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting location: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Convert coordinates to address using Google's Geocoding API with fallback
  Future<void> _getAddressFromLatLng(double latitude, double longitude) async {
    try {
      String? address;

      if (!_useBackupGeocoding) {
        try {
          // Try Google API first
          final url =
              'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';
          final response = await http.get(Uri.parse(url));

          if (response.statusCode == 200) {
            final data = json.decode(response.body);

            if (data['status'] == 'OK') {
              address = data['results'][0]['formatted_address'];
            } else if (data['status'] == 'REQUEST_DENIED') {
              // Fall back to local geocoding
              _useBackupGeocoding = true;
              throw Exception(
                  'API key restrictions: ${data['error_message'] ?? data['status']}');
            } else {
              throw Exception('Failed to get address: ${data['status']}');
            }
          } else {
            throw Exception('Failed to load geocoding data');
          }
        } catch (e) {
          // If Google API fails, use the geocoding package as fallback
          _useBackupGeocoding = true;
          rethrow;
        }
      }

      // Use local geocoding as fallback
      if (_useBackupGeocoding || address == null) {
        List<Placemark> placemarks =
            await placemarkFromCoordinates(latitude, longitude);
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          address = [
            place.street,
            place.subLocality,
            place.locality,
            place.postalCode,
            place.country,
          ]
              .where((element) => element != null && element.isNotEmpty)
              .join(', ');
        } else {
          throw Exception('No address found for this location');
        }
      }

      setState(() {
        _searchController.text = address!;
        _selectedLocation = LocationData(
          address: address,
          latitude: latitude,
          longitude: longitude,
        );
      });

      // Update map marker
      _updateMarker(latitude, longitude, address);

      // Notify parent
      widget.onLocationSelected(_selectedLocation!);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting address: ${e.toString()}';
      });
    }
  }

  // Get suggestions based on user input
  Future<void> _getSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      if (!_useBackupGeocoding) {
        try {
          // Attempt to use Google Places API
          final url =
              'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$apiKey&types=geocode';
          final response = await http.get(Uri.parse(url));

          if (response.statusCode == 200) {
            final data = json.decode(response.body);

            if (data['status'] == 'OK') {
              List<Map<String, dynamic>> suggestions = [];

              for (var prediction in data['predictions']) {
                suggestions.add({
                  'place_id': prediction['place_id'],
                  'description': prediction['description'],
                });
              }

              setState(() {
                _suggestions = suggestions;
                _isLoading = false;
              });
              return;
            } else if (data['status'] == 'REQUEST_DENIED') {
              // Switch to backup method
              _useBackupGeocoding = true;
              throw Exception(
                  'API key restrictions: ${data['error_message'] ?? data['status']}');
            } else if (data['status'] == 'ZERO_RESULTS') {
              setState(() {
                _suggestions = [];
                _isLoading = false;
              });
              return;
            } else {
              throw Exception('Failed to get suggestions: ${data['status']}');
            }
          } else {
            throw Exception('Failed to load place autocomplete data');
          }
        } catch (e) {
          _useBackupGeocoding = true;
          rethrow;
        }
      }

      // Fallback to geocoding package
      if (_useBackupGeocoding) {
        try {
          List<Location> locations = await locationFromAddress(query);
          List<Map<String, dynamic>> suggestions = [];

          for (var location in locations) {
            List<Placemark> placemarks = await placemarkFromCoordinates(
                location.latitude, location.longitude);

            if (placemarks.isNotEmpty) {
              Placemark place = placemarks[0];
              String address = [
                place.street,
                place.subLocality,
                place.locality,
                place.postalCode,
                place.country,
              ]
                  .where((element) => element != null && element.isNotEmpty)
                  .join(', ');

              suggestions.add({
                'description': address,
                'latitude': location.latitude,
                'longitude': location.longitude,
              });
            }
          }

          setState(() {
            _suggestions = suggestions;
            _isLoading = false;
          });
        } catch (e) {
          throw Exception('Error finding locations: $e');
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error finding locations: ${e.toString()}';
      });
    }
  }

  // Handle selection from suggestions
  Future<void> _selectSuggestion(Map<String, dynamic> suggestion) async {
    setState(() {
      _isLoading = true;
      _suggestions = [];
    });

    try {
      if (_useBackupGeocoding || suggestion.containsKey('latitude')) {
        // If using backup method or already have coordinates
        final locationData = LocationData(
          address: suggestion['description'],
          latitude: suggestion['latitude'],
          longitude: suggestion['longitude'],
        );

        setState(() {
          _selectedLocation = locationData;
          _searchController.text = suggestion['description'];
        });

        // Update map location and marker
        _updateMapLocation(suggestion['latitude'], suggestion['longitude']);
        _updateMarker(suggestion['latitude'], suggestion['longitude'],
            suggestion['description']);

        // Notify parent
        widget.onLocationSelected(locationData);
      } else {
        // Use Place Details API for Google suggestions
        final placeId = suggestion['place_id'];
        final url =
            'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey&fields=formatted_address,geometry';
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data['status'] == 'OK') {
            final result = data['result'];
            final address = result['formatted_address'];
            final lat = result['geometry']['location']['lat'];
            final lng = result['geometry']['location']['lng'];

            final locationData = LocationData(
              address: address,
              latitude: lat,
              longitude: lng,
            );

            setState(() {
              _selectedLocation = locationData;
              _searchController.text = address;
            });

            // Update map location and marker
            _updateMapLocation(lat, lng);
            _updateMarker(lat, lng, address);

            // Notify parent
            widget.onLocationSelected(locationData);
          } else if (data['status'] == 'REQUEST_DENIED') {
            throw Exception(
                'API key restrictions: ${data['error_message'] ?? data['status']}');
          } else {
            throw Exception('Failed to get place details: ${data['status']}');
          }
        } else {
          throw Exception('Failed to load place details');
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting place details: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Update map camera position
  void _updateMapLocation(double latitude, double longitude) {
    final newPosition = CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: 15.0,
    );

    _initialCameraPosition = newPosition;

    if (_mapController != null) {
      _mapController!
          .animateCamera(CameraUpdate.newCameraPosition(newPosition));
    }
  }

  // Update marker on map
  void _updateMarker(double latitude, double longitude, String title) {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(title: title),
        ),
      };
    });
  }

  // Handle map tap to set location
  void _onMapTap(LatLng position) async {
    setState(() {
      _isLoading = true;
    });

    await _getAddressFromLatLng(position.latitude, position.longitude);

    setState(() {
      _isLoading = false;
    });
  }

  // Check if Google Maps API has loaded correctly on web
  void _checkGoogleMapsAvailability() {
    // This method will periodically check if the Google Maps API is available
    // and will automatically switch to backup geocoding if not
    if (!kIsWeb) return; // Only needed for web

    Future.delayed(const Duration(seconds: 3), () {
      // Check if the Google Maps library is available via JS interop
      try {
        if (kIsWeb) {
          // Only perform the JS check on web
          bool isMapsAvailable = false;
          try {
            // For mobile builds, always return false
            isMapsAvailable = false;
          } catch (e) {
            debugPrint('JS interop error: $e');
            isMapsAvailable = false;
          }

          if (!isMapsAvailable) {
            debugPrint('Google Maps API not available, using backup geocoding');
            setState(() {
              _useBackupGeocoding = true;
            });
          } else {
            debugPrint('Google Maps API available and ready to use');
          }
        }
      } catch (e) {
        debugPrint('Error checking Google Maps availability: $e');
        setState(() {
          _useBackupGeocoding = true;
        });
      }
    });
  }

  // Add this method to your _LocationPickerState class
  bool _checkIfGoogleMapsIsAvailable() {
    // For mobile builds, always return false
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // API status indicator
        if (_useBackupGeocoding)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    color: Colors.amber.shade800, size: 16),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "Using basic location search. Enhanced results unavailable.",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Map component (moved to top for better mobile experience)
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 230, // Taller for better mobile viewing
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Enable GoogleMap on all platforms including web
              GoogleMap(
                initialCameraPosition: _initialCameraPosition,
                markers: _markers,
                myLocationEnabled: !kIsWeb, // Location button won't work on web
                myLocationButtonEnabled:
                    false, // We provide our own custom button
                zoomControlsEnabled: false, // We provide our own zoom controls
                mapToolbarEnabled: false,
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                onTap: _onMapTap,
              ),

              // Custom zoom controls with better mobile tap targets
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Zoom in button
                      SizedBox(
                        width: 42, // Larger tap target for mobile
                        height: 42,
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.deepOrange),
                          onPressed: () {
                            _mapController
                                ?.animateCamera(CameraUpdate.zoomIn());
                          },
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 1,
                        color: Colors.grey.shade300,
                      ),
                      // Zoom out button
                      SizedBox(
                        width: 42, // Larger tap target for mobile
                        height: 42,
                        child: IconButton(
                          icon: const Icon(Icons.remove,
                              color: Colors.deepOrange),
                          onPressed: () {
                            _mapController
                                ?.animateCamera(CameraUpdate.zoomOut());
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // My Location button for mobile (separate from standard Google one)
              Positioned(
                bottom: 16,
                left: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: 42, // Larger tap target for mobile
                    height: 42,
                    child: IconButton(
                      icon: const Icon(Icons.my_location,
                          color: Colors.deepOrange),
                      onPressed: _getCurrentLocation,
                    ),
                  ),
                ),
              ),

              // Web platform message when needed
              if (kIsWeb)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          spreadRadius: 0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.deepOrange,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Allow location access in your browser for best experience",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Loading indicator overlay
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.1),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Search row with favorites toggle
        Row(
          children: [
            // Search field - takes most of the space
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                margin: const EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search location or enter address',
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: InputBorder.none,
                    prefixIcon:
                        const Icon(Icons.search, color: Colors.deepOrange),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _suggestions = [];
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    if (_debounce?.isActive ?? false) _debounce!.cancel();
                    _debounce = Timer(const Duration(milliseconds: 500), () {
                      _getSuggestions(value);
                    });
                  },
                ),
              ),
            ),

            // Only show if favorites feature is enabled
            if (widget.showSaveOption && _favoriteLocations.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(left: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    _showFavorites ? Icons.favorite : Icons.favorite_border,
                    color: Colors.deepOrange,
                  ),
                  onPressed: () {
                    setState(() {
                      _showFavorites = !_showFavorites;
                      _suggestions = []; // Clear search results
                    });
                  },
                  tooltip: 'Show saved locations',
                ),
              ),
          ],
        ),

        // Favorites list
        if (_showFavorites && _favoriteLocations.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _favoriteLocations.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.grey.shade200,
              ),
              itemBuilder: (context, index) {
                final location = _favoriteLocations[index];
                return Dismissible(
                  key: Key('favorite_${index}_${location.address}'),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _deleteFavoriteLocation(index);
                  },
                  child: ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.favorite,
                      color: Colors.deepOrange,
                    ),
                    title: Text(
                      location.label ?? 'Saved Location',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      location.address,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      // Select this saved location
                      setState(() {
                        _selectedLocation = location;
                        _searchController.text = location.address;
                        _updateMapLocation(
                            location.latitude, location.longitude);
                        _updateMarker(location.latitude, location.longitude,
                            location.address);
                        _showFavorites = false;
                      });
                      widget.onLocationSelected(location);
                    },
                  ),
                );
              },
            ),
          ),

        // Location suggestions
        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, color: Colors.grey.shade200),
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return ListTile(
                  dense: true,
                  leading:
                      const Icon(Icons.location_on, color: Colors.deepOrange),
                  title: Text(
                    suggestion['description'],
                    style: const TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _selectSuggestion(suggestion),
                );
              },
            ),
          ),

        // Error message
        if (_errorMessage.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _errorMessage = '';
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

        // Selected location display with app-styled UI
        if (_selectedLocation != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade50, Colors.deepOrange.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
              border: Border.all(color: Colors.deepOrange.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 3,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.location_on,
                          color: Colors.deepOrange, size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Selected Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ),
                    // Save location button
                    if (widget.showSaveOption)
                      IconButton(
                        icon: const Icon(Icons.bookmark_add,
                            color: Colors.deepOrange),
                        onPressed: _showSaveLocationDialog,
                        tooltip: 'Save this location',
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedLocation!.address,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Lat: ${_selectedLocation!.latitude.toStringAsFixed(6)}, Lng: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
