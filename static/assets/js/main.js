var flashVersion = "11.3.300.271";
var messages = [];
var unloadMessage = "";
var mt = false;
var mtPST = "00:00";

let debounceTimeout;
let usernameTimer;
let TOKEN_REFRESH_INTERVAL = 50 * 60 * 1000; // 50 minutes
let isUsernameValid = false;
let isPasswordValid = false;

$(document).ready(function () {
  if (mt) {
    showMaintenanceScreen();
  } else {
    showGameScreen();
  }

  updateSubmitButton();

  const initialUsername = $("#username").val();
  if (initialUsername) {
    if (validateUsername(initialUsername)) {
      clearTimeout(usernameTimer);
      usernameTimer = setTimeout(() => {
        doesUserExist(initialUsername);
      }, 500);
    }
  }

  $("#username").on("input", function () {
    const value = $(this).val();

    clearTimeout(debounceTimeout);
    $(".username-info").text("");
    debounceTimeout = setTimeout(() => {
      if (validateUsername(value)) {
        clearTimeout(usernameTimer);
        usernameTimer = setTimeout(() => {
          doesUserExist(value);
        }, 500);
      }

      // revalidate username. this must be done if username was initially admin
      const currentPassword = $("#password").val();
      validatePassword(currentPassword);
    }, 500);
  });

  $("#password").on("input", function () {
    const value = $(this).val();

    clearTimeout(debounceTimeout);
    $(".password-info").text("");
    debounceTimeout = setTimeout(() => {
      validatePassword(value);
    }, 500);
  });

  $("#pio-login").submit(function (event) {
    event.preventDefault();
    var username = $("#username").val();
    var password = $("#password").val();
    login(username, password).then((success) => {
      if (success) {
        startGame(window.token);
      }
    });
  });

  if (window.token != null || window.token != "") {
    setInterval(refreshSession, TOKEN_REFRESH_INTERVAL);
  }
});

function updateSubmitButton() {
  const btn = $("#login-button");
  if (isUsernameValid && isPasswordValid) {
    btn.prop("disabled", false).removeClass("disabled");
  } else {
    btn.prop("disabled", true).addClass("disabled");
  }
}

function validateUsername(username) {
  const usernameRegex = /^[a-zA-Z0-9]+$/;
  const badwords = ["dick"]; // expand as needed
  const infoDiv = $(".username-info");

  if (username.length < 6 || !usernameRegex.test(username)) {
    infoDiv
      .text(
        "Username must be at least 6 characters. Only letters and digits allowed."
      )
      .css("color", "red");
    isUsernameValid = false;
    updateSubmitButton();
    return false;
  }

  if (badwords.some((bad) => username.toLowerCase().includes(bad))) {
    infoDiv
      .text("Possible badword detected. Please choose another name.")
      .css("color", "orange");
    isUsernameValid = false;
    updateSubmitButton();
    return false;
  }

  infoDiv.text("Checking to server...").css("color", "orange");
  return true;
}

function doesUserExist(username) {
  fetch(`/api/userexist?username=${encodeURIComponent(username)}`, {
    method: "GET",
    headers: {
      "Content-Type": "text/plain",
    },
  })
    .then(async (response) => {
      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.reason || "User check failed");
      }
      return response.text();
    })
    .then((result) => {
      const infoDiv = $(".username-info");

      if (result === "granted") {
        infoDiv
          .text("Admin account available. You will log in as admin.")
          .css("color", "green");
        isUsernameValid = true;
      } else if (result === "reserved") {
        infoDiv
          .text("Admin account is disabled on this server.")
          .css("color", "red");
        isUsernameValid = false;
      } else if (result === "yes") {
        infoDiv
          .text(
            "Username already exists. Input the correct password if you are trying to log in."
          )
          .css("color", "#7a8bac");
        infoDiv.append(
          '<p style="color:#b86b5f">If you are trying to register, choose another name.</p>'
        );
        isUsernameValid = true;
      } else if (result == "no") {
        infoDiv
          .text("Username is available, you will be registered.")
          .css("color", "green");
        isUsernameValid = true;
      }

      updateSubmitButton();
    })
    .catch((error) => {
      console.error("Error:", error.reason);
      $(".username-info").text("Error checking username").css("color", "red");
    });
}

function validatePassword(password) {
  const infoDiv = $(".password-info");
  const username = $("#username").val();

  if (username === "givemeadmin") {
    isPasswordValid = true;
    updateSubmitButton();
    return;
  }

  if (password.length >= 6) {
    infoDiv.text("Password is fine.").css("color", "green");
    isPasswordValid = true;
  } else {
    infoDiv.text("Password must be at least 6 characters.").css("color", "red");
    isPasswordValid = false;
  }
  updateSubmitButton();
}

