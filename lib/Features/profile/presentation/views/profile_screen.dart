import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salla_users/Features/home/data/models/user_model.dart';
import 'package:salla_users/Features/home/presentation/controller/provider/user_provider.dart';
import 'package:salla_users/Features/profile/presentation/views/widgets/custom_listtile.dart';
import 'package:salla_users/Features/profile/presentation/views/widgets/logout_button.dart';
import 'package:salla_users/Features/profile/presentation/views/widgets/please_text.dart';

import '../../../../Core/providers/theme_provider.dart';
import '../../../../Core/root_manager.dart';
import '../../../../Core/utiles/constance/assets_images.dart';
import '../../../../Core/utiles/constance/text_styles/subtitle_text.dart';
import '../../../../Core/utiles/constance/text_styles/title_text.dart';
import '../../../../Core/utiles/widgets/alert_widget.dart';
import '../../../../Core/utiles/widgets/my_app_method.dart';
import '../../../../Core/utiles/widgets/shimmer_appbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel? userModel;

  Future<void> fetchUserInfo() async {
    if (user == null) {
      //Navigator.pop(context);
      return;
    }
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      //MyAppMethods.loadingPage(context: context);
      userModel = await userProvider.fetchUserData();
      //setState(() {});
      print(userModel?.userEmail ?? 'no data');
      print('++++++++++++++++++++++');
    } catch (error) {
      MyAppMethods.showErrorORWarningDialog(
          context: context,
          subtitle: 'Error occured $error',
          fct: () {
            //Navigator.pop(context);
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
        appBar: shimmerAppBar(),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: user == null ? true : false,
                child: const PleaseText(),
              ),
              const SizedBox(
                height: 20,
              ),
              StreamBuilder(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    User user = snapshot.data;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        children: [
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).cardColor,
                              border: Border.all(
                                  color:
                                      Theme.of(context).colorScheme.background,
                                  width: 3),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: FancyShimmerImage(
                                imageUrl: user.photoURL ??
                                    "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png",
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 7,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TitlesTextWidget(
                                  label: user.displayName ?? 'No name'),
                              SubtitleTextWidget(
                                  label: user.email ?? 'No email'),
                            ],
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TitlesTextWidget(label: "General"),
                    CustomListTile(
                      imagePath: AssetsImages.orderSvg,
                      text: "All orders",
                      function: () {
                        Navigator.pushNamed(context, Routes.ordersRoute);
                      },
                    ),
                    CustomListTile(
                      imagePath: AssetsImages.wishlistSvg,
                      text: "Wishlist",
                      function: () {
                        Navigator.pushNamed(context, Routes.wishListRoute);
                      },
                    ),
                    CustomListTile(
                      imagePath: AssetsImages.recent,
                      text: "Viewed recently",
                      function: () {
                        Navigator.pushNamed(
                            context, Routes.viewedRecentlyRoute);
                      },
                    ),
                    CustomListTile(
                      imagePath: AssetsImages.address,
                      text: "Address",
                      function: () {},
                    ),
                    const Divider(
                      thickness: 1,
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    const TitlesTextWidget(label: "Settings"),
                    const SizedBox(
                      height: 7,
                    ),
                    SwitchListTile(
                      secondary: Image.asset(
                        AssetsImages.theme,
                        height: 30,
                      ),
                      title: Text(themeProvider.getIsDarkTheme
                          ? "Dark mode"
                          : "Light mode"),
                      value: themeProvider.getIsDarkTheme,
                      onChanged: (value) {
                        themeProvider.setIsDarkTheme(themeValue: value);
                      },
                    ),
                    const Divider(
                      thickness: 1,
                    ),
                  ],
                ),
              ),
              LogOutButton(
                function: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertWidget(
                        func1: () {
                          Navigator.pop(context);
                        },
                        func2: () async {
                          MyAppMethods.loadingPage(context: context);
                          await FirebaseAuth.instance.signOut().then((value) {
                            Navigator.pushReplacementNamed(
                              context,
                              Routes.loginRoute,
                            );
                          });
                        },
                        title: 'Are you sure ?',
                        subTitle1: 'NO',
                        subTitle2: 'YES',
                      );
                    },
                  );
                },
                title: user == null ? 'Login' : 'Logout',
                icon: user == null ? Icons.login : Icons.logout,
              )
            ],
          ),
        ));
  }
}
