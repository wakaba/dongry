use strict;
use warnings;
use Path::Tiny;
use lib glob path (__FILE__)->parent->parent->parent->child ('t/lib');
use lib glob path (__FILE__)->parent->parent->parent->child ('t_deps/modules/*/lib');
use Test::X1;
use Test::Dongry;
use Dongry::Database;

my $dsn = test_dsn 'hoge1';

test {
  my $c = shift;

  my $db = Dongry::Database->new
      (sources => {master => {dsn => $dsn, anyevent => 1}});

  dies_here_ok {
    $db->transaction;
  };

  $db->execute ('show tables', undef, source_name => 'master', cb => sub {
    $_[0]->disconnect (undef, cb => sub {
      test {
        done $c;
        undef $c;
      } $c;
    });
  });
} n => 1, name => 'transaction';

run_tests;

=head1 LICENSE

Copyright 2011-2014 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
