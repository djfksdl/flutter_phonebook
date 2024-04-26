import 'dart:async';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'personVo.dart';

class ReadPage extends StatelessWidget {
  const ReadPage({super.key});

  //기본레이아웃
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("읽기 페이지"),
        ),
        body: Container(
          padding: EdgeInsets.all(15),
          color: Color(0xFFd6d6d6),
          child: _ReadPage(),
        )
    );
  }
}

/*
  StatelessWidget --> 정적인 페이지

  StatefulWidget

  jsp(js객체) (자동) <-- json --> (자동) (java)springboot
  Vue(js객체) (자동) <-- json --> (자동) springboot


 */

//상태 변화를 감시하게 등록시키는 클래스
class _ReadPage extends StatefulWidget {
  //외부에서 쓸 필요없이 이 페이지에서만 쓸꺼라 private하게 바꿔줌.
  const _ReadPage({super.key});

  //  메소드
  @override
  State<_ReadPage> createState() => _ReadPageState();
}

//할일 정의 클래스(통신, 데이터 적용)
class _ReadPageState extends State<_ReadPage> {

  //라우터로 전달받은 personId
  // final args = ModalRoute.of(context)!.settings.arguments as Map; // as Map은 형변환 -> 오류나는 이유 : 빌드가 되어야 context가 완성이 되기때문에 지금 상태에서는 context가 없어서 못가져온다.

  //미래의 정우서 데이터가 담길거야
  late Future<PersonVo> personVoFuture; //실시간이 아닌 미래 개념이라 담길수도 안담길수도 있음. 그래서 late 붙이면 시점이 끝날때 담아준다.

  //초기화함수 (1번만 실행됨)
  @override
  void initState() {
    super.initState();

    print("build():데이터 가져오기 전");
    //필요시 추가 코드  //데이터 불러오기 메소드 호출
    // personVoFuture = getPersonByNo();//번호를 알아내서 먼저 가져와야하는데 밑에 context가 먼저 알아서 가져오게 됨. 근데 실행은 얘가 먼저됨. 그래서 밑에 build할때 넣어줌

    print("build():데이터 가져온 후");
  }

  //화면 그리기
  @override
  Widget build(BuildContext context) {

    //ModalRoute를 통해 현재 페이지에 전달된  arguments를 가져옵니다.
    late final args = ModalRoute.of(context)!.settings.arguments as Map;
    //'personId'키를 사용하여 값을 추출함
    late final personId = args['personId'];
    personVoFuture = getPersonByNo(personId);
    print("---------------");
    print(personId);
    print("---------------");

    print("build():그리기 작업");
    return FutureBuilder(
      future: personVoFuture, //Future<> 함수명, 으로 받은 데이타
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('데이터를 불러오는 데 실패했습니다.'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('데이터가 없습니다.'));
        } else { //데이터가 있으면
          return Column(

              children: [

                Row(
                  children: [
                    Container(
                        width: 100,
                        height: 50,
                        alignment: Alignment.centerLeft,
                        // snapshot.data!.personId //!는 백프로 널이 아니다.라는 뜻
                        color: Color(0xFFffffff),
                        child: Text("번호", style: TextStyle(fontSize: 20),)),
                    Container(
                        width: 360,
                        height: 50,
                        alignment: Alignment.centerLeft,
                        color: Color(0xFFffffff),
                        child: Text("${snapshot.data!.personId}", style: TextStyle(fontSize: 20),))
                  ],
                ),
                Row(
                  children: [
                    Container(
                        width: 100,
                        height: 50,
                        alignment: Alignment.centerLeft,
                        color: Color(0xFFffffff),
                        child: Text("이름", style: TextStyle(fontSize: 20),)),
                    Container(
                        width: 360,
                        height: 50,
                        alignment: Alignment.centerLeft,
                        color: Color(0xFFffffff),
                        child: Text("${snapshot.data!.name}", style: TextStyle(fontSize: 20),))
                  ],
                ),
                Row(
                  children: [
                    Container(
                        width: 100,
                        height: 50,
                        alignment: Alignment.centerLeft,
                        color: Color(0xFFffffff),
                        child: Text("핸드폰", style: TextStyle(fontSize: 20),)),
                    Container(
                        width: 360,
                        height: 50,
                        alignment: Alignment.centerLeft,
                        color: Color(0xFFffffff),
                        child: Text(
                          "${snapshot.data!.hp}", style: TextStyle(fontSize: 20),))
                  ],
                ),
                Row(
                  children: [
                    Container(
                        width: 100,
                        height: 50,
                        alignment: Alignment.centerLeft,
                        color: Color(0xFFffffff),
                        child: Text("회사", style: TextStyle(fontSize: 20),)),
                    Container(
                        width: 360,
                        height: 50,
                        alignment: Alignment.centerLeft,
                        color: Color(0xFFffffff),
                        child: Text(
                          "${snapshot.data!.company}", style: TextStyle(fontSize: 20),))
                  ],
                ),
              ],
            );


      } // 데이터가있으면
      },
    );
    ;
  }

  //3번(정우성) 데이터 가져오기 return 그림x
  Future<PersonVo> getPersonByNo(int pId) async {
    print("데이터 가져오는 중");
    try {
      /*----요청처리-------------------*/
      //Dio 객체 생성 및 설정
      var dio = Dio();

      // 헤더설정:json으로 전송
      dio.options.headers['Content-Type'] = 'application/json';

      // 서버 요청
      final response = await dio.get(
        'http://15.164.245.216:9000/api/persons/${pId}',
        // 'http://localhost:9000/api/phonebooks/5', --Map으로는 제대로 json으로 바뀔지는 미지수임. Vo로 바꾸는게 좋을듯
      );

      /*----응답처리-------------------*/
      if (response.statusCode == 200) {
        //접속성공 200 이면
        print(response); // json->map 자동변경
        // print(response.data["apiData"]); // 자동변경
        // return response.data; --json으로 안보냈을땐 요걸로
        return PersonVo.fromJson(response.data["apiData"]);
      } else {
        //접속실패 404, 502등등 api서버 문제
        throw Exception('api 서버 문제');
      }
    } catch (e) {
      //예외 발생
      throw Exception('Failed to load person: $e');
    }
  }
}