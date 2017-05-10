use v6;

role SystemPackageManager::Controller {

  method do-install (List $packages, Hash $options --> Promise) { ... }
  method do-remove (List $packages, Hash $options --> Promise) { ... }
  method do-sync (Hash $options --> Promise) { ... }
  method do-is-installed (Str $package, Hash $options --> Promise) { ... }

  multi method install (List $packages, Hash $options --> Promise) {
    self.do-install($packages, $options);
  }

  multi method remove (List $packages, Hash $options --> Promise) {
    self.do-remove($packages, $options);
  }

  multi method sync (Hash $options --> Promise) {
    self.do-sync($options);
  }

  multi method is-installed (Str $package, Hash $options --> Promise) {
    self.do-is-installed($package, $options);
  }

  #
  # Overloads
  #
  multi method is-installed (Str $package --> Promise) {
    self.is-installed($package, {});
  }

  multi method install (List $packages --> Promise) {
    self.install($packages, {})
  }

  multi method install (Str $package, Hash $options --> Promise) {
    self.install([$package], $options);
  }

  multi method install (Str $package --> Promise) {
    self.install([$package], {})
  }

  multi method remove (List $packages --> Promise) {
    self.remove($packages, {})
  }

  multi method remove (Str $package, Hash $options --> Promise) {
    self.remove([$package], $options);
  }

  multi method remove (Str $package --> Promise) {
    self.remove([$package], {})
  }

  multi method sync (--> Promise) {
    self.sync({})
  }
}
