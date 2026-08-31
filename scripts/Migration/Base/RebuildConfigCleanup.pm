# --
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --
## nofilter(TidyAll::Plugin::BuzzDesk::Perl::Pod::NamePod)

package scripts::Migration::Base::RebuildConfigCleanup;    ## no critic

use strict;
use warnings;
use utf8;

use parent qw(scripts::Migration::Base);

our @ObjectDependencies = ();

=head1 SYNOPSIS

Rebuilds the system configuration trying to cleanup the database.

=cut

sub Run {
    my ( $Self, %Param ) = @_;

    $Self->RebuildConfig(
        %Param,
        CleanUpIfPossible => 1,
    );

    return 1;
}

1;
