import 'package:amingo/main.dart';
import 'package:flutter/material.dart';

class ProfileSection extends StatefulWidget {
  final String userName;
  final String userHandle;
  final String userPfp;
  final String email;
  final String bio;
  final int gamesPlayed;
  final int totalWins;
  final String actionType;

  final Function()? onActionPressed;

  const ProfileSection({
    super.key,
    required this.userName,
    required this.userHandle,
    required this.userPfp,
    required this.email,
    required this.bio,
    this.gamesPlayed = 0,
    this.totalWins = 0,
    this.actionType = 'SIGN OUT',
    this.onActionPressed,
  });

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  void _showComingSoonMessage(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Feature coming soon",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final height = MediaQuery.of(context).size.height;

    final List<ProfileDetailItem> details = [
      ProfileDetailItem(
        icon: Icons.email_outlined,
        mainDetail: "Email Address",
        subDetail: widget.email,
      ),
      ProfileDetailItem(
        icon: Icons.badge_outlined,
        mainDetail: "Bio",
        subDetail: widget.bio,
      ),
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface,

      // APP BAR
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Profile",
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showComingSoonMessage(context),
          ),
        ],
      ),

      // BODY
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            SizedBox(height: height * 0.02),

            // AVATAR
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.primary, width: 3),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        widget.userPfp,
                        width: height * 0.16,
                        height: height * 0.16,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.person, size: height * 0.16),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        size: 16,
                        color: colorScheme.surface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: height * 0.02),

            // USERNAME & HANDLE DISPLAY
            Column(
              children: [
                Text(
                  widget.userName,
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: height * 0.005),
                Text(
                  widget.userHandle.startsWith('@')
                      ? widget.userHandle
                      : '@${widget.userHandle}',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            SizedBox(height: height * 0.04),

            ...details.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: ProfileDetailCard(
                  icon: item.icon,
                  mainDetail: item.mainDetail,
                  subDetail: item.subDetail,
                ),
              );
            }),

            SizedBox(height: height * 0.05),
          ],
        ),
      ),

      // BOTTOM METRICS & ACTION BUTTON
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "PLAYER STATISTICS",
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: height * 0.01),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn(
                      "Games Played",
                      "${widget.gamesPlayed}",
                      textTheme,
                      colorScheme,
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.2,
                      ),
                    ),
                    _buildStatColumn(
                      "Total Wins",
                      "${widget.totalWins}",
                      textTheme,
                      colorScheme,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // DYNAMIC ACTION BUTTON
              SizedBox(
                height: height * 0.07,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      widget.onActionPressed ??
                      () {
                        if (widget.actionType == 'SIGN OUT') {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                            (route) => false,
                          );
                        } else {
                          _showComingSoonMessage(context);
                        }
                      },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.actionType,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.surface,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    String label,
    String value,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

// CUSTOM WIDGET FOR PROFILE DETAILS
class ProfileDetailCard extends StatelessWidget {
  final IconData icon;
  final String mainDetail;
  final String subDetail;

  const ProfileDetailCard({
    super.key,
    required this.icon,
    required this.mainDetail,
    required this.subDetail,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary, size: 36),
          const SizedBox(width: 16),
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
                Text(
                  subDetail,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.3,
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

class ProfileDetailItem {
  final IconData icon;
  final String mainDetail;
  final String subDetail;

  ProfileDetailItem({
    required this.icon,
    required this.mainDetail,
    required this.subDetail,
  });
}
