import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Pour SystemMouseCursors

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // ✅ fond clair moderne
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60),
        child: Row(
          children: [
            // ================= LEFT SIDE (TEXT) =================
            Expanded(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TITRE
                  const Text(
                    "EduFlow",
                    style: TextStyle(
                      color: Color(0xFF1E3A8A), // bleu profond
                      fontSize: 48,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const Spacer(flex: 2),

                  /// SLOGAN
                  const Text(
                    "Pour une éducation plus efficace.",
                    style: TextStyle(
                      color: Color(0xFF1E3A8A),
                      fontSize: 42,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// DESCRIPTION
                  const Text(
                    "EduFlow utilise l'IA pour générer automatiquement\nles programmes scolaires.",
                    style: TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 18,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// BOUTON COMMENCER
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) => setState(() => _isHovered = true),
                    onExit: (_) => setState(() => _isHovered = false),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/',
                          (route) => false,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        width: _isHovered ? 210 : 200,
                        height: _isHovered ? 60 : 55,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB), // bleu moderne
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB)
                                  .withOpacity(_isHovered ? 0.4 : 0.25),
                              blurRadius: _isHovered ? 20 : 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Commencer",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                "→",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),
                ],
              ),
            ),

            // ================= RIGHT SIDE (IMAGE) =================
            Expanded(
              flex: 5,
              child: Center(
                child: Image.asset(
                  "assets/images/acceuil.png",
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}