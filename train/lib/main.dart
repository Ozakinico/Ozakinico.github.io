import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: DotCountingTrainingApp()));
}

const String appTitle = '点の数あてトレーニング';

class DotCountingTrainingApp extends StatefulWidget {
  const DotCountingTrainingApp({super.key});
  @override
  State<DotCountingTrainingApp> createState() => _DotCountingTrainingAppState();
}

class _DotCountingTrainingAppState extends State<DotCountingTrainingApp> {
  final _rnd = Random();
  final _controller = TextEditingController();

  // ===== 出題パラメータ（難易度調整はここだけ） =====
  static const int minCount = 30;
  static const int maxCount = 200;
  static const double minRadius = 2.0;
  static const double maxRadius = 5.0;

  // ===== 状態 =====
  int _round = 1;
  bool _showAnswer = false;
  bool _checked = false;

  int _targetCount = 0;
  double _dotRadius = 3.0;
  List<Offset> _dots = []; // 0..1 正規化座標

  int? _userAnswer;

  @override
  void initState() {
    super.initState();
    _newRound();
  }

  void _newRound() {
    _controller.clear();
    _showAnswer = false;
    _checked = false;
    _userAnswer = null;

    _targetCount = minCount + _rnd.nextInt(maxCount - minCount + 1);
    _dotRadius = minRadius + _rnd.nextDouble() * (maxRadius - minRadius);

    _dots = List.generate(
      _targetCount,
      (_) => Offset(_rnd.nextDouble(), _rnd.nextDouble()),
    );

    setState(() {});
  }

  void _toggleNext() {
    setState(() {
      if (_showAnswer) {
        _round++;
        _newRound();
      } else {
        _showAnswer = true;
      }
    });
  }

  void _checkAnswer() {
    final txt = _controller.text.trim();
    final n = int.tryParse(txt);
    setState(() {
      _checked = true;
      _userAnswer = n;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(appTitle)),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleNext,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _DotPainter(dots: _dots, radius: _dotRadius),
              ),
            ),

            Positioned(
              top: 10,
              left: 10,
              child: _chip('Round $_round'),
            ),

            Positioned(
              top: 10,
              right: 10,
              child: _chip(_showAnswer ? 'タップで次へ' : 'タップで正解表示'),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Text(
                            '何個ある？',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: '数字を入力',
                                hintStyle: const TextStyle(color: Colors.white70),
                                filled: true,
                                fillColor: Colors.black38,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                              onSubmitted: (_) => _checkAnswer(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _checkAnswer,
                            child: const Text('判定'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      if (_checked) _resultLine(),

                      if (_showAnswer)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            '正解：$_targetCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _resultLine() {
    final user = _userAnswer;
    final userText = user == null ? '（未入力）' : user.toString();
    final diff = user == null ? null : (user - _targetCount).abs();
    final diffText = diff == null ? '' : '（誤差: $diff）';

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'あなた: $userText / 正解: $_targetCount $diffText',
        style: const TextStyle(color: Colors.white70, fontSize: 16),
      ),
    );
  }
}

class _DotPainter extends CustomPainter {
  final List<Offset> dots; // 0..1
  final double radius;

  _DotPainter({required this.dots, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    for (final d in dots) {
      final x = d.dx * size.width;
      final y = d.dy * size.height;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DotPainter oldDelegate) {
    return oldDelegate.dots != dots || oldDelegate.radius != radius;
  }
}
