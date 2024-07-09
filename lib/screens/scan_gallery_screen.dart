import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:exif/exif.dart';
import 'package:image_picker/image_picker.dart';

Future<void> requestPermissions() async {
  await Permission.photos.request();
}

Future<Map<String, dynamic>> getImageMetadata(XFile file) async {
  final File imageFile = File(file.path);
  final bytes = await imageFile.readAsBytes();
  final data = await readExifFromBytes(bytes);

  log('Image Metadata: $data');

  String? dateTime = data['Image DateTime']?.toString();

  double? latitude = parseGpsCoordinate(data['GPS GPSLatitude']);
  double? longitude = parseGpsCoordinate(data['GPS GPSLongitude']);

  String? address;
  if (latitude != null && longitude != null) {
    final placemarks = await placemarkFromCoordinates(latitude, longitude);
    Placemark place = placemarks[0];
    address = '${place.street}, ${place.subLocality}, ${place.locality}, '
        '${place.administrativeArea}, ${place.postalCode}, ${place.country}';
  }

  return {
    'dateTime': dateTime,
    'address': address,
    'latitude': latitude,
    'longitude': longitude
  };
}

double? parseGpsCoordinate(dynamic coordinate) {
  if (coordinate == null) return null;
  return double.tryParse(coordinate.toString());
}

Future<List<XFile>> scanPhotos(Function(double) updateProgress) async {
  await requestPermissions();

  List<AssetPathEntity> albums =
      await PhotoManager.getAssetPathList(type: RequestType.image);
  List<XFile> photos = [];
  int totalPhotos = 0;

  // Calculate total photos for progress tracking
  for (var album in albums) {
    totalPhotos += await album.assetCountAsync;
  }

  int processedPhotos = 0;
  for (var album in albums) {
    int albumCount = await album.assetCountAsync;
    if (albumCount > 0) {
      int batchSize = 100; // Adjust the batch size as needed
      for (int i = 0; i < albumCount; i += batchSize) {
        int end = (i + batchSize > albumCount) ? albumCount : i + batchSize;
        List<AssetEntity> albumPhotos =
            await album.getAssetListRange(start: i, end: end);
        for (var asset in albumPhotos) {
          File? file = await asset.file;

          LatLng latLng = await asset.latlngAsync();
          log('latitude: ${latLng.latitude}, longitude: ${latLng.longitude}, datetime: ${asset.createDateTime}');

          if (file != null) {
            photos.add(XFile(file.path));
          }
          processedPhotos++;
          updateProgress(processedPhotos / totalPhotos);
        }
      }
    }
  }

  return photos;
}

Future<Map<String, List<XFile>>> sortImagesByDateAndLocation(
    List<XFile>? fileList) async {
  Map<String, List<XFile>> sortedMap = {};
  if (fileList != null) {
    for (var file in fileList) {
      final metadata = await getImageMetadata(file);

      final key =
          "${metadata['dateTime']} - ${metadata['address']} - ${metadata['latitude']}, ${metadata['longitude']}";

      if (!sortedMap.containsKey(key)) {
        sortedMap[key] = [];
      }
      sortedMap[key]!.add(file);
    }
  }
  return sortedMap;
}

class ScanGalleryScreen extends StatefulWidget {
  const ScanGalleryScreen({super.key});

  @override
  _ScanGalleryScreenState createState() => _ScanGalleryScreenState();
}

class _ScanGalleryScreenState extends State<ScanGalleryScreen> {
  Map<String, List<XFile>> _sortedPhotos = {};
  bool _isLoading = false;
  double _progress = 0.0;

  Future<void> _scanAndSortPhotos() async {
    setState(() {
      _isLoading = true;
      _progress = 0.0;
    });

    List<XFile> photos = await scanPhotos(updateProgress);
    Map<String, List<XFile>> sortedPhotos =
        await sortImagesByDateAndLocation(photos);

    setState(() {
      _sortedPhotos = sortedPhotos;
      _isLoading = false;
    });
  }

  void updateProgress(double progress) {
    setState(() {
      _progress = progress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: _scanAndSortPhotos,
            child: const Text('Scan and Sort Photos'),
          ),
          _isLoading
              ? Column(
                  children: [
                    CircularProgressIndicator(value: _progress),
                    const SizedBox(height: 10),
                    Text('${(_progress * 100).toStringAsFixed(1)}%'),
                  ],
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: _sortedPhotos.keys.length,
                    itemBuilder: (context, index) {
                      String key = _sortedPhotos.keys.elementAt(index);
                      return ScanGalleryItem(
                        locationKey: key,
                        photos: _sortedPhotos[key]!,
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

class ScanGalleryItem extends StatelessWidget {
  final String locationKey;
  final List<XFile> photos;

  const ScanGalleryItem(
      {super.key, required this.locationKey, required this.photos});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(locationKey, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text('Number of Photos: ${photos.length}'),
        SizedBox(
          height: 200, // Adjust the height as needed
          child: ListView.builder(
            scrollDirection: Axis
                .horizontal, // Make it horizontal to avoid nested vertical scrolling
            itemCount: photos.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.file(File(photos[index].path)),
              );
            },
          ),
        ),
      ],
    );
  }
}
