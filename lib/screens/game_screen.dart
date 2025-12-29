import 'dart:math';
import 'package:flutter/material.dart';
import '../services/localizer.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  Widget _buildCloud(double scale, {double opacity = 0.65}) {
    // 이미지 스타일 구름 - 부드러운 그림자와 함께
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 140,
        height: 70,
        child: Stack(
          children: [
            // 그림자 레이어
            Positioned(
              left: 5,
              top: 25,
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFD8EEF4).withOpacity(opacity),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 25,
              top: 12,
              child: Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE0F0F5).withOpacity(opacity),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 60,
              top: 8,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE5F2F7).withOpacity(opacity),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 90,
              top: 20,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFD8EEF4).withOpacity(opacity),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.tr('game.title')),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // 배경 (하늘 그라데이션 + 구름 + 이미지)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF7DCCEC), // 이미지와 매칭되는 하늘색
                    Color(0xFF7DCCEC),
                    Color(0xFF7DCCEC),
                  ],
                ),
              ),
            ),
          ),
          // 상단 구름들
          Positioned(
            top: 180,
            left: -20,
            child: _buildCloud(1.3),
          ),
          Positioned(
            top: 240,
            right: -30,
            child: _buildCloud(1.6),
          ),
          Positioned(
            top: 350,
            left: 40,
            child: _buildCloud(1.0),
          ),
          // 이미지
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Image.asset(
              'assets/images/game_background.png',
              fit: BoxFit.fitWidth,
              width: double.infinity,
            ),
          ),
          // 이미지 위에 오버레이 구름 (반만 보이게)
          Positioned(
            bottom: 320,
            left: -40,
            child: _buildCloud(1.8, opacity: 0.7),
          ),
          Positioned(
            bottom: 280,
            right: -50,
            child: _buildCloud(2.0, opacity: 0.6),
          ),
          // 내용
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // 오너 뽑기 카드
                _GameCard(
                  imagePath: 'assets/icon/compass_icon.png',
                  title: L10n.tr('game.ownerPick'),
                  description: L10n.tr('game.ownerPickDesc'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const OwnerPickScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                // 팀 뽑기 카드
                _GameCard(
                  imagePath: 'assets/icon/chopstick_icon.png',
                  title: L10n.tr('game.teamPick'),
                  description: L10n.tr('game.teamPickDesc'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TeamPickScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final IconData? icon;
  final String? imagePath;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _GameCard({
    this.icon,
    this.imagePath,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          imagePath!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        icon,
                        size: 32,
                        color: const Color(0xFF2E7D32),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF2E7D32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== 오너 뽑기 나침반 화면 ====================
class _Player {
  final int id;
  final String name;
  final double angle;
  final String direction;
  final String emoji;

  const _Player({
    required this.id,
    required this.name,
    required this.angle,
    required this.direction,
    required this.emoji,
  });
}

class OwnerPickScreen extends StatefulWidget {
  const OwnerPickScreen({super.key});

  @override
  State<OwnerPickScreen> createState() => _OwnerPickScreenState();
}

class _OwnerPickScreenState extends State<OwnerPickScreen>
    with SingleTickerProviderStateMixin {
  static const List<_Player> _players = [
    _Player(id: 1, name: 'Player 1', angle: 0, direction: 'N', emoji: '🏌️'),
    _Player(id: 2, name: 'Player 2', angle: 90, direction: 'E', emoji: '⛳'),
    _Player(id: 3, name: 'Player 3', angle: 180, direction: 'S', emoji: '🏆'),
    _Player(id: 4, name: 'Player 4', angle: 270, direction: 'W', emoji: '⚡'),
  ];

  bool _spinning = false;
  double _rotation = 0;
  _Player? _winner;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _spin() {
    if (_spinning) return;

    setState(() {
      _spinning = true;
      _winner = null;
    });

    final random = Random();
    final fullSpins = 3 + random.nextInt(3);
    final randomAngle = random.nextDouble() * 360;
    final totalRotation = (fullSpins * 360) + randomAngle;

    setState(() {
      _rotation = totalRotation;
    });

    Future.delayed(const Duration(milliseconds: 3000), () {
      if (!mounted) return;

      final finalAngle = totalRotation % 360;
      _Player selectedPlayer;

      if (finalAngle >= 315 || finalAngle < 45) {
        selectedPlayer = _players[0]; // N
      } else if (finalAngle >= 45 && finalAngle < 135) {
        selectedPlayer = _players[1]; // E
      } else if (finalAngle >= 135 && finalAngle < 225) {
        selectedPlayer = _players[2]; // S
      } else {
        selectedPlayer = _players[3]; // W
      }

      setState(() {
        _winner = selectedPlayer;
        _spinning = false;
      });
    });
  }

  void _reset() {
    setState(() {
      _rotation = 0;
      _winner = null;
      _spinning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final compassSize = size.width * 0.85;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF312e81), // indigo-900
              Color(0xFF581c87), // purple-900
              Color(0xFF831843), // pink-900
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 상단 바
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        L10n.tr('game.compassTitle'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: _reset,
                        icon: const Icon(Icons.refresh_rounded,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ),
              ),

              // 상태 텍스트
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  _spinning
                      ? L10n.tr('game.compassSpinning')
                      : _winner != null
                          ? L10n.tr('game.compassDecided')
                          : L10n.tr('game.compassSpin'),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.purple[200],
                  ),
                ),
              ),

              // 나침반
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: compassSize,
                    height: compassSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 외곽 원
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF374151), Color(0xFF111827)],
                            ),
                            border: Border.all(
                              color: const Color(0xFFD97706),
                              width: 6,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                        ),

                        // 내부 원
                        Container(
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF4B5563), Color(0xFF1F2937)],
                            ),
                            border: Border.all(
                              color: const Color(0xFFB45309),
                              width: 3,
                            ),
                          ),
                        ),

                        // 눈금
                        ...List.generate(36, (i) {
                          final angle = i * 10.0;
                          final isMain = i % 9 == 0;
                          return Transform.rotate(
                            angle: angle * pi / 180,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                margin: const EdgeInsets.only(top: 24),
                                width: 2,
                                height: isMain ? 16 : 8,
                                color: isMain
                                    ? const Color(0xFFFBBF24)
                                    : Colors.grey[500],
                              ),
                            ),
                          );
                        }),

                        // 플레이어들
                        ..._players.map((player) {
                          final isWinner = _winner?.id == player.id;
                          return Transform.rotate(
                            angle: player.angle * pi / 180,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Transform.rotate(
                                angle: -player.angle * pi / 180,
                                child: Container(
                                  margin: const EdgeInsets.only(top: 50),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 500),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isWinner
                                          ? const Color(0xFFFBBF24)
                                          : Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: isWinner
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFFFBBF24)
                                                    .withOpacity(0.5),
                                                blurRadius: 15,
                                                spreadRadius: 2,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          player.emoji,
                                          style: const TextStyle(fontSize: 24),
                                        ),
                                        Text(
                                          player.name,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isWinner
                                                ? Colors.grey[900]
                                                : Colors.white,
                                          ),
                                        ),
                                        Text(
                                          player.direction,
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: isWinner
                                                ? Colors.grey[700]
                                                : Colors.grey[400],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),

                        // 중앙 원
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF4B5563), Color(0xFF1F2937)],
                            ),
                            border: Border.all(
                              color: const Color(0xFFD97706),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text('🧭', style: TextStyle(fontSize: 30)),
                          ),
                        ),

                        // 바늘
                        AnimatedRotation(
                          turns: _rotation / 360,
                          duration: Duration(milliseconds: _spinning ? 3000 : 300),
                          curve: _spinning
                              ? Curves.easeOutCubic
                              : Curves.easeOut,
                          child: SizedBox(
                            width: compassSize,
                            height: compassSize,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // 빨간 바늘 (위)
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 60),
                                    child: CustomPaint(
                                      size: const Size(24, 100),
                                      painter: _NeedlePainter(
                                        color: const Color(0xFFEF4444),
                                      ),
                                    ),
                                  ),
                                ),
                                // 회색 바늘 (아래)
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 60),
                                    child: Transform.rotate(
                                      angle: pi,
                                      child: CustomPaint(
                                        size: const Size(24, 100),
                                        painter: _NeedlePainter(
                                          color: const Color(0xFF6B7280),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // 중앙 핀
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFFBBF24),
                                    border: Border.all(
                                      color: const Color(0xFF1F2937),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 5,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // SPIN 버튼
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _spinning ? 1.0 : _pulseAnimation.value,
                              child: GestureDetector(
                                onTap: _spin,
                                child: Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: _spinning
                                        ? const LinearGradient(
                                            colors: [
                                              Color(0xFF4B5563),
                                              Color(0xFF374151)
                                            ],
                                          )
                                        : const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFFFBBF24),
                                              Color(0xFFF97316)
                                            ],
                                          ),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (_spinning
                                                ? Colors.grey
                                                : Colors.orange)
                                            .withOpacity(0.5),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('🎯',
                                          style: TextStyle(fontSize: 28)),
                                      Text(
                                        _spinning ? '...' : 'SPIN',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 결과 표시
              if (_winner != null)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _winner!.emoji,
                        style: const TextStyle(fontSize: 48),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        L10n.tr('game.ownerDecided'),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _winner!.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFCD34D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        L10n.tr('game.honorTeeShot'),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.purple[200],
                        ),
                      ),
                    ],
                  ),
                )
              else
                const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}

