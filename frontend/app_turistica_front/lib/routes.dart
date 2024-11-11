import 'package:app_turistica_front/screens/destinations/destinations_screen.dart';
import 'package:app_turistica_front/screens/helpcenter/help_center.dart';
import 'package:app_turistica_front/screens/profile/profile_screen.dart';
import 'package:flutter/widgets.dart';

import 'screens/reservations/reservations_screen.dart';
import 'screens/details/details_screen.dart';
import '../screens/home/home_screen.dart';

import '../screens/register_screen.dart';

// We use name route
// All our routes will be available here
final Map<String, WidgetBuilder> routes = {
  RegisterScreen.routeName: (context) => const RegisterScreen(),
  HomeScreen.routeName: (context) => const HomeScreen(),
  DetailsScreen.routeName: (context) => const DetailsScreen(),
  ReservationScreen.routeName: (context) => const ReservationScreen(),
  ProfileScreen.routeName: (context) => const ProfileScreen(),
  DestinationsScreen.routeName: (context) => DestinationsScreen(),
  HelpCenter.routeName: (context) => HelpCenter(),
};