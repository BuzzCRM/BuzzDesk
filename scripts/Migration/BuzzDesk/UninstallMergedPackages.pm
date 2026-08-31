# --
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --
## nofilter(TidyAll::Plugin::BuzzDesk::Perl::Pod::NamePod)

package scripts::Migration::BuzzDesk::UninstallMergedPackages;    ## no critic

use strict;
use warnings;
use utf8;

use parent qw(scripts::Migration::Base);

our @ObjectDependencies = (
    'Kernel::System::Cache',
    'Kernel::System::Package',
);

=head1 SYNOPSIS

Uninstalls code that was merged from packages into BuzzDesk.

=head1 PUBLIC INTERFACE

=cut

sub Run {
    my ( $Self, %Param ) = @_;

    my @PackageNames = (
        'BuzzDesk-MultiSendmail',
        'BuzzDesk-CopyTicketNumber',
        'BuzzDesk-AgentTicketActionCommonCustomer',
        'BuzzDesk4OTRS-AdditionalTicketAttributeSelection',
        'BuzzDesk-AdditionalTicketAttributeSelection',
        'BuzzDesk-Bugfix1463',
        'BuzzDesk-Bugfix-7_3_1',
    );

    my $CacheObject   = $Kernel::OM->Get('Kernel::System::Cache');
    my $PackageObject = $Kernel::OM->Get('Kernel::System::Package');

    # Purge relevant caches before uninstalling to avoid errors because of inconsistent states.
    $CacheObject->CleanUp(
        Type => 'RepositoryList',
    );
    $CacheObject->CleanUp(
        Type => 'RepositoryGet',
    );
    $CacheObject->CleanUp(
        Type => 'XMLParse',
    );

    PACKAGENAME:
    for my $PackageName (@PackageNames) {
        my $Success = $PackageObject->_PackageUninstallMerged(
            Name => $PackageName,
        );
        next PACKAGENAME if $Success;

        print "\n    Error uninstalling package $PackageName\n\n";
        return;
    }

    return 1;
}

1;
