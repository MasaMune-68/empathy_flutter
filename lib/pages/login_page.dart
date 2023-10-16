import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:empathy_flutter/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:empathy_flutter/firebase.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';

// ログイン画面用Widget
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String infoText = ''; // メッセージ表示用
  String email = ''; // 入力したメールアドレス・パスワード
  String password = '';

  @override
  Widget build(BuildContext context) {
    final bottomSpace = MediaQuery.of(context).viewInsets.bottom;
    return GestureDetector(
      // キーボード以外をタップすると、キーボードが閉じる
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
          child: SingleChildScrollView(
            reverse: true,
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.only(right: 70, left: 70, bottom: 10),
                  child: Image.asset('images/welcome.png'),
                ),
                const Text('アナタノミカタへようこそ！'),
                const Gap(25),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'メールアドレス'),
                  onChanged: (String value) {
                    setState(() {
                      email = value;
                    });
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'パスワード'),
                  obscureText: true,
                  onChanged: (String value) {
                    setState(() {
                      password = value;
                    });
                  },
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Text(infoText),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 81, 161, 101),
                    ),
                    child: const Text('ユーザー登録'),
                    onPressed: () async {
                      try {
                        // メール/パスワードでユーザー登録
                        final FirebaseAuth auth = FirebaseAuth.instance;
                        final result =
                            await auth.createUserWithEmailAndPassword(
                          email: email,
                          password: password,
                        );
                        // ユーザー登録に成功した場合、登録画面に遷移
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    SignUpPage(result.user!)));
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'email-already-in-use') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor:
                                  Color.fromARGB(255, 81, 161, 101),
                              content: Text('指定したメールアドレスは登録済みです'),
                            ),
                          );
                          print('指定したメールアドレスは登録済みです');
                          // print('指定したメールアドレスは登録済みです');
                        } else if (e.code == 'invalid-email') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor:
                                  Color.fromARGB(255, 81, 161, 101),
                              content: Text('メールアドレスのフォーマットが正しくありません'),
                            ),
                          );
                          print('メールアドレスのフォーマットが正しくありません');
                        } else if (e.code == 'operation-not-allowed') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor:
                                  Color.fromARGB(255, 81, 161, 101),
                              content: Text('指定したメールアドレス・パスワードは現在使用できません'),
                            ),
                          );
                          print('指定したメールアドレス・パスワードは現在使用できません');
                        } else if (e.code == 'weak-password') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor:
                                  Color.fromARGB(255, 81, 161, 101),
                              content: Text('パスワードは６文字以上にしてください'),
                            ),
                          );
                          print('パスワードは６文字以上にしてください');
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                    width: double.infinity,
                    // ログイン登録ボタン
                    child: OutlinedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            const Color.fromARGB(255, 81, 161, 101),
                        backgroundColor: Colors.white, // foreground
                      ),
                      child: const Text('ログイン'),
                      onPressed: () async {
                        try {
                          // メール/パスワードでログイン
                          final FirebaseAuth auth = FirebaseAuth.instance;
                          final result = await auth.signInWithEmailAndPassword(
                            email: email,
                            password: password,
                          );
                          // ログインに成功した場合
                          // チャット画面に遷移＋ログイン画面を破棄
                          await Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) {
                              return const HomePage();
                            }),
                          );
                        } on FirebaseAuthException catch (e) {
                          // ログインに失敗した場合
                          if (e.code == 'invalid-email') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor:
                                    Color.fromARGB(255, 81, 161, 101),
                                content: Text(''),
                              ),
                            );
                            print('メールアドレスのフォーマットが正しくありません');
                          } else if (e.code == 'user-disabled') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor:
                                    Color.fromARGB(255, 81, 161, 101),
                                content: Text('現在指定したメールアドレスは使用できません'),
                              ),
                            );
                            print('現在指定したメールアドレスは使用できません');
                          } else if (e.code == 'user-not-found') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor:
                                    Color.fromARGB(255, 81, 161, 101),
                                content: Text('指定したメールアドレスは登録されていません'),
                              ),
                            );
                            print('指定したメールアドレスは登録されていません');
                          } else if (e.code == 'wrong-password') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor:
                                    Color.fromARGB(255, 81, 161, 101),
                                content: Text('パスワードが間違っています'),
                              ),
                            );
                            print('パスワードが間違っています');
                          }
                        }
                      },
                    )),
                Padding(padding: EdgeInsets.only(bottom: bottomSpace)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  SignUpPage(this.user);
  final User user;

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  bool _existsUserName = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _userNameController.dispose();
    super.dispose();
  }

  bool _isCheck = false;

  void _handleCheckbox(bool? isCheck) {
    setState(() {
      _isCheck = isCheck!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ユーザー登録',
              style: TextStyle(
                color: Colors.black,
                fontSize: 17,
              )),
          backgroundColor: Colors.grey[50],
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: Text("${widget.user.email} 様"),
                      ),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        controller: _userNameController,
                        decoration: const InputDecoration(
                          hintText: 'ユーザー名を入力してください',
                          hintStyle: TextStyle(fontSize: 13),
                        ),
                        maxLength: 15,
                        textInputAction: TextInputAction.done,
                        onChanged: (value) async {
                          _existsUserName =
                              await Firestore.existsUserName(value);
                          _formKey.currentState!.validate();
                        },
                        validator: (String? value) {
                          if (_existsUserName) {
                            return 'ⓘ そのユーザー名は使用されています';
                          } else if (value!.isEmpty) {
                            return 'ⓘ ユーザー名を入力してください';
                          } else {
                            return null;
                          }
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.all(3),
                        child: const Text("※ 性別の判断や個人の特定がされないなユーザー名を使用してください。",
                            style: TextStyle(
                              fontSize: 12,
                            )),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Checkbox(
                                activeColor:
                                    const Color.fromARGB(255, 81, 161, 101),
                                value: _isCheck,
                                onChanged: _handleCheckbox,
                              ),
                              const Text("私は現在大学生です🎓"),
                            ],
                          )),
                      Container(
                          padding: const EdgeInsets.all(0),
                          child: RichText(
                              text: TextSpan(children: [
                            const TextSpan(
                                text: 'アナタノミカタの',
                                style: TextStyle(color: Colors.black)),
                            TextSpan(
                                text: 'プライバシーポリシー',
                                style: const TextStyle(color: Colors.blue),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    _openprivacy(); // タップ時
                                  }),
                            const TextSpan(
                                text: 'に同意します。',
                                style: TextStyle(color: Colors.black))
                          ]))
                          // child: const Text("アナタノミカタのプライバシーポリシーに同意します。"),
                          ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: _isCheck
                                ? Colors.white
                                : const Color.fromARGB(255, 81, 161, 101),
                            backgroundColor: _isCheck
                                ? const Color.fromARGB(255, 81, 161, 101)
                                : Colors.white, // foreground
                          ),
                          onPressed: _isCheck
                              ? () async {
                                  final auth = FirebaseAuth.instance;
                                  final userNameText = _userNameController.text;
                                  final email = widget.user.email;
                                  final userId =
                                      auth.currentUser?.uid.toString();
                                  if (_formKey.currentState!.validate()) {
                                    if (!_existsUserName) {
                                      await Firestore.signUp(
                                          _userNameController.text, email);
                                      await Firestore.registerUid(userId, email,
                                          _userNameController.text);
                                      await Navigator.of(context)
                                          .pushReplacement(
                                        MaterialPageRoute(builder: (context) {
                                          return RegisterWorriesPage(
                                              userNameText);
                                        }),
                                      );
                                    }
                                  }
                                }
                              : null,
                          child: const Text('登録'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openprivacy() async {
    const url =
        'https://adorable-volcano-5e9.notion.site/d16800abf38b42088203f5e6f998269a'; //←ここに表示させたいURLを入力する
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: true,
        forceWebView: true,
      );
    } else {
      throw 'このURLにはアクセスできません';
    }
  }
}

