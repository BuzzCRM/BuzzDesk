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

use Kernel::System::VariableCheck qw(:all);

my $BuzzDeskHelperObject    = $Kernel::OM->Get('Kernel::System::BuzzDeskHelper');
my $ConfigObject         = $Kernel::OM->Get('Kernel::Config');
my $SysConfigObject      = $Kernel::OM->Get('Kernel::System::SysConfig');
my $UnitTestHelperObject = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
my $DBObject             = $Kernel::OM->Get('Kernel::System::DB');

my $Value = 'test';
if ( $DBObject->{Backend}->{'DB::CaseSensitive'} ) {
    $Value = 'Test';
}

# Tests for _ItemReverseListGet function
my $ResultItemReverseListGet = $BuzzDeskHelperObject->_ItemReverseListGet(
    $Value, ( 'Test' => 1 )
);

$Self->True(
    $ResultItemReverseListGet,
    'Test basic function call of _ItemReverseListGet()',
);

# Tests for _EventAdd function
my $ResultEventAdd = $BuzzDeskHelperObject->_EventAdd(
    Object => 'Ticket',
    Event  => [
        'BuzzDeskEvent1',
        'BuzzDeskEvent2',
    ],
);

$Self->True(
    $ResultEventAdd,
    'Test basic function call of _EventAdd()',
);

# Tests for _EventRemove function
my $ResultEventRemove = $BuzzDeskHelperObject->_EventRemove(
    Object => 'Ticket',
    Event  => [
        'BuzzDeskEvent1',
        'BuzzDeskEvent2',
    ],
);

$Self->True(
    $ResultEventRemove,
    'Test basic function call of _EventRemove()',
);

my $Success;
my %DefaultColumns = (
    Title                     => 1,
    CustomerUserID            => 1,
    DynamicField_DropdownTest => 1,
    DynamicField_Anotherone   => 1,
);

my %DefaultColumnsConfigs = (
    'Ticket::Frontend::AgentTicketStatusView###DefaultColumns'      => \%DefaultColumns,
    'Ticket::Frontend::AgentTicketQueue###DefaultColumns'           => \%DefaultColumns,
    'Ticket::Frontend::AgentTicketResponsibleView###DefaultColumns' => \%DefaultColumns,
    'Ticket::Frontend::AgentTicketWatchView###DefaultColumns'       => \%DefaultColumns,

    'Ticket::Frontend::AgentTicketLockedView###DefaultColumns'     => \%DefaultColumns,
    'Ticket::Frontend::AgentTicketEscalationView###DefaultColumns' => \%DefaultColumns,
    'Ticket::Frontend::AgentTicketSearch###DefaultColumns'         => \%DefaultColumns,
    'Ticket::Frontend::AgentTicketService###DefaultColumns'        => \%DefaultColumns,

    'DashboardBackend###0100-TicketPendingReminder' => \%DefaultColumns,
    'DashboardBackend###0110-TicketEscalation'      => \%DefaultColumns,
    'DashboardBackend###0120-TicketNew'             => \%DefaultColumns,
    'DashboardBackend###0130-TicketOpen'            => \%DefaultColumns,
    'DashboardBackend###0140-RunningTicketProcess'  => \%DefaultColumns,

    'AgentCustomerInformationCenter::Backend###0100-CIC-TicketPendingReminder' => \%DefaultColumns,
    'AgentCustomerInformationCenter::Backend###0110-CIC-TicketEscalation'      => \%DefaultColumns,
    'AgentCustomerInformationCenter::Backend###0120-CIC-TicketNew'             => \%DefaultColumns,
    'AgentCustomerInformationCenter::Backend###0130-CIC-TicketOpen'            => \%DefaultColumns,
);

# Tests for _DefaultColumnsEnable function
$Success = $BuzzDeskHelperObject->_DefaultColumnsEnable(%DefaultColumnsConfigs);

$Self->True(
    $Success,
    'Test basic function call of _DefaultColumnsEnable()',
);

# Tests for _DefaultColumnsDisable function
$Success = $BuzzDeskHelperObject->_DefaultColumnsDisable(%DefaultColumnsConfigs);

$Self->True(
    $Success,
    'Test basic function call of _DefaultColumnsDisable()',
);

