import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class Diary {
  String text; // 내용
  DateTime createdAt; // 작성 시간

  Diary({
    required this.text,
    required this.createdAt,
  });

  /// Diary -> Map 변경
  Map<String, dynamic> toJson() {
    return {
      "text": text,
      "createdAt": createdAt.toString(),
    };
  }

  /// Map -> Diary 변경
  factory Diary.fromJson(Map<String, dynamic> json) {
    return Diary(
      text: json["text"],
      createdAt: DateTime.parse(json["createdAt"]),
    );
  }
}

class DiaryService extends ChangeNotifier {
//생성자
  DiaryService(this.prefs) {
    // 생성자가 호출될 때 SharedPreferences로 저장해 둔 diaryList를 불러옵니다.
    // 저장할 때와 반대로 String -> Map -> Diary로 변환합니다.
    List<String> stringDiaryList = prefs.getStringList("diaryList") ?? [];
    for (String stringDiary in stringDiaryList) {
      //String-> Map
      Map<String, dynamic> jsonMap = jsonDecode(stringDiary);

      //Map -> Diary
      Diary diary = Diary.fromJson(jsonMap);
      diaryList.add(diary);
    }
  }

  /// SharedPreferences 인스턴스
  SharedPreferences prefs;

  /// Diary 목록
  List<Diary> diaryList = [];

  /// 특정 날짜의 diary 조회
  List<Diary> getByDate(DateTime date) {
    return diaryList
        .where((diary) => isSameDay(date, diary.createdAt))
        .toList();
  }

  /// Diary 작성
  void create(String text, DateTime selectedDate) {
    DateTime now = DateTime.now();
    //선택된 날짜에 현재 시간으로 추가
    DateTime createdAt = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      now.hour,
      now.minute,
      now.second,
    );

    Diary diary = Diary(
      text: text,
      createdAt: createdAt,
    );
    diaryList.add(diary);
    notifyListeners();
    // diary 정보가 변경될 때 마다 저장해줍니다.
    _saveDiaryList();
  }

  /// Diary 수정
  void update(DateTime createdAt, String newContent) {
    Diary diary = diaryList.firstWhere((diary) => diary.createdAt == createdAt);
    diary.text = newContent;
    notifyListeners();
    // diary 정보가 변경될 때 마다 저장해줍니다.
    _saveDiaryList();
  }

  /// Diary 삭제
  void delete(DateTime createdAt) {
    diaryList.removeWhere((diary) => diary.createdAt == createdAt);
    notifyListeners();
    // diary 정보가 변경될 때 마다 저장해줍니다.
    _saveDiaryList();
  }

  /// 변경된 Diary SharedPreferences로 저장
  /// 함수 이름을 _로 이름을 시작하면 DiaryService 내부에서만 호출할 수 있습니다.
  void _saveDiaryList() {
    // Diary라는 직접 만든 클래스는 shared preferences에 그대로 저장할 수 없습니다.
    // SharedPreferences에서 저장할 수 있는 String 형태로 변환을 해주겠습니다.
    // 나만의 규칙을 만들어 Diary를 String 형태로 변환할 수 있지만, 보통 json이라는 규칙을 이용합니다.
    // Diary -> Map -> String 순서로 변환합니다.
    List<String> stringDiaryList = [];
    for (Diary diary in diaryList) {
      // Diary -> Map
      Map<String, dynamic> jsonMap = diary.toJson();

      // Map -> String
      String stringDiary = jsonEncode(jsonMap);
      stringDiaryList.add(stringDiary);
    }
    prefs.setStringList("diaryList", stringDiaryList);
  }
}
