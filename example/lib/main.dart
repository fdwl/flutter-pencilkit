// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pencil_kit/pencil_kit.dart';

import 'strokes_viewer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final PencilKitController controller;
  ToolType currentToolType = ToolType.pen;
  double currentWidth = 1;
  Color currentColor = Colors.black;
  String base64Image = '';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          textButtonTheme: const TextButtonThemeData(
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              padding: WidgetStatePropertyAll(
                EdgeInsets.all(8),
              ),
            ),
          ),
          visualDensity: VisualDensity.compact),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('PencilKit'),
          actions: [
            IconButton(
              icon: const Icon(Icons.palette),
              onPressed: () => controller.show(),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => controller.hide(),
            ),
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed: () => controller.undo(),
            ),
            IconButton(
              icon: const Icon(Icons.redo),
              onPressed: () => controller.redo(),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => controller.clear(),
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SingleChildScrollView(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.save),
                        onPressed: () async {
                          final Directory documentDir =
                              await getApplicationDocumentsDirectory();
                          final String pathToSave =
                              '${documentDir.path}/drawing';
                          try {
                            final data = await controller.save(
                                uri: pathToSave, withBase64Data: true);
                            if (kDebugMode) {
                              print(data);
                            }
                            Fluttertoast.showToast(
                                msg: "Save Success to [$pathToSave]",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.blueAccent,
                                textColor: Colors.white,
                                fontSize: 12.0);
                          } catch (e) {
                            Fluttertoast.showToast(
                                msg: "Save Failed to [$pathToSave]",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.redAccent,
                                textColor: Colors.white,
                                fontSize: 12.0);
                          }
                        },
                        tooltip: "Save",
                      ),
                      IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () async {
                          final Directory documentDir =
                              await getApplicationDocumentsDirectory();
                          final String pathToLoad =
                              '${documentDir.path}/drawing';
                          try {
                            final data = await controller.load(
                                uri: pathToLoad, withBase64Data: true);
                            if (kDebugMode) {
                              print(data);
                            }
                            Fluttertoast.showToast(
                                msg: "Load Success from [$pathToLoad]",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.blueAccent,
                                textColor: Colors.white,
                                fontSize: 12.0);
                          } catch (e) {
                            Fluttertoast.showToast(
                                msg: "Load Failed from [$pathToLoad]",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.redAccent,
                                textColor: Colors.white,
                                fontSize: 12.0);
                          }
                        },
                        tooltip: "Load",
                      ),
                      IconButton(
                        icon: const Icon(Icons.print),
                        onPressed: () async {
                          final data = await controller.getBase64Data();
                          Fluttertoast.showToast(
                              msg: data,
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.blueAccent,
                              textColor: Colors.white,
                              fontSize: 12.0);
                        },
                        tooltip: "Get base64 data",
                      ),
                      IconButton(
                        icon: const Icon(Icons.image),
                        onPressed: () async {
                          final data = await controller.getBase64PngData();
                          setState(() {
                            base64Image = data;
                          });
                        },
                        tooltip: "Get base64 png data",
                      ),
                      IconButton(
                        icon: const Icon(Icons.image),
                        onPressed: () async {
                          final data = await controller.getBase64JpegData();
                          setState(() {
                            base64Image = data;
                          });
                        },
                        tooltip: "Get base64 jpeg data",
                      ),
                      IconButton(
                        icon: const Icon(Icons.data_array),
                        onPressed: () async {
                          try {
                            final strokes = await controller.getStrokes();
                            
                            // Check if this is an error response (iOS 13.x)
                            if (strokes.length == 1 && strokes[0].containsKey('error')) {
                              print('Error: ${strokes[0]['error']}');
                              print('Current Version: ${strokes[0]['currentVersion']}');
                              print('Suggestion: ${strokes[0]['suggestion']}');
                              
                              Fluttertoast.showToast(
                                  msg: "Strokes data requires iOS 14.0+",
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.orangeAccent,
                                  textColor: Colors.white,
                                  fontSize: 12.0);
                              return;
                            }
                            
                            print('Total strokes: ${strokes.length}');
                            for (int i = 0; i < strokes.length; i++) {
                              final stroke = strokes[i];
                              print('Stroke $i:');
                              print('  Ink type: ${stroke['inkType']}');
                              print('  Color: ${stroke['color']}');
                              print('  Points count: ${stroke['pathPoints']?.length ?? 0}');
                              if (stroke['transform'] != null) {
                                final transform = stroke['transform'] as Map;
                                print('  Transform: [${transform['a']}, ${transform['b']}, ${transform['c']}, ${transform['d']}, ${transform['tx']}, ${transform['ty']}]');
                              }
                            }
                            Fluttertoast.showToast(
                                msg: "Got ${strokes.length} strokes data (check console)",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.blueAccent,
                                textColor: Colors.white,
                                fontSize: 12.0);
                          } catch (e) {
                            print('Error getting strokes: $e');
                            Fluttertoast.showToast(
                                msg: "Failed to get strokes data",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.redAccent,
                                textColor: Colors.white,
                                fontSize: 12.0);
                          }
                        },
                        tooltip: "Get strokes data",
                      ),
                      IconButton(
                        icon: const Icon(Icons.list_alt),
                        onPressed: () async {
                          try {
                            final strokes = await controller.getStrokes();
                            if (!mounted) return;
                            
                            // Check if this is an error response (iOS 13.x)
                            if (strokes.length == 1 && strokes[0].containsKey('error')) {
                              if (context.mounted) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Feature Not Available'),
                                    content: Text(
                                      '${strokes[0]['error']}\n\n'
                                      'Current: ${strokes[0]['currentVersion']}\n'
                                      'Suggestion: ${strokes[0]['suggestion']}'
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return;
                            }
                            
                            if (context.mounted) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => StrokesViewer(strokes: strokes),
                                ),
                              );
                            }
                          } catch (e) {
                            print('Error getting strokes: $e');
                            Fluttertoast.showToast(
                                msg: "Failed to get strokes data",
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.redAccent,
                                textColor: Colors.white,
                                fontSize: 12.0);
                          }
                        },
                        tooltip: "View strokes details",
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        children: [
                      ToolType.pen,
                      ToolType.pencil,
                      ToolType.marker,
                      ToolType.monoline,
                      ToolType.fountainPen,
                      ToolType.watercolor,
                      ToolType.crayon
                    ]
                            .map(
                              (e) => TextButton(
                                onPressed: () {
                                  setState(() {
                                    currentToolType = e;
                                    controller.setPKTool(
                                      toolType: e,
                                      width: currentWidth,
                                      color: currentColor,
                                    );
                                  });
                                },
                                child: Text(
                                    '${e.name}${e.isAvailableFromIos17 ? ' (iOS17)' : ''}'),
                              ),
                            )
                            .toList())),
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              currentToolType = ToolType.eraserVector;
                              controller.setPKTool(
                                toolType: currentToolType,
                                width: currentWidth,
                                color: currentColor,
                              );
                            });
                          },
                          child: const Text('Vector Eraser'),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              currentToolType = ToolType.eraserBitmap;
                              controller.setPKTool(
                                toolType: currentToolType,
                                width: currentWidth,
                                color: currentColor,
                              );
                            });
                          },
                          child: const Text('Bitmap Eraser'),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              currentToolType = ToolType.eraserFixedWidthBitmap;
                              controller.setPKTool(
                                toolType: currentToolType,
                                width: currentWidth,
                                color: currentColor,
                              );
                            });
                          },
                          child:
                              const Text('FixedWidthBitmap Eraser(iOS 16.4)'),
                        ),
                      ],
                    )),
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        IconButton(
                          icon: Container(
                            color: Colors.black,
                            width: 12,
                            height: 1,
                          ),
                          onPressed: () {
                            setState(() {
                              currentWidth = 1;
                              controller.setPKTool(
                                toolType: currentToolType,
                                width: currentWidth,
                                color: currentColor,
                              );
                            });
                          },
                        ),
                        IconButton(
                          icon: Container(
                            color: Colors.black,
                            width: 12,
                            height: 3,
                          ),
                          onPressed: () {
                            setState(() {
                              currentWidth = 3;
                              controller.setPKTool(
                                toolType: currentToolType,
                                width: currentWidth,
                                color: currentColor,
                              );
                            });
                          },
                        ),
                        IconButton(
                          icon: Container(
                            color: Colors.black,
                            width: 12,
                            height: 5,
                          ),
                          onPressed: () {
                            setState(() {
                              currentWidth = 5;
                              controller.setPKTool(
                                toolType: currentToolType,
                                width: currentWidth,
                                color: currentColor,
                              );
                            });
                          },
                        ),
                        const VerticalDivider(),
                        IconButton(
                          icon: const Icon(
                            Icons.lens,
                            color: Colors.orange,
                          ),
                          onPressed: () {
                            setState(() {
                              currentColor = Colors.orange;
                              controller.setPKTool(
                                toolType: currentToolType,
                                width: currentWidth,
                                color: currentColor,
                              );
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.lens,
                            color: Colors.purpleAccent,
                          ),
                          onPressed: () {
                            setState(() {
                              currentColor = Colors.purpleAccent;
                              controller.setPKTool(
                                toolType: currentToolType,
                                width: currentWidth,
                                color: currentColor,
                              );
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.lens,
                            color: Colors.greenAccent,
                          ),
                          onPressed: () {
                            setState(() {
                              currentColor = Colors.greenAccent;
                              controller.setPKTool(
                                toolType: currentToolType,
                                width: currentWidth,
                                color: currentColor,
                              );
                            });
                          },
                        ),
                      ],
                    )),
                Expanded(
                  child: PencilKit(
                    onPencilKitViewCreated: (controller) =>
                        this.controller = controller,
                    alwaysBounceVertical: false,
                    alwaysBounceHorizontal: true,
                    isRulerActive: false,
                    drawingPolicy: PencilKitIos14DrawingPolicy.anyInput,
                    backgroundColor: Colors.yellow.withValues(alpha: 0.1),
                    isOpaque: false,
                    toolPickerVisibilityDidChange: (isVisible) =>
                        print('toolPickerVisibilityDidChange $isVisible'),
                    toolPickerIsRulerActiveDidChange: (isRulerActive) => print(
                        'toolPickerIsRulerActiveDidChange $isRulerActive'),
                    toolPickerFramesObscuredDidChange: () =>
                        print('toolPickerFramesObscuredDidChange'),
                    toolPickerSelectedToolDidChange: () =>
                        print('toolPickerSelectedToolDidChange'),
                    canvasViewDidBeginUsingTool: () =>
                        print('canvasViewDidBeginUsingTool'),
                    canvasViewDidEndUsingTool: () =>
                        print('canvasViewDidEndUsingTool'),
                    canvasViewDrawingDidChange: () =>
                        print('canvasViewDrawingDidChange'),
                    canvasViewDidFinishRendering: () =>
                        print('canvasViewDidFinishRendering'),
                  ),
                ),
              ],
            ),
            if (base64Image.isNotEmpty)
              Positioned(
                  bottom: 128,
                  right: 24,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12),
                        ),
                        border: Border.all(color: Colors.black12)),
                    child: Image.memory(
                      base64Decode(base64Image),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
