package Dongry::Table;
use strict;
use warnings;
our $VERSION = '3.0';
use Carp;

push our @CARP_NOT, qw(Dongry::Database);

# ------------ Tables ------------

sub new ($;%) {
  my $class = shift;
  return bless {@_}, $class;
} # new

# ------ Property accessors ------

sub table_name ($) {
  return $_[0]->{table_name};
} # table_name

sub table_schema ($) {
  my $schema = $_[0]->{db}->schema or return undef;
  my $tn = $_[0]->{db}->table_name_normalizer->($_[0]->{table_name});
  return $schema->{$tn}; # or undef
} # table_schema

# ------ Insertion ------

sub _serialize_values ($$) {
  my ($self, $values) = @_;
  my $schema = $self->table_schema;
  my $s_values = {};
  for my $name (keys %$values) {
    if (defined $values->{$name} and
        ref $values->{$name} eq 'Dongry::SQL::BareFragment') {
      $s_values->{$name} = $values->{$name};
      next;
    }

    my $type = $schema->{type}->{$name};
    if ($type) {
      my $handler = $Dongry::Types->{$type}
          or croak "Type handler for |$type| is not defined";
      $s_values->{$name} = $handler->{serialize}->($values->{$name});
    } else {
      if (defined $values->{$name} and
          ref $values->{$name}) {
        croak "Type for |$name| is not defined but a reference is specified";
      } else {
        $s_values->{$name} = $values->{$name};
      }
    }
  }
  return $s_values;
} # _serialize_values

sub insert ($$;%) {
  my ($self, $data, %args) = @_;

  my $schema = $self->table_schema || {};
  my $s_data = [];
  for my $values (@$data) {
    for (keys %{$schema->{default} or {}}) {
      next if defined $values->{$_};
      my $default = $schema->{default}->{$_};
      if (defined $default and ref $default eq 'CODE') {
        $values->{$_} = $default->();
      } else {
        $values->{$_} = $default;
      }
    }

    my $s_values = $self->_serialize_values ($values);
    push @$s_data, $s_values;
  }

  if ($args{duplicate} and ref $args{duplicate} eq 'HASH') {
    $args{duplicate} = $self->_serialize_values ($args{duplicate});
  }

  my $orig_cb = $args{cb} || sub {};
  my $cb = sub {
    $_[1]->{parsed_data} = $data
        if not $_[1]->is_error and not $_[1]->can ('then');
    goto &$orig_cb;
  }; # $cb

  return $self->{db}->insert
      ($self->table_name, $s_data, %args, cb => $cb);
} # insert

sub create ($$;%) {
  my ($self, $values, %args) = @_;
  croak "Option |cb| is not supported" if $args{cb};
  my $return = $self->insert ([$values], %args);
  if ($return->can ('then')) {
    return $return->then (sub {
      return undef unless $_[0]->row_count;
      my $row = $_[0]->first_as_row;
      $row->{flags} = $args{flags} if $args{flags};
      return $row;
    });
  } else {
    return undef unless $return->row_count;
    my $row = $return->first_as_row;
    $row->{flags} = $args{flags} if $args{flags};
    return $row;
  }
} # create

# ------ Retrieval ------

sub find ($$;%) {
  my ($self, $values, %args) = @_;
  my $schema = $self->table_schema
      or croak sprintf "No schema for table |%s|", $self->table_name;

  my $return;
  my $cb = $args{cb};
  if ($cb) {
    my $orig_cb = $cb;
    $cb = sub {
      $return = $_[1]->is_success ? $_[1]->first_as_row : undef;
      local $_ = $return;
      $orig_cb->(@_);
    };
  }
  
  my $result = $self->{db}
      ->select ($self->table_name, $values,
                fields => $args{fields},
                and_where => $args{and_where},
                group => $args{group},
                order => $args{order},
                offset => $args{offset},
                limit => 1,
                lock => $args{lock},
                source_name => $args{source_name},
                _table_schema => $schema,
                cb => $cb);
  return $result->can ('then') ? $result->then (sub { $_[0]->first_as_row }) : ($cb ? $return : $result->first_as_row);
} # find

sub find_all ($$;%) {
  my ($self, $values, %args) = @_;
  my $schema = $self->table_schema or
      croak sprintf "No schema for table |%s|", $self->table_name;

  my $return;
  my $cb = $args{cb};
  if ($cb) {
    my $orig_cb = $cb;
    $cb = sub {
      $return = $_[1]->is_success ? $_[1]->all_as_rows : undef;
      local $_ = $return;
      $orig_cb->(@_);
    };
  }

  my $result = $self->{db}
      ->select ($self->table_name, $values,
                distinct => $args{distinct},
                fields => $args{fields},
                and_where => $args{and_where},
                group => $args{group},
                order => $args{order},
                offset => $args{offset},
                limit => $args{limit},
                lock => $args{lock},
                source_name => $args{source_name},
                _table_schema => $schema,
                cb => $cb);
  return $result->can ('then') ? $result->then (sub { $_[0]->all_as_rows }) : ($cb ? $return : $result->all_as_rows);
} # find_all

