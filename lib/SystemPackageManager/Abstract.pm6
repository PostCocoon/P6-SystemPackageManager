use v6;

role SystemPackageManager::Abstract {
  method get-qualifiers (--> List) { ... }
  method is-distro-package-manager (--> Bool) { ... }

  sub needs-root (--> Bool) { ... }
  sub is-installed (Str $package, Hash $options --> Promise) { ... }
  sub install (Str $packge, Hash $options --> Promise) { ... }
  sub remove (Str $packge, Hash $options --> Promise) { ... }
  sub sync (Hash $options --> Promise) { ... }
}
