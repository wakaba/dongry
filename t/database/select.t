package test::Dongry::Database::select;
use strict;
use warnings;
use Path::Class;
use lib file (__FILE__)->dir->parent->subdir ('lib')->stringify;
use Test::Dongry;
use base qw(Test::Class);
use Dongry::Database;
use Encode;

sub _select_nothing_each : Test(11) {
  reset_db_set;
  my $dsn = test_dsn 'test1';
  my $db = Dongry::Database->new
      (sources => {master => {dsn => $dsn, writable => 1},
                   default => {dsn => $dsn}});
  $db->execute ('create table foo (id int, v1 text, v2 text)');
  
  my $result = $db->select ('foo', {id => 1243, v1 => "hoge", v2 => undef});
  isa_ok $result, 'Dongry::Database::Executed';
  is $result->row_count, 0;
  is $result->table_name, 'foo';
  my $invoked = 0;
  $result->each (sub { $invoked++ });
  is $invoked, 0;
  dies_ok { $result->each (sub { $invoked++ }) };
  dies_ok { $result->each_as_row (sub { $invoked++ }) };
  is $invoked, 0;
  dies_ok { $result->all };
  dies_ok { $result->all_as_rows };
  dies_ok { $result->first };
  dies_ok { $result->first_as_row };
} # _select_nothing_each

sub _select_nothing_each_as_row : Test(11) {
  reset_db_set;
  my $dsn = test_dsn 'test1';
  my $db = Dongry::Database->new
      (sources => {master => {dsn => $dsn, writable => 1},
                   default => {dsn => $dsn}});
  $db->execute ('create table foo (id int, v1 text, v2 text)');
  
  my $result = $db->select ('foo', {id => 1243, v1 => "hoge", v2 => undef});
  isa_ok $result, 'Dongry::Database::Executed';
  is $result->row_count, 0;
  is $result->table_name, 'foo';
  my $invoked = 0;
  $result->each_as_row (sub { $invoked++ });
  is $invoked, 0;
  dies_ok { $result->each_as_row (sub { $invoked++ }) };
  dies_ok { $result->each (sub { $invoked++ }) };
  is $invoked, 0;
  dies_ok { $result->all };
  dies_ok { $result->all_as_rows };
  dies_ok { $result->first };
  dies_ok { $result->first_as_row };
} # _select_nothing_each_as_row

sub _select_nothing_first : Test(11) {
  reset_db_set;
  my $dsn = test_dsn 'test1';
  my $db = Dongry::Database->new
      (sources => {master => {dsn => $dsn, writable => 1},
                   default => {dsn => $dsn}});
  $db->execute ('create table foo (id int, v1 text, v2 text)');
  
  my $result = $db->select ('foo', {id => 1243, v1 => "hoge", v2 => undef});
  isa_ok $result, 'Dongry::Database::Executed';
  is $result->row_count, 0;
  is $result->table_name, 'foo';
  is $result->first, undef;
  dies_ok { $result->first };
  dies_ok { $result->first_as_row };
  my $invoked = 0;
  dies_ok { $result->each (sub { $invoked++ }) };
  dies_ok { $result->each_as_row (sub { $invoked++ }) };
  is $invoked, 0;
  dies_ok { $result->all };
  dies_ok { $result->all_as_rows };
} # _select_nothing_first

sub _select_nothing_first_as_row : Test(11) {
  reset_db_set;
  my $dsn = test_dsn 'test1';
  my $db = Dongry::Database->new
      (sources => {master => {dsn => $dsn, writable => 1},
                   default => {dsn => $dsn}});
  $db->execute ('create table foo (id int, v1 text, v2 text)');
  
  my $result = $db->select ('foo', {id => 1243, v1 => "hoge", v2 => undef});
  isa_ok $result, 'Dongry::Database::Executed';
  is $result->row_count, 0;
  is $result->table_name, 'foo';
  is $result->first_as_row, undef;
  dies_ok { $result->first };
  dies_ok { $result->first_as_row };
  my $invoked = 0;
  dies_ok { $result->each_as_row (sub { $invoked++ }) };
  dies_ok { $result->each (sub { $invoked++ }) };
  is $invoked, 0;
  dies_ok { $result->all };
  dies_ok { $result->all_as_rows };
} # _select_nothing_first_as_row

sub _select_nothing_all : Test(11) {
  reset_db_set;
  my $dsn = test_dsn 'test1';
  my $db = Dongry::Database->new
      (sources => {master => {dsn => $dsn, writable => 1},
                   default => {dsn => $dsn}});
  $db->execute ('create table foo (id int, v1 text, v2 text)');
  
  my $result = $db->select ('foo', {id => 1243, v1 => "hoge", v2 => undef});
  isa_ok $result, 'Dongry::Database::Executed';
  is $result->row_count, 0;
  is $result->table_name, 'foo';
  isa_list_n_ok $result->all, 0;
  dies_ok { $result->all };
  dies_ok { $result->all_as_rows };
  dies_ok { $result->first };
  dies_ok { $result->first_as_row };
  my $invoked = 0;
  dies_ok { $result->each (sub { $invoked++ }) };
  dies_ok { $result->each_as_row (sub { $invoked++ }) };
  is $invoked, 0;
} # _select_nothing_all

