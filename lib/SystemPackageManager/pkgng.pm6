use v6;
use SystemPackageManager::Abstract;
use SystemPackageManager::Qualifier;
use SystemPackageManager::CommandChain;

class SystemPackageManager::pkgng does SystemPackageManager::Abstract {
  method get-qualifiers {
    return [
     SystemPackageManager::Qualifier.new(
        type => executable,
        options => {
          "file" => "pkg"
        }
      )
    ];
  }

  method get-sync-command (Hash $options --> SystemPackageManager::CommandChain) {
    cmd(<pkg update>);
  }

  method get-install-command (List $packages, Hash $options --> SystemPackageManager::CommandChain) {
    cmd(<pkg install -y>, $packages)
  }

  method get-remove-command (List $packages, Hash $options --> SystemPackageManager::CommandChain) {
    cmd(<pkg remove -y>, $packages);
  }

  method get-is-installed-command (Str $package, Hash $options --> SystemPackageManager::CommandChain) {
    cmd(<pkg info>, $package);
  }

  method is-distro-package-manager { True }
  method needs-root { True }
}
