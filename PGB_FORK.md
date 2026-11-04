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

Everything else is upstream's code as published.

## Updating

Download the newer upstream archive, re-apply the table above, bump the
version (`x.y.z+pgb.1`) and this file, then run `flutter analyze` and
`flutter test` here and the app's `test/features/docs_edit` tests.

## Checks

Not a melos workspace member (it keeps upstream's lints and its own
dependency resolution), and left out of the workspace `format` scripts.

```sh
flutter pub get && flutter analyze && flutter test
```