sub _select_nothing_all_as_rows : Test(11) {
  reset_db_set;
  my $dsn = test_dsn 'test1';
  my $db = Dongry::Database->new
      (sources => {master => {dsn => $dsn, writable => 1},
                   default => {dsn => $dsn}});
  $db->execute ('create table foo (id int, v1 text, v2 text)');
  
  my $result = $db->select ('foo', {id => 1243, v1 => "hoge", v2 => undef});
  isa_ok $result, 'Dongry::Database::Executed';
  is $result->row_count, 0;
  is $result->table_name, 'foo';
  isa_list_n_ok $result->all_as_rows, 0;
  dies_ok { $result->all };
  dies_ok { $result->all_as_rows };
  dies_ok { $result->first };
  dies_ok { $result->first_as_row };
  my $invoked = 0;
  dies_ok { $result->each_as_row (sub { $invoked++ }) };
  dies_ok { $result->each (sub { $invoked++ }) };
  is $invoked, 0;
} # _select_nothing_first_as_row

sub _select_a_row_each : Test(12) {
  reset_db_set;
  my $dsn = test_dsn 'test1';
  my $db = Dongry::Database->new
      (sources => {master => {dsn => $dsn, writable => 1},
                   default => {dsn => $dsn}});
  $db->execute ('create table foo (id int, v1 text, v2 text)');
  $db->execute ('insert into foo (id, v1, v2) values (12, "abc", 322)');
  
  my $result = $db->select ('foo', {id => 12});
  isa_ok $result, 'Dongry::Database::Executed';
  is $result->row_count, 1;
  is $result->table_name, 'foo';
  my $invoked = 0;
  my @value;
  $result->each (sub { push @value, $_; $invoked++ });
  is $invoked, 1;
  eq_or_diff \@value, [{id => 12, v1 => 'abc', v2 => '322'}];
  dies_ok { $result->each (sub { $invoked++ }) };
  dies_ok { $result->each_as_row (sub { $invoked++ }) };
  is $invoked, 1;
  dies_ok { $result->all };
  dies_ok { $result->all_as_rows };
  dies_ok { $result->first };
  dies_ok { $result->first_as_row };
} # _select_a_row_each

sub _select_a_row_each_as_row : Test(15) {
  reset_db_set;
  my $dsn = test_dsn 'test1';
  my $db = Dongry::Database->new
      (sources => {master => {dsn => $dsn, writable => 1},
                   default => {dsn => $dsn}});
  $db->execute ('create table foo (id int, v1 text, v2 text)');
  $db->execute ('insert into foo (id, v1, v2) values (12, "abc", 322)');
  
  my $result = $db->select ('foo', {id => 12});
  isa_ok $result, 'Dongry::Database::Executed';
  is $result->row_count, 1;
  is $result->table_name, 'foo';
  my $invoked = 0;
  my @value;
  $result->each_as_row (sub { push @value, $_; $invoked++ });
  is $invoked, 1;
  isa_ok $value[0], 'Dongry::Table::Row';
  is $value[0]->{db}, $db;
  is $value[0]->{table_name}, 'foo';
  eq_or_diff $value[0]->{data}, {id => 12, v1 => 'abc', v2 => '322'};
  dies_ok { $result->each_as_row (sub { $invoked++ }) };
  dies_ok { $result->each (sub { $invoked++ }) };
  is $invoked, 1;
  dies_ok { $result->all };
  dies_ok { $result->all_as_rows };
  dies_ok { $result->first };
  dies_ok { $result->first_as_row };
} # _select_a_row_each_as_row

sub _select_a_row_first : Test(12) {
  reset_db_set;
  my $dsn = test_dsn 'test1';
  my $db = Dongry::Database->new
      (sources => {master => {dsn => $dsn, writable => 1},
                   default => {dsn => $dsn}});
  $db->execute ('create table foo (id int, v1 text, v2 text)');
  $db->execute ('insert into foo (id, v1, v2) values (12, "abc", 322)');
  
  my $result = $db->select ('foo', {id => 12});
  isa_ok $result, 'Dongry::Database::Executed';
  is $result->row_count, 1;
  is $result->table_name, 'foo';
  my $invoked = 0;
  eq_or_diff $result->first, {id => 12, v1 => 'abc', v2 => '322'};
  dies_ok { $result->first };
  dies_ok { $result->first_as_row };
  dies_ok { $result->each (sub { $invoked++ }) };
  dies_ok { $result->each_as_row (sub { $invoked++ }) };
  is $invoked, 0;
  dies_ok { $result->all };
  dies_ok { $result->all_as_rows };
} # _select_a_row_first

