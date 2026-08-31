# --
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::System::SupportDataCollector::Plugin::BuzzDesk::Version;

use strict;
use warnings;

use parent qw(Kernel::System::SupportDataCollector::PluginBase);

use Kernel::Language qw(Translatable);

our @ObjectDependencies = (
    'Kernel::Config',
);

sub GetDisplayPath {
    return Translatable('BuzzDesk');
}

sub Run {
    my $Self = shift;

    $Self->AddResultInformation(
        Label => Translatable('BuzzDesk Version'),
        Value => $Kernel::OM->Get('Kernel::Config')->Get('Version'),
    );

    return $Self->GetResults();
}

1;