// 바늘 CustomPainter
class _NeedlePainter extends CustomPainter {
  final Color color;

  _NeedlePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);

    // 하이라이트
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final highlightPath = Path()
      ..moveTo(size.width / 2, 10)
      ..lineTo(size.width / 2 - 3, size.height * 0.4)
      ..lineTo(size.width / 2 + 3, size.height * 0.4)
      ..close();

    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==================== 젓가락 뽑기 (팀 뽑기) 화면 ====================
enum StickColor { red, blue, joker }

class Stick {
  final int id;
  final StickColor color;
  bool picked;
  bool rotating;
  int? pickedBy;
  bool revealed;
  StickColor? tempColor;

  Stick({
    required this.id,
    required this.color,
    this.picked = false,
    this.rotating = false,
    this.pickedBy,
    this.revealed = false,
    this.tempColor,
  });

  Stick copyWith({
    int? id,
    StickColor? color,
    bool? picked,
    bool? rotating,
    int? pickedBy,
    bool? revealed,
    StickColor? tempColor,
    bool clearPickedBy = false,
    bool clearTempColor = false,
  }) {
    return Stick(
      id: id ?? this.id,
      color: color ?? this.color,
      picked: picked ?? this.picked,
      rotating: rotating ?? this.rotating,
      pickedBy: clearPickedBy ? null : (pickedBy ?? this.pickedBy),
      revealed: revealed ?? this.revealed,
      tempColor: clearTempColor ? null : (tempColor ?? this.tempColor),
    );
  }
}

