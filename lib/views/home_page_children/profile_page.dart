import 'package:flutter/material.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AppColors _colors = AppColors.instance;
  final double headerHeight = 350;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: size.width,
              height: headerHeight,
              child: Stack(
                children: [
                  Container(
                    width: size.width,
                    height: headerHeight * .5,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                      colors: [
                        _colors.top,
                        _colors.bot,
                      ],
                    )),
                  ),
                  Positioned(
                    top: (headerHeight * .5) - 50,
                    child: SizedBox(
                      width: size.width,
                      height: headerHeight * .65,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Container(
                              color: Colors.white,
                              child: Image.network(
                                loggedUser!.avatar,
                                width: 100,
                                height: 100,
                              ),
                            ),
                            // child: Container(
                            //   width: 100,
                            //   height: 100,
                            //   // decoration: BoxDecoration(
                            //   //   borderRadius: BorderRadius.circular(100),
                            //   //   color: Colors.orange,
                            //   // ),
                            // ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              5,
                              (index) => Icon(
                                index < 4 ? Icons.star : Icons.star_border,
                                color: index < 4 ? Colors.orange : Colors.grey,
                                size: 15,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            loggedUser!.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            loggedUser!.email,
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 12,
                              color: Colors.black.withOpacity(.6),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Center(
                            child: SizedBox(
                              width: size.width * .4,
                              height: 25,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(
                                  5,
                                  (index) => Container(
                                    width: 25,
                                    height: 25,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          _colors.top,
                                          _colors.bot,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.verified_user,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Verified",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 13,
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
              width: size.width,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.all(0),
                    title: const Text("Country"),
                    subtitle: Text(
                      loggedUser!.country!,
                    ),
                  ),
                  const ListTile(
                    contentPadding: EdgeInsets.all(0),
                    title: Text("Location"),
                    subtitle: Text(
                      "Catbalogan City",
                    ),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.all(0),
                    title: const Text("Skills"),
                    subtitle: SizedBox(
                      height: 50,
                      child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (_, i) =>
                              Chip(label: Text("Skill #${i + 1}")),
                          separatorBuilder: (_, i) => const SizedBox(
                                width: 10,
                              ),
                          itemCount: 5),
                    ),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.all(0),
                    title: const Text(
                      "Work Album",
                    ),
                    subtitle: Container(
                      height: 100,
                      width: size.width - 40,
                      child: Row(
                        children: [
                          Container(
                            width: 85,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: MaterialButton(
                              onPressed: () {},
                              height: 100,
                              child: Center(
                                child: Icon(
                                  Icons.add,
                                  color: _colors.mid,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (_, i) => Container(
                                width: 85,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              separatorBuilder: (_, i) => const SizedBox(
                                width: 10,
                              ),
                              itemCount: 5,
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