sub _select_a_row_first_as_row : Test(14) {
  reset_db_set;
  my $dsn = test_dsn 'test1';
  my $db = Dongry::Database->new
      (sources => {master => {dsn => $dsn, writable => 1},
                   default => {dsn => $dsn}});
  $db->execute ('create table foo (id int, v1 text, v2 text)');
  $db->execute ('insert into foo (id, v1, v2) values (12, "abc", 322)');
  
  my $result = $db->select ('foo', {id => 12});
  isa_ok $result, 'Dongry::Database::Executed';
  is $result->row_count, 1;
  is $result->table_name, 'foo';
  my $invoked = 0;
  my $value = $result->first_as_row;
  isa_ok $value, 'Dongry::Table::Row';
  is $value->{db}, $db;
  is $value->{table_name}, 'foo';
  eq_or_diff $value->{data}, {id => 12, v1 => 'abc', v2 => '322'};
  dies_ok { $result->first };
  dies_ok { $result->first_as_row };
  dies_ok { $result->each_as_row (sub { $invoked++ }) };
  dies_ok { $result->each (sub { $invoked++ }) };
  is $invoked, 0;
  dies_ok { $result->all };
  dies_ok { $result->all_as_rows };
} # _select_a_row_first_as_row

sub _select_a_row_all : Test(12) {
  reset_db_set;
  my $dsn = test_dsn 'test1';
  my $db = Dongry::Database->new
      (sources => {master => {dsn => $dsn, writable => 1},
                   default => {dsn => $dsn}});
  $db->execute ('create table foo (id int, v1 text, v2 text)');
  $db->execute ('insert into foo (id, v1, v2) values (12, "abc", 322)');
  
  my $result = $db->select ('foo', {id => 12});
  isa_ok $result, 'Dongry::Database::Executed';
  is $result->row_count, 1;
  is $result->table_name, 'foo';
  my $invoked = 0;
  my $list = $result->all;
  isa_list_n_ok $list, 1;
  eq_or_diff $list->to_a, [{id => 12, v1 => 'abc', v2 => '322'}];
  dies_ok { $result->all };
  dies_ok { $result->all_as_rows };
  dies_ok { $result->first };
  dies_ok { $result->first_as_row };
  dies_ok { $result->each (sub { $invoked++ }) };
  dies_ok { $result->each_as_row (sub { $invoked++ }) };
  is $invoked, 0;
} # _select_a_row_all

sub _select_a_row_all_as_rows : Test(15) {
  reset_db_set;
  my $dsn = test_dsn 'test1';
  my $db = Dongry::Database->new
      (sources => {master => {dsn => $dsn, writable => 1},
                   default => {dsn => $dsn}});
  $db->execute ('create table foo (id int, v1 text, v2 text)');
  $db->execute ('insert into foo (id, v1, v2) values (12, "abc", 322)');
  
  my $result = $db->select ('foo', {id => 12});
  isa_ok $result, 'Dongry::Database::Executed';
  is $result->row_count, 1;
  is $result->table_name, 'foo';
  my $invoked = 0;
  my $list = $result->all_as_rows;
  isa_list_n_ok $list, 1;
  my $values = $list->to_a;
  isa_ok $values->[0], 'Dongry::Table::Row';
  is $values->[0]->{db}, $db;
  is $values->[0]->{table_name}, 'foo';
  eq_or_diff $values->[0]->{data}, {id => 12, v1 => 'abc', v2 => '322'};
  dies_ok { $result->all };
  dies_ok { $result->all_as_rows };
  dies_ok { $result->first };
  dies_ok { $result->first_as_row };
  dies_ok { $result->each_as_row (sub { $invoked++ }) };
  dies_ok { $result->each (sub { $invoked++ }) };
  is $invoked, 0;
} # _select_a_row_all_as_rows

sub _select_multiple_rows_each : Test(12) {
  reset_db_set;
  my $dsn = test_dsn 'test1';
  my $db = Dongry::Database->new
      (sources => {master => {dsn => $dsn, writable => 1},
                   default => {dsn => $dsn}});
  $db->execute ('create table foo (id int, v1 text, v2 text)');
  $db->execute ('insert into foo (id, v1, v2) values (12, "abc", 322)');
  $db->execute ('insert into foo (id, v1, v2) values (23, NULL, "xyxa")');
  
  my $result = $db->select ('foo', {id => {-in => [12, 23]}});
  isa_ok $result, 'Dongry::Database::Executed';
  is $result->row_count, 2;
  is $result->table_name, 'foo';
  my $invoked = 0;
  my @value;
  $result->each (sub { push @value, $_; $invoked++ });
  is $invoked, 2;
  eq_or_diff [sort { $a->{id} <=> $b->{id} } @value],
             [{id => 12, v1 => 'abc', v2 => '322'},
              {id => 23, v1 => undef, v2 => 'xyxa'}];
  dies_ok { $result->each (sub { $invoked++ }) };
  dies_ok { $result->each_as_row (sub { $invoked++ }) };
  is $invoked, 2;
  dies_ok { $result->all };
  dies_ok { $result->all_as_rows };
  dies_ok { $result->first };
  dies_ok { $result->first_as_row };
} # _select_multiple_rows_each

