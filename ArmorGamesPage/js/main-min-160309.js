console.log("sev >> " + document.referrer + " " + window.location);

var flashVersion = "11.3";
var messages = [];
var unloadMessage = "";

// Setup safari/chrome user agent detection
var userAgent = navigator.userAgent.toLowerCase(); 
$.browser.chrome = /chrome/.test(navigator.userAgent.toLowerCase()); 

if ($.browser.chrome) {
	userAgent = userAgent.substring(userAgent.indexOf('chrome/') +7);
	userAgent = userAgent.substring(0,userAgent.indexOf('.'));
	$.browser.version = userAgent;
	$.browser.safari = false;
}

if ($.browser.safari) {
	userAgent = userAgent.substring(userAgent.indexOf('safari/') +7);
	userAgent = userAgent.substring(0,userAgent.indexOf('.'));
	$.browser.version = userAgent;
}

$("document").ready(function() {
	if (mt) {
		showMaintenanceScreen();
		return;
	}

	$.ajax({
		url: "bridge.php",
		type: "GET",
		data: {
			service: "armor"
		},
		dataType: "json",
		timeout: 5000,
		cache: false,
		success: function(json) {
			// test if you should display the game or maintaince message
			if (json == null) {
				// Default to showing the game if the request fails
				showGameScreen();
				return;
			}
			
			var obj = json.services[0];
			if (obj.mode == 2) {
				// convert the eta time to a local time
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

				mtPST = (hrs < 10 ? "0" + hrs : hrs) +":"+ (mins < 10 ? "0" + mins : mins);
				showMaintenanceScreen();
			} else { 
				showGameScreen();
			}

			// if there is a message in the status, then display that now
			if (obj.htmlMessage && obj.htmlMessage != "")
				addMessage("statusMessage", obj.htmlMessage, true);			
		},
		error: function(xhr, status) {
			// display the game as usual on error
			showGameScreen();
		}
	})
});

