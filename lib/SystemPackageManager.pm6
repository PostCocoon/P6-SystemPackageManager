use v6;
use SystemPackageManager::Abstract;
use SystemPackageManager::Controller;
use SystemPackageManager::Qualifier;
use SystemPackageManager::xbps;
use Log::Any;

class SystemPackageManager does SystemPackageManager::Controller {
  has $.available-package-managers is rw = [
    'SystemPackageManager::xbps',
    'SystemPackageManager::apt-get'
  ];

  has $.installed-package-managers is rw = [];
  has SystemPackageManager::Abstract $!selected;

  method check-if-qualifies(@qualifiers --> Promise) {
    start {
      my $qualifies = False;
      for @qualifiers -> $qualifier {
        given $qualifier.type {
          when file-contents {
            my $file = $qualifier.options<file>.IO;
            if $file.f and $file.slurp ~~ $qualifier.options<regex> {
              $qualifies = True;
              last;
            }
          }

          when executable {
            my $file = $qualifier.options<file>.IO;
            if $file.f and $file.x {
              $qualifies = True;
              last;
            }
          }
        }
      }

      $qualifies;
    }
  }

  method !select-qualifying-package-manager(--> Promise) {
    my @promises = [];
    my $channel = Channel.new;
    for $.available-package-managers.values -> $package-manager {
      @promises.push: start {
        try require ::($package-manager);
        if ::($package-manager) ~~ Failure {
          Log::Any.debug("Couldn't find module {$package-manager}, skipping");
        } elsif ::($package-manager).is-distro-package-manager() and await self.check-if-qualifies(::($package-manager).get-qualifiers()) {
          Log::Any.debug("{$package-manager} qualifies");
          $channel.send: $package-manager if !$channel.closed;
        } else {
          Log::Any.debug("{$package-manager} didn't qualify");
        }
      }
    }

    return Promise.anyof(
      my $found = start {
        $channel.receive();
      },
      Promise.allof(@promises),
    ).then({
      # In case of race condition
      my $pm-name = $channel.poll;
      if $found.status ~~ Kept {
        $pm-name = $found.result;
      }

      $channel.send("");
      $channel.close();
      if ($pm-name ~~ Str) {
        Log::Any.info("Selected " ~ $pm-name ~ " as package manager for this system");
        $!selected = ::($pm-name).new;
        True;
      } else {
        Log::Any.error("Couldn't find any fitting package manager for this system");
        False;
      }
    });

  }

  method ensure-root() {
    if $*USER.Int > 0 {
      Log::Any.error("Current package manager (" ~ $!selected.WHAT.^name ~ ") needs root, currently running as " ~ $*USER.Str);
      return False;
    }

    True;
  }

  method setup-for-this-system() {
    return False if !await self!select-qualifying-package-manager();
    return $.ensure-root() if $!selected.needs-root;
    True;
  }

  method setup ($package-manager, $is-absolute = True --> Bool) {
    my $module-name = ($is-absolute ?? "" !! self.^name ~ "::") ~ $package-manager;
    try require ::($module-name);

    if ::($module-name) ~~ Failure {
      Log::Any.error("Can't find the module " ~ $module-name);
      False;
    } else {
      $!selected = ::($module-name).new;
      True;
    }
  }

  method do-install (List $packages, Hash $options --> Promise) {
    $!selected.do-install($packages, $options);
  }

  method do-remove (List $packages, Hash $options --> Promise) {
    $!selected.do-remove($packages, $options);
  }

  method do-sync (Hash $options --> Promise) {
    $!selected.do-sync($options)
  }

  method do-is-installed (Str $package, Hash $options --> Promise) {
    $!selected.do-is-installed($package, $options)
  }
}
