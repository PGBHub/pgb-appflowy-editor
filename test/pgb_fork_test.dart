// PGBHub's own tests of the fork (upstream's suite isn't carried): the
// changes listed in PGB_FORK.md, and that the editor renders and edits.
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/util/file_picker/file_picker_impl.dart'
    as impl;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the delta input service answers onFocusReceived', () {
    final s = DeltaTextInputService(
      onInsert: (_) async => true,
      onDelete: (_) async => true,
      onReplace: (_) async => true,
      onNonTextUpdate: (_) async => true,
      onPerformAction: (_) async {},
    );
    expect(s.onFocusReceived(), isFalse);
  });

  test('the file picker builds on file_picker 13', () async {
    final picker = impl.FilePicker();
    expect(await picker.saveFile(fileName: 'x'), isNull);
  });

  testWidgets('renders and edits a document', (tester) async {
    final nodes = [
      paragraphNode(text: 'Hello'),
      bulletedListNode(text: 'One'),
    ];
    final editorState = EditorState(
      document: Document.blank()..insert([0], nodes),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppFlowyEditor(
            editorState: editorState,
            editorStyle: const EditorStyle.mobile(),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Hello', findRichText: true), findsOneWidget);
    await editorState.insertText(5, ', world', path: [0]);
    await tester.pump();
    expect(find.text('Hello, world', findRichText: true), findsOneWidget);
    // Let the editor's timers (history, scrolling) finish.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });
}
