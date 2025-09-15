(function () {

    function setUserId(params) {
        console.log("setuserid", params)
    }

    window.PublishingNetworkCustomState = {
        isLoginDone: false,
    };

    window.PublishingNetwork = {
        /**
         * Show a dialog to the user.
         * @param {string} dialogName
         * @param {object} dialogArgs
         * @param {(result)=>{}} callback
         */
        dialog: function (dialogName, dialogArgs, callback) {
            console.debug(
                "PublishingNetwork.dialog",
                dialogName,
                dialogArgs,
                callback
            );

            // preloader/PublishingNetworkDialog@line 40
            const { __apitoken__ } = dialogArgs;

            let result = null;

            // HACK : dialogName is passed as null so i need to try to understand what result is expected
            // since the login dialog is the first one to be called i created a custom state with a flag
            if (!dialogName && !window.PublishingNetworkCustomState.isLoginDone) {
                result = {
                    userToken: "user-token-1",
                };

                callback(result);
                window.PublishingNetworkCustomState.isLoginDone = true;
                return;
            }

            // This is how should be managed
            switch (dialogName) {
                // preloader/playerio.PlayerIO@line 131
                case "login":
                    {
                        // TODO : IMPLEMENT LOGIN DIALOG (WHAT DOES IT DO?)
                        const errorPresent = false;
                        if (errorPresent) {
                            // preloader/playerio.PlayerIO@line 137
                            result = {
                                error: "error message",
                            };
                            break;
                        }

                        // preloader/playerio.PlayerIO@line 141 147
                        result = {
                            userToken: "user-token-1",
                        };
                    }
                    break;
                default: {
                    console.error("Unknown dialog name:", dialogName);
                    return;
                }
            }

            callback(result);
        },
    };

    // TODO : SHOULD THIS BE IMPLEMENTED? it seems not necessary since we doesn't load the script async
    // this should be a event queue to call "things" (like the dialog)
    // preloader/PublishingNetworkDialog@line 67
    window.PublishingNetwork_WaitingCalls = [];
})();
