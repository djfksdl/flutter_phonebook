import 'dart:async';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'personVo.dart';

class ListPage extends StatelessWidget {//생성자명이고
  const ListPage({super.key}); //요거 9:55

  //기본레이아웃
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("리스트 페이지"),),
      body: Container(
            padding: EdgeInsets.all(15),
            color: Color(0xFFd6d6d6),
            child: _ListPage() //여기에 위젯을 놓으면 등록하고 밑에 설정한것들 줄줄히 하게 됨
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.pushNamed(context, "/write");
        },
        child: Icon(Icons.add) ,),
    ) ;
  }
}

//등록
class _ListPage extends StatefulWidget {
  const _ListPage({super.key});

  @override
  State<_ListPage> createState() => _ListPageState();
}

//할일- 생애주기별로 언제 뭐하고가 나열됨. 독립적으로 하는것도 따로 빼서 메소드로 만들 수 있음.
class _ListPageState extends State<_ListPage> {

  //공통변수- data()같은 개념. 여기에 넣어두어야 여기저기서 뽑아 쓸수 있다.
  late Future<List<PersonVo>> personListFuture; //퓨처로 감싸져있어서 얘의 자료형도 한번 더 감싸놔야한다. 바로 쓸수 있는게 아니라 퓨쳐로 되어있음. 실시간으로 진행이 안될 수 있음을 계속 염두해두기

  //생애주기별 훅(타이밍에 딱)

  //초기화할때- 알트+인서트할때 부모꺼 오버라이드 쓰면 됨.
  @override
  void initState() {
    super.initState();
    personListFuture = getPersonList(); //공통변수에 있는 애를 일하게 시켜줌. 시점때문에 여기에 둔것. 메소드 사용!
  }

  //그림그릴때(build)
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: personListFuture, //Future<> 함수명, 으로 받은 데이타// 퓨처를 벗겨준다.
      builder: (context, snapshot) { //쓸 값이 snapshot에 들어가있다.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('데이터를 불러오는 데 실패했습니다.'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('데이터가 없습니다.'));
        } else { //데이터가 있으면
          return ListView.builder(//for문으로 돌리지 않고 이걸로 써야함.(why? for문이 안됨)
            itemCount: snapshot.data!.length, //몇개 가지고있는지 꼭 알려줘야함.
            itemBuilder: (BuildContext context, int index) { //여기에서 index로 i역할을 함.
              return Row(
                children: [
                  Container(
                      color: Color(0xFFffffff),
                      width: 50,
                      height: 40,
                      alignment: Alignment.centerLeft,
                      child: Text("${snapshot.data![index].personId}" ,style: TextStyle(fontSize: 20),)),
                  Container(
                      color: Color(0xFFffffff),
                      width: 100,
                      height: 40,
                      alignment: Alignment.centerLeft,
                      child: Text("${snapshot.data![index].name}",style: TextStyle(fontSize: 20),)),
                  Container(
                      color: Color(0xFFffffff),
                      width: 140,
                      height: 40,
                      alignment: Alignment.centerLeft,
                      child: Text("${snapshot.data![index].hp}",style: TextStyle(fontSize: 20),)),
                  Container(
                      color: Color(0xFFffffff),
                      width: 140,
                      height: 40,
                      alignment: Alignment.centerLeft,
                      child: Text("${snapshot.data![index].company}",style: TextStyle(fontSize: 20),)),
                  Container(
                      width: 40,
                      height: 40,
                      color: Color(0xFFffffff),
                      child: IconButton(onPressed: (){
                        print("${snapshot.data![index].personId}");
                        Navigator.pushNamed(context, "/read", arguments: {"personId":snapshot.data![index].personId});
                      }, icon: Icon(Icons.arrow_forward_ios)))
                ],
              ) ;
            },
          );
        } // 데이터가있으면
      },
    );
    ;
  }

  //리스트가져오기 dio통신 메소드 정의
  Future<List<PersonVo>> getPersonList() async {
    try {
      /*----요청처리-------------------*/
      //Dio 객체 생성 및 설정
      var dio = Dio();

      // 헤더설정:json으로 전송
      dio.options.headers['Content-Type'] = 'application/json';

      // 서버 요청
      final response = await dio.get(
        'http://localhost:9000/api/phonebooks',

      );

      /*----응답처리-------------------*/
      if (response.statusCode == 200) {
        //접속성공 200 이면
        print(response.data); // json->map 자동변경 response.data.length로하면 갯수나옴
        print(response.data.length);
        print(response.data[0]);
        // [map,map,map]으로 들어있음. 근데 우린 map이 아닌 {}객체로 들어있는게 편하다. map이면 키값을 자꾸 찾아줘야하기 때문.
        //그래서 map을 json으로 바꾸는걸 personVo.dart안에 설정해놨음!
        // return PersonVo.fromJson(response.data["apiData"]);

        //수신한 데이터 [map, map, map]
        //비어있는 리스트 생성[]
        //map -> {} 맵을 객체로 바꾼다. 변환
        //[{},{},{},{},{}]로 만들어야함
        List<PersonVo> personList = []; //personVo라는 생성자 쓰기 위해 파일 임포트 해주기
        for(int i=0; i<response.data.length; i++){
          PersonVo personVo= PersonVo.fromJson(response.data[i]); //personVo.dart안에 있는 fromJson이라는 메소드를 쓴거임!api쪽에서 JsonResult로 쓰건말건 상관없음!
          personList.add(personVo);
        }
        print(personList);
        return personList;

      } else {
        //접속실패 404, 502등등 api서버 문제
        throw Exception('api 서버 문제');
      }
    } catch (e) {
      //예외 발생
      throw Exception('Failed to load person: $e');
    }
  } //getPersonList()


}

