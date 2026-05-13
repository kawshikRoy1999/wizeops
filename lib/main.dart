import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'presentation/auth/bloc/auth_bloc.dart';
import 'presentation/auth/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  final themeCubit = sl<ThemeCubit>();
  await themeCubit.loadSaved();
  runApp(WizeOpsApp(themeCubit: themeCubit));
}

class WizeOpsApp extends StatelessWidget {
  final ThemeCubit themeCubit;
  const WizeOpsApp({super.key, required this.themeCubit});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<ThemeCubit>.value(value: themeCubit),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        bloc: themeCubit,
        builder: (_, mode) => MaterialApp(
          title: 'WizeOps',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          home: const LoginScreen(),
        ),
      ),
    );
  }
}
