use v6;
use Log::Any;

class SystemPackageManager::CommandChain {
  has $.env is rw = {};
  has @.command is rw = [];
  has SystemPackageManager::CommandChain $.pipe-to is rw;

  class Executor {
    has @.procs is rw = [];
    has SystemPackageManager::CommandChain $.chain is rw;

    method run() {
      my $current-chain = $.chain;
      my $prev-proc = Proc::Async.new(|$current-chain.command, :r);
      @.procs.push($prev-proc);

      while defined $current-chain.pipe-to {
        $current-chain = $current-chain.pipe-to;
        my $proc = Proc::Async.new(|$current-chain.command, :r, :w);

        $prev-proc.stdout.tap(-> $text, {
          Log::Any.debug("> " ~ $text);
          $proc.print($text);
        });

        $.procs.push($prec);
        $prev-proc = $proc;
      }

      my @promises = [];

      for 1..@.procs.end -> $i {
        my $proc-before = @.procs[$i - 1];
        my $proc = @.procs[$i];
        @promises.push(start {
          my $real-proc = try sink await $proc.start;
          $prev-proc.close-stdin;
        });
      } if @.procs.elems > 1

      return Promise.allof(@promises).then({
        @.procs[*-1].exitcode;
      });
    }
  }
}
