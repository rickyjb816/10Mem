import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Models/User.dart';
import 'Pages/Auth/Welcome.dart';
import 'Pages/Home/Home.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserMini>(context);

    return user == null ? Welcome() : Home();
  }
}