sub _select_multiple_rows_each_as_row : Test(19) {
  reset_db_set;
  my $dsn = test_dsn 'test1';
  my $db = Dongry::Database->new
      (sources => {master => {dsn => $dsn, writable => 1},
                   default => {dsn => $dsn}});
  $db->execute ('create table foo (id int, v1 text, v2 text)');
  $db->execute ('insert into foo (id, v1, v2) values (12, "abc", 322)');
  $db->execute ('insert into foo (id, v1, v2) values (23, NULL, "xyxa")');
  
  my $result = $db->select ('foo', {id => {-in => [12, 23]}});
  isa_ok $result, 'Dongry::Database::Executed';
  is $result->row_count, 2;
  is $result->table_name, 'foo';
  my $invoked = 0;
  my @value;
  $result->each_as_row (sub { push @value, $_; $invoked++ });
  is $invoked, 2;
  @value = sort { $a->{id} <=> $b->{id} } @value;
  isa_ok $value[0], 'Dongry::Table::Row';
  is $value[0]->{db}, $db;
  is $value[0]->{table_name}, 'foo';
  eq_or_diff $value[0]->{data}, {id => 12, v1 => 'abc', v2 => '322'};
  isa_ok $value[1], 'Dongry::Table::Row';
  is $value[1]->{db}, $db;
  is $value[1]->{table_name}, 'foo';
  eq_or_diff $value[1]->{data}, {id => 23, v1 => undef, v2 => 'xyxa'};
  dies_ok { $result->each_as_row (sub { $invoked++ }) };
  dies_ok { $result->each (sub { $invoked++ }) };
  is $invoked, 2;
  dies_ok { $result->all };
  dies_ok { $result->all_as_rows };
  dies_ok { $result->first };
  dies_ok { $result->first_as_row };
} # _select_multiple_rows_each_as_row

sub _select_multiple_rows_first : Test(12) {
  reset_db_set;
  my $dsn = test_dsn 'test1';
  my $db = Dongry::Database->new
      (sources => {master => {dsn => $dsn, writable => 1},
                   default => {dsn => $dsn}});
  $db->execute ('create table foo (id int, v1 text, v2 text)');
  $db->execute ('insert into foo (id, v1, v2) values (12, "abc", 322)');
  $db->execute ('insert into foo (id, v1, v2) values (23, NULL, "xyxa")');
  
  my $result = $db->select ('foo', {id => {-in => [12, 23]}});
  isa_ok $result, 'Dongry::Database::Executed';
  is $result->row_count, 2;
  is $result->table_name, 'foo';
  my $invoked = 0;
  my $value = $result->first;
  eq_or_diff $value,
      $value->{id} == 12 ? {id => 12, v1 => 'abc', v2 => '322'}
                         : {id => 23, v1 => undef, v2 => 'xyxa'};
  dies_ok { $result->first };
  dies_ok { $result->first_as_row };
  dies_ok { $result->each (sub { $invoked++ }) };
  dies_ok { $result->each_as_row (sub { $invoked++ }) };
  is $invoked, 0;
  dies_ok { $result->all };
  dies_ok { $result->all_as_rows };
} # _select_multiple_rows_first

sub _select_multiple_rows_first_as_row : Test(14) {
  reset_db_set;
  my $dsn = test_dsn 'test1';
  my $db = Dongry::Database->new
      (sources => {master => {dsn => $dsn, writable => 1},
                   default => {dsn => $dsn}});
  $db->execute ('create table foo (id int, v1 text, v2 text)');
  $db->execute ('insert into foo (id, v1, v2) values (12, "abc", 322)');
  $db->execute ('insert into foo (id, v1, v2) values (23, NULL, "xyxa")');
  
  my $result = $db->select ('foo', {id => {-in => [12, 23]}});
  isa_ok $result, 'Dongry::Database::Executed';
  is $result->row_count, 2;
  is $result->table_name, 'foo';
  my $invoked = 0;
  my $value = $result->first_as_row;
  isa_ok $value, 'Dongry::Table::Row';
  is $value->{db}, $db;
  is $value->{table_name}, 'foo';
  eq_or_diff $value->{data},
      $value->{data}->{id} == 12 ? {id => 12, v1 => 'abc', v2 => '322'}
                                 : {id => 23, v1 => undef, v2 => 'xyxa'};
  dies_ok { $result->first };
  dies_ok { $result->first_as_row };
  dies_ok { $result->each_as_row (sub { $invoked++ }) };
  dies_ok { $result->each (sub { $invoked++ }) };
  is $invoked, 0;
  dies_ok { $result->all };
  dies_ok { $result->all_as_rows };
} # _select_multiple_rows_first_as_row

