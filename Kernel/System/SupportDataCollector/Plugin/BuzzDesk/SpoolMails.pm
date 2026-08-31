# --
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::System::SupportDataCollector::Plugin::BuzzDesk::SpoolMails;

use strict;
use warnings;

use parent qw(Kernel::System::SupportDataCollector::PluginBase);

use Kernel::Language qw(Translatable);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Main',
);

sub GetDisplayPath {
    return Translatable('BuzzDesk');
}

sub Run {
    my $Self = shift;

    my $Home     = $Kernel::OM->Get('Kernel::Config')->Get('Home');
    my $SpoolDir = "$Home/var/spool";

    my @SpoolMails = $Kernel::OM->Get('Kernel::System::Main')->DirectoryRead(
        Directory => $SpoolDir,
        Filter    => '*',
    );

    if ( scalar @SpoolMails ) {
        $Self->AddResultProblem(
            Label   => Translatable('Spooled Emails'),
            Value   => scalar @SpoolMails,
            Message => Translatable('There are emails in var/spool that BuzzDesk could not process.'),
        );
    }
    else {
        $Self->AddResultOk(
            Label => Translatable('Spooled Emails'),
            Value => scalar @SpoolMails,
        );
    }

    return $Self->GetResults();
}

1;
