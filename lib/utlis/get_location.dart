import 'package:geocoding/geocoding.dart';

Future<String> getAddressFromLatLng(double lat, double lng) async {
  final List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

  if (placemarks.isNotEmpty) {
    final Placemark place = placemarks[0];

    // Construct a readable address
    String address = '';
    if (place.name != null) {
      address += '${place.street}, ';
    }
    if (place.street != null) {
      address += '${place.name}, ';
    }
    if (place.locality != null) {
      address += '${place.locality}, ';
    }

    // Remove trailing comma and space
    address =
        address.isNotEmpty ? address.substring(0, address.length - 2) : '';

    return address;
  } else {
    return 'No address found';
  }
}
