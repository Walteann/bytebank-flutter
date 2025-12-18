import 'package:bytebank_flutter/routes.dart';
import 'package:bytebank_flutter/ui/themes/app-colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
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
                      SvgPicture.asset('assets/images/ilustration_signUp.svg'),
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
                      Text(_errorMessage, style: TextStyle(color: Colors.red),),
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
          ],
        ),
      ),
    );
  }

  void _register() async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      Navigator.pushReplacementNamed(context, Routes.signIn);
    } catch(e) {
      // COLOCAR AQUI SE DER ERROR
      setState(() {
        _errorMessage = e.toString();
      });
    }

  }

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
