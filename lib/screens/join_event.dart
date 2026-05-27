import 'package:amingo/screens/event_details.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class JoinEventScreen extends StatefulWidget {
  const JoinEventScreen({super.key});
  @override
  State<JoinEventScreen> createState() => _JoinEventScreenState();
}

class _JoinEventScreenState extends State<JoinEventScreen>
    with SingleTickerProviderStateMixin {
  MobileScannerController cameraController = MobileScannerController();
  bool isScanned = false;
  String qrResult = "";
  String codeInput = "";
  late AnimationController animationController;
  late Animation<double> animation;
  final TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    animation = Tween<double>(begin: 0, end: 1).animate(animationController);
  }

  @override
  void dispose() {
    animationController.dispose();
    cameraController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _handleJoinEvent() {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please enter a 6-digit code"),
          backgroundColor: Colors.red.shade400,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Code must be exactly 6 digits"),
          backgroundColor: Colors.orange.shade400,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Successfully joined the event!"),
        backgroundColor: Colors.green.shade400,
        duration: const Duration(seconds: 3),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetails(
          eventName: 'amFOSS Praveshan 2026',
          hostName: 'amFOSS',
          hostPfp: 'https://i.pravatar.cc/150?img=6',
          joinOrStart: 'PLAY',
          duration: 160,
          description:
              'The entry to amfoss event, join now. contribute to open source',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Join an Event",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: colorScheme.outline.withValues(alpha: 0.2),
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withValues(alpha: 0.1),
                        colorScheme.primary.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.event,
                          color: colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Join Event",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Scan QR or enter code",
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: height * 0.03),

                // QR Scanner Section
                Text(
                  "Scan QR Code",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),

                SizedBox(height: 12),

                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: height * 0.35,
                        width: double.infinity,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: MobileScanner(
                                controller: cameraController,
                                onDetect: (BarcodeCapture capture) async {
                                  if (isScanned) return;
                                  isScanned = true;
                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );
                                  await cameraController.stop();
                                  List<Barcode> barcodes = capture.barcodes;
                                  if (barcodes.isNotEmpty &&
                                      barcodes.first.rawValue != null) {
                                    setState(() {
                                      qrResult = barcodes.first.rawValue!;
                                    });
                                    final uri = Uri.tryParse(qrResult);
                                    if (uri != null &&
                                        await canLaunchUrl(uri)) {
                                      await launchUrl(uri);
                                      isScanned = false;
                                    } else {
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            "Invalid QR Code",
                                          ),
                                          backgroundColor: Colors.red.shade400,
                                        ),
                                      );
                                    }
                                  }
                                  await Future.delayed(
                                    const Duration(seconds: 2),
                                  );
                                  isScanned = false;
                                  await cameraController.start();
                                },
                              ),
                            ),
                            // Animated scanning line
                            AnimatedBuilder(
                              animation: animation,
                              builder: (context, child) {
                                return Positioned(
                                  top: animation.value * ((height * 0.35) - 6),
                                  left: 2,
                                  right: 3,
                                  child: Container(
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: Colors.yellow,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.yellow,
                                          blurRadius: 20,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Corner indicators
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Container(
                                width: width * 0.15,
                                height: height * 0.08,
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.yellow,
                                      width: 3,
                                    ),
                                    left: BorderSide(
                                      color: Colors.yellow,
                                      width: 3,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                width: width * 0.15,
                                height: height * 0.08,
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: Colors.yellow,
                                      width: 3,
                                    ),
                                    right: BorderSide(
                                      color: Colors.yellow,
                                      width: 3,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: width * 0.15,
                                height: height * 0.08,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.yellow,
                                      width: 3,
                                    ),
                                    right: BorderSide(
                                      color: Colors.yellow,
                                      width: 3,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              child: Container(
                                width: width * 0.15,
                                height: height * 0.08,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.yellow,
                                      width: 3,
                                    ),
                                    left: BorderSide(
                                      color: Colors.yellow,
                                      width: 3,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: () => cameraController.toggleTorch(),
                              icon: ValueListenableBuilder(
                                valueListenable: cameraController,
                                builder: (context, value, child) {
                                  switch (value.torchState) {
                                    case TorchState.off:
                                      return Icon(
                                        Icons.flash_off,
                                        color: colorScheme.onSurfaceVariant,
                                      );
                                    case TorchState.on:
                                      return Icon(
                                        Icons.flash_on,
                                        color: colorScheme.primary,
                                      );
                                    case TorchState.auto:
                                      return Icon(
                                        Icons.flash_auto,
                                        color: colorScheme.primary,
                                      );
                                    case TorchState.unavailable:
                                      return Icon(
                                        Icons.flash_off,
                                        color: colorScheme.onSurfaceVariant,
                                      );
                                  }
                                },
                              ),
                              tooltip: "Toggle Flashlight",
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: height * 0.03),

                // Divider with OR
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "OR",
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: height * 0.03),

                // Code Input Section
                Text(
                  "Enter 6-Digit Code",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),

                SizedBox(height: 12),

                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.05),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _codeController,
                        onChanged: (value) {
                          setState(() {
                            codeInput = value;
                          });
                        },
                        keyboardType: const TextInputType.numberWithOptions(),
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          letterSpacing: 8,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        cursorColor: colorScheme.primary,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: "000000",
                          hintStyle: TextStyle(
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.5,
                            ),
                            letterSpacing: 8,
                            fontSize: 28,
                          ),
                          filled: true,
                          fillColor: colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.outline.withValues(alpha: 0.2),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.outline.withValues(alpha: 0.2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          counterText: "",
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 12,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            codeInput.length == 6
                                ? Icons.check_circle
                                : Icons.info,
                            color: codeInput.length == 6
                                ? Colors.green
                                : colorScheme.onSurfaceVariant,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            codeInput.length == 6
                                ? "Code is valid!"
                                : "Enter 6 digits",
                            style: TextStyle(
                              fontSize: 12,
                              color: codeInput.length == 6
                                  ? Colors.green
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: height * 0.04),

                // Join Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _handleJoinEvent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Join Event",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: height * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
