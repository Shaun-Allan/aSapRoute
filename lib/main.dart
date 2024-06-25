import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route/bloc/bottom_nav_cubit.dart';
import 'package:route/inheritance/coordinateState.dart';
import 'firebase_options.dart';

import 'package:flutter/material.dart';
import 'package:route/pages/home.dart';
import 'package:route/pages/login.dart';

import 'package:route/theme/theme_constraints.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CoordinateState(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark
        ),
        title: "aSapRoute",
        home: BlocProvider(
          create: (context) => BottomNavCubit(),
          child: Login(),
        ),
      ),
    );
  }
}

