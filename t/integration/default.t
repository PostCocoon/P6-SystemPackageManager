use v6;
use Test;

my $pkg = "llvm";

sub run-ok(*$command) {
  ok run($command).exitcode === 0, "Ran " ~ $command.join(" ");
}

sub p6spm-ok($box, $action, *$stuff) {
  run-ok(<vagrant ssh>, $box, "-c", "perl6 -I/vagrant/lib /vagrant/bin/p6spm " ~ $action ~ $stuff.join(" "));
}

sub fail-p6spm($box, $action, *$stuff) {
  fail-run(<vagrant ssh>, $box, "-c", "perl6 -I/vagrant/lib /vagrant/bin/p6spm " ~ $action ~ $stuff.join(" "));
}

sub fail-run() {
  ok run($command).exitcode !== 0, "Ran " ~ $command.join(" ");
}

my $boxes = run(<vagrant status>, :out).out.slurp.lines[2..*-5].map({ .words[0] });

plan $boxes.elems * 1;
for $boxes -> $box {
  run-ok(<vagrant up>, $box);
  fail-p6spm "is-installed", $pkg;
  p6spm-ok "sync";
  p6spm-ok "install", $pkg;
  p6spm-ok "is-installed", $pkg;
  p6spm-ok "remove", $pkg;
}
