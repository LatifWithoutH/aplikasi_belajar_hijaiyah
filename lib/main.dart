import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final bool isCombined;

  HijaiyahData({
    required this.arabic,
    required this.latin,
    required this.audioSequence,
    this.isCombined = false,
  });
}

// Data Huruf (Termasuk 1 Kombinasi Contoh)
final List<HijaiyahData> letters = [
  HijaiyahData(arabic: 'أَ', latin: 'Alif', audioSequence: ['alif.ogg']),
  HijaiyahData(arabic: 'بَ', latin: 'Ba', audioSequence: ['ba.ogg']),
  HijaiyahData(arabic: 'تَ', latin: 'Ta', audioSequence: ['ta.ogg']),
  HijaiyahData(arabic: 'ثَ', latin: 'Tsa', audioSequence: ['tsa.ogg']),
  // Contoh kombinasi di list utama (opsional)
  HijaiyahData(
    arabic: 'بَتَ',
    latin: 'Ba-Ta',
    audioSequence: ['ba.ogg', 'ta.ogg'],
    isCombined: true,
  ),
];

// ═══════════════════════════════════════════════════════════════
// 🎨 APP CONFIGURATION
// ═══════════════════════════════════════════════════════════════
class HijaiyahApp extends StatelessWidget {
  const HijaiyahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Belajar Hijaiyah',
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
          itemCount: letters.length + 1, // +1 untuk card Quiz
          itemBuilder: (context, index) {
            // Card terakhir adalah Quiz
            if (index == letters.length) {
              return _buildQuizCard(context);
            }

            final letter = letters[index];
            return _buildLetterCard(context, letter);
          },
        ),
      ),
    );
  }

  Widget _buildLetterCard(BuildContext context, HijaiyahData letter) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LearningScreen(letter: letter)),
        );
      },
      child: Card(
        elevation: 6,
        shadowColor: letter.isCombined ? Colors.orange : Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (letter.isCombined)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "Gabungan",
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            if (letter.isCombined) const SizedBox(height: 5),
            CircleAvatar(
              radius: letter.isCombined ? 35 : 45,
              backgroundColor: Colors.white,
              child: Text(
                letter.arabic,
                style: GoogleFonts.amiri(
                  fontSize: letter.isCombined ? 40 : 50,
                  color: Colors.green[800],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              letter.latin,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: letter.isCombined ? Colors.orange[800] : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QuizPage()),
        );
      },
      child: Card(
        elevation: 6,
        shadowColor: Colors.purple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.purpleAccent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.casino,
                size: 50,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              '🎮 Quiz',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Acak & Dengar',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 📖 LEARNING SCREEN (Individual Letter)
// ═══════════════════════════════════════════════════════════════
class LearningScreen extends StatefulWidget {
  final HijaiyahData letter;
  const LearningScreen({super.key, required this.letter});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen>
    with SingleTickerProviderStateMixin {
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
        final path = 'audio/${widget.letter.audioSequence[i]}';
        await _audioPlayer.play(AssetSource(path));
        await _audioPlayer.onPlayerComplete.first;
        if (i < widget.letter.audioSequence.length - 1) {
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.green[800],
          tabs: const [
            Tab(icon: Icon(Icons.volume_up), text: "Dengar"),
            Tab(icon: Icon(Icons.edit), text: "Tulis"),
            Tab(icon: Icon(Icons.info), text: "Info"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReadListenMode(),
          _buildWritingMode(),
          _buildInfoMode(),
        ],
      ),
    );
  }

  Widget _buildReadListenMode() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Text(
              widget.letter.arabic,
              style: GoogleFonts.amiri(
                fontSize: 180,
                color: Colors.green[800],
              ),
            ),
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: _isPlaying ? null : _playAudio,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _isPlaying
                    ? const RadialGradient(colors: [Colors.red, Colors.orange])
                    : const RadialGradient(colors: [Colors.green, Colors.teal]),
                boxShadow: [
                  BoxShadow(
                    color: (_isPlaying ? Colors.red : Colors.green).withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: Icon(
                _isPlaying ? Icons.volume_up : Icons.play_arrow,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _isPlaying ? '🔊 Memutar...' : 'Tap untuk dengar',
            style: TextStyle(
              fontSize: 16,
              color: _isPlaying ? Colors.red : Colors.green[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWritingMode() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Telusuri huruf di bawah:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: WritingCanvas(arabicChar: widget.letter.arabic)),
      ],
    );
  }

  Widget _buildInfoMode() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, size: 80, color: Colors.blue),
          const SizedBox(height: 20),
          Text(
            'Huruf: ${widget.letter.latin}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Audio: ${widget.letter.audioSequence.join(" + ")}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          if (widget.letter.isCombined) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '✨ Ini adalah huruf gabungan!',
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 🎮 QUIZ PAGE (Generate & Listen)
// ═══════════════════════════════════════════════════════════════
class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  final Map<String, String> _hurufData = {
    'Alif': 'أَ',
    'Ba': 'بَ',
    'Ta': 'تَ',
    'Tsa': 'ثَ',
  };

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
    final hurufList = _hurufData.keys.toList();

    final firstIndex = random.nextInt(hurufList.length);
    int secondIndex;
    do {
      secondIndex = random.nextInt(hurufList.length);
    } while (secondIndex == firstIndex);

    final firstHuruf = hurufList[firstIndex];
    final secondHuruf = hurufList[secondIndex];

    final firstArabic = _hurufData[firstHuruf]!.replaceAll('َ', '');
    final secondArabic = _hurufData[secondHuruf];
    final combined = '$firstArabic$secondArabic';

    setState(() {
      _currentCombination = [firstHuruf, secondHuruf];
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
        final huruf = _currentCombination[i].toLowerCase();
        final path = 'audio/$huruf.ogg';
        await _audioPlayer.play(AssetSource(path));
        await _audioPlayer.onPlayerComplete.first;
        if (i < _currentCombination.length - 1) {
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }
      // Tambah skor setelah selesai dengar
      setState(() => _score++);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isPlaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎮 Quiz Hijaiyah'),
        backgroundColor: Colors.purpleAccent,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.yellow, size: 24),
                  const SizedBox(width: 5),
                  Text(
                    '$_score',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purpleAccent, Colors.pinkAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Instruksi
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    '🎯 Tap "Generate" untuk acak huruf, lalu dengarkan!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 30),

                // Tombol Generate
                ElevatedButton.icon(
                  onPressed: _generateCombination,
                  icon: const Icon(Icons.casino, size: 28),
                  label: const Text(
                    '🎲 Generate Kombinasi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                ),
                const SizedBox(height: 40),

                // Area Tampilan
                if (_hasGenerated) ...[
                  // Teks Arab
                  Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          _combinedArabic,
                          style: GoogleFonts.amiri(
                            fontSize: 120,
                            color: Colors.purple[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _currentCombination.join('-'),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[700],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '(${_currentCombination[0]} + ${_currentCombination[1]})',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Tombol Play
                  GestureDetector(
                    onTap: _isPlaying ? null : _playCombinationAudio,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: _isPlaying
                            ? const RadialGradient(colors: [Colors.red, Colors.deepOrange])
                            : const RadialGradient(colors: [Colors.purple, Colors.blue]),
                        boxShadow: [
                          BoxShadow(
                            color: (_isPlaying ? Colors.red : Colors.purple).withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                        border: Border.all(color: Colors.white, width: 5),
                      ),
                      child: Icon(
                        _isPlaying ? Icons.volume_up : Icons.play_arrow,
                        size: 70,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isPlaying ? '🔊 Sedang diputar...' : 'Tap untuk dengarkan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _isPlaying ? Colors.red : Colors.purple[800],
                    ),
                  ),
                ] else ...[
                  // Placeholder
                  Container(
                    padding: const EdgeInsets.all(60),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.help_outline, size: 80, color: Colors.white70),
                        SizedBox(height: 20),
                        Text(
                          'Tap tombol Generate untuk mulai!',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],

                const Spacer(),

                // Info Audio
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Audio: ${_currentCombination.isNotEmpty ? _currentCombination.map((h) => '$h.ogg').join(' + ') : '-'}',
                        style: const TextStyle(fontSize: 14),
                      ),
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

  void _clearCanvas() {
    setState(() {
      _paths.clear();
      _currentPath.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green, width: 2),
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              widget.arabicChar,
              style: GoogleFonts.amiri(
                fontSize: 220,
                color: Colors.grey.shade200,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          CustomPaint(
            painter: SignaturePainter(paths: [..._paths, _currentPath]),
            size: Size.infinite,
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _clearCanvas,
              tooltip: "Hapus Coretan",
            ),
          ),
        ],
      ),
    );
  }
}

class SignaturePainter extends CustomPainter {
  final List<List<Offset>> paths;
  SignaturePainter({required this.paths});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.blueAccent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 15.0;

    for (var path in paths) {
      if (path.isEmpty) continue;
      canvas.drawPath(getPathFromPoints(path), paint);
    }
  }

  Path getPathFromPoints(List<Offset> points) {
    Path path = Path();
    if (points.isEmpty) return path;
    path.moveTo(points[0].dx, points[0].dy);
    for (var point in points) {
      path.lineTo(point.dx, point.dy);
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}