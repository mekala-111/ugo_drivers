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

  String getText(String key) =>
      (kTranslationsMap[key] ?? {})[locale.toString()] ?? '';

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
      'hi': '',
      'te': '',
    },
    'uhrogttt': {
      'en': 'Continue',
      'hi': '',
      'te': '',
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
      'hi': '',
      'te': '',
    },
    'qg68530z': {
      'en': 'Driving License',
      'hi': '',
      'te': '',
    },
    'mnqkwauk': {
      'en': 'Recommended next step',
      'hi': '',
      'te': '',
    },
    'k8fnkaky': {
      'en': 'Profile Picture',
      'hi': '',
      'te': '',
    },
    'c0kv9v5c': {
      'en': 'Aadhaar Card',
      'hi': '',
      'te': '',
    },
    'ymy7qbgz': {
      'en': 'Pan Card',
      'hi': '',
      'te': '',
    },
    'jqs0l5w3': {
      'en': 'Vehicle photo verification',
      'hi': '',
      'te': '',
    },
    'ipks4vgn': {
      'en': 'Registration Certificate (RC)',
      'hi': '',
      'te': '',
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
    'oezel2cu': {
      'en': 'First Name',
      'hi': '',
      'te': '',
    },
    '9blspwgp': {
      'en': 'Last Name',
      'hi': '',
      'te': '',
    },
    '3xyysbhm': {
      'en': 'Email Address',
      'hi': '',
      'te': '',
    },
    'xtbkk4x0': {
      'en': 'Continue',
      'hi': '',
      'te': '',
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
    'drv_voice': {'en': 'Voice', 'hi': 'आवाज़', 'te': 'వాయిస్'},
    'drv_ride_announcements': {
      'en': 'Ride announcements',
      'hi': 'राइड घोषणाएं',
      'te': 'రైడ్ ప్రకటనలు'
    },
  },
].reduce((a, b) => a..addAll(b));
