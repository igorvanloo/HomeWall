// Flutter
import 'package:flutter/material.dart';

// Others
import 'package:provider/provider.dart';

// Files
import 'package:home_wall/helper/authentication_service.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainPage();
}

class _MainPage extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Page 0'),
        ElevatedButton(
            onPressed: () {
              context.read<AuthenticationService>().signOut();
            },
            child: const Text('Sign Out'))
      ],
    );
  }
}
