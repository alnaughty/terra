import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:terra/utils/color.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  static final List<String> types = [
    "cash-in",
    "transfer",
    "scan",
    "cash-out",
    "bank-transfer",
    "pay",
  ];
  final AppColors _colors = AppColors.instance;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Container(
              width: size.width,
              height: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _colors.top,
                    _colors.bot,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Terran Wallet".toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "Available Balance".toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "\u{20B1} ${double.parse("10000").toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.spaceBetween,
              runAlignment: WrapAlignment.spaceBetween,
              children: [
                ...types.map(
                  (e) {
                    final String clean = e.replaceAll("-", " ");
                    return SizedBox(
                      width: 85,
                      height: 65,
                      child: MaterialButton(
                        padding: const EdgeInsets.all(0),
                        onPressed: () {},
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 25,
                              child: Image.asset(
                                "assets/icons/$e.png",
                                fit: BoxFit.fill,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "${clean[0].toUpperCase()}${clean.substring(1)}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            Divider(
              color: Colors.grey.shade300,
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (_, i) {
                final DateTime date = DateTime.utc(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                ).add(Duration(days: i + 1));
                final int randomIndex = Random().nextInt(types.length);
                final double randomPrice = Random().nextDouble() * 1000;
                final String clean = types[randomIndex].replaceAll("-", " ");
                return ListTile(
                  title: Text(
                    "${clean[0].toUpperCase()}${clean.substring(1)}",
                  ),
                  subtitle: Text(
                    DateFormat("MMMM dd, yyyy").format(date),
                  ),
                  trailing: Text(
                    "\u{20B1} ${randomPrice.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => Divider(
                color: Colors.grey.shade200,
              ),
              itemCount: 20,
            )
          ],
        ),
      ),
    ));
  }
}
