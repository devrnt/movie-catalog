class Subtitle {
  String language;
  // String name;
  String imageUrl;
  String downloadUrl;
  String countryCode;
  int rating;
  static final String baseUrl = 'https://www.yifysubtitles.com';

  // Fill this map up for every country name that is not 
  // directly convertable for a flag code on the site
  // https://countryflags.io/

  final Map<String, String> countryCodes = {
    'english': 'GB',
    'dutch': 'NL',
    'danish': 'DK',
    'portuguese': 'PT',
    'spanish': 'ES',
    'turkish': 'TR',
    'polish': 'PL',
    'hebrew': 'IL',
    'bulgarian': 'BG',
    'arabic': 'SA',
    'croatian': 'HR',
    'chinese': 'CN',
    'serbian': 'RS',
    'bengali': 'BD',
    'swedish': 'SE',
    'korean': 'KR',
    'malay': 'MY',
    'farsi/persian': 'IR'
  };

  Subtitle({this.language, String downloadUrl, this.rating}) {
    // default href is not the download link
    // this might change on the subtitle website
    String formattedDownloadUrl =
        downloadUrl.replaceFirst('/subtitles', '/subtitle');

    this.downloadUrl = '$baseUrl$formattedDownloadUrl.zip';
    this.countryCode = _getCountryCode(language);
  }

  String _getCountryCode(String language) {
    if (countryCodes.containsKey(language.toLowerCase())) {
      return countryCodes[language.toLowerCase()];
    } else {
      // suppose country code is first to chars of language
      // this works most of the time
      return language.substring(0, 2);
    }
  }
}
