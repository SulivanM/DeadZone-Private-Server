var _____WB$wombat$assign$function_____ = function(name) {
    return (self._wb_wombat && self._wb_wombat.local_init && self._wb_wombat.local_init(name)) || self[name];
};
if (!self.__WB_pmw) {
    self.__WB_pmw = function(obj) {
        this.__WB_source = obj;
        return this;
    }
}
{
    const window = _____WB$wombat$assign$function_____("window");
    const document = _____WB$wombat$assign$function_____("document");
    const location = _____WB$wombat$assign$function_____("location");

    const flashVersion = "11.3.300.271";
    const messages = [];
    let unloadMessage = "";
    const mt = false;
    let mtPST = "";

    const userAgent = navigator.userAgent.toLowerCase();
    $.browser.chrome = /chrome/.test(userAgent);

    if ($.browser.chrome) {
        const versionStart = userAgent.indexOf('chrome/') + 7;
        $.browser.version = userAgent.substring(versionStart, userAgent.indexOf('.', versionStart));
        $.browser.safari = false;
    } else if ($.browser.safari) {
        const versionStart = userAgent.indexOf('safari/') + 7;
        $.browser.version = userAgent.substring(versionStart, userAgent.indexOf('.', versionStart));
    }

    $(document).ready(initApp);

    function initApp() {
        if (mt) {
            showMaintenanceScreen();
            return;
        }
        showGameScreen();
    }

    function showGameScreen() {
        const currentFlashVersion = swfobject.getFlashPlayerVersion();
        $("#noflash_reqVersion").html(flashVersion);
        $("#noflash_currentVersion").html(`${currentFlashVersion.major}.${currentFlashVersion.minor}.${currentFlashVersion.release}`);

        if (screen.availWidth <= 1250) {
            $("#nav").css("left", "220px");
        }
    }

    function getParameterByName(name) {
        name = name.replace(/[[\]]/g, "\\$&");
        const regex = new RegExp(`[?&]${name}=([^&#]*)`);
        const results = regex.exec(window.location.search);
        return results ? decodeURIComponent(results[1].replace(/\+/g, " ")) : "";
    }

    function getRefererParam(key) {
        key = key.replace(/[[\]]/g, "\\$&");
        const regex = new RegExp(`[?&]${key}=([^&#]*)`);
        const qs = regex.exec(document.referrer);
        return qs ? qs[1] : "";
    }

    function startGame(username, password) {
        $("#loading").css("display", "block");
        const flashVars = {
            path: "/game/",
            service: "pio",
            username: username,
            password: password,
            affiliate: getParameterByName("a"),
            useSSL: 0,
            gameId: "laststand-deadzone",
            connectionId: "public",
            clientAPI: "javascript",
            playerInsightSegments: [],
            playCodes: [],
            clientInfo: {
                platform: navigator.platform,
                userAgent: navigator.userAgent
            }
        };

        const params = {
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

        const attributes = { id: "game", name: "game" };

        $("#game_wrapper").height("0px");
        embedSWF("/game/preloader.swf", flashVars, params, attributes);
    }

    function startMigration(username, password) {
        $("#loading").css("display", "block");
        const flashVars = {
            path: "/migration/",
            core: "importClient.swf",
            migration: getParameterByName("migration"),
            service: "pio",
            username: username,
            password: password,
            affiliate: getParameterByName("a"),
            useSSL: 1,
            gameId: "laststand-deadzone",
            connectionId: "public",
            clientAPI: "javascript",
            playerInsightSegments: [],
            playCodes: [],
            clientInfo: {
                platform: navigator.platform,
                userAgent: navigator.userAgent
            }
        };

        const params = {
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

        const attributes = { id: "game", name: "game" };

        $("#game_wrapper").height("0px");
        embedSWF("/migration/preloader.swf", flashVars, params, attributes);
    }

    function embedSWF(swfURL, flashVars, params, attributes) {
        swfobject.embedSWF(
            swfURL,
            "game_container",
            "100%",
            "100%",
            flashVersion,
            "swf/expressinstall.swf",
            flashVars,
            params,
            attributes,
            (e) => {
                if (!e.success) {
                    showNoFlash();
                } else {
                    setMouseWheelState(false);
                }
            }
        );
    }

    function showMaintenanceScreen() {
        addMessage("maintenance", `The Last Stand: Dead Zone is down for scheduled maintenance. ETA ${mtPST} local time.`);
        showError("Scheduled Maintenance", `The Last Stand: Dead Zone is down for scheduled maintenance.<br/>We apologise for any inconvenience.<br/><br/><strong>ETA ${mtPST} local time</strong>`);
    }

    function showNoFlash() {
        $("#loading").css("display", "none");
        $("#noflash").css("display", "block");
        $("#game_wrapper").height("100%");
        $("#userID").html("");
    }

    function showError(title, message) {
        $("#loading").css("display", "none");
        $("#generic_error").css("display", "flex").html(`
            <div class="error-content">
                <h2>${title}</h2>
                <p>${message}</p>
                <div class="login-container">
                    <input type="text" id="username" placeholder="Username" />
                    <input type="password" id="password" placeholder="Password" />
                    <button onclick="handleLogin()">Login</button>
                </div>
            </div>
        `);
        $("#userID").html("");
    }

    function handleLogin() {
        const username = $("#username").val();
        const password = $("#password").val();
        if (username && password) {
            $("#generic_error").css("display", "none");
            getParameterByName("migration") ? startMigration(username, password) : startGame(username, password);
        } else {
            alert("Please enter both username and password.");
        }
    }

    function killGame() {
        $("#game, #game_container, #loading").remove();
        $("#content").prepend(`
            <div id='messagebox'>
                <div class='header'>Are you there?</div>
                <div class='msg'>You've left your compound unattended for some time. Are you still playing?</div>
                <div class='btn' onclick='refresh()'>BACK TO THE DEAD ZONE</div>
            </div>
        `);
    }

    function onPreloaderReady() {
        $("#loading").css("display", "none");
        $("#game_wrapper").height("100%");
    }

    function refresh() {
        location.reload();
    }

    function addMessage(id, message, showCloseButton, showSpinner = false) {
        const bar = $(`<div class="header_message_bar"></div>`).data("id", id);

        if (showCloseButton) {
            bar.append($("<div class='close'></div>").click(() => bar.stop(true, true).animate({ height: "toggle" }, 250)));
        }

        if (showSpinner) {
            bar.append($("<div class='loader'></div>"));
        }

        bar.append($(`<div class="header_message">${parseUTCStrings(message)}</div>`));
        $("#warning_container").append(bar.height("0px").animate({ height: "30px" }, 250));
        messages.push(bar);
    }

    function removeMessage(id) {
        messages.filter(msg => msg.data("id") === id).forEach(msg => {
            msg.stop(true).animate({ height: "toggle" }, 250);
        });
        messages = messages.filter(msg => msg.data("id") !== id);
    }

    function parseUTCStrings(msg) {
        return msg
            .replace(/\[\%UTC (\d{4})-(\d{2})-(\d{2}) (\d{2})-(\d{2})\]/ig, (_, y, m, d, h, min) => convertUTCtoLocal(y, m, d, h, min))
            .replace(/\[\%UTC (\d{2})-(\d{2})\]/ig, (_, h, min) => convertUTCtoLocal(0, 0, 0, h, min));
    }

    function convertUTCtoLocal(year, month, date, hours, mins) {
        const d = new Date();
        if (year > 0) d.setUTCFullYear(year, month-1, date);
        d.setUTCHours(hours);
        d.setUTCMinutes(mins);

        const months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
        let str = year > 0 ? `${months[d.getMonth()]} ${d.getDate()}, ${d.getFullYear()} ` : "";

        const displayHours = d.getHours() % 12 || 12;
        const displayMins = d.getMinutes().toString().padStart(2, "0");
        return `${str}${displayHours}:${displayMins}${d.getHours() < 12 ? "am" : "pm"}`;
    }

    let requestCodeRedeemInterval;
    let waitingForCodeRedeem = false;

    function openRedeemCodeDialogue() {
        updateNavClass("code");
        if (mt || waitingForCodeRedeem) return;

        const requestDialogue = () => {
            try {
                document.getElementById("game").openRedeemCode();
                removeMessage("openingCodeRedeem");
                updateNavClass(null);
                return true;
            } catch (err) {
                return false;
            }
        };

        if (!requestDialogue()) {
            addMessage("openingCodeRedeem", "Please wait while the game loads...", false, true);
            waitingForCodeRedeem = true;

            requestCodeRedeemInterval = setInterval(() => {
                if (requestDialogue()) {
                    waitingForCodeRedeem = false;
                    clearInterval(requestCodeRedeemInterval);
                }
            }, 1000);
        }
    }

    let requestGetMoreInterval;
    let waitingForGetMore = false;

    function openGetMoreDialogue() {
        updateNavClass("get_more");
        if (mt || waitingForGetMore) return;

        const requestDialogue = () => {
            try {
                if (document.getElementById("game").openGetMore()) {
                    removeMessage("openingFuel");
                    updateNavClass(null);
                    return true;
                }
            } catch (err) {}
            return false;
        };

        if (!requestDialogue()) {
            addMessage("openingFuel", "Opening Fuel Store, please wait while the game loads...", false, true);
            waitingForGetMore = true;

            requestGetMoreInterval = setInterval(() => {
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
            document.onmousewheel = () => preventWheel();
            if (document.addEventListener) {
                document.addEventListener("DOMMouseScroll", preventWheel, false);
            }
        }
    }

    function preventWheel(e = window.event) {
        if (e.preventDefault) {
            e.preventDefault();
        } else {
            e.returnValue = false;
        }
    }

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