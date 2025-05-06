import 'package:feelcare/components/habit_tile.dart';
import 'package:feelcare/components/my_fab.dart';
import 'package:feelcare/components/my_alert_box.dart';
import 'package:feelcare/data/habit_database.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key, 
  });

  @override
  State<HomePage> createState() => _HomePageState();
  } 

  class _HomePageState extends State<HomePage> {
    HabitDatabase db = HabitDatabase();
    final _myBox = Hive.box("Habit_Database");

    @override
    void initState() {

      //if there is no current habit list, then it is the 1st time ever opening the app
      //then create default data
      if (_myBox.get("CURRENT_HABIT_LIST") == null){
        db.createDefaultData();      
      }

      //there already exist data, this is not the first time
      else {
        db.loadData();
      }

      //update the database
      db.updateDatabase();

      super.initState();    
    }

    // checkbox was tapped
    void checkBoxTapped(bool? value, int index) {
      setState(() {
        db.todaysHabitList[index][1] = value!;
      });
    }
    
    //create a new habit
    final _newHabitController = TextEditingController();
    void createNewHabit(){
      //show alert dialog for user to enter the new habit details
      showDialog(
        context: context,
        builder: (context){
          return MyAlertBox(
            controller: _newHabitController,
            hintText: 'Enter Habit Name',
            onSave: saveNewHabit,
            onCancel: cancelDialogBox,
          );
        },
      );
    }

    //save new habit
    void saveNewHabit(){
      //add new habit to todays habit list
      setState(() {
        db.todaysHabitList.add([_newHabitController.text,false]);
      });

      //clear textfield
      _newHabitController.clear();
      //pop dialog box
      Navigator.of(context).pop();
    }
    
    //cancel new habit
    void cancelDialogBox(){
      //clear textfield
      _newHabitController.clear();
      //pop dialog box
      Navigator.of(context).pop();
    }

    //open habbit settins to edit
    void openHabitSettings(int index) {
      showDialog(
        context: context, 
        builder: (context) {
          return MyAlertBox(
            controller: _newHabitController, 
            hintText: db.todaysHabitList[index][0],
            onSave: () => saveExistingHabit(index), 
            onCancel: cancelDialogBox,
          );
        },
      );
    }

    //save existing habit with a new name
    void saveExistingHabit(int index) {
      setState(() {
        db.todaysHabitList[index][0]=_newHabitController.text;
      });
      _newHabitController.clear();
      Navigator.pop(context);
    }

    //delete existing habit 
    void deleteHabit(int index) {
      setState(() {
        db.todaysHabitList.remove(index);
      });
    }

    @override
    Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      floatingActionButton: MyFloatingActionButton(
        onPressed: () => createNewHabit(),
      ),
      body: ListView.builder(
        itemCount: db.todaysHabitList.length,
        itemBuilder: (context, index) {
          return HabitTile(
            habitName: db.todaysHabitList[index][0],
            habitCompleted: db.todaysHabitList[index][1],
            onChanged: (value)=>checkBoxTapped(value,index) ,
            settingsTapped: (context)=>openHabitSettings(index),
            deleteTapped: (context) => deleteHabit(index),
          );
    },
      ),
    );
    }
  }
        