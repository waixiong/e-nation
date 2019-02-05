import 'package:package_info/package_info.dart';

class Package{
  static PackageInfo packageInfo;

  static getVersion() async {
    packageInfo = await PackageInfo.fromPlatform();
  }
}