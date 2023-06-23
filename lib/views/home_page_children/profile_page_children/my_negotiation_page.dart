import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:terra/models/v2/negotiation_model.dart';
import 'package:terra/services/API/user_api.dart';
import 'package:terra/utils/color.dart';

class MyNegotiationPage extends StatefulWidget {
  const MyNegotiationPage({super.key});

  @override
  State<MyNegotiationPage> createState() => _MyNegotiationPageState();
}

class _MyNegotiationPageState extends State<MyNegotiationPage> {
  final AppColors _colors = AppColors.instance;
  final UserApi _api = UserApi();
  final BehaviorSubject<List<NegotiationModel>> _subject =
      BehaviorSubject<List<NegotiationModel>>();

  Stream<List<NegotiationModel>> get stream => _subject.stream;

  void fetch() async {
    await _api.getMyNegotiations().then((value) {
      _subject.add(value);
    });
  }

  @override
  void initState() {
    fetch();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text("My Negotiations"),
      ),
      body: StreamBuilder<List<NegotiationModel>>(
        stream: stream,
        builder: (_, snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Image.asset("assets/images/loader.gif"),
            );
          }
          final List<NegotiationModel> data = snapshot.data!;
          if (data.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "No Negotiations found",
                  style: TextStyle(
                    color: Colors.black.withOpacity(.6),
                  ),
                ),
              ),
            );
          }
          return Container();
          // return ListView.separated(
          //   itemBuilder: (_, i) {
          //     final NegotiationModel value = data[i];
          //     return ListTile(
          //       title: ,
          //     );
          //   },
          //   separatorBuilder: (_, i) => const SizedBox(
          //     height: 10,
          //   ),
          //   itemCount: data.length,
          // );
        },
      ),
    );
  }
}
