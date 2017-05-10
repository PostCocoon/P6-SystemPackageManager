use v6;

enum SystemPackageManager::QualifierType (
  file-contents => 0,
  executable => 1,
);

class SystemPackageManager::Qualifier {
  has SystemPackageManager::QualifierType $.type;
  has Hash $.options;
}
