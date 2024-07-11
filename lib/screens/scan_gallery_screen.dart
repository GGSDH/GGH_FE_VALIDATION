import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ggh_fe_valdation/screens/range_picker_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

Future<void> requestPermissions() async {
  await Permission.photos.request();
}

double? parseGpsCoordinate(dynamic coordinate) {
  if (coordinate == null) return null;
  return double.tryParse(coordinate.toString());
}

Future<List<AssetEntity>> scanPhotos(
  DateTime startDate,
  DateTime endDate,
  Function(double) updateProgress
) async {
  await requestPermissions();

  List<AssetPathEntity> albums =
      await PhotoManager.getAssetPathList(type: RequestType.image);
  List<AssetEntity> photos = [];
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
          DateTime assetDate = asset.createDateTime;
          if (assetDate.isAfter(startDate) && assetDate.isBefore(endDate)) {
            File? file = await asset.file;
            if (file != null) {
              photos.add(asset);
            }
          }
          processedPhotos++;
          updateProgress(processedPhotos / totalPhotos);
        }
      }
    }
  }

  return photos;
}

Future<Map<String, List<AssetEntity>>> sortImagesByDateAndLocation(
    List<AssetEntity>? fileList) async {
  Map<String, List<AssetEntity>> sortedMap = {};
  if (fileList != null) {
    for (var file in fileList) {
      LatLng latLng = await file.latlngAsync();

      final date = "${file.createDateTime.year}-${file.createDateTime.month}-${file.createDateTime.day}";
      final key = "${latLng.latitude} ${latLng.longitude} $date";

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
  Map<String, List<AssetEntity>> _sortedPhotos = {};
  bool _isLoading = false;
  double _progress = 0.0;

  late DateTime startDate;
  late DateTime endDate;

  @override
  void initState() {
    super.initState();
    startDate = DateTime.now();
    endDate = DateTime.now();
  }

  void _onDaySelected(DateTime selectedDay) {
    setState(() {
      if (startDate.isBefore(endDate)) {
        startDate = selectedDay;
        endDate = selectedDay;
      } else if (selectedDay.isBefore(startDate)) {
        startDate = selectedDay;
      } else if (selectedDay.isAfter(endDate)) {
        endDate = selectedDay;
      } else {
        startDate = selectedDay;
        endDate = selectedDay;
      }
    });
  }

  Future<void> _scanAndSortPhotos() async {
    setState(() {
      _isLoading = true;
      _progress = 0.0;
    });

    List<AssetEntity> photos = await scanPhotos( startDate, endDate, updateProgress);
    Map<String, List<AssetEntity>> sortedPhotos =
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  if (_isLoading) return;
                  showModalBottomSheet<DateTime>(
                    context: context,
                    builder: (BuildContext context) {
                      return StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return RangePickerScreen(
                            startDate: startDate,
                            endDate: endDate,
                            onDaySelected: (DateTime selectedDay) {
                              setState(() {
                                _onDaySelected(selectedDay);
                              });
                            },
                          );
                        },
                      );
                    },
                  );
                },
                child: Text('Start Date: ${startDate.year}-${startDate.month}-${startDate.day}'),
              ),

              const SizedBox(width: 8),

              GestureDetector(
                onTap: () {
                  if (_isLoading) return;
                  showModalBottomSheet<DateTime>(
                    context: context,
                    builder: (BuildContext context) {
                      return StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return RangePickerScreen(
                            startDate: startDate,
                            endDate: endDate,
                            onDaySelected: (DateTime selectedDay) {
                              setState(() {
                                _onDaySelected(selectedDay);
                              });
                            },
                          );
                        },
                      );
                    },
                  );
                },
                child: Text('End Date: ${endDate.year}-${endDate.month}-${endDate.day}'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        ElevatedButton(
          onPressed: _scanAndSortPhotos,
          child: const Text('Scan and Sort Photos'),
        ),

        const SizedBox(height: 16),

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
    );
  }
}

class ScanGalleryItem extends StatelessWidget {
  final String locationKey;
  final List<AssetEntity> photos;

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
            itemBuilder: (context, snapshot) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: FutureBuilder<File?>(
                  future: photos[snapshot].file,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData) {
                      return Image.file(
                        snapshot.data!,
                        width: 200,
                        height: 200,
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                )
              );
            },
          ),
        ),
      ],
    );
  }
}
