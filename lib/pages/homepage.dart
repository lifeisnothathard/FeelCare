import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:shake/shake.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';
import '../services/habit_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ConfettiController _confetti;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // PLAYLIST DATA
  final List<Map<String, String>> _playlist = [
    {'name': 'Btob', 'path': 'sounds/btob.mp3'},
    {'name': 'Zootopia', 'path': 'sounds/zootopia.mp3'},
    {'name': 'Bahagia', 'path': 'sounds/bahagia.mp3'},
    {'name': 'CakCakCekuk', 'path': 'sounds/cakcakcekuk.mp3'},
  ];
  int _currentTrack = 0;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    
    // SHAKE FEATURE
    ShakeDetector.autoStart(onPhoneShake: (event) {
      _confetti.play();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Stay Positive! ✨")));
    });

    // START INITIAL MUSIC
    _playTrack();
  }

  void _playTrack() async {
    await _audioPlayer.play(AssetSource(_playlist[_currentTrack]['path']!));
    setState(() => _isPlaying = true);
  }

  void _toggleMusic() {
    if (_isPlaying) { _audioPlayer.pause(); } 
    else { _audioPlayer.resume(); }
    setState(() => _isPlaying = !_isPlaying);
  }

  void _nextTrack() {
    setState(() => _currentTrack = (_currentTrack + 1) % _playlist.length);
    _playTrack();
  }

  @override
  void dispose() {
    _confetti.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FeelCare 🌿"),
        actions: [
          IconButton(icon: const Icon(Icons.bar_chart), onPressed: () => Navigator.pushNamed(context, '/dashboard')),
          IconButton(icon: const Icon(Icons.person), onPressed: () => Navigator.pushNamed(context, '/profile')),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // WELCOME INTERFACE
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Card(
                  color: Colors.green.shade50,
                  child: ListTile(
                    leading: Lottie.asset('assets/lottie/hi_stiker.json', height: 50),
                    title: const Text("Welcome Back!", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text("Ready to track your mood?"),
                  ),
                ),
              ),
              const Spacer(),
              const Text("Shake your phone for a surprise! 📱"),
              const Spacer(),
              
              // MUSIC PLAYER BAR
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20))
                ),
                child: Row(
                  children: [
                    Icon(Icons.music_note, color: Colors.green.shade700),
                    const SizedBox(width: 10),
                    Expanded(child: Text("Playing: ${_playlist[_currentTrack]['name']}")),
                    IconButton(icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow), onPressed: _toggleMusic),
                    IconButton(icon: const Icon(Icons.skip_next), onPressed: _nextTrack),
                  ],
                ),
              ),
            ],
          ),
          
          // CONFETTI EFFECT
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMoodDialog(context),
        label: const Text("How are you feeling?"),
        icon: const Icon(Icons.add_reaction),
        backgroundColor: Colors.green,
      ),
    );
  }

  // THE UPGRADED DIALOG (NOTES + STICKERS)
  void _showAddMoodDialog(BuildContext context) {
    String selectedEmoji = '😊';
    int score = 5;
    String selectedSticker = 'assets/lottie/happy_sticker.json';
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20, right: 20, top: 20
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Log Your Mood", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              
              // Emoji Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _moodIcon('😡', 1, (e, s) { selectedEmoji = e; score = s; }),
                  _moodIcon('😔', 2, (e, s) { selectedEmoji = e; score = s; }),
                  _moodIcon('😐', 3, (e, s) { selectedEmoji = e; score = s; }),
                  _moodIcon('😊', 5, (e, s) { selectedEmoji = e; score = s; }),
                ],
              ),
              const SizedBox(height: 20),
              
              // Note Section
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: "Add a note (optional)",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  prefixIcon: const Icon(Icons.note_alt),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              
              // Cute Stickers Section
              const Text("Pick a Sticker:"),
              SizedBox(
                height: 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _stickerBtn('assets/lottie/dancer-woman.json', (s) => selectedSticker = s),
                    _stickerBtn('assets/lottie/fire heart.json', (s) => selectedSticker = s),
                    _stickerBtn('assets/lottie/loading refresh.json', (s) => selectedSticker = s),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.green,
                ),
                onPressed: () {
                  Provider.of<HabitService>(context, listen: false).addHabit(
                    name: "Daily Mood",
                    emoji: selectedEmoji,
                    score: score,
                    note: noteController.text,
                    sticker: selectedSticker
                  );
                  _confetti.play(); // Play confetti on save!
                  Navigator.pop(context);
                },
                child: const Text("Save Log", style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _moodIcon(String emo, int s, Function(String, int) onSelect) {
    return InkWell(
      onTap: () => onSelect(emo, s),
      child: Text(emo, style: const TextStyle(fontSize: 40)),
    );
  }

  Widget _stickerBtn(String path, Function(String) onSelect) {
    return GestureDetector(
      onTap: () => onSelect(path),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Lottie.asset(path, width: 60),
      ),
    );
  }
}