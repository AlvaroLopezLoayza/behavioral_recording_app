enum AccessRole {
  owner,
  editor,
  viewer;

  String get toStringValue {
    switch (this) {
      case AccessRole.owner:
        return 'owner';
      case AccessRole.editor:
        return 'editor';
      case AccessRole.viewer:
        return 'viewer';
    }
  }

  static AccessRole fromString(String value) {
    switch (value) {
      case 'owner':
        return AccessRole.owner;
      case 'editor':
        return AccessRole.editor;
      case 'viewer':
        return AccessRole.viewer;
      default:
        throw Exception('Unknown AccessRole: $value');
    }
  }
}
