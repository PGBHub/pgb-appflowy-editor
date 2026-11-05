# pgb_appflowy_editor — PGBHub's fork of appflowy_editor

This package is a fork of **appflowy_editor 6.2.0** as published on pub.dev
(<https://pub.dev/packages/appflowy_editor/versions/6.2.0>, archive
`appflowy_editor-6.2.0.tar.gz`, upstream
<https://github.com/AppFlowy-IO/appflowy-editor>), forked on 2026-11-04 for the
native Docs editor of the PGB Business app.

## Licence

appflowy_editor is dual-licensed under AGPL-3.0 and MPL-2.0 (see `LICENSE`,
kept unchanged). **PGBHub uses and distributes this fork under the Mozilla
Public License 2.0.** The fork is an open-source package of its own:

- `LICENSE`, `README.md` and `CHANGELOG.md` are upstream's, unchanged.
- Every file PGBHub changed starts with a `Modified by PGBHub` notice (YAML
  files: a `#` comment at the top). Their source stays available under
  MPL-2.0 with the rest of this package.
- Code from this package is never copied into PGBHub's proprietary code; the
  app uses it as a dependency only (its binding lives in the app, in
  `lib/features/docs/edit/`).
- Files under `lib/src/flutter/` are upstream's copies of Flutter code and
  keep their BSD notices.

Upstream's `example/`, `test/` and `documentation/` folders are not carried.
The Dart package name stays `appflowy_editor` so upstream changes merge
cleanly; don't add pub.dev's appflowy_editor next to it.

## Published source

The fork's source is public at <https://github.com/PGBHub/pgb-appflowy-editor>
(branch `main`), as MPL-2.0 requires once the app ships. The app's licences page
(Settings, View licenses) points there (`lib/core/open_source.dart` in
pgb-business-mobile).

Publishing is automatic: `.github/workflows/publish-appflowy-fork.yml`
republishes on every push to `main` that changes this folder (it can also be run
by hand from the Actions tab). One-time setup:

1. `ssh-keygen -t ed25519 -N "" -C appflowy-fork-publish -f ~/fork_key`
2. In github.com/PGBHub/pgb-appflowy-editor, Settings, Deploy keys: add
   `~/fork_key.pub` and tick "Allow write access".
3. In github.com/PGBHub/pgb-mobile-core, Settings, Secrets and variables,
   Actions: add the secret `APPFLOWY_FORK_DEPLOY_KEY` with the contents of
   `~/fork_key`.
4. Delete both key files.

By hand, if ever needed:

```
cd pgb-mobile-core
git subtree split --prefix=packages/pgb_appflowy_editor -b appflowy-fork-public
git push git@github.com:PGBHub/pgb-appflowy-editor.git appflowy-fork-public:main
```

Only this folder and its history are published, never the rest of pgb-mobile-core.

## Changes from 6.2.0

| File | Change |
|---|---|
| `pubspec.yaml` | Version `6.2.0+pgb.1`, `publish_to: none`; `device_info_plus` and `file_picker` constraints widened to the app's (13.x); upstream-only dev dependencies dropped |
| `analysis_options.yaml` | `build/**` excluded |
| `lib/src/editor/util/file_picker/file_picker_impl.dart` | Ported to file_picker 13's static API |
| `lib/src/editor/block_component/image_block_component/image_upload_widget.dart` | file_picker 13: bytes read with `readAsBytes()` |
| `lib/src/editor/editor_component/service/ime/delta_input_service.dart` | `onFocusReceived` (new in Flutter's `TextInputClient`) |
| `lib/src/flutter/scrollable_positioned_list/src/{scroll_view,scrollable_positioned_list,viewport,wrapping}.dart` | `deprecated_member_use` silenced (Flutter 3.41 `cacheExtent` deprecations); behaviour unchanged |
| `lib/src/extensions/node_extensions.dart` | Lint fix (`unnecessary_this`) |
| `lib/src/core/document/node.dart` | `Node.revision`: a counter that changes whenever the node or anything under it changes (attributes, text, children), so the app's binding re-serialises only what an edit touched (phase 1c, large documents) |
| `test/pgb_fork_test.dart` | PGBHub's own tests (upstream's suite isn't carried), incl. `Node.revision` |
| `tool/upstream_merge.sh` | PGBHub's own: the upstream merge below |

Everything else is upstream's code as published.

## Updating (pulling an upstream release)

`tool/upstream_merge.sh <new-version> [<base-version>]` does a three-way
merge per file: the pub.dev archive of the base release (6.2.0 now) is the
common ancestor, this package is ours, the new release is theirs.

- Files PGBHub never changed are replaced by upstream's.
- Files PGBHub changed (the table above, each marked `Modified by PGBHub`)
  are merged with `git merge-file`; conflicts are left with markers.
- New upstream files are added; files upstream removed (and PGBHub never
  changed) are deleted. `example/`, `test/` and `documentation/` stay out.

Then, by hand:

1. Resolve conflicts (`grep -rn '<<<<<<<' lib`), keeping each file's
   `Modified by PGBHub` notice.
2. Bump `pubspec.yaml` to `<new>+pgb.1`, set the base version in this file
   (the first paragraph and the script's default) and update the table.
3. `flutter pub get && flutter analyze && flutter test` here, then in
   pgb-business-mobile `flutter test test/features/docs_edit` (the
   conformance, fuzz and benchmark tests exercise the editor through the
   binding) and a manual pass on a phone (IME, selection handles, tables).
4. Read upstream's CHANGELOG for behaviour changes to the input service,
   selection, transactions and `Node` (the binding depends on them).

Nothing is committed by the script; review the diff like any change.

## Checks

Not a melos workspace member (it keeps upstream's lints and its own
dependency resolution), and left out of the workspace `format` scripts.

```sh
flutter pub get && flutter analyze && flutter test
```
