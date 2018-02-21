# CHANGELOG

The change log for `FunctionalTableData`.
1.1.3
-----
- Remove the unused, non-public function `updateRow` from `FunctionalTableData` and `FunctionalCollectionData`
- Add `void` to block definition where no params are expected

1.1.2
-----
- Fixes an issue that caused laggy renders. Operations were queued by many quick calls to `renderAndDiff`

1.1.1
-----
- Exposes a few properties in `TableSectionChangeSet`

1.1.0
-----

- Adds support for corner radius clipping, `UICollectionViewCell` only.
- Adds support for `canSelectAction`.
- Adds support for `separatorColor`.
- Fixes a bug where the new sections weren't recorded in `NSExceptionName.internalInconsistencyException`.
- Lowers the deployment target to iOS 9.0

1.0.0
-----

Initial release. :heart:
