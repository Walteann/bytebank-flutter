import 'package:bytebank_flutter/routes.dart';
import 'package:bytebank_flutter/ui/themes/app-colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _emailController =
      TextEditingController();
  final TextEditingController
  _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign up")),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.neutral100,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: Color.fromRGBO(
                255,
                255,
                255,
                0.3,
              ),
              borderRadius: BorderRadius.circular(
                15,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [
                  Text(
                    'Preencha os campos abaixo para criar sua conta corrente!',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      Text(
                        'E-mail',
                        style: GoogleFonts.inter(
                          fontSize: 18.0,
                          fontWeight:
                              FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  TextField(
                    controller: _emailController,
                    decoration:
                        inputDecorationCustom(),
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      Text(
                        'Senha',
                        style: GoogleFonts.inter(
                          fontSize: 18.0,
                          fontWeight:
                              FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  TextField(
                    controller:
                        _passwordController,
                    decoration:
                        inputDecorationCustom(),
                    obscureText: true,
                  ),
                  SizedBox(height: 24.0),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor:
                                AppColors
                                    .neutral100,
                            backgroundColor:
                                AppColors.accent,
                            padding:
                                EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                    8,
                                  ),
                            ),
                          ),
                          onPressed: _register,
                          child: Text(
                            "Criar Conta",
                            style:
                                GoogleFonts.inter(
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                  fontSize: 16,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.0),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        Routes.signIn,
                      );
                    },
                    child: Text("Já tenho conta"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _register() {}

  InputDecoration inputDecorationCustom() {
    return InputDecoration(
      fillColor: AppColors.neutral100,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          8.0,
        ), // Bordas arredondadas
      ),
      contentPadding: EdgeInsets.symmetric(
        // vertical: 20.0,
        horizontal: 12.0,
      ),
      floatingLabelBehavior:
          FloatingLabelBehavior.always,
    );
  }
}
