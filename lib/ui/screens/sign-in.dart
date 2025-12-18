import 'package:bytebank_flutter/routes.dart';
import 'package:bytebank_flutter/ui/themes/app-colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _emailController =
      TextEditingController();
  final TextEditingController
  _passwordController = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  
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
                      SvgPicture.asset('assets/images/ilustration_signIn.svg'),
                      Text(
                        'Login',
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
                                    AppColors.success,
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
                              onPressed: _isLoading ? null : _signIn,
                              child: _isLoading
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.neutral100,
                                      ),
                                    )
                                  : Text(
                                      "Entrar",
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
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
                            Routes.signUp,
                          );
                        },
                        child: Text("Abra uma conta"),
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

  void _signIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        Routes.home,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao fazer login: ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  InputDecoration inputDecorationCustom() {
    return InputDecoration(
      fillColor: AppColors.neutral100,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 12.0,
      ),
      floatingLabelBehavior:
          FloatingLabelBehavior.always,
    );
  }
}
