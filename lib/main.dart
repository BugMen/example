import 'dart:async';
import "dart:math";

import 'package:date_format/date_format.dart';
import 'package:example/bean/checkinbean.dart';
import 'package:example/checkindetail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('zh', 'CH')],
      // 国际化
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _minute = ""; // 分钟
  String _seconds = ""; // 秒钟
  double _opacity = 1.0; // 渐变
  late DateTime _nowDate; // 当前日期
  late DateTime _lastDate; // 下个月日期
  late DateTime _lastDay; // 这个月最后一天日期
  final List<CheckInBean> _allCheckInList = []; // 所有打卡日期
  String _currentDate = ""; // 当前日期
  int _currentDay = 0; // 当前天
  int _sumCheckInNum = 0; // 总打卡次数
  int _sumCheckInDayNum = 0; // 总打卡天数
  int _currentContinuousNum = 0; // 当前连续打卡天数
  int _highestContinuousNum = 0; // 最高连续打卡天数

  @override
  void initState() {
    super.initState();
    _nowDate = DateTime.now();
    _lastDate = DateTime(_nowDate.year, _nowDate.month + 1);
    _lastDay = _lastDate.subtract(const Duration(days: 1));
    _currentDate = formatDate(_nowDate, [yyyy, "-", mm, "-", dd]);
    _currentDay = int.parse(formatDate(_nowDate, [dd]));
    for (int i = 1; i <= _lastDay.day; i++) {
      CheckInBean checkInBean = CheckInBean();
      checkInBean.lastCheckInDate = "${_nowDate.year}-${_nowDate.month}-$i";
      _allCheckInList.add(checkInBean);
    }
    _setTime();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _setTime();
        _toggle();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          CalendarDatePicker(
              initialDate:
                  DateTime(_nowDate.year, _nowDate.month, _nowDate.day),
              firstDate: DateTime(_nowDate.year, _nowDate.month, 1),
              lastDate: DateTime(_nowDate.year, _nowDate.month, _lastDay.day),
              onDateChanged: (value) {
                setState(() {
                  _currentDate = formatDate(value, [yyyy, "-", mm, "-", dd]);
                  _currentDay = int.parse(formatDate(value, [dd]));
                  if (_currentDate !=
                          formatDate(_nowDate, [yyyy, "-", mm, "-", dd]) &&
                      _allCheckInList[_currentDay].checkInList.isEmpty) {
                    _repairCheckIn();
                  }
                });
              }),
          GestureDetector(
            child: Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(left: 16, right: 16),
              padding: const EdgeInsets.only(
                  left: 16, top: 12, right: 16, bottom: 12),
              decoration:
                  BoxDecoration(color: Colors.grey.shade200.withOpacity(0.7)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Expanded(
                        child: Text(
                          "最新打卡时间",
                          style: TextStyle(color: Colors.black, fontSize: 14),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_right,
                        color: Colors.grey,
                      )
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 12, bottom: 12),
                    child: Text(_allCheckInList[_currentDay]
                            .checkInList
                            .isNotEmpty
                        ? _allCheckInList[_currentDay].checkInList[
                            _allCheckInList[_currentDay].checkInList.length - 1]
                        : ""),
                  )
                ],
              ),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CheckInDetail(
                            checkInList:
                                _allCheckInList[_currentDay].checkInList,
                          )));
            },
          ),
          Container(
            margin:
                const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "总打卡次数: $_sumCheckInNum次",
                ),
                Text("总打卡天数: $_sumCheckInDayNum天"),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("当前连续打卡天数: $_currentContinuousNum天"),
                Text("历史最高连续打卡天数: $_highestContinuousNum天"),
              ],
            ),
          ),
          Expanded(child: Container()),
          GestureDetector(
            child: Container(
                width: 160,
                height: 160,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0066FF),
                  borderRadius: BorderRadius.circular(1000),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _minute,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 32),
                        ),
                        AnimatedOpacity(
                          opacity: _opacity,
                          duration: const Duration(seconds: 1),
                          child: const Text(" : ",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 24)),
                        ),
                        Text(
                          _seconds,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 32),
                        ),
                      ],
                    ),
                    const Text(
                      "开始打卡",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                )),
            onTap: () {
              String currentTime = formatDate(DateTime.now(), [HH, ":", nn]);
              _allCheckInList[_currentDay].lastCheckInDate = _currentDate;
              _allCheckInList[_currentDay].lastCheckInTime = currentTime;
              _allCheckInList[_currentDay]
                  .checkInList
                  .add("$_currentDate $currentTime");
              setState(() {
                _getSumCheckInNum();
                _getSumCheckInDayNum();
                _getContinuousDayNum();
              });
            },
          )
        ],
      ),
    );
  }

  /// 设置时间
  _setTime() {
    DateTime nowDate = DateTime.now();
    _minute = formatDate(nowDate, [HH]);
    _seconds = formatDate(nowDate, [nn]);
  }

  /// 切换显示/隐藏
  _toggle() {
    _opacity = _opacity > 0 ? 0.0 : 1.0;
  }

  /// 总的打卡次数
  _getSumCheckInNum() {
    int sum = 0;
    for (var element in _allCheckInList) {
      sum += element.checkInList.length;
    }
    _sumCheckInNum = sum;
  }

  /// 总的打卡天数
  _getSumCheckInDayNum() {
    int sum = 0;
    for (var element in _allCheckInList) {
      if (element.checkInList.isNotEmpty) {
        sum += 1;
      }
    }
    _sumCheckInDayNum = sum;
  }

  /// 连续打卡天数
  _getContinuousDayNum() {
    List<String> checkInList = [];
    for (var element in _allCheckInList) {
      if (element.checkInList.isNotEmpty) {
        checkInList.add(element.lastCheckInDate);
      }
    }
    checkInList.sort(); // 排序
    checkInList.toSet().toList(); // 去重
    int sum = 1;
    List<int> sumList = [];
    for (int i = 0; i < checkInList.length; i++) {
      if (i + 1 < checkInList.length) {
        if (DateTime.parse(checkInList[i]) ==
            DateTime.parse(checkInList[i + 1])
                .subtract(const Duration(days: 1))) {
          // 判断日期是否连续
          sum += 1;
        } else {
          sumList.toSet(); // 去重
          sumList.add(sum);
          sum = 1; // 重置sum
        }
      }
    }
    _currentContinuousNum = sum;
    if (sumList.isNotEmpty) {
      _highestContinuousNum = sumList.reduce(max); // 取最大值
    }
  }

  /// 补卡
  _repairCheckIn() async {
    var time =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time != null) {
      String checkInTime = "${time.hour}:${time.minute}";
      _allCheckInList[_currentDay].lastCheckInDate = _currentDate;
      _allCheckInList[_currentDay].lastCheckInTime = checkInTime;
      _allCheckInList[_currentDay]
          .checkInList
          .add("$_currentDate $checkInTime");
    }
  }
}
