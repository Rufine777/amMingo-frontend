import 'dart:io';
import 'package:dio/dio.dart';
import 'package:amingo/screens/preview_screen.dart';
import 'package:amingo/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FriendVerification extends StatefulWidget {
  final String letter;
  final int bingoId;
  final int row;
  final int col;

  const FriendVerification({
    super.key,
    required this.letter,
    required this.bingoId,
    required this.row,
    required this.col,
  });

  @override
  State<FriendVerification> createState() => _FriendVerificationState();
}

class _FriendVerificationState extends State<FriendVerification> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();

  File? image;
  final ImagePicker picker = ImagePicker();
  bool isSubmitting = false;
  String myCode = "...";

  @override
  void initState() {
    super.initState();
    _fetchMyCode();
  }

  Future<void> _fetchMyCode() async {
    try {
      String? storedCode = await AuthService.getUserCode();
      if (storedCode != null && mounted) {
        setState(() {
          myCode = storedCode;
        });
        return;
      }

      final response = await AuthService().getProfile(0);
      final data = response.data;
      if (mounted) {
        String fetchedCode = data['code'] ?? "000000";
        setState(() {
          myCode = fetchedCode;
        });
        if (fetchedCode != "000000") {
          await AuthService.saveUserCode(fetchedCode);
        }
      }
    } catch (e) {
      debugPrint("Error fetching user code: $e");
    }
  }

  Future<void> _openCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) return;

    if (!mounted) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreviewScreen(image: File(pickedFile.path)),
      ),
    );

    if (result == true && mounted) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitVerification() async {
    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please take a photo first")),
      );
      return;
    }
    if (nameController.text.isEmpty || codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in friend's name and code")),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      await AuthService().submitTile(
        bingoId: widget.bingoId,
        row: widget.row,
        col: widget.col,
        friendName: nameController.text.trim(),
        friendCode: codeController.text.trim(),
        fact: aboutController.text.trim(),
        image: image!,
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint("Error submitting verification: $e");
      String errorMessage = e.toString();
      if (e is DioException && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('detail')) {
          errorMessage = data['detail'].toString();
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Verification failed: $errorMessage")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final height = MediaQuery.of(context).size.height;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,

      appBar: AppBar(
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        title: Text(
          "Verify Friend",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // IMAGE SECTION
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: _openCamera,
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: height * 0.25,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: image != null
                              ? FileImage(image!)
                              : const AssetImage('assets/images/default2.png')
                                    as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: height * 0.25,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.black.withValues(alpha: 0.3),
                      ),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.8),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: colorScheme.primary,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Tap to take photo",
                              style: textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // FRIEND NAME SECTION
            Text(
              "Friend's Name",
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: nameController,
              cursorColor: colorScheme.primary,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                prefixIcon: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  child: Text(
                    "${widget.letter} |",
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                hintText: "Enter friend's name",
                hintStyle: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Helping you complete the '${widget.letter}' tile on your Bingoboard",
              style: textTheme.bodySmall?.copyWith(color: colorScheme.tertiary),
            ),

            const SizedBox(height: 24),

            // FRIEND CODE SECTION
            Text(
              "Friend's Code",
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: codeController,
              cursorColor: colorScheme.primary,
              style: TextStyle(color: colorScheme.onSurface),
              keyboardType: TextInputType.text,
              maxLength: 6,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: "e.g. A1B2C3",
                hintStyle: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                counterText: "",
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Ask your friend for their 6-character code to verify.",
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Check profile to see your code.",
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.tertiary,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            // ABOUT FRIEND SECTION
            Text(
              "About your friend",
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: aboutController,
              maxLength: 100,
              maxLines: 3,
              cursorColor: colorScheme.primary,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: "Share a quick vibe check or note about your friend",
                hintStyle: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 32), // Space before bottom button
          ],
        ),
      ),

      //BOTTOM VERIFY BUTTON
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: height * 0.09,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : _submitVerification,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      "VERIFY AND MARK TILE",
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.surface,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
