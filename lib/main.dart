import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:math';

void main() {
  runApp(const HijaiyahApp());
}

// ═══════════════════════════════════════════════════════════════
// 📦 DATA MODEL
// ═══════════════════════════════════════════════════════════════
class HijaiyahData {
  final String arabic;
  final String latin;
  final List<String> audioSequence;
  final String mandarinPinyin;

  HijaiyahData({
    required this.arabic,
    required this.latin,
    required this.audioSequence,
    required this.mandarinPinyin,
  });
}

// 4 Huruf Dasar + Mandarin Pinyin Mapping
final List<HijaiyahData> letters = [
  HijaiyahData(arabic: 'أَ', latin: 'Alif', audioSequence: ['alif.ogg'], mandarinPinyin: 'a'),
  HijaiyahData(arabic: 'بَ', latin: 'Ba', audioSequence: ['ba.ogg'], mandarinPinyin: 'ba'),
  HijaiyahData(arabic: 'تَ', latin: 'Ta', audioSequence: ['ta.ogg'], mandarinPinyin: 'ta'),
  HijaiyahData(arabic: 'ثَ', latin: 'Tsa', audioSequence: ['tsa.ogg'], mandarinPinyin: 'sa'),
];

// ═══════════════════════════════════════════════════════════════
// 🎨 APP CONFIGURATION
// ═══════════════════════════════════════════════════════════════
class HijaiyahApp extends StatelessWidget {
  const HijaiyahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '📚 Belajar Hijaiyah',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: GoogleFonts.poppins().fontFamily,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 🏠 HOME SCREEN
// ═══════════════════════════════════════════════════════════════
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Belajar Hijaiyah'),
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlueAccent, Colors.greenAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1,
          ),
          itemCount: letters.length + 2, // 4 huruf + Quiz + STT
          itemBuilder: (context, index) {
            if (index == letters.length) return _buildQuizCard(context);
            if (index == letters.length + 1) return _buildSttCard(context);
            return _buildLetterCard(context, letters[index]);
          },
        ),
      ),
    );
  }

  Widget _buildLetterCard(BuildContext context, HijaiyahData letter) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LearningScreen(letter: letter))),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.white,
              child: Text(letter.arabic, style: GoogleFonts.amiri(fontSize: 50, color: Colors.green[800])),
            ),
            const SizedBox(height: 10),
            Text(letter.latin, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizPage())),
      child: Card(
        elevation: 6,
        color: Colors.purpleAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(padding: const EdgeInsets.all(15), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.casino, size: 50, color: Colors.purple)),
            const SizedBox(height: 15),
            const Text('🎮 Quiz', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const Text('Acak & Dengar', style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildSttCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SttPracticePage())),
      child: Card(
        elevation: 6,
        color: Colors.blueAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(padding: const EdgeInsets.all(15), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.mic, size: 50, color: Colors.blue)),
            const SizedBox(height: 15),
            const Text('🎤 STT', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const Text('Latihan Ucap', style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 📖 LEARNING SCREEN
// ═══════════════════════════════════════════════════════════════
class LearningScreen extends StatefulWidget {
  final HijaiyahData letter;
  const LearningScreen({super.key, required this.letter});
  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late TabController _tabController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _playAudio() async {
    if (_isPlaying) return;
    setState(() => _isPlaying = true);
    try {
      for (int i = 0; i < widget.letter.audioSequence.length; i++) {
        await _audioPlayer.play(AssetSource('audio/${widget.letter.audioSequence[i]}'));
        await _audioPlayer.onPlayerComplete.first;
        if (i < widget.letter.audioSequence.length - 1) await Future.delayed(const Duration(milliseconds: 200));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isPlaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Huruf ${widget.letter.latin}'),
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
        bottom: TabBar(controller: _tabController, labelColor: Colors.green[800], tabs: const [Tab(icon: Icon(Icons.volume_up), text: "Dengar"), Tab(icon: Icon(Icons.edit), text: "Tulis"), Tab(icon: Icon(Icons.info), text: "Info")]),
      ),
      body: TabBarView(controller: _tabController, children: [_buildReadListenMode(), _buildWritingMode(), _buildInfoMode()]),
    );
  }

  Widget _buildReadListenMode() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(padding: const EdgeInsets.all(30), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 20, spreadRadius: 5)]), child: Text(widget.letter.arabic, style: GoogleFonts.amiri(fontSize: 180, color: Colors.green[800]))),
          const SizedBox(height: 40),
          GestureDetector(onTap: _isPlaying ? null : _playAudio, child: AnimatedContainer(duration: const Duration(milliseconds: 300), width: 120, height: 120, decoration: BoxDecoration(shape: BoxShape.circle, gradient: _isPlaying ? const RadialGradient(colors: [Colors.red, Colors.orange]) : const RadialGradient(colors: [Colors.green, Colors.teal]), boxShadow: [BoxShadow(color: (_isPlaying ? Colors.red : Colors.green).withOpacity(0.5), blurRadius: 30, spreadRadius: 5)], border: Border.all(color: Colors.white, width: 4)), child: Icon(_isPlaying ? Icons.volume_up : Icons.play_arrow, size: 60, color: Colors.white))),
          const SizedBox(height: 10),
          Text(_isPlaying ? '🔊 Memutar...' : 'Tap untuk dengar', style: TextStyle(fontSize: 16, color: _isPlaying ? Colors.red : Colors.green[800])),
        ],
      ),
    );
  }

  Widget _buildWritingMode() => Column(children: [const Padding(padding: EdgeInsets.all(16), child: Text("Telusuri huruf di bawah:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))), Expanded(child: WritingCanvas(arabicChar: widget.letter.arabic))]);

  Widget _buildInfoMode() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, size: 80, color: Colors.blue),
          const SizedBox(height: 20),
          Text('Huruf: ${widget.letter.latin}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('Audio: ${widget.letter.audioSequence.join(" + ")}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 10),
          Text('STT Pinyin: ${widget.letter.mandarinPinyin}', style: const TextStyle(fontSize: 14, color: Colors.blue)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 🎮 QUIZ PAGE
// ═══════════════════════════════════════════════════════════════
class QuizPage extends StatefulWidget {
  const QuizPage({super.key});
  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<String> _currentCombination = [];
  String _combinedArabic = '';
  bool _isPlaying = false;
  bool _hasGenerated = false;
  int _score = 0;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _generateCombination() {
    final random = Random();
    final firstIndex = random.nextInt(letters.length);
    int secondIndex;
    do { secondIndex = random.nextInt(letters.length); } while (secondIndex == firstIndex);
    final first = letters[firstIndex], second = letters[secondIndex];
    final combined = '${first.arabic.replaceAll('َ', '')}${second.arabic}';
    setState(() {
      _currentCombination = [first.latin, second.latin];
      _combinedArabic = combined;
      _hasGenerated = true;
      _isPlaying = false;
    });
  }

  Future<void> _playCombinationAudio() async {
    if (_currentCombination.isEmpty) return;
    setState(() => _isPlaying = true);
    try {
      for (int i = 0; i < _currentCombination.length; i++) {
        await _audioPlayer.play(AssetSource('audio/${_currentCombination[i].toLowerCase()}.ogg'));
        await _audioPlayer.onPlayerComplete.first;
        if (i < _currentCombination.length - 1) await Future.delayed(const Duration(milliseconds: 200));
      }
      setState(() => _score++);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isPlaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🎮 Quiz Hijaiyah'), backgroundColor: Colors.purpleAccent, centerTitle: true, actions: [Padding(padding: const EdgeInsets.only(right: 16), child: Row(children: [const Icon(Icons.star, color: Colors.yellow, size: 24), const SizedBox(width: 5), Text('$_score', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))]))]),
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.purpleAccent, Colors.pinkAccent], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: const Text('🎯 Tap "Generate" untuk acak huruf, lalu dengarkan!', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                const SizedBox(height: 30),
                ElevatedButton.icon(onPressed: _generateCombination, icon: const Icon(Icons.casino, size: 28), label: const Text('🎲 Generate Kombinasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 5)),
                const SizedBox(height: 40),
                if (_hasGenerated) ...[
                  Container(padding: const EdgeInsets.all(40), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.3), blurRadius: 20, spreadRadius: 5)]), child: Column(children: [Text(_combinedArabic, style: GoogleFonts.amiri(fontSize: 120, color: Colors.purple[800], fontWeight: FontWeight.bold)), const SizedBox(height: 20), Text(_currentCombination.join('-'), style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.purple[700])), const SizedBox(height: 10), Text('(${_currentCombination[0]} + ${_currentCombination[1]})', style: TextStyle(fontSize: 16, color: Colors.grey[600]))])),
                  const SizedBox(height: 30),
                  GestureDetector(onTap: _isPlaying ? null : _playCombinationAudio, child: AnimatedContainer(duration: const Duration(milliseconds: 300), width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, gradient: _isPlaying ? const RadialGradient(colors: [Colors.red, Colors.deepOrange]) : const RadialGradient(colors: [Colors.purple, Colors.blue]), boxShadow: [BoxShadow(color: (_isPlaying ? Colors.red : Colors.purple).withOpacity(0.5), blurRadius: 30, spreadRadius: 5)], border: Border.all(color: Colors.white, width: 5)), child: Icon(_isPlaying ? Icons.volume_up : Icons.play_arrow, size: 70, color: Colors.white))),
                  const SizedBox(height: 10),
                  Text(_isPlaying ? '🔊 Sedang diputar...' : 'Tap untuk dengarkan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _isPlaying ? Colors.red : Colors.purple[800])),
                ] else ...[
                  Container(padding: const EdgeInsets.all(60), decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white, width: 3)), child: const Column(children: [Icon(Icons.help_outline, size: 80, color: Colors.white70), SizedBox(height: 20), Text('Tap tombol Generate untuk mulai!', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center)])),
                ],
                const Spacer(),
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(12)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.info_outline, color: Colors.blue), const SizedBox(width: 8), Text('Audio: ${_currentCombination.isNotEmpty ? _currentCombination.map((h) => '$h.ogg').join(' + ') : '-'}', style: const TextStyle(fontSize: 14))])),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 🎤 STT PRACTICE PAGE - WEB COMPATIBLE ✅ FINAL VERSION
// ═══════════════════════════════════════════════════════════════
class SttPracticePage extends StatefulWidget {
  const SttPracticePage({super.key});
  @override
  State<SttPracticePage> createState() => _SttPracticePageState();
}

