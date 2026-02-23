import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleStorageKey = '__locale_key__';

class FFLocalizations {
  FFLocalizations(this.locale);

  final Locale locale;

  static FFLocalizations of(BuildContext context) =>
      Localizations.of<FFLocalizations>(context, FFLocalizations)!;

  static List<String> languages() => ['en', 'te', 'hi'];

  static late SharedPreferences _prefs;
  static Future initialize() async =>
      _prefs = await SharedPreferences.getInstance();
  static Future storeLocale(String locale) =>
      _prefs.setString(_kLocaleStorageKey, locale);
  static Locale? getStoredLocale() {
    final locale = _prefs.getString(_kLocaleStorageKey);
    return locale != null && locale.isNotEmpty ? createLocale(locale) : null;
  }

  String get languageCode => locale.toString();
  String? get languageShortCode =>
      _languagesWithShortCode.contains(locale.toString())
          ? '${locale.toString()}_short'
          : null;
  int get languageIndex => languages().contains(languageCode)
      ? languages().indexOf(languageCode)
      : 0;

  String getText(String key) {
    final translations = kTranslationsMap[key] ?? {};
    return translations[locale.toString()] ??
        translations[locale.languageCode] ??
        '';
  }

  String getVariableText({
    String? enText = '',
    String? teText = '',
    String? hiText = '',
  }) =>
      [enText, teText, hiText][languageIndex] ?? '';

  static const Set<String> _languagesWithShortCode = {
    'ar',
    'az',
    'ca',
    'cs',
    'da',
    'de',
    'dv',
    'en',
    'es',
    'et',
    'fi',
    'fr',
    'gr',
    'he',
    'hi',
    'hu',
    'it',
    'km',
    'ku',
    'mn',
    'ms',
    'no',
    'pt',
    'ro',
    'ru',
    'rw',
    'sv',
    'th',
    'uk',
    'vi',
  };
}

/// Used if the locale is not supported by GlobalMaterialLocalizations.
class FallbackMaterialLocalizationDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<MaterialLocalizations> load(Locale locale) async =>
      SynchronousFuture<MaterialLocalizations>(
        const DefaultMaterialLocalizations(),
      );

  @override
  bool shouldReload(FallbackMaterialLocalizationDelegate old) => false;
}

/// Used if the locale is not supported by GlobalCupertinoLocalizations.
class FallbackCupertinoLocalizationDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      SynchronousFuture<CupertinoLocalizations>(
        const DefaultCupertinoLocalizations(),
      );

  @override
  bool shouldReload(FallbackCupertinoLocalizationDelegate old) => false;
}

class FFLocalizationsDelegate extends LocalizationsDelegate<FFLocalizations> {
  const FFLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<FFLocalizations> load(Locale locale) =>
      SynchronousFuture<FFLocalizations>(FFLocalizations(locale));

  @override
  bool shouldReload(FFLocalizationsDelegate old) => false;
}

Locale createLocale(String language) => language.contains('_')
    ? Locale.fromSubtags(
        languageCode: language.split('_').first,
        scriptCode: language.split('_').last,
      )
    : Locale(language);

bool _isSupportedLocale(Locale locale) {
  final language = locale.toString();
  return FFLocalizations.languages().contains(
    language.endsWith('_')
        ? language.substring(0, language.length - 1)
        : language,
  );
}

