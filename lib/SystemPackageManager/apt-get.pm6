use v6;
use SystemPackageManager::Abstract;
use SystemPackageManager::Qualifier;
use SystemPackageManager::CommandChain;

class SystemPackageManager::apt-get does SystemPackageManager::Abstract {
  method get-qualifiers {
    return [
     SystemPackageManager::Qualifier.new(
        type => executable,
        options => {
          "file" => "apt-get"
        }
      )
    ];
  }

  method get-sync-command (Hash $options --> SystemPackageManager::CommandChain) {
    cmd(
      <apt-get update>,
      env => {
        DEBIAN_FRONTEND => "noninteractive"
      }
    );
  }

  method get-install-command (List $packages, Hash $options --> SystemPackageManager::CommandChain) {
    cmd(
      <apt-get install -yq>, $packages,
      env => {
        DEBIAN_FRONTEND => "noninteractive"
      }
    );
  }

  method get-remove-command (List $packages, Hash $options --> SystemPackageManager::CommandChain) {
    cmd(
      <apt-get remove -yq>, $packages,
      env => {
        DEBIAN_FRONTEND => "noninteractive"
      }
    );
  }

  method get-is-installed-command (Str $package, Hash $options --> SystemPackageManager::CommandChain) {
    cmd(
      <dpkg-query -Wf>, "\$\{db:Status-abbrev\}", $package,
      env => {
        DEBIAN_FRONTEND => "noninteractive"
      }
    );
  }

  method is-distro-package-manager { True }
  method needs-root { True }
}
