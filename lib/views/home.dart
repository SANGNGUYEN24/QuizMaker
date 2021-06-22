import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quiz_maker_app/helper/functions.dart';
import 'package:quiz_maker_app/services/auth.dart';
import 'package:quiz_maker_app/services/database.dart';
import 'package:quiz_maker_app/styles/images.dart';
import 'package:quiz_maker_app/views/create_quiz.dart';
import 'package:quiz_maker_app/views/play_quiz.dart';
import 'package:quiz_maker_app/views/signin.dart';
import 'package:quiz_maker_app/widgets/widgets.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DatabaseService databaseService = new DatabaseService();

  FirebaseAuth _user = FirebaseAuth.instance;
  final String _userID = AuthService().getUserID();

  confirmSignOut() {
    final snackBar = SnackBar(
      elevation: 2.0,
      behavior: SnackBarBehavior.floating,
      content: Text("Sign out?"),
      action: SnackBarAction(
        label: "Sign out",
        onPressed: () {
          _user.signOut();
          HelperFunctions.saveUserLoggedInDetail(isLoggedIn: false);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => SignIn()));
        },
      ),
    );

    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  Widget quizList() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("Quiz")
            .doc(_userID)
            .collection("User quiz data")
            .snapshots(),
        builder: (context, snapshot) {
          return (snapshot.data == null)
              ? Center(child: CircularProgressIndicator())
              : ((snapshot.data.docs.length <= 0)
                  ? Container(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(emptyImageQuizList, height: 100,),
                            SizedBox(height: 10,),
                            Text(
                              "Quizzes you add appear here",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 18.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        return QuizCard(
                          userID: snapshot.data.docs[index]["userId"],
                          imageUrl: snapshot.data.docs[index]["quizImageUrl"],
                          title: snapshot.data.docs[index]["quizTitle"],
                          description: snapshot.data.docs[index]
                              ["quizDescription"],
                          quizId: snapshot.data.docs[index]["quizId"],
                        );
                      },
                    ));
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: appBar(context),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        brightness: Brightness.light,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              confirmSignOut();
            },
            icon: Icon(
              Icons.logout,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: quizList(),
      floatingActionButton: FloatingActionButton(
        tooltip: "Add a new quiz",
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateQuiz()),
          );
        },
      ),
    );
  }
}

class QuizCard extends StatelessWidget {
  //add uid for each quiz
  final String userID;
  final String imageUrl;
  final String title;
  final String description;
  final String quizId;

  QuizCard(
      {@required this.userID,
      @required this.imageUrl,
      @required this.title,
      @required this.description,
      @required this.quizId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PlayQuiz(
                      quizId: quizId,
                    )));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        height: 150,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(9.0),
              child: Image.network(
                imageUrl,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9.0),
                color: Colors.black26,
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Text(
                    description,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