function showGameScreen() {
	// Update required/current version text
	var currentFlashVersion = swfobject.getFlashPlayerVersion();
	$("#noflash_reqVersion").html(flashVersion);
	$("#noflash_currentVersion").html(currentFlashVersion.major + "." + currentFlashVersion.minor + "." + currentFlashVersion.release);
	
	if(getRefererParam("migration")!="")
	{
		startMigration();
	}
	else
	{
		startGame();
	}

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

function getRefererParam(key)
{
  key = key.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
  var regex = new RegExp("[\\?&]"+key+"=([^&#]*)");
  var qs = regex.exec(document.referrer);
  if(qs == null)
    return "";
  else
    return qs[1];
}

function startGame(accessToken) {
	var flashVars = {
		path: "/game/",
        service: "fb",
        accessToken,
        affiliate: getParameterByName("a"),
        useSSL: window.location.protocol === "http:" ? "0" : "1"
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
		id: "deadzonegame",	
		name: "deadzonegame"
	};

	$("#game_wrapper").height("0px");

	var swfURL = "http://localhost/game/preloader.swf";
	swfobject.embedSWF(swfURL, "game_container", "100%", "100%", flashVersion, "swf/expressinstall.swf", flashVars, params, attributes, function(e)	{
		if (!e.success)
		{
			showNoFlash();
		}
		else
		{
			setMouseWheelState(false);
		}
	});
}

function startMigration() {

	var migrationStr = getRefererParam("migration");


	var flashVars = {
		path: "/migration/",
		core: "importClient.swf",
		migration: migrationStr,
		service: "armor",
		userId: getParameterByName("user_id"),
		accessToken: getParameterByName("auth_token"),
		//useSSL: ("http:" == document.location.protocol ? "1" : "0")
		useSSL: 0,
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
		id: "deadzonegame",	
		name: "deadzonegame"
	};

	$("#game_wrapper").height("0px");

	var swfURL = "http://localhost/migration/preloader.swf";
	swfobject.embedSWF(swfURL, "game_container", "100%", "100%", flashVersion, "swf/expressinstall.swf", flashVars, params, attributes, function(e)	{
		if (!e.success)
		{
			showNoFlash();
		}
		else
		{
			setMouseWheelState(false);
		}
	});
}

function showMaintenanceScreen() {
	$("#userID").html("");
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
	$("#generic_error").html("<h2>" + title + "</h2></p><p>" + message);
}

function killGame() {
	$("#deadzonegame").remove();
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

function refresh() {
	location.reload();
}

function setUserId(id) {
	$("#userID").html("User Id: " + id);
}

function openWindow(url, target) {
	if (!target)
		target = "_blank";

	window.open(url, target);
	window.focus();
}

function addMessage(id, message, showCloseButton, showSpinner) {
	var bar = $("<div class=\"header_message_bar\"></div>");
	bar.data("id", id);

	if (showCloseButton) {
		var closeDiv = $("<div class=\"close\"></div>").click(function()
		{
			bar.stop(true, true).animate( { height: "toggle" }, 250);
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

	// Animate bar
	bar.height("0px").animate( { height: "30px" }, 250);
	messages.push(bar);
}

function removeMessage(id) {
	for (var i =  messages.length - 1; i >= 0; i--) {
		var msg = messages[i];
		if (msg.data("id") == id) {
			msg.stop(true).animate( { height: "toggle" }, 250);
			messages.splice(i, 1);
		}
	}
}

function parseUTCStrings(msg)
{
	reg = /\[\%UTC (\d{4})\-(\d{2})\-(\d{2}) (\d{2})\-(\d{2})\]/ig;
	while (seg = reg.exec(msg))
	{
		msg = msg.replace(seg[0], convertUTCtoLocal(Number(seg[1]), Number(seg[2]), Number(seg[3]), Number(seg[4]), Number(seg[5])));
	}
	reg = /\[\%UTC (\d{2})\-(\d{2})\]/ig;
	while (seg = reg.exec(msg))
	{
		//alert("found short " + seg[0])
		msg = msg.replace(seg[0], convertUTCtoLocal(0,0,0,Number(seg[1]), Number(seg[2])));
	}
	return msg;
}

function convertUTCtoLocal(year, month, date, hours, mins)
{
	var d = new Date();
	if (year > 0)
		d.setUTCFullYear(year, month-1, date);
	d.setUTCHours(hours);
	d.setUTCMinutes(mins);
	
	var str = "";
	if (year > 0)
	{
		months = ["Jan","Feb", "Mar", "Apr","May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
		str = months[d.getMonth()] + " " + d.getDate() + ", " + d.getFullYear() + " ";
	}
	str += (d.getHours() <= 12 ? d.getHours() : d.getHours() - 12) + ":" + (d.getMinutes() < 10 ? "0"+d.getMinutes() : d.getMinutes()) + (d.getHours() < 12 ? "am" : "pm");
	return str;
}


var requestCodeRedeemInterval;
var waitingForCodeRedeem = false;

function openRedeemCodeDialogue() {

	if (mt || waitingForCodeRedeem)
		return;

	var requestDialogue = function() {
		try {
			document.getElementById("deadzonegame").openRedeemCode();
			removeMessage("openingCodeRedeem");
			return true;
		}
		catch (err) { }
		return false;
	};

	if (!requestDialogue()) {
		addMessage("openingCodeRedeem", "Please wait while the game loads...", false, true);

		waitingForCodeRedeem = true;
		requestCodeRedeemInterval = setInterval(function() {
			if (requestDialogue())
			{
				waitingForCodeRedeem = false;
				clearInterval(requestCodeRedeemInterval);
			}
		}, 1000);
	}
}

var requestGetMoreInterval;
var waitingForGetMore = false;

function openGetMoreDialogue() {

	if (mt || waitingForGetMore)
		return;

	var requestDialogue = function() {
		try {
			if (document.getElementById("deadzonegame").openGetMore()) {
				removeMessage("openingFuel");
				return true;
			}
		}
		catch (err) { }
		return false;
	};

	if (!requestDialogue()) {
		addMessage("openingFuel", "Opening Fuel store, please wait while the game loads...", false, true);

		waitingForGetMore = true;
		requestGetMoreInterval = setInterval(function() {
			if (requestDialogue())
			{
				waitingForGetMore = false;
				clearInterval(requestGetMoreInterval);
			}
		}, 1000);
	}
}

function setMouseWheelState(state)
{
	if (state) {
		document.onmousewheel = null;  /* IE7, IE8 */
		if(document.addEventListener){ /* Chrome, Safari, Firefox */
			document.removeEventListener("DOMMouseScroll", preventWheel, false);
		}		
	} else {
		document.onmousewheel = function(){ preventWheel(); } /* IE7, IE8 */
		if(document.addEventListener) { /* Chrome, Safari, Firefox */
			document.addEventListener("DOMMouseScroll", preventWheel, false);
		}
	}
}

function preventWheel(e) {
	if(!e) { e = window.event; } /* IE7, IE8, Chrome, Safari */
	if(e.preventDefault) { e.preventDefault(); } /* Chrome, Safari, Firefox */
	e.returnValue = false; /* IE7, IE8 */
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

function handlePayment(success, item) {
	// Execute callback in Flash application
	document.getElementById("deadzonegame").handlePayment(success, item);
}
