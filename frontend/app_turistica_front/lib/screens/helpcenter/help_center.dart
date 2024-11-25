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
          title: 'How to Use the App',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HelpCenterStep(
                stepNumber: '1',
                stepTitle: 'Register',
                stepDescription: 'If you are new, sign up by providing your name, email, and a secure password.',
              ),
              HelpCenterStep(
                stepNumber: '2',
                stepTitle: 'Login',
                stepDescription: 'If you already have an account, log in with your email and password.',
              ),
              HelpCenterStep(
                stepNumber: '3',
                stepTitle: 'Explore Services',
                stepDescription: 'Browse through the various available tourism services. You can view details, photos, and prices of each service.',
              ),
              HelpCenterStep(
                stepNumber: '4',
                stepTitle: 'Reservations',
                stepDescription: 'Select the service you are interested in and make a reservation by providing the desired date and time.',
              ),
              HelpCenterStep(
                stepNumber: '5',
                stepTitle: 'Profile',
                stepDescription: 'In your profile, you can view and edit your personal information, as well as review your reservations.',
              ),
              HelpCenterStep(
                stepNumber: '6',
                stepTitle: 'Promotions',
                stepDescription: 'Stay tuned for special promotions to get discounts on your reservations.',
              ),
            ],
          ),
        ),
        Divider(),
        HelpCenterSection(
          title: 'Contact Us',
          content: Text(
            'If you have any questions or need assistance, feel free to contact us. You can send us an email at:\n\npathi@gmail.com',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}

class HelpCenterHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Welcome to the Help Center',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),
      ),
    );
  }
}

class HelpCenterSection extends StatelessWidget {
  final String title;
  final Widget content;

  HelpCenterSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            content,
          ],
        ),
      ),
    );
  }
}

class HelpCenterStep extends StatelessWidget {
  final String stepNumber;
  final String stepTitle;
  final String stepDescription;

  HelpCenterStep({
    required this.stepNumber,
    required this.stepTitle,
    required this.stepDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: Colors.blueGrey,
            child: Text(
              stepNumber,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stepTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  stepDescription,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}