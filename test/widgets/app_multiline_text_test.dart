import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wfs/widgets/app_detail_section_card.dart';
import 'package:wfs/widgets/app_multiline_text.dart';

void main() {
  for (final note in ['note\n\nnote', r'note\n\nnote']) {
    testWidgets('Note preserves blank lines for ${note.codeUnits}', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DefaultTextStyle(
              style: const TextStyle(),
              maxLines: 1,
              child: AppDetailSectionCard(
                title: 'Note',
                descWidget: AppMultilineText(label: note),
                fullWidth: true,
              ),
            ),
          ),
        ),
      );

      final finder = find.text('note\n\nnote');
      expect(finder, findsOneWidget);
      final paragraph = tester.renderObject<RenderParagraph>(
        find.descendant(of: finder, matching: find.byType(RichText)),
      );
      expect(paragraph.maxLines, isNull);
      expect(paragraph.didExceedMaxLines, isFalse);
      final firstLine = paragraph
          .getBoxesForSelection(
            const TextSelection(baseOffset: 0, extentOffset: 4),
          )
          .first;
      final lastLine = paragraph
          .getBoxesForSelection(
            const TextSelection(baseOffset: 6, extentOffset: 10),
          )
          .first;
      expect(lastLine.top - firstLine.top, closeTo(44, 1));
      expect(tester.takeException(), isNull);
    });
  }
}
