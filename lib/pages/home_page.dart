import 'package:feelcare/components/habit_tile.dart';
import 'package:feelcare/components/my_fab.dart';
import 'package:feelcare/components/my_alert_box.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key, 
  });

  @override
  State<HomePage> createState() => _HomePageState();
  } 

  class _HomePageState extends State<HomePage> {
    //data structured for todays list
    List todaysHabitList = [
      // [ habitName, habitCompleted ]
      ["Morning Run", false],
      ["Read Book", false],
    ];
    
    // checkbox was tapped
    void checkBoxTapped(bool? value, int index) {
      setState(() {
        todaysHabitList[index][1] = value!;
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
        todaysHabitList.add([_newHabitController.text,false]);
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
            hintText: todaysHabitList[index][0],
            onSave: () => saveExistingHabit(index), 
            onCancel: cancelDialogBox,
          );
        },
      );
    }

    //save existing habit with a new name
    void saveExistingHabit(int index) {
      setState(() {
        todaysHabitList[index][0]=_newHabitController.text;
      });
      _newHabitController.clear();
      Navigator.pop(context);
    }

    //delete existing habit 
    void deleteHabit(int index) {
      setState(() {
        todaysHabitList.remove(index);
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
        itemCount: todaysHabitList.length,
        itemBuilder: (context, index) {
          return HabitTile(
            habitName: todaysHabitList[index][0],
            habitCompleted: todaysHabitList[index][1],
            onChanged: (value)=>checkBoxTapped(value,index) ,
            settingsTapped: (context)=>openHabitSettings(index),
            deleteTapped: (context) => deleteHabit(index),
          );
    },
      ),
    );
    }
  }
        