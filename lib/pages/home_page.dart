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
    
    //bool to control habit completed
    bool habitCompleted = false;
    
    // checkbox was tapped
    void checkBoxTapped(bool? value) {
      setState(() {
        habitCompleted = value!;
      });
    }
    
    @override
    Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: ListView(
        children: [
          //habit tiles
          HabitTile(
            habitName: "Morning Run",
            habitCompleted: false,
            onChanged: (value) => checkBoxTapped(value),
          )
        ],
      ),
    );
  }
}