class RegisterWorriesPage extends StatefulWidget {
  RegisterWorriesPage(this.userNameText);
  final String userNameText;

  @override
  _RegisterWorriesPage createState() => _RegisterWorriesPage();
}

class _RegisterWorriesPage extends State<RegisterWorriesPage> {
  final TextEditingController _worriesExplanationController =
      TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _worriesExplanationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Firestore.registerUserDoc(widget.userNameText);
    // reverseがtrueでも、画面が一番上に移動する
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  bool _school01 = false;
  bool _school02 = false;
  bool _school03 = false;
  bool _school04 = false;
  bool _school05 = false;
  bool _school06 = false;
  bool _school07 = false;
  bool _school08 = false;
  bool _relationship01 = false;
  bool _relationship02 = false;
  bool _relationship03 = false;
  bool _relationship04 = false;
  bool _relationship05 = false;
  bool _relationship06 = false;
  bool _life01 = false;
  bool _life02 = false;
  bool _life03 = false;
  bool _health01 = false;
  bool _health02 = false;
  bool _health03 = false;
  var count = 0;

  @override
  Widget build(BuildContext context) {
    final bottomSpace = MediaQuery.of(context).viewInsets.bottom;
    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            iconTheme: const IconThemeData(color: Colors.black),
            title: const Text('悩みを登録する',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  // fontWeight: FontWeight.bold
                )),
            elevation: 0.0,
            shape: const Border(
                bottom: BorderSide(color: Colors.grey, width: 0.2)),
            backgroundColor: Colors.grey[50],
          ),
          body: SingleChildScrollView(
            controller: _scrollController,
            reverse: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Padding(
                    padding: EdgeInsets.only(
                        top: 20, bottom: 0, left: 20, right: 20),
                    child: Text('1. 当てはまる悩みにチェックをしてください。',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          // fontWeight: FontWeight.bold
                        ))),
                const Padding(
                    padding:
                        EdgeInsets.only(top: 5, bottom: 5, left: 20, right: 20),
                    child: Text('※ 登録できる悩みは4つまでです。',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ))),
                const Padding(
                    padding: EdgeInsets.only(
                        top: 10, bottom: 10, left: 20, right: 20),
                    child: Text('🎓 学業に関する悩み',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          // fontWeight: FontWeight.bold
                        ))),
                const Divider(
                  color: Colors.grey,
                  thickness: 0.5,
                  height: 0,
                  indent: 15,
                  endIndent: 15,
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                ),
                CheckboxListTile(
                  activeColor: const Color.fromARGB(255, 81, 161, 101),
                  value: _school01,
                  title: const Text('試験・レポート・研究等が上手く進まず、進級・卒業できるか心配である。',
                      style: TextStyle(
                        fontSize: 13,
                      )),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool? value) async {
                    setState(() {
                      _school01 = value!;
                    });
                    if (_school01 == true) {
                      countUp();
                      await FirebaseFirestore.instance
                          .collection('学業')
                          .doc('進級・卒業')
                          .update({
                        "users": FieldValue.arrayUnion([widget.userNameText])
                      });
                      await Firestore.registerUserConfirmWorries(
                          widget.userNameText,
                          '🎓学業に関する悩み: 試験・レポート・研究等が上手く進まず、進級・卒業できるか心配である。');
                      if (count == 5) {
                        await FirebaseFirestore.instance
                            .collection('学業')
                            .doc('進級・卒業')
                            .update({
                          "users": FieldValue.arrayRemove([widget.userNameText])
                        });
                        await Firestore.deleteUserConfirmWorries(
                            widget.userNameText,
                            '🎓学業に関する悩み: 試験・レポート・研究等が上手く進まず、進級・卒業できるか心配である。');
                        showLimit();
                        setState(() {
                          count--;
                          _school01 = false;
                        });
                      }
                    } else if (_school01 == false) {
                      countDown();
                      await FirebaseFirestore.instance
                          .collection('学業')
                          .doc('進級・卒業')
                          .update({
                        "users": FieldValue.arrayRemove([widget.userNameText])
                      });
                      await Firestore.deleteUserConfirmWorries(
                          widget.userNameText,
                          '🎓学業に関する悩み: 試験・レポート・研究等が上手く進まず、進級・卒業できるか心配である。');
                    }
                  },
                ),
                CheckboxListTile(
                  activeColor: const Color.fromARGB(255, 81, 161, 101),
                  value: _school02,
                  title: const Text('大学の講義を受ける中で、自分の入りたい学部じゃなかったと感じることがある。',
                      style: TextStyle(
                        fontSize: 13,
                      )),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool? value) async {
                    setState(() {
                      _school02 = value!;
                    });
                    if (_school02 == true) {
                      countUp();
                      await FirebaseFirestore.instance
                          .collection('学業')
                          .doc('入りたい学部じゃなかった')
                          .update({
                        "users": FieldValue.arrayUnion([widget.userNameText])
                      });
                      await Firestore.registerUserConfirmWorries(
                          widget.userNameText,
                          '🎓学業に関する悩み: 大学の講義を受ける中で、自分の入りたい学部じゃなかったと感じることがある。');
                      // 上限に達した時は、選択したものを自動的に削除する(選んでなかったことにする)
                      if (count == 5) {
                        await FirebaseFirestore.instance
                            .collection('学業')
                            .doc('入りたい学部じゃなかった')
                            .update({
                          "users": FieldValue.arrayRemove([widget.userNameText])
                        });
                        await Firestore.deleteUserConfirmWorries(
                            widget.userNameText,
                            '🎓学業に関する悩み: 大学の講義を受ける中で、自分の入りたい学部じゃなかったと感じることがある。');
                        // ダイアログの表示
                        showLimit();
                        // カウントを減らし、チェックしていなかったことにする
                        setState(() {
                          count--;
                          _school02 = false;
                        });
                      }
                    }
                    // チェックを外した時
                    else if (_school02 == false) {
                      countDown();
                      await FirebaseFirestore.instance
                          .collection('学業')
                          .doc('入りたい学部じゃなかった')
                          .update({
                        "users": FieldValue.arrayRemove([widget.userNameText])
                      });
                      await Firestore.deleteUserConfirmWorries(
                          widget.userNameText,
                          '🎓学業に関する悩み: 大学の講義を受ける中で、自分の入りたい学部じゃなかったと感じることがある。');
                    }
                  },
                ),
                CheckboxListTile(
                  activeColor: const Color.fromARGB(255, 81, 161, 101),
                  value: _school03,
                  title: const Text('大学の講義を受ける中で、ついていけないと感じることがある。',
                      style: TextStyle(
                        fontSize: 13,
                      )),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool? value) async {
                    setState(() {
                      _school03 = value!;
                    });
                    if (_school03 == true) {
                      countUp();
                      await FirebaseFirestore.instance
                          .collection('学業') // コレクションID指定
                          .doc('講義についていけない')
                          .update({
                        "users": FieldValue.arrayUnion([widget.userNameText])
                      });
                      await Firestore.registerUserConfirmWorries(
                          widget.userNameText,
                          '🎓学業に関する悩み: 大学の講義を受ける中で、ついていけないと感じることがある。');
                      if (count == 5) {
                        await FirebaseFirestore.instance
                            .collection('学業')
                            .doc('講義についていけない')
                            .update({
                          "users": FieldValue.arrayRemove([widget.userNameText])
                        });
                        await Firestore.deleteUserConfirmWorries(
                            widget.userNameText,
                            '🎓学業に関する悩み: 大学の講義を受ける中で、ついていけないと感じることがある。');
                        showLimit();
                        setState(() {
                          count--;
                          _school03 = false;
                        });
                      }
                    } else if (_school03 == false) {
                      countDown();
                      await FirebaseFirestore.instance
                          .collection('学業')
                          .doc('講義についていけない')
                          .update({
                        "users": FieldValue.arrayRemove([widget.userNameText])
                      });
                      await Firestore.deleteUserConfirmWorries(
                          widget.userNameText,
                          '🎓学業に関する悩み: 大学の講義を受ける中で、ついていけないと感じることがある。');
                    }
                  },
                ),
                CheckboxListTile(
                  activeColor: const Color.fromARGB(255, 81, 161, 101),
                  value: _school04,
                  title: const Text('学業とサークル・バイトの両立が難しく悩んでいる。',
                      style: TextStyle(
                        fontSize: 13,
                      )),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool? value) async {
                    setState(() {
                      _school04 = value!;
                    });
                    if (_school04 == true) {
                      countUp();
                      await FirebaseFirestore.instance
                          .collection('学業') // コレクションID指定
                          .doc('両立が難しい')
                          .update({
                        "users": FieldValue.arrayUnion([widget.userNameText])
                      });
                      await Firestore.registerUserConfirmWorries(
                          widget.userNameText,
                          '🎓学業に関する悩み: 学業とサークル・バイトの両立が難しく悩んでいる。');
                      if (count == 5) {
                        await FirebaseFirestore.instance
                            .collection('学業')
                            .doc('両立が難しい')
                            .update({
                          "users": FieldValue.arrayRemove([widget.userNameText])
                        });
                        await Firestore.deleteUserConfirmWorries(
                            widget.userNameText,
                            '🎓学業に関する悩み: 学業とサークル・バイトの両立が難しく悩んでいる。');
                        showLimit();
                        setState(() {
                          count--;
                          _school04 = false;
                        });
                      }
                    } else if (_school04 == false) {
                      countDown();
                      await FirebaseFirestore.instance
                          .collection('学業')
                          .doc('両立が難しい')
                          .update({
                        "users": FieldValue.arrayRemove([widget.userNameText])
                      });
                      await Firestore.deleteUserConfirmWorries(
                          widget.userNameText,
                          '🎓学業に関する悩み: 学業とサークル・バイトの両立が難しく悩んでいる。');
                    }
                  },
                ),
                CheckboxListTile(
                  activeColor: const Color.fromARGB(255, 81, 161, 101),
                  value: _school05,
                  title: const Text('大学院に進学すべきか、就職するべきか悩んでいる。',
                      style: TextStyle(
                        fontSize: 13,
                      )),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool? value) async {
                    setState(() {
                      _school05 = value!;
                    });
                    if (_school05 == true) {
                      countUp();
                      await FirebaseFirestore.instance
                          .collection('学業') // コレクションID指定
                          .doc('大学院への進学に不安')
                          .update({
                        "users": FieldValue.arrayUnion([widget.userNameText])
                      });
                      await Firestore.registerUserConfirmWorries(
                          widget.userNameText,
                          '🎓学業に関する悩み: 大学院に進学すべきか、就職するべきか悩んでいる。');
                      if (count == 5) {
                        await FirebaseFirestore.instance
                            .collection('学業')
                            .doc('大学院への進学に不安')
                            .update({
                          "users": FieldValue.arrayRemove([widget.userNameText])
                        });
                        await Firestore.deleteUserConfirmWorries(
                            widget.userNameText,
                            '🎓学業に関する悩み: 大学院に進学すべきか、就職するべきか悩んでいる。');
                        showLimit();
                        setState(() {
                          count--;
                          _school05 = false;
                        });
                      }
                    } else if (_school05 == false) {
                      countDown();
                      await FirebaseFirestore.instance
                          .collection('学業')
                          .doc('大学院への進学に不安')
                          .update({
                        "users": FieldValue.arrayRemove([widget.userNameText])
                      });
                      await Firestore.deleteUserConfirmWorries(
                          widget.userNameText,
                          '🎓学業に関する悩み: 大学院に進学すべきか、就職するべきか悩んでいる。');
                    }
                  },
                ),
                CheckboxListTile(
                  activeColor: const Color.fromARGB(255, 81, 161, 101),
                  value: _school06,
                  title: const Text('周りと比べ就職先がなかなか決まらず、焦り・不安を感じている。',
                      style: TextStyle(
                        fontSize: 13,
                      )),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool? value) async {
                    setState(() {
                      _school06 = value!;
                    });
                    if (_school06 == true) {
                      countUp();
                      await FirebaseFirestore.instance
                          .collection('学業') // コレクションID指定
                          .doc('就職先が決まらない')
                          .update({
                        "users": FieldValue.arrayUnion([widget.userNameText])
                      });
                      await Firestore.registerUserConfirmWorries(
                          widget.userNameText,
                          '🎓学業に関する悩み: 周りと比べ就職先がなかなか決まらず、焦り・不安を感じている。');
                      if (count == 5) {
                        await FirebaseFirestore.instance
                            .collection('学業')
                            .doc('就職先が決まらない')
                            .update({
                          "users": FieldValue.arrayRemove([widget.userNameText])
                        });
                        await Firestore.deleteUserConfirmWorries(
                            widget.userNameText,
                            '🎓学業に関する悩み: 周りと比べ就職先がなかなか決まらず、焦り・不安を感じている。');
                        showLimit();
                        setState(() {
                          count--;
                          _school06 = false;
                        });
                      }
                    } else if (_school06 == false) {
                      countDown();
                      await FirebaseFirestore.instance
                          .collection('学業')
                          .doc('就職先が決まらない')
                          .update({
                        "users": FieldValue.arrayRemove([widget.userNameText])
                      });
                      await Firestore.deleteUserConfirmWorries(
                          widget.userNameText,
                          '🎓学業に関する悩み: 周りと比べ就職先がなかなか決まらず、焦り・不安を感じている。');
                    }
                  },
                ),
                CheckboxListTile(
                  activeColor: const Color.fromARGB(255, 81, 161, 101),
                  value: _school07,
                  title: const Text('就職したい業界が決まらず悩んでいる。',
                      style: TextStyle(
                        fontSize: 13,
                      )),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool? value) async {
                    setState(() {
                      _school07 = value!;
                    });
                    if (_school07 == true) {
                      countUp();
                      await FirebaseFirestore.instance
                          .collection('学業') // コレクションID指定
                          .doc('就職したい業界が分からない')
                          .update({
                        "users": FieldValue.arrayUnion([widget.userNameText])
                      });
                      await Firestore.registerUserConfirmWorries(
                          widget.userNameText,
                          '🎓学業に関する悩み: 就職したい業界が決まらず悩んでいる。');
                      if (count == 5) {
                        await FirebaseFirestore.instance
                            .collection('学業')
                            .doc('就職したい業界が分からない')
                            .update({
                          "users": FieldValue.arrayRemove([widget.userNameText])
                        });
                        await Firestore.deleteUserConfirmWorries(
                            widget.userNameText,
                            '🎓学業に関する悩み: 就職したい業界が決まらず悩んでいる。');
                        showLimit();
                        setState(() {
                          count--;
                          _school07 = false;
                        });
                      }
                    } else if (_school07 == false) {
                      countDown();
                      await FirebaseFirestore.instance
                          .collection('学業')
                          .doc('就職したい業界が分からない')
                          .update({
                        "users": FieldValue.arrayRemove([widget.userNameText])
                      });
                      await Firestore.deleteUserConfirmWorries(
                          widget.userNameText,
                          '🎓学業に関する悩み: 就職したい業界が決まらず悩んでいる。');
                    }
                  },
                ),
                CheckboxListTile(
                  activeColor: const Color.fromARGB(255, 81, 161, 101),
                  value: _school08,
                  title: const Text('学費・奨学金・生活費などの金銭面で悩んでいる。',
                      style: TextStyle(
                        fontSize: 13,
                      )),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool? value) async {
                    setState(() {
                      _school08 = value!;
                    });
                    if (_school08 == true) {
                      countUp();
                      await FirebaseFirestore.instance
                          .collection('学業') // コレクションID指定
                          .doc('金銭面')
                          .update({
                        "users": FieldValue.arrayUnion([widget.userNameText])
                      });
                      await Firestore.registerUserConfirmWorries(
                          widget.userNameText,
                          '🎓学業に関する悩み: 学費・奨学金・生活費などの金銭面で悩んでいる。');
                      if (count == 5) {
                        await FirebaseFirestore.instance
                            .collection('学業')
                            .doc('金銭面')
                            .update({
                          "users": FieldValue.arrayRemove([widget.userNameText])
                        });
                        await Firestore.deleteUserConfirmWorries(
                            widget.userNameText,
                            '🎓学業に関する悩み: 学費・奨学金・生活費などの金銭面で悩んでいる。');
                        showLimit();
                        setState(() {
                          count--;
                          _school08 = false;
                        });
                      }
                    } else if (_school08 == false) {
                      countDown();
                      await FirebaseFirestore.instance
                          .collection('学業')
                          .doc('金銭面')
                          .update({
                        "users": FieldValue.arrayRemove([widget.userNameText])
                      });
                      await Firestore.deleteUserConfirmWorries(
                          widget.userNameText,
                          '🎓学業に関する悩み: 学費・奨学金・生活費などの金銭面で悩んでいる。');
                    }
                  },
                ),
                const Padding(
                    padding: EdgeInsets.only(
                        top: 20, bottom: 10, left: 20, right: 20),
                    child: Text('👫 人間関係に関する悩み',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          // fontWeight: FontWeight.bold
                        ))),
                const Divider(
                  color: Colors.grey,
                  thickness: 0.5,
                  height: 0,
                  indent: 15,
                  endIndent: 15,
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                ),
                CheckboxListTile(
                  activeColor: const Color.fromARGB(255, 81, 161, 101),
                  value: _relationship01,
                  title: const Text('大学・サークル・バイト内などでの友人関係・上下関係に悩んでいる。',
                      style: TextStyle(
                        fontSize: 13,
                      )),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool? value) async {
                    setState(() {
                      _relationship01 = value!;
                    });
                    if (_relationship01 == true) {
                      countUp();
                      await FirebaseFirestore.instance
                          .collection('人間関係')
                          .doc('友人関係・上下関係')
                          .update({
                        "users": FieldValue.arrayUnion([widget.userNameText])
                      });
                      await Firestore.registerUserConfirmWorries(
                          widget.userNameText,
                          '👫人間関係に関する悩み: 大学・サークル・バイト内などでの友人関係・上下関係に悩んでいる。');
                      if (count == 5) {
                        await FirebaseFirestore.instance
                            .collection('人間関係')
                            .doc('友人関係・上下関係')
                            .update({
                          "users": FieldValue.arrayRemove([widget.userNameText])
                        });
                        await Firestore.deleteUserConfirmWorries(
                            widget.userNameText,
                            '👫人間関係に関する悩み: 大学・サークル・バイト内などでの友人関係・上下関係に悩んでいる。');
                        showLimit();
                        setState(() {
                          count--;
                          _relationship01 = false;
                        });
                      }
                    } else if (_relationship01 == false) {
                      countDown();
                      await FirebaseFirestore.instance
                          .collection('人間関係')
                          .doc('友人関係・上下関係')
                          .update({
                        "users": FieldValue.arrayRemove([widget.userNameText])
                      });
                      await Firestore.deleteUserConfirmWorries(
                          widget.userNameText,
                          '👫人間関係に関する悩み: 大学・サークル・バイト内などでの友人関係・上下関係に悩んでいる。');
                    }
                  },
                ),
                CheckboxListTile(
                  activeColor: const Color.fromARGB(255, 81, 161, 101),
                  value: _relationship02,
                  title: const Text('研究室やクラスルームの先生、メンバーに不満を抱えている。',
                      style: TextStyle(
                        fontSize: 13,
                      )),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool? value) async {
                    setState(() {
                      _relationship02 = value!;
                    });
                    if (_relationship02 == true) {
                      countUp();
                      await FirebaseFirestore.instance
                          .collection('人間関係')
                          .doc('先生やメンバーへの不満')
                          .update({
                        "users": FieldValue.arrayUnion([widget.userNameText])
                      });
                      await Firestore.registerUserConfirmWorries(
                          widget.userNameText,
                          '👫人間関係に関する悩み: 研究室やクラスルームの先生、メンバーに不満を抱えている。');
                      if (count == 5) {
                        await FirebaseFirestore.instance
                            .collection('人間関係')
                            .doc('先生やメンバーへの不満')
                            .update({
                          "users": FieldValue.arrayRemove([widget.userNameText])
                        });
                        await Firestore.deleteUserConfirmWorries(
                            widget.userNameText,
                            '👫人間関係に関する悩み: 研究室やクラスルームの先生、メンバーに不満を抱えている。');
                        showLimit();
                        setState(() {
                          count--;
                          _relationship02 = false;
                        });
                      }
                    } else if (_relationship02 == false) {
                      countDown();
                      await FirebaseFirestore.instance
                          .collection('人間関係')
                          .doc('先生やメンバーへの不満')
                          .update({
                        "users": FieldValue.arrayRemove([widget.userNameText])
                      });
                      await Firestore.deleteUserConfirmWorries(
                          widget.userNameText,
                          '👫人間関係に関する悩み: 研究室やクラスルームの先生、メンバーに不満を抱えている。');
                    }
                  },
                ),
                CheckboxListTile(
                  activeColor: const Color.fromARGB(255, 81, 161, 101),
                  value: _relationship03,
                  title: const Text('大学・サークル・バイト内などで友達ができずに悩んでいる。',
                      style: TextStyle(
                        fontSize: 13,
                      )),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool? value) async {
                    setState(() {
                      _relationship03 = value!;
                    });
                    if (_relationship03 == true) {
                      countUp();
                      await FirebaseFirestore.instance
                          .collection('人間関係')
                          .doc('友達ができない')
                          .update({
                        "users": FieldValue.arrayUnion([widget.userNameText])
                      });
                      await Firestore.registerUserConfirmWorries(
                          widget.userNameText,
                          '👫人間関係に関する悩み: 大学・サークル・バイト内などで友達ができずに悩んでいる。');
                      if (count == 5) {
                        await FirebaseFirestore.instance
                            .collection('人間関係')
                            .doc('友達ができない')
                            .update({
                          "users": FieldValue.arrayRemove([widget.userNameText])
                        });
                        await Firestore.deleteUserConfirmWorries(
                            widget.userNameText,
                            '👫人間関係に関する悩み: 大学・サークル・バイト内などで友達ができずに悩んでいる。');
                        showLimit();
                        setState(() {
                          count--;
                          _relationship03 = false;
                        });
                      }
                    } else if (_relationship03 == false) {
                      countDown();
                      await FirebaseFirestore.instance
                          .collection('人間関係')
                          .doc('友達ができない')
                          .update({
                        "users": FieldValue.arrayRemove([widget.userNameText])
                      });
                      await Firestore.deleteUserConfirmWorries(
                          widget.userNameText,
                          '👫人間関係に関する悩み: 大学・サークル・バイト内などで友達ができずに悩んでいる。');
                    }
                  },
                ),
                CheckboxListTile(
                  activeColor: const Color.fromARGB(255, 81, 161, 101),
                  value: _relationship04,
                  title: const Text('家族に不満を抱えている。',
                      style: TextStyle(
                        fontSize: 13,
                      )),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool? value) async {
                    setState(() {
                      _relationship04 = value!;
                    });
                    if (_relationship04 == true) {
                      countUp();
                      await FirebaseFirestore.instance
                          .collection('人間関係')
                          .doc('家族に不満')
                          .update({
                        "users": FieldValue.arrayUnion([widget.userNameText])
                      });
                      await Firestore.registerUserConfirmWorries(
                          widget.userNameText, '👫人間関係に関する悩み: 家族に不満を抱えている。');
                      if (count == 5) {
                        await FirebaseFirestore.instance
                            .collection('人間関係')
                            .doc('家族に不満')
                            .update({
                          "users": FieldValue.arrayRemove([widget.userNameText])
                        });
                        await Firestore.deleteUserConfirmWorries(
                            widget.userNameText, '👫人間関係に関する悩み: 家族に不満を抱えている。');
                        showLimit();
                        setState(() {
                          count--;
                          _relationship04 = false;
                        });
                      }
                    } else if (_relationship04 == false) {
                      countDown();
                      await FirebaseFirestore.instance
                          .collection('人間関係')
                          .doc('家族に不満')
                          .update({
                        "users": FieldValue.arrayRemove([widget.userNameText])
                      });
                      await Firestore.deleteUserConfirmWorries(
                          widget.userNameText, '👫人間関係に関する悩み: 家族に不満を抱えている。');
                    }
                  },
                ),
                CheckboxListTile(
                  activeColor: const Color.fromARGB(255, 81, 161, 101),
                  value: _relationship05,
                  title: const Text('セクシャリティのことについて悩んでいる。',
                      style: TextStyle(
                        fontSize: 13,
                      )),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool? value) async {
                    setState(() {
                      _relationship05 = value!;
                    });
                    if (_relationship05 == true) {
                      countUp();
                      await FirebaseFirestore.instance
                          .collection('人間関係')
                          .doc('セクシャリティ')
                          .update({
                        "users": FieldValue.arrayUnion([widget.userNameText])
                      });
                      await Firestore.registerUserConfirmWorries(
                          widget.userNameText,
                          '👫人間関係に関する悩み: セクシャリティのことについて悩んでいる。');
                      if (count == 5) {
                        await FirebaseFirestore.instance
                            .collection('人間関係')
                            .doc('セクシャリティ')
                            .update({
                          "users": FieldValue.arrayRemove([widget.userNameText])
                        });
                        await Firestore.deleteUserConfirmWorries(
                            widget.userNameText,
                            '👫人間関係に関する悩み: セクシャリティのことについて悩んでいる。');
                        showLimit();
                        setState(() {
                          count--;
                          _relationship05 = false;
                        });
                      }
                    } else if (_relationship05 == false) {
                      countDown();
                      await FirebaseFirestore.instance
                          .collection('人間関係')
                          .doc('セクシャリティ')
                          .update({
                        "users": FieldValue.arrayRemove([widget.userNameText])
                      });
                      await Firestore.deleteUserConfirmWorries(
                          widget.userNameText,
                          '👫人間関係に関する悩み: セクシャリティのことについて悩んでいる。');
                    }
                  },
                ),
                CheckboxListTile(
                  activeColor: const Color.fromARGB(255, 81, 161, 101),
                  value: _relationship06,
                  title: const Text('失恋から立ち直ることができない。',
                      style: TextStyle(
                        fontSize: 13,
                      )),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool? value) async {
                    setState(() {
                      _relationship06 = value!;
                    });
                    if (_relationship06 == true) {
                      countUp();
                      await FirebaseFirestore.instance
                          .collection('人間関係')
                          .doc('失恋')
                          .update({
                        "users": FieldValue.arrayUnion([widget.userNameText])
                      });
                      await Firestore.registerUserConfirmWorries(
                          widget.userNameText,
                          '👫人間関係に関する悩み: 失恋から立ち直ることができない。');
                      if (count == 5) {
                        await FirebaseFirestore.instance
                            .collection('人間関係')
                            .doc('失恋')
                            .update({
                          "users": FieldValue.arrayRemove([widget.userNameText])
                        });
                        await Firestore.deleteUserConfirmWorries(
                            widget.userNameText,
                            '👫人間関係に関する悩み: 失恋から立ち直ることができない。');
                        showLimit();
                        setState(() {
                          count--;
                          _relationship06 = false;
                        });
                      }
                    } else if (_relationship06 == false) {
                      countDown();
                      await FirebaseFirestore.instance
                          .collection('人間関係')
                          .doc('失恋')
                          .update({
                        "users": FieldValue.arrayRemove([widget.userNameText])
                      });
                      await Firestore.deleteUserConfirmWorries(
                          widget.userNameText,
                          '👫人間関係に関する悩み: 失恋から立ち直ることができない。');
                    }
                  },
                ),
                const Padding(
                    padding: EdgeInsets.only(
                        top: 20, bottom: 10, left: 20, right: 20),
                    child: Text('🏠 環境の変化に関する悩み',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          // fontWeight: FontWeight.bold
                        ))),
                const Divider(
                  color: Colors.grey,
                  thickness: 0.5,
                  height: 0,
                  indent: 15,
                  endIndent: 15,
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                ),
                CheckboxListTile(
                  activeColor: const Color.fromARGB(255, 81, 161, 101),
                  value: _life01,
                  title: const Text('親元を離れてしまったことで、寂しさ・孤独感を感じている。',
                      style: TextStyle(
                        fontSize: 13,
                      )),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool? value) async {
                    setState(() {
                      _life01 = value!;
                    });
                    if (_life01 == true) {
                      countUp();
                      await FirebaseFirestore.instance
                          .collection('環境の変化')
                          .doc('寂しさ・孤独感')
                          .update({
                        "users": FieldValue.arrayUnion([widget.userNameText])
                      });
                      await Firestore.registerUserConfirmWorries(
                          widget.userNameText,
                          '🏠環境の変化に関する悩み: 親元を離れてしまったことで、寂しさ・孤独感を感じている。');
                      if (count == 5) {
                        await FirebaseFirestore.instance
                            .collection('環境の変化')
                            .doc('寂しさ・孤独感')
                            .update({
                          "users": FieldValue.arrayRemove([widget.userNameText])
                        });
                        await Firestore.deleteUserConfirmWorries(
                            widget.userNameText,
                            '🏠環境の変化に関する悩み: 親元を離れてしまったことで、寂しさ・孤独感を感じている。');
                        showLimit();
                        setState(() {
                          count--;
                          _life01 = false;
                        });
                      }
                    } else if (_life01 == false) {
                      countDown();
                      await FirebaseFirestore.instance
                          .collection('環境の変化')
                          .doc('寂しさ・孤独感')
                          .update({
                        "users": FieldValue.arrayRemove([widget.userNameText])
                      });
                      await Firestore.deleteUserConfirmWorries(
                          widget.userNameText,
                          '🏠環境の変化に関する悩み: 親元を離れてしまったことで、寂しさ・孤独感を感じている。');
                    }
                  },
                ),
                CheckboxListTile(
                  activeColor: const Color.fromARGB(255, 81, 161, 101),
                  value: _life02,
                  title: const Text('一人暮らしを始めたが、一人で生活できるか不安だ。',
                      style: TextStyle(
                        fontSize: 13,
                      )),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool? value) async {
                    setState(() {
                      _life02 = value!;
                    });
                    if (_life02 == true) {
                      countUp();
                      await FirebaseFirestore.instance
                          .collection('環境の変化')
                          .doc('一人暮らしの不安')
                          .update({
                        "users": FieldValue.arrayUnion([widget.userNameText])
                      });
                      await Firestore.registerUserConfirmWorries(
                          widget.userNameText,
                          '🏠環境の変化に関する悩み: 一人暮らしを始めたが、一人で生活できるか不安だ。');
                      if (count == 5) {
                        await FirebaseFirestore.instance
                            .collection('環境の変化')
                            .doc('一人暮らしの不安')
                            .update({
                          "users": FieldValue.arrayRemove([widget.userNameText])
                        });
                        await Firestore.deleteUserConfirmWorries(
                            widget.userNameText,
                            '🏠環境の変化に関する悩み: 一人暮らしを始めたが、一人で生活できるか不安だ。');
                        showLimit();
                        setState(() {
                          count--;
                          _life02 = false;
                        });
                      }
                    } else if (_life02 == false) {
                      countDown();
                      await FirebaseFirestore.instance
                          .collection('環境の変化')
                          .doc('一人暮らしの不安')
                          .update({
                        "users": FieldValue.arrayRemove([widget.userNameText])
                      });
                      await Firestore.deleteUserConfirmWorries(
                          widget.userNameText,
                          '🏠環境の変化に関する悩み: 一人暮らしを始めたが、一人で生活できるか不安だ。');
                    }
                  },
                ),
                CheckboxListTile(
                  activeColor: const Color.fromARGB(255, 81, 161, 101),
                  value: _life03,
                  title: const Text('隣人の騒音に悩んでいる。',
                      style: TextStyle(
                        fontSize: 13,
                      )),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool? value) async {
                    setState(() {
                      _life03 = value!;
                    });
                    if (_life03 == true) {
                      countUp();
                      await FirebaseFirestore.instance
                          .collection('環境の変化')
                          .doc('騒音')
                          .update({
                        "users": FieldValue.arrayUnion([widget.userNameText])
                      });
                      await Firestore.registerUserConfirmWorries(
                          widget.userNameText, '🏠環境の変化に関する悩み: 隣人の騒音に悩んでいる');
                      if (count == 5) {
                        await FirebaseFirestore.instance
                            .collection('環境の変化')
                            .doc('騒音')
                            .update({
                          "users": FieldValue.arrayRemove([widget.userNameText])
                        });
                        await Firestore.deleteUserConfirmWorries(
                            widget.userNameText, '🏠環境の変化に関する悩み: 隣人の騒音に悩んでいる');
                        showLimit();
                        setState(() {
                          count--;
                          _life03 = false;
                        });
                      }
                    } else if (_life03 == false) {
                      countDown();
                      await FirebaseFirestore.instance
                          .collection('環境の変化')
                          .doc('騒音')
                          .update({
                        "users": FieldValue.arrayRemove([widget.userNameText])
                      });
                      await Firestore.deleteUserConfirmWorries(
                          widget.userNameText, '🏠環境の変化に関する悩み: 隣人の騒音に悩んでいる');
                    }
                  },
                ),
                const Padding(
                    padding: EdgeInsets.only(
                        top: 20, bottom: 10, left: 20, right: 20),
                    child: Text('🐱 自分のことに関する悩み',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                        ))),
                const Divider(
                  color: Colors.grey,
                  thickness: 0.5,
                  height: 0,
                  indent: 15,
                  endIndent: 15,
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                ),
                CheckboxListTile(
                  activeColor: const Color.fromARGB(255, 81, 161, 101),
                  value: _health01,
                  title: const Text('自分の性格について悩んでいる。',
                      style: TextStyle(
                        fontSize: 13,
                      )),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool? value) async {
                    setState(() {
                      _health01 = value!;
                    });
                    if (_health01 == true) {
                      countUp();
                      await FirebaseFirestore.instance
                          .collection('自分のこと')
                          .doc('自分の性格')
                          .update({
                        "users": FieldValue.arrayUnion([widget.userNameText])
                      });
                      await Firestore.registerUserConfirmWorries(
                          widget.userNameText,
                          '🐱自分のことに関する悩み: 自分の性格について悩んでいる。');
                      if (count == 5) {
                        await FirebaseFirestore.instance
                            .collection('自分のこと')
                            .doc('自分の性格')
                            .update({
                          "users": FieldValue.arrayRemove([widget.userNameText])
                        });
                        await Firestore.deleteUserConfirmWorries(
                            widget.userNameText,
                            '🐱自分のことに関する悩み: 自分の性格について悩んでいる。');
                        showLimit();
                        setState(() {
                          count--;
                          _health01 = false;
                        });
                      }
                    } else if (_health01 == false) {
                      countDown();
                      await FirebaseFirestore.instance
                          .collection('自分のこと')
                          .doc('自分の性格')
                          .update({
                        "users": FieldValue.arrayRemove([widget.userNameText])
                      });
                      await Firestore.deleteUserConfirmWorries(
                          widget.userNameText,
                          '🐱自分のことに関する悩み: 自分の性格について悩んでいる。');
                    }
                  },
                ),
                CheckboxListTile(
                  activeColor: const Color.fromARGB(255, 81, 161, 101),
                  value: _health02,
                  title: const Text('自分の成育過程・過程環境(トラウマなど)について悩んでいる。',
                      style: TextStyle(
                        fontSize: 13,
                      )),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool? value) async {
                    setState(() {
                      _health02 = value!;
                    });
                    if (_health02 == true) {
                      countUp();
                      await FirebaseFirestore.instance
                          .collection('自分のこと')
                          .doc('成育過程・過程環境')
                          .update({
                        "users": FieldValue.arrayUnion([widget.userNameText])
                      });
                      await Firestore.registerUserConfirmWorries(
                          widget.userNameText,
                          '🐱自分のことに関する悩み: 自分の成育過程・過程環境(トラウマなど)について悩んでいる。');
                      if (count == 5) {
                        await FirebaseFirestore.instance
                            .collection('自分のこと')
                            .doc('成育過程・過程環境')
                            .update({
                          "users": FieldValue.arrayRemove([widget.userNameText])
                        });
                        await Firestore.deleteUserConfirmWorries(
                            widget.userNameText,
                            '🐱自分のことに関する悩み: 自分の成育過程・過程環境(トラウマなど)について悩んでいる。');
                        showLimit();
                        setState(() {
                          count--;
                          _health02 = false;
                        });
                      }
                    } else if (_health02 == false) {
                      countDown();
                      await FirebaseFirestore.instance
                          .collection('自分のこと')
                          .doc('成育過程・過程環境')
                          .update({
                        "users": FieldValue.arrayRemove([widget.userNameText])
                      });
                      await Firestore.deleteUserConfirmWorries(
                          widget.userNameText,
                          '🐱自分のことに関する悩み: 自分の成育過程・過程環境(トラウマなど)について悩んでいる。');
                    }
                  },
                ),
                CheckboxListTile(
                  activeColor: const Color.fromARGB(255, 81, 161, 101),
                  value: _health03,
                  title: const Text('自分の身体・健康について悩んでいる。',
                      style: TextStyle(
                        fontSize: 13,
                      )),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool? value) async {
                    setState(() {
                      _health03 = value!;
                    });
                    if (_health03 == true) {
                      countUp();
                      await FirebaseFirestore.instance
                          .collection('自分のこと')
                          .doc('身体・健康')
                          .update({
                        "users": FieldValue.arrayUnion([widget.userNameText])
                      });
                      await Firestore.registerUserConfirmWorries(
                          widget.userNameText,
                          '🐱自分のことに関する悩み: 自分の身体・健康について悩んでいる。');
                      if (count == 5) {
                        await FirebaseFirestore.instance
                            .collection('自分のこと')
                            .doc('身体・健康')
                            .update({
                          "users": FieldValue.arrayRemove([widget.userNameText])
                        });
                        await Firestore.deleteUserConfirmWorries(
                            widget.userNameText,
                            '🐱自分のことに関する悩み: 自分の身体・健康について悩んでいる。');
                        showLimit();
                        setState(() {
                          count--;
                          _health03 = false;
                        });
                      }
                    } else if (_health03 == false) {
                      countDown();
                      await FirebaseFirestore.instance
                          .collection('自分のこと')
                          .doc('身体・健康')
                          .update({
                        "users": FieldValue.arrayRemove([widget.userNameText])
                      });
                      await Firestore.deleteUserConfirmWorries(
                          widget.userNameText,
                          '🐱自分のことに関する悩み: 自分の身体・健康について悩んでいる。');
                    }
                  },
                ),
                Center(
                  child: TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor:
                            const Color.fromARGB(255, 81, 161, 101),
                      ),
                      onPressed: () => _openUrl(),
                      icon: const Icon(
                        Icons.error,
                        size: 20,
                      ),
                      label: const Text(
                        '当てはまる悩みがなかった方はこちら',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      )),
                ),
                const Padding(
                    padding: EdgeInsets.only(
                        top: 20, bottom: 0, left: 20, right: 20),
                    child: Text('2. あなたの悩みについて教えてください。',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ))),
                const Gap(5),
                const Padding(
                    padding:
                        EdgeInsets.only(top: 5, bottom: 0, left: 20, right: 20),
                    child: Text(
                        'Q. あなたが一番悩んでいる悩みを教えてください。\nQ. 上記の項目にないことで悩んでいることがあれば、ここに記載してください。 \n\n※ここに入力されたお悩みは、マッチング相手に公開されます。\n※記入が難しい場合は、入力なしで登録してください。',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ))),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 20, bottom: 10, left: 20, right: 20),
                  child: TextFormField(
                    controller: _worriesExplanationController,
                    maxLines: 6,
                    minLines: 6,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      hintText: '悩みを教えてください',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          width: 1,
                          color: Colors.grey,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          width: 2,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 50),
                    child: Align(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            alignment: Alignment.center,
                            foregroundColor: Colors.white,
                            backgroundColor:
                                const Color.fromARGB(255, 81, 161, 101),
                          ),
                          onPressed: () async {
                            final worriesExplanation =
                                _worriesExplanationController.text;
                            final userName = widget.userNameText;

                            // 悩みをチェックしているかを確認する
                            // 全てfalseならダイアログを表示する
                            if ((!_school01 &&
                                !_school02 &&
                                !_school03 &&
                                !_school04 &&
                                !_school05 &&
                                !_school06 &&
                                !_school07 &&
                                !_school08 &&
                                !_relationship01 &&
                                !_relationship02 &&
                                !_relationship03 &&
                                !_relationship04 &&
                                !_relationship05 &&
                                !_relationship06 &&
                                !_life01 &&
                                !_life02 &&
                                !_life03 &&
                                !_health01 &&
                                !_health02 &&
                                !_health03)) {
                              return showNoSelect();
                            } else {
                              return showConfirmWorries();
                            }

                            // 悩みの説明に記載がない場合、テンプレート文を登録、記載がある場合、その内容を登録
                            // if (worriesExplanation == '') {
                            //   await Firestore.registerExplanationEmpty(userName);
                            // } else {
                            //   await Firestore.registerExplanation(
                            //       userName, worriesExplanation);
                            // }

                            // await Navigator.of(context).pushReplacement(
                            //   MaterialPageRoute(builder: (context) {
                            //     return const HomePage();
                            //   }),
                            // );
                          },
                          child: const Text('登録'),
                        ))),
                Padding(padding: EdgeInsets.only(bottom: bottomSpace)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void countUp() {
    count++;
    if (count == 5) {
      print(count);
    }
  }

  void countDown() {
    count--;
    print(count);
  }

  void showLimit() {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            titlePadding: const EdgeInsets.only(top: 20),
            title: Image.asset(
              'images/sorry.png',
              height: 180,
            ),
            content: const Text(
              '登録できる悩みは4つまでです。\n新しく追加したい場合は、既に登録されている悩みを外してから、追加してください。',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              // シミュレーターだと戻れるが、実機だとログインページまで戻ってしまうため、一時コメントアウト
              // TextButton(
              //   child: const Text(
              //     'OK',
              //     style: TextStyle(color: Color.fromARGB(255, 81, 161, 101)),
              //   ),
              //   onPressed: () {
              //     Navigator.of(context).pop();
              //   },
              // ),
            ],
          );
        });
  }

  void showNoSelect() {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            titlePadding: const EdgeInsets.only(top: 20),
            title: Image.asset(
              'images/sorry.png',
              height: 180,
            ),
            content: const Text(
              '現在、悩みが登録されていません。\n\n当てはまる悩みがなかった方は、この画面の「当てはまる悩みがなかった方はこちら」からアンケートにお進みください。',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              // シミュレーターだと戻れるが、実機だとログインページまで戻ってしまうため、一時コメントアウト
              // TextButton(
              //   child: const Text(
              //     'OK',
              //     style: TextStyle(color: Color.fromARGB(255, 81, 161, 101)),
              //   ),
              //   onPressed: () {
              //     Navigator.of(context).pop();
              //   },
              // ),
            ],
          );
        });
  }

  void showConfirmWorries() {
    final worriesExplanation = _worriesExplanationController.text;
    final userName = widget.userNameText;
    showDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
            // イラストを使用する場合
            // title: Image.asset(
            //   'images/OK.png',
            //   height: 180,
            // ),
            title: const Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 5),
              child: Text(
                '登録内容の確認',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
            content: Column(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'こちらの悩みで登録してもよろしいですか？',
                    style: TextStyle(fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Text(
                  '登録後は悩みを変更することができません。',
                  style: TextStyle(fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const Gap(10),
                if (_school01)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      '✅ 試験・レポート・研究等が上手く進まず、進級・卒業できるか心配である。',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                if (_school02)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      '✅ 大学の講義を受ける中で、自分の入りたい学部じゃなかったと感じることがある。',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                if (_school03)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      '✅ 大学の講義を受ける中で、ついていけないと感じることがある。',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                if (_school04)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      '✅ 学業とサークル・バイトの両立が難しく悩んでいる。',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                if (_school05)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      '✅ 大学院に進学すべきか、就職するべきか悩んでいる。',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                if (_school06)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      '✅ 周りと比べ就職先がなかなか決まらず、焦り・不安を感じている。',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                if (_school07)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      '✅ 就職したい業界が決まらず悩んでいる。',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                if (_school08)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      '✅ 学費・奨学金・生活費などの金銭面で悩んでいる。',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                if (_relationship01)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      '✅ 大学・サークル・バイト内などでの友人関係・上下関係に悩んでいる。',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                if (_relationship02)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      '✅ 研究室やクラスルームの先生、メンバーに不満を抱えている。',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                if (_relationship03)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      '✅ 大学・サークル・バイト内などで友達ができずに悩んでいる。',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                if (_relationship04)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      '✅ 家族に不満を抱えている。',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                if (_relationship05)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      '✅ セクシャリティのことについて悩んでいる。',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                if (_relationship06)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      '✅ 失恋から立ち直ることができない。',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                if (_life01)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      '✅ 親元を離れてしまったことで、寂しさ・孤独感を感じている。',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                if (_life02)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      '✅ 一人暮らしを始めたが、一人で生活できるか不安だ。',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                if (_life03)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      '✅ 隣人の騒音に悩んでいる。',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                if (_health01)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      '✅ 自分の性格について悩んでいる。',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                if (_health02)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      '✅ 自分の成育過程・過程環境(トラウマなど)について悩んでいる。',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                if (_health03)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      '✅ 自分の身体・健康について悩んでいる。',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  '戻る',
                ),
                onPressed: () {
                  return Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text(
                  '登録',
                ),
                onPressed: () async {
                  // 悩みの説明に記載がない場合、テンプレート文を登録、記載がある場合、その内容を登録
                  if (worriesExplanation == '') {
                    await Firestore.registerExplanationEmpty(userName);
                  } else {
                    await Firestore.registerExplanation(
                        userName, worriesExplanation);
                  }

                  await Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) {
                      return const HomePage();
                    }),
                  );
                },
              ),
            ],
          );
        });
  }

  _openUrl() async {
    const url = 'https://forms.gle/W9UMC2Um6vB5bvrM9';
    if (await canLaunch(url)) {
      await launch(
        url,
        // iOSでアプリ内かブラウザのどちらかでURLを開くか決める。
        forceSafariVC: true,
        // Androidでアプリ内かブラウザのどちらかでURLを開くか決める。
        forceWebView: false,
      );
    } else {
      throw 'このURLにはアクセスできません';
    }
  }
}
