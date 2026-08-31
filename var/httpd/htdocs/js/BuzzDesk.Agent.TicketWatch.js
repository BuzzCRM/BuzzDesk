// --
// --
// This software comes with ABSOLUTELY NO WARRANTY. For details, see
// the enclosed file COPYING for license information (AGPL). If you
// did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
// --

"use strict";

var Core = Core || {},
    BuzzDesk = BuzzDesk || {};

BuzzDesk.Agent = BuzzDesk.Agent || {};

BuzzDesk.Agent.TicketWatch = (function (TargetNS) {

    TargetNS.Init = function () {
        var Data = {
            Action:    'AgentTicketWatchView',
            Subaction: 'AJAXUnsubscribeTickets'
        },
        TicketID,
        TicketIDs = [];

        $('#UnsubscribeWatchedTickets').on('click', function(Event) {
            Event.preventDefault();

            $('.MasterAction').each(function() {
                if ($(this).children().first().children().first().prop('checked')) {
                    TicketID = $(this).attr('id').replace('TicketID_', '');
                    TicketIDs.push(TicketID);
                }
            });

            if (TicketIDs.length > 0) {
                Data.TicketIDs = TicketIDs.toString();
                Core.AJAX.FunctionCall(
                    Core.Config.Get('Baselink'),
                    Data,
                    function() {
                        location.reload();
                    }
                );
            }
        });
    };

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(BuzzDesk.Agent.TicketWatch || {}));
