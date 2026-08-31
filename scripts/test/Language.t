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
use File::Path();

use Kernel::System::VariableCheck qw(:all);

$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        RestoreDatabase => 1,
    },
);

my $ConfigObject   = $Kernel::OM->Get('Kernel::Config');
my $MainObject     = $Kernel::OM->Get('Kernel::System::Main');
my $LanguageObject = $Kernel::OM->Get('Kernel::Language');

my $DefaultTheme = $ConfigObject->Get('DefaultTheme');
my $TempDir      = $ConfigObject->Get('TempDir');
my $ModuleDir    = "$TempDir/BuzzDeskLanguage";

if ( !-d $ModuleDir ) {
    File::Path::make_path( $ModuleDir, { chmod => 0770 } );    ## no critic
}

# GetTTTemplateTranslatableStrings
my @Tests = (
    {
        Name => '1. [% Translate("GetTTTemplateTranslatableStrings - BuzzDesk rocks") | html %]',
        Data => {
            Filename  => 'Template.tt',
            Content   => '<h1>[% Translate("GetTTTemplateTranslatableStrings - BuzzDesk rocks") | html %]</h1>',
            Directory => "$ModuleDir/Kernel/Output/HTML/Templates/$DefaultTheme",
        },
        Expected => [
            {
                'Location' => 'TT Template: Kernel/Output/HTML/Templates/Standard/Template.tt',
                'Source'   => 'GetTTTemplateTranslatableStrings - BuzzDesk rocks',
            }
        ],
    },
);

for my $Test (@Tests) {

    if ( !-d $Test->{Data}->{Directory} ) {
        File::Path::make_path( $Test->{Data}->{Directory}, { chmod => 0770 } );    ## no critic
    }

    my $TemplateLocation = $MainObject->FileWrite(
        %{ $Test->{Data} },
        Permission => '644',
        Content    => \$Test->{Data}->{Content},
    );

    my @TranslationStrings = $LanguageObject->GetTTTemplateTranslatableStrings(
        ModuleDirectory => $ModuleDir,
    );

    $Self->IsDeeply(
        \@TranslationStrings,
        $Test->{Expected},
        'GetTTTemplateTranslatableStrings - ' . $Test->{Name},
    );
}

# GetJSTemplateTranslatableStrings
@Tests = (
    {
        Name => '1. <span>{{ "GetJSTemplateTranslatableStrings - BuzzDesk rocks" | Translate }}</span>',
        Data => {
            Filename  => 'Template.html.tmpl',
            Content   => '<span>{{ "GetJSTemplateTranslatableStrings - BuzzDesk rocks" | Translate }}</span>',
            Directory => "$ModuleDir/Kernel/Output/JavaScript/Templates/$DefaultTheme",
        },
        Expected => [
            {
                'Location' => 'JS Template: Kernel/Output/JavaScript/Templates/Standard/Template.html.tmpl',
                'Source'   => 'GetJSTemplateTranslatableStrings - BuzzDesk rocks',
            }
        ],
    },
);

for my $Test (@Tests) {

    if ( !-d $Test->{Data}->{Directory} ) {
        File::Path::make_path( $Test->{Data}->{Directory}, { chmod => 0770 } );    ## no critic
    }

    my $TemplateLocation = $MainObject->FileWrite(
        %{ $Test->{Data} },
        Permission => '644',
        Content    => \$Test->{Data}->{Content},
    );

    my @TranslationStrings = $LanguageObject->GetJSTemplateTranslatableStrings(
        ModuleDirectory => $ModuleDir,
    );

    $Self->IsDeeply(
        \@TranslationStrings,
        $Test->{Expected},
        'GetJSTemplateTranslatableStrings - ' . $Test->{Name},
    );
}

