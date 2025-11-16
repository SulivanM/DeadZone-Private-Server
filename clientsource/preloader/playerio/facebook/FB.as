package playerio.facebook
{
   import flash.events.*;
   import flash.external.*;
   import flash.net.*;
   import flash.system.*;
   
   public class FB
   {
      
      private static var allowedMethods:Object = {
         "GET":1,
         "POST":1,
         "DELETE":1,
         "PUT":1
      };
      
      private static var readOnlyCalls:Object = {
         "fql_query":1,
         "fql_multiquery":1,
         "friends_get":1,
         "notifications_get":1,
         "stream_get":1,
         "users_getinfo":1
      };
      
      private static var access_token:String = null;
      
      private static var app_id:String = null;
      
      private static var debug:Boolean = false;
      
      private static var uiFlashId:String = null;
      
      private static var uiCallbackId:Number = 0;
      
      private static var data:FBData = new FBData();
      
      private static var _formatRE:RegExp = /(\{[^\}^\{]+\})/g;
      
      private static var _trimRE:RegExp = /^\s*|\s*$/g;
      
      private static var _quoteRE:RegExp = /["\\\x00-\x1f\x7f-\x9f]/g;
      
      public function FB()
      {
         super();
      }
      
      public static function get Data() : FBData
      {
         return data;
      }
      
      public static function init(param1:*) : void
      {
         debug = !!param1.debug;
         app_id = param1.app_id;
         if((param1.access_token + "").length < 3)
         {
            error("You must supply the init method with an not-null access_token string.");
         }
         else
         {
            access_token = param1.access_token;
            log("Initializing with access_token: " + access_token);
         }
      }
      
      public static function api(... rest) : void
      {
         requireAccessToken("api");
         if(typeof rest[0] == "string")
         {
            graphCall.apply(null,rest);
         }
         else
         {
            restCall.apply(null,rest);
         }
      }
      
      public static function get uiAvailable() : Boolean
      {
         return initUI() == null;
      }
      
      public static function ui(param1:*, param2:Function) : void
      {
         var callbackId:String;
         var params:* = param1;
         var cb:Function = param2;
         var err:String = initUI();
         if(err != null)
         {
            error(err);
         }
         if(!params.method)
         {
            error("\"method\" is a required parameter for FB.ui().");
         }
         callbackId = "as_ui_callback_" + uiCallbackId++;
         ExternalInterface.addCallback(callbackId,function(param1:*):void
         {
            log("Got response from Javascript FB.ui: " + toString(param1));
            cb(param1);
         });
         ExternalInterface.call("__doFBUICall",uiFlashId,params,callbackId);
      }
      
      private static function initUI() : String
      {
         var allowsExternalInterface:Boolean = false;
         var hasJavascript:Boolean = false;
         var source:String = null;
         if(uiFlashId == null)
         {
            Security.allowDomain("*");
            allowsExternalInterface = false;
            try
            {
               allowsExternalInterface = ExternalInterface.call("eval","true");
            }
            catch(e:*)
            {
            }
            if(!allowsExternalInterface)
            {
               return "The flash element must not have allowNetworking = \'none\' in the containing page in order to call the FB.ui() method.";
            }
            hasJavascript = ExternalInterface.call("eval","typeof(FB)!=\'undefined\' && typeof(FB.ui)!=\'undefined\'");
            if(!hasJavascript)
            {
               return "The FB.ui() method can only be used when the containing page includes the Facebook Javascript SDK. Read more here: http://developers.facebook.com/docs/reference/javascript/FB.init";
            }
            uiFlashId = "flash_" + new Date().getTime() + Math.round(Math.random() * 9999999);
            ExternalInterface.addCallback("getFlashId",function():String
            {
               return uiFlashId;
            });
            source = "";
            source += "__doFBUICall = function(uiFlashId,params,callbackId){";
            source += " var find = function(tag){var list=document.getElementsByTagName(tag);for(var i=0;i!=list.length;i++){if(list[i].getFlashId&&list[i].getFlashId()==\"" + uiFlashId + "\"){return list[i]}}};";
            source += " var flashObj = find(\"embed\") || find(\"object\");";
            source += " if(flashObj != null){";
            source += "  FB.ui(params, function(response){";
            source += "   flashObj[callbackId](response);";
            source += "  })";
            source += " }else{alert(\"could not find flash element on the page w/ uiFlashId: " + uiFlashId + "\")}";
            source += "};";
            ExternalInterface.call("eval",source);
         }
         return null;
      }
      
      private static function graphCall(... rest) : void
      {
         var _loc7_:* = null;
         var _loc8_:String = null;
         var _loc2_:String = null;
         var _loc3_:* = null;
         var _loc4_:Function = null;
         var _loc5_:String = rest.shift();
         var _loc6_:* = rest.shift();
         while(_loc6_)
         {
            _loc7_ = typeof _loc6_;
            if(_loc7_ === "string" && _loc2_ == null)
            {
               _loc8_ = _loc6_.toUpperCase();
               if(allowedMethods[_loc8_])
               {
                  _loc2_ = _loc8_;
               }
               else
               {
                  error("Invalid method passed to FB.api(" + _loc5_ + "): " + _loc6_);
               }
            }
            else if(_loc7_ === "function" && _loc4_ == null)
            {
               _loc4_ = _loc6_;
            }
            else if(_loc7_ === "object" && _loc3_ == null)
            {
               _loc3_ = _loc6_;
            }
            else
            {
               error("Invalid argument passed to FB.api(" + _loc5_ + "): " + _loc6_);
            }
            _loc6_ = rest.shift();
         }
         _loc2_ ||= "GET";
         _loc3_ ||= {};
         log("Graph call: path=" + _loc5_ + ", method=" + _loc2_ + ", params=" + toString(_loc3_));
         oauthRequest("https://graph.facebook.com" + _loc5_,_loc2_,_loc3_,_loc4_);
      }
      
      private static function restCall(param1:*, param2:Function) : void
      {
         var _loc3_:String = (param1.method + "").toLowerCase().replace(".","_");
         param1.format = "json-strings";
         param1.api_key = app_id;
         log("REST call: method=" + _loc3_ + ", params=" + toString(param1));
         oauthRequest("https://" + (readOnlyCalls[_loc3_] ? "api-read" : "api") + ".facebook.com/restserver.php","get",param1,param2);
      }
      
      private static function oauthRequest(param1:String, param2:String, param3:*, param4:Function) : void
      {
         var x:* = undefined;
         var loader:URLLoader = null;
         var url:String = param1;
         var method:String = param2;
         var params:* = param3;
         var cb:Function = param4;
         var request:URLRequest = new URLRequest(url);
         request.method = method;
         request.data = new URLVariables();
         request.data.access_token = access_token;
         for(x in params)
         {
            request.data[x] = params[x];
         }
         request.data.callback = "c";
         loader = new URLLoader();
         loader.addEventListener(Event.COMPLETE,function(param1:Event):void
         {
            var _loc2_:String = loader.data;
            _loc2_ = _loc2_.replace(/\/\*\*\/\s*/ig,"");
            if(_loc2_.length > 2 && _loc2_.indexOf("c(") == 0)
            {
               _loc2_ = loader.data.substring(loader.data.indexOf("(") + 1,loader.data.lastIndexOf(")"));
            }
            var _loc3_:* = JSON.parse(_loc2_);
            if(url.substring(0,11) == "https://api")
            {
               log("REST call result, method=" + params.method + " => " + toString(_loc3_));
            }
            else
            {
               log("Graph call result, path=" + url + " => " + toString(_loc3_));
            }
            cb(_loc3_);
         });
         loader.addEventListener(IOErrorEvent.IO_ERROR,function(param1:IOErrorEvent):void
         {
            error("Error in response from Facebook api servers, most likely cause is expired or invalid access_token. Error message: " + param1.text);
         });
         loader.load(request);
      }
      
      private static function requireAccessToken(param1:String) : void
      {
         if(access_token == null)
         {
            error("You must call FB.init({access_token:\"...\") before attempting to call FB." + param1 + "()");
         }
      }
      
      private static function error(param1:String) : void
      {
         if(debug)
         {
         }
         throw new Error(param1);
      }
      
      private static function log(param1:String) : void
      {
         if(debug)
         {
         }
      }
      
      public static function toString(param1:*) : String
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:Boolean = false;
         var _loc5_:Boolean = false;
         var _loc6_:* = undefined;
         if(param1 == null)
         {
            return "[null]";
         }
         switch(typeof param1)
         {
            case "object":
               _loc2_ = "{";
               _loc3_ = "[";
               _loc4_ = true;
               _loc5_ = false;
               for(_loc6_ in param1)
               {
                  _loc2_ += (_loc2_ == "{" ? "" : ", ") + _loc6_ + "=" + toString(param1[_loc6_]);
                  _loc3_ += (_loc3_ == "[" ? "" : ", ") + toString(param1[_loc6_]);
                  if(typeof _loc6_ != "number")
                  {
                     _loc4_ = false;
                  }
                  _loc5_ = true;
               }
               return _loc4_ && _loc5_ ? _loc3_ + "]" : _loc2_ + "}";
            case "string":
               return "\"" + param1.replace("\n","\\n").replace("\r","\\r") + "\"";
            default:
               return param1 + "";
         }
      }
      
      internal static function stringTrim(param1:String) : String
      {
         return param1.replace(_trimRE,"");
      }
      
      internal static function stringFormat(param1:String, ... rest) : String
      {
         var format:String = param1;
         var args:Array = rest;
         return format.replace(_formatRE,function(param1:String, param2:String, param3:int, param4:String):String
         {
            param3 = parseInt(param2.substr(1),10);
            var _loc5_:* = args[param3];
            if(_loc5_ === null || typeof _loc5_ == "undefined")
            {
               return "";
            }
            return _loc5_.toString();
         });
      }
      
      internal static function stringQuote(param1:String) : String
      {
         var subst:Object = null;
         var value:String = param1;
         subst = {
            "\b":"\\b",
            "\t":"\\t",
            "\n":"\\n",
            "\f":"\\f",
            "\r":"\\r",
            "\"":"\\\"",
            "\\":"\\\\"
         };
         return _quoteRE.test(value) ? "\"" + value.replace(_quoteRE,function(param1:String):String
         {
            var _loc2_:* = subst[param1];
            if(_loc2_)
            {
               return _loc2_;
            }
            _loc2_ = param1.charCodeAt();
            return "\\u00" + Math.floor(_loc2_ / 16).toString(16) + (_loc2_ % 16).toString(16);
         }) + "\"" : "\"" + value + "\"";
      }
      
      internal static function arrayIndexOf(param1:Array, param2:*) : int
      {
         var _loc4_:int = 0;
         var _loc3_:uint = param1.length;
         if(_loc3_)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               if(param1[_loc4_] === param2)
               {
                  return _loc4_;
               }
               _loc4_++;
            }
         }
         return -1;
      }
      
      internal static function arrayMerge(param1:Array, param2:Array) : Array
      {
         var _loc3_:int = 0;
         while(_loc3_ < param2.length)
         {
            if(arrayIndexOf(param1,param2[_loc3_]) < 0)
            {
               param1.push(param2[_loc3_]);
            }
            _loc3_++;
         }
         return param1;
      }
      
      internal static function arrayMap(param1:Array, param2:Function) : Array
      {
         var _loc3_:Array = [];
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            _loc3_.push(param2(param1[_loc4_]));
            _loc4_++;
         }
         return _loc3_;
      }
      
      internal static function arrayFilter(param1:Array, param2:Function) : Array
      {
         var _loc3_:Array = [];
         var _loc4_:int = 0;
         while(_loc4_ < param1.length)
         {
            if(param2(param1[_loc4_]))
            {
               _loc3_.push(param1[_loc4_]);
            }
            _loc4_++;
         }
         return _loc3_;
      }
      
      internal static function objCopy(param1:Object, param2:Object, param3:Boolean, param4:Function) : Object
      {
         var _loc5_:String = null;
         for(_loc5_ in param2)
         {
            if(param3 || typeof param1[_loc5_] == "undefined")
            {
               param1[_loc5_] = typeof param4 == "function" ? param4(param2[_loc5_]) : param2[_loc5_];
            }
         }
         return param1;
      }
      
      internal static function forEach(param1:*, param2:Function) : void
      {
         var _loc3_:uint = 0;
         var _loc4_:* = undefined;
         if(!param1)
         {
            return;
         }
         if(param1 is Array)
         {
            _loc3_ = 0;
            while(_loc3_ != param1.length)
            {
               param2(param1[_loc3_],_loc3_,param1);
               _loc3_++;
            }
         }
         else if(param1 is Object)
         {
            for(_loc4_ in param1)
            {
               param2(param1[_loc4_],_loc4_,param1);
            }
         }
      }
   }
}

