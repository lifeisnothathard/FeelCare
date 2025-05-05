import 'package:feelcare/components/habit_tile.dart';
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

    @override
    Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: ListView.builder(
        itemCount: todaysHabitList.length,
        itemBuilder: (context, index) {
          return HabitTile(
            habitName: todaysHabitList[index][0],
            habitCompleted: todaysHabitList[index][1],
            onChanged: (value)=>checkBoxTapped(value,index) ,
          );
    },
      ),
    );
    }
  }
        