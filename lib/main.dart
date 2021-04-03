import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key) {
    this.temp = 75.toString();
  }

  final String title;
  String temp;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {

  Animation<double> animation;
  AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1)
    );

    Tween<double> _heightTween = Tween(begin: 0.0, end: 1.0);

    animation = _heightTween.animate(controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // controller.repeat();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });
    
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   elevation: 0,
      // ),
      backgroundColor: Color.fromARGB(255, 149, 165, 165),
      body: SafeArea(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 30, left: 15, right: 15),
              child: Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(Icons.menu, size: 40),
                    Text(
                      'Bothell',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white60,
                        letterSpacing: 2,
                      ),
                    ),
                    Icon(
                      Icons.more_vert,
                      size: 40,
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Container(
                child: Icon(
                  Icons.wb_sunny_outlined,
                  size: 140,
                  color: Colors.white60,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Container(
                child: Text(
                  'Sunday 8 AM',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w300
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        child: CustomPaint(
                          painter: TempCurvePainter(animation.value),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class TempCurvePainter extends CustomPainter {
  final double progress;
  TempCurvePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.blueGrey;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 4;

    var path = Path();

    double widthInterval = size.width / 8;
    double heightInterval = size.height / 20;
    List<double> xs =
        [0, 1, 2, 3, 4, 5, 6, 7, 8].map((e) => (e * widthInterval).toDouble()).toList();
    List<double> ys = [1, 3, 4, 7, 6, 5, 4, 2, 0].map((e) => e * this.progress).toList();
    double maxNum = ys.reduce(max);
    ys = ys.map((e) => (((maxNum - e) * heightInterval) + size.height - (maxNum + 1) * heightInterval).toDouble()).toList();
    path.moveTo(xs[0], ys[0]);

    for (var i = 0; i < xs.length - 1; i++) {
      var x_mid = (xs[i] + xs[i + 1]) / 2;
      var y_mid = (ys[i] + ys[i + 1]) / 2;
      var cp_x1 = (x_mid + xs[i]) / 2;
      var cp_x2 = (x_mid + xs[i + 1]) / 2;
      path.quadraticBezierTo(cp_x1, ys[i], x_mid, y_mid);
      path.quadraticBezierTo(cp_x2, ys[i + 1], xs[i + 1], ys[i + 1]);
    }

    // path.quadraticBezierTo(interval * i, ys[i], midPointX, midPointY);

    // path.lineTo(size.width, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

