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

BuzzDesk.Agent.MentionAction = (function (TargetNS) {

    TargetNS.Init = function () {
        var Data = {
            Action:    'Mentions',
            Subaction: 'Remove',
            TicketID:  Core.Config.Get("TicketID")
        };

        $('.MentionRow').each(function() {
            $(this).on('click', function(Event) {
                Event.preventDefault();
                Data.MentionedUserID = $(this).attr('data-user-id');

                Core.AJAX.FunctionCall(
                    Core.Config.Get('Baselink'),
                    Data,
                    function() {
                        location.reload();
                    }
                )
            });
        });
    };

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(BuzzDesk.Agent.MentionAction || {}));
