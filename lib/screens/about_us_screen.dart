import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  final List<Map<String, String>> developers = const [
    {
      "name": "Arlif",
      "position": "Developer",
      "instagram": "arlifzs2006",
      "imageUrl": "assets/obj/ArlifProfile.jpg", // ✅ รูปในเครื่อง
    },
    {
      "name": "Apirak",
      "position": "Developer",
      "instagram": "g0dgam3inwza",
      "imageUrl":
          "https://i.pinimg.com/736x/07/1f/95/071f95fa318a91884b1a23c316c2833e.jpg", // ✅ รูปจากเน็ต
    },
    {
      "name": "Thanaphat",
      "position": "Server Admin",
      "instagram": "Nan",
      "imageUrl":
          "https://i.pinimg.com/736x/07/1f/95/071f95fa318a91884b1a23c316c2833e.jpg",
    },
    {
      "name": "Wish",
      "position": "Developer",
      "instagram": "Nan",
      "imageUrl":
          "https://i.pinimg.com/736x/07/1f/95/071f95fa318a91884b1a23c316c2833e.jpg",
    },
    {
      "name": "Chanasorn",
      "position": "Developer",
      "instagram": "Nan",
      "imageUrl": "assets/obj/SugusProfile.jpg", // ✅ รูปในเครื่อง
    },
    {
      "name": "Saksit",
      "position": "Developer",
      "instagram": "Nan",
      "imageUrl":
          "https://i.pinimg.com/736x/07/1f/95/071f95fa318a91884b1a23c316c2833e.jpg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? Colors.black54 : Colors.white70,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            color: isDark ? Colors.white : Colors.black,
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ================= HEADER =================
            Stack(
              children: [
                Container(
                  height: 350,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      // ✅ 1. แก้ตรงนี้: ใช้ AssetImage สำหรับรูปปกในเครื่อง
                      image: AssetImage('assets/obj/aboutbackground.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 350,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        isDark ? Colors.black54 : Colors.white24,
                        isDark
                            ? theme.scaffoldBackgroundColor
                            : theme.scaffoldBackgroundColor,
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        "TEAM",
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                          color: isDark ? Colors.white : Colors.black87,
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.black26,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "ทีมผู้พัฒนาและผู้อยู่เบื้องหลัง NotStackApp 💻",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ================= CONTENT =================
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    "ผู้พัฒนา",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: developers.length,
                    itemBuilder: (context, index) {
                      final dev = developers[index];
                      return _buildDevCard(context, dev);
                    },
                  ),

                  const SizedBox(height: 40),

                  // ส่วน Footer
                  FutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    builder: (context, snapshot) {
                      String versionText = "";
                      if (snapshot.hasData) {
                        versionText =
                            " v${snapshot.data!.version} build ${snapshot.data!.buildNumber}";
                      }

                      return Text(
                        "© 2025-2026 NotStackApp$versionText. All rights reserved.",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevCard(BuildContext context, Map<String, String> dev) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final imageUrl = dev['imageUrl']!;

    // ✅ 2. แก้ Logic การเลือก ImageProvider ให้ชัวร์ขึ้น
    ImageProvider imageProvider;
    if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
      imageProvider = NetworkImage(imageUrl);
    } else {
      // ตัด 'file:///' ออกถ้ามี (เผื่อ Error เก่า)
      final assetPath = imageUrl.replaceAll('file:///', '');
      imageProvider = AssetImage(assetPath);
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.primaryColor.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundImage: imageProvider,
              backgroundColor: Colors.grey.shade300,
              // กัน Error ถ้ารูปโหลดไม่ได้
              onBackgroundImageError: (exception, stackTrace) {
                debugPrint("Image load failed: $imageUrl");
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(
            dev['name']!,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              dev['position']!,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "IG: ${dev['instagram']}",
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.white70 : Colors.black54,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