sub _select_multiple_rows_all : Test(12) {
  reset_db_set;
  my $dsn = test_dsn 'test1';
  my $db = Dongry::Database->new
      (sources => {master => {dsn => $dsn, writable => 1},
                   default => {dsn => $dsn}});
  $db->execute ('create table foo (id int, v1 text, v2 text)');
  $db->execute ('insert into foo (id, v1, v2) values (12, "abc", 322)');
  $db->execute ('insert into foo (id, v1, v2) values (23, NULL, "xyxa")');
  
  my $result = $db->select ('foo', {id => {-in => [12, 23]}});
  isa_ok $result, 'Dongry::Database::Executed';
  is $result->row_count, 2;
  is $result->table_name, 'foo';
  my $invoked = 0;
  my $list = $result->all;
  isa_list_n_ok $list, 2;
  eq_or_diff $list->sort (sub { $_[0]->{id} <=> $_[1]->{id} })->to_a,
      [{id => 12, v1 => 'abc', v2 => '322'},
       {id => 23, v1 => undef, v2 => 'xyxa'}];
  dies_ok { $result->all };
  dies_ok { $result->all_as_rows };
  dies_ok { $result->first };
  dies_ok { $result->first_as_row };
  dies_ok { $result->each (sub { $invoked++ }) };
  dies_ok { $result->each_as_row (sub { $invoked++ }) };
  is $invoked, 0;
} # _select_multiple_rows_all

sub _select_multiple_rows_all_as_rows : Test(19) {
  reset_db_set;
  my $dsn = test_dsn 'test1';
  my $db = Dongry::Database->new
      (sources => {master => {dsn => $dsn, writable => 1},
                   default => {dsn => $dsn}});
  $db->execute ('create table foo (id int, v1 text, v2 text)');
  $db->execute ('insert into foo (id, v1, v2) values (12, "abc", 322)');
  $db->execute ('insert into foo (id, v1, v2) values (23, NULL, "xyxa")');
  
  my $result = $db->select ('foo', {id => {-in => [12, 23]}});
  isa_ok $result, 'Dongry::Database::Executed';
  is $result->row_count, 2;
  is $result->table_name, 'foo';
  my $invoked = 0;
  my $list = $result->all_as_rows;
  isa_list_n_ok $list, 2;
  my $values = $list->sort (sub { $_[0]->{id} <=> $_[1]->{id} })->to_a;
  isa_ok $values->[0], 'Dongry::Table::Row';
  is $values->[0]->{db}, $db;
  is $values->[0]->{table_name}, 'foo';
  eq_or_diff $values->[0]->{data}, {id => 12, v1 => 'abc', v2 => '322'};
  isa_ok $values->[1], 'Dongry::Table::Row';
  is $values->[1]->{db}, $db;
  is $values->[1]->{table_name}, 'foo';
  eq_or_diff $values->[1]->{data}, {id => 23, v1 => undef, v2 => 'xyxa'};
  dies_ok { $result->all };
  dies_ok { $result->all_as_rows };
  dies_ok { $result->first };
  dies_ok { $result->first_as_row };
  dies_ok { $result->each_as_row (sub { $invoked++ }) };
  dies_ok { $result->each (sub { $invoked++ }) };
  is $invoked, 0;
} # _select_multiple_rows_all_as_rows

sub _select_multiple_rows_no_return : Test(2) {
  reset_db_set;
  my $dsn = test_dsn 'test1';
  {
    my $db = Dongry::Database->new
        (sources => {master => {dsn => $dsn, writable => 1},
                     default => {dsn => $dsn}});
    $db->execute ('create table foo (id int, v1 text, v2 text)');
    $db->execute ('insert into foo (id, v1, v2) values (12, "abc", 322)');
    $db->execute ('insert into foo (id, v1, v2) values (23, NULL, "xyxa")');
    
    lives_ok {
      $db->select ('foo', {id => {-in => [12, 23]}});
      undef;
    };
    undef $db;
  }
  ok 1;
} # _select_multiple_rows_no_return

sub _select_no_source : Test(2) {
  my $db = Dongry::Database->new;
  dies_ok {
    my $result = $db->select ('foo', {id => {-in => [12, 23]}});
  };
} # _select_no_source

sub _select_sources : Test(5) {
  reset_db_set;
  my $dsn1 = test_dsn 'dsn1';
  my $dsn2 = test_dsn 'dsn2';
  my $dsn3 = test_dsn 'dsn3';
  my $db1 = Dongry::Database->new
      (sources => {master => {dsn => $dsn1, writable => 1}});
  my $db2 = Dongry::Database->new
      (sources => {master => {dsn => $dsn2, writable => 1}});
  my $db3 = Dongry::Database->new
      (sources => {master => {dsn => $dsn3, writable => 1}});
  $db1->execute ('create table foo (id int)');
  $db2->execute ('create table foo (id int)');
  $db3->execute ('create table foo (id int)');
  $db1->execute ('insert into foo (id) values (1)');
  $db2->execute ('insert into foo (id) values (2)');
  $db3->execute ('insert into foo (id) values (3)');
  
  my $db = Dongry::Database->new
      (sources => {default => {dsn => $dsn1},
                   master => {dsn => $dsn2},
                   heavy => {dsn => $dsn3}});

  my $result1 = $db->select ('foo', {id => {'>=', 0}});
  is $result1->first->{id}, 1;

  my $result2 = $db->select ('foo', {id => {'>=', 0}},
                             source_name => 'default');
  is $result2->first->{id}, 1;

  my $result3 = $db->select ('foo', {id => {'>=', 0}},
                             source_name => 'master');
  is $result3->first->{id}, 2;

  my $result4 = $db->select ('foo', {id => {'>=', 0}},
                             source_name => 'heavy');
  is $result4->first->{id}, 3;
  
  dies_ok {
    my $result5 = $db->select ('foo', {id => {'>=', 0}},
                               source_name => 'notfound');
  };
} # _select_sources

