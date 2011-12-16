package test::Dongry::Table::insert;
use strict;
use warnings;
use Path::Class;
use lib file (__FILE__)->dir->parent->subdir ('lib')->stringify;
use Test::Dongry;
use base qw(Test::Class);
use Dongry::Database;
use Dongry::Type::DateTime;
use Encode;

sub new_db (%) {
  my %args = @_;
  reset_db_set;
  my $dsn = test_dsn 'test1';
  my $db = Dongry::Database->new
      (sources => {master => {dsn => $dsn, writable => 1},
                   default => {dsn => $dsn}},
       schema => $args{schema});
  for my $name (keys %{$args{schema} || {}}) {
    if ($args{schema}->{$name}->{_create}) {
      $db->execute ($args{schema}->{$name}->{_create});
    }
  }
  return $db;
} # new_db

sub _insert_fully_serialized : Test(1) {
  my $schema = {
    table1 => {
      type => {
        col1 => 'timestamp_as_DateTime',
        col2 => 'as_ref',
      },
      _create => 'create table table1 (col1 timestamp, col2 blob)',
    },
  };
  my $db = new_db schema => $schema;

  my $table = $db->table ('table1');
  $table->insert
      ([{col1 => DateTime->new (year => 2001, month => 12, day => 3,
                                time_zone => 'Asia/Tokyo'),
         col2 => \"abc def"},
        {col1 => DateTime->new (year => 2001, month => 3, day => 12,
                                time_zone => 'UTC'),
         col2 => \undef}]);
  
  eq_or_diff $db->execute
     ('select * from table1 order by col1 desc')->all->to_a,
     [{col1 => '2001-12-02 15:00:00', col2 => 'abc def'},
      {col1 => '2001-03-12 00:00:00', col2 => undef}];
} # _insert_fully_serialized

sub _insert_not_serialized : Test(1) {
  my $schema = {
    table1 => {
      type => {
        col1 => 'timestamp_as_DateTime',
        col2 => 'as_ref',
      },
      _create => 'create table table1 (col1 timestamp, col2 blob,
                                       col3 blob, col4 int)',
    },
  };
  my $db = new_db schema => $schema;

  my $table = $db->table ('table1');
  $table->insert
      ([{col1 => DateTime->new (year => 2001, month => 12, day => 3,
                                time_zone => 'Asia/Tokyo'),
         col2 => \"abc def",
         col3 => "ab x\x{500}",
         col4 => 124.1},
        {col1 => DateTime->new (year => 2001, month => 3, day => 12,
                                time_zone => 'UTC'),
         col2 => \undef,
         col3 => "ab"}]);
  
  eq_or_diff $db->execute
     ('select * from table1 order by col1 desc')->all->to_a,
     [{col1 => '2001-12-02 15:00:00', col2 => 'abc def',
       col3 => (encode 'utf-8', "ab x\x{500}"),
       col4 => 124},
      {col1 => '2001-03-12 00:00:00', col2 => undef,
       col3 => 'ab', col4 => undef}];
} # _insert_not_serialized

sub _insert_not_serialized_with_ref : Test(2) {
  my $schema = {
    table1 => {
      type => {
        col1 => 'timestamp_as_DateTime',
        col2 => 'as_ref',
      },
      _create => 'create table table1 (col1 timestamp, col2 blob,
                                       col3 blob, col4 int)',
    },
  };
  my $db = new_db schema => $schema;

  my $table = $db->table ('table1');
  dies_ok {
    $table->insert
        ([{col1 => DateTime->new (year => 2001, month => 12, day => 3,
                                  time_zone => 'Asia/Tokyo'),
           col2 => \"abc def",
           col3 => ["ab x\x{500}"],
           col4 => 124.1},
          {col1 => DateTime->new (year => 2001, month => 3, day => 12,
                                  time_zone => 'UTC'),
           col2 => \undef,
           col3 => "ab"}]);
  };

  eq_or_diff $db->execute
     ('select * from table1 order by col1 desc')->all->to_a, [];
} # _insert_not_serialized_with_ref