class TeamPickScreen extends StatefulWidget {
  const TeamPickScreen({super.key});

  @override
  State<TeamPickScreen> createState() => _TeamPickScreenState();
}

class _TeamPickScreenState extends State<TeamPickScreen>
    with TickerProviderStateMixin {
  late List<Stick> _sticks;
  bool _gameOver = false;
  int _currentPlayer = 1;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _shuffleSticks();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _shuffleSticks() {
    final colors = [
      StickColor.red,
      StickColor.red,
      StickColor.blue,
      StickColor.blue,
      StickColor.joker,
    ];
    colors.shuffle(Random());
    _sticks = List.generate(
      5,
      (index) => Stick(id: index + 1, color: colors[index]),
    );
  }

  void _pickStick(int id) {
    if (_gameOver || _currentPlayer > 4) return;

    final stickIndex = _sticks.indexWhere((s) => s.id == id);
    if (stickIndex == -1) return;

    final stick = _sticks[stickIndex];
    if (stick.picked) return;

    setState(() {
      _sticks[stickIndex] = stick.copyWith(rotating: true);
    });

    final colors = [StickColor.red, StickColor.blue, StickColor.joker];
    int colorIndex = 0;
    final colorTimer = Stream.periodic(
      const Duration(milliseconds: 80),
      (i) => i,
    ).take(8).listen((i) {
      if (mounted) {
        setState(() {
          _sticks[stickIndex] = _sticks[stickIndex].copyWith(
            tempColor: colors[colorIndex % colors.length],
          );
        });
        colorIndex++;
      }
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      colorTimer.cancel();
      if (!mounted) return;

      setState(() {
        _sticks[stickIndex] = _sticks[stickIndex].copyWith(
          picked: true,
          rotating: false,
          pickedBy: _currentPlayer,
          revealed: true,
          clearTempColor: true,
        );

        if (_currentPlayer == 4) {
          _gameOver = true;
        } else {
          _currentPlayer++;
        }
      });
    });
  }

  void _reset() {
    setState(() {
      _shuffleSticks();
      _gameOver = false;
      _currentPlayer = 1;
    });
  }

  Color _getStickColor(StickColor color) {
    switch (color) {
      case StickColor.red:
        return const Color(0xFFE53935);
      case StickColor.blue:
        return const Color(0xFF1E88E5);
      case StickColor.joker:
        return const Color(0xFFFFB300);
    }
  }

  List<Color> _getStickGradient(StickColor color) {
    switch (color) {
      case StickColor.red:
        return [const Color(0xFFEF5350), const Color(0xFFC62828)];
      case StickColor.blue:
        return [const Color(0xFF42A5F5), const Color(0xFF1565C0)];
      case StickColor.joker:
        return [const Color(0xFFFFD54F), const Color(0xFFFF8F00)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D1B2A),
              Color(0xFF1B263B),
              Color(0xFF415A77),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 상단 바
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 20),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        L10n.tr('game.chopstickTitle'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: _reset,
                        icon: const Icon(Icons.refresh_rounded,
                          color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // 현재 플레이어 표시
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _gameOver ? 1.0 : _pulseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _gameOver
                              ? [const Color(0xFF4CAF50), const Color(0xFF2E7D32)]
                              : [const Color(0xFFFF6B6B), const Color(0xFFEE5A24)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: (_gameOver ? Colors.green : Colors.orange)
                                .withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _gameOver ? Icons.celebration : Icons.sports_golf,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _gameOver
                                ? L10n.tr('game.gameComplete')
                                : L10n.tr('game.playerTurn', params: {'num': '$_currentPlayer'}),
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // 젓가락 영역
              Expanded(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.15),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: _sticks.map((stick) {
                        return _buildStick(stick);
                      }).toList(),
                    ),
                  ),
                ),
              ),

              // 하단 팀 정보
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTeamIndicator(
                        '🔴',
                        'RED',
                        const Color(0xFFE53935),
                        _sticks
                            .where((s) => s.color == StickColor.red && s.pickedBy != null)
                            .map((s) => s.pickedBy!)
                            .toList(),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    Expanded(
                      child: _buildTeamIndicator(
                        '🔵',
                        'BLUE',
                        const Color(0xFF1E88E5),
                        _sticks
                            .where((s) => s.color == StickColor.blue && s.pickedBy != null)
                            .map((s) => s.pickedBy!)
                            .toList(),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    Expanded(
                      child: _buildTeamIndicator(
                        '⭐',
                        'JOKER',
                        const Color(0xFFFFB300),
                        _sticks
                            .where((s) => s.color == StickColor.joker && s.pickedBy != null)
                            .map((s) => s.pickedBy!)
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamIndicator(String emoji, String label, Color color, List<int> players) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          players.isEmpty ? '-' : players.map((p) => 'P$p').join(', '),
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStick(Stick stick) {
    final displayColor = stick.rotating && stick.tempColor != null
        ? stick.tempColor!
        : stick.color;
    final isAvailable = !stick.picked && !_gameOver && _currentPlayer <= 4;

    return GestureDetector(
      onTap: () => _pickStick(stick.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(isAvailable ? 1.0 : 0.95),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // 플레이어 표시
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: stick.pickedBy != null ? 36 : 0,
              child: stick.pickedBy != null
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _getStickGradient(stick.color),
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _getStickColor(stick.color).withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        'P${stick.pickedBy}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : const SizedBox(),
            ),

            // 젓가락 손잡이 (상단)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: stick.picked
                      ? [Colors.grey[600]!, Colors.grey[800]!]
                      : [Colors.grey[400]!, Colors.grey[700]!],
                  center: const Alignment(-0.3, -0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(stick.rotating ? 0.6 : 0.4),
                    blurRadius: stick.rotating ? 20 : 10,
                    offset: const Offset(0, 5),
                  ),
                  if (isAvailable)
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 15,
                      spreadRadius: -5,
                    ),
                ],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: stick.rotating
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation(Colors.white54),
                          ),
                        )
                      : Text(
                          '?',
                          style: TextStyle(
                            fontSize: 28,
                            color: isAvailable
                                ? Colors.white.withOpacity(0.8)
                                : Colors.grey[500],
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                ),
              ),
            ),

            // 젓가락 몸통
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              width: 12,
              height: stick.picked ? 120 : 35,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.grey[500]!,
                    Colors.grey[400]!,
                    Colors.grey[500]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
            ),

            // 젓가락 끝 (색상)
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              width: stick.picked ? 44 : 0,
              height: stick.picked ? 44 : 0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getStickGradient(displayColor),
                ),
                boxShadow: [
                  BoxShadow(
                    color: stick.picked
                        ? _getStickColor(displayColor).withOpacity(0.6)
                        : Colors.transparent,
                    blurRadius: stick.picked ? 15 : 0,
                    spreadRadius: stick.picked ? 3 : 0,
                  ),
                ],
              ),
              child: stick.color == StickColor.joker && stick.revealed
                  ? const Center(
                      child: Text('⭐', style: TextStyle(fontSize: 22)),
                    )
                  : null,
            ),

            const SizedBox(height: 12),

            // 젓가락 번호
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: stick.picked
                    ? Colors.grey[800]!.withOpacity(0.5)
                    : Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '#${stick.id}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: stick.picked
                      ? Colors.grey[500]
                      : Colors.white.withOpacity(0.9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
