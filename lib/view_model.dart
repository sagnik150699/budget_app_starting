import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

import 'components.dart';

final viewModel =
    ChangeNotifierProvider.autoDispose<ViewModel>((ref) => ViewModel());

class ViewModel extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  bool isSignedIn = false;
  bool isObscure = true;
  var logger = Logger();
  final GoogleSignIn _google = GoogleSignIn.instance; // v 7+ singleton
  List expensesName = [];
  List expensesAmount = [];
  List incomesName = [];
  List incomesAmount = [];

  //Check if Signed In
  Future<void> isLoggedIn() async {
    await _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        isSignedIn = false;
      } else {
        isSignedIn = true;
      }
    });
    notifyListeners();
  }

  //--------------------------------------------------------------------
  ///  GOOGLE-SIGN-IN  – MOBILE  (Android / iOS)  – v 7 API
//--------------------------------------------------------------------
  Future<void> signInWithGoogleMobile(BuildContext context) async {
    final GoogleSignInAccount account = await _google
        .authenticate(scopeHint: const ['email']) // replaces signIn()
        .onError((error, stackTrace) {
      logger.d(error);
      DialogBox(
        context,
        error.toString().replaceAll(RegExp(r'\[.*?\]'), ''),
      );
      throw error!;
    });

    // authentication is now *synchronous* and returns only idToken
    final String? idToken = account.authentication.idToken;

    final credential = GoogleAuthProvider.credential(idToken: idToken);

    await _auth
        .signInWithCredential(credential)
        .then(
          (value) => logger.e('Signed in successfully $value'),
    )
        .onError((error, stackTrace) {
      DialogBox(context, error.toString().replaceAll(RegExp(r'\[.*?\]'), ''));
      logger.d(error);
    });
  }

}
