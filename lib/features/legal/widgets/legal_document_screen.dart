import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:snapconnect/common/common.dart';

/// A single heading + body block within a [LegalDocumentScreen].
class LegalSection {
  const LegalSection(this.heading, this.paragraphs);

  final String heading;
  final List<String> paragraphs;
}

/// Shared scrollable layout for statutory documents (Terms of Service,
/// Privacy Policy, ...) so both read with the same typography and spacing
/// instead of duplicating scaffold/section boilerplate per screen.
class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.effectiveDate,
    required this.intro,
    required this.sections,
  });

  final String title;
  final String effectiveDate;
  final String intro;
  final List<LegalSection> sections;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = context.text.bodyMedium?.copyWith(
      color: context.appColors.mutedText,
      height: AppDimens.lineHeightRelaxed,
    );

    return Scaffold(
      backgroundColor: context.appColors.screenBackground,
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimens.maxContentWidth),
          child: ListView(
            padding: const EdgeInsets.all(AppDimens.screenPadding),
            children: [
              Text(
                'Effective $effectiveDate',
                style: context.text.labelMedium
                    ?.copyWith(color: context.appColors.mutedText),
              ),
              const Gap(AppDimens.space16),
              Text(intro, style: bodyStyle),
              const Gap(AppDimens.space24),
              for (final section in sections) ...[
                Text(section.heading, style: context.text.titleMedium),
                const Gap(AppDimens.space8),
                for (final paragraph in section.paragraphs) ...[
                  Text(paragraph, style: bodyStyle),
                  const Gap(AppDimens.space12),
                ],
                const Gap(AppDimens.space12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
