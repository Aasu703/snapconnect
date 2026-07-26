import 'package:flutter/material.dart';
import 'package:snapconnect/features/legal/widgets/legal_document_screen.dart';

/// Terms of Service governing use of the SnapConnect app.
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentScreen(
      title: 'Terms of Service',
      effectiveDate: 'July 25, 2026',
      intro:
          'These Terms of Service ("Terms") govern your access to and use of '
          'SnapConnect, a mobile app for creating shared photo albums for '
          'events and parties. By creating an account, joining an event as a '
          'guest, or otherwise using the app, you agree to these Terms.',
      sections: [
        LegalSection('1. The Service', [
          'SnapConnect lets a host create an event, party, or album and '
              'invite guests to view and upload photos, typically via a '
              'join code or QR code. Guests may be able to contribute '
              'photos without creating a full account.',
        ]),
        LegalSection('2. Accounts', [
          'You are responsible for the accuracy of the information you '
              'provide (such as your name and, optionally, your email '
              'address) and for maintaining the security of your device and '
              'session. You must not impersonate another person or create '
              'an account for anyone other than yourself.',
        ]),
        LegalSection('3. Your Content', [
          'You retain ownership of the photos and other content you upload '
              '("Your Content"). By uploading Your Content, you grant '
              'SnapConnect and the host of the relevant event a worldwide, '
              'non-exclusive, royalty-free license to host, store, '
              'reproduce, and display Your Content solely for the purpose '
              'of operating the album and letting other invited guests view '
              'and download it.',
          'You are solely responsible for Your Content and confirm you have '
              'the right to share it and, where it depicts other people, '
              'that you have their permission to do so.',
        ]),
        LegalSection('4. Acceptable Use', [
          'You agree not to upload content that is unlawful, infringing, '
              'harassing, or that violates another person’s privacy or '
              'rights, and not to use the app to gain unauthorized access '
              'to another host’s event, album, or account.',
        ]),
        LegalSection('5. Hosts & Guest Access', [
          'Anyone with a valid join code or QR code for an event can access '
              'that event’s album as a guest. Hosts are responsible for '
              'deciding who they share a join code with and for managing '
              'the photos uploaded to their events.',
        ]),
        LegalSection('6. Termination', [
          'You may stop using SnapConnect and delete your account at any '
              'time from the Profile screen. We may suspend or terminate '
              'access to the app for anyone who violates these Terms.',
        ]),
        LegalSection('7. Disclaimers & Limitation of Liability', [
          'SnapConnect is provided "as is" without warranties of any kind. '
              'To the fullest extent permitted by law, SnapConnect and its '
              'developers are not liable for indirect, incidental, or '
              'consequential damages arising from your use of the app, '
              'including loss of photos or other content.',
        ]),
        LegalSection('8. Changes to These Terms', [
          'We may update these Terms from time to time. Continued use of '
              'the app after an update constitutes acceptance of the '
              'revised Terms.',
        ]),
        LegalSection('9. Contact', [
          'Questions about these Terms can be sent to '
              'support@snapconnect.app.',
        ]),
      ],
    );
  }
}
