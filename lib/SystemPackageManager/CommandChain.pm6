use v6.c;
use experimental :pack;
# use soft;
use Log::Any;

class SystemPackageManager::CommandChain { ... }

sub cmd(*@command, *%args) is export {
  %args<command> //= @command.List;
  SystemPackageManager::CommandChain.new(|%args)
}

class SystemPackageManager::CommandChain {
  has $.env is rw = {};
  has $.command is rw = [];
  has SystemPackageManager::CommandChain $.pipe-to is rw;

  class Executor { ... }

  method run {
    return SystemPackageManager::CommandChain::Executor.new(chain => self).run;
  }

  class Executor {
    has @.procs is rw = [];
    has SystemPackageManager::CommandChain $.chain is rw;

    method !pipe($from, $to) {
      my $buffer = "";
      my $done = False;
      my $emptied-buffer = False;
      my $lock = Lock.new;
      my Proc::Async $.from;
      my Proc::Async $.to;

      $to.ready.then({
        $lock.protect({
          $to.print($buffer);
          $emptied-buffer = True;

          if $done {
            $to.close-stdin;
          }
        });
      });

      $from.stderr;
      $from.stdout.tap(-> $v {
        $lock.protect({
          if $emptied-buffer {
            $to.print($v);
          } else {
            $buffer ~= $v;
          }
        });
      }, done => {
        $lock.protect({
          $done = True;
          if $emptied-buffer {
            $to.close-stdin;
          }
        });
      });
    }

    method run() {
      my $current-chain = $.chain;
      my $prev-proc = Proc::Async.new(|$current-chain.command, :r);
      @.procs.push($prev-proc);
      my @promises = [];

      while defined $current-chain.pipe-to {
        $current-chain = $current-chain.pipe-to;
        my $proc = Proc::Async.new(|$current-chain.command, :r, :w);
        self!pipe($prev-proc, $proc);
        @promises.push: $prev-proc.start();
        $.procs.push($proc);
        $prev-proc = $proc;
      }

      $prev-proc.stdout;
      @promises.push: $prev-proc.start();

      return Promise.allof(@promises).then({
        my $proc = @promises[*-1].result;
        $proc.exitcode === 0;
      });
    }
  }
}
