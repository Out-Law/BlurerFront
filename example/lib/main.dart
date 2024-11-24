import 'dart:async' show Completer;
import 'dart:typed_data' show Uint8List, BytesBuilder;
import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

import 'GridDialog.dart';
import 'HighlightedContainer.dart';
import 'TextInputExample.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late DropzoneViewController controller1;
  String message1 = 'Перетащите файл сюда';
  bool highlighted1 = false;
  String? videoUrl = "";
  late VideoPlayerController _videoPlayerController;
  bool _isPlaying = false;
  bool _isLoading = false;
  String header = "Видео загрузка и просмотр";
  bool _isSwitched = false;
  bool openClousDiolog = false;
  String model = "";
  String _umodel = "";
  List<String> models = [];
  Uint8List? fileDataProt = null;
  Uint8List? fileDataCafe = null;

  bool typeOne = false;
  bool typeTwo = false;
  String filenameProt = "";
  String filenameCafe = "";

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData.dark(),
    home: Scaffold(
      appBar: AppBar(
        title: Text(header),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Switch(
                value: _isSwitched,
                onChanged: (value) {
                  setState(() {
                    _isSwitched = value;
                    openClousDiolog = false;
                    if(_isSwitched){
                      header = "Загрузка моделей";
                    }
                    else{
                      header = "Видео загрузка и просмотр";
                    }
                  });
                },
                activeTrackColor: Colors.lightGreenAccent, // цвет трека при включении
                activeColor: Colors.green, // цвет переключателя при включении
              ),
              const SizedBox(height: 20),
              Visibility(
                visible: !_isSwitched,
                child: ElevatedButton(
                  onPressed: () {
                    getModels();
                    setState(() {
                      openClousDiolog = !openClousDiolog;
                    });
                  },
                  child: _umodel == "" ? Text('Показать модели') : Text(_umodel),
                ),
              ),
              Visibility(
                  visible: _isSwitched,
                  child: TextInputExample(onTextSaved: (String value) {
                      model = value;
                  })
              ),
              Visibility(
                visible: !_isSwitched,
                child: Expanded(
                  child: HighlightedContainer(
                    highlighted: highlighted1, // Указывает состояние выделения
                    message: 'Upload your file here', // Сообщение
                    child: buildZone1(
                        context, (String fileName, Uint8List fileData) async {
                          uploadFile(fileName, fileData);
                        }
                    ), // Дочерний виджет
                  ),
                ),
              ),
              Visibility(
                visible: _isSwitched,
                child: Expanded(
                    child: HighlightedContainer(
                      highlighted: typeOne, // Указывает состояние выделения
                      message: 'Загрузите Prototxt файл', // Сообщение
                      child: buildZone1(
                          context, (String fileName, Uint8List fileData) async {
                            fileDataProt = fileData;
                            filenameProt = fileName;
                            setState(() {
                              typeOne = true;
                            });
                          }
                      ),
                    ),
                ),
              ),
              Visibility(
                visible: _isSwitched,
                child: Expanded(
                    child: HighlightedContainer(
                      highlighted: typeTwo, // Указывает состояние выделения
                      message: 'Загрузите caffe файл', // Сообщение
                      child: buildZone1(
                        context, (String fileName, Uint8List fileData) async {
                          fileDataCafe = fileData;
                          filenameCafe = fileName;
                          setState(() {
                            typeTwo = true;
                          });
                        }
                      ),
                    ),
                ),
              ),
              Visibility(
                visible: _isSwitched,
                child: ElevatedButton(
                  onPressed: () {
                    uploadModels(model, filenameCafe, fileDataCafe!, filenameProt, fileDataProt!);
                    setState(() {
                      typeOne = false;
                      typeTwo = false;
                    });
                  },
                  child: Text('Загрузить'),
                ),
              ),
              Visibility(
                visible: !_isSwitched,
                child: Visibility(
                  visible: _videoPlayerController.value.isInitialized,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: (){
                          _initializeVideoPlayer(videoUrl!);
                          _videoPlayerController.pause();
                          _isPlaying = false;
                        },
                        icon: const Icon(Icons.restart_alt),
                        label: const Text(' Restart'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: (){
                          html.window.open(videoUrl!, '_blank');
                        },
                        icon: const Icon(Icons.arrow_circle_down),
                        label: const Text(' Download'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Отображаем видео ниже
              if (videoUrl != null)
                _videoPlayerController.value.isInitialized
                    ? Visibility(
                  visible: !_isSwitched,
                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                      SizedBox(
                        width: 500,
                        height: 400,
                        child: VideoPlayer(_videoPlayerController),
                      ),
                      IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 50,
                        ),
                        onPressed: () {
                          setState(() {
                            if (_isPlaying) {
                              _videoPlayerController.pause();
                            } else {
                              _videoPlayerController.play();
                            }
                            _isPlaying = !_isPlaying;
                          });
                        },
                      ),
                                        ],
                                      ),
                    ) : Container(),
            ],
          ),

          GridDialogExample(
            openClousDialog: openClousDiolog,
            items: models,
            onItemTap: (String model) {
              _umodel = model;
              setState(() {
                openClousDiolog = false;
              });
            },
          ),

          // Полупрозрачный слой, который появляется при загрузке
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5), // Полупрозрачный черный фон
                child: Center(
                  child: CircularProgressIndicator(), // Индикатор загрузки
                ),
              ),
            ),
        ],
      ),
    ),
  );

  /*Widget buildZone1(BuildContext context) => DropzoneView(
    operation: DragOperation.copy,
    cursor: CursorType.grab,
    onCreated: (ctrl) => controller1 = ctrl,
    onLoaded: () => print('Zone 1 loaded'),
    onError: (error) => print('Zone 1 error: $error'),
    onHover: () => setState(() => highlighted1 = true),
    onLeave: () => setState(() => highlighted1 = false),
    onDropFile: (file) async {
      print('Zone 1 drop: ${file.name}');
      setState(() {
        highlighted1 = false;
      });
      final bytes = await controller1.getFileData(file);
      await uploadFile(file.name, bytes);
    },
    onDropInvalid: (mime) => print('Zone 1 invalid MIME: $mime'),
  );*/

  Widget buildZone1(BuildContext context,
      Future<void> Function(String fileName, Uint8List fileData) uploadCallback) {
    return DropzoneView(
      operation: DragOperation.copy,
      cursor: CursorType.grab,
      onCreated: (ctrl) => controller1 = ctrl,
      onLoaded: () => print('Zone 1 loaded'),
      onError: (error) => print('Zone 1 error: $error'),
      onHover: () => setState(() => highlighted1 = true),
      onLeave: () => setState(() => highlighted1 = false),
      onDropFile: (file) async {
        print('Zone 1 drop: ${file.name}');
        setState(() {
          highlighted1 = false;
        });
        final bytes = await controller1.getFileData(file);
        final name = await controller1.getFilename(file);
        // Now we use the passed callback to upload the file
        await uploadCallback(file.name, bytes);
      },
      onDropInvalid: (mime) => print('Zone 1 invalid MIME: $mime'),
    );
  }


  Future<void> uploadFile(String fileName, Uint8List bytes) async {
    const uploadUrl = 'http://localhost:8080/api/videos/upload';
    final client = http.Client();
    setState(() {
      videoUrl = null;
      _isLoading = true; // Начинаем загрузку, показываем индикатор
    });
    try {
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl))
        ..fields['fileName'] = fileName
        ..fields['objectType'] = _umodel
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
        ));
      final response = await client.send(request).timeout(Duration(seconds: 120));
      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(body);
        setState(() {
          videoUrl = "http://localhost:8080/api/videos/" + jsonResponse['fileName'];
          _initializeVideoPlayer(videoUrl!);
        });
        print('Файл успешно загружен!');
      } else {
        print('Ошибка загрузки: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка при загрузке файла: $e');
    } finally {
      setState(() {
        _isLoading = false; // Заканчиваем загрузку, скрываем индикатор
      });
    }
  }

  Future<void> uploadModels(String objectType, String filenameCafe, Uint8List caffe, String filenameProto, Uint8List protoFile) async {
    const uploadUrl = 'http://localhost:8080/api/models/upload';

    final client = http.Client();
    setState(() {
      videoUrl = null;
      _isLoading = true; // Начинаем загрузку, показываем индикатор
    });

    try {
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl))
        ..fields['objectType'] = objectType  // Добавляем параметр в запрос
        ..files.add(http.MultipartFile.fromBytes(
          'protoFile',       // Имя параметра для первого файла
          protoFile,
          filename: filenameProto,
        ))
        ..files.add(http.MultipartFile.fromBytes(
          'caffeFile',       // Имя параметра для второго файла
          caffe,
          filename: filenameCafe,
        ));

      final response = await client.send(request).timeout(Duration(seconds: 120));

      if (response.statusCode == 200) {
        print('Файлы успешно загружены!');
      } else {
        print('Ошибка загрузки: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка при загрузке файлов: $e');
    } finally {
      setState(() {
        _isLoading = false; // Заканчиваем загрузку, скрываем индикатор
      });
    }
  }

  Future<void> getModels() async {
    const uploadUrl = 'http://localhost:8080/api/models'; // URL для GET запроса

    final client = http.Client();
    /*setState(() {
      _isLoading = true; // Начинаем загрузку, показываем индикатор
    });*/

    try {
      // Выполняем GET запрос
      final response = await client.get(Uri.parse(uploadUrl)).timeout(Duration(seconds: 120));

      if (response.statusCode == 200) {
        // Если статус 200, парсим тело ответа
        final body = response.body;
        final List<dynamic> jsonResponse = jsonDecode(body); // Преобразуем в список

        // Преобразуем динамический список в список строк
        models = List<String>.from(jsonResponse.map((item) => item.toString()));

        setState(() {
        });
       /* setState(() {
          _isLoading = false; // Заканчиваем загрузку, скрываем индикатор
        });*/

      } else {
        // В случае ошибки выводим статус ошибки
        print('Ошибка при получении данных: ${response.statusCode}');
      }
    } catch (e) {
      // Если произошла ошибка
      print('Ошибка при запросе данных: $e');
    } finally {
      /*setState(() {
        _isLoading = false; // Заканчиваем загрузку, скрываем индикатор
      });*/
    }
  }

  // Функция для инициализации VideoPlayer
  void _initializeVideoPlayer(String videoUrl) {
    _videoPlayerController = VideoPlayerController.network(videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.file(
        'http://localhost:8080/api/videos/5bf8b2a8-a4f8-4549-9e39-f4dadafbfb11.mp4')
    )..initialize().then((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController.dispose();
  }
}

