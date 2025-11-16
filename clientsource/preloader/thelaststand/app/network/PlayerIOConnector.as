package thelaststand.app.network
{
   import flash.display.Loader;
   import flash.display.Stage;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.external.ExternalInterface;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.system.Security;
   import flash.utils.setTimeout;
   import playerio.Client;
   import playerio.PlayerIO;
   import playerio.PlayerIOError;
   import thelaststand.app.core.SharedResources;
   import thelaststand.app.network.users.*;
   
   public class PlayerIOConnector extends EventDispatcher
   {
      
      private static var _instance:PlayerIOConnector;
      
      public static const GAME_ID:String = "dev-the-last-stand-iret8ormbeshajyk6woewg";
      
      public static const GAME_CONN:String = "public";
      
      public static const SERVICE_FACEBOOK:String = "fb";
      
      public static const SERVICE_ARMOR_GAMES:String = "armor";
      
      public static const SERVICE_KONGREGATE:String = "kong";
      
      public static const SERVICE_YAHOO:String = "yahoo";
      
      public static const SERVICE_PLAYER_IO:String = "pio";
      
      public static const PARTNER_PAY_ARMOR_GAMES:String = "armorgames";
      
      private var _client:Client;
      
      private var _service:String;
      
      private var _accessToken:String;
      
      private var _userId:String;
      
      private var _user:AbstractUser;
      
      private var _connectRetryCount:int;
      
      public function PlayerIOConnector(param1:PlayerIOConnectorSingletonEnforcer)
      {
         super();
         if(!param1)
         {
            throw new Error("PlayerIOConnector is a Singleton and cannot be directly instantiated. Use PlayerIOConnector.getInstance().");
         }
      }
      
      public static function getInstance() : PlayerIOConnector
      {
         if(!_instance)
         {
            _instance = new PlayerIOConnector(new PlayerIOConnectorSingletonEnforcer());
         }
         return _instance;
      }
      
      public function get client() : Client
      {
         return this._client;
      }
      
      public function get service() : String
      {
         return this._service;
      }
      
      public function get user() : AbstractUser
      {
         return this._user;
      }
      
      public function connect(param1:Stage) : void
      {
         var _loc2_:Object = param1.loaderInfo.parameters || {};
         this._service = _loc2_.service;
         switch(this._service)
         {
            case SERVICE_FACEBOOK:
               this.connectViaFacebook(param1,_loc2_.accessToken,_loc2_.affiliate);
               break;
            case SERVICE_ARMOR_GAMES:
               this.connectViaArmorGames(param1,_loc2_.userId,_loc2_.accessToken);
               break;
            case SERVICE_KONGREGATE:
               this.connectViaKongregate(param1);
               break;
            case SERVICE_PLAYER_IO:
               this.connectViaPlayerIO(param1,_loc2_.userToken);
               break;
            default:
               throw new Error("Invalid service \'" + this._service + "\' supplied.");
         }
      }
      
      private function getFacebookAccessToken(param1:Function) : void
      {
         var tokenLoader:URLLoader = null;
         var callback:Function = param1;
         tokenLoader = new URLLoader();
         tokenLoader.addEventListener(IOErrorEvent.IO_ERROR,function(param1:Event):void
         {
            getFacebookAccessToken(callback);
         });
         tokenLoader.addEventListener(Event.COMPLETE,function(param1:Event):void
         {
            tokenLoader.removeEventListener(Event.COMPLETE,arguments.callee);
            var _loc3_:XML = XML(tokenLoader.data);
            var _loc4_:String = _loc3_.hasOwnProperty("token") ? _loc3_.token.toString() : null;
            callback(_loc4_);
            if(_loc4_)
            {
            }
         });
         tokenLoader.load(new URLRequest("http://fb.deadzonegame.com/token.php"));
      }
      
      private function connectViaFacebook(param1:Stage, param2:String, param3:String = null) : void
      {
         var stage:Stage = param1;
         var accessToken:String = param2;
         var affiliate:String = param3;
         if(!accessToken)
         {
            this.getFacebookAccessToken(function(param1:String):void
            {
               if(!param1)
               {
                  onConnectError(null);
                  return;
               }
               connectViaFacebook(stage,param1,affiliate);
            });
            return;
         }
         this._accessToken = accessToken;
         PlayerIO.quickConnect.facebookOAuthConnect(stage,GAME_ID,this._accessToken,affiliate || "",this.onFacebookConnected,this.onConnectError);
      }
      
      private function connectViaArmorGames(param1:Stage, param2:String, param3:String) : void
      {
         var agUser:ArmorGamesUser = null;
         var stage:Stage = param1;
         var userId:String = param2;
         var accessToken:String = param3;
         this._userId = userId;
         this._accessToken = accessToken;
         agUser = new ArmorGamesUser(userId,accessToken);
         agUser.authSuccess.addOnce(function(param1:String, param2:String):void
         {
            _user = agUser;
            PlayerIO.connect(stage,GAME_ID,GAME_CONN,param1,param2,PARTNER_PAY_ARMOR_GAMES,onArmorGamesConnected,onConnectError);
         });
         agUser.authTimeout.addOnce(function(param1:String, param2:String):void
         {
            var connId:String = param1;
            var auth:String = param2;
            if(++_connectRetryCount > 10)
            {
               onConnectError();
               return;
            }
            setTimeout(function():void
            {
               connectViaArmorGames(stage,userId,accessToken);
            },2000);
         });
         agUser.authFailed.addOnce(this.onConnectError);
         agUser.authenticate();
      }
      
      public function connectViaKongregate(param1:Stage) : void
      {
         var apiLoader:Loader = null;
         var stage:Stage = param1;
         var apiURI:String = stage.loaderInfo.parameters.kongregate_api_path || "http://www.kongregate.com/flash/API_AS3_Local.swf";
         Security.allowDomain(apiURI);
         apiLoader = new Loader();
         stage.addChild(apiLoader);
         apiLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,function(param1:Event):void
         {
            var _loc2_:KongregateUser = null;
            SharedResources.kongregateAPI = apiLoader.content;
            SharedResources.kongregateAPI.services.connect();
            stage.addChild(SharedResources.kongregateAPI);
            _loc2_ = new KongregateUser(SharedResources.kongregateAPI.services.getUserId(),SharedResources.kongregateAPI.services.getGameAuthToken());
            _user = _loc2_;
            PlayerIO.quickConnect.kongregateConnect(stage,GAME_ID,_loc2_.userId,_loc2_.accessToken,onKongregateConnected,onConnectError);
         });
         apiLoader.load(new URLRequest(apiURI));
      }
      
      public function connectViaPlayerIO(param1:Stage, param2:String) : void
      {
         var stage:Stage = param1;
         var userToken:String = param2;
         PlayerIO.authenticate(stage,GAME_ID,"publishingnetwork",{"userToken":userToken},null,function(param1:Client):void
         {
            onPlayerIOPubNetworkConnected(param1,userToken);
         },this.onConnectError);
      }
      
      private function onPlayerIOPubNetworkConnected(param1:Client, param2:String) : void
      {
         var client:Client = param1;
         var userToken:String = param2;
         this._client = client;
         this._client.publishingnetwork.refresh(function():void
         {
            try
            {
               _user = new PlayerIOUser();
               if(ExternalInterface.available)
               {
                  ExternalInterface.call("setUserId",client.connectUserId);
               }
               dispatchEvent(new Event(Event.COMPLETE));
            }
            catch(error:Error)
            {
               onConnectError();
               return;
            }
         },function(param1:PlayerIOError):void
         {
            onConnectError();
         });
      }
      
      private function onFacebookConnected(param1:Client, param2:String = null) : void
      {
         this._client = param1;
         this._userId = param2;
         this._user = new FacebookUser(this._userId,this._accessToken);
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      private function onArmorGamesConnected(param1:Client) : void
      {
         this._client = param1;
         if(ExternalInterface.available)
         {
            ExternalInterface.call("setUserId",ArmorGamesUser(this._user).userName);
         }
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      private function onKongregateConnected(param1:Client) : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.call("setUserId",param1.connectUserId);
         }
         this._client = param1;
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      private function onConnectError(param1:PlayerIOError = null) : void
      {
         dispatchEvent(new ErrorEvent(ErrorEvent.ERROR));
      }
   }
}

class PlayerIOConnectorSingletonEnforcer
{
   
   public function PlayerIOConnectorSingletonEnforcer()
   {
      super();
   }
}
