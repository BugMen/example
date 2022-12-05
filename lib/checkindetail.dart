import 'package:flutter/material.dart';

/// 打卡详情
class CheckInDetail extends StatelessWidget {
  List<String> checkInList;

  CheckInDetail({Key? key, required this.checkInList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("打卡详情"),
      ),
      body: CheckInDetailState(
        checkInList: checkInList,
      ),
    );
  }
}

class CheckInDetailState extends StatefulWidget {
  List<String> checkInList;

  CheckInDetailState({Key? key, required this.checkInList}) : super(key: key);

  @override
  State<CheckInDetailState> createState() =>
      _CheckInDetailStateState(checkInList);
}

class _CheckInDetailStateState extends State<CheckInDetailState> {
  List<String> _checkInList;

  _CheckInDetailStateState(this._checkInList);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 12),
      padding: EdgeInsets.only(left: 16, right: 16),
      child: ListView.builder(
          itemCount: _checkInList.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(top: 8, bottom: 9),
                        child: Text(
                          _checkInList[index],
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ),
                    GestureDetector(
                      child: Icon(
                        Icons.close,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        _checkInList.removeAt(index);
                        setState(() {
                        });
                      },
                    )
                  ],
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 1,
                  color: Colors.grey.withOpacity(0.4),
                  margin: EdgeInsets.only(top: 12, bottom: 12),
                )
              ],
            );
          }),
    );
  }
}
