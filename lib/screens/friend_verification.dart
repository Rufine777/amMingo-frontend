import 'dart:io';
import 'package:amingo/screens/preview_screen.dart';
import 'package:amingo/screens/role_selection.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FriendVerification extends StatefulWidget {
  final String letter;

  const FriendVerification({super.key, required this.letter});

  @override
  State<FriendVerification> createState() => _FriendVerificationState();
}

class _FriendVerificationState extends State<FriendVerification> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();

  File? image;
  final ImagePicker picker = ImagePicker();

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
              keyboardType: TextInputType.number,
              maxLength: 3,
              decoration: InputDecoration(
                hintText: "e.g. 123",
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    "Ask your friend for their 3-digit code to verify.",
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.outline),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Your Code: ",
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "867",
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Roleselection()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
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
