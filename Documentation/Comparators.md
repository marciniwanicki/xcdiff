# Comparators

The list of built-in comparators available in xcdiff.

### `configurations`

Compares build configurations i.e. Debug, Release.

### `dependencies`

Compares linked and embedded frameworks.

### `file_references`

Compares all file references in the Xcode project.

As the comparator is very sensitive, it's likely that differences from other comparators will be flagged here too.

### `headers`

Compares headers including their visibility attributes i.e. Public, Project, and Private.

### `resolved_settings` (optional)

Compares evaluated build settings, the final values used by the build system.

As the comparator uses `xcodebuild -showBuildSettings` under the hood, it can be slow depending on the number of targets and configurations being compared. As such it's not included in the default list of comparators.

### `resources`

Compares resources i.e. files copied to the resources directory.

### `settings`

Compares raw project and target level build settings values.

### `sources`

Compares sources including their compiler flag attributes.

### `source_trees`

Compares the project group structure.

### `targets`

Compares target names and types.
