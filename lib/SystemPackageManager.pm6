use v6;
use SystemPackageManager::Abstract;
use SystemPackageManager::xbps;
use Log::Any;

class SystemPackageManager {
  has $.available-package-managers = <
    SystemPackageManager::xbps
    SystemPackageManager::apt-get
  >;

  has $.installed-package-managers is rw = [];
  has SystemPackageManager::Abstract $!selected;

  method !select-package-manager() {
    for $.available-package-managers.values -> $package-manager {
      try require ::($package-manager);
      if ::($package-manager) ~~ Failure {
        Log::Any.debug("Couldn't find module {$package-manager}, skipping");
        next;
      }

      if ::($package-manager).is-distro-package-manager() and ::($package-manager).does-qualify() {
        Log::Any.info("Selected {$package-manager} as package manager to use for this system");
        $!selected = ::($package-manager).new;
        return True;
      }
    }

    Log::Any.error("Couldn't find any fitting package manager for this system");
    False;
  }

  method ensure-root() {
    if $*USER.Int > 0 {
      Log::Any.error("Current package manager (" ~ $!selected.WHAT.^name ~ ") needs root, currently running as " ~ $*USER.Str);
    }
  }

  method setup-for-this-system() {
    return False if !self!select-package-manager();
    return $.ensure-root() if $!selected.needs-root;
    True;
  }

  method sync(Hash $options = {} --> Bool) {
    $!selected.sync($options);
  }
}
