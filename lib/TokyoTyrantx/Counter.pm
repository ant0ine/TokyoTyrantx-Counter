package TokyoTyrantx::Counter;
use strict;
use warnings;

our $DEBUG = 0;

our $VERSION = '0.01';

=head1 NAME

TokyoTyrantx::Counter - Manage a large set of counters using Tokyo Tyrant

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

 # start an In Memory Tokyo Tyrant before.
 # (TokyoTyrantx::Instance can help)
 
 my $ti = TokyoTyrantx::Instance->new( counthash => {
         dir => '/tmp',
         host => '127.0.0.1',
         port => 4000,
         filename => "'*'",
     }
 );
 $ti->start;

 # then in your code when you need counters
 # (TokyoTyrantx::Instance can still help to get the $rdb)
 
 use TokyoTyrantx::Counter;
 
 my $c = TokyoTyrantx::Counter->instance( hash => $ti->get_rdb );

=head1 METHODS

=cut

my $Instance;

sub _new_instance {
    my $class = shift;
    my %args = @_;
    die 'hash required' unless $args{hash};
    die 'hash is not a TokyoTyrant::RDB' 
        unless $args{hash}->isa('TokyoTyrant::RDB');
    return bless \%args, $class;
}

=head2 instance( hash => $rdb );

Pass the parameters the first time you call instance, then call it without parameter.

The only required parameter is hash that should specify the TokyoTyrant::RDB object.

Optional parameters:

=over 4

=item * default_n_times

define the default value of n_times, if not specified, defaults to 5


=item * default_usleep

define the default sleep dealy in microseconds, if not specified, defaults to 100000

=back

=cut

sub instance {
    my $class = shift;
    return $Instance ||= $class->_new_instance(@_);
}

use constant RDB_TRY => 3;

=head2 add_int( $key, $int )

=cut

sub add_int {
    my $self = shift;
    my ($key, $int) = @_;
    die 'key required' unless $key;
    my $rdb = $self->get_tyrant_client;
    for my $try (1..RDB_TRY()) {
        my $count = $rdb->addint( $key, $int );
        if (defined $count) {
            return $count;
        }
        else {
            if ($rdb->ecode == $rdb->ERECV && $try < RDB_TRY()) {
                # network error
                next;
            }
            else {
                my $msg = $rdb->errmsg($rdb->ecode);
                die "error while trying to increment the counter (key $key) ".$msg;
            }
        }
    }
}

=head2 inc( $key )

=cut

sub inc {
    my $self = shift;
    my ($key) = @_;
    return $self->add_int($key, 1);
}


=head2 dec( $key )

=cut

sub dec {
    my $self = shift;
    my ($key) = @_;
    return $self->add_int($key, -1);
}

=head2 value( $key )

=cut

sub value { 
    my $self = shift;
    my ($key) = @_;
    die 'key required' unless $key;
    my $rdb = $self->get_tyrant_client;
    for my $try (1..RDB_TRY()) {
        if (my $value = $rdb->get( $key )) {
            return unpack 'i', $value;
        }
        else {
            if ($rdb->ecode == $rdb->ERECV && $try < RDB_TRY()) {
                # network error
                next;
            }
            else {
                my $msg = $rdb->errmsg($rdb->ecode);
                die "error while trying to get the counter value (key $key) ".$msg;
            }
        }
    }
}

=head2 iterinit

=cut

sub iterinit {
    my $self = shift;
    my $rdb = $self->get_tyrant_client;
    $rdb->iterinit();
}

=head2 iternext

=cut

sub iternext {
    my $self = shift;
    my $rdb = $self->get_tyrant_client;
    return $rdb->iternext();
}

=head2 reset( $key )

=cut

sub reset {
    my $self = shift;
    my ($key) = @_;
    die 'key required' unless $key;
    my $rdb = $self->get_tyrant_client;
    for my $try (1..RDB_TRY()) {
        if ($rdb->out( $key )) {
            last;
        }
        else {
            if ($rdb->ecode == $rdb->ERECV && $try < RDB_TRY()) {
                # network error
                next;
            }
            else {
                my $msg = $rdb->errmsg($rdb->ecode);
                die "error while trying to reset the counter (key $key) ".$msg;
            }
        }
    }
    return 1;
}

=head2 get_tyrant_client

get the tokyo tyrantclient

=cut

sub get_tyrant_client {
    my $self = shift;
    return $self->{hash};
}

=head2 counter_count

Return the number of counters currently in the hash.
Of course, assumes that the hash is not used for something else.

=cut

sub counter_count {
    my $self = shift;
    my $rdb = $self->get_tyrant_client;
    return $rdb->rnum();
}

=head1 AUTHOR

Antoine Imbert, C<< <antoine.imbert at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Antoine Imbert, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
