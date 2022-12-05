/// lastCheckInTime : ""
/// checkInList : []

class CheckInBean {
  String lastCheckInDate = "";
  String lastCheckInTime = "";
  List<String> checkInList = [];

  static CheckInBean fromMap(Map<String, dynamic> map) {
    CheckInBean checkInBean = CheckInBean();
    checkInBean.lastCheckInDate = map['lastCheckInDate'];
    checkInBean.lastCheckInTime = map['lastCheckInTime'];
    checkInBean.checkInList = map['checkInList'];
    return checkInBean;
  }

  Map toJson() => {
    "lastCheckInDate": lastCheckInDate,
    "lastCheckInTime": lastCheckInTime,
    "checkInList": checkInList,
  };
}