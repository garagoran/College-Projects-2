import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  ENTRY POINT
// ─────────────────────────────────────────────
void main() {
  runApp(const HealthTrackerApp());
}

// ─────────────────────────────────────────────
//  IN-MEMORY DATA MODELS
// ─────────────────────────────────────────────

class SymptomEntry {
  final String symptom;
  final int severity; // 1–10
  final String note;
  final DateTime timestamp;

  SymptomEntry({
    required this.symptom,
    required this.severity,
    required this.note,
    required this.timestamp,
  });
}

class WaterEntry {
  final DateTime timestamp;
  WaterEntry({required this.timestamp});
}

class MoodEntry {
  final String mood;
  final String emoji;
  final DateTime timestamp;

  MoodEntry({
    required this.mood,
    required this.emoji,
    required this.timestamp,
  });
}

// ─────────────────────────────────────────────
//  CENTRAL IN-MEMORY STORE
// ─────────────────────────────────────────────

class HealthData {
  // Symptoms log
  static final List<SymptomEntry> symptomLog = [];

  // Water intake (glasses per session)
  static final List<WaterEntry> waterLog = [];
  static int dailyWaterGoal = 8;

  // Mood log
  static final List<MoodEntry> moodLog = [];

  // BMI (stored after last calculation)
  static double? lastBmi;
  static String? lastBmiCategory;

  static int get todayWaterCount {
    final now = DateTime.now();
    return waterLog
        .where((e) =>
            e.timestamp.year == now.year &&
            e.timestamp.month == now.month &&
            e.timestamp.day == now.day)
        .length;
  }

  static String? get todayMood {
    final now = DateTime.now();
    final todayMoods = moodLog.where((e) =>
        e.timestamp.year == now.year &&
        e.timestamp.month == now.month &&
        e.timestamp.day == now.day);
    return todayMoods.isNotEmpty ? todayMoods.last.emoji : null;
  }
}

// ─────────────────────────────────────────────
//  APP ROOT
// ─────────────────────────────────────────────

class HealthTrackerApp extends StatelessWidget {
  const HealthTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00897B),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00897B),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// ─────────────────────────────────────────────
//  HOME SCREEN
// ─────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr =
        '${_weekday(now.weekday)}, ${now.day} ${_month(now.month)} ${now.year}';

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8F7),
      appBar: AppBar(
        title: const Text('MediTrack 🏥',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Full Log',
            onPressed: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const HealthLogScreen()));
              _refresh();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Date banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF00897B),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              dateStr,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),

          // Summary cards row
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  icon: Icons.water_drop,
                  color: Colors.blue,
                  label: 'Water',
                  value:
                      '${HealthData.todayWaterCount} / ${HealthData.dailyWaterGoal} glasses',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.mood,
                  color: Colors.orange,
                  label: 'Mood',
                  value: HealthData.todayMood ?? 'Not logged',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  icon: Icons.sick,
                  color: Colors.red,
                  label: 'Symptoms logged',
                  value: '${HealthData.symptomLog.length} total',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.monitor_weight,
                  color: Colors.purple,
                  label: 'BMI',
                  value: HealthData.lastBmi != null
                      ? '${HealthData.lastBmi!.toStringAsFixed(1)} (${HealthData.lastBmiCategory})'
                      : 'Not calculated',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          const _SectionTitle('Quick Actions'),
          const SizedBox(height: 12),

          // Navigation buttons
          _NavButton(
            icon: Icons.add_circle_outline,
            label: 'Log Symptoms',
            color: Colors.red.shade400,
            onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const LogSymptomsScreen()));
              _refresh();
            },
          ),
          _NavButton(
            icon: Icons.water_drop_outlined,
            label: 'Water Intake Tracker',
            color: Colors.blue.shade400,
            onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const WaterIntakeScreen()));
              _refresh();
            },
          ),
          _NavButton(
            icon: Icons.emoji_emotions_outlined,
            label: 'Mood Tracker',
            color: Colors.orange.shade400,
            onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MoodTrackerScreen()));
              _refresh();
            },
          ),
          _NavButton(
            icon: Icons.calculate_outlined,
            label: 'BMI Calculator',
            color: Colors.purple.shade400,
            onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const BmiCalculatorScreen()));
              _refresh();
            },
          ),
        ],
      ),
    );
  }

  String _weekday(int d) =>
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d - 1];
  String _month(int m) => [
        'Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'
      ][m - 1];
}

