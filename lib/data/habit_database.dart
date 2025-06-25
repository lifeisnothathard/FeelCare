//reference our box
import 'package:feelcare/datetime/date_time.dart';
import 'package:hive_flutter/hive_flutter.dart';

final _myBox = Hive.box("Habit_Database");

class HabitDatabase {
  List todaysHabitList = [];
  Map<DateTime,int> heatMapDataSet = {};

  //create initial default data
  void createDefaultData() {
     todaysHabitList = [
      // [ habitName, habitCompleted ]
      ["Run", false],
      ["Read", false],
    ];

    _myBox.put("START_DATE", todaysDateFormatted());
  }

  //load data if it already exist
  void loadData() {
    //if its a new day , get habit from database
    if (_myBox.get(todaysDateFormatted()) == null) {
      todaysHabitList = _myBox.get("CURRENT_HABIT_LIST");
      //set all habit completed to false since its a new day
      for(int i =0; i< todaysHabitList.length; i++) {
        todaysHabitList[i][1] = false;
      }
    }

    //if its not a new day, load todays list
    else {
      todaysHabitList = _myBox.get(todaysDateFormatted());
    }
  }

  //update database
  void updateDatabase() {
     //update todays entry
     _myBox.put(todaysDateFormatted(), todaysHabitList);

     //update universal habit list in case it changed (new, edit, delete)
     _myBox.put("CURRENT_HABIT_LIST",todaysHabitList);

     //calculate habit complete percentages
     calculateHabitPercentages();

     //load heat map
     loadHeatMap();

  }
  
  void calculateHabitPercentages() {
    int countCompleted = 0;
    for (int i =0 ; i< todaysHabitList.length; i++){
      if (todaysHabitList[i][1] == true){
        countCompleted++;
      }
    }
    String percent = todaysHabitList.isEmpty
    ? '0.0'
    : (countCompleted/todaysHabitList.length).toStringAsFixed(1);

    //key: "PERCENTAGE_SUMMARY_yyyymmdd"
    //value: string to 1dp number 0-1 inclusive
    _myBox.put("PERCENTAGE_SUMMARY_${todaysDateFormatted()}", percent);
  }
  
  void loadHeatMap() {
  try {
    final startDateString = _myBox.get("START_DATE");
    if (startDateString == null) {
      createDefaultData();
      return;
    }

    DateTime startDate = createDataTimeObject(startDateString);
    int daysInBetween = DateTime.now().difference(startDate).inDays;
    
    heatMapDataSet.clear();

    for (int i = 0; i <= daysInBetween; i++) {
      DateTime currentDate = startDate.add(Duration(days: i));
      String yyyymmdd = convertDateTimeToString(currentDate);
      
      double strengthAsPercent = double.tryParse(
        _myBox.get("PERCENTAGE_SUMMARY_$yyyymmdd")?.toString() ?? "0.0"
      ) ?? 0.0;

      heatMapDataSet[DateTime(currentDate.year, currentDate.month, currentDate.day)] = 
        (10 * strengthAsPercent).toInt();
    }
  } catch (e) {
    // Consider showing a user-friendly error message
  }
}
}