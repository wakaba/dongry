package test::Dongry::Database::schema;
use strict;
use warnings;
use Path::Class;
use lib file (__FILE__)->dir->parent->subdir ('lib')->stringify;
use Test::Dongry;
use base qw(Test::Class);
use Dongry::Database;
use Encode;

sub _schema_default : Test(1) {
  my $db = Dongry::Database->new;
  ng $db->schema;
} # _schema_default

sub _schema_non_null : Test(3) {
  my $db = Dongry::Database->new
      (schema => {hoge => {foo => 122}});
  eq_or_diff $db->schema, {hoge => {foo => 122}};
  
  $db->schema ({foo => 123, bar => 42});
  eq_or_diff $db->schema, {foo => 123, bar => 42};

  $db->schema (undef);
  eq_or_diff $db->schema, undef;
} # _schema_non_null

sub _table_no_name : Test(1) {
  my $db = Dongry::Database->new;
  dies_here_ok {
    my $table = $db->table;
  };
} # _table_no_name

sub _table_with_name : Test(3) {
  my $db = Dongry::Database->new;
  my $table = $db->table ("hoge`&a\x{1001}");
  isa_ok $table, 'Dongry::Table';
  is $table->name, "hoge`&a\x{1001}";
  is $table->{db}, $db;
} # _table_with_name

sub _query_default : Test(5) {
  my $db = Dongry::Database->new;
  my $q = $db->query
      (table_name => 'hoge', where => {1 => 2}, order => [id => -1]);
  isa_ok $q, 'Dongry::Query';
  is $q->table_name, 'hoge';
  eq_or_diff $q->where, {1 => 2};
  eq_or_diff $q->order, [id => -1];
  is $q->group, undef;
} # _query_default

sub _query_class : Test(3) {
  my $db = Dongry::Database->new;
  my $q = $db->query
      (query_class => 'Test::Dongry::Query1', where => {1 => 2});
  isa_ok $q, 'Test::Dongry::Query1';
  is $q->table_name, 'table1';
  eq_or_diff $q->where, {1 => 2};
} # _query_class

__PACKAGE__->runtests;

1;