our $MaxFillItems ||= 100;

sub fill_related_rows ($$$$;%) {
  my ($self, $list, $method_column_map => $object_method_name, %args) = @_;

  croak "Methods are not specified" unless keys %$method_column_map;
  return unless @$list;

  if (@$list > $MaxFillItems) {
    for my $i (0..int($#$list / $MaxFillItems)) {
      my $from = ($i * $MaxFillItems);
      my $to = $from + $MaxFillItems - 1;
      $to = $#$list if $to > $#$list;
      if ($from <= $to) {
        $self->fill_related_rows
            ([@$list[$from..$to]],
             $method_column_map => $object_method_name, %args);
      }
    }
    return;
  }
  
  my @methods = keys %$method_column_map;
  my @cols = map { $method_column_map->{$_} } @methods;
  my $method_name = shift @methods;
  my $col = shift @cols;
  
  my $where = {};
  for my $method_name (keys %$method_column_map) {
    $where->{$method_column_map->{$method_name}}
        = {-in => [keys %{{map { ($_->$method_name => 1) } @$list}}]};
  }

  my $map = {};
  my $each_cb = $args{multiple} ? sub {
    my $hash = $map;
    for my $col (@cols) {
      $hash = $hash->{$_->get_bare ($col)} ||= {};
    }
    ($hash->{$_->get_bare ($col)} ||= $self->{db}->_list)->push ($_);
  } : sub {
    my $hash = $map;
    for my $col (@cols) {
      $hash = $hash->{$_->get_bare ($col)} ||= {};
    }
    if ($hash->{$_->get_bare ($col)}) {
      carp "More than one rows found for an object";
    } else {
      $hash->{$_->get_bare ($col)} = $_;
    }
  };

  $self->{db}->select
      ($self->table_name,
       $where,
       fields => $args{fields},
       source_name => $args{source_name},
       lock => $args{lock}, 
       each_as_row_cb => $each_cb,
       cb => sub {
    my $db = $_[0];
    if ($_[1]->is_error) {
      if ($args{cb}) {
        $args{cb}->($db, $_[1]);
      }
      return;
    }

    my $default = $args{multiple} ? $db->_list : undef;
    for my $obj (@$list) {
      my $hash = $map;
      for my $method_name (@methods) {
        $hash = $hash->{$obj->$method_name} ||= {};
      }
      $obj->$object_method_name ($hash->{$obj->$method_name} || $default);
    }

    goto &{$args{cb}} if $args{cb};
  });
} # fill_related_rows

# ------ Modifications ------

sub update ($$;%) {
  my ($self, $values, %args) = @_;

  my $schema = $self->table_schema || {};
  my $s_values = $self->_serialize_values ($values);

  return $self->{db}->update
      ($self->table_name, $s_values,
       %args,
       _table_schema => $schema);
} # update

sub delete ($$;%) {
  my ($self, $where, %args) = @_;
  my $schema = $self->table_schema || {};
  return $self->{db}->delete
      ($self->table_name, $where,
       %args,
       _table_schema => $schema);
} # delete

# ------ Development -------

sub debug_info ($) {
  my $self = shift;
  return sprintf '{Table: %s}', $self->table_name;
} # debug_info

sub DESTROY {
  if ($Dongry::LeakTest) {
    warn "Possible memory leak by object " . ref $_[0];
  }
} # DESTROY

# ------------ Table rows ------------

package Dongry::Table::Row;
our $VERSION = '1.0';
use Carp;

our $CARP_NOT = qw(Dongry::Table);

# ------ Property accessors ------

sub table_name ($) {
  return $_[0]->{table_name};
} # table_name

sub table_schema ($) {
  my $schema = $_[0]->{db}->schema or return undef;
  my $tn = $_[0]->{db}->table_name_normalizer->($_[0]->{table_name});
  return $schema->{$tn}; # or undef
} # table_schema

sub flags ($) {
  return $_[0]->{flags} ||= {};
} # flags

# ------ Value accessors ------

sub get ($$) {
  my ($self, $name) = @_;
  croak "No data for column |$name|"
      if not exists $self->{data}->{$name} or
         ref $self->{data}->{$name} eq 'Dongry::SQL::BareFragment';
  return $self->{parsed_data}->{$name} if exists $self->{parsed_data}->{$name};

  my $schema = $self->table_schema || do {
    carp "No schema for table |$self->{table_name}|";
    +{};
  };
  my $type = $schema->{type}->{$name};
  if ($type) {
    my $handler = $Dongry::Types->{$type}
        or croak "Type handler for |$type| is not defined";
    return $self->{parsed_data}->{$name}
        = $handler->{parse}->($self->{data}->{$name});
  } else {
    return $self->{parsed_data}->{$name}
        = $self->{data}->{$name};
  }
} # get

sub get_bare ($$) {
  croak "No data for column |$_[1]|"
      if not exists $_[0]->{data}->{$_[1]} or
         ref $_[0]->{data}->{$_[1]} eq 'Dongry::SQL::BareFragment';
  return $_[0]->{data}->{$_[1]};
} # get_bare

sub values_as_hashref {
    return $_[0]->{data};
}

sub primary_key_bare_values ($) {
  my $self = shift;
  my $schema = $self->table_schema || {};
  my $pk = $schema->{primary_keys};
  croak "No primary key" if not $pk or not @$pk;
  my $data = $self->{data};
  return {map {
    croak "Primary key |$_| has no value"
        if not defined $data->{$_} or
           ref $data->{$_} eq 'Dongry::SQL::BareFragment';
    ($_ => $data->{$_});
  } @$pk};
} # primary_key_bare_values

sub reload ($;%) {
  my ($self, %args) = @_;
  my $pk_values = $self->primary_key_bare_values;
  $self->{db}->select
      ($self->table_name, $pk_values, %args, limit => 2, cb => sub {
         if ($_[1]->is_error) {
           goto &{$args{cb}} if $args{cb};
           return:
         }

         if ($_[1]->row_count != 1) {
           local $Carp::CarpLevel = $Carp::CarpLevel - 1;
           croak sprintf "There are %d rows for the primary keys",
               $_[1]->row_count;
         }
         $self->{data} = $_[1]->first;
         delete $self->{parsed_data};

         goto &{$args{cb}} if $args{cb};
       });
  return $self;
} # reload

# ------ Modifications ------

sub update ($$;%) {
  my ($self, $values, %args) = @_;
  croak "No value to set" unless keys %$values;

  my $pk_values = $self->primary_key_bare_values;

  my $schema = $self->table_schema || {};
  my $s_values = {};
  for my $name (keys %$values) {
    if (defined $values->{$name} and
        ref $values->{$name} eq 'Dongry::SQL::BareFragment') {
      $s_values->{$name} = $values->{$name};
      next;
    }

    my $type = $schema->{type}->{$name};
    if ($type) {
      my $handler = $Dongry::Types->{$type}
          or croak "Type handler for |$type| is not defined";
      $s_values->{$name} = $handler->{serialize}->($values->{$name});
    } else {
      if (defined $values->{$name} and ref $values->{$name}) {
        croak "Type for |$name| is not defined but a reference is specified";
      } else {
        $s_values->{$name} = $values->{$name};
      }
    }
  }

  $self->{db}->update
      ($self->table_name, $s_values,
       where => $pk_values,
       source_name => $args{source_name},
       cb => sub {
    if ($_[1]->is_error) {
      goto &{$args{cb}} if $args{cb};
      return:
    }

    local $Carp::CarpLevel = $Carp::CarpLevel - 1;
    croak "@{[$_[1]->{row_count}]} rows are modified by an update"
        unless $_[1]->{row_count} == 1;
    
    for (keys %$values) {
      $self->{data}->{$_} = $s_values->{$_};
      $self->{parsed_data}->{$_} = $values->{$_};
    }

    goto &{$args{cb}} if $args{cb};
  });
} # update

sub delete ($$;%) {
  my ($self, %args) = @_;
  $self->{db}->delete
      ($self->table_name,
       $self->primary_key_bare_values,
       source_name => $args{source_name},
       cb => sub {
    if ($_[1]->is_error) {
      goto &{$args{cb}} if $args{cb};
      return:
    }

    local $Carp::CarpLevel = $Carp::CarpLevel - 1;
    croak "@{[$_[1]->{row_count}]} rows are modified by a delete"
        unless $_[1]->{row_count} == 1;

    goto &{$args{cb}} if $args{cb};
  });
} # delete

sub debug_info ($) {
  my $self = shift;
  local $@;
  my $pk = eval { $self->primary_key_bare_values };
  if ($pk) {
    return sprintf '{Row: %s: %s}',
        $self->table_name,
        join '; ', map { $_ . ' = ' . $pk->{$_} } keys %$pk;
  } else {
    return sprintf '{Row: %s}', $self->table_name;
  }
} # debug_info

sub DESTROY {
  if ($Dongry::LeakTest) {
    warn "Possible memory leak by object " . ref $_[0];
  }
} # DESTROY

1;

=head1 LICENSE

Copyright 2011-2014 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
