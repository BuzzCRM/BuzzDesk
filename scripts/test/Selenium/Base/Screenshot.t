# --
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

use strict;
use warnings;
use utf8;

use vars (qw($Self));
use Data::Dumper;
use Kernel::System::VariableCheck qw(:all);

my $ConfigObject   = $Kernel::OM->Get('Kernel::Config');
my $SeleniumObject = $Kernel::OM->Get('Kernel::System::UnitTest::Selenium');
my $HelperObject   = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
my $DateTimeObject = $Kernel::OM->Create('Kernel::System::DateTime');

# GetScreenshotFileName
my @Tests = (
    {
        Name => 'Filename',
        Data => {
            Filename => 'BuzzDeskRocks',
        },
        Expected => "BuzzDeskRocks.png",
    },
);

for my $Test (@Tests) {

    my $ScreenshotFileName = $SeleniumObject->GetScreenshotFileName(
        %{ $Test->{Data} },
    );

    $Self->Is(
        $ScreenshotFileName,
        $Test->{Expected},
        $Test->{Name},
    );
}

# GetScreenshotDirectory
my $Home    = $SeleniumObject->{Home};
my $WebPath = $ConfigObject->Get('Frontend::WebPath');

@Tests = (
    {
        Name     => 'Default',
        Data     => {},
        Expected => {
            WebPath  => $WebPath . 'SeleniumScreenshots',
            FullPath => $Home . '/var/httpd/htdocs/SeleniumScreenshots',
        }
    },
    {
        Name => 'Additional Directory',
        Data => {
            Directory => 'BuzzDeskRocks',
        },
        Expected => {
            WebPath  => $WebPath . 'SeleniumScreenshots/BuzzDeskRocks',
            FullPath => $Home . '/var/httpd/htdocs/SeleniumScreenshots/BuzzDeskRocks',
        }
    },
);

for my $Test (@Tests) {

    my %ScreenshotDirectory = $SeleniumObject->GetScreenshotDirectory(
        %{ $Test->{Data} },
    );

    $Self->IsDeeply(
        \%ScreenshotDirectory,
        $Test->{Expected},
        $Test->{Name},
    );
}

# GetScreenshotURL

my $HttpType = $ConfigObject->Get('HttpType');
my $Hostname = $HelperObject->GetTestHTTPHostname();

@Tests = (
    {
        Name => 'Default',
        Data => {
            WebPath  => '/otrs-web/SeleniumScreenshots/BuzzDeskRocks',
            Filename => 'AgentTicketZoom',
        },
        Expected => "$HttpType://$Hostname" . "/otrs-web/SeleniumScreenshots/BuzzDeskRocks/AgentTicketZoom",
    },
);

for my $Test (@Tests) {

    my $ScreenshotURL = $SeleniumObject->GetScreenshotURL(
        %{ $Test->{Data} },
    );

    $Self->Is(
        $ScreenshotURL,
        $Test->{Expected},
        $Test->{Name},
    );
}

1;
