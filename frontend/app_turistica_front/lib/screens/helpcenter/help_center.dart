import 'package:flutter/material.dart';

class HelpCenter extends StatelessWidget {
    const HelpCenter({Key? key}) : super(key: key);
  static String routeName = "/helpcenter";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help Center'),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: HelpContent(),
        ),
      ),
    );
  }
}

class HelpContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HelpCenterHeader(),
        SizedBox(height: 20),
        HelpCenterSection(
          title: 'FAQ',
          content: 'Here are some frequently asked questions...',
        ),
        Divider(),
        HelpCenterSection(
          title: 'Contact Us',
          content: 'If you have any questions, feel free to contact us...',
        ),
      ],
    );
  }
}

class HelpCenterHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Welcome to the Help Center',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey,
      ),
    );
  }
}

class HelpCenterSection extends StatelessWidget {
  final String title;
  final String content;

  HelpCenterSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 10),
        Text(
          content,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}