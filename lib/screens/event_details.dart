import 'dart:async';
import 'package:amingo/services/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'bingo_board.dart';
import 'game_monitor.dart';
import 'dart:convert';

class EventDetails extends StatefulWidget {
  final String eventName;
  final String hostName;
  final String hostPfp;
  final String joinOrStart;
  final int duration;
  final String description;
  final String joinCode;
  final String qrImage;
  final int participantCount;
  final String initialGridSize;
  final Function(String)? onGridSizeChanged;

  const EventDetails({
    super.key,
    required this.qrImage,
    required this.eventName,
    required this.hostName,
    required this.hostPfp,
    required this.joinOrStart,
    required this.duration,
    required this.description,
    required this.joinCode,
    this.participantCount = 0,
    this.initialGridSize = '5 x 5',
    this.onGridSizeChanged,
  });

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  late String _selectedGridSize;
  int _currentParticipantCount = 0;
  String _currentHostName = "";
  String _currentHostPfp = "";
  String _currentEventName = "";
  String _currentDescription = "";
  bool _gameStarted = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _selectedGridSize = widget.initialGridSize;
    _currentParticipantCount = widget.participantCount;
    _currentHostName = widget.hostName;
    _currentHostPfp = widget.hostPfp;
    _currentEventName = widget.eventName;
    _currentDescription = widget.description;
    _startPolling();
  }

  void _startPolling() {
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _fetchEventData(),
    );
  }

  Future<void> _fetchEventData() async {
    if (widget.joinCode.isEmpty) return;
    try {
      final lobbyResponse = await AuthService().getLobby(widget.joinCode);
      final gameResponse = await AuthService().getGameDetails(widget.joinCode);

      if (mounted) {
        final game = gameResponse.data;
        setState(() {
          _currentParticipantCount =
              lobbyResponse.data['player_count'] ?? _currentParticipantCount;

          final String? hostName = game['host_name'];
          if (hostName != null && hostName.isNotEmpty) {
            _currentHostName = hostName;
          } else {
            // Final fallback to the widget's initial name if API returns nothing
            _currentHostName = _currentHostName.isEmpty
                ? widget.hostName
                : _currentHostName;
          }

          _gameStarted = game['board_size'] != null;

          final String rawDesc = game['description'] ?? "";
          if (rawDesc.contains('|')) {
            var parts = rawDesc.split('|');
            _currentEventName = parts[0].trim();
            _currentDescription = parts[1].trim();
          } else if (rawDesc.isNotEmpty) {
            _currentEventName = rawDesc;
            _currentDescription = "";
          }

          if (game['host_pfp'] != null) {
            String pfpPath = game['host_pfp'];
            _currentHostPfp = pfpPath.startsWith('http')
                ? pfpPath
                : "${AuthService.baseUrl}${pfpPath.startsWith('/') ? '' : '/'}$pfpPath";
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching event data: $e");
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant EventDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialGridSize != widget.initialGridSize) {
      setState(() {
        _selectedGridSize = widget.initialGridSize;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    final List<EventDetail> details = [
      if (widget.joinOrStart == "START")
        EventDetail(
          icon: Icons.key_rounded,
          mainDetail: "Join Code",
          subDetail: widget.joinCode,
        ),
      EventDetail(
        icon: Icons.timer_rounded,
        mainDetail: "Duration",
        subDetail: "${widget.duration} mins",
      ),
      EventDetail(
        icon: Icons.description_rounded,
        mainDetail: "Description",
        subDetail: _currentDescription,
      ),
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          "•  LIVE EVENT",
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildBanner(size, colorScheme, textTheme),
                    const SizedBox(height: 24),
                    _buildHostHeader(textTheme, colorScheme, size),
                    const SizedBox(height: 24),
                    ...details.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DetailCard(
                          icon: item.icon,
                          mainDetail: item.mainDetail,
                          subDetail: item.subDetail,
                        ),
                      ),
                    ),
                    if (widget.joinOrStart == "START")
                      _buildQRCodeSection(textTheme, size),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildBottomPanel(colorScheme, textTheme, size),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner(Size size, ColorScheme cs, TextTheme tt) {
    return Container(
      width: double.infinity,
      height: size.height * 0.2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: AssetImage('assets/images/crowd_gathering.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "SOCIAL BINGO",
                style: tt.labelSmall?.copyWith(
                  color: cs.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHostHeader(TextTheme tt, ColorScheme cs, Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _currentEventName,
          style: tt.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: cs.primary, width: 2),
              ),
              child: CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(_currentHostPfp),
                backgroundColor: cs.surfaceContainer,
                onBackgroundImageError: (exception, stackTrace) {},
                child: _currentHostPfp.isEmpty
                    ? const Icon(Icons.person)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "HOSTED BY",
                  style: tt.labelSmall?.copyWith(
                    color: cs.primary,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _currentHostName,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQRCodeSection(TextTheme tt, Size size) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Text(
          "QR Code",
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (widget.qrImage.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.memory(
              base64Decode(widget.qrImage.split(',').last),
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.qr_code_2_rounded, size: 200),
            ),
          )
        else
          const Icon(Icons.qr_code_2_rounded, size: 200),
        const SizedBox(height: 12),
        SelectableText(
          widget.joinCode,
          style: tt.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomPanel(ColorScheme cs, TextTheme tt, Size size) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.joinOrStart == 'START')
            _buildGridSizeSelector(cs, tt, size),
          _buildParticipantCount(cs, tt),
          const SizedBox(height: 16),
          _buildActionButton(cs, tt, size),
        ],
      ),
    );
  }

  Widget _buildGridSizeSelector(ColorScheme cs, TextTheme tt, Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "GRID SIZE",
          style: tt.labelSmall?.copyWith(
            color: cs.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: ['3 x 3', '4 x 4', '5 x 5'].map((sizeLabel) {
              final isSelected = _selectedGridSize == sizeLabel;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedGridSize = sizeLabel);
                    if (widget.onGridSizeChanged != null) {
                      widget.onGridSizeChanged!(sizeLabel);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? cs.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      sizeLabel,
                      textAlign: TextAlign.center,
                      style: tt.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildParticipantCount(ColorScheme cs, TextTheme tt) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.people_alt_rounded, size: 18, color: cs.primary),
        const SizedBox(width: 8),
        Text(
          "Participants Joined: ",
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        Text(
          "$_currentParticipantCount",
          style: tt.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(ColorScheme cs, TextTheme tt, Size size) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          if (widget.joinOrStart == 'PLAY' || widget.joinOrStart == 'RESUME') {
            if (!_gameStarted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Waiting for host to start the game..."),
                ),
              );
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BingoBoard(
                  joinCode: widget.joinCode,
                  eventName: _currentEventName,
                  hostName: _currentHostName,
                  timelimit: widget.duration,
                  description: _currentDescription,
                ),
              ),
            );
          } else if (widget.joinOrStart == 'START') {
            try {
              int gridIntSize =
                  int.tryParse(_selectedGridSize.split('x').first.trim()) ?? 5;
              await AuthService().startGame(
                code: widget.joinCode,
                size: gridIntSize,
              );
              if (!mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameMonitorScreen(
                    eventName: widget.eventName,
                    time: widget.duration,
                    maxParticipants: '100',
                    joinCode: widget.joinCode,
                  ),
                ),
              );
            } catch (e) {
              String errorMsg = "Failed to start game: $e";
              if (e is DioException && e.response?.data is Map) {
                final detail = e.response!.data['detail'];
                if (detail != null) errorMsg = detail.toString();
              }
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(errorMsg)));
              }
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          (widget.joinOrStart == 'PLAY' && !_gameStarted)
              ? 'WAITING FOR HOST'
              : widget.joinOrStart,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}

// CUSTOM WIDGET FOR DETAILS
class DetailCard extends StatelessWidget {
  final IconData icon;
  final String mainDetail;
  final String subDetail;

  const DetailCard({
    super.key,
    required this.icon,
    required this.mainDetail,
    required this.subDetail,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: width * 0.9,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary, size: 36),

          SizedBox(width: width * 0.04),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  mainDetail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 6),

                Flexible(
                  child: Text(
                    subDetail,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EventDetail {
  final IconData icon;
  final String mainDetail;
  final String subDetail;

  EventDetail({
    required this.icon,
    required this.mainDetail,
    required this.subDetail,
  });
}