final kTranslationsMap = <Map<String, Map<String, String>>>[
  // login
  {
    '0wqdgogt': {
      'en': 'Start your journey – enter your phone number',
      'hi': 'अपनी यात्रा शुरू करें - अपना फ़ोन नंबर दर्ज करें',
      'te': 'మీ ప్రయాణాన్ని ప్రారంభించండి - మీ ఫోన్ నంబర్‌ను నమోదు చేయండి',
    },
    'lu0ku0g6': {
      'en': 'We\'ll send you a code to verify your number',
      'hi': 'हम आपको आपका नंबर सत्यापित करने के लिए एक कोड भेजेंगे',
      'te': 'మీ నంబర్‌ను ధృవీకరించడానికి మేము మీకు ఒక కోడ్‌ను పంపుతాము.',
    },
    'kd9srmop': {
      'en': 'Phone number',
      'hi': 'फ़ोन नंबर',
      'te': 'ఫోన్ నంబర్',
    },
    '398um26d': {
      'en': 'ENTER YOUR NUMBER',
      'hi': 'अपना नंबर दर्ज करें',
      'te': 'మీ నంబర్‌ను నమోదు చేయండి',
    },
    'm21mv0lk': {
      'en': 'SEND OTP',
      'hi': 'ओटीपी भेजें',
      'te': 'OTP పంపండి',
    },
    'hczr77o0': {
      'en': 'or connect with',
      'hi': 'या से जुड़ें',
      'te': 'లేదా కనెక్ట్ అవ్వండి',
    },
    'login0001': {
      'en': 'Welcome Partner,',
      'hi': 'स्वागत है, पार्टनर,',
      'te': 'స్వాగతం, భాగస్వామి,',
    },
    'login0002': {
      'en': "Let's get you on the road.",
      'hi': 'चलिए आपको सड़क पर ले चलते हैं।',
      'te': 'మిమ్మల్ని రోడ్డుపైకి తీసుకెళ్దాం.',
    },
    'login0003': {
      'en': 'Enter Mobile Number',
      'hi': 'मोबाइल नंबर दर्ज करें',
      'te': 'మొబైల్ నంబర్ నమోదు చేయండి',
    },
    'login0004': {
      'en': 'Mobile Number',
      'hi': 'मोबाइल नंबर',
      'te': 'మొబైల్ నంబర్',
    },
    'login0005': {
      'en': 'Get OTP',
      'hi': 'OTP प्राप्त करें',
      'te': 'OTP పొందండి',
    },
    'login0006': {
      'en': 'By continuing, you agree to our\n',
      'hi': 'जारी रखने पर, आप हमारी\n',
      'te': 'కొనసాగించడం ద్వారా, మీరు మా\n',
    },
    'login0007': {
      'en': 'Terms of Service',
      'hi': 'सेवा की शर्तें',
      'te': 'సేవా నిబంధనలు',
    },
    'login0008': {
      'en': ' & ',
      'hi': ' और ',
      'te': ' మరియు ',
    },
    'login0009': {
      'en': 'Privacy Policy',
      'hi': 'गोपनीयता नीति',
      'te': 'గోప్యతా విధానం',
    },
    'login0010': {
      'en':
          'Verification Required: Please enter your mobile number to complete registration.',
      'hi':
          'सत्यापन आवश्यक: पंजीकरण पूरा करने के लिए अपना मोबाइल नंबर दर्ज करें।',
      'te':
          'ధృవీకరణ అవసరం: రిజిస్ట్రేషన్ పూర్తి చేయడానికి మీ మొబైల్ నంబర్ నమోదు చేయండి.',
    },
    'login0011': {
      'en': 'Please enter a valid 10-digit mobile number.',
      'hi': 'कृपया 10 अंकों का मान्य मोबाइल नंबर दर्ज करें।',
      'te': 'దయచేసి చెల్లుబాటు అయ్యే 10 అంకెల మొబైల్ నంబర్ నమోదు చేయండి.',
    },
    'login0012': {
      'en': '+91',
      'hi': '+91',
      'te': '+91',
    },
  },
  // otpverification
  {
    'ujhimmtb': {
      'en': 'Enter the OTP to continue.',
      'hi': 'जारी रखने के लिए OTP दर्ज करें.',
      'te': 'కొనసాగించడానికి OTP ని నమోదు చేయండి.',
    },
    'xupvugn4': {
      'en': 'We\'ve sent you a 6-digit code – check your messages',
      'hi': 'हमने आपको एक 6-अंकीय कोड भेजा है - अपने संदेश देखें',
      'te': 'మేము మీకు 6-అంకెల కోడ్‌ను పంపాము – మీ సందేశాలను తనిఖీ చేయండి',
    },
    'f9214evl': {
      'en': 'RESEND OTP',
      'hi': 'OTP पुनः भेजें',
      'te': 'OTP ని మళ్ళీ పంపండి',
    },
    'k9o36d8i': {
      'en': 'VERIFY',
      'hi': 'सत्यापित करें',
      'te': 'ధృవీకరించండి',
    },
    'duko62qy': {
      'en': 'Verification',
      'hi': 'सत्यापन',
      'te': 'ధృవీకరణ',
    },
    'otpv0001': {
      'en': 'Enter the code we sent you.',
      'hi': 'हमने आपको जो कोड भेजा है उसे दर्ज करें।',
      'te': 'మేము పంపిన కోడ్‌ను నమోదు చేయండి.',
    },
    'otpv0002': {
      'en': 'Enter the 6-digit OTP sent to',
      'hi': 'भेजा गया 6-अंकीय OTP दर्ज करें',
      'te': 'పంపిన 6-అంకెల OTPను నమోదు చేయండి',
    },
    'otpv0003': {
      'en': 'Verify & Continue',
      'hi': 'सत्यापित करें और जारी रखें',
      'te': 'ధృవీకరించి కొనసాగించండి',
    },
    'otpv0004': {
      'en': "Didn't receive code?",
      'hi': 'कोड नहीं मिला?',
      'te': 'కోడ్ రాలేదా?',
    },
    'otpv0005': {
      'en': 'Resend',
      'hi': 'पुनः भेजें',
      'te': 'మళ్లీ పంపండి',
    },
    'otpv0006': {
      'en': 'Resend in',
      'hi': 'फिर से भेजें',
      'te': 'మళ్లీ పంపండి',
    },
    'otpv0007': {
      'en': 'OTP Resent Successfully!',
      'hi': 'OTP सफलतापूर्वक फिर से भेजा गया!',
      'te': 'OTP విజయవంతంగా మళ్లీ పంపబడింది!',
    },
    'otpv0008': {
      'en': 'Failed to resend OTP',
      'hi': 'OTP फिर से भेजने में विफल',
      'te': 'OTP మళ్లీ పంపడం విఫలమైంది',
    },
    'otpv0009': {
      'en': 'Please enter a valid 6-digit OTP.',
      'hi': 'कृपया एक मान्य 6-अंकीय OTP दर्ज करें।',
      'te': 'దయచేసి చెల్లుబాటు అయ్యే 6-అంకెల OTPని నమోదు చేయండి.',
    },
    'otpv0010': {
      'en': 'Verification Failed:',
      'hi': 'सत्यापन विफल:',
      'te': 'ధృవీకరణ విఫలమైంది:',
    },
  },
  // language_select
  {
    'langsel0001': {
      'en': 'Choose your language',
      'hi': 'अपनी भाषा चुनें',
      'te': 'మీ భాషను ఎంచుకోండి',
    },
    'langsel0002': {
      'en': 'Select the language you want to use.',
      'hi': 'आप उपयोग करना चाहते हैं वह भाषा चुनें।',
      'te': 'మీరు ఉపయోగించాలనుకునే భాషను ఎంచుకోండి.',
    },
    'langsel0003': {
      'en': 'Select language',
      'hi': 'भाषा चुनें',
      'te': 'భాషను ఎంచుకోండి',
    },
    'langsel0004': {
      'en': 'English',
      'hi': 'अंग्रेज़ी',
      'te': 'ఇంగ్లీష్',
    },
    'langsel0005': {
      'en': 'Hindi',
      'hi': 'हिन्दी',
      'te': 'హిందీ',
    },
    'langsel0006': {
      'en': 'Telugu',
      'hi': 'तेलुगु',
      'te': 'తెలుగు',
    },
    'langsel0007': {
      'en': 'Continue',
      'hi': 'जारी रखें',
      'te': 'కొనసాగించండి',
    },
  },
  // menu_widget
  {
    'menu0001': {
      'en': 'Welcome Back',
      'hi': 'वापसी पर स्वागत है',
      'te': 'తిరిగి స్వాగతం',
    },
    'menu0002': {
      'en': 'Account',
      'hi': 'खाता',
      'te': 'ఖాతా',
    },
    'menu0003': {
      'en': 'Manage your profile',
      'hi': 'अपनी प्रोफ़ाइल प्रबंधित करें',
      'te': 'మీ ప్రొఫైల్‌ను నిర్వహించండి',
    },
    'menu0004': {
      'en': 'Earnings',
      'hi': 'कमाई',
      'te': 'ఆదాయాలు',
    },
    'menu0005': {
      'en': 'History & Bank transfer',
      'hi': 'इतिहास और बैंक ट्रांसफर',
      'te': 'చరిత్ర & బ్యాంక్ బదిలీ',
    },
    'menu0006': {
      'en': 'Incentives',
      'hi': 'प्रोत्साहन',
      'te': 'ప్రోత్సాహకాలు',
    },
    'menu0007': {
      'en': 'Know how you get paid',
      'hi': 'जानें कि आपको कैसे भुगतान मिलता है',
      'te': 'మీరు ఎలా చెల్లింపు పొందుతున్నారో తెలుసుకోండి',
    },
    'menu0008': {
      'en': 'Help',
      'hi': 'मदद',
      'te': 'సహాయం',
    },
    'menu0009': {
      'en': 'Support & Accident Insurance',
      'hi': 'सहायता और दुर्घटना बीमा',
      'te': 'మద్దతు & ప్రమాద బీమా',
    },
    'menu0010': {
      'en': 'Refer friends & earn ₹10 per ride',
      'hi': 'दोस्तों को रेफर करें और प्रति सवारी ₹10 कमाएं',
      'te': 'స్నేహితులను సిఫార్సు చేయండి & ప్రతి రైడ్‌కు ₹10 సంపాదించండి',
    },
    'menu0011': {
      'en': 'Refer Now',
      'hi': 'अभी रेफर करें',
      'te': 'ఇప్పుడే సిఫార్సు చేయండి',
    },
  },
  // privacypolicy
  {
    'xmkcjp48': {
      'en': 'Accept Terms & Review Privacy Notice',
      'hi': 'शर्तें स्वीकार करें और गोपनीयता सूचना की समीक्षा करें',
      'te': 'నిబంధనలను అంగీకరించి, గోప్యతా నోటీసును సమీక్షించండి',
    },
    '1hdp8y0l': {
      'en': 'By selecting \\"I Agree\\" below, I confirm that:',
      'hi': 'नीचे \\"मैं सहमत हूँ\\" का चयन करके, मैं पुष्टि करता/करती हूँ कि:',
      'te':
          'కింద \\"నేను అంగీకరిస్తున్నాను\\" ఎంచుకోవడం ద్వారా, నేను వీటిని నిర్ధారిస్తున్నాను:',
    },
    'xsmpe8lc': {
      'en': 'I have read and agree to the Terms of Use',
      'hi': 'मैंने उपयोग की शर्तें पढ़ ली हैं और उनसे सहमत हूँ',
      'te': 'నేను ఉపయోగ నిబంధనలను చదివి అంగీకరిస్తున్నాను.',
    },
    'zt7g0lt1': {
      'en': 'I acknowledge the Privacy Notice',
      'hi': 'मैं गोपनीयता सूचना को स्वीकार करता/करती हूँ',
      'te': 'నేను గోప్యతా నోటీసును అంగీకరిస్తున్నాను',
    },
    'esk52694': {
      'en': 'I am at least 18 years of age',
      'hi': 'मैं कम से कम 18 साल का हूँ',
      'te': 'నాకు కనీసం 18 సంవత్సరాలు నిండి ఉండాలి.',
    },
    'i1uu17n2': {
      'en': 'Agree terms and conditions',
      'hi': 'नियम और शर्तों से सहमत हों',
      'te': 'నిబంధనలు మరియు షరతులను అంగీకరించండి',
    },
    'xxge13d3': {
      'en': 'Additional Information',
      'hi': 'अतिरिक्त जानकारी',
      'te': 'అదనపు సమాచారం',
    },
    'ma5k2a5l': {
      'en':
          '• Your data will be processed in accordance with our Privacy Policy',
      'hi': '• आपका डेटा हमारी गोपनीयता नीति के अनुसार संसाधित किया जाएगा',
      'te': '• మీ డేటా మా గోప్యతా విధానానికి అనుగుణంగా ప్రాసెస్ చేయబడుతుంది.',
    },
    'ap3gdbuv': {
      'en': '• You can withdraw consent at any time by contacting support',
      'hi': '• आप किसी भी समय सहायता टीम से संपर्क करके सहमति वापस ले सकते हैं',
      'te':
          '• మీరు మద్దతును సంప్రదించడం ద్వారా ఎప్పుడైనా సమ్మతిని ఉపసంహరించుకోవచ్చు',
    },
    'i0augwch': {
      'en': '• Terms may be updated periodically with notice',
      'hi': '• शर्तों को समय-समय पर सूचना के साथ अद्यतन किया जा सकता है',
      'te': '• నిబంధనలు కాలానుగుణంగా నోటీసుతో నవీకరించబడవచ్చు.',
    },
    '8bd4c5yq': {
      'en': 'Need help?',
      'hi': 'मदद की ज़रूरत है?',
      'te': 'సహాయం కావాలి?',
    },
    'gzvrni3c': {
      'en': 'Contact Support',
      'hi': 'समर्थन से संपर्क करें',
      'te': 'మద్దతును సంప్రదించండి',
    },
    'x4yfngl0': {
      'en': 'Continue',
      'hi': 'जारी रखना',
      'te': 'కొనసాగించు',
    },
  },
  // serviceoptions
  {
    'xlfqyvqa': {
      'en': 'Comfortable Rides, Anytime',
      'hi': 'आरामदायक सवारी, कभी भी',
      'te': 'సౌకర్యవంతమైన రైడ్‌లు, ఎప్పుడైనా',
    },
    'o76sscog': {
      'en': 'Book a bike',
      'hi': 'बाइक बुक करें',
      'te': 'బైక్ బుక్ చేసుకోండి',
    },
    'p3js2d3q': {
      'en': 'Book a auto',
      'hi': 'ऑटो बुक करें',
      'te': 'ఆటో బుక్ చేసుకోండి',
    },
    'a1vegvac': {
      'en': 'Book a Cab',
      'hi': 'कैब बुक करें',
      'te': 'క్యాబ్ బుక్ చేసుకోండి',
    },
    'rnwdwckb': {
      'en': 'Services',
      'hi': 'सेवाएं',
      'te': 'సేవలు',
    },
    'bi51z7ga': {
      'en': 'Home',
      'hi': 'घर',
      'te': 'హొమ్ పేజ్',
    },
    'ebo27o5n': {
      'en': 'Services',
      'hi': 'सेवाएं',
      'te': 'సేవలు',
    },
    '7d51nyn6': {
      'en': 'History',
      'hi': 'इतिहास',
      'te': 'చరిత్ర',
    },
    'av1fdhh2': {
      'en': 'Account',
      'hi': 'खाता',
      'te': 'ఖాతా',
    },
    'g8fj5flo': {
      'en': 'Rideoptions',
      'hi': 'सवारी विकल्प',
      'te': 'రైడ్‌ఆప్షన్‌లు',
    },
  },
  // home
  {
    'nrjzvb2s': {
      'en': 'Today',
      'hi': 'आज',
      'te': 'ఈ రోజు',
    },
    'od11ng7s': {
      'en': '₹0.00',
      'hi': '',
      'te': '',
    },
    'lvps3bvl': {
      'en': '50%',
      'hi': '',
      'te': '',
    },
    'w3p04fqe': {
      'en': 'home',
      'hi': 'घर',
      'te': 'హోమ్',
    },
  },
  // AccountManagement
  {
    'lcjkk7vc': {
      'en': 'Go code Designers',
      'hi': '',
      'te': '',
    },
    'uwwd4cw4': {
      'en': 'Inbox',
      'hi': 'इनबॉक्स',
      'te': 'ఇన్‌బాక్స్',
    },
    'mc9wnk6s': {
      'en': 'Refer Friend',
      'hi': 'सेटिंग्स',
      'te': 'సెట్టింగులు',
    },
    'u3u05cev': {
      'en': 'Wallet',
      'hi': 'वॉलेट',
      'te': 'వాలెట్',
    },
    'kf80lpgb': {
      'en': 'Account',
      'hi': 'संदेशों',
      'te': 'సందేశాలు',
    },
    'gw6i4s9e': {
      'en': 'Help',
      'hi': 'कानूनी',
      'te': 'చట్టపరమైన',
    },
    'yvr6aj95': {
      'en': 'Privacy Policy',
      'hi': 'सेटिंग्स',
      'te': 'సెట్టింగులు',
    },
    'utfxvwam': {
      'en': 'Terms and  Conditions',
      'hi': 'सेटिंग्स',
      'te': 'సెట్టింగులు',
    },
    'p0413re4': {
      'en': 'Logout',
      'hi': 'लॉग आउट',
      'te': 'లాగ్ అవుట్',
    },
    '87zx8uve': {
      'en': 'Account',
      'hi': 'खाता',
      'te': 'ఖాతా',
    },
    'luv589l7': {
      'en': 'My Account',
      'hi': 'मेरा खाता',
      'te': 'నా ఖాతా',
    },
    'am0001': {
      'en': 'Select Language',
      'hi': 'भाषा चुनें',
      'te': 'భాష ఎంచుకోండి',
    },
    'am0002': {
      'en': 'App and voice will use this language',
      'hi': 'ऐप और वॉयस इस भाषा का उपयोग करेंगे',
      'te': 'యాప్ మరియు వాయిస్ ఈ భాషను ఉపయోగిస్తాయి',
    },
    'am0003': {
      'en': 'Language changed to %1',
      'hi': 'भाषा %1 में बदल दी गई',
      'te': 'భాష %1కి మార్చబడింది',
    },
    'am0004': {
      'en': 'Profile',
      'hi': 'प्रोफ़ाइल',
      'te': 'ప్రొఫైల్',
    },
    'am0005': {
      'en': 'Language',
      'hi': 'भाषा',
      'te': 'భాష',
    },
    'am0006': {
      'en': 'App & voice language',
      'hi': 'ऐप और वॉयस भाषा',
      'te': 'యాప్ మరియు వాయిస్ భాష',
    },
  },
  // document_upload_common
  {
    'doc0001': {
      'en': 'Front Side',
      'hi': 'आगे की तरफ',
      'te': 'ముందు వైపు',
    },
    'doc0002': {
      'en': 'Back Side',
      'hi': 'पीछे की तरफ',
      'te': 'వెనుక వైపు',
    },
    'doc0003': {
      'en': 'Front side uploaded!',
      'hi': 'आगे की तरफ अपलोड हो गया!',
      'te': 'ముందు వైపు అప్లోడ్ అయ్యింది!',
    },
    'doc0004': {
      'en': 'Back side uploaded!',
      'hi': 'पीछे की तरफ अपलोड हो गया!',
      'te': 'వెనుక వైపు అప్లోడ్ అయ్యింది!',
    },
    'doc0005': {
      'en': 'Front side removed',
      'hi': 'आगे की तरफ हटाया गया',
      'te': 'ముందు వైపు తొలగించబడింది',
    },
    'doc0006': {
      'en': 'Back side removed',
      'hi': 'पीछे की तरफ हटाया गया',
      'te': 'వెనుక వైపు తొలగించబడింది',
    },
    'doc0007': {
      'en': '✓ Verified and uploaded',
      'hi': '✓ सत्यापित और अपलोड',
      'te': '✓ ధృవీకరించి అప్లోడ్ చేయబడింది',
    },
    'doc0008': {
      'en': 'Image uploaded',
      'hi': 'इमेज अपलोड हुई',
      'te': 'చిత్రం అప్లోడ్ అయ్యింది',
    },
    'doc0009': {
      'en': 'Tap to upload %1',
      'hi': '%1 अपलोड करने के लिए टैप करें',
      'te': '%1 అప్లోడ్ చేయడానికి ట్యాప్ చేయండి',
    },
  },
  // common_guidelines
  {
    'guide0001': {
      'en': 'Important Guidelines',
      'hi': 'महत्वपूर्ण दिशानिर्देश',
      'te': 'ముఖ్య మార్గదర్శకాలు',
    },
    'guide0002': {
      'en': 'All four corners should be visible',
      'hi': 'चारों कोने दिखाई देने चाहिए',
      'te': 'నాలుగు మూలలు కనిపించాలి',
    },
    'guide0003': {
      'en': 'Avoid glare and shadows',
      'hi': 'चमक और छाया से बचें',
      'te': 'ప్రతిబింబం మరియు నీడలు నివారించండి',
    },
    'guide0004': {
      'en': '✓ Images persist after app restart',
      'hi': '✓ ऐप रीस्टार्ट के बाद भी इमेज रहेंगी',
      'te': '✓ యాప్ రీస్టార్ట్ తర్వాత కూడా చిత్రాలు ఉంటాయి',
    },
  },
  // common_badges_upload
  {
    'badge0001': {
      'en': 'Saved',
      'hi': 'सहेजा गया',
      'te': 'సేవ్ చేయబడింది',
    },
    'upload0001': {
      'en': 'Photo uploaded successfully! ✓',
      'hi': 'फोटो सफलतापूर्वक अपलोड हुई! ✓',
      'te': 'ఫోటో విజయవంతంగా అప్లోడ్ అయ్యింది! ✓',
    },
    'upload0002': {
      'en': 'Tap to upload',
      'hi': 'अपलोड करने के लिए टैप करें',
      'te': 'అప్లోడ్ చేయడానికి ట్యాప్ చేయండి',
    },
    'upload0003': {
      'en': 'Tap to upload photo',
      'hi': 'फोटो अपलोड करने के लिए टैप करें',
      'te': 'ఫోటో అప్లోడ్ చేయడానికి ట్యాప్ చేయండి',
    },
    'upload0004': {
      'en': 'Camera or Gallery',
      'hi': 'कैमरा या गैलरी',
      'te': 'కెమేరా లేదా గ్యాలరీ',
    },
    'upload0005': {
      'en': 'Uploaded',
      'hi': 'अपलोड हुआ',
      'te': 'అప్లోడ్ అయ్యింది',
    },
    'upload0006': {
      'en': 'Failed to load image',
      'hi': 'इमेज लोड नहीं हो सकी',
      'te': 'చిత్రం లోడ్ కాలేకపోయింది',
    },
    'upload0007': {
      'en': 'Remove image',
      'hi': 'इमेज हटाएं',
      'te': 'చిత్రాన్ని తొలగించండి',
    },
    'upload0008': {
      'en': 'Photo removed',
      'hi': 'फोटो हटाई गई',
      'te': 'ఫోటో తొలగించబడింది',
    },
  },
  // driving_license
  {
    'dl0001': {
      'en': 'Upload Driving License',
      'hi': 'ड्राइविंग लाइसेंस अपलोड करें',
      'te': 'డ్రైవింగ్ లైసెన్స్ అప్లోడ్ చేయండి',
    },
    'dl0002': {
      'en': 'Auto-fill with OCR',
      'hi': 'OCR से स्वतः भरें',
      'te': 'OCR తో ఆటో-ఫిల్',
    },
    'dl0003': {
      'en': 'Upload front side to auto-fill DL number',
      'hi': 'DL नंबर स्वतः भरने के लिए आगे की तरफ अपलोड करें',
      'te': 'DL నంబర్ ఆటో-ఫిల్ కోసం ముందు వైపు అప్లోడ్ చేయండి',
    },
    'dl0004': {
      'en': 'Photo & License number visible',
      'hi': 'फोटो और लाइसेंस नंबर दिखना चाहिए',
      'te': 'ఫోటో మరియు లైసెన్స్ నంబర్ కనిపించాలి',
    },
    'dl0005': {
      'en': 'Address & validity details visible',
      'hi': 'पता और वैधता विवरण दिखना चाहिए',
      'te': 'చిరునామా మరియు చెల్లుబాటు వివరాలు కనిపించాలి',
    },
    'dl0006': {
      'en': 'License Number',
      'hi': 'लाइसेंस नंबर',
      'te': 'లైసెన్స్ నంబర్',
    },
    'dl0007': {
      'en': 'Auto-filled',
      'hi': 'स्वतः भरा गया',
      'te': 'ఆటో-ఫిల్ అయ్యింది',
    },
    'dl0008': {
      'en': 'KA01 20200001234',
      'hi': 'KA01 20200001234',
      'te': 'KA01 20200001234',
    },
    'dl0009': {
      'en': 'Auto-filled from photo or enter manually',
      'hi': 'फोटो से स्वतः भरा गया या मैन्युअली दर्ज करें',
      'te': 'ఫోటో నుండి ఆటో-ఫిల్ లేదా మాన్యువల్‌గా నమోదు చేయండి',
    },
    'dl0010': {
      'en': 'License number verified ✓',
      'hi': 'लाइसेंस नंबर सत्यापित ✓',
      'te': 'లైసెన్స్ నంబర్ ధృవీకరించబడింది ✓',
    },
    'dl0011': {
      'en': 'License Expiry Date',
      'hi': 'लाइसेंस की समाप्ति तिथि',
      'te': 'లైసెన్స్ గడువు ముగింపు తేదీ',
    },
    'dl0012': {
      'en': 'YYYY-MM-DD or DD/MM/YYYY',
      'hi': 'YYYY-MM-DD या DD/MM/YYYY',
      'te': 'YYYY-MM-DD లేదా DD/MM/YYYY',
    },
    'dl0013': {
      'en': 'Upload both front and back sides',
      'hi': 'आगे और पीछे दोनों तरफ अपलोड करें',
      'te': 'ముందు మరియు వెనుక రెండు వైపులు అప్లోడ్ చేయండి',
    },
    'dl0014': {
      'en': 'License number must be clearly readable',
      'hi': 'लाइसेंस नंबर स्पष्ट रूप से दिखाई देना चाहिए',
      'te': 'లైసెన్స్ నంబర్ స్పష్టంగా కనిపించాలి',
    },
    'dl0015': {
      'en': 'OCR will auto-fill DL number from photo',
      'hi': 'OCR फोटो से DL नंबर स्वतः भरेगा',
      'te': 'OCR ఫోటో నుండి DL నంబర్ ఆటో-ఫిల్ చేస్తుంది',
    },
    'dl0016': {
      'en': 'Please upload front side of license',
      'hi': 'कृपया लाइसेंस की आगे वाली तरफ अपलोड करें',
      'te': 'దయచేసి లైసెన్స్ ముందు వైపు అప్లోడ్ చేయండి',
    },
    'dl0017': {
      'en': 'Please upload back side of license',
      'hi': 'कृपया लाइसेंस की पीछे वाली तरफ अपलोड करें',
      'te': 'దయచేసి లైసెన్స్ వెనుక వైపు అప్లోడ్ చేయండి',
    },
    'dl0018': {
      'en': 'License verified and sent to backend!',
      'hi': 'लाइसेंस सत्यापित हुआ और बैकएंड को भेजा गया!',
      'te': 'లైసెన్స్ ధృవీకరించబడింది మరియు బ్యాకెండ్‌కు పంపబడింది!',
    },
    'dl0019': {
      'en': 'Could not update license. Please try again.',
      'hi': 'लाइसेंस अपडेट नहीं हो सका। कृपया फिर कोशिश करें।',
      'te': 'లైసెన్స్ అప్డేట్ చేయలేకపోయాము. దయచేసి మళ్లీ ప్రయత్నించండి.',
    },
    'dl0020': {
      'en': 'Network error. Please try again.',
      'hi': 'नेटवर्क त्रुटि। कृपया फिर कोशिश करें।',
      'te': 'నెట్‌వర్క్ లోపం. దయచేసి మళ్లీ ప్రయత్నించండి.',
    },
    'dl0021': {
      'en': 'License saved. Will be sent with registration.',
      'hi': 'लाइसेंस सेव हो गया। रजिस्ट्रेशन के साथ भेजा जाएगा।',
      'te': 'లైసెన్స్ సేవ్ అయ్యింది. రిజిస్ట్రేషన్‌తో పంపబడుతుంది.',
    },
    'dl0022': {
      'en': 'Sending...',
      'hi': 'भेजा जा रहा है...',
      'te': 'పంపుతోంది...',
    },
    'dl0023': {
      'en': 'DL Number auto-filled: %1',
      'hi': 'DL नंबर स्वतः भरा गया: %1',
      'te': 'DL నంబర్ ఆటో-ఫిల్ అయ్యింది: %1',
    },
    'dl0024': {
      'en': 'Could not detect DL number. Please enter manually.',
      'hi': 'DL नंबर नहीं मिला। कृपया मैन्युअली दर्ज करें।',
      'te': 'DL నంబర్ గుర్తించబడలేదు. దయచేసి మాన్యువల్‌గా నమోదు చేయండి.',
    },
    'dl0025': {
      'en': 'OCR failed. Please enter DL number manually.',
      'hi': 'OCR असफल। कृपया DL नंबर मैन्युअली दर्ज करें।',
      'te': 'OCR విఫలమైంది. దయచేసి DL నంబర్ మాన్యువల్‌గా నమోదు చేయండి.',
    },
    'dl0026': {
      'en': 'Reading DL Number...',
      'hi': 'DL नंबर पढ़ा जा रहा है...',
      'te': 'DL నంబర్ చదువుతోంది...',
    },
    'dl0027': {
      'en': 'Please enter license number',
      'hi': 'कृपया लाइसेंस नंबर दर्ज करें',
      'te': 'దయచేసి లైసెన్స్ నంబర్ నమోదు చేయండి',
    },
    'dl0028': {
      'en': 'Invalid license format (e.g., KA0120200001234)',
      'hi': 'अमान्य लाइसेंस फॉर्मेट (उदा., KA0120200001234)',
      'te': 'చెల్లని లైసెన్స్ ఫార్మాట్ (ఉదా., KA0120200001234)',
    },
    'dl0029': {
      'en': 'License must be 15 characters',
      'hi': 'लाइसेंस 15 अक्षरों का होना चाहिए',
      'te': 'లైసెన్స్ 15 అక్షరాలు ఉండాలి',
    },
  },
  // aadhaar_upload
  {
    'aad0001': {
      'en': 'Upload Aadhaar Card',
      'hi': 'आधार कार्ड अपलोड करें',
      'te': 'ఆధార్ కార్డ్ అప్లోడ్ చేయండి',
    },
    'aad0002': {
      'en': 'Both sides required',
      'hi': 'दोनों तरफ आवश्यक',
      'te': 'రెండు వైపులు అవసరం',
    },
    'aad0003': {
      'en': 'Photo & Aadhaar number visible',
      'hi': 'फोटो और आधार नंबर दिखना चाहिए',
      'te': 'ఫోటో మరియు ఆధార్ నంబర్ కనిపించాలి',
    },
    'aad0004': {
      'en': 'Address details visible',
      'hi': 'पता विवरण दिखना चाहिए',
      'te': 'చిరునామా వివరాలు కనిపించాలి',
    },
    'aad0005': {
      'en': 'Aadhaar Number',
      'hi': 'आधार नंबर',
      'te': 'ఆధార్ నంబర్',
    },
    'aad0006': {
      'en': 'XXXX XXXX XXXX',
      'hi': 'XXXX XXXX XXXX',
      'te': 'XXXX XXXX XXXX',
    },
    'aad0007': {
      'en': 'Enter 12-digit Aadhaar number',
      'hi': '12 अंकों का आधार नंबर दर्ज करें',
      'te': '12 అంకెల ఆధార్ నంబర్ నమోదు చేయండి',
    },
    'aad0008': {
      'en': 'Aadhaar number verified ✓',
      'hi': 'आधार नंबर सत्यापित ✓',
      'te': 'ఆధార్ నంబర్ ధృవీకరించబడింది ✓',
    },
    'aad0009': {
      'en': 'Text should be clearly readable',
      'hi': 'टेक्स्ट स्पष्ट रूप से पढ़ने योग्य होना चाहिए',
      'te': 'పాఠ్యం స్పష్టంగా చదవగలిగేలా ఉండాలి',
    },
    'aad0010': {
      'en': 'Verified stamp appears after upload',
      'hi': 'अपलोड के बाद सत्यापित स्टैम्प दिखेगा',
      'te': 'అప్లోడ్ తర్వాత ధృవీకరించిన ముద్ర కనిపిస్తుంది',
    },
    'aad0011': {
      'en': 'Please upload front side',
      'hi': 'कृपया आगे की तरफ अपलोड करें',
      'te': 'దయచేసి ముందు వైపు అప్లోడ్ చేయండి',
    },
    'aad0012': {
      'en': 'Please upload back side',
      'hi': 'कृपया पीछे की तरफ अपलोड करें',
      'te': 'దయచేసి వెనుక వైపు అప్లోడ్ చేయండి',
    },
    'aad0013': {
      'en': 'Aadhaar verification completed!',
      'hi': 'आधार सत्यापन पूरा हुआ!',
      'te': 'ఆధార్ ధృవీకరణ పూర్తైంది!',
    },
    'aad0014': {
      'en': 'Please enter Aadhaar number',
      'hi': 'कृपया आधार नंबर दर्ज करें',
      'te': 'దయచేసి ఆధార్ నంబర్ నమోదు చేయండి',
    },
    'aad0015': {
      'en': 'Aadhaar must contain only numbers',
      'hi': 'आधार में केवल नंबर होने चाहिए',
      'te': 'ఆధార్‌లో సంఖ్యలు మాత్రమే ఉండాలి',
    },
    'aad0016': {
      'en': 'Aadhaar must be 12 digits',
      'hi': 'आधार 12 अंकों का होना चाहिए',
      'te': 'ఆధార్ 12 అంకెలుగా ఉండాలి',
    },
    'aad0017': {
      'en': 'Invalid Aadhaar number',
      'hi': 'अमान्य आधार नंबर',
      'te': 'చెల్లని ఆధార్ నంబర్',
    },
  },
  // pan_upload
  {
    'pan0001': {
      'en': 'Upload PAN Card',
      'hi': 'पैन कार्ड अपलोड करें',
      'te': 'పాన్ కార్డ్ అప్లోడ్ చేయండి',
    },
    'pan0002': {
      'en': 'Front side with photo',
      'hi': 'फोटो वाली आगे की तरफ',
      'te': 'ఫోటో ఉన్న ముందు వైపు',
    },
    'pan0003': {
      'en': 'PAN Card',
      'hi': 'पैन कार्ड',
      'te': 'పాన్ కార్డ్',
    },
    'pan0004': {
      'en': 'Clear photo with all details visible',
      'hi': 'सभी विवरण दिखने वाली स्पष्ट फोटो',
      'te': 'అన్ని వివరాలు కనిపించే స్పష్టమైన ఫోటో',
    },
    'pan0005': {
      'en': 'PAN card uploaded!',
      'hi': 'पैन कार्ड अपलोड हो गया!',
      'te': 'పాన్ కార్డ్ అప్లోడ్ అయ్యింది!',
    },
    'pan0006': {
      'en': 'PAN card removed',
      'hi': 'पैन कार्ड हटाया गया',
      'te': 'పాన్ కార్డ్ తొలగించబడింది',
    },
    'pan0007': {
      'en': 'PAN Number',
      'hi': 'पैन नंबर',
      'te': 'పాన్ నంబర్',
    },
    'pan0008': {
      'en': 'ABCDE1234F',
      'hi': 'ABCDE1234F',
      'te': 'ABCDE1234F',
    },
    'pan0009': {
      'en': 'Enter 10-character PAN number',
      'hi': '10 अक्षरों का पैन नंबर दर्ज करें',
      'te': '10 అక్షరాల పాన్ నంబర్ నమోదు చేయండి',
    },
    'pan0010': {
      'en': 'PAN number verified ✓',
      'hi': 'पैन नंबर सत्यापित ✓',
      'te': 'పాన్ నంబర్ ధృవీకరించబడింది ✓',
    },
    'pan0011': {
      'en': 'Upload clear photo of PAN card',
      'hi': 'पैन कार्ड की स्पष्ट फोटो अपलोड करें',
      'te': 'పాన్ కార్డ్ స్పష్టమైన ఫోటో అప్లోడ్ చేయండి',
    },
    'pan0012': {
      'en': 'Photo and details must be readable',
      'hi': 'फोटो और विवरण पढ़ने योग्य होने चाहिए',
      'te': 'ఫోటో మరియు వివరాలు చదవగలిగేలా ఉండాలి',
    },
    'pan0013': {
      'en': 'PAN number format: ABCDE1234F',
      'hi': 'पैन नंबर फॉर्मेट: ABCDE1234F',
      'te': 'పాన్ నంబర్ ఫార్మాట్: ABCDE1234F',
    },
    'pan0014': {
      'en': '✓ Data persists after app restart',
      'hi': '✓ ऐप रीस्टार्ट के बाद भी डेटा रहेगा',
      'te': '✓ యాప్ రీస్టార్ట్ తర్వాత కూడా డేటా ఉంటుంది',
    },
    'pan0015': {
      'en': 'Please upload PAN card',
      'hi': 'कृपया पैन कार्ड अपलोड करें',
      'te': 'దయచేసి పాన్ కార్డ్ అప్లోడ్ చేయండి',
    },
    'pan0016': {
      'en': 'PAN verification completed!',
      'hi': 'पैन सत्यापन पूरा हुआ!',
      'te': 'పాన్ ధృవీకరణ పూర్తైంది!',
    },
    'pan0017': {
      'en': 'Please enter PAN number',
      'hi': 'कृपया पैन नंबर दर्ज करें',
      'te': 'దయచేసి పాన్ నంబర్ నమోదు చేయండి',
    },
    'pan0018': {
      'en': 'PAN must be 10 characters',
      'hi': 'पैन 10 अक्षरों का होना चाहिए',
      'te': 'పాన్ 10 అక్షరాలు ఉండాలి',
    },
    'pan0019': {
      'en': 'Invalid PAN format (e.g., ABCDE1234F)',
      'hi': 'अमान्य पैन फॉर्मेट (उदा., ABCDE1234F)',
      'te': 'చెల్లని పాన్ ఫార్మాట్ (ఉదా., ABCDE1234F)',
    },
    'pan0020': {
      'en': 'Invalid PAN number',
      'hi': 'अमान्य पैन नंबर',
      'te': 'చెల్లని పాన్ నంబర్',
    },
  },
  // vehicle_image
  {
    'veh0001': {
      'en': 'Vehicle Details',
      'hi': 'वाहन विवरण',
      'te': 'వాహన వివరాలు',
    },
    'veh0002': {
      'en': 'Vehicle Color',
      'hi': 'वाहन का रंग',
      'te': 'వాహన రంగు',
    },
    'veh0003': {
      'en': 'License Plate',
      'hi': 'लाइसेंस प्लेट',
      'te': 'లైసెన్స్ ప్లేట్',
    },
    'veh0004': {
      'en': 'e.g., AP01AB1234',
      'hi': 'उदा., AP01AB1234',
      'te': 'ఉదా., AP01AB1234',
    },
    'veh0005': {
      'en': 'Registration Number',
      'hi': 'पंजीकरण नंबर',
      'te': 'రిజిస్ట్రేషన్ నంబర్',
    },
    'veh0006': {
      'en': 'RC number',
      'hi': 'RC नंबर',
      'te': 'RC నంబర్',
    },
    'veh0007': {
      'en': 'Registration Date',
      'hi': 'पंजीकरण तिथि',
      'te': 'రిజిస్ట్రేషన్ తేదీ',
    },
    'veh0008': {
      'en': 'YYYY-MM-DD',
      'hi': 'YYYY-MM-DD',
      'te': 'YYYY-MM-DD',
    },
    'veh0009': {
      'en': 'Insurance Number',
      'hi': 'बीमा नंबर',
      'te': 'బీమా నంబర్',
    },
    'veh0010': {
      'en': 'Policy number',
      'hi': 'पॉलिसी नंबर',
      'te': 'పాలసీ నంబర్',
    },
    'veh0011': {
      'en': 'Insurance Expiry',
      'hi': 'बीमा समाप्ति',
      'te': 'బీమా గడువు',
    },
    'veh0012': {
      'en': 'Pollution Certificate Expiry',
      'hi': 'प्रदूषण प्रमाणपत्र समाप्ति',
      'te': 'కాలుష్య సర్టిఫికేట్ గడువు',
    },
    'veh0013': {
      'en': 'Vehicle Photo',
      'hi': 'वाहन की फोटो',
      'te': 'వాహన ఫోటో',
    },
    'veh0014': {
      'en': 'Pollution Certificate',
      'hi': 'प्रदूषण प्रमाणपत्र',
      'te': 'కాలుష్య సర్టిఫికేట్',
    },
    'veh0015': {
      'en': 'Insurance Document',
      'hi': 'बीमा दस्तावेज',
      'te': 'బీమా డాక్యుమెంట్',
    },
    'veh0016': {
      'en': 'Could not load vehicle types',
      'hi': 'वाहन प्रकार लोड नहीं हो सके',
      'te': 'వాహన రకాలను లోడ్ చేయలేకపోయాము',
    },
    'veh0017': {
      'en': 'No vehicle types available',
      'hi': 'कोई वाहन प्रकार उपलब्ध नहीं है',
      'te': 'వాహన రకాలు అందుబాటులో లేవు',
    },
    'veh0018': {
      'en': 'Selected: %1',
      'hi': 'चयनित: %1',
      'te': 'ఎంచుకున్నది: %1',
    },
    'veh0019': {
      'en': 'Vehicle Name',
      'hi': 'वाहन नाम',
      'te': 'వాహన పేరు',
    },
    'veh0020': {
      'en': 'Select make (e.g., Toyota, Honda)',
      'hi': 'मेक चुनें (जैसे, Toyota, Honda)',
      'te': 'మేక్ ఎంచుకోండి (ఉదా., Toyota, Honda)',
    },
    'veh0021': {
      'en': 'Vehicle Model',
      'hi': 'वाहन मॉडल',
      'te': 'వాహన మోడల్',
    },
    'veh0022': {
      'en': 'Select model (e.g., Camry, Civic)',
      'hi': 'मॉडल चुनें (जैसे, Camry, Civic)',
      'te': 'మోడల్ ఎంచుకోండి (ఉదా., Camry, Civic)',
    },
    'veh0023': {
      'en': 'Save Vehicle Details',
      'hi': 'वाहन विवरण सहेजें',
      'te': 'వాహన వివరాలు సేవ్ చేయండి',
    },
    'veh0024': {
      'en': '✓ Vehicle details saved successfully!',
      'hi': '✓ वाहन विवरण सफलतापूर्वक सहेजे गए!',
      'te': '✓ వాహన వివరాలు విజయవంతంగా సేవ్ అయ్యాయి!',
    },
    'veh0025': {
      'en': 'Please select vehicle type first (from Choose Vehicle)',
      'hi': 'कृपया पहले वाहन प्रकार चुनें (Choose Vehicle से)',
      'te': 'ముందుగా వాహన రకం ఎంచుకోండి (Choose Vehicle నుంచి)',
    },
    'veh0026': {
      'en': 'Please enter vehicle name',
      'hi': 'कृपया वाहन नाम दर्ज करें',
      'te': 'దయచేసి వాహన పేరు నమోదు చేయండి',
    },
    'veh0027': {
      'en': 'Please enter vehicle model',
      'hi': 'कृपया वाहन मॉडल दर्ज करें',
      'te': 'దయచేసి వాహన మోడల్ నమోదు చేయండి',
    },
    'veh0028': {
      'en': 'Please upload vehicle photo',
      'hi': 'कृपया वाहन की फोटो अपलोड करें',
      'te': 'దయచేసి వాహన ఫోటో అప్లోడ్ చేయండి',
    },
    'veh0029': {
      'en': 'Please upload pollution photo',
      'hi': 'कृपया प्रदूषण प्रमाणपत्र की फोटो अपलोड करें',
      'te': 'దయచేసి కాలుష్య సర్టిఫికేట్ ఫోటో అప్లోడ్ చేయండి',
    },
    'veh0030': {
      'en': 'Please upload insurance photo',
      'hi': 'कृपया बीमा दस्तावेज की फोटो अपलोड करें',
      'te': 'దయచేసి బీమా డాక్యుమెంట్ ఫోటో అప్లోడ్ చేయండి',
    },
  },
  // color_names
  {
    'color0001': {
      'en': 'White',
      'hi': 'सफेद',
      'te': 'తెలుపు',
    },
    'color0002': {
      'en': 'Black',
      'hi': 'काला',
      'te': 'నలుపు',
    },
    'color0003': {
      'en': 'Silver',
      'hi': 'सिल्वर',
      'te': 'వెండి',
    },
    'color0004': {
      'en': 'Red',
      'hi': 'लाल',
      'te': 'ఎరుపు',
    },
    'color0005': {
      'en': 'Blue',
      'hi': 'नीला',
      'te': 'నీలం',
    },
    'color0006': {
      'en': 'Grey',
      'hi': 'ग्रे',
      'te': 'బూడిద',
    },
  },
  // face_verify
  {
    'face0001': {
      'en': 'Profile photo captured!',
      'hi': 'प्रोफ़ाइल फोटो कैप्चर हो गई!',
      'te': 'ప్రొఫైల్ ఫోటో క్యాప్చర్ అయింది!',
    },
    'face0002': {
      'en': 'Camera error: %1',
      'hi': 'कैमरा त्रुटि: %1',
      'te': 'కెమెరా లోపం: %1',
    },
    'face0003': {
      'en': 'Take your profile photo',
      'hi': 'अपनी प्रोफ़ाइल फोटो लें',
      'te': 'మీ ప్రొఫైల్ ఫోటో తీసుకోండి',
    },
    'face0004': {
      'en': 'Live camera only - Fraud prevention',
      'hi': 'केवल लाइव कैमरा - धोखाधड़ी रोकथाम',
      'te': 'లైవ్ కెమెరా మాత్రమే - మోసాల నివారణ',
    },
    'face0005': {
      'en': 'Your profile photo helps others recognize you and builds trust with passengers.',
      'hi': 'आपकी प्रोफ़ाइल फोटो दूसरों को आपको पहचानने में मदद करती है और यात्रियों के साथ भरोसा बनाती है।',
      'te': 'మీ ప్రొఫైల్ ఫోటో ఇతరులకు మిమ్మల్ని గుర్తించడంలో సహాయం చేస్తుంది మరియు ప్రయాణికులతో నమ్మకం పెంచుతుంది.',
    },
    'face0006': {
      'en': 'Security Notice',
      'hi': 'सुरक्षा सूचना',
      'te': 'భద్రతా సూచన',
    },
    'face0007': {
      'en': 'For fraud prevention, you must take a live photo using your camera. Gallery photos are not allowed.',
      'hi': 'धोखाधड़ी रोकथाम के लिए, आपको कैमरे से लाइव फोटो लेनी होगी। गैलरी फोटो की अनुमति नहीं है।',
      'te': 'మోసాల నివారణ కోసం, మీరు కెమెరాతో లైవ్ ఫోటో తీయాలి. గ్యాలరీ ఫోటోలు అనుమతించబడవు.',
    },
    'face0008': {
      'en': 'Photo Guidelines',
      'hi': 'फोटो दिशानिर्देश',
      'te': 'ఫోటో మార్గదర్శకాలు',
    },
    'face0009': {
      'en': 'Make sure your face is clearly visible and well-lit',
      'hi': 'सुनिश्चित करें कि आपका चेहरा स्पष्ट और अच्छी तरह रोशन हो',
      'te': 'మీ ముఖం స్పష్టంగా మరియు వెలుతురుగా ఉండేలా చూసుకోండి',
    },
    'face0010': {
      'en': 'Remove sunglasses, hats, or anything covering your face',
      'hi': 'सनग्लास, टोपी या चेहरे को ढकने वाली कोई भी चीज़ हटाएं',
      'te': 'సన్‌గ్లాసెస్, టోపీ లేదా ముఖాన్ని కప్పే ఏదైనా తీసివేయండి',
    },
    'face0011': {
      'en': 'Use front camera and face directly at the camera',
      'hi': 'फ्रंट कैमरा उपयोग करें और सीधे कैमरे की ओर देखें',
      'te': 'ఫ్రంట్ కెమెరాను ఉపయోగించి నేరుగా కెమెరాను ఎదుర్కొనండి',
    },
    'face0012': {
      'en': 'Neutral expression with eyes open',
      'hi': 'आंखें खुली रखें और चेहरा सामान्य रखें',
      'te': 'కళ్ళు తెరిచి, తటస్థ ముఖభావం ఉంచండి',
    },
    'face0013': {
      'en': 'Avoid blurry or low-quality images',
      'hi': 'धुंधली या कम गुणवत्ता वाली इमेज से बचें',
      'te': 'మసకగా లేదా తక్కువ నాణ్యత ఉన్న చిత్రాలను నివారించండి',
    },
    'face0014': {
      'en': 'Live photo required - No saved photos allowed',
      'hi': 'लाइव फोटो आवश्यक - सेव की गई फोटो की अनुमति नहीं है',
      'te': 'లైవ్ ఫోటో అవసరం - సేవ్ చేసిన ఫోటోలు అనుమతించబడవు',
    },
    'face0015': {
      'en': 'Tap to capture',
      'hi': 'कैप्चर करने के लिए टैप करें',
      'te': 'క్యాప్చర్ చేయడానికి ట్యాప్ చేయండి',
    },
    'face0016': {
      'en': 'Live camera only',
      'hi': 'केवल लाइव कैमरा',
      'te': 'లైవ్ కెమెరా మాత్రమే',
    },
    'face0017': {
      'en': '✓ Photo verified',
      'hi': '✓ फोटो सत्यापित',
      'te': '✓ ఫోటో ధృవీకరించబడింది',
    },
    'face0018': {
      'en': 'Photo captured',
      'hi': 'फोटो कैप्चर हुई',
      'te': 'ఫోటో క్యాప్చర్ అయింది',
    },
    'face0019': {
      'en': 'Profile photo removed',
      'hi': 'प्रोफ़ाइल फोटो हटाई गई',
      'te': 'ప్రొఫైల్ ఫోటో తొలగించబడింది',
    },
    'face0020': {
      'en': 'Open Camera',
      'hi': 'कैमरा खोलें',
      'te': 'కెమెరా తెరచండి',
    },
    'face0021': {
      'en': 'Profile photo saved successfully!',
      'hi': 'प्रोफ़ाइल फोटो सफलतापूर्वक सेव हो गई!',
      'te': 'ప్రొఫైల్ ఫోటో విజయవంతంగా సేవ్ అయింది!',
    },
    'face0022': {
      'en': 'Continue',
      'hi': 'जारी रखें',
      'te': 'కొనసాగించండి',
    },
    'face0023': {
      'en': 'Retake Photo',
      'hi': 'फोटो फिर से लें',
      'te': 'ఫోటో మళ్లీ తీసుకోండి',
    },
    'face0024': {
      'en': 'Failed to load',
      'hi': 'लोड करने में विफल',
      'te': 'లోడ్ చేయడం విఫలమైంది',
    },
  },
  // registration_certificate
  {
    'rc0001': {
      'en': 'Vehicle Registration',
      'hi': 'वाहन पंजीकरण',
      'te': 'వాహన నమోదు',
    },
    'rc0002': {
      'en': 'Upload RC Document',
      'hi': 'RC दस्तावेज़ अपलोड करें',
      'te': 'RC డాక్యుమెంట్ అప్లోడ్ చేయండి',
    },
    'rc0003': {
      'en': 'Registration number visible',
      'hi': 'पंजीकरण नंबर दिखाई देना चाहिए',
      'te': 'రిజిస్ట్రేషన్ నంబర్ కనిపించాలి',
    },
    'rc0004': {
      'en': 'Owner details & address visible',
      'hi': 'मालिक विवरण और पता दिखाई देना चाहिए',
      'te': 'యజమాని వివరాలు మరియు చిరునామా కనిపించాలి',
    },
    'rc0005': {
      'en': 'Registration Number',
      'hi': 'पंजीकरण नंबर',
      'te': 'రిజిస్ట్రేషన్ నంబర్',
    },
    'rc0006': {
      'en': 'DL03CW3121',
      'hi': 'DL03CW3121',
      'te': 'DL03CW3121',
    },
    'rc0007': {
      'en': 'Auto-filled from photo or enter manually',
      'hi': 'फोटो से स्वतः भरा गया या मैन्युअली दर्ज करें',
      'te': 'ఫోటో నుండి ఆటో-ఫిల్ లేదా మాన్యువల్‌గా నమోదు చేయండి',
    },
    'rc0008': {
      'en': 'Reading Registration Number...',
      'hi': 'पंजीकरण नंबर पढ़ा जा रहा है...',
      'te': 'రిజిస్ట్రేషన్ నంబర్ చదువుతోంది...',
    },
    'rc0009': {
      'en': 'Registration Number auto-filled: %1',
      'hi': 'पंजीकरण नंबर स्वतः भरा गया: %1',
      'te': 'రిజిస్ట్రేషన్ నంబర్ ఆటో-ఫిల్ అయ్యింది: %1',
    },
    'rc0010': {
      'en': 'Could not detect registration number. Please enter manually.',
      'hi': 'पंजीकरण नंबर नहीं मिला। कृपया मैन्युअली दर्ज करें।',
      'te': 'రిజిస్ట్రేషన్ నంబర్ గుర్తించబడలేదు. దయచేసి మాన్యువల్‌గా నమోదు చేయండి.',
    },
    'rc0011': {
      'en': 'OCR failed. Please enter registration number manually.',
      'hi': 'OCR असफल। कृपया पंजीकरण नंबर मैन्युअली दर्ज करें।',
      'te': 'OCR విఫలమైంది. దయచేసి రిజిస్ట్రేషన్ నంబర్ మాన్యువల్‌గా నమోదు చేయండి.',
    },
    'rc0012': {
      'en': 'Please enter registration number',
      'hi': 'कृपया पंजीकरण नंबर दर्ज करें',
      'te': 'దయచేసి రిజిస్ట్రేషన్ నంబర్ నమోదు చేయండి',
    },
    'rc0013': {
      'en': 'Invalid format (e.g., DL03CW3121)',
      'hi': 'अमान्य फॉर्मेट (उदा., DL03CW3121)',
      'te': 'చెల్లని ఫార్మాట్ (ఉదా., DL03CW3121)',
    },
    'rc0014': {
      'en': 'Registration must be 9-10 characters',
      'hi': 'पंजीकरण 9-10 अक्षरों का होना चाहिए',
      'te': 'రిజిస్ట్రేషన్ 9-10 అక్షరాలు ఉండాలి',
    },
    'rc0015': {
      'en': 'Registration number verified ✓',
      'hi': 'पंजीकरण नंबर सत्यापित ✓',
      'te': 'రిజిస్ట్రేషన్ నంబర్ ధృవీకరించబడింది ✓',
    },
    'rc0016': {
      'en': 'Registration number must be clearly visible',
      'hi': 'पंजीकरण नंबर स्पष्ट रूप से दिखाई देना चाहिए',
      'te': 'రిజిస్ట్రేషన్ నంబర్ స్పష్టంగా కనిపించాలి',
    },
    'rc0017': {
      'en': 'All four corners should be clear',
      'hi': 'चारों कोने स्पष्ट होने चाहिए',
      'te': 'నాలుగు మూలలు స్పష్టంగా కనిపించాలి',
    },
    'rc0018': {
      'en': 'OCR will auto-fill registration number',
      'hi': 'OCR पंजीकरण नंबर स्वतः भरेगा',
      'te': 'OCR రిజిస్ట్రేషన్ నంబర్ ఆటో-ఫిల్ చేస్తుంది',
    },
    'rc0019': {
      'en': 'Please upload front side',
      'hi': 'कृपया आगे की तरफ अपलोड करें',
      'te': 'దయచేసి ముందు వైపు అప్లోడ్ చేయండి',
    },
    'rc0020': {
      'en': 'Please upload back side',
      'hi': 'कृपया पीछे की तरफ अपलोड करें',
      'te': 'దయచేసి వెనుక వైపు అప్లోడ్ చేయండి',
    },
    'rc0021': {
      'en': 'Registration certificate uploaded!',
      'hi': 'पंजीकरण प्रमाणपत्र अपलोड हो गया!',
      'te': 'రిజిస్ట్రేషన్ సర్టిఫికేట్ అప్లోడ్ అయ్యింది!',
    },
  },
  // bank_account
  {
    'bank0001': {
      'en': 'Unknown Bank',
      'hi': 'अज्ञात बैंक',
      'te': 'తెలియని బ్యాంక్',
    },
    'bank0002': {
      'en': 'Bank Verified ✓',
      'hi': 'बैंक सत्यापित ✓',
      'te': 'బ్యాంక్ ధృవీకరించబడింది ✓',
    },
    'bank0003': {
      'en': 'Bank: %1',
      'hi': 'बैंक: %1',
      'te': 'బ్యాంక్: %1',
    },
    'bank0004': {
      'en': 'Branch: %1',
      'hi': 'शाखा: %1',
      'te': 'బ్రాంచ్: %1',
    },
    'bank0005': {
      'en': 'City: %1',
      'hi': 'शहर: %1',
      'te': 'నగరం: %1',
    },
    'bank0006': {
      'en': 'IFSC: %1',
      'hi': 'IFSC: %1',
      'te': 'IFSC: %1',
    },
    'bank0007': {
      'en': 'Account: ****%1',
      'hi': 'खाता: ****%1',
      'te': 'ఖాతా: ****%1',
    },
    'bank0008': {
      'en': 'Confirm',
      'hi': 'पुष्टि करें',
      'te': 'నిర్ధారించండి',
    },
    'bank0009': {
      'en': 'Invalid IFSC code',
      'hi': 'अमान्य IFSC कोड',
      'te': 'చెల్లని IFSC కోడ్',
    },
    'bank0010': {
      'en': 'IFSC Validation Error: %1',
      'hi': 'IFSC सत्यापन त्रुटि: %1',
      'te': 'IFSC ధృవీకరణ లోపం: %1',
    },
    'bank0011': {
      'en': 'Error: %1',
      'hi': 'त्रुटि: %1',
      'te': 'లోపం: %1',
    },
    'bank0012': {
      'en': 'Bank account added successfully!',
      'hi': 'बैंक खाता सफलतापूर्वक जोड़ दिया गया!',
      'te': 'బ్యాంక్ ఖాతా విజయవంతంగా జోడించబడింది!',
    },
    'bank0013': {
      'en': 'Full name is required.',
      'hi': 'पूरा नाम आवश्यक है।',
      'te': 'పూర్తి పేరు అవసరం.',
    },
    'bank0014': {
      'en': 'Account number is required.',
      'hi': 'खाता नंबर आवश्यक है।',
      'te': 'ఖాతా సంఖ్య అవసరం.',
    },
    'bank0015': {
      'en': 'Account number must be 9 to 18 digits.',
      'hi': 'खाता नंबर 9 से 18 अंकों का होना चाहिए।',
      'te': 'ఖాతా సంఖ్య 9 నుంచి 18 అంకెల వరకు ఉండాలి.',
    },
    'bank0016': {
      'en': 'Please confirm account number.',
      'hi': 'कृपया खाता नंबर की पुष्टि करें।',
      'te': 'దయచేసి ఖాతా సంఖ్యను నిర్ధారించండి.',
    },
    'bank0017': {
      'en': 'Account numbers do not match.',
      'hi': 'खाता नंबर मेल नहीं खाते।',
      'te': 'ఖాతా సంఖ్యలు సరిపోలడం లేదు.',
    },
    'bank0018': {
      'en': 'IFSC code is required.',
      'hi': 'IFSC कोड आवश्यक है।',
      'te': 'IFSC కోడ్ అవసరం.',
    },
    'bank0019': {
      'en': 'Enter a valid IFSC code.',
      'hi': 'मान्य IFSC कोड दर्ज करें।',
      'te': 'చెల్లుబాటు అయ్యే IFSC కోడ్ నమోదు చేయండి.',
    },
    'bank0020': {
      'en': 'Validating...',
      'hi': 'सत्यापित किया जा रहा है...',
      'te': 'ధృవీకరిస్తోంది...',
    },
  },
  // document_management
  {
    'docm0001': {
      'en': 'Please upload at least one new document to update.',
      'hi': 'अपडेट के लिए कम से कम एक नया दस्तावेज़ अपलोड करें।',
      'te': 'అప్డేట్ కోసం కనీసం ఒక కొత్త డాక్యుమెంట్‌ను అప్లోడ్ చేయండి.',
    },
    'docm0002': {
      'en': '✓ Documents updated successfully!',
      'hi': '✓ दस्तावेज़ सफलतापूर्वक अपडेट हो गए!',
      'te': '✓ డాక్యుమెంట్లు విజయవంతంగా అప్డేట్ అయ్యాయి!',
    },
    'docm0003': {
      'en': 'Update failed',
      'hi': 'अपडेट विफल रहा',
      'te': 'అప్డేట్ విఫలమైంది',
    },
    'docm0004': {
      'en': 'An error occurred. Please try again.',
      'hi': 'एक त्रुटि हुई। कृपया फिर से कोशिश करें।',
      'te': 'ఒక లోపం జరిగింది. దయచేసి మళ్లీ ప్రయత్నించండి.',
    },
    'docm0005': {
      'en': 'Manage Documents',
      'hi': 'दस्तावेज़ प्रबंधित करें',
      'te': 'డాక్యుమెంట్లు నిర్వహించండి',
    },
    'docm0006': {
      'en': 'Update your proofs here.',
      'hi': 'यहां अपने प्रमाण अपडेट करें।',
      'te': 'మీ రుజువులను ఇక్కడ అప్డేట్ చేయండి.',
    },
    'docm0007': {
      'en': 'Personal Documents',
      'hi': 'व्यक्तिगत दस्तावेज़',
      'te': 'వ్యక్తిగత డాక్యుమెంట్లు',
    },
    'docm0008': {
      'en': 'Profile Photo',
      'hi': 'प्रोफ़ाइल फोटो',
      'te': 'ప్రొఫైల్ ఫోటో',
    },
    'docm0009': {
      'en': 'Driving License',
      'hi': 'ड्राइविंग लाइसेंस',
      'te': 'డ్రైవింగ్ లైసెన్స్',
    },
    'docm0010': {
      'en': 'Aadhaar Card',
      'hi': 'आधार कार्ड',
      'te': 'ఆధార్ కార్డ్',
    },
    'docm0011': {
      'en': 'PAN Card',
      'hi': 'पैन कार्ड',
      'te': 'పాన్ కార్డ్',
    },
    'docm0012': {
      'en': 'Vehicle Documents',
      'hi': 'वाहन दस्तावेज़',
      'te': 'వాహన డాక్యుమెంట్లు',
    },
    'docm0013': {
      'en': 'Vehicle Photo',
      'hi': 'वाहन फोटो',
      'te': 'వాహన ఫోటో',
    },
    'docm0014': {
      'en': 'RC Book',
      'hi': 'RC बुक',
      'te': 'RC బుక్',
    },
    'docm0015': {
      'en': 'Update Documents',
      'hi': 'दस्तावेज़ अपडेट करें',
      'te': 'డాక్యుమెంట్లు అప్డేట్ చేయండి',
    },
    'docm0016': {
      'en': 'Ready to Update',
      'hi': 'अपडेट के लिए तैयार',
      'te': 'అప్డేట్‌కు సిద్ధం',
    },
    // Ride Flow
    'ride0001': {
      'en': 'Failed to accept ride. Please check your connection.',
      'hi': 'राइड स्वीकार करने में विफल। कृपया अपना कनेक्शन जांचें।',
      'te': 'రైడ్‌ను అంగీకరించడం విఫలమైంది. దయచేసి మీ కనెక్షన్‌ను తనిఖీ చేయండి.',
    },
    'ride0002': {
      'en': 'Invalid OTP',
      'hi': 'अमान्य OTP',
      'te': 'చెల్లని OTP',
    },
    'ride0003': {
      'en': 'Verification Failed',
      'hi': 'सत्यापन विफल',
      'te': 'ధృవీకరణ విఫలమైంది',
    },
    'ride0004': {
      'en': 'Connection error. Please try again.',
      'hi': 'कनेक्शन त्रुटि। कृपया पुनः प्रयास करें।',
      'te': 'కనెక్షన్ లోపం. దయచేసి మళ్ళీ ప్రయత్నించండి.',
    },
    'ride0005': {
      'en': 'Failed to complete ride. Please try again.',
      'hi': 'राइड पूर्ण करने में विफल। कृपया पुनः प्रयास करें।',
      'te': 'రైడ్ పూర్తి చేయడం విఫలమైంది. దయచేసి మళ్ళీ ప్రయత్నించండి.',
    },
    'ride0006': {
      'en': 'Fare',
      'hi': 'किराया',
      'te': 'ఛార్జీ',
    },
    'ride0007': {
      'en': 'Phone number not available.',
      'hi': 'फोन नंबर उपलब्ध नहीं है।',
      'te': 'ఫోన్ నంబర్ అందుబాటులో లేదు.',
    },
    // History
    'hist0001': {
      'en': 'No past rides yet.',
      'hi': 'अभी तक कोई पिछली राइड नहीं।',
      'te': 'ఇంకా గత రైడ్‌లు లేవు.',
    },
    // Error Messages
    'err0001': {
      'en': 'Try Again',
      'hi': 'पुनः प्रयास करें',
      'te': 'మళ్ళీ ప్రయత్నించండి',
    },
  },
  // support
  {
    'ilu9a857': {
      'en': 'All topics',
      'hi': 'सभी विषय',
      'te': 'అన్ని అంశాలు',
    },
    'l5axm4k6': {
      'en': 'Help with a trip',
      'hi': 'यात्रा में सहायता',
      'te': 'యాత్రకు సహాయం చేయండి',
    },
    '1x4bvc77': {
      'en': 'Account',
      'hi': 'खाता',
      'te': 'ఖాతా',
    },
    'eg87aj55': {
      'en': 'Membership',
      'hi': 'सदस्यता',
      'te': 'సభ్యత్వం',
    },
    'mltafgrv': {
      'en': 'Accessibility',
      'hi': 'सरल उपयोग',
      'te': 'యాక్సెసిబిలిటీ',
    },
    'ai29673v': {
      'en': 'grievance redressal',
      'hi': 'शिकायत निवारण',
      'te': 'ఫిర్యాదుల పరిష్కారం',
    },
    'wugnnj8h': {
      'en': 'Guides',
      'hi': 'गाइड',
      'te': 'గైడ్‌లు',
    },
    'sftkxprc': {
      'en': 'Cancellation policy',
      'hi': 'शटल',
      'te': 'షటిల్',
    },
    '1khvfk0r': {
      'en': 'Map issue',
      'hi': 'मानचित्र समस्या',
      'te': 'మ్యాప్ సమస్య',
    },
    '0bntvzxa': {
      'en': 'Support',
      'hi': '',
      'te': '',
    },
  },
  // Wallet
  {
    '7idwe1xc': {
      'en': 'Ugo cash',
      'hi': 'उगो कैश',
      'te': 'ఉగో నగదు',
    },
    'o5o4i3gu': {
      'en': '₹0.00',
      'hi': '₹0.00',
      'te': '₹0.00',
    },
    'a6u6d0sq': {
      'en': 'Gift card',
      'hi': 'उपहार कार्ड',
      'te': 'బహుమతి కార్డు',
    },
    'ktxa402r': {
      'en': 'Payment methods',
      'hi': 'भुगतान विधियाँ',
      'te': 'చెల్లింపు పద్ధతులు',
    },
    'oao5dvnw': {
      'en': 'Upi scan and pay',
      'hi': 'Upi स्कैन और भुगतान',
      'te': 'UPI స్కాన్ చేసి చెల్లించండి',
    },
    'mcje350w': {
      'en': 'Cash',
      'hi': 'नकद',
      'te': 'నగదు',
    },
    'zsnn2w5x': {
      'en': 'Add payment method',
      'hi': 'भुगतान विधि जोड़ें',
      'te': 'చెల్లింపు పద్ధతిని జోడించండి',
    },
    'vo9mscox': {
      'en': 'Rides profiles',
      'hi': 'सवारी प्रोफाइल',
      'te': 'రైడ్ ప్రొఫైల్స్',
    },
    'ksdpgb8i': {
      'en': 'Personal',
      'hi': 'निजी',
      'te': 'వ్యక్తిగత',
    },
    'qnqo8992': {
      'en': 'Starting using Ugo for business',
      'hi': 'व्यवसाय के लिए Ugo का उपयोग शुरू करना',
      'te': 'వ్యాపారం కోసం Ugoని ఉపయోగించడం ప్రారంభించడం',
    },
    'hk03dlx6': {
      'en': 'Shared with you',
      'hi': 'आपके साथ साझा',
      'te': 'మీతో పంచుకున్నారు',
    },
    '5iatkiuw': {
      'en': 'Manage business rides for others',
      'hi': 'दूसरों के लिए व्यावसायिक यात्राओं का प्रबंधन करें',
      'te': 'ఇతరుల కోసం వ్యాపార సవారీలను నిర్వహించండి',
    },
    'ijvyfwt8': {
      'en': 'Vouchers',
      'hi': 'वाउचर',
      'te': 'వోచర్లు',
    },
    'uy42yrs1': {
      'en': 'Vouchers',
      'hi': 'वाउचर',
      'te': 'వోచర్లు',
    },
    '6sj8408l': {
      'en': '0',
      'hi': '0',
      'te': '0',
    },
    'i796wiq8': {
      'en': 'Add vouchers code',
      'hi': 'वाउचर कोड जोड़ें',
      'te': 'వోచర్ల కోడ్‌ను జోడించండి',
    },
    '9n8ry32v': {
      'en': 'Promotions',
      'hi': 'प्रचार',
      'te': 'ప్రమోషన్లు',
    },
    'gb7bjv1c': {
      'en': 'Promotions',
      'hi': 'प्रचार',
      'te': 'ప్రమోషన్లు',
    },
    'ae6qnm0p': {
      'en': 'Add promo code',
      'hi': 'प्रोमो कोड जोड़ें',
      'te': 'ప్రోమో కోడ్‌ను జోడించండి',
    },
    'gtwmsvor': {
      'en': 'Referrals',
      'hi': 'रेफरल',
      'te': 'సిఫార్సులు',
    },
    'bqk65ixo': {
      'en': 'Add referral code',
      'hi': 'रेफरल कोड जोड़ें',
      'te': 'రిఫెరల్ కోడ్‌ను జోడించండి',
    },
    '8bs46fqf': {
      'en': 'Wallet',
      'hi': '',
      'te': '',
    },
    'wallet0001': {
      'en': 'Total Balance',
      'hi': 'कुल शेष राशि',
      'te': 'మొత్తం బ్యాలెన్స్',
    },
    'wallet0002': {
      'en': 'Recent Transactions',
      'hi': 'हाल की लेन-देन',
      'te': 'ఇటీవలి లావాదేవీలు',
    },
    'wallet0003': {
      'en': 'Ride Earnings',
      'hi': 'राइड कमाई',
      'te': 'రైడ్ ఆదాయం',
    },
    'wallet0004': {
      'en': 'Commission Paid',
      'hi': 'कमीशन भुगतान',
      'te': 'కమీషన్ చెల్లింపు',
    },
    'wallet0005': {
      'en': 'Incentive Bonus',
      'hi': 'प्रोत्साहन बोनस',
      'te': 'ప్రోత్సాహక బోనస్',
    },
    'wallet0006': {
      'en': 'View All Transactions',
      'hi': 'सभी लेन-देन देखें',
      'te': 'అన్ని లావాదేవీలు చూడండి',
    },
    'wallet0007': {
      'en': 'Manage',
      'hi': 'प्रबंधित करें',
      'te': 'నిర్వహించండి',
    },
    'wallet0008': {
      'en': 'Bank Account',
      'hi': 'बैंक खाता',
      'te': 'బ్యాంక్ ఖాతా',
    },
    'wallet0009': {
      'en': 'Manage withdrawal account',
      'hi': 'निकासी खाता प्रबंधित करें',
      'te': 'విత్‌డ్రాయల్ ఖాతాను నిర్వహించండి',
    },
    'wallet0010': {
      'en': 'Vouchers & Promos',
      'hi': 'वाउचर और प्रोमो',
      'te': 'వోచర్లు & ప్రమోలు',
    },
    'wallet0011': {
      'en': '0 Active vouchers',
      'hi': '0 सक्रिय वाउचर',
      'te': '0 క్రియాశీల వోచర్లు',
    },
    'wallet0012': {
      'en': 'Referrals',
      'hi': 'रेफरल',
      'te': 'సిఫార్సులు',
    },
    'wallet0013': {
      'en': 'Invite friends & earn',
      'hi': 'दोस्तों को आमंत्रित करें और कमाएं',
      'te': 'మిత్రులను ఆహ్వానించి సంపాదించండి',
    },
    'wallet0014': {
      'en': 'Add Money',
      'hi': 'पैसे जोड़ें',
      'te': 'డబ్బు జోడించండి',
    },
    'wallet0015': {
      'en': 'Scan',
      'hi': 'स्कैन करें',
      'te': 'స్కాన్ చేయండి',
    },
    'wallet0016': {
      'en': 'History',
      'hi': 'इतिहास',
      'te': 'చరిత్ర',
    },
    'wallet0017': {
      'en': 'Today, 10:23 AM',
      'hi': 'आज, 10:23 AM',
      'te': 'ఈ రోజు, 10:23 AM',
    },
    'wallet0018': {
      'en': 'Today, 09:45 AM',
      'hi': 'आज, 09:45 AM',
      'te': 'ఈ రోజు, 09:45 AM',
    },
    'wallet0019': {
      'en': 'Yesterday',
      'hi': 'कल',
      'te': 'నిన్న',
    },
  },
  // auto-book
  {
    'lqrebzzn': {
      'en': 'Moto',
      'hi': 'मोटो',
      'te': 'మోటో',
    },
    'bi8twbdw': {
      'en': 'Pick up : dilsukhnagar drop location : Ameerpet',
      'hi': 'पिक-अप: दिलसुखनगर ड्रॉप स्थान: अमीरपेट',
      'te': 'పికప్: దిల్‌సుఖ్‌నగర్ డ్రాప్ లొకేషన్: అమీర్‌పేట్',
    },
    '5kmx6fh5': {
      'en': '₹34.22',
      'hi': '₹34.22',
      'te': '₹34.22',
    },
    'xwgtg5ie': {
      'en': 'Cancel',
      'hi': 'रद्द करना',
      'te': 'రద్దు చేయి',
    },
    '077w129n': {
      'en': 'UGO-AUTO',
      'hi': 'यूगो-ऑटो',
      'te': 'యుజిఓ-ఆటో',
    },
  },
  // available-options
  {
    'sss1lv7l': {
      'en': 'Choose a ride',
      'hi': 'एक सवारी चुनें',
      'te': 'రైడ్‌ను ఎంచుకోండి',
    },
    '4e967bug': {
      'en': 'Moto',
      'hi': 'मोटो',
      'te': 'మోటో',
    },
    '6lv15tcx': {
      'en': 'Pick up : dilsukhnagar',
      'hi': 'पिक अप : दिलसुखनगर',
      'te': 'పికప్: దిల్ సుఖ్ నగర్',
    },
    '1p739tgd': {
      'en': 'drop location : Ameerpet',
      'hi': 'ड्रॉप स्थान: अमीरपेट',
      'te': 'దిగాల్సిన ప్రదేశం: అమీర్‌పేట',
    },
    '9oaeksau': {
      'en': '₹34.22',
      'hi': '₹34.22',
      'te': '₹34.22',
    },
    'fcrhf0w3': {
      'en': 'Moto pro',
      'hi': 'मोटो प्रो',
      'te': 'మోటో ప్రో',
    },
    'mlew9kme': {
      'en': 'Pick up : dilsukhnagar',
      'hi': 'पिक अप : दिलसुखनगर',
      'te': 'పికప్: దిల్ సుఖ్ నగర్',
    },
    'a2l0auns': {
      'en': 'drop location : Ameerpet',
      'hi': 'ड्रॉप स्थान: अमीरपेट',
      'te': 'దిగాల్సిన ప్రదేశం: అమీర్‌పేట',
    },
    'pl1v7jnw': {
      'en': '₹70.00',
      'hi': '₹70.00',
      'te': '₹70.00',
    },
    'o77lf1sb': {
      'en': 'Auto',
      'hi': 'ऑटो',
      'te': 'ఆటో',
    },
    'vmmpm3p6': {
      'en': 'Pick up : dilsukhnagar',
      'hi': 'पिक अप : दिलसुखनगर',
      'te': 'పికప్: దిల్ సుఖ్ నగర్',
    },
    'bonxcfmd': {
      'en': 'drop location : Ameerpet',
      'hi': 'ड्रॉप स्थान: अमीरपेट',
      'te': 'దిగాల్సిన ప్రదేశం: అమీర్‌పేట',
    },
    'ffqtl5de': {
      'en': '₹50.00',
      'hi': '₹50.00',
      'te': '₹50.00',
    },
    'm81fun72': {
      'en': 'Auto pro',
      'hi': 'ऑटो प्रो',
      'te': 'ఆటో ప్రో',
    },
    'k37l7dk0': {
      'en': 'Pick up : dilsukhnagar',
      'hi': 'पिक अप : दिलसुखनगर',
      'te': 'పికప్: దిల్ సుఖ్ నగర్',
    },
    'uigtb205': {
      'en': 'drop location : Ameerpet',
      'hi': 'ड्रॉप स्थान: अमीरपेट',
      'te': 'దిగాల్సిన ప్రదేశం: అమీర్‌పేట',
    },
    'bzzd4m6e': {
      'en': '₹70.00',
      'hi': '₹70.00',
      'te': '₹70.00',
    },
    'dcaqw0v8': {
      'en': 'Cab',
      'hi': 'कैब',
      'te': 'క్యాబ్',
    },
    'yq013f7e': {
      'en': 'Pick up : dilsukhnagar',
      'hi': 'पिक अप : दिलसुखनगर',
      'te': 'పికప్: దిల్ సుఖ్ నగర్',
    },
    'inek0qa3': {
      'en': 'drop location : Ameerpet',
      'hi': 'ड्रॉप स्थान: अमीरपेट',
      'te': 'దిగాల్సిన ప్రదేశం: అమీర్‌పేట',
    },
    'hr875s0h': {
      'en': '₹400.00',
      'hi': '₹400.00',
      'te': '₹400.00',
    },
    '9i8wvtyx': {
      'en': 'Cash',
      'hi': 'नकद',
      'te': 'నగదు',
    },
    'wkk5mvrs': {
      'en': 'Scan',
      'hi': 'स्कैन',
      'te': 'స్కాన్ చేయండి',
    },
    'd9gp7e0g': {
      'en': 'Book ride',
      'hi': 'सवारी बुक करें',
      'te': 'బుక్ రైడ్',
    },
    'm2899lty': {
      'en': 'Add Stops',
      'hi': 'स्टॉप जोड़ें',
      'te': 'స్టాప్‌లను జోడించండి',
    },
  },
  // conform_location
  {
    'imzt8cr8': {
      'en': 'Add stops',
      'hi': 'स्टॉप जोड़ें',
      'te': 'స్టాప్‌లను జోడించండి',
    },
    'albhijj1': {
      'en': '•',
      'hi': '•',
      'te': '•',
    },
    'u6x3lohi': {
      'en': 'Enter pickup location',
      'hi': 'पिकअप स्थान दर्ज करें',
      'te': 'పికప్ స్థానాన్ని నమోదు చేయండి',
    },
    '8qw8lcxh': {
      'en': '1',
      'hi': '1',
      'te': '1. 1.',
    },
    'i3kf70rh': {
      'en': 'Add stop',
      'hi': 'स्टॉप जोड़ें',
      'te': 'స్టాప్‌ను జోడించండి',
    },
    '8ysdsq60': {
      'en': '2',
      'hi': '2',
      'te': '2',
    },
    'akzfkkd2': {
      'en': 'Add stop',
      'hi': 'स्टॉप जोड़ें',
      'te': 'స్టాప్‌ను జోడించండి',
    },
    'qh4iq3du': {
      'en': 'Pickup now',
      'hi': 'अभी उठाओ',
      'te': 'ఇప్పుడే తీసుకోండి',
    },
    'ymq0ndnp': {
      'en': 'For me',
      'hi': 'मेरे लिए',
      'te': 'నా కోసం',
    },
    'tioigdzn': {
      'en': 'Done',
      'hi': 'हो गया',
      'te': 'పూర్తయింది',
    },
    '83kqrbgp': {
      'en': 'Add Stops',
      'hi': 'स्टॉप जोड़ें',
      'te': 'స్టాప్‌లను జోడించండి',
    },
  },
  // scan_to_book
  {
    'd5nsxfra': {
      'en': 'Scan the QR Code to Book Your Ride',
      'hi': 'अपनी सवारी बुक करने के लिए QR कोड स्कैन करें',
      'te': 'మీ రైడ్ బుక్ చేసుకోవడానికి QR కోడ్‌ను స్కాన్ చేయండి.',
    },
    't346q4kk': {
      'en': 'Scan Qr',
      'hi': 'क्यूआर स्कैन करें',
      'te': 'Qr స్కాన్ చేయండి',
    },
  },
  // History
  {
    'c0vu40lh': {
      'en': 'Past',
      'hi': 'अतीत',
      'te': 'గతం',
    },
    '0gut0jmn': {
      'en': 'Moosarambagh',
      'hi': 'मूसारामबाग',
      'te': 'మూసారంబాగ్',
    },
    'lxpk8m0l': {
      'en': 'Nov 17. 5:20 PM',
      'hi': '17 नवंबर, शाम 5:20 बजे',
      'te': 'నవంబర్ 17. సాయంత్రం 5:20',
    },
    'oxsoi771': {
      'en': '₹ 30.00',
      'hi': '₹ 30.00',
      'te': '₹ 30.00',
    },
    '8rlnckeh': {
      'en': 'Rebook',
      'hi': 'पुनः बुक करें',
      'te': 'రీబుక్',
    },
    'it4iktrs': {
      'en': 'Dilsukhnagar',
      'hi': 'दिलसुखनगर',
      'te': 'దిల్ సుఖ్ నగర్',
    },
    'wy0c9zr0': {
      'en': 'Nov 12. 2:20 PM',
      'hi': '12 नवंबर, दोपहर 2:20 बजे',
      'te': 'నవంబర్ 12. మధ్యాహ్నం 2:20',
    },
    '4vux8ze9': {
      'en': '₹ 40.00',
      'hi': '₹ 40.00',
      'te': '₹ 40.00',
    },
    'zy4irrh0': {
      'en': 'Rebook',
      'hi': 'पुनः बुक करें',
      'te': 'రీబుక్',
    },
    'puj2e3gd': {
      'en': 'Moosarambagh',
      'hi': 'मूसारामबाग',
      'te': 'మూసారంబాగ్',
    },
    'b0vj804q': {
      'en': 'Nov 17. 5:20 PM',
      'hi': '17 नवंबर, शाम 5:20 बजे',
      'te': 'నవంబర్ 17. సాయంత్రం 5:20',
    },
    'tric25j6': {
      'en': '₹ 30.00',
      'hi': '₹ 30.00',
      'te': '₹ 30.00',
    },
    'z6wnb9dz': {
      'en': 'Rebook',
      'hi': 'पुनः बुक करें',
      'te': 'రీబుక్',
    },
    '0dy2vanb': {
      'en': 'Dilsukhnagar',
      'hi': 'दिलसुखनगर',
      'te': 'దిల్ సుఖ్ నగర్',
    },
    'ob0fb5ve': {
      'en': 'Nov 12. 2:20 PM',
      'hi': '12 नवंबर, दोपहर 2:20 बजे',
      'te': 'నవంబర్ 12. మధ్యాహ్నం 2:20',
    },
    'qinmxv0b': {
      'en': '₹ 40.00',
      'hi': '₹ 40.00',
      'te': '₹ 40.00',
    },
    'pt5eqqo4': {
      'en': 'Rebook',
      'hi': 'पुनः बुक करें',
      'te': 'రీబుక్',
    },
    'd1xoho5t': {
      'en': 'Dilsukhnagar',
      'hi': 'दिलसुखनगर',
      'te': 'దిల్ సుఖ్ నగర్',
    },
    'exychc9j': {
      'en': 'Nov 12. 2:20 PM',
      'hi': '12 नवंबर, दोपहर 2:20 बजे',
      'te': 'నవంబర్ 12. మధ్యాహ్నం 2:20',
    },
    'hw807j6y': {
      'en': '₹ 40.00',
      'hi': '₹ 40.00',
      'te': '₹ 40.00',
    },
    'w9nepd8d': {
      'en': 'Rebook',
      'hi': 'पुनः बुक करें',
      'te': 'రీబుక్',
    },
    'b5u7cma8': {
      'en': 'History',
      'hi': 'इतिहास',
      'te': 'చరిత్ర',
    },
  },
  // Profile_setting
  {
    'strai6nr': {
      'en': 'GO CODE DESIGNERS',
      'hi': 'गो कोड डिज़ाइनर्स',
      'te': 'గో కోడ్ డిజైనర్లు',
    },
    'gpjsbapw': {
      'en': 'Name',
      'hi': 'नाम',
      'te': 'పేరు',
    },
    'nzougsbz': {
      'en': 'Go CODE DESIGNERS',
      'hi': 'गो कोड डिज़ाइनर्स',
      'te': 'కోడ్ డిజైనర్లకు వెళ్లండి',
    },
    'bub0e7tg': {
      'en': 'Phone number',
      'hi': 'फ़ोन नंबर',
      'te': 'ఫోన్ నంబర్',
    },
    '99l2lyka': {
      'en': '9885881832',
      'hi': '9885881832',
      'te': '9885881832 ద్వారా www.mc.gov.in',
    },
    'uj2qqhvh': {
      'en': 'Gender',
      'hi': 'लिंग',
      'te': 'లింగం',
    },
    '3yx1101c': {
      'en': 'Man',
      'hi': 'आदमी',
      'te': 'మనిషి',
    },
    '1za01ujf': {
      'en': 'Email',
      'hi': 'ईमेल',
      'te': 'ఇ-మెయిల్',
    },
    'cqz2gscf': {
      'en': 'Duggiralanaresh1@gmail.com',
      'hi': 'Duggiralanaresh1@gmail.com',
      'te': 'దుగ్గిరలనరేష్1@gmail.com',
    },
    '383johu2': {
      'en': 'Language',
      'hi': 'भाषा',
      'te': 'భాష',
    },
    'h5ox1a3d': {
      'en': 'English',
      'hi': 'अंग्रेज़ी',
      'te': 'ఇంగ్లీష్',
    },
    '6uptrs2q': {
      'en': 'Save',
      'hi': 'बचाना',
      'te': 'సేవ్ చేయండి',
    },
    'l6xp81l6': {
      'en': 'App Settings',
      'hi': 'ऐप सेटिंग्स',
      'te': 'యాప్ సెట్టింగ్‌లు',
    },
  },
  // Add_office
  {
    'ma10493c': {
      'en': 'Rajiv Gandhi airport',
      'hi': 'राजीव गांधी हवाई अड्डा',
      'te': 'రాజీవ్ గాంధీ విమానాశ్రయం',
    },
    '7dwgh835': {
      'en': 'Shamshad Hyderabad, airport',
      'hi': 'शमशाद हैदराबाद, हवाई अड्डा',
      'te': 'షంషాద్ హైదరాబాద్ విమానాశ్రయం',
    },
    'olo2j5pf': {
      'en': '12km',
      'hi': '12 किमी',
      'te': '12 కి.మీ',
    },
    'c0fm547s': {
      'en': 'Search in different city',
      'hi': 'अलग शहर में खोजें',
      'te': 'వేరే నగరంలో శోధించండి',
    },
    'juv5dgq8': {
      'en': 'Set location on map',
      'hi': 'मानचित्र पर स्थान सेट करें',
      'te': 'మ్యాప్‌లో స్థానాన్ని సెట్ చేయండి',
    },
    'l8rl8ngc': {
      'en': 'Saved places',
      'hi': 'सहेजे गए स्थान',
      'te': 'సేవ్ చేసిన స్థలాలు',
    },
    '0990b83s': {
      'en': 'Add office',
      'hi': 'कार्यालय जोड़ें',
      'te': 'కార్యాలయాన్ని జోడించండి',
    },
  },
  // saved_add
  {
    'hfosrynq': {
      'en': 'Saved places',
      'hi': 'सहेजे गए स्थान',
      'te': 'సేవ్ చేసిన స్థలాలు',
    },
    'wsx3v4m0': {
      'en': 'Add Home',
      'hi': 'होम जोड़ें',
      'te': 'ఇంటిని జోడించండి',
    },
    'o6pkmpcm': {
      'en': 'Add Work',
      'hi': 'कार्य जोड़ें',
      'te': 'కార్యాలయాన్ని జోడించండి',
    },
    '354dyfpp': {
      'en': 'Add a new place',
      'hi': 'नया स्थान जोड़ें',
      'te': 'కొత్త స్థలాన్ని జోడించండి',
    },
  },
  // Accessibility_settings
  {
    'txczm026': {
      'en': 'Hearing',
      'hi': 'सुनवाई',
      'te': 'వినికిడి',
    },
    'mt067xu4': {
      'en': 'Indicate hearing preference',
      'hi': 'श्रवण वरीयता इंगित करें',
      'te': 'వినికిడి ప్రాధాన్యతను సూచించండి',
    },
    '5vt79gun': {
      'en': 'Vision',
      'hi': 'दृष्टि',
      'te': 'దృష్టి',
    },
    'nu22iv2u': {
      'en': 'Choose to disclose whether you\'re blind or low vision',
      'hi': 'यह बताना चुनें कि आप अंधे हैं या कम दृष्टि वाले हैं',
      'te':
          'మీరు అంధులా లేదా తక్కువ దృష్టి ఉన్నారా అని వెల్లడించడానికి ఎంచుకోండి',
    },
    'hji1iy90': {
      'en': 'Communication settings',
      'hi': 'संचार सेटिंग्स',
      'te': 'కమ్యూనికేషన్ సెట్టింగ్‌లు',
    },
    't70apkmo': {
      'en': 'Let others know how you need to or prefer to communicate.',
      'hi':
          'दूसरों को बताएं कि आपको किस प्रकार संवाद करना चाहिए या आप किस प्रकार संवाद करना पसंद करते हैं।',
      'te':
          'మీరు ఎలా కమ్యూనికేట్ చేయాలో లేదా ఎలా కమ్యూనికేట్ చేయాలనుకుంటున్నారో ఇతరులకు తెలియజేయండి.',
    },
    '69386x4e': {
      'en': 'Accessibility',
      'hi': 'सरल उपयोग',
      'te': 'యాక్సెసిబిలిటీ',
    },
  },
  // Hearing
  {
    'q7ai65o0': {
      'en': 'Let drivers and couriers know if you\'re deaf or hard of hearing',
      'hi': 'यदि आप बहरे हैं या कम सुनते हैं तो ड्राइवरों और कूरियर को बताएं',
      'te':
          'మీరు చెవిటివారో లేదా వినికిడి లోపం ఉన్నారో లేదో డ్రైవర్లు మరియు కొరియర్‌లకు తెలియజేయండి.',
    },
    '2bir0a8h': {
      'en': 'I;m deaf',
      'hi': 'मैं बहरा हूँ',
      'te': 'నేను చెవిటివాడిని.',
    },
    'j0nd9ppv': {
      'en': 'I;m hard of hearing',
      'hi': 'मुझे सुनने में दिक्कत है',
      'te': 'నాకు వినికిడి కష్టంగా ఉంది.',
    },
    '19pk9vwp': {
      'en': 'I;m not deaf or hard of hearing',
      'hi': 'मैं बहरा या कम सुनने वाला नहीं हूँ',
      'te': 'నేను చెవిటివాడిని లేదా వినికిడి లోపం ఉన్నవాడిని కాదు.',
    },
    '0vz47ig4': {
      'en': 'Hearing',
      'hi': 'सुनवाई',
      'te': 'వినికిడి',
    },
  },
  // Vision
  {
    'l7hiz6yp': {
      'en': 'Let drivers and couriers know if you\'re deaf or hard of hearing',
      'hi': 'यदि आप बहरे हैं या कम सुनते हैं तो ड्राइवरों और कूरियर को बताएं',
      'te':
          'మీరు చెవిటివారో లేదా వినికిడి లోపం ఉన్నారో లేదో డ్రైవర్లు మరియు కొరియర్‌లకు తెలియజేయండి.',
    },
    '3zrdl7j9': {
      'en': 'I;m blind',
      'hi': 'मैं अंधा हुँ',
      'te': 'నేను అంధుడిని;',
    },
    'rdyxxwt6': {
      'en': 'I;m low vision',
      'hi': 'मेरी दृष्टि कमज़ोर है',
      'te': 'నాకు దృష్టి తక్కువగా ఉంది.',
    },
    'kx5zxhf5': {
      'en': 'I;m not blind or low vision',
      'hi': 'मैं अंधा या कम दृष्टि वाला नहीं हूँ',
      'te': 'నేను అంధుడిని లేదా తక్కువ దృష్టిని కలిగి లేను.',
    },
    'tmb60xz8': {
      'en': 'Vision',
      'hi': 'दृष्टि',
      'te': 'దృష్టి',
    },
  },
  // Pushnotifications
  {
    'gaeok22h': {
      'en': 'Categories',
      'hi': 'श्रेणियाँ',
      'te': 'వర్గం',
    },
    'fe2109ti': {
      'en': 'Promotional offers',
      'hi': 'प्रचारात्मक प्रस्ताव',
      'te': 'ప్రమోషనల్ ఆఫర్లు',
    },
    '0sx5can7': {
      'en': 'Promotional offers, discounts and referral bonus',
      'hi': 'प्रचारात्मक ऑफ़र, छूट और रेफरल बोनस',
      'te': 'ప్రమోషనల్ ఆఫర్లు, డిస్కౌంట్లు మరియు రిఫెరల్ బోనస్',
    },
    'd3vf20um': {
      'en': 'Membership',
      'hi': 'सदस्यता',
      'te': 'సభ్యత్వం',
    },
    '8768rwio': {
      'en': 'Ugo One membership benefits and loyalty rewards',
      'hi': 'उगो वन सदस्यता लाभ और वफादारी पुरस्कार',
      'te': 'Ugo One సభ్యత్వ ప్రయోజనాలు మరియు లాయల్టీ రివార్డులు',
    },
    'ijpmysvu': {
      'en': 'Product updates & news',
      'hi': 'उत्पाद अपडेट और समाचार',
      'te': 'ఉత్పత్తి నవీకరణలు & వార్తలు',
    },
    '98202sfo': {
      'en': 'New product updates and interesting news',
      'hi': 'नए उत्पाद अपडेट और दिलचस्प समाचार',
      'te': 'కొత్త ఉత్పత్తి నవీకరణలు మరియు ఆసక్తికరమైన వార్తలు',
    },
    'd2h0rkrw': {
      'en': 'Recommendations',
      'hi': 'सिफारिशों',
      'te': 'సిఫార్సులు',
    },
    'msr0xh2v': {
      'en': 'Personalized trip suggestions',
      'hi': 'व्यक्तिगत यात्रा सुझाव',
      'te': 'వ్యక్తిగతీకరించిన ట్రిప్ సూచనలు',
    },
    '7sdy4gcc': {
      'en': 'Feedback',
      'hi': 'प्रतिक्रिया',
      'te': 'అభిప్రాయం',
    },
    '73qwhbgg': {
      'en': 'User research and marketing surveys',
      'hi': 'उपयोगकर्ता अनुसंधान और विपणन सर्वेक्षण',
      'te': 'వినియోగదారు పరిశోధన మరియు మార్కెటింగ్ సర్వేలు',
    },
    'gystp015': {
      'en': 'Push notifications',
      'hi': 'सूचनाएं धक्का',
      'te': 'పుష్ నోటిఫికేషన్లు',
    },
  },
  // Safetypreferences
  {
    'ixe1axt7': {
      'en': 'These will turn on when you use your preference',
      'hi': 'जब आप अपनी प्राथमिकता का उपयोग करेंगे तो ये चालू हो जाएंगे',
      'te': 'మీరు మీ ప్రాధాన్యతను ఉపయోగించినప్పుడు ఇవి ఆన్ అవుతాయి.',
    },
    '6uu87tpc': {
      'en': 'Get more safety check-ins',
      'hi': 'अधिक सुरक्षा जांच प्राप्त करें',
      'te': 'మరిన్ని భద్రతా తనిఖీలను పొందండి',
    },
    'ezx2ad7g': {
      'en': 'Monitor ride for route or time issues',
      'hi': 'मार्ग या समय संबंधी समस्याओं के लिए सवारी की निगरानी करें',
      'te': 'మార్గం లేదా సమయ సమస్యల కోసం రైడ్‌ను పర్యవేక్షించండి',
    },
    'yjlrlal7': {
      'en': 'Record audio',
      'hi': 'ऑडियो रिकॉर्ड करें',
      'te': 'ఆడియోను రికార్డ్ చేయండి',
    },
    'alme3h8l': {
      'en': 'Send a recording with your safety report',
      'hi': 'अपनी सुरक्षा रिपोर्ट के साथ एक रिकॉर्डिंग भेजें',
      'te': 'మీ భద్రతా నివేదికతో రికార్డింగ్‌ను పంపండి',
    },
    'gk9cnj7m': {
      'en': 'Share trip status',
      'hi': 'यात्रा की स्थिति साझा करें',
      'te': 'ట్రిప్ స్థితిని షేర్ చేయండి',
    },
    'b4blepbz': {
      'en': 'Share live trip with friends or family',
      'hi': 'दोस्तों या परिवार के साथ लाइव यात्रा साझा करें',
      'te': 'స్నేహితులు లేదా కుటుంబ సభ్యులతో ప్రత్యక్ష యాత్రను పంచుకోండి',
    },
    'woxk3510': {
      'en': 'Schedule',
      'hi': 'अनुसूची',
      'te': 'షెడ్యూల్',
    },
    'cyjugduq': {
      'en': 'This is how and when your preferences will turn on',
      'hi': 'आपकी प्राथमिकताएँ इस प्रकार और कब चालू होंगी',
      'te': 'మీ ప్రాధాన్యతలు ఎలా మరియు ఎప్పుడు ఆన్ అవుతాయి అనేది ఇక్కడ ఉంది',
    },
    'ue8ium3r': {
      'en': 'All rides',
      'hi': 'सभी सवारी',
      'te': 'అన్ని రైడ్‌లు',
    },
    'w7emc38a': {
      'en': 'on during every ride',
      'hi': 'हर सवारी के दौरान चालू',
      'te': 'ప్రతి రైడ్ సమయంలో ఆన్',
    },
    'lbu77i6m': {
      'en': 'Some rides',
      'hi': 'कुछ सवारी',
      'te': 'కొన్ని రైడ్‌లు',
    },
    '284tu9bw': {
      'en': 'Choose ride types',
      'hi': 'सवारी के प्रकार चुनें',
      'te': 'రైడ్ రకాలను ఎంచుకోండి',
    },
    'ugclg4l8': {
      'en': 'No rides',
      'hi': 'कोई सवारी नहीं',
      'te': 'రైడ్‌లు లేవు',
    },
    'a3btvneb': {
      'en': 'only turn on manually',
      'hi': 'केवल मैन्युअल रूप से चालू करें',
      'te': 'మాన్యువల్‌గా మాత్రమే ఆన్ చేయండి',
    },
    'j4u6mh08': {
      'en': 'Done',
      'hi': 'हो गया',
      'te': 'పూర్తయింది',
    },
    'to0i86k9': {
      'en': 'Safety preferences',
      'hi': 'सुरक्षा प्राथमिकताएँ',
      'te': 'భద్రతా ప్రాధాన్యతలు',
    },
  },
  // Trustedcontacts
  {
    'g6m134u2': {
      'en': 'Share your trip status',
      'hi': 'अपनी यात्रा की स्थिति साझा करें',
      'te': 'మీ ట్రిప్ స్టేటస్‌ను షేర్ చేయండి',
    },
    'ic5f70x5': {
      'en': 'Share your live location with contacts during any Ugo trip',
      'hi':
          'किसी भी उगो यात्रा के दौरान अपने संपर्कों के साथ अपना लाइव स्थान साझा करें',
      'te':
          'ఏదైనా Ugo ట్రిప్ సమయంలో మీ ప్రత్యక్ష స్థానాన్ని కాంటాక్ట్‌లతో పంచుకోండి',
    },
    '243jdoch': {
      'en': 'Set your emergency contact',
      'hi': 'अपना आपातकालीन संपर्क सेट करें',
      'te': 'మీ అత్యవసర పరిచయాన్ని సెట్ చేయండి',
    },
    'vmbbzyy4': {
      'en': 'Share your live location with contacts during any Ugo trip',
      'hi':
          'किसी भी उगो यात्रा के दौरान अपने संपर्कों के साथ अपना लाइव स्थान साझा करें',
      'te':
          'ఏదైనా Ugo ట్రిప్ సమయంలో మీ ప్రత్యక్ష స్థానాన్ని కాంటాక్ట్‌లతో పంచుకోండి',
    },
    '8kdg92mk': {
      'en': 'Add contact',
      'hi': 'संपर्क जोड़ें',
      'te': 'పరిచయాన్ని జోడించండి',
    },
    'i7r9ws1o': {
      'en': 'Trusted contacts',
      'hi': 'विश्वसनीय संपर्क',
      'te': 'విశ్వసనీయ పరిచయాలు',
    },
  },
  // Ridecheck
  {
    '6l4gljqb': {
      'en':
          'RideCheck helps in unexpected situations by offering quick access to safety tools, so you can get help fast',
      'hi':
          'राइडचेक अप्रत्याशित परिस्थितियों में सुरक्षा उपकरणों तक त्वरित पहुंच प्रदान करके मदद करता है, ताकि आपको तुरंत सहायता मिल सके',
      'te':
          'RideCheck భద్రతా సాధనాలకు త్వరిత ప్రాప్యతను అందించడం ద్వారా ఊహించని పరిస్థితుల్లో సహాయపడుతుంది, కాబట్టి మీరు త్వరగా సహాయం పొందవచ్చు.',
    },
    'qz96lcn7': {
      'en': 'Ridecheck Notification',
      'hi': 'राइडचेक अधिसूचना',
      'te': 'రైడ్‌చెక్ నోటిఫికేషన్',
    },
    'shl1sb1b': {
      'en':
          'When enabled, we\'ll notify you with a RideCheck if your trip seems off course',
      'hi':
          'सक्षम होने पर, यदि आपकी यात्रा मार्ग से भटकती हुई प्रतीत होती है, तो हम आपको राइडचेक के माध्यम से सूचित करेंगे',
      'te':
          'ప్రారంభించబడినప్పుడు, మీ ప్రయాణం తప్పుగా అనిపిస్తే మేము RideCheck ద్వారా మీకు తెలియజేస్తాము.',
    },
    'm5hml2iz': {
      'en': 'Ride check',
      'hi': 'सवारी जांच',
      'te': 'రైడ్ చెక్',
    },
  },
  // Tipautomatically
  {
    'ocvw6zj4': {
      'en':
          'Make tipping easy by setting a default tip for each ride. You can adjust it within an hour, and 100% goes to your driver.',
      'hi':
          'हर सवारी के लिए एक डिफ़ॉल्ट टिप सेट करके टिप देना आसान बनाएँ। आप इसे एक घंटे के अंदर एडजस्ट कर सकते हैं, और 100% आपके ड्राइवर को जाता है।',
      'te':
          'ప్రతి రైడ్‌కు డిఫాల్ట్ చిట్కాను సెట్ చేయడం ద్వారా టిప్పింగ్‌ను సులభతరం చేయండి. మీరు దానిని ఒక గంటలోపు సర్దుబాటు చేయవచ్చు మరియు 100% మీ డ్రైవర్‌కు వెళ్తుంది.',
    },
    'njyvr94a': {
      'en': 'Turn on auto tipping',
      'hi': 'ऑटो टिपिंग चालू करें',
      'te': 'ఆటో టిప్పింగ్‌ను ఆన్ చేయండి',
    },
    'bktuvk3x': {
      'en': 'Tip amount',
      'hi': 'टिप राशि',
      'te': 'టిప్ మొత్తం',
    },
    'ixm84wqm': {
      'en': '10',
      'hi': '10',
      'te': '10',
    },
    '7l694w2k': {
      'en': '20',
      'hi': '20',
      'te': '20',
    },
    '7q63yu0x': {
      'en': 'Custom',
      'hi': 'रिवाज़',
      'te': 'కస్టమ్',
    },
    'q7rhig4g': {
      'en': 'Tip automatically',
      'hi': 'स्वचालित रूप से टिप',
      'te': 'ఆటోమేటిక్‌గా చిట్కా',
    },
  },
  // Reservematching
  {
    'tv934q4t': {
      'en': 'Reserve matching',
      'hi': 'आरक्षित मिलान',
      'te': 'రిజర్వ్ మ్యాచింగ్',
    },
    'dipozvy7': {
      'en': 'Choose how you\'re matched with drivers when you book ahead',
      'hi':
          'पहले से बुकिंग करते समय ड्राइवरों से आपका मिलान कैसे किया जाए, यह चुनें',
      'te':
          'మీరు ముందుగా బుక్ చేసుకునేటప్పుడు డ్రైవర్లతో ఎలా సరిపోలాలో ఎంచుకోండి',
    },
    'l67s2hr8': {
      'en': 'Auto rematch',
      'hi': 'ऑटो रीमैच',
      'te': 'ఆటో రీమ్యాచ్',
    },
    'yi2dd18f': {
      'en':
          'Match with a new drivers if yours will be late due to slow progress',
      'hi':
          'यदि आपकी गाड़ी धीमी प्रगति के कारण देर से पहुंचेगी तो नए ड्राइवर से मिलान करें',
      'te':
          'మీ డ్రైవర్ నెమ్మదిగా ఉండటం వల్ల ఆలస్యం అవుతుంటే కొత్త డ్రైవర్లతో మ్యాచ్ చేయండి.',
    },
    'dx2c7h8q': {
      'en': 'Reserve matching',
      'hi': 'आरक्षित मिलान',
      'te': 'రిజర్వ్ మ్యాచింగ్',
    },
  },
  // chooseride
  {
    'tprxoefz': {
      'en': 'Late nights',
      'hi': 'देर रात तक',
      'te': 'అర్థరాత్రులు',
    },
    'kk4nvssl': {
      'en': 'Between 10PM to 6AM',
      'hi': 'रात 10 बजे से सुबह 6 बजे के बीच',
      'te': 'రాత్రి 10 గంటల నుండి ఉదయం 6 గంటల మధ్య',
    },
    'a2xf8mbz': {
      'en': 'Bar and restaurants',
      'hi': 'बार और रेस्तरां',
      'te': 'బార్ మరియు రెస్టారెంట్లు',
    },
    'gc3skc6j': {
      'en': 'Within 50 meters',
      'hi': '50 मीटर के भीतर',
      'te': '50 మీటర్ల లోపల',
    },
    '7g3bpi7m': {
      'en': 'Weekends',
      'hi': 'सप्ताहांत',
      'te': 'వారాంతాలు',
    },
    'vnc3rpu5': {
      'en': 'Friday through sunday',
      'hi': 'शुक्रवार से रविवार तक',
      'te': 'శుక్రవారం నుండి ఆదివారం వరకు',
    },
    '1a5usrvr': {
      'en': 'Confirm',
      'hi': 'पुष्टि करना',
      'te': 'నిర్ధారించండి',
    },
    '13agxu8t': {
      'en': 'Cancel',
      'hi': 'रद्द करना',
      'te': 'రద్దు చేయి',
    },
    'lj1iagwe': {
      'en': 'Choose ride types',
      'hi': 'सवारी के प्रकार चुनें',
      'te': 'రైడ్ రకాలను ఎంచుకోండి',
    },
    'z9v6iqjj': {
      'en': 'Home',
      'hi': 'घर',
      'te': 'హొమ్ పేజ్',
    },
  },
  // Commute_alerts
  {
    'u20mk24x': {
      'en': 'We\'re here to help make your commute more predictable.',
      'hi':
          'हम आपकी यात्रा को अधिक पूर्वानुमानित बनाने में सहायता के लिए यहां हैं।',
      'te':
          'మీ ప్రయాణాన్ని మరింత ఊహించదగినదిగా చేయడంలో సహాయపడటానికి మేము ఇక్కడ ఉన్నాము.',
    },
    'wzg5jc2w': {
      'en': 'Add a commute for the trips you take routinely',
      'hi': 'अपनी नियमित यात्राओं के लिए आवागमन जोड़ें',
      'te': 'మీరు రోజూ చేసే ప్రయాణాలకు ప్రయాణ మార్గాన్ని జోడించండి',
    },
    '076xy4r4': {
      'en':
          'Receive personalised commute notifications with traffic and waiting time',
      'hi':
          'ट्रैफ़िक और प्रतीक्षा समय के साथ व्यक्तिगत आवागमन सूचनाएं प्राप्त करें',
      'te':
          'ట్రాఫిక్ మరియు వేచి ఉండే సమయంతో వ్యక్తిగతీకరించిన ప్రయాణ నోటిఫికేషన్‌లను స్వీకరించండి',
    },
    'hyug15zy': {
      'en': 'Get suggestions on when to request a trip for a timely arrival',
      'hi':
          'समय पर आगमन के लिए यात्रा का अनुरोध कब करें, इस पर सुझाव प्राप्त करें',
      'te':
          'సకాలంలో చేరుకోవడానికి ఎప్పుడు ట్రిప్‌ని అభ్యర్థించాలో సూచనలను పొందండి',
    },
    'vziqnf97': {
      'en': 'Get started',
      'hi': 'शुरू हो जाओ',
      'te': 'ప్రారంభించండి',
    },
    'fu7p71gq': {
      'en': 'Commute alerts',
      'hi': 'आवागमन अलर्ट',
      'te': 'ప్రయాణ హెచ్చరికలు',
    },
  },
  // Payment_options
  {
    'q5l67j5j': {
      'en': 'Personal',
      'hi': 'निजी',
      'te': 'వ్యక్తిగత',
    },
    'l9hbshk7': {
      'en': 'Business',
      'hi': 'व्यापार',
      'te': 'బిజినెస్‌',
    },
    'ck9jlsm2': {
      'en': 'Ugo balance ₹0.00',
      'hi': 'उगो बैलेंस ₹0.00',
      'te': 'యుగో బ్యాలెన్స్ ₹0.00',
    },
    '3n2ljdag': {
      'en': 'Ugo cash : ₹0.00',
      'hi': 'उगो कैश : ₹0.00',
      'te': 'ఉగో నగదు : ₹0.00',
    },
    '53zufytw': {
      'en': 'Payment methods',
      'hi': 'भुगतान विधियाँ',
      'te': 'చెల్లింపు పద్ధతులు',
    },
    'tv7rlhvh': {
      'en': '\$',
      'hi': '\$',
      'te': '\$',
    },
    'm786q92q': {
      'en': 'Cash',
      'hi': 'नकद',
      'te': 'నగదు',
    },
    'nb2o49pw': {
      'en': 'Add payment method',
      'hi': 'भुगतान विधि जोड़ें',
      'te': 'చెల్లింపు పద్ధతిని జోడించండి',
    },
    'xt4t3gpw': {
      'en': 'Vouchers',
      'hi': 'वाउचर',
      'te': 'వోచర్లు',
    },
    'w3uwmx1x': {
      'en': 'Add Vouchers code',
      'hi': 'वाउचर कोड जोड़ें',
      'te': 'వోచర్‌ల కోడ్‌ను జోడించండి',
    },
    'vuudjeki': {
      'en': 'Payment options',
      'hi': 'भुगतान विकल्प',
      'te': 'చెల్లింపు ఎంపికలు',
    },
  },
  // add_payment
  {
    'zt4zn1bv': {
      'en': 'Credit or debit',
      'hi': 'क्रेडिट या डेबिट',
      'te': 'క్రెడిట్ లేదా డెబిట్',
    },
    'zii9uz3g': {
      'en': 'Gift card',
      'hi': 'उपहार कार्ड',
      'te': 'బహుమతి కార్డు',
    },
    'j27860pt': {
      'en': 'Add Payment',
      'hi': 'भुगतान जोड़ें',
      'te': 'చెల్లింపును జోడించండి',
    },
  },
  // voucher
  {
    'vwnvxe7z': {
      'en': 'Enter voucher code',
      'hi': 'वाउचर कोड दर्ज करें',
      'te': 'వోచర్ కోడ్‌ను నమోదు చేయండి',
    },
    '2qlkdmuh': {
      'en': 'Enter the code in order to claim and use you voucher',
      'hi': 'अपने वाउचर का दावा करने और उसका उपयोग करने के लिए कोड दर्ज करें',
      'te': 'మీ వోచర్‌ను క్లెయిమ్ చేసి ఉపయోగించడానికి కోడ్‌ను నమోదు చేయండి.',
    },
    'zflfzuy8': {
      'en': 'Continue',
      'hi': 'जारी रखना',
      'te': 'కొనసాగించు',
    },
    'an1a9ec8': {
      'en': 'Add vocher code',
      'hi': 'वाउचर कोड जोड़ें',
      'te': 'వోచర్ కోడ్‌ను జోడించండి',
    },
  },
  // wallet_password
  {
    '6j592fk4': {
      'en': 'To add a new payment method create a password for you Ugo account',
      'hi': 'नई भुगतान विधि जोड़ने के लिए अपने Ugo खाते के लिए पासवर्ड बनाएँ',
      'te':
          'కొత్త చెల్లింపు పద్ధతిని జోడించడానికి మీ Ugo ఖాతా కోసం పాస్‌వర్డ్‌ను సృష్టించండి',
    },
    'w08xsjta': {
      'en': 'Minimum 8 characters',
      'hi': 'न्यूनतम 8 अक्षर',
      'te': 'కనీసం 8 అక్షరాలు',
    },
    '3tili4xw': {
      'en': 'Next',
      'hi': 'अगला',
      'te': 'తరువాతి',
    },
    'q11nxck4': {
      'en': 'Add Password',
      'hi': 'पासवर्ड जोड़ें',
      'te': 'పాస్‌వర్డ్‌ను జోడించండి',
    },
  },
  // Driver_details
  {
    'ekfej241': {
      'en': 'UGO TAXI',
      'hi': 'यूगो टैक्सी',
      'te': 'యుజిఓ టాక్సీ',
    },
    '14hhszp0': {
      'en': 'Driver details',
      'hi': 'ड्राइवर विवरण',
      'te': 'డ్రైవర్ వివరాలు',
    },
    'gepq9jh1': {
      'en': 'Driver name: Sharath',
      'hi': 'ड्राइवर का नाम: शरत',
      'te': 'డ్రైవర్ పేరు: శరత్',
    },
    'f87kknso': {
      'en': 'vehicle number : 1287737738',
      'hi': 'वाहन संख्या : 1287737738',
      'te': 'వాహనం నంబర్: 1287737738',
    },
    'u8ny24ht': {
      'en': 'Rating :',
      'hi': 'रेटिंग :',
      'te': 'రేటింగ్ :',
    },
    '5wyvvbo9': {
      'en': '4.7',
      'hi': '4.7',
      'te': '4.7 समानिक समानी',
    },
    '5cshm3od': {
      'en': 'Drop location : Ameerpet',
      'hi': 'ड्रॉप स्थान: अमीरपेट',
      'te': 'డ్రాప్ లొకేషన్: అమీర్‌పేట',
    },
    'sq2q0aex': {
      'en': 'Drop distance : 15km',
      'hi': 'ड्रॉप दूरी : 15 किमी',
      'te': 'డ్రాప్ దూరం: 15 కి.మీ.',
    },
    'e2qayho8': {
      'en': 'Trip amount : ₹100.00',
      'hi': 'यात्रा राशि : ₹100.00',
      'te': 'ట్రిప్ మొత్తం: ₹100.00',
    },
    'tvvu7856': {
      'en': 'TIP AMOUNT',
      'hi': 'टिप राशि',
      'te': 'చిట్కా మొత్తం',
    },
    '3eeo73fo': {
      'en': '10',
      'hi': '10',
      'te': '10',
    },
    'qp9ckf7f': {
      'en': '20',
      'hi': '20',
      'te': '20',
    },
    'gvv3ine5': {
      'en': '30',
      'hi': '30',
      'te': '30 లు',
    },
    'fvj1to8q': {
      'en': 'Total amount',
      'hi': 'कुल राशि',
      'te': 'మొత్తం మొత్తం',
    },
    'm7v44mwf': {
      'en': '₹100.00',
      'hi': '₹100.00',
      'te': '₹100.00',
    },
    '3iah97vf': {
      'en': 'Cancel',
      'hi': 'रद्द करना',
      'te': 'రద్దు చేయి',
    },
    'bd8wulws': {
      'en': 'Continue',
      'hi': 'जारी रखना',
      'te': 'కొనసాగించు',
    },
  },
  // Messages
  {
    '0rdq2ugn': {
      'en': 'No new messages right now. Check back soon for the latest offers!',
      'hi': 'अभी कोई नया संदेश नहीं है। नवीनतम ऑफ़र के लिए जल्द ही वापस देखें!',
      'te':
          'ప్రస్తుతం కొత్త సందేశాలు లేవు. తాజా ఆఫర్‌ల కోసం త్వరలో తిరిగి తనిఖీ చేయండి!',
    },
    'lpprsepq': {
      'en': 'Messages',
      'hi': 'संदेशों',
      'te': 'సందేశాలు',
    },
  },
  // Account_support
  {
    'ysdtmrd0': {
      'en': 'Account',
      'hi': '',
      'te': '',
    },
    'auf6ztu7': {
      'en': 'Go code Designers',
      'hi': '',
      'te': '',
    },
    '9bn2wxvo': {
      'en': 'Documents',
      'hi': 'सेटिंग्स',
      'te': 'సెట్టింగులు',
    },
    '34o7vjtz': {
      'en': 'Payment',
      'hi': 'सेटिंग्स',
      'te': 'సెట్టింగులు',
    },
    'fq1goojf': {
      'en': 'Tax info',
      'hi': 'सेटिंग्स',
      'te': 'సెట్టింగులు',
    },
    'd1egk9by': {
      'en': 'Edit Address',
      'hi': 'सेटिंग्स',
      'te': 'సెట్టింగులు',
    },
    'huk3perd': {
      'en': 'About',
      'hi': 'सेटिंग्स',
      'te': 'సెట్టింగులు',
    },
    'rvazl893': {
      'en': 'Insurance',
      'hi': 'सेटिंग्स',
      'te': 'సెట్టింగులు',
    },
    's6ev8eqo': {
      'en': 'Privacy',
      'hi': 'सेटिंग्स',
      'te': 'సెట్టింగులు',
    },
    '1gepgp40': {
      'en': 'Security',
      'hi': 'सेटिंग्स',
      'te': 'సెట్టింగులు',
    },
    'glh63usn': {
      'en': 'App Settings',
      'hi': 'सेटिंग्स',
      'te': 'సెట్టింగులు',
    },
    'accsup0001': {
      'en': 'Help',
      'hi': 'सहायता',
      'te': 'సహాయం',
    },
    'accsup0002': {
      'en': 'My Profile',
      'hi': 'मेरा प्रोफाइल',
      'te': 'నా ప్రొఫైల్',
    },
    'accsup0003': {
      'en': 'Rating',
      'hi': 'रेटिंग',
      'te': 'రేటింగ్',
    },
    'accsup0004': {
      'en': 'Trips',
      'hi': 'यात्राएं',
      'te': 'ప్రయాణాలు',
    },
    'accsup0005': {
      'en': 'Years',
      'hi': 'वर्ष',
      'te': 'సంవత్సరాలు',
    },
    'accsup0006': {
      'en': 'Documents',
      'hi': 'दस्तावेज़',
      'te': 'పత్రాలు',
    },
    'accsup0007': {
      'en': 'RC, DL, PAN & Insurance',
      'hi': 'RC, DL, PAN और बीमा',
      'te': 'RC, DL, PAN మరియు బీమా',
    },
    'accsup0008': {
      'en': 'Edit Address',
      'hi': 'पता संपादित करें',
      'te': 'చిరునామా సవరించండి',
    },
    'accsup0009': {
      'en': 'Update your address',
      'hi': 'अपना पता अपडेट करें',
      'te': 'మీ చిరునామాను నవీకరించండి',
    },
    'accsup0010': {
      'en': 'Refer & Earn',
      'hi': 'रेफर करें और कमाएं',
      'te': 'సూచించి సంపాదించండి',
    },
    'accsup0011': {
      'en': 'Invite friends, earn rewards',
      'hi': 'मित्रों को आमंत्रित करें, पुरस्कार कमाएं',
      'te': 'మిత్రులను ఆహ్వానించండి, బహుమతులు పొందండి',
    },
    'accsup0012': {
      'en': 'Terms & Conditions',
      'hi': 'नियम और शर्तें',
      'te': 'నిబంధనలు మరియు షరతులు',
    },
    'accsup0013': {
      'en': 'Legal information',
      'hi': 'कानूनी जानकारी',
      'te': 'చట్టపరమైన సమాచారం',
    },
    'accsup0014': {
      'en': 'Privacy Policy',
      'hi': 'गोपनीयता नीति',
      'te': 'గోప్యతా విధానం',
    },
    'accsup0015': {
      'en': 'How we handle your data',
      'hi': 'हम आपका डेटा कैसे संभालते हैं',
      'te': 'మీ డేటాను మేము ఎలా నిర్వహిస్తాము',
    },
    'accsup0016': {
      'en': 'Logout',
      'hi': 'लॉग आउट',
      'te': 'లాగ్ అవుట్',
    },
    'accsup0017': {
      'en': 'Are you sure you want to logout? You will need to sign in again to receive ride requests.',
      'hi': 'क्या आप वाकई लॉग आउट करना चाहते हैं? राइड अनुरोध प्राप्त करने के लिए आपको फिर से साइन इन करना होगा।',
      'te': 'మీరు నిజంగా లాగ్ అవుట్ కావాలనుకుంటున్నారా? రైడ్ అభ్యర్థనలు పొందడానికి మళ్లీ సైన్ ఇన్ చేయాలి.',
    },
    'accsup0018': {
      'en': 'Cancel',
      'hi': 'रद्द करें',
      'te': 'రద్దు',
    },
    'accsup0019': {
      'en': 'Delete Account',
      'hi': 'खाता हटाएं',
      'te': 'ఖాతా తొలగించండి',
    },
    'accsup0020': {
      'en': 'This action cannot be undone. All your data including ride history, earnings, and documents will be permanently deleted.\n\nAre you sure you want to delete your account?',
      'hi': 'यह कार्रवाई वापस नहीं की जा सकती। आपकी राइड हिस्ट्री, कमाई और दस्तावेज़ सहित सभी डेटा स्थायी रूप से हट जाएगा।\n\nक्या आप वाकई अपना खाता हटाना चाहते हैं?',
      'te': 'ఈ చర్యను తిరిగి రద్దు చేయలేము. మీ రైడ్ చరిత్ర, ఆదాయం మరియు పత్రాలు సహా మీ డేటా మొత్తం శాశ్వతంగా తొలగించబడుతుంది.\n\nమీరు నిజంగా మీ ఖాతాను తొలగించాలనుకుంటున్నారా?',
    },
    'accsup0021': {
      'en': 'Account deleted successfully',
      'hi': 'खाता सफलतापूर्वक हटाया गया',
      'te': 'ఖాతా విజయవంతంగా తొలగించబడింది',
    },
    'accsup0022': {
      'en': 'Failed to delete account',
      'hi': 'खाता हटाने में विफल',
      'te': 'ఖాతా తొలగించడం విఫలమైంది',
    },
    'accsup0023': {
      'en': 'Account deletion is not available. Your account has linked data. Please contact support.',
      'hi': 'खाता हटाना उपलब्ध नहीं है। आपके खाते से डेटा जुड़ा हुआ है। कृपया सहायता से संपर्क करें।',
      'te': 'ఖాతా తొలగింపు అందుబాటులో లేదు. మీ ఖాతాతో డేటా లింక్ అయి ఉంది. దయచేసి సహాయాన్ని సంప్రదించండి.',
    },
    'accsup0024': {
      'en': 'Error: ',
      'hi': 'त्रुटि: ',
      'te': 'లోపం: ',
    },
    'accsup0025': {
      'en': 'Driver Name',
      'hi': 'ड्राइवर नाम',
      'te': 'డ్రైవర్ పేరు',
    },
    'accsup0026': {
      'en': 'Logging out...',
      'hi': 'लॉग आउट हो रहा है...',
      'te': 'లాగ్ అవుతోంది...',
    },
    'accsup0027': {
      'en': 'Deleting...',
      'hi': 'हटाया जा रहा है...',
      'te': 'తొలగిస్తోంది...',
    },
  },
  // address_details
  {
    'ad0001': {
      'en': 'Address & Emergency',
      'hi': 'पता और आपातकालीन',
      'te': 'చిరునామా మరియు ఆపత్కాలీన',
    },
    'ad0002': {
      'en': 'Optional - Add for faster KYC verification',
      'hi': 'वैकल्पिक - तेजी से KYC सत्यापन के लिए जोड़ें',
      'te': 'ఐచ్ఛికం - వేగవంతమైన KYC ధృవీకరణ కోసం జోడించండి',
    },
    'ad0003': {
      'en': 'Date of Birth',
      'hi': 'जन्म तारीख',
      'te': 'జన్మ తేదీ',
    },
    'ad0004': {
      'en': 'YYYY-MM-DD or DD/MM/YYYY',
      'hi': 'YYYY-MM-DD या DD/MM/YYYY',
      'te': 'YYYY-MM-DD లేదా DD/MM/YYYY',
    },
    'ad0005': {
      'en': 'Address',
      'hi': 'पता',
      'te': 'చిరునామా',
    },
    'ad0006': {
      'en': 'Street, area',
      'hi': 'सड़क, क्षेत्र',
      'te': 'వీధి, ప్రాంతం',
    },
    'ad0007': {
      'en': 'City',
      'hi': 'शहर',
      'te': 'నగరం',
    },
    'ad0008': {
      'en': 'State',
      'hi': 'राज्य',
      'te': 'రాష్ట్రం',
    },
    'ad0009': {
      'en': 'Postal Code',
      'hi': 'डाकीय कोड',
      'te': 'పోస్టల్ కోడ్',
    },
    'ad0010': {
      'en': 'e.g. 500001',
      'hi': 'उदा. 500001',
      'te': 'ఉదా. 500001',
    },
    'ad0011': {
      'en': 'Emergency Contact',
      'hi': 'आपातकालीन संपर्क',
      'te': 'ఆపత్కాలీన సంప్రదింపు',
    },
    'ad0012': {
      'en': 'Contact Name',
      'hi': 'संपर्क नाम',
      'te': 'సంప్రదింపు పేరు',
    },
    'ad0013': {
      'en': 'Contact Phone',
      'hi': 'संपर्क फोन',
      'te': 'సంప్రదింపు ఫోన్',
    },
    'ad0014': {
      'en': '10-digit number',
      'hi': '10 अंकों की संख्या',
      'te': '10-అంకెల సంఖ్య',
    },
    'ad0015': {
      'en': 'Continue',
      'hi': 'जारी रखें',
      'te': 'కొనసాగించు',
    },
    'ad0016': {
      'en': 'Skip for now',
      'hi': 'अभी के लिए छोड़ दें',
      'te': 'ప్రస్తుతానికి దాటవేయండి',
    },
  },
  // support_ride
  {
    'gnde4jfz': {
      'en': 'Choose a trip',
      'hi': '',
      'te': '',
    },
  },
  // ride_overview
  {
    'hc5zvngx': {
      'en': 'Having an issue with a different\ndriver?',
      'hi': '',
      'te': '',
    },
    'y2ttgl8h': {
      'en': 'Get help',
      'hi': '',
      'te': '',
    },
    'ljppe8um': {
      'en': 'Moto ride with JILLA\nRAJENDRA PRASAD',
      'hi': '',
      'te': '',
    },
    'ehqd5nb0': {
      'en': 'Jan 18 11:12AM',
      'hi': '',
      'te': '',
    },
    'ygqiactr': {
      'en': '₹103.00',
      'hi': '',
      'te': '',
    },
    't13nqnia': {
      'en': 'Receipt',
      'hi': '',
      'te': '',
    },
    '858a9u1g': {
      'en': 'Invoice',
      'hi': '',
      'te': '',
    },
    '3g341fjq': {
      'en': 'Secunderabad, Telangana 500003,\nIndia',
      'hi': '',
      'te': '',
    },
    'gvct7vaz': {
      'en': '11:23 AM',
      'hi': '',
      'te': '',
    },
    'wj0fb88l': {
      'en':
          '16-11-477/1, Shashi Hospital Ln, Indira\nNagar, Dilsukhnagar, Hyderabad, Tela...',
      'hi': '',
      'te': '',
    },
    'v96p81tf': {
      'en': '11:59 AM',
      'hi': '',
      'te': '',
    },
    'xtwustmq': {
      'en': 'No tip added',
      'hi': '',
      'te': '',
    },
    'zfv9e386': {
      'en': 'No rating',
      'hi': '',
      'te': '',
    },
    'e3d5d8wp': {
      'en': 'Help & safety',
      'hi': '',
      'te': '',
    },
    'fii1tu3m': {
      'en': 'Find lost item',
      'hi': '',
      'te': '',
    },
    '8hzyd342': {
      'en': 'We can help you get in touch with your\ndriver',
      'hi': '',
      'te': '',
    },
    'w778vvv7': {
      'en': 'Report safety issue',
      'hi': '',
      'te': '',
    },
    '8jdx0bd7': {
      'en': 'Report any safety related issues to us',
      'hi': '',
      'te': '',
    },
    '2627acjm': {
      'en': 'Customer support',
      'hi': '',
      'te': '',
    },
    '6b25o08x': {
      'en': 'Ride details',
      'hi': '',
      'te': '',
    },
  },
  // Report_issues
  {
    'leew4lf2': {
      'en': 'Safety',
      'hi': '',
      'te': '',
    },
    'kje7no8j': {
      'en': 'My driver didn\'t match the profile in my app',
      'hi': '',
      'te': '',
    },
    'ua7essc9': {
      'en': 'My driver\'s vehicle was different',
      'hi': '',
      'te': '',
    },
    'ni50t98o': {
      'en': 'Report inappropriate driver behaviour',
      'hi': '',
      'te': '',
    },
    '95bcajt9': {
      'en': 'I was involved in an accident',
      'hi': '',
      'te': '',
    },
    'yi3xzmc0': {
      'en': 'My driver\'s vehicle was unsafe or broke down',
      'hi': '',
      'te': '',
    },
    'a1507nfa': {
      'en': 'Report safety issue',
      'hi': '',
      'te': '',
    },
  },
  // Customer_support
  {
    'bj4b2zwh': {
      'en': 'Wed, Aug 13, 3:50 PM',
      'hi': '',
      'te': '',
    },
    'ajsw9xpw': {
      'en': 'Hi Naresh, welcome to customer support.',
      'hi': '',
      'te': '',
    },
    '1c03oj7k': {
      'en':
          'If you\'re reaching out about the price you paid for this ride, unfortunately it is too late to review it.',
      'hi': '',
      'te': '',
    },
    'ii0ixfby': {
      'en':
          'In the future, if you need support with a ride\'s price, please contact us as soon as possible so we can help. I can still help with the following options. If you\'d like to share feedback about the driver or vehicle, please select that option below.',
      'hi': '',
      'te': '',
    },
    'gopklq8z': {
      'en': 'Share feedback about the driver or vehicle',
      'hi': '',
      'te': '',
    },
    'kt5woz1j': {
      'en': 'That\'s all I need',
      'hi': '',
      'te': '',
    },
    'zpy3yojt': {
      'en': 'Help with something else',
      'hi': '',
      'te': '',
    },
    '7uibnal3': {
      'en': 'Customer support',
      'hi': '',
      'te': '',
    },
  },
  // Book_sucessfull
  {
    '88qi4lhh': {
      'en': 'Otp :',
      'hi': '',
      'te': '',
    },
    'n36b4xti': {
      'en': '2',
      'hi': '',
      'te': '',
    },
    'yb3qxw4x': {
      'en': '5',
      'hi': '',
      'te': '',
    },
    'xvghbrv2': {
      'en': '4',
      'hi': '',
      'te': '',
    },
    'pdplo6jz': {
      'en': '2',
      'hi': '',
      'te': '',
    },
    'z1rynwit': {
      'en': 'AP28TA',
      'hi': '',
      'te': '',
    },
    '2dgclytm': {
      'en': '2',
      'hi': '',
      'te': '',
    },
    's2ppwd0m': {
      'en': '5',
      'hi': '',
      'te': '',
    },
    'lnc7td6b': {
      'en': '4',
      'hi': '',
      'te': '',
    },
    'x84wnc38': {
      'en': '2',
      'hi': '',
      'te': '',
    },
    'zao712re': {
      'en': 'Name : Bharath',
      'hi': '',
      'te': '',
    },
    'k9ut8cez': {
      'en': 'Rating :',
      'hi': '',
      'te': '',
    },
    'xuero9r2': {
      'en': '4.6',
      'hi': '',
      'te': '',
    },
    '4vnlodv0': {
      'en': ': Dilsukhnagar',
      'hi': '',
      'te': '',
    },
    'xu50sls1': {
      'en': ': Ameerpet',
      'hi': '',
      'te': '',
    },
    's5ihqfjt': {
      'en': 'Amount',
      'hi': '',
      'te': '',
    },
    'y6tax9ap': {
      'en': '₹76.00',
      'hi': '',
      'te': '',
    },
    '4p03da39': {
      'en': 'Distance : 15km',
      'hi': '',
      'te': '',
    },
    'zawb7u8r': {
      'en': 'Cancel',
      'hi': 'रद्द करना',
      'te': 'రద్దు చేయి',
    },
  },
  // cancel_ride
  {
    'ohc1zeqa': {
      'en': '🚕',
      'hi': '',
      'te': '',
    },
    'eyqf5dyn': {
      'en': 'Driver delayed too long',
      'hi': '',
      'te': '',
    },
    'nz6u65ls': {
      'en': '📞',
      'hi': '',
      'te': '',
    },
    'i2pyehba': {
      'en': 'Unable to contact driver',
      'hi': '',
      'te': '',
    },
    'bcer8eaw': {
      'en': '📍',
      'hi': '',
      'te': '',
    },
    '1j1jnqj4': {
      'en': 'Wrong pickup location',
      'hi': '',
      'te': '',
    },
    'vchg0nsl': {
      'en': '❌',
      'hi': '',
      'te': '',
    },
    'q43sw3j7': {
      'en': 'Change in travel plan',
      'hi': '',
      'te': '',
    },
    'g8a3tgmz': {
      'en': '💸',
      'hi': '',
      'te': '',
    },
    'adfjszay': {
      'en': 'Fare is too high',
      'hi': '',
      'te': '',
    },
    '6kdzzyh9': {
      'en': '👥',
      'hi': '',
      'te': '',
    },
    'djwquulj': {
      'en': 'Booked by mistake',
      'hi': '',
      'te': '',
    },
    'iyy10m4d': {
      'en': '🛑',
      'hi': '',
      'te': '',
    },
    'su8wk1sl': {
      'en': 'Safety concerns',
      'hi': '',
      'te': '',
    },
    'igi6n2xn': {
      'en': 'others',
      'hi': '',
      'te': '',
    },
    'qhfrthhl': {
      'en': 'Submit',
      'hi': '',
      'te': '',
    },
    '0bgtqxm5': {
      'en': 'Cancel Ride Options',
      'hi': '',
      'te': '',
    },
  },
  // Add_stop
  {
    '0b9t1w3t': {
      'en': 'Where to go ?',
      'hi': '',
      'te': '',
    },
    '742chcyj': {
      'en': '',
      'hi': '',
      'te': '',
    },
    'p3hnvsn1': {
      'en': 'Where to go ?',
      'hi': '',
      'te': '',
    },
    'k8xb627q': {
      'en': 'Select Location',
      'hi': '',
      'te': '',
    },
    'urdfohz6': {
      'en': 'Rajiv Gandhi airport',
      'hi': 'राजीव गांधी हवाई अड्डा',
      'te': 'రాజీవ్ గాంధీ విమానాశ్రయం',
    },
    '2u1lja4w': {
      'en': 'Shamshad Hyderabad, airport',
      'hi': 'शमशाद हैदराबाद, हवाई अड्डा',
      'te': 'షంషాద్ హైదరాబాద్ విమానాశ్రయం',
    },
    'jksc2tm1': {
      'en': '12km',
      'hi': '12 किमी',
      'te': '12 కి.మీ',
    },
    'kd5cum4o': {
      'en': 'Search in different city',
      'hi': 'अलग शहर में खोजें',
      'te': 'వేరే నగరంలో శోధించండి',
    },
    'k8cz6ggv': {
      'en': 'Set location on map',
      'hi': 'मानचित्र पर स्थान सेट करें',
      'te': 'మ్యాప్‌లో స్థానాన్ని సెట్ చేయండి',
    },
    '36lo0tu4': {
      'en': 'Saved places',
      'hi': 'सहेजे गए स्थान',
      'te': 'సేవ్ చేసిన స్థలాలు',
    },
    'c4m6gzcd': {
      'en': 'Add a stop',
      'hi': '',
      'te': '',
    },
  },
  // detailspageCopy
  {
    'ya832hbh': {
      'en': 'We need your sign-in details to get started',
      'hi': 'कृपया अपना पूरा नाम दर्ज करें',
      'te': 'దయచేసి మీ పూర్తి పేరును నమోదు చేయండి.',
    },
    'nfdpne0v': {
      'en': ' choose when, where, and how you work',
      'hi': 'कृपया अपना पूरा नाम दर्ज करें',
      'te': 'దయచేసి మీ పూర్తి పేరును నమోదు చేయండి.',
    },
    'j4j5fqua': {
      'en': 'Email Address',
      'hi': 'पहला नाम',
      'te': 'మొదటి పేరు',
    },
    'ohq0v00u': {
      'en': '*',
      'hi': '*',
      'te': '*',
    },
    'cnjc2umj': {
      'en': 'Continue',
      'hi': 'जारी रखना',
      'te': 'కొనసాగించు',
    },
    'fjlya6jm': {
      'en': 'Earn on your terms with Ugo',
      'hi': 'कृपया अपना पूरा नाम दर्ज करें',
      'te': 'దయచేసి మీ పూర్తి పేరును నమోదు చేయండి.',
    },
  },
  // Details_p1
  {
    'oxfwca81': {
      'en': 'Earn on your terms with Ugo',
      'hi': '',
      'te': '',
    },
    'iirkojwa': {
      'en': 'choose when, where, and how you work',
      'hi': '',
      'te': '',
    },
    'gwg3ksgw': {
      'en': 'Referral code',
      'hi': '',
      'te': '',
    },
    'krnpfx67': {
      'en': 'Continue',
      'hi': '',
      'te': '',
    },
    'bajybvx1': {
      'en': 'Home',
      'hi': '',
      'te': '',
    },
  },
  // Choose_vehicle
  {
    'n5wkquh8': {
      'en': 'Choose How You Want to Earn with Ugo',
      'hi': 'UGO के साथ आप कैसे कमाना चाहते हैं चुनें',
      'te': 'UGO తో మీరు ఎలా సంపాదించాలనుకుంటున్నారో ఎంచుకోండి',
    },
    'uhrogttt': {
      'en': 'Continue',
      'hi': 'जारी रखें',
      'te': 'కొనసాగించు',
    },
    'cv0001': {
      'en': 'Vehicle Type',
      'hi': 'वाहन प्रकार',
      'te': 'వాహన రకం',
    },
    'cv0002': {
      'en': 'How do you want to earn?',
      'hi': 'आप कैसे कमाना चाहते हैं?',
      'te': 'మీరు ఎలా సంపాదించాలనుకుంటున్నారు?',
    },
    'cv0003': {
      'en': 'No vehicles available',
      'hi': 'कोई वाहन उपलब्ध नहीं है',
      'te': 'వాహనాలు అందుబాటులో లేవు',
    },
    'cv0004': {
      'en': 'Unknown',
      'hi': 'अज्ञात',
      'te': 'తెలియదు',
    },
    'cv0005': {
      'en': 'Failed to load vehicles',
      'hi': 'वाहन लोड करने में विफल',
      'te': 'వాహనాలను లోడ్ చేయడం విఫలమైంది',
    },
    'cv0006': {
      'en': 'Retry',
      'hi': 'पुनः प्रयास करें',
      'te': 'మళ్లీ ప్రయత్నించండి',
    },
    '7bszawn6': {
      'en': 'U G O',
      'hi': '',
      'te': '',
    },
    'chpyrniv': {
      'en': 'Home',
      'hi': '',
      'te': '',
    },
  },
  // on_boarding
  {
    'gy1r3xab': {
      'en': 'Welcome, Naresh',
      'hi': '',
      'te': '',
    },
    'gymcdncw': {
      'en': 'Complete the following steps to set up your account',
      'hi': 'अपने खाते को सेटअप करने के लिए निम्न चरण पूरे करें',
      'te': 'మీ ఖాతాను సెటప్ చేయడానికి క్రింది దశలను పూర్తి చేయండి',
    },
    'qg68530z': {
      'en': 'Driving License',
      'hi': 'ड्राइविंग लाइसेंस',
      'te': 'డ్రైవింగ్ లైసెన్స్',
    },
    'mnqkwauk': {
      'en': 'Recommended next step',
      'hi': '',
      'te': '',
    },
    'k8fnkaky': {
      'en': 'Profile Picture',
      'hi': 'प्रोफ़ाइल फोटो',
      'te': 'ప్రొఫైల్ ఫోటో',
    },
    'c0kv9v5c': {
      'en': 'Aadhaar Card',
      'hi': 'आधार कार्ड',
      'te': 'ఆధార్ కార్డు',
    },
    'ymy7qbgz': {
      'en': 'Pan Card',
      'hi': 'पैन कार्ड',
      'te': 'పాన్ కార్డు',
    },
    'jqs0l5w3': {
      'en': 'Vehicle photo verification',
      'hi': 'वाहन फोटो सत्यापन',
      'te': 'వాహన ఫోటో ధృవీకరణ',
    },
    'ipks4vgn': {
      'en': 'Registration Certificate (RC)',
      'hi': 'पंजीकरण प्रमाणपत्र (RC)',
      'te': 'నమోదు సర్టిఫికేట్ (RC)',
    },
    'ob0001': {
      'en': 'Setup Profile',
      'hi': 'प्रोफ़ाइल सेटअप करें',
      'te': 'ప్రొఫైల్ సెటప్',
    },
    'ob0002': {
      'en': '%1% Done',
      'hi': '%1% पूरा',
      'te': '%1% పూర్తైంది',
    },
    'ob0003': {
      'en': 'Required Documents',
      'hi': 'आवश्यक दस्तावेज़',
      'te': 'అవసరమైన పత్రాలు',
    },
    'ob0004': {
      'en': 'Submit for Verification',
      'hi': 'सत्यापन के लिए सबमिट करें',
      'te': 'ధృవీకరణకు సమర్పించండి',
    },
    'ob0005': {
      'en': 'Skip',
      'hi': 'छोड़ें',
      'te': 'దాటవేయండి',
    },
    'ob0006': {
      'en': 'Uploaded',
      'hi': 'अपलोड किया गया',
      'te': 'అప్‌లోడ్ైంది',
    },
    'ob0007': {
      'en': 'Tap to upload',
      'hi': 'अपलोड करने के लिए टैप करें',
      'te': 'అప్‌లోడ్ చేయడానికి ట్యాప్ చేయండి',
    },
    'ob0008': {
      'en': 'Verification Required',
      'hi': 'सत्यापन आवश्यक',
      'te': 'ధృవీకరణ అవసరం',
    },
    'ob0009': {
      'en': 'Please fix the following before submitting:',
      'hi': 'सबमिट करने से पहले निम्न ठीक करें:',
      'te': 'సమర్పించే ముందు ఇవి సరిచేయండి:',
    },
    'ob0010': {
      'en': 'Incomplete Profile',
      'hi': 'अधूरी प्रोफ़ाइल',
      'te': 'అపూర్ణ ప్రొఫైల్',
    },
    'ob0011': {
      'en': "You won't be able to go online until all documents are verified. Continue anyway?",
      'hi': 'जब तक सभी दस्तावेज़ सत्यापित नहीं होते, आप ऑनलाइन नहीं जा सकेंगे। फिर भी जारी रखें?',
      'te': 'అన్ని పత్రాలు ధృవీకరించబడే వరకు మీరు ఆన్‌లైన్‌లోకి వెళ్లలేరు. అయినా కొనసాగాలా?',
    },
    'ob0012': {
      'en': 'Registration complete. Please sign in to continue.',
      'hi': 'पंजीकरण पूरा हुआ। जारी रखने के लिए साइन इन करें।',
      'te': 'నమోదు పూర్తైంది. కొనసాగడానికి సైన్ ఇన్ చేయండి.',
    },
    'ob0013': {
      'en': 'Registration Failed',
      'hi': 'पंजीकरण विफल',
      'te': 'నమోదు విఫలమైంది',
    },
    'grevajyl': {
      'en': 'Register',
      'hi': 'सत्यापित करें',
      'te': 'ధృవీకరించండి',
    },
    '1zwx91lm': {
      'en': 'UGO',
      'hi': '',
      'te': '',
    },
    'gwebwsk0': {
      'en': 'Home',
      'hi': '',
      'te': '',
    },
  },
  // Driving_dl
  {
    '1adxycv9': {
      'en': 'UGQ TAXI',
      'hi': '',
      'te': '',
    },
    'xxboi6jx': {
      'en': 'Take a picture of your driving license for verification',
      'hi': '',
      'te': '',
    },
    '3ztjdjtl': {
      'en':
          'Please upload a clear photo of the front side and back side of your driver\'s license. Make sure all text is clearly visible and the image is not blurred. This helps us verify your identity quickly and securely.',
      'hi': '',
      'te': '',
    },
    '5et5mb7v': {
      'en': 'Take Photo',
      'hi': '',
      'te': '',
    },
  },
  // face_verify
  {
    '4x5qzh2a': {
      'en': 'UGO TAXI',
      'hi': '',
      'te': '',
    },
    'jb35bi98': {
      'en': 'Take your profile photo',
      'hi': '',
      'te': '',
    },
    '8g67ujss': {
      'en':
          'Your profile photo helps others recognize you and builds trust in our community',
      'hi': '',
      'te': '',
    },
    'gp52hikk': {
      'en': 'Make sure your face is clearly visible and well-lit',
      'hi': '',
      'te': '',
    },
    'cwpexs55': {
      'en': 'Remove sunglasses, hats, or anything covering your face',
      'hi': '',
      'te': '',
    },
    'cx7kd7oq': {
      'en': 'Use a recent photo that looks like you',
      'hi': '',
      'te': '',
    },
    'yatg8h7p': {
      'en': 'Take photo',
      'hi': '',
      'te': '',
    },
  },
  // Adhar_Upload
  {
    'gevrq6og': {
      'en': 'Take a photo of your Aadhaar card',
      'hi': '',
      'te': '',
    },
    'v9g63czf': {
      'en':
          '• Make sure all four corners of your Aadhaar card are visible\n• Ensure the text is clear and readable\n• Avoid shadows and glare\n• Keep the card flat and straight',
      'hi': '',
      'te': '',
    },
    'ugnycsbu': {
      'en': 'Take photo',
      'hi': '',
      'te': '',
    },
    '932jflc2': {
      'en': 'UGQ TAXI',
      'hi': '',
      'te': '',
    },
  },
  // Upload_rc
  {
    'pbyekz0w': {
      'en': 'Let’s find your registration certificate (RC)',
      'hi': '',
      'te': '',
    },
    'e8g5muj9': {
      'en':
          'Enter your vehicle registration number to search for your certificate, or upload your documents manually if needed.',
      'hi': '',
      'te': '',
    },
    'toev289b': {
      'en': 'Enter vehicle registration number',
      'hi': '',
      'te': '',
    },
    'jvl4q2p4': {
      'en': 'Upload documents instead',
      'hi': '',
      'te': '',
    },
    '25gderrw': {
      'en': 'Continue',
      'hi': '',
      'te': '',
    },
    'iquflyhj': {
      'en': 'UGQ TAXI',
      'hi': '',
      'te': '',
    },
  },
  // RC_upload
  {
    '8grbcx0q': {
      'en': 'Take a photo of your registration certificate (RC)',
      'hi': '',
      'te': '',
    },
    'zr3quzqv': {
      'en':
          'By taking this photo, you consent to UGQ TAXI processing your registration certificate information for verification purposes. Your data will be handled securely and in accordance with our privacy policy. Please ensure the document is clearly visible and all text is readable.',
      'hi': '',
      'te': '',
    },
    'dqgmjp2r': {
      'en': 'Take photo',
      'hi': '',
      'te': '',
    },
    'hllykqk3': {
      'en': 'UGQ TAXI',
      'hi': '',
      'te': '',
    },
  },
  // inboxPage
  {
    'nty55wsd': {
      'en': 'Notifications',
      'hi': '',
      'te': '',
    },
    'd6jqm9ie': {
      'en': 'Support',
      'hi': '',
      'te': '',
    },
    'yk1kpsjg': {
      'en': 'inbox',
      'hi': '',
      'te': '',
    },
    'lh8gd4z4': {
      'en': 'Home',
      'hi': '',
      'te': '',
    },
  },
  // invitePage
  {
    '7xta2ktn': {
      'en': 'Refer Friend',
      'hi': '',
      'te': '',
    },
    'em04mmgl': {
      'en': 'Home',
      'hi': '',
      'te': '',
    },
  },
  // teampage
  {
    'vnara3f7': {
      'en': 'Bharath / T3',
      'hi': '',
      'te': '',
    },
    'd2yhnnfq': {
      'en': 'Anand / T5',
      'hi': '',
      'te': '',
    },
    '5s5fdfzw': {
      'en': 'Total rides',
      'hi': '',
      'te': '',
    },
    'ucta21pk': {
      'en': '240',
      'hi': '',
      'te': '',
    },
    'rd40uyls': {
      'en': 'Total earnings',
      'hi': '',
      'te': '',
    },
    '2uavdr8q': {
      'en': '240',
      'hi': '',
      'te': '',
    },
    '1g48gy8t': {
      'en': 's/no',
      'hi': '',
      'te': '',
    },
    '5mrz4d7g': {
      'en': 'Names',
      'hi': '',
      'te': '',
    },
    'zl9smx3d': {
      'en': 'Vehicle no :',
      'hi': '',
      'te': '',
    },
    'a648fgo9': {
      'en': 'Today',
      'hi': '',
      'te': '',
    },
    'pca74cj7': {
      'en': '1',
      'hi': '',
      'te': '',
    },
    'o0n66ayh': {
      'en': 'Ramesh',
      'hi': '',
      'te': '',
    },
    'rvyfttlk': {
      'en': '4489',
      'hi': '',
      'te': '',
    },
    'o88epopw': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    'skz8hmiz': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    '892h4d0w': {
      'en': '2',
      'hi': '',
      'te': '',
    },
    '0vnjwsbh': {
      'en': 'Bharath',
      'hi': '',
      'te': '',
    },
    'oa0vdrpj': {
      'en': '4489',
      'hi': '',
      'te': '',
    },
    '4uy86ma2': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    'g8rh9wtd': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    'kqbvc0d0': {
      'en': '3',
      'hi': '',
      'te': '',
    },
    '00xk7d5t': {
      'en': 'Anand',
      'hi': '',
      'te': '',
    },
    'yteplb9j': {
      'en': '4489',
      'hi': '',
      'te': '',
    },
    'h977xldo': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    'rbbmg9ee': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    'fwkh36h1': {
      'en': '4',
      'hi': '',
      'te': '',
    },
    'ewomhnp3': {
      'en': 'Ramesh',
      'hi': '',
      'te': '',
    },
    'h00k3nhx': {
      'en': '4489',
      'hi': '',
      'te': '',
    },
    '7dqf61mz': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    '4zu0gpzs': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    'lja99gvt': {
      'en': '5',
      'hi': '',
      'te': '',
    },
    'gvxa03jf': {
      'en': 'Bharath',
      'hi': '',
      'te': '',
    },
    'a4qukhzw': {
      'en': '4489',
      'hi': '',
      'te': '',
    },
    'o63bf2ka': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    'aeoyycfx': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    'clvgl9ed': {
      'en': 'My Team',
      'hi': '',
      'te': '',
    },
    'hcwrcmg6': {
      'en': 'Home',
      'hi': '',
      'te': '',
    },
  },
  // teamrides
  {
    'xfnx6i08': {
      'en': 'My Team',
      'hi': '',
      'te': '',
    },
    'oo99znau': {
      'en': 'Home',
      'hi': '',
      'te': '',
    },
  },
  // teamEarnings
  {
    'k2gyrp5k': {
      'en': 'Total Earnings',
      'hi': '',
      'te': '',
    },
    'vrz6y55l': {
      'en': 'Home',
      'hi': '',
      'te': '',
    },
  },
  // firstdetails
  {
    'nh50n2jd': {
      'en': 'We need your sign-in details to get started',
      'hi': '',
      'te': '',
    },
    'g1uc4h7t': {
      'en': 'First Name',
      'hi': '',
      'te': '',
    },
    'u8lnzlcn': {
      'en': 'Last Name',
      'hi': '',
      'te': '',
    },
    'o2sldx3m': {
      'en': 'Email Address',
      'hi': '',
      'te': '',
    },
    'tygs9jrf': {
      'en': 'Continue',
      'hi': '',
      'te': '',
    },
    'vlrozm99': {
      'en': 'Home',
      'hi': '',
      'te': '',
    },
  },
  // panuploadScreen
  {
    '2ow0uxza': {
      'en': 'Pan Upload',
      'hi': '',
      'te': '',
    },
    'ngrq7btb': {
      'en': 'Take a photo of your Pan card',
      'hi': '',
      'te': '',
    },
    '4qhipqt5': {
      'en':
          '• Make sure all four corners of your Pan card are visible\n• Ensure the text is clear and readable\n• Avoid shadows and glare\n• Keep the card flat and straight',
      'hi': '',
      'te': '',
    },
    '6p898w2h': {
      'en': 'Take photo',
      'hi': '',
      'te': '',
    },
    '7d1d867w': {
      'en': 'Home',
      'hi': '',
      'te': '',
    },
  },
  // vehicleImage
  {
    'mbrwn8ps': {
      'en': 'vehicle Image',
      'hi': '',
      'te': '',
    },
    'olk3hlpk': {
      'en': 'Take a photo of your Vehcle Image',
      'hi': '',
      'te': '',
    },
    '3n24su23': {
      'en': '• Make sure  Vehicle Image visible Clearly\n\n',
      'hi': '',
      'te': '',
    },
    'qgrwzepa': {
      'en': 'Take photo',
      'hi': '',
      'te': '',
    },
    'uv8us9tg': {
      'en': 'Home',
      'hi': '',
      'te': '',
    },
  },
  // RegistrationImage
  {
    '3i8p9kjl': {
      'en': 'Take a photo of your registration certificate (RC)',
      'hi': '',
      'te': '',
    },
    'kffyk3cw': {
      'en':
          'By taking this photo, you consent to UGQ TAXI processing your registration certificate information for verification purposes. Your data will be handled securely and in accordance with our privacy policy. Please ensure the document is clearly visible and all text is readable.',
      'hi': '',
      'te': '',
    },
    'gewz9k80': {
      'en': 'Take photo',
      'hi': '',
      'te': '',
    },
    '4w9lgnq9': {
      'en': 'Registration Image',
      'hi': '',
      'te': '',
    },
    'bx00za2f': {
      'en': 'Home',
      'hi': '',
      'te': '',
    },
  },
  // Menu
  {
    'dc4d2jzu': {
      'en': 'Home',
      'hi': 'घर',
      'te': 'హొమ్ పేజ్',
    },
    '7gtos5g5': {
      'en': 'Services',
      'hi': '',
      'te': '',
    },
    'b6qjqpkc': {
      'en': 'History',
      'hi': '',
      'te': '',
    },
    'yzazzu72': {
      'en': 'Account',
      'hi': '',
      'te': '',
    },
  },
  // ride_detais
  {
    'nqlh5yse': {
      'en': '1/18/25, 11:12 AM',
      'hi': '',
      'te': '',
    },
    'hpgy10eh': {
      'en': 'Hero Glamour',
      'hi': '',
      'te': '',
    },
    'dm3vkyld': {
      'en': '₹103.00',
      'hi': '',
      'te': '',
    },
    'e7sn691y': {
      'en': 'CASH',
      'hi': '',
      'te': '',
    },
  },
  // details
  {
    'ut99qmg2': {
      'en': 'Earn on your terms with Ugo',
      'hi': '',
      'te': '',
    },
    '25q4qxzy': {
      'en': 'choose when, where, and how you work',
      'hi': '',
      'te': '',
    },
    'kcs0ols5': {
      'en': 'Referral code',
      'hi': '',
      'te': '',
    },
    'gcrskycu': {
      'en': 'Continue',
      'hi': '',
      'te': '',
    },
  },
  // Vehicle
  {
    '1irb145s': {
      'en': 'Choose How You Want to Earn with Ugo',
      'hi': '',
      'te': '',
    },
    '566mujas': {
      'en': '',
      'hi': '',
      'te': '',
    },
    '709wrpn4': {
      'en': '',
      'hi': '',
      'te': '',
    },
    'wczmqr2s': {
      'en': '',
      'hi': '',
      'te': '',
    },
    'q21dqnjj': {
      'en': 'Continue',
      'hi': '',
      'te': '',
    },
  },
  // inbox
  {
    '3uts8bvx': {
      'en': '2:93 PM',
      'hi': '',
      'te': '',
    },
    '5041d8s3': {
      'en': 'Inbox',
      'hi': '',
      'te': '',
    },
    'cg037o9l': {
      'en': 'Notifications',
      'hi': '',
      'te': '',
    },
    '5ey5qqji': {
      'en': 'Support',
      'hi': '',
      'te': '',
    },
    '4yh91f1o': {
      'en': 'Keep your Ugo account safe',
      'hi': '',
      'te': '',
    },
    'rql4r1hw': {
      'en': '2 days ago',
      'hi': '',
      'te': '',
    },
    'pxm6rbm5': {
      'en': 'Update your profile',
      'hi': '',
      'te': '',
    },
    '27507joi': {
      'en': '3 days ago',
      'hi': '',
      'te': '',
    },
    'u30bv2v7': {
      'en': 'Don\'t miss the motorbike',
      'hi': '',
      'te': '',
    },
    'lwwj6rvb': {
      'en': '3 days ago',
      'hi': '',
      'te': '',
    },
    'dw81la11': {
      'en': 'Keep your Ugo account safe',
      'hi': '',
      'te': '',
    },
    '19ofnr7o': {
      'en': '2 days ago',
      'hi': '',
      'te': '',
    },
    'krkgpa6x': {
      'en': 'Update your profile',
      'hi': '',
      'te': '',
    },
    'p9crrocl': {
      'en': '3 days ago',
      'hi': '',
      'te': '',
    },
    'zjcsjdap': {
      'en': 'Don\'t miss the motorbike',
      'hi': '',
      'te': '',
    },
    '7h21kp4t': {
      'en': '3 days ago',
      'hi': '',
      'te': '',
    },
    '6jaucaf6': {
      'en': 'Keep your Ugo account safe',
      'hi': '',
      'te': '',
    },
    'lfkrbhfd': {
      'en': '2 days ago',
      'hi': '',
      'te': '',
    },
    'hzr5jw8l': {
      'en': 'Update your profile',
      'hi': '',
      'te': '',
    },
    'jnxnd450': {
      'en': '3 days ago',
      'hi': '',
      'te': '',
    },
    't0slnp3h': {
      'en': 'Don\'t miss the motorbike',
      'hi': '',
      'te': '',
    },
    'ez5iecbw': {
      'en': '3 days ago',
      'hi': '',
      'te': '',
    },
    '95ec5ivr': {
      'en': 'Keep your Ugo account safe',
      'hi': '',
      'te': '',
    },
    'ymr3m56d': {
      'en': '2 days ago',
      'hi': '',
      'te': '',
    },
    'haamdbws': {
      'en': 'Update your profile',
      'hi': '',
      'te': '',
    },
    '8k4ipkl4': {
      'en': '3 days ago',
      'hi': '',
      'te': '',
    },
    'ybtihk1c': {
      'en': 'Don\'t miss the motorbike',
      'hi': '',
      'te': '',
    },
    'jklmcpt8': {
      'en': '3 days ago',
      'hi': '',
      'te': '',
    },
  },
  // invite
  {
    'npfnoox3': {
      'en': 'Share your link',
      'hi': '',
      'te': '',
    },
    'vfotgfnq': {
      'en':
          'Invite them now through the Ugo Driver App and get cash rewards when they complete their first ride!',
      'hi': '',
      'te': '',
    },
    'x632ugvm': {
      'en': 'Ugo.referal.friends',
      'hi': '',
      'te': '',
    },
    'dxodtrzn': {
      'en': 'Copy',
      'hi': '',
      'te': '',
    },
    'uyzyvuqi': {
      'en': 'More ways share',
      'hi': '',
      'te': '',
    },
  },
  // team1
  {
    'ombr48r7': {
      'en': 'My team',
      'hi': '',
      'te': '',
    },
    'nzfoesqh': {
      'en': 'Bharath / T3',
      'hi': '',
      'te': '',
    },
    'fpsvbzsj': {
      'en': 'Anand / T5',
      'hi': '',
      'te': '',
    },
    'd8jyewpf': {
      'en': 'Total rides',
      'hi': '',
      'te': '',
    },
    'wwechcyk': {
      'en': '240',
      'hi': '',
      'te': '',
    },
    '2di732pq': {
      'en': 'Total earnings',
      'hi': '',
      'te': '',
    },
    '96bassro': {
      'en': '240',
      'hi': '',
      'te': '',
    },
    'l8wbom0d': {
      'en': 's/no',
      'hi': '',
      'te': '',
    },
    'xfzlklrk': {
      'en': 'Names',
      'hi': '',
      'te': '',
    },
    'zscs8euz': {
      'en': 'Vehicle no :',
      'hi': '',
      'te': '',
    },
    '2btl132x': {
      'en': 'Yesterday',
      'hi': '',
      'te': '',
    },
    'ut7ohsmr': {
      'en': 'Today',
      'hi': '',
      'te': '',
    },
    '13ks2yr9': {
      'en': '1',
      'hi': '',
      'te': '',
    },
    'xw9ohfl0': {
      'en': 'Ramesh',
      'hi': '',
      'te': '',
    },
    'ykbpliby': {
      'en': '4489',
      'hi': '',
      'te': '',
    },
    '8i64toaw': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    'z7luspas': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    'ragszkx8': {
      'en': '2',
      'hi': '',
      'te': '',
    },
    'is2hvcx1': {
      'en': 'Bharath',
      'hi': '',
      'te': '',
    },
    '3riv8j27': {
      'en': '4489',
      'hi': '',
      'te': '',
    },
    '8zavdwib': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    '0mfvej84': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    '8hor401v': {
      'en': '3',
      'hi': '',
      'te': '',
    },
    'y4243p7s': {
      'en': 'Anand',
      'hi': '',
      'te': '',
    },
    '2ltinyz9': {
      'en': '4489',
      'hi': '',
      'te': '',
    },
    '2m1hgteq': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    '2isa91l8': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    'zkkw19vn': {
      'en': '4',
      'hi': '',
      'te': '',
    },
    'xuet2mqq': {
      'en': 'Ramesh',
      'hi': '',
      'te': '',
    },
    'me7paxcc': {
      'en': '4489',
      'hi': '',
      'te': '',
    },
    'ifvsgpyy': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    'gx5neslt': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    'oj923nnk': {
      'en': '5',
      'hi': '',
      'te': '',
    },
    'vpcnancr': {
      'en': 'Bharath',
      'hi': '',
      'te': '',
    },
    'tgib1ctn': {
      'en': '4489',
      'hi': '',
      'te': '',
    },
    '8fhmrgzf': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    'j3dpovkd': {
      'en': '10',
      'hi': '',
      'te': '',
    },
  },
  // teamride
  {
    'sk7j9i27': {
      'en': 'Anand / TI',
      'hi': '',
      'te': '',
    },
    '4gxsceb5': {
      'en': '14-07-25 Monday',
      'hi': '',
      'te': '',
    },
    'w7yc95kv': {
      'en': 'Daily',
      'hi': '',
      'te': '',
    },
    'cfqkw8j8': {
      'en': 'Total rides',
      'hi': '',
      'te': '',
    },
    's9uff3yo': {
      'en': '240',
      'hi': '',
      'te': '',
    },
    'cpyyg93r': {
      'en': 'Total earnings',
      'hi': '',
      'te': '',
    },
    'czo6r2ra': {
      'en': '12000',
      'hi': '',
      'te': '',
    },
    'biv4ge9x': {
      'en': 'Total earnings',
      'hi': '',
      'te': '',
    },
    'un6z7n7b': {
      'en': '4000',
      'hi': '',
      'te': '',
    },
    'grjcmm5w': {
      'en': 'Sunday',
      'hi': '',
      'te': '',
    },
    'kk9rep95': {
      'en': '13-07-25',
      'hi': '',
      'te': '',
    },
    'o8hbomb1': {
      'en': 'Total earnings',
      'hi': '',
      'te': '',
    },
    '1kywqdna': {
      'en': '3000',
      'hi': '',
      'te': '',
    },
    '96jfvpf6': {
      'en': 'Saturday',
      'hi': '',
      'te': '',
    },
    'niztj9ot': {
      'en': '13-07-25',
      'hi': '',
      'te': '',
    },
    '0h10j774': {
      'en': 'Total earnings',
      'hi': '',
      'te': '',
    },
    '0pdv0nqv': {
      'en': '5000',
      'hi': '',
      'te': '',
    },
    'qnebei2m': {
      'en': 'Friday',
      'hi': '',
      'te': '',
    },
    'xppct04g': {
      'en': '13-07-25',
      'hi': '',
      'te': '',
    },
    'zmxljnu3': {
      'en': 'Total earnings',
      'hi': '',
      'te': '',
    },
    'krt2ic3k': {
      'en': '4000',
      'hi': '',
      'te': '',
    },
    'aappgscp': {
      'en': 'Sunday',
      'hi': '',
      'te': '',
    },
    'd4axj5tb': {
      'en': '13-07-25',
      'hi': '',
      'te': '',
    },
    '1b7o353d': {
      'en': 'Total earnings',
      'hi': '',
      'te': '',
    },
    'kzw086ii': {
      'en': '3000',
      'hi': '',
      'te': '',
    },
    'ih3d3z6v': {
      'en': 'Saturday',
      'hi': '',
      'te': '',
    },
    'k949tctk': {
      'en': '13-07-25',
      'hi': '',
      'te': '',
    },
    'f5kdpwrf': {
      'en': 'Total earnings',
      'hi': '',
      'te': '',
    },
    '6hufe7ku': {
      'en': '5000',
      'hi': '',
      'te': '',
    },
    '7nac8o7v': {
      'en': 'Friday',
      'hi': '',
      'te': '',
    },
    'ujc9echk': {
      'en': '13-07-25',
      'hi': '',
      'te': '',
    },
  },
  // team_earnings_tab
  {
    '6epu8gzj': {
      'en': 'Daily',
      'hi': '',
      'te': '',
    },
    't7z2pij1': {
      'en': '2400',
      'hi': '',
      'te': '',
    },
    'axdabukp': {
      'en': '14-07-25 Monday',
      'hi': '',
      'te': '',
    },
    'uhq7o2kg': {
      'en': 'Chart Area',
      'hi': '',
      'te': '',
    },
    'wlmav8wv': {
      'en': '1',
      'hi': '',
      'te': '',
    },
    '2yg8fwt7': {
      'en': '7',
      'hi': '',
      'te': '',
    },
    'ejiym2x2': {
      'en': '14',
      'hi': '',
      'te': '',
    },
    'pmmfq01p': {
      'en': '21',
      'hi': '',
      'te': '',
    },
    'zm8f8ixc': {
      'en': '28',
      'hi': '',
      'te': '',
    },
    '448l68z4': {
      'en': 's/no',
      'hi': '',
      'te': '',
    },
    '3wvsmf81': {
      'en': 'Names',
      'hi': '',
      'te': '',
    },
    'zchuyuis': {
      'en': 'Vehicle no :',
      'hi': '',
      'te': '',
    },
    'yk1a7r78': {
      'en': 'Yesterday',
      'hi': '',
      'te': '',
    },
    'gg4f60ft': {
      'en': 'Today',
      'hi': '',
      'te': '',
    },
    '4m9ywj6y': {
      'en': '1',
      'hi': '',
      'te': '',
    },
    'fxu7qsv0': {
      'en': 'Ramesh',
      'hi': '',
      'te': '',
    },
    '1gxuia0w': {
      'en': '4489',
      'hi': '',
      'te': '',
    },
    'xsr68rra': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    '8fdrprjv': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    'y0xdqu3i': {
      'en': '2',
      'hi': '',
      'te': '',
    },
    'xxv45nbf': {
      'en': 'Bharath',
      'hi': '',
      'te': '',
    },
    'esz5qe0p': {
      'en': '4489',
      'hi': '',
      'te': '',
    },
    '45l62ds8': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    '8tb4tinm': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    'u0zk3tkq': {
      'en': '3',
      'hi': '',
      'te': '',
    },
    'z8zrs3ma': {
      'en': 'Anand',
      'hi': '',
      'te': '',
    },
    '9r4z161p': {
      'en': '4489',
      'hi': '',
      'te': '',
    },
    'vy26oc5h': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    'liyj9lqc': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    'etq5it2j': {
      'en': '4',
      'hi': '',
      'te': '',
    },
    '9wcst386': {
      'en': 'Ramesh',
      'hi': '',
      'te': '',
    },
    'l4arglwv': {
      'en': '4489',
      'hi': '',
      'te': '',
    },
    '9aaeufi6': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    'jkuel9gg': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    '1oebhska': {
      'en': '5',
      'hi': '',
      'te': '',
    },
    'gba7f8lu': {
      'en': 'Bharath',
      'hi': '',
      'te': '',
    },
    'sic3lyce': {
      'en': '4489',
      'hi': '',
      'te': '',
    },
    'e40scj7b': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    '1lrtq5ll': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    '3b7sxtov': {
      'en': '6',
      'hi': '',
      'te': '',
    },
    'oz69hi96': {
      'en': 'Anand',
      'hi': '',
      'te': '',
    },
    'lguv1nnl': {
      'en': '4489',
      'hi': '',
      'te': '',
    },
    'fepiqn51': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    'ds9weymi': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    'w9rfc251': {
      'en': '7',
      'hi': '',
      'te': '',
    },
    '17k3196l': {
      'en': 'Ramesh',
      'hi': '',
      'te': '',
    },
    'q1j6ddp6': {
      'en': '4489',
      'hi': '',
      'te': '',
    },
    'mgue0nyg': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    '9hbvn8j7': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    'j08llbko': {
      'en': '8',
      'hi': '',
      'te': '',
    },
    'vfief4ca': {
      'en': 'Bharath',
      'hi': '',
      'te': '',
    },
    'tc3woka4': {
      'en': '4489',
      'hi': '',
      'te': '',
    },
    '64r974jd': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    'osmtd076': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    '23mqc7r4': {
      'en': '9',
      'hi': '',
      'te': '',
    },
    'vrotngsl': {
      'en': 'Anand',
      'hi': '',
      'te': '',
    },
    '2hqihmje': {
      'en': '4489',
      'hi': '',
      'te': '',
    },
    'ubdhykr7': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    'bmv2uawv': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    '6be5bspy': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    'x990qnd0': {
      'en': 'Ramesh',
      'hi': '',
      'te': '',
    },
    'he275oqq': {
      'en': '4489',
      'hi': '',
      'te': '',
    },
    '3328cjx3': {
      'en': '10',
      'hi': '',
      'te': '',
    },
    '14vmt60h': {
      'en': '10',
      'hi': '',
      'te': '',
    },
  },
  // detailsfirst
  {
    '8lbslu6e': {
      'en': 'We need your sign-in details to get started',
      'hi': '',
      'te': '',
    },
    'fd0001': {
      'en': 'Partner Profile',
      'hi': 'पार्टनर प्रोफाइल',
      'te': 'భాగస్వామి ప్రొఫైల్',
    },
    'fd0002': {
      'en': 'Let\'s get to know you better.',
      'hi': 'आइए आपको बेहतर जानते हैं।',
      'te': 'మిమ్మల్ని బాగా తెలుసుకోవాలి.',
    },
    'fd0003': {
      'en': 'Basic Details',
      'hi': 'मूल विवरण',
      'te': 'ప్రాథమిక వివరాలు',
    },
    'oezel2cu': {
      'en': 'First Name',
      'hi': 'पहला नाम',
      'te': 'మొదటి పేరు',
    },
    '9blspwgp': {
      'en': 'Last Name',
      'hi': 'अंतिम नाम',
      'te': 'చివరి పేరు',
    },
    '3xyysbhm': {
      'en': 'Email Address',
      'hi': 'ईमेल पता',
      'te': 'ఈమెయిల్ చిరునామా',
    },
    'fd0004': {
      'en': 'Required',
      'hi': 'आवश्यक',
      'te': 'అవసరం',
    },
    'fd0005': {
      'en': 'Invalid Email',
      'hi': 'अमान्य ईमेल',
      'te': 'చెల్లని ఈమెయిల్',
    },
    'fd0006': {
      'en': 'Referral Code',
      'hi': 'रेफरल कोड',
      'te': 'రెఫరల్ కోడ్',
    },
    'xtbkk4x0': {
      'en': 'Continue',
      'hi': 'जारी रखें',
      'te': 'కొనసాగించు',
    },
  },
  // Miscellaneous
  {
    'il0x470m': {
      'en': '',
      'hi': '',
      'te': '',
    },
    'grcdu80x': {
      'en': '',
      'hi': '',
      'te': '',
    },
    'zhnss238': {
      'en': '',
      'hi': '',
      'te': '',
    },
    '80d2q2of': {
      'en': '',
      'hi': '',
      'te': '',
    },
    'txqtzfi9': {
      'en': '',
      'hi': '',
      'te': '',
    },
    'km8s16pb': {
      'en': '',
      'hi': '',
      'te': '',
    },
    '3frlu4on': {
      'en': '',
      'hi': '',
      'te': '',
    },
    '2uvtdyx1': {
      'en': '',
      'hi': '',
      'te': '',
    },
    'ht806lil': {
      'en': '',
      'hi': '',
      'te': '',
    },
    'ebdkb0h2': {
      'en': '',
      'hi': '',
      'te': '',
    },
    'opg8t6we': {
      'en': '',
      'hi': '',
      'te': '',
    },
    'wns4o5pt': {
      'en': '',
      'hi': '',
      'te': '',
    },
    'y5wkpu4r': {
      'en': '',
      'hi': '',
      'te': '',
    },
    'gm5w49nn': {
      'en': '',
      'hi': '',
      'te': '',
    },
    '4pvkeeoe': {
      'en': '',
      'hi': '',
      'te': '',
    },
    '9j4ii7im': {
      'en': '',
      'hi': '',
      'te': '',
    },
    'tnl2vzl7': {
      'en': '',
      'hi': '',
      'te': '',
    },
    'bi921mey': {
      'en': '',
      'hi': '',
      'te': '',
    },
    'brsrxxpc': {
      'en': '',
      'hi': '',
      'te': '',
    },
    'jy1mqc03': {
      'en': '',
      'hi': '',
      'te': '',
    },
    'v98krr7z': {
      'en': '',
      'hi': '',
      'te': '',
    },
    'u745jhgp': {
      'en': '',
      'hi': '',
      'te': '',
    },
    '35v2nqx0': {
      'en': '',
      'hi': '',
      'te': '',
    },
    'jy9uagvs': {
      'en': '',
      'hi': '',
      'te': '',
    },
    'gr1avdi1': {
      'en': '',
      'hi': '',
      'te': '',
    },
  },
  // incentivePage
  {
    'o4ik6hfp': {
      'en': 'Incentives',
      'hi': 'प्रोत्साहन',
      'te': 'ప్రోత్సాహనలు',
    },
    'r35w09da': {
      'en': 'Complete 80 more rides to earn ₹600',
      'hi': '₹600 अर्जित करने के लिए 80 और सवारियाँ पूरी करें',
      'te': '₹600 సంపాదించడానికి 80 మరిన్ని రైడ్‌లను పూర్తి చేయండి',
    },
    'zg0xawte': {
      'en': '0/80',
      'hi': '0/80',
      'te': '0/80',
    },
    'u3ymy4pr': {
      'en': '+₹600',
      'hi': '+₹600',
      'te': '+₹600',
    },
    'bt7kot3y': {
      'en': '20 rides',
      'hi': '20 सवारियाँ',
      'te': '20 రైడ్‌లు',
    },
    '7r9r8l37': {
      'en': '+₹400',
      'hi': '+₹400',
      'te': '+₹400',
    },
    'dvk5wszx': {
      'en': '30 rides',
      'hi': '30 सवारियाँ',
      'te': '30 రైడ్‌లు',
    },
    'v8r4nr1u': {
      'en': '+₹500',
      'hi': '+₹500',
      'te': '+₹500',
    },
    'ky05gank': {
      'en': '40 rides',
      'hi': '40 सवारियाँ',
      'te': '40 రైడ్‌లు',
    },
    'bczspme7': {
      'en': '+₹700',
      'hi': '+₹700',
      'te': '+₹700',
    },
    'lof014xm': {
      'en': '50 rides',
      'hi': '50 सवारियाँ',
      'te': '50 రైడ్‌లు',
    },
    '2zgf027h': {
      'en': '+₹1300',
      'hi': '+₹1300',
      'te': '+₹1300',
    },
  },
  // addBankAccount
  {
    'wlxvqket': {
      'en': 'Add Bank Account',
      'hi': 'बैंक खाता जोड़ें',
      'te': 'బ్యాంక్ ఖాతాను జోడించండి',
    },
    'z3yviii2': {
      'en': 'Full Name',
      'hi': 'पूरा नाम',
      'te': 'పూర్తి పేరు',
    },
    'vwehe0jg': {
      'en': 'Bank Account Number',
      'hi': 'बैंक खाता संख्या',
      'te': 'బ్యాంక్ ఖాతా సంఖ్య',
    },
    '6kj7r3jn': {
      'en': 'Confirm Bank Account Number',
      'hi': 'बैंक खाता संख्या की पुष्टि करें',
      'te': 'బ్యాంక్ ఖాతా సంఖ్యను నిర్ధారించండి',
    },
    'l1eb56jt': {
      'en': 'Bank IFSC Code',
      'hi': 'बैंक IFSC कोड',
      'te': 'బ్యాంక్ IFSC కోడ్',
    },
    'wv7qy5fs': {
      'en': 'Cancel',
      'hi': 'रद्द करें',
      'te': 'రద్దు చేయండి',
    },
    '67uqdtth': {
      'en': 'Submit',
      'hi': 'जमा करें',
      'te': 'సమర్పించండి',
    },
  },
  // withdraw
  {
    'u0xnthuk': {
      'en': 'Withdraw',
      'hi': 'निकासी',
      'te': 'విత్‌డ్రా',
    },
    '9ltoao1v': {
      'en': 'Enter Amount',
      'hi': 'राशि दर्ज करें',
      'te': 'మొత్తం నమోదు చేయండి',
    },
    '9z3c0f6c': {
      'en': '₹380',
      'hi': '₹380',
      'te': '₹380',
    },
    'visvh3a4': {
      'en': 'Bank Account Number',
      'hi': 'बैंक खाता संख्या',
      'te': 'బ్యాంక్ ఖాతా సంఖ్య',
    },
    'g95ih7v8': {
      'en': 'XXXXXXXXXXXXXXX38',
      'hi': 'XXXXXXXXXXXXXXX38',
      'te': 'XXXXXXXXXXXXXXX38',
    },
    '5rbl97wg': {
      'en': 'Bank IFSC Code',
      'hi': 'बैंक IFSC कोड',
      'te': 'బ్యాంక్ IFSC కోడ్',
    },
    'i2j5vzhu': {
      'en': 'XXXXXX38',
      'hi': 'XXXXXX38',
      'te': 'XXXXXX38',
    },
    'c1crgt2r': {
      'en': 'Cancel',
      'hi': 'रद्द करें',
      'te': 'రద్దు చేయండి',
    },
    'bhzb42xw': {
      'en': 'Submit',
      'hi': 'जमा करें',
      'te': 'సమర్పించండి',
    },
  },
  // driver_app - Home, Ride flow, Account
  {
    'drv_good_morning': {
      'en': 'Good Morning',
      'hi': 'सुप्रभात',
      'te': 'శుభోదయం'
    },
    'drv_good_afternoon': {
      'en': 'Good Afternoon',
      'hi': 'शुभ दोपहर',
      'te': 'శుభ మధ్యాహ్నం'
    },
    'drv_good_evening': {
      'en': 'Good Evening',
      'hi': 'शुभ संध्या',
      'te': 'శుభ సాయంత్రం'
    },
    'drv_cannot_offline': {
      'en': 'Cannot go offline during an active ride!',
      'hi': 'सक्रिय राइड के दौरान ऑफलाइन नहीं हो सकते!',
      'te': 'యాక్టివ్ రైడ్ సమయంలో ఆఫ్‌లైన్ కాజాలరు!'
    },
    'drv_kyc_not_approved': {
      'en': 'KYC Not Approved',
      'hi': 'KYC स्वीकृत नहीं',
      'te': 'KYC ఆమోదించబడలేదు'
    },
    'drv_kyc_complete': {
      'en': 'Your KYC status is "%1". Please complete KYC.',
      'hi': 'आपकी KYC स्थिति "%1" है। कृपया KYC पूर्ण करें।',
      'te': 'మీ KYC స్థితి "%1". దయచేసి KYC పూర్తి చేయండి.'
    },
    'drv_ok': {'en': 'OK', 'hi': 'ठीक है', 'te': 'సరే'},
    'drv_you_online': {
      'en': 'You are online',
      'hi': 'आप ऑनलाइन हैं',
      'te': 'మీరు ఆన్‌లైన్‌లో ఉన్నారు'
    },
    'drv_failed_offline': {
      'en': 'Failed to go offline',
      'hi': 'ऑफलाइन जाने में विफल',
      'te': 'ఆఫ్‌లైన్ కావడంలో విఫలమైంది'
    },
    'drv_location_needed': {
      'en': 'Location Access Needed',
      'hi': 'स्थान पहुंच की आवश्यकता',
      'te': 'స్థాన ప్రవేశం అవసరం'
    },
    'drv_location_body': {
      'en':
          'UGO needs your location to receive ride requests, share with passengers, and navigate. Your location is only used when you\'re online.',
      'hi':
          'राइड रिक्वेस्ट प्राप्त करने, यात्रियों के साथ साझा करने और नेविगेट करने के लिए UGO को आपके स्थान की आवश्यकता है। आपका स्थान केवल ऑनलाइन होने पर उपयोग किया जाता है।',
      'te':
          'రైడ్ అభ్యర్థనలు స్వీకరించడానికి, ప్రయాణీకులతో భాగస్వామ్యం చేయడానికి మరియు నావిగేట్ చేయడానికి UGOకు మీ స్థానం అవసరం. మీరు ఆన్‌లైన్‌లో ఉన్నప్పుడు మాత్రమే మీ స్థానం ఉపయోగించబడుతుంది.'
    },
    'drv_not_now': {'en': 'Not Now', 'hi': 'अभी नहीं', 'te': 'ఇప్పుడు కాదు'},
    'drv_allow': {'en': 'Allow', 'hi': 'अनुमति दें', 'te': 'అనుమతించండి'},
    'drv_overlay_needed_title': {
      'en': 'Allow display over other apps',
      'hi': 'अन्य ऐप्स पर दिखाने की अनुमति दें',
      'te': 'ఇతర యాప్‌లపై చూపేందుకు అనుమతి ఇవ్వండి'
    },
    'drv_overlay_needed_body': {
      'en':
          'Enable display over other apps so the ride request bubble can show when you are in another app.',
      'hi':
          'जब आप किसी अन्य ऐप में हों तब राइड रिक्वेस्ट बबल दिखाने के लिए इस अनुमति को सक्षम करें।',
      'te':
          'మీరు ఇతర యాప్‌లో ఉన్నప్పుడు రైడ్ రిక్వెస్ట్ బబుల్ చూపించడానికి ఈ అనుమతిని ప్రారంభించండి.'
    },
    'drv_open_settings': {
      'en': 'Open Settings',
      'hi': 'सेटिंग्स खोलें',
      'te': 'సెట్టింగ్‌లు తెరయండి'
    },
    'drv_location_unavailable': {
      'en':
          'Location not available.\\nPlease grant location permission to use the app.',
      'hi': 'स्थान उपलब्ध नहीं।\\nऐप उपयोग के लिए स्थान अनुमति दें।',
      'te':
          'స్థానం అందుబాటులో లేదు.\\nయాప్ ఉపయోగించడానికి స్థాన అనుమతి ఇవ్వండి.'
    },
    'drv_back_exit': {
      'en': 'Press back again to exit',
      'hi': 'बाहर निकलने के लिए फिर से बैक दबाएं',
      'te': 'నిష్క్రమించడానికి మళ్ళీ బ్యాక్ నొక్కండి'
    },
    'drv_captains_nearby': {
      'en': 'captains nearby',
      'hi': 'कैप्टन पास में',
      'te': 'కెప్టెన్లు సమీపంలో'
    },
    'drv_captain_nearby': {
      'en': 'captain nearby',
      'hi': 'कैप्टन पास में',
      'te': 'కెప్టెన్ సమీపంలో'
    },
    'drv_offline': {
      'en': 'You are currently Offline',
      'hi': 'आप वर्तमान में ऑफलाइन हैं',
      'te': 'మీరు ప్రస్తుతం ఆఫ్‌లైన్‌లో ఉన్నారు'
    },
    'drv_go_online': {
      'en': 'GO ONLINE',
      'hi': 'ऑनलाइन जाएं',
      'te': 'ఆన్‌లైన్ కండి'
    },
    'drv_incentives': {
      'en': 'Incentives',
      'hi': 'प्रोत्साहन',
      'te': 'ప్రోత్సాహకాలు'
    },
    'drv_coming_soon': {
      'en': 'Coming Soon',
      'hi': 'जल्द ही आ रहा है',
      'te': 'త్వరలో వస్తోంది'
    },
    'drv_incentives_soon': {
      'en': 'Coming Soon or Please Complete first ride to view Incentives',
      'hi': 'जल्द आ रहा है या प्रोत्साहन देखने के लिए पहली राइड पूरी करें',
      'te':
          'త్వరలో వస్తోంది లేదా ప్రోత్సాహకాలు చూడడానికి మొదటి రైడ్ పూర్తి చేయండి'
    },
    'drv_incentives_excite': {
      'en': 'Exciting incentive programs will be available soon!',
      'hi': 'रोमांचक प्रोत्साहन कार्यक्रम जल्द उपलब्ध होंगे!',
      'te': 'ఉత్తేజకరమైన ప్రోత్సాహక కార్యక్రమాలు త్వరలో అందుబాటులో ఉంటాయి!'
    },
    'drv_rides': {'en': 'rides', 'hi': 'राइड्स', 'te': 'రైడ్‌లు'},
    'drv_today_total': {
      'en': 'Today Total',
      'hi': 'आज का कुल',
      'te': 'ఈ రోజు మొత్తం'
    },
    'drv_ride_count': {
      'en': 'Ride Count',
      'hi': 'राइड की संख्या',
      'te': 'రైడ్ గణన'
    },
    'drv_wallet': {'en': 'Wallet', 'hi': 'वॉलेट', 'te': 'వాలెట్'},
    'drv_last_ride': {
      'en': 'Last Ride',
      'hi': 'आखिरी राइड',
      'te': 'చివరి రైడ్'
    },
    'drv_new_request': {
      'en': 'NEW REQUEST',
      'hi': 'नई अनुरोध',
      'te': 'కొత్త అభ్యర్థన'
    },
    'drv_pickup_distance': {
      'en': 'Pickup Distance',
      'hi': 'पिकअप दूरी',
      'te': 'పికప్ దూరం'
    },
    'drv_fare': {'en': 'Fare', 'hi': 'किराया', 'te': 'ఛార్జీ'},
    'drv_drop_distance': {
      'en': 'Drop Distance',
      'hi': 'ड्रॉप दूरी',
      'te': 'డ్రాప్ దూరం'
    },
    'drv_drop': {'en': 'Drop', 'hi': 'ड्रॉप', 'te': 'డ్రాప్'},
    'drv_pickup': {'en': 'Pickup', 'hi': 'पिकअप', 'te': 'పికప్'},
    'drv_decline': {'en': 'DECLINE', 'hi': 'अस्वीकार', 'te': 'తిరస్కరించండి'},
    'drv_accept': {'en': 'ACCEPT', 'hi': 'स्वीकार', 'te': 'అంగీకరించండి'},
    'drv_navigate': {
      'en': 'NAVIGATE',
      'hi': 'नेविगेट',
      'te': 'నావిగేట్ చేయండి'
    },
    'drv_go_to_pickup': {
      'en': 'GO TO PICKUP',
      'hi': 'पिकअप पर जाएं',
      'te': 'పికప్‌కు వెళ్లండి'
    },
    'drv_waiting_time': {
      'en': 'Waiting Time',
      'hi': 'प्रतीक्षा समय',
      'te': 'వేచి ఉన్న సమయం'
    },
    'drv_arrived': {'en': 'ARRIVED', 'hi': 'पहुंच गए', 'te': 'వచ్చారు'},
    'drv_start_ride': {
      'en': 'START RIDE',
      'hi': 'राइड शुरू करें',
      'te': 'రైడ్ ప్రారంభించండి'
    },
    'drv_go_to_drop': {
      'en': 'GO TO DROP',
      'hi': 'ड्रॉप पर जाएं',
      'te': 'డ్రాప్‌కు వెళ్లండి'
    },
    'drv_complete_ride': {
      'en': 'COMPLETE RIDE',
      'hi': 'राइड पूरी करें',
      'te': 'రైడ్ పూర్తి చేయండి'
    },
    'drv_nav_to_drop': {
      'en': 'NAVIGATE TO DROP',
      'hi': 'ड्रॉप पर नेविगेट करें',
      'te': 'డ్రాప్‌కు నావిగేట్ చేయండి'
    },
    'drv_nav_to_pickup': {
      'en': 'NAVIGATE TO PICKUP',
      'hi': 'पिकअप पर नेविगेट करें',
      'te': 'పికప్‌కు నావిగేట్ చేయండి'
    },
    'drv_passenger': {'en': 'Passenger', 'hi': 'यात्री', 'te': 'ప్రయాణీకుడు'},
    'drv_unknown_location': {
      'en': 'Unknown Location',
      'hi': 'अज्ञात स्थान',
      'te': 'తెలియని స్థానం'
    },
    'drv_otp_title': {
      'en': 'Enter The OTP To Start The Ride',
      'hi': 'राइड शुरू करने के लिए OTP दर्ज करें',
      'te': 'రైడ్ ప్రారంభించడానికి OTP నమోదు చేయండి'
    },
    'drv_enter_otp': {
      'en': 'Enter OTP',
      'hi': 'OTP दर्ज करें',
      'te': 'OTP నమోదు చేయండి'
    },
    'drv_ride_otp': {'en': 'Ride OTP', 'hi': 'राइड OTP', 'te': 'రైడ్ OTP'},
    'drv_verify': {'en': 'VERIFY', 'hi': 'सत्यापित करें', 'te': 'ధృవీకరించండి'},
    'drv_phone_unavailable': {
      'en': 'Phone number not available.',
      'hi': 'फ़ोन नंबर उपलब्ध नहीं।',
      'te': 'ఫోన్ నంబర్ అందుబాటులో లేదు.'
    },
    'drv_dialer_fail': {
      'en': 'Could not launch dialer.',
      'hi': 'डायलर खोल नहीं सके।',
      'te': 'డయలర్ తెరవలేకపోయాం.'
    },
    'drv_drop_location': {
      'en': 'Drop Location',
      'hi': 'ड्रॉप स्थान',
      'te': 'డ్రాప్ స్థానం'
    },
    'drv_ride_completed': {
      'en': 'Ride Completed',
      'hi': 'राइड पूरी हुई',
      'te': 'రైడ్ పూర్తయింది'
    },
    'drv_received_online': {
      'en': 'You received it online',
      'hi': 'आपने इसे ऑनलाइन प्राप्त किया',
      'te': 'మీరు దీన్ని ఆన్‌లైన్‌లో అందుకున్నారు'
    },
    'drv_cash_collected': {
      'en': 'Cash collected',
      'hi': 'नकद प्राप्त हुआ',
      'te': 'నగదు సంపాదించారు'
    },
    'drv_review': {'en': 'Review', 'hi': 'समीक्षा', 'te': 'సమీక్ష'},
    'drv_total_fare': {
      'en': 'Total Fare',
      'hi': 'कुल किराया',
      'te': 'మొత్తం ఛార్జీ'
    },
    'drv_submit': {'en': 'Submit', 'hi': 'जमा करें', 'te': 'సమర్పించండి'},
    'drv_manage_prefs': {
      'en': 'Manage your Preferences.',
      'hi': 'अपनी प्राथमिकताएं प्रबंधित करें।',
      'te': 'మీ ప్రాధాన్యతలను నిర్వహించండి.'
    },
    'drv_view_messages': {
      'en': 'View messages',
      'hi': 'संदेश देखें',
      'te': 'సందేశాలు చూడండి'
    },
    'drv_check_balance': {
      'en': 'Check balance',
      'hi': 'बैलेंस जांचें',
      'te': 'బ్యాలెన్స్ తనిఖీ చేయండి'
    },
    'drv_edit_info': {
      'en': 'Edit your info',
      'hi': 'अपनी जानकारी संपादित करें',
      'te': 'మీ సమాచారాన్ని సవరించండి'
    },
    'drv_legal_info': {
      'en': 'Legal information',
      'hi': 'कानूनी जानकारी',
      'te': 'చట్టపరమైన సమాచారం'
    },
    'drv_how_we_handle': {
      'en': 'How we handle your data',
      'hi': 'हम आपके डेटा को कैसे संभालते हैं',
      'te': 'మేము మీ డేటాను ఎలా నిర్వహిస్తాము'
    },
    'drv_logout_title': {'en': 'Logout', 'hi': 'लॉग आउट', 'te': 'లాగ్ అవుట్'},
    'drv_logout_confirm': {
      'en': 'Are you sure you want to logout?',
      'hi': 'क्या आप लॉग आउट करना चाहते हैं?',
      'te': 'మీరు లాగ్ అవుట్ చేయాలనుకుంటున్నారా?'
    },
    'drv_cancel': {'en': 'Cancel', 'hi': 'रद्द करें', 'te': 'రద్దు చేయండి'},
    'drv_cancel_ride_confirm': {
      'en': 'Are you sure you want to cancel this ride?',
      'hi': 'क्या आप इस राइड को रद्द करना चाहते हैं?',
      'te': 'మీరు ఈ రైడ్‌ను రద్దు చేయాలనుకుంటున్నారా?'
    },
    'drv_yes_cancel': {
      'en': 'Yes, Cancel',
      'hi': 'हाँ, रद्द करें',
      'te': 'అవును, రద్దు చేయండి'
    },
    'drv_ride_cancelled': {
      'en': 'Ride cancelled',
      'hi': 'राइड रद्द हो गई',
      'te': 'రైడ్ రద్దు చేయబడింది'
    },
    'drv_select_cancel_reason': {
      'en': 'Select reason for cancellation',
      'hi': 'रद्दीकरण का कारण चुनें',
      'te': 'రద్దు కారణం ఎంచుకోండి'
    },
    'drv_cancel_ride': {
      'en': 'Cancel Ride',
      'hi': 'राइड रद्द करें',
      'te': 'రైడ్ రద్దు చేయండి'
    },
    'drv_cancel_reason_emergency': {
      'en': 'Personal emergency',
      'hi': 'व्यक्तिगत आपातकाल',
      'te': 'వ్యక్తిగత అత్యవసరం'
    },
    'drv_cancel_reason_vehicle': {
      'en': 'Vehicle issues',
      'hi': 'वाहन समस्या',
      'te': 'వాహన సమస్యలు'
    },
    'drv_cancel_reason_passenger_no_show': {
      'en': 'Passenger no-show',
      'hi': 'यात्री नहीं मिला',
      'te': 'ప్రయాణీకుడు రాలేదు'
    },
    'drv_cancel_reason_wrong_pickup': {
      'en': 'Incorrect pickup location',
      'hi': 'गलत पिकअप स्थान',
      'te': 'తప్పు పికప్ స్థానం'
    },
    'drv_cancel_reason_long_wait': {
      'en': 'Long waiting time',
      'hi': 'लंबा इंतजार',
      'te': 'ఎక్కువ వేచి ఉన్న సమయం'
    },
    'drv_cancel_reason_wrong_address': {
      'en': 'Wrong address',
      'hi': 'गलत पता',
      'te': 'తప్పు చిరునామా'
    },
    'drv_cancel_reason_change_plans': {
      'en': 'Change of plans',
      'hi': 'योजना बदल गई',
      'te': 'ప్రణాళికలు మార్చారు'
    },
    'drv_cancel_reason_other': {'en': 'Other', 'hi': 'अन्य', 'te': 'ఇతర'},
    'drv_collect_cash': {
      'en': 'Collect cash',
      'hi': 'नकद लें',
      'te': 'నగదు సంపాదించండి'
    },
    'drv_from_passenger': {
      'en': 'from passenger',
      'hi': 'यात्री से',
      'te': 'ప్రయాణీకుని నుండి'
    },
    'drv_received_cash': {
      'en': "I've received the amount",
      'hi': 'मुझे राशि मिल गई',
      'te': 'నాకు మొత్తం వచ్చింది'
    },
    'drv_privacy_policy': {
      'en': 'Privacy Policy',
      'hi': 'गोपनीयता नीति',
      'te': 'గోప్యతా విధానం'
    },
    'drv_review_friendly': {
      'en': 'Friendly',
      'hi': 'मैत्रीपूर्ण',
      'te': 'స్నేహపూర్వకం'
    },
    'drv_review_safe': {'en': 'Safe', 'hi': 'सुरक्षित', 'te': 'సురక్షితం'},
    'drv_review_worst': {'en': 'Worst', 'hi': 'सबसे खराब', 'te': 'చెత్త'},
    'drv_review_fast': {'en': 'Fast', 'hi': 'तेज़', 'te': 'వేగంగా'},
    'drv_review_clean': {'en': 'Clean', 'hi': 'साफ', 'te': 'శుభ్రంగా'},
    'drv_review_affordable': {'en': 'Affordable', 'hi': 'किफायती', 'te': 'సరసమైనది'},
    'drv_optional_comments': {'en': 'Optional Comments', 'hi': 'वैकल्पिक टिप्पणियाँ', 'te': 'ఐచ్ఛిక వ్యాఖ్యలు'},
    'drv_collect': {'en': 'Collect', 'hi': 'संग्रह करें', 'te': 'సేకరించండి'},
    'drv_payment_method': {'en': 'Payment Method', 'hi': 'भुगतान विधि', 'te': 'చెల్లింపు పద్ధతి'},
    'drv_cash': {'en': 'Cash', 'hi': 'नकद', 'te': 'నగదు'},
    'drv_online': {'en': 'Online', 'hi': 'ऑनलाइन', 'te': 'ఆన్‌లైన్'},
    'drv_received': {'en': 'Received', 'hi': 'प्राप्त', 'te': 'అందుకున్నారు'},
    'drv_voice': {'en': 'Voice', 'hi': 'आवाज़', 'te': 'వాయిస్'},
    'drv_ride_announcements': {
      'en': 'Ride announcements',
      'hi': 'राइड घोषणाएं',
      'te': 'రైడ్ ప్రకటనలు'
    },
    'drv_preferred_city': {
      'en': 'Preferred City',
      'hi': 'पसंदीदा शहर',
      'te': 'ప్రాధాన్య నగరం'
    },
    'drv_preferred_city_title': {
      'en': 'Preferred City',
      'hi': 'पसंदीदा शहर',
      'te': 'ప్రాధాన్య నగరం'
    },
    'drv_preferred_city_subtitle': {
      'en': 'Set your preferred city',
      'hi': 'अपना पसंदीदा शहर सेट करें',
      'te': 'మీ ప్రాధాన్య నగరాన్ని సెట్ చేయండి'
    },
    'drv_preferred_city_locked_subtitle': {
      'en': 'Approval required to change',
      'hi': 'बदलने के लिए अनुमोदन आवश्यक',
      'te': 'మార్చడానికి అనుమతి అవసరం'
    },
    'drv_select_city': {
      'en': 'Select a city',
      'hi': 'एक शहर चुनें',
      'te': 'ఒక నగరాన్ని ఎంచుకోండి'
    },
    'drv_no_cities': {
      'en': 'No active cities available',
      'hi': 'कोई सक्रिय शहर उपलब्ध नहीं',
      'te': 'సక్రియ నగరాలు లభ్యం కావు'
    },
    'drv_save': {'en': 'Save', 'hi': 'सेव करें', 'te': 'సేవ్'},
    'drv_city_saved': {
      'en': 'Preferred city updated',
      'hi': 'पसंदीदा शहर अपडेट किया गया',
      'te': 'ప్రాధాన్య నగరం నవీకరించబడింది'
    },
    'drv_city_failed': {
      'en': 'Failed to update preferred city',
      'hi': 'पसंदीदा शहर अपडेट करने में विफल',
      'te': 'ప్రాధాన్య నగరాన్ని నవీకరించడంలో విఫలమైంది'
    },
    'drv_select_preferred_city': {
      'en': 'Select your preferred city to go online',
      'hi': 'ऑनलाइन जाने के लिए अपना पसंदीदा शहर चुनें',
      'te': 'ఆన్‌లైన్ కావడానికి మీ ప్రాధాన్య నగరాన్ని ఎంచుకోండి'
    },
    'drv_preferred_city_locked': {
      'en': 'Preferred city is locked after initial set. Request admin approval to change it.',
      'hi': 'पसंदीदा शहर पहली बार सेट होने के बाद लॉक हो जाता है। बदलने के लिए एडमिन अनुमोदन मांगें।',
      'te': 'ప్రాధాన్య నగరం ఒకసారి సెట్ చేసిన తర్వాత లాక్ అవుతుంది. మార్చడానికి అడ్మిన్ అనుమతి కోరండి.'
    },
    'drv_request_approval': {
      'en': 'Request approval',
      'hi': 'अनुमोदन का अनुरोध करें',
      'te': 'అనుమతి కోరండి'
    },
    'drv_send_request': {
      'en': 'Send request',
      'hi': 'अनुरोध भेजें',
      'te': 'అభ్యర్థన పంపండి'
    },
    'drv_request_sent': {
      'en': 'Approval request sent',
      'hi': 'अनुमोदन अनुरोध भेजा गया',
      'te': 'అనుమతి అభ్యర్థన పంపబడింది'
    },
    'drv_request_failed': {
      'en': 'Failed to send approval request',
      'hi': 'अनुमोदन अनुरोध भेजने में विफल',
      'te': 'అనుమతి అభ్యర్థన పంపడంలో విఫలమైంది'
    },
    'drv_request_same_city': {
      'en': 'Selected city is same as current',
      'hi': 'चयनित शहर वर्तमान जैसा ही है',
      'te': 'ఎంచుకున్న నగరం ప్రస్తుతం ఉన్నదే'
    },
    'drv_go_online_failed': {
      'en': 'Failed to go online',
      'hi': 'ऑनलाइन होने में विफल',
      'te': 'ఆన్‌లైన్ అవ్వడంలో విఫలమైంది'
    },
  },
].reduce((a, b) => a..addAll(b));
