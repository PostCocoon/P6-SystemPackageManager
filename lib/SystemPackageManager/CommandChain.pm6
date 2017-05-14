use v6.c;
# use soft;
use Log::Any;

class SystemPackageManager::CommandChain {
  has $.env is rw = {};
  has @.command is rw = [];
  has SystemPackageManager::CommandChain $.pipe-to is rw;

  class Piper { ... }
  class Executor { ... }

  method run {
    return SystemPackageManager::CommandChain::Executor.new(chain => self).run;
  }

  class Executor {
    has @.procs is rw = [];
    has SystemPackageManager::CommandChain $.chain is rw;

    method run() {
      my $current-chain = $.chain;
      my $prev-proc = Proc::Async.new(|$current-chain.command, :r);
      @.procs.push($prev-proc);
      my @promises = [];

      if defined $current-chain.pipe-to {
        while defined $current-chain.pipe-to {
          $current-chain = $current-chain.pipe-to;
          my $proc = Proc::Async.new(|$current-chain.command, :r, :w);
          SystemPackageManager::CommandChain::Piper.do($prev-proc, $proc);
          @promises.push: $prev-proc.start();
          $.procs.push($proc);
          $prev-proc = $proc;
        }
      } else {
        @promises.push: $prev-proc.start();
      }

      return Promise.allof(@promises).then({
        my $proc = @promises[*-1].result;
        $proc.exitcode === 0;
      });
    }
  }


  class Piper {
    has $!buffer = "";
    has $!done = False;
    has $!emptied-buffer = False;
    has $!lock = Lock.new;
    has Proc::Async $.from;
    has Proc::Async $.to;

    submethod do(Proc::Async $from, Proc::Async $to) {
      my $obj = self.new(from => $from, to => $to);
      return $obj.start;
    }

    method start() {
      $.to.^find_method('start').wrap({
        my $res = callsame;
        start {
          until $.to.started {
            sleep(.1);
          }

          $!lock.protect({
            $.to.print($!buffer);
            $!emptied-buffer = True;

            if $!done {
              $.to.close-stdin;
            }
          });
        }

        $res
      });

      $.from.stderr;
      $.from.stdout.tap(-> $v {
        $!lock.protect({
          if $!emptied-buffer {
            $.to.print($v);
          } else {
            $!buffer ~= $v;
          }
        });
      }, quit => {
        $!lock.protect({
          $!done = False;
          if $!emptied-buffer {
            $.to.close-stdin;
          }
        });
      })
    }
  }
}