sub _insert_unknown_type : Test(2) {
  my $schema = {
    table1 => {
      type => {
        col1 => 'timestamp_as_DateTime',
        col2 => 'as_unknown',
      },
      _create => 'create table table1 (col1 timestamp, col2 blob,
                                       col3 blob, col4 int)',
    },
  };
  my $db = new_db schema => $schema;

  my $table = $db->table ('table1');
  dies_ok {
    $table->insert
        ([{col1 => DateTime->new (year => 2001, month => 12, day => 3,
                                  time_zone => 'Asia/Tokyo'),
           col2 => \"abc def"},
          {col1 => DateTime->new (year => 2001, month => 3, day => 12,
                                  time_zone => 'UTC'),
           col2 => \undef}]);
  };

  eq_or_diff $db->execute
     ('select * from table1 order by col1 desc')->all->to_a, [];
} # _insert_unknown_type

sub _insert_no_table_schema : Test(1) {
  my $schema = {
    table2 => {
      type => {
        col1 => 'timestamp_as_DateTime',
        col2 => 'as_ref',
      },
      _create => 'create table table1 (col1 timestamp, col2 blob,
                                       col3 blob, col4 int)',
    },
  };
  my $db = new_db schema => $schema;

  my $table = $db->table ('table1');
  $table->insert
      ([{col1 => '2011-01-02 00:00:01',
         col2 => "abc def",
         col3 => "ab x\x{500}",
         col4 => 124.1},
        {col1 => '2001-03-12 00:00:00',
         col2 => undef,
         col3 => "ab"}]);
  
  eq_or_diff $db->execute
     ('select * from table1 order by col1 desc')->all->to_a,
     [{col1 => '2011-01-02 00:00:01', col2 => 'abc def',
       col3 => (encode 'utf-8', "ab x\x{500}"),
       col4 => 124},
      {col1 => '2001-03-12 00:00:00', col2 => undef,
       col3 => 'ab', col4 => undef}];
} # _insert_no_table_schema

sub _insert_no_table_schema_with_ref : Test(2) {
  my $schema = {
    table2 => {
      type => {
        col1 => 'timestamp_as_DateTime',
        col2 => 'as_ref',
      },
      _create => 'create table table1 (col1 timestamp, col2 blob,
                                       col3 blob, col4 int)',
    },
  };
  my $db = new_db schema => $schema;

  my $table = $db->table ('table1');
  dies_ok {
    $table->insert
        ([{col1 => '2011-01-02 00:00:01',
           col2 => qr/abc def/,
           col3 => "ab x\x{500}",
           col4 => 124.1},
          {col1 => '2001-03-12 00:00:00',
           col2 => undef,
           col3 => "ab"}]);
  };
  
  eq_or_diff $db->execute
     ('select * from table1 order by col1 desc')->all->to_a, [];
} # _insert_no_table_schema_with_ref

sub _insert_no_schema : Test(1) {
  my $db = new_db schema => undef;
  $db->execute ('create table table1 (col1 timestamp, col2 blob,
                                      col3 blob, col4 int)');

  my $table = $db->table ('table1');
  $table->insert
      ([{col1 => '2011-01-02 00:00:01',
         col2 => "abc def",
         col3 => "ab x\x{500}",
         col4 => 124.1},
        {col1 => '2001-03-12 00:00:00',
         col2 => undef,
         col3 => "ab"}]);
  
  eq_or_diff $db->execute
     ('select * from table1 order by col1 desc')->all->to_a,
     [{col1 => '2011-01-02 00:00:01', col2 => 'abc def',
       col3 => (encode 'utf-8', "ab x\x{500}"),
       col4 => 124},
      {col1 => '2001-03-12 00:00:00', col2 => undef,
       col3 => 'ab', col4 => undef}];
} # _insert_no_schema

sub _insert_no_schema_with_ref : Test(2) {
  my $db = new_db schema => undef;
  $db->execute ('create table table1 (col1 timestamp, col2 blob,
                                      col3 blob, col4 int)');

  my $table = $db->table ('table1');
  dies_ok {
    $table->insert
        ([{col1 => '2011-01-02 00:00:01',
           col2 => {abc => 'def'},
           col3 => "ab x\x{500}",
           col4 => 124.1},
          {col1 => '2001-03-12 00:00:00',
           col2 => undef,
           col3 => "ab"}]);
  };
  
  eq_or_diff $db->execute
     ('select * from table1 order by col1 desc')->all->to_a, [];
} # _insert_no_schema_with_ref