sub _select_must_be_writable_yes : Test(1) {
  reset_db_set;
  my $dsn = test_dsn 'test1';
  my $db = Dongry::Database->new
      (sources => {default => {dsn => $dsn, writable => 1},
                   master => {dsn => $dsn, writable => 1}});
  $db->execute ('create table foo (id int, v1 text, v2 text)');
  $db->execute ('insert into foo (id, v1, v2) values (12, "abc", 322)');
  $db->execute ('insert into foo (id, v1, v2) values (23, NULL, "xyxa")');
  
  my $result = $db->select ('foo', {id => {-in => [12, 23]}},
                            source_name => 'default',
                            must_be_writable => 1);
  is $result->row_count, 2;
} # _select_must_be_writable_yes

sub _select_must_be_writable_yes_2 : Test(1) {
  reset_db_set;
  my $dsn = test_dsn 'test1';
  my $db = Dongry::Database->new
      (sources => {default => {dsn => $dsn, writable => 0},
                   master => {dsn => $dsn, writable => 1}});
  $db->execute ('create table foo (id int, v1 text, v2 text)');
  $db->execute ('insert into foo (id, v1, v2) values (12, "abc", 322)');
  $db->execute ('insert into foo (id, v1, v2) values (23, NULL, "xyxa")');
  
  my $result = $db->select ('foo', {id => {-in => [12, 23]}},
                            must_be_writable => 1);
  is $result->row_count, 2;
} # _select_must_be_writable_yes_2

sub _select_must_be_writable_yes_3 : Test(1) {
  reset_db_set;
  my $dsn = test_dsn 'test1';
  my $db = Dongry::Database->new
      (sources => {default => {dsn => $dsn, writable => 0},
                   master => {dsn => $dsn, writable => 1}});
  $db->execute ('create table foo (id int, v1 text, v2 text)');
  $db->execute ('insert into foo (id, v1, v2) values (12, "abc", 322)');
  $db->execute ('insert into foo (id, v1, v2) values (23, NULL, "xyxa")');
  
  my $result = $db->select ('foo', {id => {-in => [12, 23]}},
                            source => 'master',
                            must_be_writable => 1);
  is $result->row_count, 2;
} # _select_must_be_writable_yes_3

sub _select_must_be_writable_no : Test(1) {
  reset_db_set;
  my $dsn = test_dsn 'test1';
  my $db = Dongry::Database->new
      (sources => {default => {dsn => $dsn, writable => 0},
                   master => {dsn => $dsn, writable => 1}});
  $db->execute ('create table foo (id int, v1 text, v2 text)');
  $db->execute ('insert into foo (id, v1, v2) values (12, "abc", 322)');
  $db->execute ('insert into foo (id, v1, v2) values (23, NULL, "xyxa")');
  
  dies_ok {
    my $result = $db->select ('foo', {id => {-in => [12, 23]}},
                              source_name => 'default',
                              must_be_writable => 1);
  };
} # _select_must_be_writable_no

sub _select_must_be_writable_no_2 : Test(1) {
  reset_db_set;
  my $dsn = test_dsn 'test1';
  my $db = Dongry::Database->new
      (sources => {default => {dsn => $dsn, writable => 0},
                   master => {dsn => $dsn, writable => 1}});
  $db->execute ('create table foo (id int, v1 text, v2 text)');
  $db->execute ('insert into foo (id, v1, v2) values (12, "abc", 322)');
  $db->execute ('insert into foo (id, v1, v2) values (23, NULL, "xyxa")');
  
  dies_ok {
    my $result = $db->select ('foo', {id => {-in => [12, 23]}},
                              source_name => 'default',
                              must_be_writable => 1);
  };
} # _select_must_be_writable_no_2

sub _select_distinct : Test(2) {
  reset_db_set;
  my $dsn = test_dsn 'test1';
  my $db = Dongry::Database->new
      (sources => {default => {dsn => $dsn, writable => 0},
                   master => {dsn => $dsn, writable => 1}});
  $db->execute ('create table foo (id int, v1 text, v2 text)');
  $db->execute ('insert into foo (id, v1, v2) values (12, "abc", 322)');
  $db->execute ('insert into foo (id, v1, v2) values (12, "abc", 322)');
  
  my $result0 = $db->select ('foo', {id => {'>', 0}}, distinct => 0);
  eq_or_diff $result0->all->to_a,
      [{id => 12, v1 => 'abc', v2 => '322'},
       {id => 12, v1 => 'abc', v2 => '322'}];

  my $result = $db->select ('foo', {id => {'>', 0}}, distinct => 1);
  eq_or_diff $result->all->to_a, [{id => 12, v1 => 'abc', v2 => '322'}];
} # _select_distinct

