use v6;
use SystemPackageManager::Abstract;
use SystemPackageManager::Qualifier;
use SystemPackageManager::CommandChain;

class SystemPackageManager::xbps does SystemPackageManager::Abstract {
  method get-qualifiers {
    return [
     SystemPackageManager::Qualifier.new(
        type => file-contents,
        options => {
          "regex" => /:i id\=\"?void\"?/,
          "file" => "/etc/os-release"
        }
      )
    ];
  }

  method get-sync-command (Hash $options --> SystemPackageManager::CommandChain) {
    cmd(<xbps-install -S>)
  }

  method get-install-command (List $packages, Hash $options --> SystemPackageManager::CommandChain) {
    cmd(<xbps-install -y>, $packages)
  }

  method get-remove-command (List $packages, Hash $options --> SystemPackageManager::CommandChain) {
    cmd(<xbps-remove -y>, $packages);
  }

  method get-is-installed-command (Str $package, Hash $options --> SystemPackageManager::CommandChain) {
    cmd("xbps-query", $package);
  }

  method is-distro-package-manager (--> Bool) { True }
  method needs-root (--> Bool) { True }
}