sub _insert_with_default_fully_serialized : Test(1) {
  my $schema = {
    table1 => {
      type => {
        col1 => 'timestamp_as_DateTime',
        col2 => 'as_ref',
      },
      default => {
        col1 => DateTime->new (year => 2005, month => 12, day => 4),
        col2 => \"ab cd",
      },
      _create => 'create table table1 (col1 timestamp, col2 blob)',
    },
  };
  my $db = new_db schema => $schema;

  my $table = $db->table ('table1');
  $table->insert
      ([{col1 => DateTime->new (year => 2001, month => 12, day => 3,
                                time_zone => 'Asia/Tokyo'),
         col2 => undef},
        {col2 => \undef}]);
  
  eq_or_diff $db->execute
     ('select * from table1 order by col1 asc')->all->to_a,
     [{col1 => '2001-12-02 15:00:00', col2 => 'ab cd'},
      {col1 => '2005-12-04 00:00:00', col2 => undef}];
} # _insert_with_default_fully_serialized

sub _insert_with_default_code_fully_serialized : Test(1) {
  my $schema = {
    table1 => {
      type => {
        col1 => 'timestamp_as_DateTime',
        col2 => 'as_ref',
      },
      default => {
        col1 => sub { DateTime->new (year => 2005, month => 12, day => 4) },
        col2 => sub { \"ab cd" },
      },
      _create => 'create table table1 (col1 timestamp, col2 blob)',
    },
  };
  my $db = new_db schema => $schema;

  my $table = $db->table ('table1');
  $table->insert
      ([{col1 => DateTime->new (year => 2001, month => 12, day => 3,
                                time_zone => 'Asia/Tokyo'),
         col2 => undef},
        {col2 => \undef}]);
  
  eq_or_diff $db->execute
     ('select * from table1 order by col1 asc')->all->to_a,
     [{col1 => '2001-12-02 15:00:00', col2 => 'ab cd'},
      {col1 => '2005-12-04 00:00:00', col2 => undef}];
} # _insert_with_default_code_fully_serialized

sub _insert_empty : Test(2) {
  my $schema = {
    table1 => {
      type => {
        col1 => 'timestamp_as_DateTime',
        col2 => 'as_ref',
      },
      _create => 'create table table1 (col1 timestamp, col2 blob)',
    },
  };
  my $db = new_db schema => $schema;

  my $table = $db->table ('table1');
  dies_ok {
    $table->insert ([]);
  };

  eq_or_diff $db->execute
     ('select * from table1 order by col1 asc')->all->to_a, [];
} # _insert_empty

sub _insert_empty_return : Test(2) {
  my $schema = {
    table1 => {
      type => {
        col1 => 'timestamp_as_DateTime',
        col2 => 'as_ref',
      },
      _create => 'create table table1 (col1 timestamp, col2 blob)',
    },
  };
  my $db = new_db schema => $schema;

  my $table = $db->table ('table1');
  dies_ok {
    my $return = $table->insert ([]);
  };

  eq_or_diff $db->execute
     ('select * from table1 order by col1 asc')->all->to_a, [];
} # _insert_empty_return

sub _insert_return_all : Test(5) {
  my $date0 = DateTime->new (year => 2005, month => 12, day => 4);
  my $schema = {
    table1 => {
      type => {
        col1 => 'timestamp_as_DateTime',
        col2 => 'as_ref',
      },
      default => {
        col1 => sub { $date0 },
        col2 => sub { \"ab cd" },
      },
      _create => 'create table table1 (col1 timestamp, col2 blob, col3 blob)',
    },
  };
  my $db = new_db schema => $schema;

  my $table = $db->table ('table1');
  my $date1 = DateTime->new (year => 2001, month => 12, day => 3,
                             time_zone => 'Asia/Tokyo');
  my $result = $table->insert
      ([{col1 => $date1,
         col2 => undef,
         col3 => 'abc'},
        {col2 => \undef}]);
  isa_ok $result, 'Dongry::Database::Executed';
  is $result->row_count, 2;
  my $rows = $result->all;
  isa_list_n_ok $rows, 2;

  eq_or_diff $rows->[0],
      {col1 => '2001-12-02 15:00:00', col2 => 'ab cd', col3 => 'abc'};
  eq_or_diff $rows->[1],
      {col1 => '2005-12-04 00:00:00', col2 => undef};
} # _insert_return_all

