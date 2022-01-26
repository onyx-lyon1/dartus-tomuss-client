import 'dart:io';

import 'package:dartus/src/parser/parsedpage.dart';
import 'package:dartus/tomuss.dart';
import 'package:dartz/dartz.dart';
import 'package:test/test.dart';
import 'package:dartus/src/utils/urlcreator.dart';

import 'package:dotenv/dotenv.dart' show env, isEveryDefined, load;

void main() async {
  late Dartus tomussOK;
  late Dartus tomussBAD;

  setUpAll(() {
    String username = Platform.environment['username'] ?? "";
    String password = Platform.environment['password'] ?? "";
    try {
      load('test/.env');
      if (isEveryDefined(['username', 'password'])) {
        username = env['username'] ?? "";
        password = env['password'] ?? "";
      }
    } catch (e) {
      // do nothing. Tests will fail and messages will appear if necessary.
    }

    if (username.isEmpty || password.isEmpty) {
      fail("username or password were empty. check your envt variables");
    }
    tomussOK = Dartus(username, password);
    tomussBAD = Dartus("p1234567", "not_valid_password");
  });

  test('Dartus.authenticate ok', () async {
    final bool isAuthenticated = await tomussOK.authenticate();
    expect(isAuthenticated, equals(true));
  });

  test('Dartus.getPage with wrong creds', () async {
    final Option<ParsedPage> parsedPageOpt =
        await tomussBAD.getParsedPage(URLCreator.basic());

    expect(parsedPageOpt.isNone(), equals(true));
  });

  test('Dartus.getPage', () async {
    final Option<ParsedPage> parsedPageOpt =
        await tomussOK.getParsedPage(URLCreator.basic());

    expect(parsedPageOpt.isSome(), equals(true));
    final ParsedPage parsedPage =
        parsedPageOpt.getOrElse(() => ParsedPage.empty());

    expect(parsedPage.semesters.isNotEmpty, equals(true));
    expect(parsedPage.teachingunits.isNotEmpty, equals(true));
  });

  test('Dartus.getPage x2', () async {
    final Option<ParsedPage> parsedPageOpt =
        await tomussOK.getParsedPage(URLCreator.basic());
    expect(parsedPageOpt.isSome(), equals(true));
  }, timeout: Timeout.parse("5m"));

  // TODO: check edge values
  test('Dartus.currentSemester()', () async {
    expect(URLCreator.currentSemester(DateTime.parse("20220124")),
        "https://tomuss.univ-lyon1.fr/S/2022/Printemps");

    expect(URLCreator.currentSemester(DateTime.parse("20211129")),
        "https://tomuss.univ-lyon1.fr/S/2021/Automne");

    expect(URLCreator.previousSemester(DateTime.parse("20220124")),
        "https://tomuss.univ-lyon1.fr/S/2021/Automne");

    expect(URLCreator.previousSemester(DateTime.parse("20211129")),
        "https://tomuss.univ-lyon1.fr/S/2021/Printemps");
  });
}
