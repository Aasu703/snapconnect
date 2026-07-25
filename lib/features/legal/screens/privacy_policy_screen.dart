import 'package:flutter/material.dart';
import 'package:snapconnect/features/legal/widgets/legal_document_screen.dart';

/// Privacy Policy describing what data SnapConnect collects and how it's used.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentScreen(
      title: 'Privacy Policy',
      effectiveDate: 'July 25, 2026',
      intro:
          'This Privacy Policy explains what information SnapConnect '
          'collects, how it is used, and the choices you have. By using '
          'the app you agree to the collection and use of information as '
          'described here.',
      sections: [
        LegalSection('1. Information We Collect', [
          'Account information: the name you provide and, if you choose to '
              'add one, your email address.',
          'Content: photos and any captions or metadata you upload to an '
              'album, event, or party.',
          'Usage & device information: technical data such as your device '
              'type and app logs, used to keep the app working reliably.',
          'Join codes: the event or party codes you create or use to join, '
              'which control who can see a given album.',
        ]),
        LegalSection('2. How We Use Information', [
          'To create and operate your account, albums, events, and '
              'parties.',
          'To let guests with a valid join code or QR code view and '
              'contribute photos to the relevant album.',
          'To diagnose problems, keep the app secure, and improve '
              'reliability.',
          'We do not sell your personal information.',
        ]),
        LegalSection('3. How Photos Are Shared', [
          'Photos uploaded to an event or party are visible to anyone the '
              'host has shared the join code or QR code with. Choose who '
              'you share a join code with accordingly, and ask your host '
              'about an album’s privacy settings if you’re unsure who can '
              'see it.',
        ]),
        LegalSection('4. Third-Party Service Providers', [
          'SnapConnect uses third-party infrastructure providers to store '
              'and serve data on our behalf — including cloud media hosting '
              'for photos and backend data storage. These providers process '
              'data only as needed to provide the app’s functionality and '
              'under their own security and privacy commitments.',
        ]),
        LegalSection('5. Data Retention & Deletion', [
          'We retain your account information and content for as long as '
              'your account is active. You can delete your account from '
              'the Profile screen; you may also ask us to delete your data '
              'by contacting us at the email below. Deleting an album or '
              'account may not immediately remove photos already saved by '
              'other guests to their own devices.',
        ]),
        LegalSection('6. Your Choices', [
          'Adding an email address is optional. You can edit your name, '
              'update or remove your email, and delete your account at any '
              'time from the Profile screen.',
        ]),
        LegalSection('7. Children’s Privacy', [
          'SnapConnect is not directed at children under 13, and we do not '
              'knowingly collect personal information from children under '
              '13. If you believe a child has provided us with personal '
              'information, please contact us so we can remove it.',
        ]),
        LegalSection('8. Changes to This Policy', [
          'We may update this Privacy Policy from time to time. Material '
              'changes will be reflected by updating the effective date at '
              'the top of this page.',
        ]),
        LegalSection('9. Contact', [
          'Questions about this Privacy Policy or your data can be sent to '
              'support@snapconnect.app.',
        ]),
      ],
    );
  }
}