class _SttPracticePageState extends State<SttPracticePage> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  bool _isSpeechAvailable = false;
  bool _isListening = false;
  String _recognizedWords = '';
  String _feedback = '';
  int _score = 0;
  HijaiyahData? _currentLetter;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _pickRandomLetter();
  }

  @override
  void dispose() {
    _speech.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    try {
      // Simple init - NO localeId here (causes web error)
      _isSpeechAvailable = await _speech.initialize(
        onStatus: (status) => print('🎤 Speech Status: $status'),
        onError: (error) => print('❌ Speech Error: $error'),
      );
      if (mounted) setState(() {});
    } catch (e) {
      print('❌ Failed to init speech: $e');
      if (mounted) setState(() => _isSpeechAvailable = false);
    }
  }

  void _pickRandomLetter() {
    final random = Random();
    setState(() {
      _currentLetter = letters[random.nextInt(letters.length)];
      _recognizedWords = '';
      _feedback = '';
    });
  }

  Future<void> _playExample() async {
    if (_currentLetter == null) return;
    try {
      await _audioPlayer.play(AssetSource('audio/${_currentLetter!.audioSequence.first}'));
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  Future<void> _startListening() async {
    if (!_isSpeechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Mikrofon tidak tersedia'), backgroundColor: Colors.red));
      return;
    }

    setState(() {
      _isListening = true;
      _recognizedWords = '';
      _feedback = '';
    });

    try {
      // ✅ WEB-COMPATIBLE: Simple listen() without problematic options
      _speech.listen(
        onResult: _onSpeechResult,  // Use method reference, not inline lambda
        // ❌ REMOVE: localeId parameter (causes web compilation error)
        // ❌ REMOVE: listenOptions with localeId (not supported in web)
        listenFor: const Duration(seconds: 5),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: true,
      );
    } catch (e) {
      print('❌ Error starting listen: $e');
      setState(() {
        _isListening = false;
        _feedback = '❌ Gagal: $e';
      });
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  // ✅ Use dynamic for web compatibility
  void _onSpeechResult(dynamic result) {
    // Safely extract recognized words
    String words = '';
    try {
      words = result?.recognizedWords?.toString() ?? '';
    } catch (e) {
      print('Error extracting result: $e');
      words = result?.toString() ?? '';
    }
    
    setState(() => _recognizedWords = words);

    // Check if final result
    bool isFinal = false;
    try {
      isFinal = result?.finalResult ?? false;
    } catch (_) {}
    
    if (isFinal) {
      _checkAnswer(words);
    }
  }

  void _checkAnswer(String recognizedWords) {
    setState(() => _isListening = false);
    _speech.stop();

    if (_currentLetter == null) return;

    final normalized = _normalizePinyin(recognizedWords.toLowerCase().trim());
    final expected = _normalizePinyin(_currentLetter!.mandarinPinyin);

    print('🎤 Recognized: "$recognizedWords" | Normalized: "$normalized" | Expected: "$expected"');

    // Simple matching logic
    bool isCorrect = false;
    if (normalized.isNotEmpty && expected.isNotEmpty) {
      isCorrect = normalized.contains(expected) || 
                  expected.contains(normalized) || 
                  _similarityScore(normalized, expected) >= 60;
    }

    setState(() {
      if (isCorrect) {
        _score++;
        _feedback = '🎉 Hebat! Benar! ⭐';
      } else if (recognizedWords.isEmpty) {
        _feedback = '⏰ Tidak ada suara. Coba lagi!';
      } else {
        _feedback = '💪 Coba lagi! Kamu: "$recognizedWords"';
      }
    });
  }

  String _normalizePinyin(String input) => 
      input.replaceAll(RegExp(r'[̄áǎàēéěèīíǐìōóǒòūúǔùǘǚ]'), '').replaceAll(' ', '').trim();

  int _similarityScore(String s1, String s2) {
    if (s1 == s2) return 100;
    if (s1.isEmpty || s2.isEmpty) return 0;
    final maxLen = s1.length > s2.length ? s1.length : s2.length;
    var distance = 0;
    for (var i = 0; i < maxLen; i++) {
      if (i >= s1.length || i >= s2.length || s1[i] != s2[i]) distance++;
    }
    return ((maxLen - distance) / maxLen * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎤 Latihan Ucap'), 
        backgroundColor: Colors.blueAccent, 
        centerTitle: true, 
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16), 
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.yellow, size: 24), 
                const SizedBox(width: 5), 
                Text('$_score', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Colors.blueAccent, Colors.cyanAccent], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Fallback jika STT tidak available
                if (!_isSpeechAvailable) ...[
                  Container(
                    padding: const EdgeInsets.all(16), 
                    decoration: BoxDecoration(color: Colors.orange[100], borderRadius: BorderRadius.circular(12)), 
                    child: const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange), 
                        SizedBox(width: 10), 
                        Expanded(child: Text('⚠️ Fitur suara tidak tersedia. Gunakan Chrome dan izinkan mikrofon.', style: TextStyle(fontSize: 14)))
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                
                // Instruksi
                Container(
                  padding: const EdgeInsets.all(16), 
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), 
                  child: const Text('🎯 Dengarkan contoh, lalu ucapkan huruf yang muncul!', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 30),
                
                if (_currentLetter != null) ...[
                  // Tampilan huruf
                  Container(
                    padding: const EdgeInsets.all(40), 
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 20, spreadRadius: 5)]), 
                    child: Column(
                      children: [
                        Text(_currentLetter!.arabic, style: GoogleFonts.amiri(fontSize: 120, color: Colors.blue[800], fontWeight: FontWeight.bold)), 
                        const SizedBox(height: 20), 
                        Text(_currentLetter!.latin, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue[700])), 
                        const SizedBox(height: 10), 
                        Text('Pinyin: ${_currentLetter!.mandarinPinyin}', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Tombol kontrol
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, 
                    children: [
                      ElevatedButton.icon(
                        onPressed: _playExample, 
                        icon: const Icon(Icons.volume_up), 
                        label: const Text('🔊 Dengar Contoh'), 
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      ), 
                      const SizedBox(width: 20), 
                      ElevatedButton.icon(
                        onPressed: _pickRandomLetter, 
                        icon: const Icon(Icons.refresh), 
                        label: const Text('🔄 Ganti Huruf'), 
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  // Tombol Mic Besar
                  GestureDetector(
                    onTap: _isListening ? _stopListening : _startListening, 
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300), 
                      width: 150, 
                      height: 150, 
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, 
                        gradient: _isListening ? const RadialGradient(colors: [Colors.red, Colors.deepOrange]) : const RadialGradient(colors: [Colors.blue, Colors.teal]), 
                        boxShadow: [BoxShadow(color: (_isListening ? Colors.red : Colors.blue).withOpacity(0.5), blurRadius: 30, spreadRadius: 5)], 
                        border: Border.all(color: Colors.white, width: 5),
                      ), 
                      child: Icon(_isListening ? Icons.mic : Icons.mic_none, size: 70, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isListening ? '🎤 Mendengarkan... Ucapkan "${_currentLetter!.latin}"' : 'Tap mic untuk mulai bicara', 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _isListening ? Colors.red : Colors.blue[800]), 
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  
                  // Hasil recognition
                  if (_recognizedWords.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16), 
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(12)), 
                      child: Column(
                        children: [
                          const Text('🎤 Kamu mengucapkan:', style: TextStyle(fontSize: 14, color: Colors.grey)), 
                          const SizedBox(height: 5), 
                          Text(_recognizedWords, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  
                  // Feedback
                  if (_feedback.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16), 
                      decoration: BoxDecoration(
                        color: _feedback.contains('Hebat') ? Colors.green[100] : Colors.orange[100], 
                        borderRadius: BorderRadius.circular(12), 
                        border: Border.all(color: _feedback.contains('Hebat') ? Colors.green : Colors.orange, width: 2),
                      ), 
                      child: Text(
                        _feedback, 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _feedback.contains('Hebat') ? Colors.green[800] : Colors.orange[800]), 
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
                
                const Spacer(),
                
                // Info footer
                Container(
                  padding: const EdgeInsets.all(12), 
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(12)), 
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center, 
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue), 
                      SizedBox(width: 8), 
                      Text('STT: Web Speech API (Chrome) - Locale: Browser Default', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ✍️ WRITING CANVAS
// ═══════════════════════════════════════════════════════════════
class WritingCanvas extends StatefulWidget {
  final String arabicChar;
  const WritingCanvas({super.key, required this.arabicChar});
  @override
  State<WritingCanvas> createState() => _WritingCanvasState();
}

class _WritingCanvasState extends State<WritingCanvas> {
  List<List<Offset>> _paths = [];
  List<Offset> _currentPath = [];
  void _clearCanvas() => setState(() { _paths.clear(); _currentPath.clear(); });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(border: Border.all(color: Colors.green, width: 2), borderRadius: BorderRadius.circular(20), color: Colors.white),
      child: Stack(children: [
        Center(child: Text(widget.arabicChar, style: GoogleFonts.amiri(fontSize: 220, color: Colors.grey.shade200, fontWeight: FontWeight.bold))),
        CustomPaint(painter: SignaturePainter(paths: [..._paths, _currentPath]), size: Size.infinite),
        Positioned(top: 10, right: 10, child: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: _clearCanvas, tooltip: "Hapus Coretan")),
      ]),
    );
  }
}

class SignaturePainter extends CustomPainter {
  final List<List<Offset>> paths;
  SignaturePainter({required this.paths});
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = Colors.blueAccent..strokeCap = StrokeCap.round..strokeWidth = 15.0;
    for (var path in paths) { if (path.isEmpty) continue; canvas.drawPath(getPathFromPoints(path), paint); }
  }
  Path getPathFromPoints(List<Offset> points) {
    Path path = Path();
    if (points.isEmpty) return path;
    path.moveTo(points[0].dx, points[0].dy);
    for (var point in points) path.lineTo(point.dx, point.dy);
    return path;
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}