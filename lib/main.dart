import 'package:ditredi/ditredi.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:rxdart/subjects.dart';
import 'presentationals/widgets/face_detector/face_detector.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
    ),
  );
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Stack(
        children: [
          FaceDetectorView(
            onFaceDetected: (face) {
              if (face.headEulerAngleX != null) {
                FaceTrackerBloc.main.face.add(face);
              }
            },
          ),
          const IgnorePointer(child: TestRender()),
        ],
      ),
    );
  }
}

class TestRender extends StatefulWidget {
  const TestRender({
    super.key,
  });
  @override
  State<TestRender> createState() => _TestRenderState();
}

class _TestRenderState extends State<TestRender> {
  DiTreDiController model3DController = DiTreDiController(
    rotationX: -90,
    rotationY: 0,
    rotationZ: 0,
  );
  @override
  void initState() {
    super.initState();
    FaceTrackerBloc.main.face.listen((value) {
      if (value?.headEulerAngleX != null) {
        model3DController.update(rotationX: value!.headEulerAngleX! - 90);
      }
      if (value?.headEulerAngleY != null) {
        model3DController.update(rotationY: value!.headEulerAngleY!);
      }
      if (value?.headEulerAngleZ != null) {
        model3DController.update(rotationZ: value!.headEulerAngleZ!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future:
            ObjParser().loadFromResources("assets/glasses/circle_glasses.obj"),
        builder: (context, snapshot) {
          return (snapshot.data != null)
              ? DiTreDi(
                  controller: model3DController,
                  figures: [
                    Mesh3D(snapshot.data!),
                  ],
                )
              : Container();
        });
  }
}

class FaceTrackerBloc {
  static FaceTrackerBloc main = FaceTrackerBloc();
  BehaviorSubject<Face?> face = BehaviorSubject<Face?>.seeded(null);
}