// ─────────────────────────────────────────────
//  LOG SYMPTOMS SCREEN
// ─────────────────────────────────────────────

class LogSymptomsScreen extends StatefulWidget {
  const LogSymptomsScreen({super.key});

  @override
  State<LogSymptomsScreen> createState() => _LogSymptomsScreenState();
}

class _LogSymptomsScreenState extends State<LogSymptomsScreen> {
  final List<String> _allSymptoms = [
    'Fever', 'Headache', 'Fatigue', 'Cough', 'Sore Throat',
    'Runny Nose', 'Nausea', 'Vomiting', 'Diarrhea', 'Chest Pain',
    'Shortness of Breath', 'Dizziness', 'Back Pain', 'Joint Pain',
    'Loss of Appetite', 'Insomnia', 'Rash', 'Swollen Glands',
  ];

  String? _selectedSymptom;
  double _severity = 5;
  final TextEditingController _noteController = TextEditingController();

  void _save() {
    if (_selectedSymptom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a symptom first.')),
      );
      return;
    }
    HealthData.symptomLog.add(SymptomEntry(
      symptom: _selectedSymptom!,
      severity: _severity.round(),
      note: _noteController.text.trim(),
      timestamp: DateTime.now(),
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Symptom logged!'), backgroundColor: Colors.green),
    );
    _noteController.clear();
    setState(() {
      _selectedSymptom = null;
      _severity = 5;
    });
  }

