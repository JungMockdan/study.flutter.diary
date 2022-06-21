import 'package:diary/diary_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime selectedDate = DateTime.now();

  CalendarFormat calendarFormat = CalendarFormat.month;

  TextEditingController createTextController = TextEditingController();
  TextEditingController updateTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<DiaryService>(
      builder: (context, diaryService, child) {
        List<Diary> diaryList = diaryService.getByDate(selectedDate);
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Column(
              children: [
                ///달력
                TableCalendar(
                  firstDay: DateTime.utc(2010, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                  focusedDay: selectedDate,
                  calendarFormat: calendarFormat,
                  onFormatChanged: (format) {
                    setState(() {
                      calendarFormat = format;
                    });
                  },
                  eventLoader: (date) {
                    //각 날짜에 해당하는 diaryList 보여주기
                    return diaryService.getByDate(date);
                  },
                  calendarStyle: CalendarStyle(
                    //today 색상 제거
                    todayTextStyle: TextStyle(color: Colors.black),
                    todayDecoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  selectedDayPredicate: (day) {
                    return isSameDay(selectedDate, day);
                  },
                  onDaySelected: (_, focusedDay) {
                    setState(() {
                      selectedDate = focusedDay;
                    });
                  },
                ),
                Divider(height: 1),

                /// 선택한 날짜의 일기 목록
                Expanded(
                    child: diaryList.isEmpty
                        ? Center(
                            child: Text("한 줄 일기를 작성해주세요",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                )),
                          )
                        : ListView.separated(
                            itemCount: diaryList.length,
                            itemBuilder: (context, index) {
                              // 역순으로 보여주기
                              int i = diaryList.length - index - 1;
                              Diary diary = diaryList[i];
                              return ListTile(
                                /// text
                                title: Text(
                                  diary.text,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 24,
                                  ),
                                ),
                                trailing: Text(
                                  DateFormat('kk:mm').format(diary.createdAt),
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),

                                /// 클릭시 업데이트
                                onTap: () {
                                  showUpdateDialog(diaryService, diary);
                                },

                                /// 꾹 눌러 삭제
                                onLongPress: () {
                                  showDeleteDialog(diaryService, diary);
                                },
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              // item 사이에 Divider 추가
                              return Divider(height: 1);
                            },
                          ))
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.create),
            backgroundColor: Colors.indigo,
            onPressed: () {
              showCreateDialog(diaryService);
            },
          ),
        );
      },
    );
  }

  /// 작성하기
  /// 엔터를 누르거나 작성 버튼을 누르는 경우 호출
  void createDiary(DiaryService diaryService) {}

  /// 수정하기
  /// 엔터를 누르거나 수정 버튼을 누르는 경우 호출
  void updateDiary(DiaryService diaryService, Diary diary) {}

  /// 작성 다이얼로그 보여주기
  void showCreateDialog(DiaryService diaryService) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("일기 작성"),
          content: TextField(
            controller: createTextController,
            autofocus: true,
            //color of cusor
            cursorColor: Colors.indigo,
            decoration: InputDecoration(
              hintText: "한 줄 일기를 작성해주세요.",
              //underline color on focusing
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.indigo),
              ),
            ),
            onSubmitted: (_) {
              createDiary(diaryService);
              Navigator.pop(context);
            },
          ),
          actions: [
            //cancle
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("취소", style: TextStyle(color: Colors.indigo)),
            ),
            TextButton(
                onPressed: () {
                  createDiary(diaryService);
                  Navigator.pop(context);
                },
                child: Text("작성", style: TextStyle(color: Colors.indigo))),
          ],
        );
      },
    );
  }

  /// 수정 다이얼로그 보여주기
  void showUpdateDialog(DiaryService diaryService, Diary diary) {
    showDialog(
      context: context,
      builder: (context) {
        updateTextController.text = diary.text;
        return AlertDialog(
          title: Text("일기 수정"),
          content: TextField(
            autofocus: true,
            cursorColor: Colors.indigo,
            decoration: InputDecoration(
              hintText: "한 줄 일기를 작성해 주세요.",
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.indigo),
              ),
            ),
            onSubmitted: (v) {
              updateDiary(diaryService, diary);
              Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "취소",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.indigo,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                updateDiary(diaryService, diary);
                Navigator.pop(context);
              },
              child: Text(
                "수정",
                style: TextStyle(fontSize: 18, color: Colors.indigo),
              ),
            )
          ],
        );
      },
    );
  }

  /// 삭제 다이얼로그 보여주기
  void showDeleteDialog(DiaryService diaryService, Diary diary) {
    showDialog(
      context: context,
      builder: (context) {
        updateTextController.text = diary.text;
        return AlertDialog(
          title: Text("일기 삭제"),
          content: Text('"${diary.text}"를 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "취소",
                style: TextStyle(fontSize: 18, color: Colors.indigo),
              ),
            ),
            TextButton(
              onPressed: () {
                diaryService.delete(diary.createdAt);
                Navigator.pop(context);
              },
              child: Text(
                "삭제",
                style: TextStyle(fontSize: 18, color: Colors.indigo),
              ),
            ),
          ],
        );
      },
    );
  }
}
