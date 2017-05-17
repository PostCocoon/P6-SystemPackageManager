use v6;
use Log::Any;
use SystemPackageManager::Controller;
use SystemPackageManager::CommandChain;

role SystemPackageManager::Abstract does SystemPackageManager::Controller {
  method get-qualifiers (--> List) { ... }
  method is-distro-package-manager (--> Bool) { ... }

  method needs-root (--> Bool) { ... }

  method get-is-installed-command(Str $package, Hash $options --> SystemPackageManager::CommandChain) { ... }

  method get-install-command(List $packages, Hash $options --> SystemPackageManager::CommandChain) { ... }

  method get-remove-command(List $packages, Hash $options --> SystemPackageManager::CommandChain) { ... }

  method get-sync-command(Hash $options --> SystemPackageManager::CommandChain) { ... }

  method run-promise(SystemPackageManager::CommandChain $chain) {
    $chain.run;
  }



  method do-install (List $packages, Hash $options --> Promise) {
    Log::Any.debug("Installing " ~ $packages.perl ~ " with " ~ self.^name ~ " and options " ~ $options.perl);
    self.run-promise(self.get-install-command($packages, $options));
  }

  method do-remove (List $packages, Hash $options --> Promise) {
    self.run-promise(self.get-remove-command($packages, $options));
  }

  method do-sync (Hash $options --> Promise) {
    self.run-promise(self.get-sync-command($options));
  }

  method do-is-installed (Str $package, Hash $options --> Promise) {
    self.run-promise(self.get-is-installed-command($package, $options))
  }
}
