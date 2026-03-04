import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import '../view_model/login_view_model.dart';
import 'package:apk_web_eduflow/auth/view_model/login_view_model.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  //  CACHER LE MOT DE PASSE
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        inputField(
          icon: Icons.person,
          hint: "Nom utilisateur",
          controller: usernameController,
        ),

        const SizedBox(height: 15),

        inputField(
          icon: Icons.lock,
          hint: "Mot de passe",
          isPassword: true,
          controller: passwordController,
        ),

        const SizedBox(height: 20),

        SizedBox(
          //240*42
          width: 280,
          height: 42,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF000000),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            //Boutton se connecte deja backend
            onPressed: () async {
              final vm = context.read<LoginViewModel>();

              await vm.login(
                email: usernameController.text,   // ← ici le nom du paramètre
                password: passwordController.text,
                context: context,                 // ← indispensable pour Navigator
              );

              if (vm.loginResponse != null) {
                print("TOKEN: ${vm.loginResponse!.token}");
                print("ROLE: ${vm.loginResponse!.user.role}");
              }

              if (vm.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(vm.errorMessage!)),
                );
              }
            },


            child: const Text("SE CONNECTER"),
          ),
        ),

        const SizedBox(height: 10),

        SizedBox(
          width: 280, // MM largeur que le champ et bouton
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              "Mot de passe oublié ?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget inputField({
    required IconData icon,
    required String hint,
    bool isPassword = false,
    required TextEditingController controller,
  }) {
    return SizedBox(
      width: 280,
      child: TextField(
        controller: controller,

        // MOT DE PASSE AZO JERENA
        obscureText: isPassword ? _obscurePassword : false,

        // REBUILD REHEFA MISY SORATRA
        onChanged: (_) {
          setState(() {});
        },

        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white),

          // OEIL MIPOITRA REHEFA MISY TEXTE
          suffixIcon: isPassword && controller.text.isNotEmpty
              ? IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: Colors.white54,
              size: 19,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          )
              : null,

          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.white70),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
