use v6;
use Log::Any;
use SystemPackageManager::Controller;

role SystemPackageManager::Abstract does SystemPackageManager::Controller {
  method get-qualifiers (--> List) { ... }
  method is-distro-package-manager (--> Bool) { ... }

  method needs-root (--> Bool) { ... }

  method get-is-installed-command(Str $package, Hash $options --> List) { ... }

  method get-install-command(List $packages, Hash $options --> List) { ... }

  method get-remove-command(List $packages, Hash $options --> List) { ... }

  method get-sync-command(Hash $options --> List) { ... }

  method run-promise(@commands) {
    # TODO run chain of commands instead of only first
    my $command = @commands.shift;
    if (@commands.elems > 0) {

    }
    Log::Any.debug("Executing " ~ $command[0] ~ " with " ~ $command[1..*].perl);
    my $proc = Proc::Async.new($command[0], $command[1..*], :r);
    $proc.stdout.tap( -> $str {
      say $str;
    });

    return (start {
      my $procPromise = $proc.start;
      try sink await $procPromise;
      $procPromise.result;
    }).then({
      .result.exitcode == 0;
    })
  }



  method do-install (List $packages, Hash $options --> Promise) {
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
