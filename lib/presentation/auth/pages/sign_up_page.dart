import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:todo_list/core/constants/app_colors.dart';
import 'package:todo_list/core/constants/app_strings.dart';
import 'package:todo_list/core/constants/app_styles.dart';
import 'package:todo_list/presentation/auth/bloc/auth_bloc.dart';
import 'package:todo_list/presentation/auth/pages/sign_in_page.dart';
import 'package:todo_list/presentation/home/home_page.dart';
import 'package:todo_list/presentation/common/widgets/app_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onFieldsChanged);
    _passwordController.addListener(_onFieldsChanged);
    _usernameController.addListener(_onFieldsChanged);
  }

  void _onFieldsChanged() => setState(() {});

  bool get _allFieldsFilled =>
      _emailController.text.trim().isNotEmpty &&
      _passwordController.text.isNotEmpty &&
      _usernameController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _emailController.removeListener(_onFieldsChanged);
    _passwordController.removeListener(_onFieldsChanged);
    _usernameController.removeListener(_onFieldsChanged);
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _signUp() {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.pleaseFillAllFields)),
      );
      return;
    }
    context.read<AuthBloc>().add(
      AuthSignUpRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(size.width / 16),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppStrings.signup, style: AppStyles.authTitle),
                  SizedBox(height: size.height / 18),
                  AppTextField(
                    controller: _usernameController,
                    hintText: AppStrings.hintUsername,
                  ),
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
                        ).showSnackBar(SnackBar(content: Text(state.message)));
                      }
                      if (state is Authenticated) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => HomePage(
                              key: ValueKey('home_${state.user.uid}'),
                              user: state.user,
                            ),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      final isActive = _allFieldsFilled && !isLoading;
                      return SizedBox(
                        width: size.width,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonActive,
                            disabledBackgroundColor: AppColors.buttonDisabled,
                          ),
                          onPressed: isActive ? _signUp : null,
                          child: isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.loadingIndicator,
                                  ),
                                )
                              : const Text(
                                  AppStrings.signup,
                                  style: AppStyles.buttonText,
                                ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: size.height / 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(AppStrings.alreadyHaveAccount),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SigninScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          AppStrings.signin,
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
