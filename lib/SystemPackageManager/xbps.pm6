use v6;
use SystemPackageManager::Abstract;
use SystemPackageManager::Qualifier;

class SystemPackageManager::xbps does SystemPackageManager::Abstract {
  method get-qualifiers {
    return [
     SystemPackageManager::Qualifier.new(
        type => "file-contents",
        options => {
          "regex" => /:i id\=\"?void\"?/,
          "file" => "/etc/os-release"
        }
      )
    ];
  }

  method is-distro-package-manager { True }
  method needs-root { True }
}
