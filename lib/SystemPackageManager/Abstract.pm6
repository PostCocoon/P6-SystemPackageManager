use v6;

role SystemPackageManager::Abstract {
  method does-qualify (--> Bool) { ... }
  method is-distro-package-manager (--> Bool) { ... }

  sub needs-root (--> Bool) { ... }
  sub is-installed (Str $package, Hash $options --> Bool) { ... }
  sub install (Str $packge, Hash $options --> Bool) { ... }
  sub remove (Str $packge, Hash $options --> Bool) { ... }
  sub sync (Hash $options --> Bool) { ... }
}