# GetPerlModuleTranslatableStrings
@Tests = (
    {
        Name => '1. Translatable("GetPerlModuleTranslatableStrings - BuzzDesk rocks")',
        Data => {
            Filename  => 'Nanok.pm',
            Content   => 'my $Strin = Translatable("GetPerlModuleTranslatableStrings - BuzzDesk rocks");',
            Directory => "$ModuleDir/Kernel/",
        },
        Expected => [
            {
                'Location' => 'Perl Module: Kernel/Nanok.pm',
                'Source'   => 'GetPerlModuleTranslatableStrings - BuzzDesk rocks',
            }
        ],
    },
);

for my $Test (@Tests) {

    if ( !-d $Test->{Data}->{Directory} ) {
        File::Path::make_path( $Test->{Data}->{Directory}, { chmod => 0770 } );    ## no critic
    }

    my $TemplateLocation = $MainObject->FileWrite(
        %{ $Test->{Data} },
        Permission => '644',
        Content    => \$Test->{Data}->{Content},
    );

    my @TranslationStrings = $LanguageObject->GetPerlModuleTranslatableStrings(
        ModuleDirectory => $ModuleDir,
    );

    $Self->IsDeeply(
        \@TranslationStrings,
        $Test->{Expected},
        'GetPerlModuleTranslatableStrings - ' . $Test->{Name},
    );
}

# GetXMLTranslatableStrings
@Tests = (
    {
        Name => '1. <Description Translatable="1">GetXMLTranslatableStrings - BuzzDesk rocks</Description>',
        Data => {
            Filename  => 'BuzzDesk.sopm',
            Content   => '<Description Translatable="1">GetXMLTranslatableStrings - BuzzDesk rocks</Description>',
            Directory => "$ModuleDir/BuzzDesk/",
        },
        Expected => [
            {
                'Location' => 'XML Definition: BuzzDesk.sopm',
                'Source'   => 'GetXMLTranslatableStrings - BuzzDesk rocks',
            }
        ],
    },
);

for my $Test (@Tests) {

    if ( !-d $Test->{Data}->{Directory} ) {
        File::Path::make_path( $Test->{Data}->{Directory}, { chmod => 0770 } );    ## no critic
    }

    my $TemplateLocation = $MainObject->FileWrite(
        %{ $Test->{Data} },
        Permission => '644',
        Content    => \$Test->{Data}->{Content},
    );

    my @TranslationStrings = $LanguageObject->GetXMLTranslatableStrings(
        ModuleDirectory => $ModuleDir,
    );

    $Self->IsDeeply(
        \@TranslationStrings,
        $Test->{Expected},
        'GetXMLTranslatableStrings - ' . $Test->{Name},
    );
}

# GetJSTranslatableStrings
@Tests = (
    {
        Name => '1. [% Translate("GetJSTranslatableStrings - BuzzDesk rocks") | html %]',
        Data => {
            Filename  => 'BuzzDesk.App.js',
            Content   => "Core.Language.Translate('GetJSTranslatableStrings - BuzzDesk rocks')",
            Directory => "$ModuleDir/var/httpd/htdocs/js",
        },
        Expected => [
            {
                'Location' => 'JS File: var/httpd/htdocs/js/BuzzDesk.App.js',
                'Source'   => 'GetJSTranslatableStrings - BuzzDesk rocks',
            }
        ],
    },
);

for my $Test (@Tests) {

    if ( !-d $Test->{Data}->{Directory} ) {
        File::Path::make_path( $Test->{Data}->{Directory}, { chmod => 0770 } );    ## no critic
    }

    my $TemplateLocation = $MainObject->FileWrite(
        %{ $Test->{Data} },
        Permission => '644',
        Content    => \$Test->{Data}->{Content},
    );

    my @TranslationStrings = $LanguageObject->GetJSTranslatableStrings(
        ModuleDirectory => $ModuleDir,
    );

    $Self->IsDeeply(
        \@TranslationStrings,
        $Test->{Expected},
        'GetJSTranslatableStrings - ' . $Test->{Name},
    );
}

1;