my %DynamicFieldsScreen = (
    'TestDynamicField1' => 1,
    'TestDynamicField2' => 1,
);

# Tests for _DynamicFieldsScreenEnable function
my $ResultDynamicFieldsScreenEnable = $BuzzDeskHelperObject->_DynamicFieldsScreenEnable(
    'AgentTicketFreeText' => \%DynamicFieldsScreen
);

$Self->True(
    $ResultDynamicFieldsScreenEnable,
    'Test basic function call of _DynamicFieldsScreenEnable()',
);

$BuzzDeskHelperObject->_RebuildConfig();
$SysConfigObject = $Kernel::OM->Get('Kernel::System::SysConfig');
$ConfigObject    = $Kernel::OM->Get('Kernel::Config');

my $AgentTicketFreeTextFrontendConfig = $ConfigObject->Get('Ticket::Frontend::AgentTicketFreeText');

for my $DynamicFieldScreen ( sort keys %DynamicFieldsScreen ) {
    $Self->Is(
        $AgentTicketFreeTextFrontendConfig->{DynamicField}->{$DynamicFieldScreen},
        $DynamicFieldsScreen{$DynamicFieldScreen},
        "_DynamicFieldsScreenEnable() for $DynamicFieldScreen in AgentTicketFreeText",
    );
}

# Tests for _DynamicFieldsScreenDisable function
my $ResultDynamicFieldsScreenDisable = $BuzzDeskHelperObject->_DynamicFieldsScreenDisable(
    'AgentTicketFreeText' => \%DynamicFieldsScreen,
);

$Self->True(
    $ResultDynamicFieldsScreenDisable,
    'Test basic function call of _DynamicFieldsScreenDisable()',
);

$BuzzDeskHelperObject->_RebuildConfig();
$SysConfigObject = $Kernel::OM->Get('Kernel::System::SysConfig');
$ConfigObject    = $Kernel::OM->Get('Kernel::Config');

$AgentTicketFreeTextFrontendConfig = $ConfigObject->Get('Ticket::Frontend::AgentTicketFreeText');

for my $DynamicFieldScreen ( sort keys %DynamicFieldsScreen ) {
    $Self->False(
        $AgentTicketFreeTextFrontendConfig->{DynamicField}->{$DynamicFieldScreen},
        "_DynamicFieldsScreenDisable() for $DynamicFieldScreen in AgentTicketFreeText",
    );
}

# Tests for _DynamicFieldsCreateIfNotExists function
my $ResultDynamicFieldsCreateIfNotExists = $BuzzDeskHelperObject->_DynamicFieldsCreateIfNotExists(
    {
        Name       => 'TestDynamicField1',
        Label      => "TestDynamicField1",
        ObjectType => 'Ticket',
        FieldType  => 'Text',
        Config     => {
            DefaultValue => "",
        },
    },
);

$Self->True(
    $ResultDynamicFieldsCreateIfNotExists,
    'Test basic function call of _DynamicFieldsCreateIfNotExists()',
);

# Tests for _DynamicFieldsDisable function
my $ResultDynamicFieldsDisable = $BuzzDeskHelperObject->_DynamicFieldsDisable(
    'TestDynamicField1',
);

$Self->True(
    $ResultDynamicFieldsDisable,
    'Test basic function call of _DynamicFieldsDisable()',
);

# Tests for _DynamicFieldsDelete function
my $ResultDynamicFieldsDelete = $BuzzDeskHelperObject->_DynamicFieldsDelete(
    'TestDynamicField1',
);

$Self->True(
    $ResultDynamicFieldsDelete,
    'Test basic function call of _DynamicFieldsDelete()',
);

# Tests for _GroupCreateIfNotExists function
my $ResultGroupCreateIfNotExists = $BuzzDeskHelperObject->_GroupCreateIfNotExists(
    Name => 'Some Group Name',
);

$Self->True(
    $ResultGroupCreateIfNotExists,
    'Test basic function call of _GroupCreateIfNotExists()',
);

# Tests for _RoleCreateIfNotExists function
my $ResultRoleCreateIfNotExists = $BuzzDeskHelperObject->_RoleCreateIfNotExists(
    Name => 'Some Role Name',
);