sub _insert_return_all_as_rows : Test(11) {
  my $date0 = DateTime->new (year => 2005, month => 12, day => 4);
  my $schema = {
    table1 => {
      type => {
        col1 => 'timestamp_as_DateTime',
        col2 => 'as_ref',
      },
      default => {
        col1 => sub { $date0 },
        col2 => sub { \"ab cd" },
      },
      _create => 'create table table1 (col1 timestamp, col2 blob, col3 blob)',
    },
  };
  my $db = new_db schema => $schema;

  my $table = $db->table ('table1');
  my $date1 = DateTime->new (year => 2001, month => 12, day => 3,
                             time_zone => 'Asia/Tokyo');
  my $result = $table->insert
      ([{col1 => $date1,
         col2 => undef,
         col3 => 'abc'},
        {col2 => \undef}]);
  isa_ok $result, 'Dongry::Database::Executed';
  is $result->row_count, 2;
  my $rows = $result->all_as_rows;
  isa_list_n_ok $rows, 2;

  isa_ok $rows->[0], 'Dongry::Table::Row';
  is $rows->[0]->table_name, 'table1';
  eq_or_diff $rows->[0]->{data},
      {col1 => '2001-12-02 15:00:00', col2 => 'ab cd', col3 => 'abc'};
  eq_or_diff $rows->[0]->{parsed_data},
      {col1 => $date1, col2 => \'ab cd', col3 => 'abc'};
  
  isa_ok $rows->[1], 'Dongry::Table::Row';
  is $rows->[1]->table_name, 'table1';
  eq_or_diff $rows->[1]->{data},
      {col1 => '2005-12-04 00:00:00', col2 => undef};
  eq_or_diff $rows->[1]->{parsed_data}, {col1 => $date0, col2 => \undef};
} # _insert_return_all_as_rows

sub _insert_return_each : Test(5) {
  my $date0 = DateTime->new (year => 2005, month => 12, day => 4);
  my $schema = {
    table1 => {
      type => {
        col1 => 'timestamp_as_DateTime',
        col2 => 'as_ref',
      },
      default => {
        col1 => sub { $date0 },
        col2 => sub { \"ab cd" },
      },
      _create => 'create table table1 (col1 timestamp, col2 blob, col3 blob)',
    },
  };
  my $db = new_db schema => $schema;

  my $table = $db->table ('table1');
  my $date1 = DateTime->new (year => 2001, month => 12, day => 3,
                             time_zone => 'Asia/Tokyo');
  my $result = $table->insert
      ([{col1 => $date1,
         col2 => undef,
         col3 => 'abc'},
        {col2 => \undef}]);
  isa_ok $result, 'Dongry::Database::Executed';
  is $result->row_count, 2;
  my $rows = List::Rubyish->new;
  $result->each (sub { $rows->push ($_) });
  isa_list_n_ok $rows, 2;

  eq_or_diff $rows->[0],
      {col1 => '2001-12-02 15:00:00', col2 => 'ab cd', col3 => 'abc'};
  eq_or_diff $rows->[1],
      {col1 => '2005-12-04 00:00:00', col2 => undef};
} # _insert_return_each

