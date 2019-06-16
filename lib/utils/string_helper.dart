class StringHelper {
  static String fromMinutesToHourNotation(int minutes) {
    int amountOfHours = (minutes / 60).floor();
    int amountOfMinutes = minutes % 60;

    String amountOfMinutesFormatted;
    if (amountOfMinutes.toString().length < 2) {
      amountOfMinutesFormatted = '0$amountOfMinutes';
    } else {
      amountOfMinutesFormatted = amountOfMinutes.toString();
    }

    return '$amountOfHours:${amountOfMinutesFormatted}h';
  }
}