sub _fields_valid : Test(27) {
  my $db = Dongry::Database->new;
  for (
    [undef, '*'],
    ['abc', '`abc`'],
    ['ab `\\c', '`ab ``\\c`'],
    ['abc', '`abc`'],
    ["\x{4010}\x{124}ab", encode 'utf-8', qq{`\x{4010}\x{124}ab`}],
    [['a', 'bcd'], '`a`, `bcd`'],
    [['a', "\x{4010}\x{124}ab"], encode 'utf-8', qq{`a`, `\x{4010}\x{124}ab`}],
    [['a', ['b', ['c']]] => '`a`, `b`, `c`'],
    [\'ab cde' => 'ab cde'],
    [\"ab\x{8000} cde" => encode 'utf-8', "ab\x{8000} cde"],
    [['a', \'count(b) as c'] => '`a`, count(b) as c'],
    [{-count => undef} => 'COUNT(*)'],
    [{-count => 1} => 'COUNT(`1`)'],
    [{-count => 'a'} => 'COUNT(`a`)'],
    [{-count => "\x{5000}"}
         => encode 'utf-8', qq{COUNT(`\x{5000}`)}],
    [{-count => ['a', 'b']} => 'COUNT(`a`, `b`)'],
    [{-count => 'a', as => 'ab c'} => 'COUNT(`a`) AS `ab c`'],
    [{-count => 'a', as => "\x{8000}"}
         => encode 'utf-8', qq{COUNT(`a`) AS `\x{8000}`}],
    [{-count => undef, distinct => 1} => 'COUNT(DISTINCT *)'],
    [{-count => 'a', distinct => 1} => 'COUNT(DISTINCT `a`)'],
    [{-count => "\x{5000}", distinct => 1}
         => encode 'utf-8', qq{COUNT(DISTINCT `\x{5000}`)}],
    [{-count => ['a', 'b'], distinct => 1} => 'COUNT(DISTINCT `a`, `b`)'],
    [{-count => 'a', distinct => 1, as => 'ab c'}
         => 'COUNT(DISTINCT `a`) AS `ab c`'],
    [{-count => 'a', distinct => 1, as => "\x{8000}"}
         => encode 'utf-8', qq{COUNT(DISTINCT `a`) AS `\x{8000}`}],
    [{-min => 'a', distinct => 1, as => "\x{8000}"}
         => encode 'utf-8', qq{MIN(DISTINCT `a`) AS `\x{8000}`}],
    [{-max => 'a', distinct => 1, as => "\x{8000}"}
         => encode 'utf-8', qq{MAX(DISTINCT `a`) AS `\x{8000}`}],
    [{-sum => 'a', distinct => 1, as => "\x{8000}"}
         => encode 'utf-8', qq{SUM(DISTINCT `a`) AS `\x{8000}`}],
  ) {
    eq_or_diff Dongry::Database::_fields $_->[0], $_->[1];
  }
} # _fields_valid

sub _select_fields_none : Test(1) {
  reset_db_set;
  my $dsn = test_dsn 'test1';
  my $db = Dongry::Database->new
      (sources => {default => {dsn => $dsn, writable => 0},
                   master => {dsn => $dsn, writable => 1}});
  $db->execute ('create table foo (id int, v1 text, v2 text)');
  $db->execute ('insert into foo (id, v1, v2) values (12, "abc", 322)');
  $db->execute ('insert into foo (id, v1, v2) values (12, "abc", 322)');
  
  my $result = $db->select ('foo', {id => {'>', 0}}, fields => undef);
  eq_or_diff $result->all->to_a,
      [{id => 12, v1 => 'abc', v2 => '322'},
       {id => 12, v1 => 'abc', v2 => '322'}];
} # _select_fields_none

sub _select_fields_some : Test(1) {
  reset_db_set;
  my $dsn = test_dsn 'test1';
  my $db = Dongry::Database->new
      (sources => {default => {dsn => $dsn, writable => 0},
                   master => {dsn => $dsn, writable => 1}});
  $db->execute ('create table foo (id int, v1 text, v2 text)');
  $db->execute ('insert into foo (id, v1, v2) values (12, "abc", 322)');
  $db->execute ('insert into foo (id, v1, v2) values (12, "abc", 322)');
  
  my $result = $db->select ('foo', {id => {'>', 0}}, fields => ['id', 'v1']);
  eq_or_diff $result->all->to_a,
      [{id => 12, v1 => 'abc'},
       {id => 12, v1 => 'abc'}];
} # _select_fields_some

