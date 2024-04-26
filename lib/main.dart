import 'package:flutter/material.dart';
import 'read.dart';
import 'list.dart';

void main() {
  runApp(const MyApp());//const는 한번올리면 안바꾸겠다는것. const new MyApp임. MyApp은 생성자다
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: "/list",
      routes: { //{키:값}인 Map이다.
        "/read": (context)=> ReadPage(),//(context)=>{ return Ex01(){}}//원래는 이런 익명함수이다.//파일이름이 아닌 클래스 이름. 즉 생성자를 써줘야한다.
        "/list": (context)=> ListPage(),
      },

    );
  }
}


