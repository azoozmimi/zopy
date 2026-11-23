import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../l10n/app_localizations.dart';
import '../models/assignment.dart';
import '../providers/assignment_provider.dart';
import '../widgets/assignment_card.dart';
import '../widgets/main_drawer.dart';
import 'assignment_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssignmentProvider>().fetchAssignments();
    });
  }

  List<Assignment> _getAssignmentsForDay(DateTime day, List<Assignment> all) {
    return all.where((a) {
      final local = a.deadlineUtc.toLocal();
      return isSameDay(local, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final assignmentProvider = context.watch<AssignmentProvider>();
    final allAssignments = assignmentProvider.assignments;

    final selectedAssignments = _selectedDay != null ? _getAssignmentsForDay(_selectedDay!, allAssignments) : <Assignment>[];

    return Scaffold(
      drawer: const MainDrawer(currentRoute: 'calendar'),
      appBar: AppBar(
        title: Text(l10n.calendar),
      ),
      body: Column(
        children: [
          // TableCalendar Widget
          Card(
            margin: const EdgeInsets.all(12),
            child: TableCalendar<Assignment>(
              firstDay: DateTime.now().subtract(const Duration(days: 90)),
              lastDay: DateTime.now().add(const Duration(days: 180)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.saturday, // Standard university week start
              eventLoader: (day) => _getAssignmentsForDay(day, allAssignments),
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.35),
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
            ),
          ),

          // Day Agenda Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.event_note, size: 18, color: Color(0xFF1E56A0)),
                const SizedBox(width: 8),
                Text(
                  _selectedDay != null
                      ? 'مهام وتكاليف تاريخ: ${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}'
                      : 'اختر يوماً لعرض المواعيد',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const Spacer(),
                Text(
                  '${selectedAssignments.length}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
          ),

          // Day Agenda List
          Expanded(
            child: selectedAssignments.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('لا توجد مواعيد تسليم في هذا اليوم المختار.', style: TextStyle(color: Colors.grey)),
                    ),
                  )
                : ListView.builder(
                    itemCount: selectedAssignments.length,
                    itemBuilder: (context, index) {
                      final a = selectedAssignments[index];
                      return AssignmentCard(
                        assignment: a,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AssignmentDetailScreen(assignmentId: a.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
