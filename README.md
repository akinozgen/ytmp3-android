# Musiclick

<div align="center"><img src="playstore/main.jpg"></div>

YouTube mp3 download app. App language is currently Turkish.

## Installation

Use this command to get server code: `git submodule update --init --recursive`
[Server Readme](https://github.com/akinozgen/ytmp3-node/tree/e331f215de6ce60ec5c79350315c97067594fa4d#readme)

Then edit the server line at [lib/pages/home_page.dart:27](https://github.com/akinozgen/ytmp3-android/blob/c78505a124cac6300472f4e562a34383b658f0a9/lib/pages/home_page.dart#L27)

To run;
`flutter run android # or ios`

To build;
`flutter build apk # or whatever for ios is...`

To signed build;
* Generate a keystore first: `keytool -genkey -v -keystore my-release-key.jks -alias alias_name -keyalg RSA -keysize 2048 -validity 10000`
* Rename `android/key-example.properties` file to `android/key.properties` and fill it with your keystore information.
* Then build again.
