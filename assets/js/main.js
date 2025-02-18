var _____WB$wombat$assign$function_____ = function (name) { return (self._wb_wombat && self._wb_wombat.local_init && self._wb_wombat.local_init(name)) || self[name]; };
if (!self.__WB_pmw) { self.__WB_pmw = function (obj) { this.__WB_source = obj; return this; } }
{
    let window = _____WB$wombat$assign$function_____("window");
    let self = _____WB$wombat$assign$function_____("self");
    let document = _____WB$wombat$assign$function_____("document");
    let location = _____WB$wombat$assign$function_____("location");
    let top = _____WB$wombat$assign$function_____("top");
    let parent = _____WB$wombat$assign$function_____("parent");
    let frames = _____WB$wombat$assign$function_____("frames");
    let opener = _____WB$wombat$assign$function_____("opener");

    var appId = "1131663138272181";
    var flashVersion = "11.3.300.271";
    var messages = [];
    var unloadMessage = "";
    var mt = "";
    var simulatedUserId = "930437541626936";
    var simulatedAccessToken = "GGQVliSTFPU2NqUldJRXp6RmpFMTQwVXlGMEZABYnJUMTlYMzlnR1Y4WkhhN2t6UzM4NVFGekdQQ01pdGNpc3JqN1FRYzdPaEc0VkcyaXhwNWxENXF5MDRsZA1BlVXQ5QU9Ielg4RF94VXVjaFF3UFYxOFU3eEtGMzZAHc25OTkNKdzBpLUxKcmxoamUxenZAIMFE2aGdiTDlVd0dNTzR5azFWNgZDZD";

    var userAgent = navigator.userAgent.toLowerCase();
    $.browser.chrome = /chrome/.test(navigator.userAgent.toLowerCase());

    if ($.browser.chrome) {
        userAgent = userAgent.substring(userAgent.indexOf('chrome/') + 7);
        userAgent = userAgent.substring(0, userAgent.indexOf('.'));
        $.browser.version = userAgent;
        $.browser.safari = false;
    }

    if ($.browser.safari) {
        userAgent = userAgent.substring(userAgent.indexOf('safari/') + 7);
        userAgent = userAgent.substring(0, userAgent.indexOf('.'));
        $.browser.version = userAgent;
    }

    $("document").ready(function () {
        if (mt) {
            showMaintenanceScreen();
            return;
        }

        $.ajax({
            url: "bridge.php",
            type: "GET",
            data: {
                service: "fb"
            },
            dataType: "json",
            timeout: 5000,
            cache: false,
            success: function (json) {
                if (json == null) {
                    showGameScreen();
                    return;
                }

                var obj = json.services[0];
                if (obj.mode == 2) {
                    orig = obj.onlineETA;
                    origArr = orig.split(":");
                    var d = new Date();
                    d.setUTCHours(origArr[0]);
                    d.setUTCMinutes(origArr[1]);
                    var hrs = d.getHours();
                    var mins = Math.ceil(d.getMinutes() / 15) * 15;
                    while (mins >= 60) {
                        mins -= 60;
                        hrs++;
                    }
                    while (hrs >= 24)
                        hrs -= 24;

                    mtPST = (hrs < 10 ? "0" + hrs : hrs) + ":" + (mins < 10 ? "0" + mins : mins);
                    showMaintenanceScreen();
                } else {
                    showGameScreen();
                }

                if (obj.htmlMessage && obj.htmlMessage != "")
                    addMessage("statusMessage", obj.htmlMessage, true);

            },
            error: function (xhr, status) {
                showGameScreen();
            }
        })
    });

    function showGameScreen() {
        var currentFlashVersion = swfobject.getFlashPlayerVersion();
        $("#noflash_reqVersion").html(flashVersion);
        $("#noflash_currentVersion").html(currentFlashVersion.major + "." + currentFlashVersion.minor + "." + currentFlashVersion.release);

        if (screen.availWidth <= 1250) {
            $("#fb_likes").css("right", "-6px");
            $("#nav").css("left", "220px");
        }

        window.fbAsyncInit = function () {
            FB.init({
                appId: appId,
                status: true,
                cookie: true,
                oauth: true,
                version: 'v22.0',
                hideFlashCallback: onFlashHide
            });
        
            FB.AppEvents.logPageView();
        
            setTimeout(function () {
                FB.Canvas.setSize({ height: 1100 });
        
                var response = {
                    status: "connected",
                    authResponse: {
                        userID: simulatedUserId,
                        accessToken: simulatedAccessToken
                    }
                };
        
                handleLoginStatus(response);
            }, 500);
        };
        
        function handleLoginStatus(response) {
            switch (response.status) {
                case "connected":
                    $("#userID").html("User Id: " + response.authResponse.userID);
                    if (getParameterByName("migration") != "") {
                        startMigration(response.authResponse.accessToken);
                    } else {
                        startGame(response.authResponse.accessToken);
                    }
                    break;
        
                case "not_authorized":
                    $("#userID").html("");
                    showError("App not Authorized", "L'application n'a pas été autorisée.");
                    showLoginButton();
                    break;
        
                default:
                    $("#userID").html("");
                    showError("Not logged into Facebook", "Vous devez être connecté à Facebook pour jouer.");
                    break;
            }
        }

        (function(d, s, id){
            var js, fjs = d.getElementsByTagName(s)[0];
            if (d.getElementById(id)) {return;}
            js = d.createElement(s); js.id = id;
            js.src = "https://connect.facebook.net/en_US/sdk.js";
            fjs.parentNode.insertBefore(js, fjs);
          }(document, 'script', 'facebook-jssdk'));
    }

    function getParameterByName(name) {
        name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
        var regexS = "[\\?&]" + name + "=([^&#]*)";
        var regex = new RegExp(regexS);
        var results = regex.exec(window.location.search);
        if (results == null)
            return "";
        else
            return decodeURIComponent(results[1].replace(/\+/g, " "));
    }

    function getRefererParam(key) {
        key = key.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
        var regex = new RegExp("[\\?&]" + key + "=([^&#]*)");
        var qs = regex.exec(document.referrer);
        if (qs == null)
            return "";
        else
            return qs[1];
    }


    function startGame(accessToken) {
        var flashVars = {
            path: "/game/",
            service: "fb",
            accessToken: accessToken,
            affiliate: getParameterByName("a"),
            useSSL: ("https:" == document.location.protocol ? "1" : "0")
        };

        var params = {
            allowScriptAccess: "always",
            allowFullScreen: "true",
            allowFullScreenInteractive: "true",
            allowNetworking: "all",
            menu: "false",
            scale: "noScale",
            salign: "tl",
            wmode: "direct",
            bgColor: "#000000"
        };

        var attributes = {
            id: "game",
            name: "game"
        };

        $("#game_wrapper").height("0px");

        var swfURL = "/game/preloader.swf"
        swfobject.embedSWF(swfURL, "game_container", "100%", "100%", flashVersion, "swf/expressinstall.swf", flashVars, params, attributes, function (e) {
            if (!e.success) {
                showNoFlash();
            } else {
                setMouseWheelState(false);
            }
        });
    }

    function startMigration(accessToken) {

        var migrationStr = getParameterByName("migration");

        var flashVars = {
            path: "/migration/",
            core: "importClient.swf",
            migration: migrationStr,
            service: "fb",
            accessToken: accessToken,
            affiliate: getParameterByName("a"),
            useSSL: ("https:" == document.location.protocol ? "1" : "0"),
        };

        var params = {
            allowScriptAccess: "always",
            allowFullScreen: "true",
            allowFullScreenInteractive: "false",
            allowNetworking: "all",
            menu: "false",
            scale: "noScale",
            salign: "tl",
            wmode: "direct",
            bgColor: "#000000"
        };

        var attributes = {
            id: "game",
            name: "game"
        };

        $("#game_wrapper").height("0px");

        var swfURL = "/game/preloader.swf"
        swfobject.embedSWF(swfURL, "game_container", "100%", "100%", flashVersion, "swf/expressinstall.swf", flashVars, params, attributes, function (e) {
            if (!e.success) {
                showNoFlash();
            } else {
                setMouseWheelState(false);
            }
        });
    }

    function showMaintenanceScreen() {
        addMessage("maintenance", "The Last Stand: Dead Zone is down for scheduled maintenance. ETA " + mtPST + " local time.");
        showError("Scheduled Maintenance", "The Last Stand: Dead Zone is down for scheduled maintenance.<br/>We apologise for any inconvenience.<br/><br/><strong>ETA " + mtPST + " local time</strong>");
    }

    function showNoFlash() {
        $("#loading").remove();
        $("#noflash").css("display", "block");
        $("#game_wrapper").height("100%");
        $("#userID").html("");
    }

    function showError(title, message) {
        $("#loading").remove();
        $("#generic_error").css("display", "block");
        $("#generic_error").html("<p><h2>" + title + "</h2></p><p>" + message + "</p>");
        $("#generic_error").append($("#loginbutton"));
        $("#userID").html("");
    }

    function showLoginButton() {
        $("#loginbutton").show();
    }

    function killGame() {
        $("#game").remove();
        $("#game_container").remove();
        $("#loading").remove();
        $("#content").prepend("" +
            "<div id='messagebox'>" +
            "<div class='header'>Are you there?</div>" +
            "<div class='msg'>You've left your compound unattended for some time. Are you still playing?</div>" +
            "<div class='btn' onclick='refresh()'>BACK TO THE DEAD ZONE</div>" +
            "</div>");
    }

    function onPreloaderReady() {
        $("#loading").remove();
        $("#game_wrapper").height("100%");
    }

    function onFlashHide(info) {
        if (info.state == "opened") {
            var strImg = document.getElementById("game").getScreenshot();
            if (strImg != null)
                $("#content").append("<img id='screenshot' style='position:absolute; top:120px; width:960px; height:804px;' src='data:image/jpeg;base64," + strImg + "'/>");
        }
        else {
            var screenElement = $("#screenshot");
            if (screenElement != null) screenElement.remove();
        }
    }

    function showFlash() {
        $("#showGame").remove();
        FB.Canvas.showFlashElement(document.getElementById("game"));
    }

    function refresh() {
        location.reload();
    }

    function addMessage(id, message, showCloseButton, showSpinner) {
        var bar = $("<div class=\"header_message_bar\"></div>");
        bar.data("id", id);

        if (showCloseButton) {
            var closeDiv = $("<div class=\"close\"></div>").click(function () {
                bar.stop(true, true).animate({ height: "toggle" }, 250);
            });
            bar.append(closeDiv);
        }

        if (showSpinner) {
            var loader = $("<div class=\"loader\"></div<");
            bar.append(loader);
        }

        message = parseUTCStrings(message);

        var msgDiv = $("<div class=\"header_message\">" + message + "</div>");
        bar.append(msgDiv);
        $("#warning_container").append(bar);

        bar.height("0px").animate({ height: "30px" }, 250);
        messages.push(bar);
    }

    function removeMessage(id) {
        for (var i = messages.length - 1; i >= 0; i--) {
            var msg = messages[i];
            if (msg.data("id") == id) {
                msg.stop(true).animate({ height: "toggle" }, 250);
                messages.splice(i, 1);
            }
        }
    }

    function parseUTCStrings(msg) {
        reg = /\[\%UTC (\d{4})\-(\d{2})\-(\d{2}) (\d{2})\-(\d{2})\]/ig;
        while (seg = reg.exec(msg)) {
            msg = msg.replace(seg[0], convertUTCtoLocal(Number(seg[1]), Number(seg[2]), Number(seg[3]), Number(seg[4]), Number(seg[5])));
        }
        reg = /\[\%UTC (\d{2})\-(\d{2})\]/ig;
        while (seg = reg.exec(msg)) {
            msg = msg.replace(seg[0], convertUTCtoLocal(0, 0, 0, Number(seg[1]), Number(seg[2])));
        }
        return msg;
    }

    function convertUTCtoLocal(year, month, date, hours, mins) {
        var d = new Date();
        if (year > 0)
            d.setUTCFullYear(year, month - 1, date);
        d.setUTCHours(hours);
        d.setUTCMinutes(mins);

        var str = "";
        if (year > 0) {
            months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
            str = months[d.getMonth()] + " " + d.getDate() + ", " + d.getFullYear() + " ";
        }
        str += (d.getHours() <= 12 ? d.getHours() : d.getHours() - 12) + ":" + (d.getMinutes() < 10 ? "0" + d.getMinutes() : d.getMinutes()) + (d.getHours() < 12 ? "am" : "pm");
        return str;
    }

    var requestCodeRedeemInterval;
    var waitingForCodeRedeem = false;

    function openRedeemCodeDialogue() {
        updateNavClass("code");

        if (mt || waitingForCodeRedeem)
            return;

        var requestDialogue = function () {
            try {
                document.getElementById("game").openRedeemCode();
                removeMessage("openingCodeRedeem");
                updateNavClass(null);
                return true;
            }
            catch (err) { }
            return false;
        };

        if (!requestDialogue()) {
            addMessage("openingCodeRedeem", "Please wait while the game loads...", false, true);

            waitingForCodeRedeem = true;
            requestCodeRedeemInterval = setInterval(function () {
                if (requestDialogue()) {
                    waitingForCodeRedeem = false;
                    clearInterval(requestCodeRedeemInterval);
                }
            }, 1000);
        }
    }

    var requestGetMoreInterval;
    var waitingForGetMore = false;

    function openGetMoreDialogue() {
        updateNavClass("get_more");

        if (mt || waitingForGetMore)
            return;

        var requestDialogue = function () {
            try {
                if (document.getElementById("game").openGetMore()) {
                    removeMessage("openingFuel");
                    updateNavClass(null);
                    return true;
                }
            }
            catch (err) { }
            return false;
        };

        if (!requestDialogue()) {
            addMessage("openingFuel", "Opening Fuel Store, please wait while the game loads...", false, true);

            waitingForGetMore = true;
            requestGetMoreInterval = setInterval(function () {
                if (requestDialogue()) {
                    waitingForGetMore = false;
                    clearInterval(requestGetMoreInterval);
                }
            }, 1000);
        }
    }

    function updateNavClass(className) {
        $("#nav_ul")[0].className = className;
    }

    function setMouseWheelState(state) {
        if (state) {
            document.onmousewheel = null;
            if (document.addEventListener) {
                document.removeEventListener("DOMMouseScroll", preventWheel, false);
            }
        } else {
            document.onmousewheel = function () { preventWheel(); }
            if (document.addEventListener) {
                document.addEventListener("DOMMouseScroll", preventWheel, false);
            }
        }
    }

    function preventWheel(e) {
        if (!e) { e = window.event; }
        if (e.preventDefault) {
            e.preventDefault();
        } else e.returnValue = false;

        function setBeforeUnloadMessage(msg) {
            unloadMessage = msg;
            $(window).bind('beforeunload', handleUnload);
            return true;
        }

        function clearBeforeUnloadMessage() {
            unloadMessage = "";
            $(window).unbind('beforeunload', handleUnload);
            return true;
        }

        function handleUnload() {
            return unloadMessage;
        }

    }
}