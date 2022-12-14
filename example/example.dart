import 'package:dartus/tomuss.dart';

void main() async {
  final Dartus tomuss = Dartus(Authentication("p1234567", "a_valid_password"));
  final bool isAuthenticated = await tomuss.authenticate();
  if (!isAuthenticated) {
    print("You are not authenticated. Please check your username and password");
    return;
  }

  final ParsedPage? parsedPageOpt =
      await tomuss.getParsedPage(Dartus.currentSemester());

  if (parsedPageOpt == null) {
    print("There was an error while fetching Tomuss");
    return;
  }

  final ParsedPage parsedPage = parsedPageOpt;

  // list teaching units
  for (final TeachingUnit tu in parsedPage.teachingunits) {
    print(tu.name);
    print("\tGrades:");
    for (final Grade g in tu.grades) {
      print("\t\t${g.name}: ${g.humanGrade}");
    }

    // list masters for current TU
    print("\tMasters:");
    for (final Teacher t in tu.masters) {
      print("\t\t${t.name} (${t.email})");
    }
  }

  // list semesters
  for (final Semester s in parsedPage.semesters) {
    print("${s.name} (${s.url})");
  }
}