  Color _severityColor(double v) {
    if (v <= 3) return Colors.green;
    if (v <= 6) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Symptoms')),
      backgroundColor: const Color(0xFFF1F8F7),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionTitle('Select Symptom'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allSymptoms.map((s) {
              final selected = _selectedSymptom == s;
              return ChoiceChip(
                label: Text(s),
                selected: selected,
                selectedColor: const Color(0xFF00897B),
                labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.black87),
                onSelected: (_) => setState(() => _selectedSymptom = s),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const _SectionTitle('Severity'),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('1', style: TextStyle(color: Colors.green)),
              Expanded(
                child: Slider(
                  min: 1,
                  max: 10,
                  divisions: 9,
                  value: _severity,
                  activeColor: _severityColor(_severity),
                  label: _severity.round().toString(),
                  onChanged: (v) => setState(() => _severity = v),
                ),
              ),
              const Text('10', style: TextStyle(color: Colors.red)),
            ],
          ),
          Center(
            child: Text(
              'Severity: ${_severity.round()} / 10',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _severityColor(_severity),
                  fontSize: 15),
            ),
          ),
          const SizedBox(height: 20),
          const _SectionTitle('Additional Notes (optional)'),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'e.g. started after lunch, getting worse at night...',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('Save Symptom'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00897B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          if (HealthData.symptomLog.isNotEmpty) ...[
            const _SectionTitle('Recent Entries'),
            const SizedBox(height: 8),
            ...HealthData.symptomLog.reversed.take(5).map((e) =>
                _SymptomTile(entry: e)),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  HEALTH LOG SCREEN
// ─────────────────────────────────────────────

class HealthLogScreen extends StatelessWidget {
  const HealthLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final log = HealthData.symptomLog.reversed.toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Full Symptom Log')),
      backgroundColor: const Color(0xFFF1F8F7),
      body: log.isEmpty
          ? const Center(
              child: Text('No symptoms logged yet.',
                  style: TextStyle(color: Colors.grey, fontSize: 16)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: log.length,
              itemBuilder: (_, i) => _SymptomTile(entry: log[i]),
            ),
    );
  }
}

// ─────────────────────────────────────────────
//  WATER INTAKE SCREEN
// ─────────────────────────────────────────────

class WaterIntakeScreen extends StatefulWidget {
  const WaterIntakeScreen({super.key});

  @override
  State<WaterIntakeScreen> createState() => _WaterIntakeScreenState();
}

class _WaterIntakeScreenState extends State<WaterIntakeScreen> {
  void _addGlass() {
    setState(() {
      HealthData.waterLog.add(WaterEntry(timestamp: DateTime.now()));
    });
  }

  void _removeGlass() {
    if (HealthData.waterLog.isEmpty) return;
    setState(() => HealthData.waterLog.removeLast());
  }

  void _changeGoal(int delta) {
    setState(() {
      HealthData.dailyWaterGoal =
          (HealthData.dailyWaterGoal + delta).clamp(1, 20);
    });
  }

  @override
  Widget build(BuildContext context) {
    final count = HealthData.todayWaterCount;
    final goal = HealthData.dailyWaterGoal;
    final progress = (count / goal).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(title: const Text('Water Intake Tracker')),
      backgroundColor: const Color(0xFFF1F8F7),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Today's Intake",
                style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 14,
                    backgroundColor: Colors.blue.shade100,
                    color: Colors.blue,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$count',
                        style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue)),
                    Text('of $goal glasses',
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: List.generate(goal, (i) {
                return Icon(
                  i < count ? Icons.water_drop : Icons.water_drop_outlined,
                  color: i < count ? Colors.blue : Colors.blue.shade100,
                  size: 32,
                );
              }),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _removeGlass,
                  icon: const Icon(Icons.remove),
                  label: const Text('Remove'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                      foregroundColor: Colors.red),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _addGlass,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Glass'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            const Text('Daily Goal',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: () => _changeGoal(-1),
                    icon: const Icon(Icons.remove_circle_outline)),
                Text('$goal glasses',
                    style: const TextStyle(fontSize: 18)),
                IconButton(
                    onPressed: () => _changeGoal(1),
                    icon: const Icon(Icons.add_circle_outline)),
              ],
            ),
            if (count >= goal)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text('🎉 Daily goal reached! Great job!',
                    style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  MOOD TRACKER SCREEN
// ─────────────────────────────────────────────

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  final List<Map<String, String>> _moods = [
    {'emoji': '😄', 'label': 'Great'},
    {'emoji': '🙂', 'label': 'Good'},
    {'emoji': '😐', 'label': 'Neutral'},
    {'emoji': '😔', 'label': 'Sad'},
    {'emoji': '😠', 'label': 'Angry'},
    {'emoji': '😰', 'label': 'Anxious'},
    {'emoji': '😴', 'label': 'Tired'},
    {'emoji': '🤒', 'label': 'Sick'},
  ];

  String? _selectedEmoji;
  String? _selectedLabel;

  void _saveMood() {
    if (_selectedEmoji == null) return;
    HealthData.moodLog.add(MoodEntry(
      mood: _selectedLabel!,
      emoji: _selectedEmoji!,
      timestamp: DateTime.now(),
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Mood "$_selectedLabel" logged!'),
          backgroundColor: Colors.green),
    );
    setState(() {
      _selectedEmoji = null;
      _selectedLabel = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mood Tracker')),
      backgroundColor: const Color(0xFFF1F8F7),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('How are you feeling today?',
                style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: _moods.map((m) {
                final selected = _selectedEmoji == m['emoji'];
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedEmoji = m['emoji'];
                    _selectedLabel = m['label'];
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF00897B)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: selected
                              ? const Color(0xFF00897B)
                              : Colors.grey.shade300),
                      boxShadow: selected
                          ? [
                              const BoxShadow(
                                  color: Color(0x4400897B),
                                  blurRadius: 8,
                                  offset: Offset(0, 3))
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(m['emoji']!,
                            style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 4),
                        Text(m['label']!,
                            style: TextStyle(
                                fontSize: 11,
                                color: selected
                                    ? Colors.white
                                    : Colors.black87)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            if (_selectedEmoji != null)
              Center(
                child: ElevatedButton.icon(
                  onPressed: _saveMood,
                  icon: const Icon(Icons.check),
                  label: Text('Log mood: $_selectedEmoji $_selectedLabel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00897B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            if (HealthData.moodLog.isNotEmpty) ...[
              const _SectionTitle('Mood History'),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: HealthData.moodLog.reversed
                      .take(10)
                      .map((e) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              leading: Text(e.emoji,
                                  style: const TextStyle(fontSize: 28)),
                              title: Text(e.mood,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(_formatDateTime(e.timestamp),
                                  style: const TextStyle(fontSize: 11)),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  BMI CALCULATOR SCREEN
// ─────────────────────────────────────────────

class BmiCalculatorScreen extends StatefulWidget {
  const BmiCalculatorScreen({super.key});

  @override
  State<BmiCalculatorScreen> createState() => _BmiCalculatorScreenState();
}

class _BmiCalculatorScreenState extends State<BmiCalculatorScreen> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  double? _bmi;
  String? _category;
  Color? _categoryColor;
  bool _useCm = true;

  void _calculate() {
    final heightStr = _heightController.text.trim();
    final weightStr = _weightController.text.trim();

    if (heightStr.isEmpty || weightStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter both height and weight.')),
      );
      return;
    }

    double height = double.tryParse(heightStr) ?? 0;
    double weight = double.tryParse(weightStr) ?? 0;

    if (height <= 0 || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid numbers.')),
      );
      return;
    }

    if (_useCm) height = height / 100;

    final bmi = weight / (height * height);
    String category;
    Color color;

    if (bmi < 18.5) {
      category = 'Underweight';
      color = Colors.blue;
    } else if (bmi < 25) {
      category = 'Normal weight';
      color = Colors.green;
    } else if (bmi < 30) {
      category = 'Overweight';
      color = Colors.orange;
    } else {
      category = 'Obese';
      color = Colors.red;
    }

    setState(() {
      _bmi = bmi;
      _category = category;
      _categoryColor = color;
    });

    HealthData.lastBmi = bmi;
    HealthData.lastBmiCategory = category;
  }

  void _reset() {
    _heightController.clear();
    _weightController.clear();
    setState(() {
      _bmi = null;
      _category = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BMI Calculator')),
      backgroundColor: const Color(0xFFF1F8F7),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SectionTitle('Height'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: _useCm ? 'e.g. 170' : 'e.g. 1.70',
                      suffixText: _useCm ? 'cm' : 'm',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ToggleButtons(
                  isSelected: [_useCm, !_useCm],
                  onPressed: (i) => setState(() => _useCm = i == 0),
                  borderRadius: BorderRadius.circular(10),
                  children: const [
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('cm')),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('m')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _SectionTitle('Weight'),
            const SizedBox(height: 8),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g. 70',
                suffixText: 'kg',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _calculate,
                    icon: const Icon(Icons.calculate),
                    label: const Text('Calculate BMI'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00897B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            if (_bmi != null)
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _categoryColor!.withOpacity(0.1),
                  border: Border.all(color: _categoryColor!, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      _bmi!.toStringAsFixed(2),
                      style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          color: _categoryColor),
                    ),
                    Text(
                      _category!,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: _categoryColor),
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    _BmiRangeRow(
                        label: 'Underweight',
                        range: '< 18.5',
                        color: Colors.blue),
                    _BmiRangeRow(
                        label: 'Normal',
                        range: '18.5 – 24.9',
                        color: Colors.green),
                    _BmiRangeRow(
                        label: 'Overweight',
                        range: '25 – 29.9',
                        color: Colors.orange),
                    _BmiRangeRow(
                        label: 'Obese', range: '≥ 30', color: Colors.red),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  REUSABLE WIDGETS
// ─────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _SummaryCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 6,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(label,
              style:
                  TextStyle(color: Colors.grey.shade600, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 6,
                  offset: const Offset(0, 3))
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Text(label,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
              const Spacer(),
              Icon(Icons.arrow_forward_ios,
                  size: 14, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

class _SymptomTile extends StatelessWidget {
  final SymptomEntry entry;
  const _SymptomTile({required this.entry});

  Color _severityColor(int v) {
    if (v <= 3) return Colors.green;
    if (v <= 6) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              _severityColor(entry.severity).withOpacity(0.15),
          child: Text(
            '${entry.severity}',
            style: TextStyle(
                color: _severityColor(entry.severity),
                fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(entry.symptom,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatDateTime(entry.timestamp),
                style:
                    const TextStyle(fontSize: 11, color: Colors.grey)),
            if (entry.note.isNotEmpty)
              Text(entry.note,
                  style: const TextStyle(
                      fontSize: 12, fontStyle: FontStyle.italic)),
          ],
        ),
        trailing: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _severityColor(entry.severity).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            entry.severity <= 3
                ? 'Mild'
                : entry.severity <= 6
                    ? 'Moderate'
                    : 'Severe',
            style: TextStyle(
                color: _severityColor(entry.severity),
                fontSize: 11,
                fontWeight: FontWeight.bold),
          ),
        ),
        isThreeLine: entry.note.isNotEmpty,
      ),
    );
  }
}

class _BmiRangeRow extends StatelessWidget {
  final String label;
  final String range;
  final Color color;

  const _BmiRangeRow({
    required this.label,
    required this.range,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                  color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
          const Spacer(),
          Text(range,
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────

String _formatDateTime(DateTime dt) {
  final hour = dt.hour.toString().padLeft(2, '0');
  final min = dt.minute.toString().padLeft(2, '0');
  return '${dt.day}/${dt.month}/${dt.year}  $hour:$min';
}
