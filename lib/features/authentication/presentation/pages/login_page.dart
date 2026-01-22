import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo or App Name
              Icon(
                Icons.psychology, 
                size: 80, 
                color: Theme.of(context).colorScheme.primary
              ),
              const SizedBox(height: 16),
              Text(
                'Behavior Tracker',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 48),

              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                builder: (context, state) {
                   if (state is AuthLoading) {
                     return const CircularProgressIndicator();
                   }
                   
                   return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: FormBuilder(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              _isLogin ? 'Bienvenido' : 'Crear Cuenta',
                              style: Theme.of(context).textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            FormBuilderTextField(
                              name: 'email',
                              decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(errorText: 'Requerido'),
                                FormBuilderValidators.email(errorText: 'Email inválido'),
                              ]),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),
                            FormBuilderTextField(
                              name: 'password',
                              decoration: const InputDecoration(labelText: 'Contraseña'),
                              obscureText: true,
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(errorText: 'Requerido'),
                                FormBuilderValidators.minLength(6, errorText: 'Mínimo 6 caracteres'),
                              ]),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState?.saveAndValidate() ?? false) {
                                  final values = _formKey.currentState!.value;
                                  if (_isLogin) {
                                    context.read<AuthBloc>().add(SignInEvent(
                                      values['email'], 
                                      values['password']
                                    ));
                                  } else {
                                    context.read<AuthBloc>().add(SignUpEvent(
                                      values['email'], 
                                      values['password']
                                    ));
                                  }
                                }
                              },
                              child: Text(_isLogin ? 'Iniciar Sesión' : 'Registrarse'),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                  _formKey.currentState?.reset();
                                });
                              },
                              child: Text(_isLogin 
                                ? '¿Necesitas cuenta? Regístrate' 
                                : '¿Ya tienes cuenta? Inicia Sesión'
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
