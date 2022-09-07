import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'chat_reg_screen.dart';
import '../components/snackbar_body.dart';
import '../api/auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String phone = "88619121";
  String password = "Daam_1234";
  bool loading = false;

  void handleLogin() {
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(snackBarBody('Must insert phone!', Colors.greenAccent));
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(snackBarBody('Must insert password!', Colors.yellowAccent));
      return;
    }

    setState(() => loading = true);

    login(phone, password).then((value) {
      setState(() => loading = false);
      Hive.box('testBox').put('token', {
        "access_token": value?['access_token'],
        "refresh_token": value?["refresh_token"]
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(snackBarBody('Successfully logged in.', Colors.greenAccent));
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => RegScreen()));
    }).catchError((err) {
      debugPrint(err.toString());
      setState(() => loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(snackBarBody(err.message, Colors.redAccent));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(children: [
            const Text(
              "Login Screen",
              style: TextStyle(color: Colors.black, fontSize: 40),
            ),
            Container(
              padding: const EdgeInsets.only(top: 40),
              width: MediaQuery.of(context).size.width - 100,
              child: TextFormField(
                initialValue: phone,
                onChanged: (value) => setState(() => phone = value),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Phone number',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 20),
              width: MediaQuery.of(context).size.width - 100,
              child: TextFormField(
                initialValue: password,
                onChanged: (value) => setState(() => password = value),
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 20),
              width: MediaQuery.of(context).size.width - 100,
              child: TextButton(
                child: loading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Login",
                        style: TextStyle(color: Colors.white),
                      ),
                onPressed: () => {if (!loading) handleLogin()},
                style: TextButton.styleFrom(backgroundColor: Colors.blue),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
