import 'dart:math';

class Images {
  static const String _base = 'assets/';

  // Sub-paths
  static const String _appCalendar = '${_base}app-calendar/';
  static const String _appSocial = '${_base}app-social/';
  static const String _brand = '${_base}brands/';
  static const String _browser = '${_base}browsers/';
  static const String _flags = '${_base}flags/';
  static const String _small = '${_base}small/';
  static const String _users = '${_base}users/';
  static const String _product = '${_base}product/';
  static const String _seller = '${_base}seller/';

  /// Returns a random image from the given list or fallback
  static String randomImage(List<String> images, {String? fallback}) {
    return images.isNotEmpty ? images[Random().nextInt(images.length)] : fallback ?? '';
  }

  // ----------------- App Calendar Images -----------------
  static const String facebook = '${_appCalendar}facebook.png';
  static const String googleAnalytics = '${_appCalendar}google-analytics.png';
  static const String googleChrome = '${_appCalendar}google-chrome.png';
  static const String googleMail = '${_appCalendar}google-mail.png';
  static const String googleMeet = '${_appCalendar}google-meet.png';
  static const String help1 = '${_appCalendar}help-1.png';
  static const String help2 = '${_appCalendar}help-2.png';
  static const String help3 = '${_appCalendar}help-3.png';
  static const String help4 = '${_appCalendar}help-4.png';
  static const String help5 = '${_appCalendar}help-5.png';
  static const String help6 = '${_appCalendar}help-6.png';
  static const String hubspot = '${_appCalendar}hubspot.png';
  static const String intercom = '${_appCalendar}intercom.png';
  static const String microsoftOutlook = '${_appCalendar}microsoft-outlook.png';
  static const String microsoftTeamConference = '${_appCalendar}microsoft-team-conference.png';
  static const String salesForce = '${_appCalendar}sales-force.png';
  static const String slack = '${_appCalendar}slack.png';
  static const String stripe = '${_appCalendar}stripe.png';
  static const String webHooks = '${_appCalendar}web-hooks.png';
  static const String zapier = '${_appCalendar}zapier.png';
  static const String zoom = '${_appCalendar}zoom.png';

  // ----------------- App Social Images -----------------
  static const String accWallpaper = '${_appSocial}acc-wallpaper.png';
  static final List<String> favourite = List.generate(4, (i) => '${_appSocial}favourite-$i.jpg');
  static final List<String> group = List.generate(9, (i) => '${_appSocial}group-$i.jpg');
  static const String memory = '${_appSocial}memory.png';
  static final List<String> post = List.generate(7, (i) => '${_appSocial}post-$i.jpg');
  static const String wallpaper = '${_appSocial}wallpaper.jpg';

  // ----------------- Brand Images -----------------

  static const String bitbucket = '${_brand}bitbucket.svg';
  static const String dribbble = '${_brand}dribbble.svg';
  static const String dropbox = '${_brand}dropbox.svg';
  static const String github = '${_brand}github.svg';
  static const String slackSvg = '${_brand}slack.svg';
  static const String dhl = '${_brand}dhl.png';
  static const String fedex = '${_brand}fedex.png';
  static const String ups = '${_brand}ups.png';

  // ----------------- Browser Images -----------------
  static const String brave = '${_browser}brave.png';
  static const String chrome = '${_browser}chrome.png';
  static const String firefox = '${_browser}firefox.png';
  static const String safari = '${_browser}safari.png';
  static const String web = '${_browser}web.png';

  // ----------------- Flag Images -----------------
  static const String french = '${_flags}french.jpg';
  static const String germany = '${_flags}germany.jpg';
  static const String italy = '${_flags}italy.jpg';
  static const String russia = '${_flags}russia.jpg';
  static const String spain = '${_flags}spain.jpg';
  static const String us = '${_flags}us.jpg';

  // ----------------- Small Images -----------------
  static final List<String> smallImages = List.generate(10, (i) => '${_small}img-${i + 1}.jpg');

  // ----------------- User Avatars -----------------
  static final List<String> product = List.generate(14, (i) => '${_product}p-$i.png');

  // ----------------- User Avatars -----------------
  static final List<String> userAvatars = List.generate(12, (i) => '${_users}avatar-${i + 1}.jpg');
  static const String chat = '${_users}chat.jpg';
  // static const String dummyAvatar = '${_users}dummy-avatar.jpg';

  // ----------------- Sellers -----------------
  static const String dyson = '${_seller}dyson.svg';
  static const String gopro = '${_seller}gopro.svg';
  static const String hAndM = '${_seller}h&m.svg';
  static const String huawei = '${_seller}huawei.svg';
  static const String nike = '${_seller}nike.svg';
  static const String rolex = '${_seller}rolex.svg';
  static const String thenorthface = '${_seller}thenorthface.svg';
  static const String zara = '${_seller}zara.svg';

  // ----------------- Other -----------------
  static const String lightLogo = '${_base}logo-light.png';
  static const String darkLogo = '${_base}logo-dark.png';
  static const String smLogo = '${_base}logo-sm.png';
}
