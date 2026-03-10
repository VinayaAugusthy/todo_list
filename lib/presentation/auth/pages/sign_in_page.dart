import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:todo_list/core/constants/app_colors.dart';
import 'package:todo_list/core/constants/app_strings.dart';
import 'package:todo_list/core/constants/app_styles.dart';
import 'package:todo_list/core/extensions/build_context_x.dart';
import 'package:todo_list/presentation/auth/bloc/auth_bloc.dart';
import 'package:todo_list/presentation/auth/pages/sign_up_page.dart';
import 'package:todo_list/presentation/common/widgets/app_text_field.dart';
import 'package:todo_list/presentation/common/widgets/app_snackbar.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onFieldsChanged);
    _passwordController.addListener(_onFieldsChanged);
  }

  void _onFieldsChanged() => setState(() {});

  bool get _allFieldsFilled =>
      _emailController.text.trim().isNotEmpty &&
      _passwordController.text.isNotEmpty;

  @override
  void dispose() {
    _emailController.removeListener(_onFieldsChanged);
    _passwordController.removeListener(_onFieldsChanged);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signInWithEmail() {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(AppSnackBar.error(AppStrings.pleaseFillAllFields));
      return;
    }
    context.read<AuthBloc>().add(
      AuthSignInRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  void _signInWithGoogle() {
    context.read<AuthBloc>().add(const AuthGoogleSignInRequested());
  }

  @override
  Widget build(BuildContext context) {
    final size = context.screenSize;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(size.width / 16),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppStrings.signin, style: AppStyles.authTitle),
                  SizedBox(height: size.height / 18),

                  AppTextField(
                    controller: _emailController,
                    hintText: AppStrings.hintEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: size.height / 18),
                  AppTextField(
                    controller: _passwordController,
                    hintText: AppStrings.hintPassword,
                    obscureText: true,
                  ),
                  SizedBox(height: size.height / 18),
                  BlocConsumer<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is AuthError) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(AppSnackBar.error(state.message));
                      }
                    },
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      final isActive = _allFieldsFilled && !isLoading;
                      return SizedBox(
                        width: size.width,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor: AppColors.primaryLight,
                          ),
                          onPressed: isActive ? _signInWithEmail : null,
                          child: isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primaryDark,
                                  ),
                                )
                              : const Text(
                                  AppStrings.signIn,
                                  style: AppStyles.buttonText,
                                ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: size.height / 24),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return SizedBox(
                        width: size.width,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(
                              color: isLoading
                                  ? AppColors.primaryLight
                                  : AppColors.primary,
                              width: 2,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: isLoading ? null : _signInWithGoogle,
                          icon: SizedBox(
                            width: 24,
                            height: 24,
                            child: Image.asset(
                              AppStrings.googleLogoAsset,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => Image.asset(
                                AppStrings.googleLogoAsset,
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) =>
                                    const Icon(Icons.g_mobiledata, size: 24),
                              ),
                            ),
                          ),
                          label: const Text(AppStrings.signInWithGoogle),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: size.height / 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(AppStrings.dontHaveAccount),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          AppStrings.signup,
                          style: AppStyles.linkText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
