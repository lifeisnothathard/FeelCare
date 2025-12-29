import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../services/habit_service.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<HabitService>(context);
    final habits = service.habits;

    return Scaffold(
      appBar: AppBar(title: const Text("Mood Analytics")),
      body: habits.isEmpty
          ? const Center(child: Text("No data yet. Start tracking!"))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TableCalendar(
                  focusedDay: DateTime.now(),
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2030, 1, 1),
                  calendarFormat: CalendarFormat.twoWeeks,
                ),
                const SizedBox(height: 20),
                const Text("Mood History Chart", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 10),
                
                // THE CHART
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: habits.asMap().entries.map((e) {
                            return FlSpot(
                              e.key.toDouble(), 
                              (e.value['score'] ?? 0).toDouble()
                            );
                          }).toList(),
                          isCurved: true,
                          color: Colors.green,
                          barWidth: 4,
                          belowBarData: BarAreaData(
                            show: true, 
                            color: Colors.green.withOpacity(0.2)
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                
                const Divider(height: 40),
                const Text("Recent Logs", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),

                // LIST OF HABITS
                ...habits.reversed.map((h) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Text(h['emoji'] ?? '😶', 
                      style: const TextStyle(fontSize: 30)),
                    title: Text(h['note'] == "" ? "No Note" : h['note']),
                    subtitle: Text(h['date'].toString().split('T')[0]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // Pass only the ID to our new fixed function
                        service.deleteHabit(h['id']);
                      },
                    ),
                  ),
                )),
              ],
            ),
    );
  }
}