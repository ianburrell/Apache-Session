#############################################################################
#
# Apache::Session::Flex
# Apache persistent user sessions stored however you want
# Copyright(c) 2000 Jeffrey William Baker (jwbaker@acm.org)
# Distribute under the Artistic License
#
############################################################################

package Apache::Session::Flex;

use strict;
use vars qw(@ISA $VERSION $incl);

$VERSION = '1.00';
@ISA = qw(Apache::Session);

$incl = {};

use Apache::Session;

sub populate {
    my $self = shift;

    my $store = "Apache::Session::Store::$self->{args}->{Store}";
    my $lock  = "Apache::Session::Lock::$self->{args}->{Lock}";
    my $gen   = "Apache::Session::Generate::$self->{args}->{Generate}";
    my $ser   = "Apache::Session::Serialize::$self->{args}->{Serialize}";

    if (!exists $incl->{$store}) {
        eval "require $store" || die $@;
        $incl->{$store} = 1;
    }
    
    if (!exists $incl->{$lock}) {
        eval "require $lock" || die $@;
        $incl->{$lock} = 1;
    }
    
    if (!exists $incl->{$gen}) {
        eval "require $gen" || die $@;
        eval '$incl->{$gen} = \&' . $gen . '::generate' || die $@;
    }
    
    if (!exists $incl->{$ser}) {
        eval "require $ser" || die $@;
        eval '$incl->{$ser}->[0] = \&' . $ser . '::serialize' || die $@;
        eval '$incl->{$ser}->[1] = \&' . $ser . '::unserialize' || die $@;
    }
    
    $self->{object_store} = new $store $self;
    $self->{lock_manager} = new $lock $self;
    $self->{generate}     = $incl->{$gen};
    $self->{serialize}    = $incl->{$ser}->[0];
    $self->{unserialize}  = $incl->{$ser}->[1];

    return $self;
}

1;

=pod

=head1 NAME

Apache::Session::Flex - Specify everything at runtime

=head1 SYNOPSIS

 use Apache::Session::Flex;
 
 tie %hash, 'Apache::Session::Flex', $id, {
    Store     => 'DB_File',
    Lock      => 'Null',
    Generate  => 'MD5',
    Serialize => 'Storable'
 };
 
 # or

 tie %hash, 'Apache::Session::Flex', $id, {
    Store     => 'Postgres',
    Lock      => 'Null',
    Generate  => 'MD5',
    Serialize => 'Base64'
 };
 
 # you decide!

=head1 DESCRIPTION

This module is an implementation of Apache::Session.  Unlike other
implementations, it allows you to specify the backing store, locking scheme,
ID generator, and data serializer at runtime.  You do this by passing
arguments in the usual Apache::Session style (see SYNOPSIS).  You may
use any of the modules included in this distribution, or a module of your
own making.  If you wish to use a module of your own making, you should
make sure that it is available under the Apache::Session package namespace.

=head1 USAGE

You pass the modules you want to use as arguments to the constructor.  The
Apache::Session::Whatever part is appended for you: you should not supply it.
For example, if you wanted to use MySQL as the backing store, you should give
the argument C<Store => 'MySQL'>, and not 
C<Store => 'Apache::Session::Store::MySQL'>.  There are four modules that you
need to specify.  Store is the backing store to use.  Lock is the locking scheme.
Generate is the ID generation module.  Serialize is the data serialization
module.

There are many modules included in this distribution.  For each role, they are:

 Store:
    MySQL
    Postgres
    DB_File
    File
 
 Lock:
    Null
    MySQL
    Semaphore

 Generate:
    MD5
    
 Serialize:
    Storable
    Base64
    UUEncode
   
In addition to the arguments needed by this module, you must provide whatever
arguments are expected by the backing store and lock manager that you are
using.  Please see the documentation for those modules.

=head1 AUTHOR

This module was written by Jeffrey William Baker <jwbaker@acm.org>.

=head1 SEE ALSO

L<Apache::Session::File>, L<Apache::Session::DB_File>,
L<Apache::Session::MySQL>, L<Apache::Session::Postgres>, L<Apache::Session>
