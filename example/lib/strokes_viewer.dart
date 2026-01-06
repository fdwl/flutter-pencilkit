import 'package:flutter/material.dart';

class StrokesViewer extends StatelessWidget {
  final List<Map<String, dynamic>> strokes;

  const StrokesViewer({super.key, required this.strokes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Strokes Data (${strokes.length} strokes)'),
      ),
      body: strokes.isEmpty
          ? const Center(
              child: Text(
                'No strokes data available.\nDraw something first!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: strokes.length,
              itemBuilder: (context, index) {
                final stroke = strokes[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ExpansionTile(
                    title: Text('Stroke ${index + 1}'),
                    subtitle: Text(
                      'Type: ${_getInkTypeName(stroke['inkType'])}, '
                      'Color: ${stroke['color']}, '
                      'Points: ${stroke['pathPoints']?.length ?? 0}',
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow('Ink Type', _getInkTypeName(stroke['inkType'])),
                            _buildInfoRow('Color', stroke['color']),
                            _buildInfoRow('Points Count', '${stroke['pathPoints']?.length ?? 0}'),
                            if (stroke['transform'] != null) ...[
                              const SizedBox(height: 8),
                              const Text(
                                'Transform Matrix:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              _buildTransformInfo(stroke['transform']),
                            ],
                            if (stroke['pathPoints'] != null && stroke['pathPoints'].isNotEmpty) ...[
                              const SizedBox(height: 8),
                              const Text(
                                'Sample Points (first 3):',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              ..._buildSamplePoints(stroke['pathPoints']),
                            ],
                            if (stroke['mask'] != null) ...[
                              const SizedBox(height: 8),
                              _buildInfoRow('Has Mask', 'Yes (${stroke['mask'].length} path elements)'),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildTransformInfo(Map<String, dynamic> transform) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('a: ${transform['a']?.toStringAsFixed(3)}'),
          Text('b: ${transform['b']?.toStringAsFixed(3)}'),
          Text('c: ${transform['c']?.toStringAsFixed(3)}'),
          Text('d: ${transform['d']?.toStringAsFixed(3)}'),
          Text('tx: ${transform['tx']?.toStringAsFixed(3)}'),
          Text('ty: ${transform['ty']?.toStringAsFixed(3)}'),
        ],
      ),
    );
  }

  List<Widget> _buildSamplePoints(List<dynamic> pathPoints) {
    final sampleCount = pathPoints.length > 3 ? 3 : pathPoints.length;
    return List.generate(sampleCount, (index) {
      final point = pathPoints[index] as Map<String, dynamic>;
      final location = point['location'] as Map<String, dynamic>;
      final size = point['size'] as Map<String, dynamic>;
      
      return Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Point ${index + 1}:'),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Location: (${location['x']?.toStringAsFixed(2)}, ${location['y']?.toStringAsFixed(2)})'),
                  Text('Size: ${size['width']?.toStringAsFixed(2)} × ${size['height']?.toStringAsFixed(2)}'),
                  Text('Force: ${point['force']?.toStringAsFixed(3)}'),
                  Text('Opacity: ${point['opacity']?.toStringAsFixed(3)}'),
                  Text('Time: ${point['timeOffset']?.toStringAsFixed(3)}s'),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  String _getInkTypeName(dynamic inkType) {
    if (inkType == null) return 'Unknown';
    
    // PKInkType enum values
    switch (inkType) {
      case 0:
        return 'Pen';
      case 1:
        return 'Pencil';
      case 2:
        return 'Marker';
      case 3:
        return 'Monoline';
      case 4:
        return 'Fountain Pen';
      case 5:
        return 'Watercolor';
      case 6:
        return 'Crayon';
      default:
        return 'Unknown ($inkType)';
    }
  }
}