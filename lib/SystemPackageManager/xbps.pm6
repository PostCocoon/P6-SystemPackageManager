use v6;
use SystemPackageManager::Abstract;

class SystemPackageManager::xbps does SystemPackageManager::Abstract {
  method does-qualify {
    my $release-file = "/etc/os-release".IO;
    if $release-file.f {
      return True if $release-file.slurp ~~ /:i 'ID="void"'/;
    }

    False;
  }

  method is-distro-package-manager { True }
  method needs-root { True }
}