$Self->True(
    $ResultRoleCreateIfNotExists,
    'Test basic function call of _RoleCreateIfNotExists()',
);

# Tests for _TypeCreateIfNotExists function
my $ResultTypeCreateIfNotExists = $BuzzDeskHelperObject->_TypeCreateIfNotExists(
    Name => 'Some Type Name',
);

$Self->True(
    $ResultTypeCreateIfNotExists,
    'Test basic function call of _TypeCreateIfNotExists()',
);

# Tests for _StateCreateIfNotExists function
my $ResultStateCreateIfNotExists = $BuzzDeskHelperObject->_StateCreateIfNotExists(
    Name   => 'Some State Name',
    TypeID => 1,
);

$Self->True(
    $ResultStateCreateIfNotExists,
    'Test basic function call of _StateCreateIfNotExists()',
);

# Tests for _StateDisable function
my $ResultStateDisable = $BuzzDeskHelperObject->_StateDisable(
    'Some State Name',
);

$Self->True(
    $ResultStateDisable,
    'Test basic function call of _StateDisable()',
);

# Tests for _ServiceCreateIfNotExists function
my $ResultServiceCreateIfNotExists = $BuzzDeskHelperObject->_ServiceCreateIfNotExists(
    Name => 'Some ServiceName',
);

$Self->True(
    $ResultServiceCreateIfNotExists,
    'Test basic function call of _ServiceCreateIfNotExists()',
);

# Tests for _SLACreateIfNotExists function
my $ResultSLACreateIfNotExists = $BuzzDeskHelperObject->_SLACreateIfNotExists(
    Name => 'Some SLAName',
);

$Self->True(
    $ResultSLACreateIfNotExists,
    'Test basic function call of _SLACreateIfNotExists()',
);

# Tests for _QueueCreateIfNotExists function
my $ResultQueueCreateIfNotExists = $BuzzDeskHelperObject->_QueueCreateIfNotExists(
    Name    => 'Some Queue Name',
    GroupID => 1,
);

$Self->True(
    $ResultQueueCreateIfNotExists,
    'Test basic function call of _QueueCreateIfNotExists()',
);

# Tests for _WebserviceCreateIfNotExists function
my $ResultWebserviceCreateIfNotExists = $BuzzDeskHelperObject->_WebserviceCreateIfNotExists(
    SubDir => 'BuzzDesk',
);

$Self->True(
    $ResultWebserviceCreateIfNotExists,
    'Test basic function call of _WebserviceCreateIfNotExists()',
);

# Tests for _WebservicesGet function
my $ResultWebservicesGet = $BuzzDeskHelperObject->_WebservicesGet(
    SubDir => 'BuzzDesk',
);

$Self->True(
    $ResultWebservicesGet,
    'Test basic function call of _WebservicesGet()',
);

# Tests for _WebserviceDelete function
my $ResultWebserviceDelete = $BuzzDeskHelperObject->_WebserviceDelete(
    SubDir => 'BuzzDesk',
);

$Self->True(
    $ResultWebserviceDelete,
    'Test basic function call of _WebserviceDelete()',
);

# Tests for _GenericAgentCreate and _GenericAgentCreateIfNotExists function
my @GenericAgents = (
    {
        Name => 'UnitTestJob',
        Data => {
            Valid => '1'
            ,

            # Event based execution (single ticket)
            EventValues => [
                'TicketCreate'
            ],

            # Select Tickets
            LockIDs => [
                '1'
            ],

            # Update/Add Ticket Attributes
            NewLockID => '2',
        },
        UserID => 1,
    },
);

my $ResultGenericAgentCreate = $BuzzDeskHelperObject->_GenericAgentCreate(@GenericAgents);
$Self->True(
    $ResultGenericAgentCreate,
    'Test basic function call of _GenericAgentCreate()',
);

my $ResultGenericAgentCreateIfNotExists = $BuzzDeskHelperObject->_GenericAgentCreateIfNotExists(@GenericAgents);
$Self->True(
    $ResultGenericAgentCreateIfNotExists,
    'Test basic function call of _GenericAgentCreateIfNotExists()',
);

1;