function login(username, password) {
  const loginDiv = $(".login-info");
  loginDiv.text("Logging in...").css("color", "orange");

  return fetch("/api/login", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ username: username, password: password }),
  })
    .then(async (response) => {
      if (!response.ok) {
        const error = await response.json();
        loginDiv.text(`Login failed: ${error.reason}`).css("color", "red");
        return false;
      }
      return response.json();
    })
    .then((data) => {
      if (!data || !data.token) return false;

      window.token = data.token;
      loginDiv
        .text("Login success, now getting you in...")
        .css("color", "green");
      return true;
    })
    .catch((error) => {
      console.error("Login error:", error.reason);
      $(".error-reason")
        .text("Unexpected error during login")
        .css("color", "red");
      return false;
    });
}

function refreshSession() {
  let ss = $(".server-status");

  fetch(`/keepalive?token=${SESSION_TOKEN}`)
    .then((response) => {
      if (response.status === 200) {
      } else if (response.status === 401) {
        ss.text("Session expired, login again.").css("color", "red");
      } else {
        console.error("Unexpected error during keepalive.");
      }
    })
    .catch((err) => {
      console.error("Keepalive request failed:", err);
    });
}

function showGameScreen() {
  var a = swfobject.getFlashPlayerVersion();
  $("#noflash-reqVersion").html(flashVersion);
  $("#noflash-currentVersion").html(a.major + "." + a.minor + "." + a.release);
  if (screen.availWidth <= 1250) {
    $("#nav").css("left", "220px");
  }
}

function startGame(token) {
  $("#loading").css("display", "block");
  const flashVars = {
    path: "/game/",
    service: "pio",
    // username: username,
    // password: password,
    affiliate: getParameterByName("a"),
    useSSL: 0,
    // core: "core.swf",
    gameId: "laststand-deadzone",
    connectionId: "public",
    clientAPI: "javascript",
    playerInsightSegments: [],
    playCodes: [],
    userToken: token,
    // local: 0,
    clientInfo: {
      platform: navigator.platform,
      userAgent: navigator.userAgent,
    },
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
    bgColor: "#000000",
  };

  const attributes = { id: "game", name: "game" };

  $("#game-wrapper").height("0px");
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
      userAgent: navigator.userAgent,
    },
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
    bgColor: "#000000",
  };

  const attributes = { id: "game", name: "game" };

  $("#game-wrapper").height("0px");
  embedSWF("/migration/preloader.swf", flashVars, params, attributes);
}