sub _select_fields_utf8_flagged : Test(1) {
  reset_db_set;
  my $dsn = test_dsn 'test1';
  my $db = Dongry::Database->new
      (sources => {default => {dsn => $dsn, writable => 0},
                   master => {dsn => $dsn, writable => 1}});
  $db->execute
      (encode 'utf-8', "create table foo (id int, v1 text, `\x{6000}` text)");
  $db->execute
      (encode 'utf-8', "insert into foo (id, `\x{6000}`) values (12, 'abc')");

  my $result = $db->select ('foo', {id => {'>', 0}}, fields => ["\x{6000}"]);
  eq_or_diff $result->all->to_a,
      [{"\x{6000}" => 'abc'}];
} # _select_fields_utf8_flagged

sub _select_fields_utf8_unflagged : Test(1) {
  reset_db_set;
  my $dsn = test_dsn 'test1';
  my $db = Dongry::Database->new
      (sources => {default => {dsn => $dsn, writable => 0},
                   master => {dsn => $dsn, writable => 1}});
  $db->execute
      (encode 'utf-8', "create table foo (id int, v1 text, `\x{6000}` text)");
  $db->execute
      (encode 'utf-8', "insert into foo (id, `\x{6000}`) values (12, 'abc')");

  dies_ok {
    my $result = $db->select ('foo', {id => {'>', 0}},
                              fields => [encode 'utf-8', "\x{6000}"]);
  };
} # _select_fields_utf8_unflagged

sub _select_fields_function : Test(1) {
  reset_db_set;
  my $dsn = test_dsn 'test1';
  my $db = Dongry::Database->new
      (sources => {default => {dsn => $dsn, writable => 0},
                   master => {dsn => $dsn, writable => 1}});
  $db->execute ('create table foo (id int, v1 text, v2 text)');
  $db->execute ('insert into foo (id, v1, v2) values (12, "abc", 322)');
  $db->execute ('insert into foo (id, v1, v2) values (12, "abc", 322)');
  
  my $result = $db->select ('foo', {id => {'>', 0}},
                            fields => ['id', {-count => undef}]);
  eq_or_diff $result->all->to_a,
      [{id => 12, 'COUNT(*)' => '2'}];
} # _select_fields_function

sub _select_fields_function_named : Test(1) {
  reset_db_set;
  my $dsn = test_dsn 'test1';
  my $db = Dongry::Database->new
      (sources => {default => {dsn => $dsn, writable => 0},
                   master => {dsn => $dsn, writable => 1}});
  $db->execute ('create table foo (id int, v1 text, v2 text)');
  $db->execute ('insert into foo (id, v1, v2) values (12, "abc", 322)');
  $db->execute ('insert into foo (id, v1, v2) values (12, "abc", 322)');
  
  my $result = $db->select ('foo', {id => {'>', 0}},
                            fields => ['id', {-count => undef, as => 'v1'}]);
  eq_or_diff $result->all->to_a,
      [{id => 12, 'v1' => '2'}];
} # _select_fields_function_named

sub _select_fields_function_distinct : Test(1) {
  reset_db_set;
  my $dsn = test_dsn 'test1';
  my $db = Dongry::Database->new
      (sources => {default => {dsn => $dsn, writable => 0},
                   master => {dsn => $dsn, writable => 1}});
  $db->execute ('create table foo (id int, v1 text, v2 text)');
  $db->execute ('insert into foo (id, v1, v2) values (12, "abc", 322)');
  $db->execute ('insert into foo (id, v1, v2) values (12, "abc", 322)');
  
  my $result = $db->select
      ('foo', {id => {'>', 0}},
       fields => ['id', {-count => 'id', distinct => 1, as => 'hoge'}]);
  eq_or_diff $result->all->to_a,
      [{id => 12, 'hoge' => '1'}];
} # _select_fields_function_distinct

sub _select_fields_bare : Test(1) {
  reset_db_set;
  my $dsn = test_dsn 'test1';
  my $db = Dongry::Database->new
      (sources => {default => {dsn => $dsn, writable => 0},
                   master => {dsn => $dsn, writable => 1}});
  $db->execute ('create table foo (id int, v1 text, v2 text)');
  $db->execute ('insert into foo (id, v1, v2) values (12, "abc", 322)');
  $db->execute ('insert into foo (id, v1, v2) values (10, "abc", 322)');
  
  my $result = $db->select
      ('foo', {id => {'>', 0}},
       fields => \'min(id) as min, max(id) as max, min(id) + max(id) as mm');
  eq_or_diff $result->all->to_a,
      [{min => 10, max => 12, mm => 22}];
} # _select_fields_bare

# XXX field

# XXX field SQL error

# XXX table

# XXX SQLA

# XXX SQLP

# XXX where SQL error

# XXX utf8, bytes

# XXX group

# XXX group SQL error

# XXX order

# XXX order SQL error

# XXX offset limit

# XXX lock

# XXX other options

__PACKAGE__->runtests;

1;

=head1 LICENSE

Copyright 2011 Wakaba <w@suika.fam.cx>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
