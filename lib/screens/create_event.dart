import 'package:flutter/material.dart';
import 'event_details.dart';
import 'package:amingo/services/auth_service.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});
  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _timeLimitController = TextEditingController();
  final TextEditingController _participantsController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _eventNameController.dispose();
    _descriptionController.dispose();
    _timeLimitController.dispose();
    _participantsController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(centerTitle: true, title: Text("Create New Event")),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height * 0.02),
                Text(
                  "Event Name",
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: width * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: height * 0.01),
                TextField(
                  style: TextStyle(color: colorScheme.onSurface),
                  controller: _eventNameController,
                  cursorColor: colorScheme.primary,
                  decoration: InputDecoration(
                    hintText: "Enter event title",
                    hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    filled: true,
                    fillColor: colorScheme.surface,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.03),
                Text(
                  "Event Description",
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: width * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: height * 0.01),
                TextField(
                  style: TextStyle(color: colorScheme.onSurface),
                  cursorColor: colorScheme.primary,
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: "Describe the goal of the event",
                    hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: height * 0.03),

                Text(
                  "Location",
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: width * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: height * 0.01),
                TextField(
                  style: TextStyle(color: colorScheme.onSurface),
                  cursorColor: colorScheme.primary,
                  controller: _locationController,
                  decoration: InputDecoration(
                    hintText: "Enter the location of the event",
                    hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: height * 0.03),

                Text(
                  "Time Limit",
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: width * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: height * 0.01),
                TextField(
                  keyboardType: TextInputType.numberWithOptions(),
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: width * 0.04,
                  ),
                  controller: _timeLimitController,
                  cursorColor: Colors.yellow,
                  decoration: InputDecoration(
                    hintText: "Enter time in minutes",
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(
                      Icons.timer,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    filled: true,
                    fillColor: colorScheme.surface,
                    contentPadding: EdgeInsets.symmetric(vertical: 18),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.03),
                Text(
                  "Maximum Participants",
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: width * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: height * 0.01),
                TextField(
                  keyboardType: TextInputType.numberWithOptions(),
                  controller: _participantsController,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: width * 0.04,
                  ),
                  decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.grey),

                    hintText: "Enter the number of participants",
                    prefixIcon: Icon(
                      Icons.people,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    filled: true,
                    fillColor: colorScheme.surface,
                    contentPadding: EdgeInsets.symmetric(vertical: 18),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.07),
                SizedBox(
                  width: double.infinity,
                  height: height * 0.07,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_eventNameController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Event name is required"),
                          ),
                        );
                        return;
                      }
                      if (_timeLimitController.text.isEmpty ||
                          _participantsController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please fill in all required fields"),
                          ),
                        );
                        return;
                      }

                      try {
                        // Fetch host profile first
                        final profileResponse = await _authService.getProfile(
                          0,
                        );
                        final String hostName =
                            profileResponse.data["name"] ?? "Host";
                        final String? pfp =
                            profileResponse.data["profile_image"];
                        final String hostPfp = (pfp != null && pfp.isNotEmpty)
                            ? (pfp.startsWith('http')
                                  ? pfp
                                  : "${AuthService.baseUrl}${pfp.startsWith('/') ? '' : '/'}$pfp")
                            : "https://i.pravatar.cc/150?img=6";

                        final response = await _authService.createGame(
                          description:
                              "${_eventNameController.text}|${_descriptionController.text}",
                          location: _locationController.text,
                          duration: int.parse(_timeLimitController.text),
                        );

                        final String joinCode =
                            response.data["join_code"] ?? "";
                        final String qrImage = response.data["qr_img"] ?? "";

                        if (!context.mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventDetails(
                              eventName: _eventNameController.text,
                              hostName: hostName,
                              hostPfp: hostPfp,
                              joinOrStart: "START",
                              duration: int.parse(_timeLimitController.text),
                              description: _descriptionController.text,
                              joinCode: joinCode,
                              qrImage: qrImage,
                            ),
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Failed to create event: $e")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(12),
                      ),
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: width * 0.04,
                      ),
                    ),
                    child: Text(
                      "Create Event",
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