sub _insert_return_each_as_row : Test(11) {
  my $date0 = DateTime->new (year => 2005, month => 12, day => 4);
  my $schema = {
    table1 => {
      type => {
        col1 => 'timestamp_as_DateTime',
        col2 => 'as_ref',
      },
      default => {
        col1 => sub { $date0 },
        col2 => sub { \"ab cd" },
      },
      _create => 'create table table1 (col1 timestamp, col2 blob, col3 blob)',
    },
  };
  my $db = new_db schema => $schema;

  my $table = $db->table ('table1');
  my $date1 = DateTime->new (year => 2001, month => 12, day => 3,
                             time_zone => 'Asia/Tokyo');
  my $result = $table->insert
      ([{col1 => $date1,
         col2 => undef,
         col3 => 'abc'},
        {col2 => \undef}]);
  isa_ok $result, 'Dongry::Database::Executed';
  is $result->row_count, 2;
  my $rows = List::Rubyish->new;
  $result->each_as_row (sub { $rows->push ($_) });
  isa_list_n_ok $rows, 2;

  isa_ok $rows->[0], 'Dongry::Table::Row';
  is $rows->[0]->table_name, 'table1';
  eq_or_diff $rows->[0]->{data},
      {col1 => '2001-12-02 15:00:00', col2 => 'ab cd', col3 => 'abc'};
  eq_or_diff $rows->[0]->{parsed_data},
      {col1 => $date1, col2 => \'ab cd', col3 => 'abc'};
  
  isa_ok $rows->[1], 'Dongry::Table::Row';
  is $rows->[1]->table_name, 'table1';
  eq_or_diff $rows->[1]->{data},
      {col1 => '2005-12-04 00:00:00', col2 => undef};
  eq_or_diff $rows->[1]->{parsed_data}, {col1 => $date0, col2 => \undef};
} # _insert_return_each_as_row

sub _insert_return_first : Test(3) {
  my $date0 = DateTime->new (year => 2005, month => 12, day => 4);
  my $schema = {
    table1 => {
      type => {
        col1 => 'timestamp_as_DateTime',
        col2 => 'as_ref',
      },
      default => {
        col1 => sub { $date0 },
        col2 => sub { \"ab cd" },
      },
      _create => 'create table table1 (col1 timestamp, col2 blob, col3 blob)',
    },
  };
  my $db = new_db schema => $schema;

  my $table = $db->table ('table1');
  my $date1 = DateTime->new (year => 2001, month => 12, day => 3,
                             time_zone => 'Asia/Tokyo');
  my $result = $table->insert
      ([{col1 => $date1,
         col2 => undef,
         col3 => 'abc'},
        {col2 => \undef}]);
  isa_ok $result, 'Dongry::Database::Executed';
  is $result->row_count, 2;
  my $row = $result->first;
  eq_or_diff $row,
      {col1 => '2001-12-02 15:00:00', col2 => 'ab cd', col3 => 'abc'};
} # _insert_return_first

sub _insert_return_first_as_row : Test(6) {
  my $date0 = DateTime->new (year => 2005, month => 12, day => 4);
  my $schema = {
    table1 => {
      type => {
        col1 => 'timestamp_as_DateTime',
        col2 => 'as_ref',
      },
      default => {
        col1 => sub { $date0 },
        col2 => sub { \"ab cd" },
      },
      _create => 'create table table1 (col1 timestamp, col2 blob, col3 blob)',
    },
  };
  my $db = new_db schema => $schema;

  my $table = $db->table ('table1');
  my $date1 = DateTime->new (year => 2001, month => 12, day => 3,
                             time_zone => 'Asia/Tokyo');
  my $result = $table->insert
      ([{col1 => $date1,
         col2 => undef,
         col3 => 'abc'},
        {col2 => \undef}]);
  isa_ok $result, 'Dongry::Database::Executed';
  is $result->row_count, 2;
  my $row = $result->first_as_row;

  isa_ok $row, 'Dongry::Table::Row';
  is $row->table_name, 'table1';
  eq_or_diff $row->{data},
      {col1 => '2001-12-02 15:00:00', col2 => 'ab cd', col3 => 'abc'};
  eq_or_diff $row->{parsed_data},
      {col1 => $date1, col2 => \'ab cd', col3 => 'abc'};
} # _insert_return_first_as_row

__PACKAGE__->runtests;

1;

=head1 LICENSE

Copyright 2011 Wakaba <w@suika.fam.cx>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
