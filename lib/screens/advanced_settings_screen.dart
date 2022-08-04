import 'package:flutter/material.dart';
import 'package:flutter_weather/constants/constants.dart';
import 'package:flutter_weather/preferences/language.dart';
import 'package:flutter_weather/preferences/shared_prefs.dart';
import 'package:flutter_weather/screens/search_screen.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class AdvancedSettingsScreen extends StatefulWidget {
  @override
  _AdvancedSettingsScreenState createState() => _AdvancedSettingsScreenState();
}

class _AdvancedSettingsScreenState extends State<AdvancedSettingsScreen> {
  String version;

  TextEditingController weatherKeyTextController;

  String defaultLocationText = "";
  String owmApiKeyText = "";

  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    weatherKeyTextController.dispose();
    super.dispose();
  }

  Future<void> initialize() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var info = await SharedPrefs.getDefaultLocation();
    var userOwmKey = await SharedPrefs.getOpenWeatherAPIKey();

    weatherKeyTextController = TextEditingController(text: userOwmKey);

    weatherKeyTextController.addListener(() async {
      await SharedPrefs.setOpenWeatherAPIKey(
          weatherKeyTextController.text.trim());
    });

    setState(() {
      version = packageInfo.version;
      defaultLocationText = info[0];
      weatherKeyTextController.text = userOwmKey;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: TextButton(
          child: Icon(
            Icons.arrow_back,
            color: Theme.of(context).primaryColorLight,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Text(
          Language.getTranslation("advancedSettings"),
          style: TextStyle(color: Theme.of(context).primaryColorLight),
        ), //Language.getTranslation("advancedSettings")
        centerTitle: true,
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: Container(
          margin: EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                height: 80,
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: kBorderRadius),
                  color: Theme.of(context).cardColor,
                  child: Center(
                    child: ListTile(
                      onLongPress: () async {
                        await SharedPrefs.removeDefaultLocation();
                        await initialize();
                      },
                      onTap: () async {
                        var locationData = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchScreen(),
                          ),
                        );
                        //check if returned data != null
                        if (locationData != null) {
                          MapBoxPlace place = locationData;
                          double latitude = place.geometry.coordinates[1];
                          double longitude = place.geometry.coordinates[0];
                          String name = place.text;

                          await SharedPrefs.setDefaultLocation(
                              text: name, lat: latitude, long: longitude);
                          await initialize();
                          print("$name: $latitude, $longitude");
                        }
                      },
                      leading: Icon(
                        Icons.location_on_outlined,
                        color: Theme.of(context).primaryColorDark,
                      ),
                      title: Text(
                        Language.getTranslation("defaultLocation"),
                        style: TextStyle(
                          color: Theme.of(context).primaryColorLight,
                        ),
                      ),
                      subtitle: Text(
                        defaultLocationText ==
                                "Use a default location on app startup."
                            ? Language.getTranslation(
                                "useDefaultLocationOnStartup")
                            : "$defaultLocationText. ${Language.getTranslation("pressAndHold")}",
                        style:
                            TextStyle(color: Theme.of(context).primaryColorDark),
                      ),
                    ),
                  ),
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(borderRadius: kBorderRadius),
                color: Theme.of(context).cardColor,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.app_settings_alt_outlined,
                        color: Theme.of(context).primaryColorDark,
                      ),
                      title: Text(
                        Language.getTranslation("customAPIKeys"),
                        style: TextStyle(
                          color: Theme.of(context).primaryColorLight,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: TextField(
                        controller: weatherKeyTextController,
                        style: TextStyle(color: Theme.of(context).primaryColorLight),
                        decoration: InputDecoration(
                          hintText: Language.getTranslation("owmKey"),
                          hintStyle: TextStyle(
                            color: Theme.of(context).primaryColorDark,
                            fontSize: 15,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColorDark,
                                width: 2.0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blueAccent,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColorDark,
                                width: 2.0),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Center(
                        child: Text(
                          Language.getTranslation("customKeyInfo"),
                          style: TextStyle(
                              color: Theme.of(context).primaryColorDark),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        const url =
                            "https://home.openweathermap.org/users/sign_up";
                        if (await canLaunch(url)) {
                          await launch(url);
                        }
                      },
                      child: Text(
                        Language.getTranslation("getAKey"),
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          Language.getTranslation("getAKeyNote"),
                          style: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 80,
                child: Card(
                  child: Center(
                    child: ListTile(
                      title: Text(
                        Language.getTranslation("aboutPluvia"),
                        style: TextStyle(
                          color: Theme.of(context).primaryColorLight,
                        ),
                      ),
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationVersion: version,
                          applicationLegalese:
                              "Pluvia Weather is completely free and open source, and is licensed under GPLv3.",
                        );
                      },
                      leading: Icon(
                        Icons.more_horiz_outlined,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: kBorderRadius),
                  color: Theme.of(context).cardColor,
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    Language.getTranslation("thankYouForUsing"),
                    style: TextStyle(color: Theme.of(context).primaryColorDark),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
/*
var locationData = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchScreen(),
            ),
          );
          //check if returned data != null
          if (locationData != null) {
            MapBoxPlace place = locationData;
            double latitude = place.geometry.coordinates[1];
            double longitude = place.geometry.coordinates[0];
            String name = place.text;

            print("$name: $latitude, $longitude");
 */