function embedSWF(swfURL, flashVars, params, attributes) {
  swfobject.embedSWF(
    swfURL,
    "game-container",
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
  var maintenanceMessage =
    "The Last Stand: Dead Zone is down for scheduled maintenance. ETA " +
    mtPST +
    " local time.";
  addMessage("maintenance", maintenanceMessage);
  showError(
    "Scheduled Maintenance",
    "The Last Stand: Dead Zone is down for scheduled maintenance.<br/>We apologize for any inconvenience.<br/><br/><strong>ETA " +
      mtPST +
      " local time</strong>"
  );
}

function showNoFlash() {
  $("#loading").remove();
  $("#noflash").css("display", "block");
  $("#game-wrapper").height("100%");
  $("#user-id").html("");
}

function showError(b, a) {
  $("#loading").remove();
  $("#generic-error").css("display", "block");
  $("#generic-error").html("<p><h2>" + b + "</h2></p><p>" + a + "</p>");
  $("#user-id").html("");
}

function killGame() {
  $("#game").remove();
  $("#game-container").remove();
  $("#loading").remove();
  $("#content").prepend(
    "<div id='messagebox'><div class='header'>Are you there?</div><div class='msg'>You've left your compound unattended for some time. Are you still playing?</div><div class='btn' onclick='refresh()'>BACK TO THE DEAD ZONE</div></div>"
  );
}

function onPreloaderReady() {
  $("#loading").remove();
  $("#game-wrapper").height("100%");
}

function onFlashHide(c) {
  if (c.state == "opened") {
    var b = document.getElementById("game").getScreenshot();
    if (b != null) {
      $("#content").append(
        "<img id='screenshot' style='position:absolute; top:120px; width:960px; height:804px;' src='data:image/jpeg;base64," +
          b +
          "'/>"
      );
    }
  } else {
    var a = $("#screenshot");
    if (a != null) {
      a.remove();
    }
  }
}

function showFlash() {
  $("#showGame").remove();
  FB.Canvas.showFlashElement(document.getElementById("game"));
}

function refresh() {
  location.reload();
}

function addMessage(h, f, g, b) {
  var e = $('<div class="header-message-bar"></div>');
  e.data("id", h);
  if (g) {
    var c = $('<div class="close"></div>').click(function () {
      e.stop(true, true).animate({ height: "toggle" }, 250);
    });
    e.append(c);
  }
  if (b) {
    var a = $('<div class="loader"></div>');
    e.append(a);
  }
  f = parseUTCStrings(f);
  var d = $('<div class="header-message">' + f + "</div>");
  e.append(d);
  $("#warning-container").append(e);
  e.height("0px").animate({ height: "30px" }, 250);
  messages.push(e);
}

function removeMessage(c) {
  for (var a = messages.length - 1; a >= 0; a--) {
    var b = messages[a];
    if (b.data("id") == c) {
      b.stop(true).animate({ height: "toggle" }, 250);
      messages.splice(a, 1);
    }
  }
}

function parseUTCStrings(a) {
  reg = /\[\%UTC (\d{4})\-(\d{2})\-(\d{2}) (\d{2})\-(\d{2})\]/gi;
  while ((seg = reg.exec(a))) {
    a = a.replace(
      seg[0],
      convertUTCtoLocal(
        Number(seg[1]),
        Number(seg[2]),
        Number(seg[3]),
        Number(seg[4]),
        Number(seg[5])
      )
    );
  }
  reg = /\[\%UTC (\d{2})\-(\d{2})\]/gi;
  while ((seg = reg.exec(a))) {
    a = a.replace(
      seg[0],
      convertUTCtoLocal(0, 0, 0, Number(seg[1]), Number(seg[2]))
    );
  }
  return a;
}

function convertUTCtoLocal(c, f, b, a, e) {
  var h = new Date();
  if (c > 0) {
    h.setUTCFullYear(c, f - 1, b);
  }
  h.setUTCHours(a);
  h.setUTCMinutes(e);
  var g = "";
  if (c > 0) {
    months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    g = months[h.getMonth()] + " " + h.getDate() + ", " + h.getFullYear() + " ";
  }
  g +=
    (h.getHours() <= 12 ? h.getHours() : h.getHours() - 12) +
    ":" +
    (h.getMinutes() < 10 ? "0" + h.getMinutes() : h.getMinutes()) +
    (h.getHours() < 12 ? "am" : "pm");
  return g;
}

var requestCodeRedeemInterval;
var waitingForCodeRedeem = false;

function openRedeemCodeDialogue() {
  updateNavClass("code");
  if (mt || waitingForCodeRedeem) {
    return;
  }
  var a = function () {
    try {
      document.getElementById("game").openRedeemCode();
      removeMessage("openingCodeRedeem");
      updateNavClass(null);
      return true;
    } catch (b) {}
    return false;
  };
  if (!a()) {
    addMessage(
      "openingCodeRedeem",
      "Please wait while the game loads...",
      false,
      true
    );
    waitingForCodeRedeem = true;
    requestCodeRedeemInterval = setInterval(function () {
      if (a()) {
        waitingForCodeRedeem = false;
        clearInterval(requestCodeRedeemInterval);
      }
    }, 1000);
  }
}

var requestGetMoreInterval;
var waitingForGetMore = false;

function openGetMoreDialogue() {
  updateNavClass("get-more");
  if (mt || waitingForGetMore) {
    return;
  }
  var a = function () {
    try {
      if (document.getElementById("game").openGetMore()) {
        removeMessage("openingFuel");
        updateNavClass(null);
        return true;
      }
    } catch (b) {}
    return false;
  };
  if (!a()) {
    addMessage(
      "openingFuel",
      "Opening Fuel Store, please wait while the game loads...",
      false,
      true
    );
    waitingForGetMore = true;
    requestGetMoreInterval = setInterval(function () {
      if (a()) {
        waitingForGetMore = false;
        clearInterval(requestGetMoreInterval);
      }
    }, 1000);
  }
}

function updateNavClass(a) {
  $("#nav-ul")[0].className = a;
}

function setMouseWheelState(a) {
  if (a) {
    document.onmousewheel = null;
    if (document.addEventListener) {
      document.removeEventListener("DOMMouseScroll", preventWheel, false);
    }
  } else {
    document.onmousewheel = function () {
      preventWheel();
    };
    if (document.addEventListener) {
      document.addEventListener("DOMMouseScroll", preventWheel, false);
    }
  }
}

function preventWheel(a) {
  if (!a) {
    a = window.event;
  }
  if (a.preventDefault) {
    a.preventDefault();
  } else {
    a.returnValue = false;
  }
}

function setBeforeUnloadMessage(a) {
  unloadMessage = a;
  $(window).bind("beforeunload", handleUnload);
  return true;
}

function clearBeforeUnloadMessage() {
  unloadMessage = "";
  $(window).unbind("beforeunload", handleUnload);
  return true;
}

function handleUnload() {
  return unloadMessage;
}

function getParameterByName(b) {
  b = b.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
  var a = "[\\?&]" + b + "=([^&#]*)";
  var d = new RegExp(a);
  var c = d.exec(window.location.search);
  if (c == null) {
    return "";
  } else {
    return decodeURIComponent(c[1].replace(/\+/g, " "));
  }
}
