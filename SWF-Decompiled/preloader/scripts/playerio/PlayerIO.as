package playerio
{
   import flash.display.Stage;
   import playerio.generated.PlayerIO;
   import playerio.generated.PlayerIOError;
   import playerio.generated.messages.AuthenticateStartDialog;
   import playerio.generated.messages.KeyValuePair;
   import playerio.generated.messages.PlayerInsightState;
   import playerio.utils.HTTPChannel;
   import playerio.utils.Utilities;
   
   public final class PlayerIO extends playerio.generated.PlayerIO
   {
      public namespace inside = "http://playerio.com/inside/";
      
      public static var useSecureApiRequests:Boolean = false;
      
      public function PlayerIO()
      {
         super();
      }
      
      internal static function _internal_getChannel() : HTTPChannel
      {
         return new HTTPChannel(useSecureApiRequests);
      }
      
      public static function connect(param1:Stage, param2:String, param3:String, param4:String, param5:String, param6:* = null, param7:* = null, param8:* = null, param9:* = null) : void
      {
         new playerio.PlayerIO().connect(param1,param2,param3,param4,param5,param6,param7,param8,param9);
      }
      
      public static function authenticate(param1:Stage, param2:String, param3:String, param4:Object, param5:* = null, param6:* = null, param7:* = null) : void
      {
         new playerio.PlayerIO().authenticate(param1,param2,param3,param4,param5,param6,param7);
      }
      
      private static function authSuccess(param1:Client, param2:HTTPChannel, param3:Array, param4:Function) : void
      {
         var dialog:AuthenticateStartDialog;
         var dialogArgs:Object;
         var a:int;
         var kvp:KeyValuePair;
         var client:Client = param1;
         var channel:HTTPChannel = param2;
         var dialogs:Array = param3;
         var successCallback:Function = param4;
         if(dialogs == null || dialogs.length == 0)
         {
            if(successCallback != null)
            {
               successCallback(client);
            }
         }
         else
         {
            dialog = dialogs[0];
            dialogArgs = {};
            if(dialog.arguments != null)
            {
               a = 0;
               while(a < dialog.arguments.length)
               {
                  kvp = dialog.arguments[a] as KeyValuePair;
                  dialogArgs[kvp.key] = kvp.value;
                  a++;
               }
            }
            PublishingNetworkDialog.showDialog(dialog.name,dialogArgs,channel,function(param1:Object):void
            {
               dialogs.shift();
               authSuccess(client,channel,dialogs,successCallback);
            });
         }
      }
      
      public static function get quickConnect() : QuickConnect
      {
         return new QuickConnect(_internal_getChannel());
      }
      
      public static function gameFS(param1:String) : GameFS
      {
         return new GameFS(param1,null);
      }
      
      private function connect(param1:Stage, param2:String, param3:String, param4:String, param5:String, param6:* = null, param7:* = null, param8:* = null, param9:* = null) : void
      {
         var stage:Stage = param1;
         var gameId:String = param2;
         var connectionId:String = param3;
         var userId:String = param4;
         var auth:String = param5;
         var partnerId:* = param6;
         var playerInsightSegments:* = param7;
         var callback:* = param8;
         var errorHandler:* = param9;
         if(partnerId is Function)
         {
            connect(stage,gameId,connectionId,userId,auth,null,null,partnerId,playerInsightSegments);
            return;
         }
         if(playerInsightSegments is Function)
         {
            connect(stage,gameId,connectionId,userId,auth,partnerId,null,playerInsightSegments,callback);
            return;
         }
         _connect(_internal_getChannel(),gameId,connectionId,userId,auth,partnerId,playerInsightSegments,Utilities.clientAPI,Utilities.getSystemInfo(),function(param1:String, param2:String, param3:Boolean, param4:String, param5:String, param6:PlayerInsightState):void
         {
            if(stage && param3 && Minilogo.showLogo)
            {
               stage.addChild(new Minilogo());
            }
            var _loc7_:HTTPChannel = _internal_getChannel();
            _loc7_.token = param1;
            callback(new Client(stage,_loc7_,gameId,param4,param1,userId,param3,param6));
         },errorHandler);
      }
      
      private function authenticate(param1:Stage, param2:String, param3:String, param4:Object, param5:Array, param6:Function, param7:Function) : void
      {
         var stage:Stage = param1;
         var gameId:String = param2;
         var connectionId:String = param3;
         var authenticationArguments:Object = param4;
         var playerInsightSegments:Array = param5;
         var callback:Function = param6;
         var errorHandler:Function = param7;
         if(authenticationArguments["publishingnetworklogin"] != undefined && authenticationArguments["publishingnetworklogin"] == "auto")
         {
            PublishingNetworkDialog.showDialog("login",{
               "gameId":gameId,
               "connectionId":connectionId,
               "__use_usertoken__":"true"
            },null,function(param1:Object):void
            {
               if(param1["error"] != undefined)
               {
                  errorHandler(new playerio.generated.PlayerIOError(param1["error"],playerio.PlayerIOError.GeneralError.errorID));
               }
               else if(param1["userToken"] == undefined)
               {
                  errorHandler(new playerio.generated.PlayerIOError("Missing userToken value in result, but no error message given.",playerio.PlayerIOError.GeneralError.errorID));
               }
               else
               {
                  authenticate(stage,gameId,connectionId,{"userToken":param1["userToken"]},playerInsightSegments,callback,errorHandler);
               }
            });
            return;
         }
         _authenticate(_internal_getChannel(),gameId,connectionId,authenticationArguments,playerInsightSegments,Utilities.clientAPI,Utilities.getSystemInfo(),null,function(param1:String, param2:String, param3:Boolean, param4:String, param5:PlayerInsightState, param6:Array, param7:Boolean, param8:Array, param9:String, param10:Boolean, param11:Array, param12:int, param13:Array):void
         {
            var _loc14_:HTTPChannel = new HTTPChannel(useSecureApiRequests);
            _loc14_.token = param1;
            authSuccess(new Client(stage,_loc14_,gameId,param4,param1,param2,param3,param5),_loc14_,param6,callback);
         },errorHandler);
      }
   }
}

