//reference our box
import 'package:feelcare/datetime/date_time.dart';
import 'package:hive_flutter/hive_flutter.dart';

final _myBox = Hive.box("Habit_Database");

class HabitDatabase {
  List todaysHabitList = [];

  //create initial default data
  void createDefaultData() {
    List todaysHabitList = [
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
  }
}