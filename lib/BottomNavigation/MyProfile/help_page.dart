import 'package:flutter/material.dart';
import 'package:qvid/Locale/locale.dart';
import 'package:qvid/Theme/colors.dart';

class Help {
  final String question;
  final String answer;

  Help(this.question, this.answer);
}

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    List<Help> helps = [
        ];
    return Scaffold(
      appBar: AppBar(
        title: Text(locale.help),
        centerTitle: true,
      ),
      body: ListView.builder(
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.all(20.0),
          itemCount: helps.length,
          itemBuilder: (context, index) {
            return RichText(
              text: TextSpan(
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1
                      .copyWith(height: 1.3),
                  children: [
                    TextSpan(text: helps[index].question),
                    TextSpan(
                      text: '\n' + helps[index].answer + '\n',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(color: secondaryColor),
                    ),
                  ]),
            );
          }),
    );
  }
}
