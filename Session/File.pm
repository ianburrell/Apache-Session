#############################################################################
#
# Apache::Session::File
# Apache persistent user sessions in the filesystem
# Copyright(c) 1998, 1999 Jeffrey William Baker (jeffrey@kathyandjeffrey.net)
# Distribute under the Artistic License
#
############################################################################

package Apache::Session::File;

use strict;
use vars qw(@ISA $VERSION);

$VERSION = '1.00';
@ISA = qw(Apache::Session);

use Apache::Session;
use Apache::Session::SysVSemaphoreLocker;
use Apache::Session::FileStore;

sub get_object_store {
    my $self = shift;

    return new Apache::Session::FileStore $self;
}

sub get_lock_manager {
    my $self = shift;
    
    return new Apache::Session::SysVSemaphoreLocker $self;
}

1;
