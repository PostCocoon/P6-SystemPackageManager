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
    SystemPackageManager::CommandChain.new(
      env => {
        DEBIAN_FRONTEND => "noninteractive"
      },
      command => [ 'apt-get', 'update' ]
    );
  }

  method get-install-command (List $packages, Hash $options --> SystemPackageManager::CommandChain) {
    SystemPackageManager::CommandChain.new(
      env => {
        DEBIAN_FRONTEND => "noninteractive"
      },
      command => [ 'apt-get', 'install', '-yq', |$packages ]
    );
  }

  method get-remove-command (List $packages, Hash $options --> SystemPackageManager::CommandChain) {
    SystemPackageManager::CommandChain.new(
      env => {
        DEBIAN_FRONTEND => "noninteractive"
      },
      command => [ 'apt-get', 'remove', '-yq', |$packages ]
    );
  }

  method get-is-installed-command (Str $package, Hash $options --> SystemPackageManager::CommandChain) {
    SystemPackageManager::CommandChain.new(
      env => {
        DEBIAN_FRONTEND => "noninteractive"
      },
      command => [ 'dpkg-query', "-Wf'\$\{db:Status-abbrev\}'", $package ],
      pipe-to => SystemPackageManager::CommandChain.new(
        command => [ 'grep', '-q', '^i' ]
      )
    );
  }

  method is-distro-package-manager { True }
  method needs-root { True }
}
