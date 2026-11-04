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

  test('Node.revision changes with the node and every ancestor', () async {
    final a = paragraphNode(text: 'a');
    final b = bulletedListNode(text: 'b', children: [paragraphNode(text: 'c')]);
    final editorState = EditorState(
      document: Document.blank()..insert([0], [a, b]),
    );
    final root = editorState.document.root;
    final ra = a.revision;
    final rb = b.revision;
    final rRoot = root.revision;
    // Text inside the nested child: the child, b and the root change; a not.
    final c = b.children.single;
    final rc = c.revision;
    await editorState.apply(editorState.transaction..insertText(c, 1, 'd'));
    expect(c.revision, isNot(rc));
    expect(b.revision, isNot(rb));
    expect(root.revision, isNot(rRoot));
    expect(a.revision, ra);
    // Attributes, inserts and deletes of children count too.
    var r = b.revision;
    b.updateAttributes({'x': 1});
    expect(b.revision, isNot(r));
    r = b.revision;
    b.insert(paragraphNode(text: 'e'));
    expect(b.revision, isNot(r));
    r = b.revision;
    b.children.last.unlink();
    expect(b.revision, isNot(r));
    r = root.revision;
    a.insertAfter(paragraphNode(text: 'f'));
    expect(root.revision, isNot(r));
    expect(a.revision, ra);
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
