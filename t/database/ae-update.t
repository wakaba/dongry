use strict;
use warnings;
use Path::Tiny;
use lib glob path (__FILE__)->parent->parent->parent->child ('t/lib');
use lib glob path (__FILE__)->parent->parent->parent->child ('t_deps/modules/*/lib');
use Test::Dongry;
use Dongry::Database;

my $dsn = test_dsn 'hoge1';

test {
  my $c = shift;

  my $db = Dongry::Database->new
      (sources => {ae => {dsn => $dsn, anyevent => 1, writable => 1}});

  my $invoked = 0;
  $db->execute ('create table foo1 (id int, name blob)', undef, source_name => 'ae')->then (sub {
    return $db->insert ('foo1', [{id => 1434}], source_name => 'ae');
  })->then (sub {
    return $db->update ('foo1', {name => 'foo'}, where => {id => 1434}, source_name => 'ae');
  })->then (sub {
    my $result = $_[0];
    test {
      isa_ok $result, 'Dongry::Database::Executed';
      ok $result->is_success;
      ok not $result->is_error;
      is $result->row_count, 1;
      dies_here_ok { $result->all };
      dies_here_ok { $result->each (sub { }) };
      dies_here_ok { $result->first };
      dies_here_ok { $result->all_as_rows };
      dies_here_ok { $result->each_as_row (sub { }) };
      dies_here_ok { $result->first_as_row };
    } $c;
    return $db->select ('foo1', {id => 1434}, source_name => 'ae');
  })->then (sub {
    my $result = $_[0];
    test {
      isa_ok $result, 'Dongry::Database::Executed';
      ok $result->is_success;
      ok not $result->is_error;
      eq_or_diff $result->all->to_a, [{id => 1434, name => 'foo'}];
    } $c;
  })->catch (sub {
    warn $_[0]->can ('error_text') ? $_[0]->error_text : $_[0];
  })->then (sub {
    return $db->disconnect;
  })->then (sub {
    test {
      done $c;
      undef $c;
    } $c;
  });
} n => 14, name => 'update promise';

RUN;

=head1 LICENSE

Copyright 2011-2017 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
