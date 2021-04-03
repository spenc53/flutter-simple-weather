import 'dart:math';

import 'package:flutter/gestures.dart';
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
  GlobalKey _paintKey = new GlobalKey();
  int mouseLoc = -1;

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
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var padding = MediaQuery.of(context).padding;
    double newheight = height - padding.top - padding.bottom;
    double newwidth = width - padding.left - padding.right;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 149, 165, 165),
      body: new Listener(
        onPointerHover: (PointerHoverEvent event) {
          double yPos = (newheight - event.position.dy) / newheight;
          double temp = (1 - ((newwidth - event.position.dx) / newwidth)) * 8;
          int newMouseLoc = temp.round();
          if (yPos >= .38) {
            newMouseLoc = -1;
          }
          setState(() {mouseLoc = newMouseLoc;});
        },
        child: SafeArea(
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
                        'Seattle',
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
                    '47 F',
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.white70,
                      fontWeight: FontWeight.w900
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  child: Text(
                    'Saturday 9 AM',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white70
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
                            key: _paintKey,
                            painter: TempCurvePainter(animation.value, mouseLoc),
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
      ),
    );
  }
}

class TempCurvePainter extends CustomPainter {
  final double progress;
  final int selected;
  TempCurvePainter(this.progress, this.selected);

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
    List<String> xData = [
      '9 AM',
      '10 AM',
      '11 AM',
      '12 PM',
      '1 PM',
      '2 PM',
      '3 PM',
      '4 PM',
      '5 PM',
    ];
    List<double> yData = [46, 46, 50, 54, 55, 57, 57, 59, 57].map((e) => e.toDouble()).toList();
    double maxNum = yData.reduce(max).toDouble();
    double minNum = yData.reduce(min).toDouble();
    double divisor = maxNum - minNum;
    List<double> ys = yData.map((e) => ((e - minNum) / (divisor)).toDouble()).toList();
    ys = ys.map((e) => ((-9 * (e * heightInterval) + size.height)) - 10).toList();
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

    if (selected == -1) {
      return;
    }


    paint.style = PaintingStyle.fill;
    canvas.drawCircle(new Offset(xs[selected], ys[selected]), 10.0, paint);

    TextSpan span = new TextSpan(style: new TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500), text: "${xData[selected]}\n${yData[selected]} F");
    TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, new Offset(xs[selected] - tp.size.width / 2, ys[selected] - 70));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

