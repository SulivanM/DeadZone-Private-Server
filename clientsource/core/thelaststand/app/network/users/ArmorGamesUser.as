package thelaststand.app.network.users
{
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   import org.osflash.signals.Signal;
   import thelaststand.app.data.Currency;
   import thelaststand.app.network.PlayerIOConnector;
   
   public class ArmorGamesUser extends AbstractUser
   {
      
      private var _authenticated:Boolean = false;
      
      private var _avatarURL:String;
      
      private var _accessToken:String;
      
      private var _userId:String;
      
      private var _userName:String;
      
      private var _friends:Array;
      
      private var _loadedFriends:Boolean = false;
      
      private var _loadedUser:Boolean = false;
      
      public var authSuccess:Signal;
      
      public var authFailed:Signal;
      
      public var authTimeout:Signal;
      
      public function ArmorGamesUser(param1:String, param2:String)
      {
         super();
         this._userId = param1;
         this._accessToken = param2;
         this._friends = [];
         _defaultCurrency = Currency.US_DOLLARS;
         this.authSuccess = new Signal(String,String);
         this.authFailed = new Signal();
         this.authTimeout = new Signal();
      }
      
      public function get avatarURL() : String
      {
         return this._avatarURL;
      }
      
      public function get accessToken() : String
      {
         return this._accessToken;
      }
      
      public function get userId() : String
      {
         return this._userId;
      }
      
      public function get userName() : String
      {
         return this._userName;
      }
      
      public function get friends() : Array
      {
         return this._friends;
      }
      
      override public function getJoinData() : Object
      {
         return {
            "serviceUserId":this._userId,
            "serviceAvatar":this._avatarURL,
            "service":PlayerIOConnector.SERVICE_ARMOR_GAMES,
            "user":JSON.stringify(_data),
            "friends":JSON.stringify(this._friends)
         };
      }
      
      public function authenticate() : void
      {
         this._authenticated = false;
         var _loc1_:URLVariables = new URLVariables();
         _loc1_.userid = this._userId;
         _loc1_.authtoken = this._accessToken;
         var _loc2_:URLRequest = new URLRequest("http://api.playerio.com/clientintegrations/armorgames/auth2");
         _loc2_.method = URLRequestMethod.GET;
         _loc2_.data = _loc1_;
         var _loc3_:URLLoader = new URLLoader();
         _loc3_.addEventListener(Event.COMPLETE,this.onAuthComplete);
         _loc3_.addEventListener(IOErrorEvent.IO_ERROR,this.onAuthFailed);
         _loc3_.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onAuthFailed);
         _loc3_.load(_loc2_);
      }
      
      private function checkLoaded() : void
      {
         if(this._loadedUser && this._loadedFriends)
         {
            loaded.dispatch();
         }
      }
      
      override public function load() : void
      {
         this._loadedUser = false;
         if(!this._authenticated)
         {
            throw new Error("User is not authenticated. Call authenticate() first.");
         }
         var _loc1_:URLVariables = new URLVariables();
         _loc1_.api_key = "DDBD50F0-D8F6-4D6C-A4BD-5D99229D5EE9";
         var _loc2_:URLRequest = new URLRequest("https://services.armorgames.com/services/rest/v1/users/" + this._userId + ".json");
         _loc2_.method = URLRequestMethod.GET;
         _loc2_.data = _loc1_;
         var _loc3_:URLLoader = new URLLoader();
         _loc3_.addEventListener(Event.COMPLETE,this.onDataLoaded);
         _loc3_.addEventListener(IOErrorEvent.IO_ERROR,this.onDataFailed);
         _loc3_.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onDataFailed);
         _loc3_.load(_loc2_);
         this.loadFriends();
      }
      
      private function loadFriends() : void
      {
         this._loadedFriends = true;
         this.checkLoaded();
      }
      
      private function onDataLoaded(param1:Event) : void
      {
         var strData:String = null;
         var data:Object = null;
         var strDob:String = null;
         var dobValues:Array = null;
         var dob:Date = null;
         var age:Date = null;
         var e:Event = param1;
         try
         {
            strData = URLLoader(e.currentTarget).data;
            data = JSON.parse(strData);
            if(data == null || data.code != 200 || data.payload == null)
            {
               loadFailed.dispatch();
               return;
            }
            this._avatarURL = data.payload.avatar;
            _data = {};
            _data.username = data.payload.username;
            _data.email = data.payload.email;
            _data.gender = String(data.payload.gender).toLowerCase();
            if(data.payload.hasOwnProperty("birthday"))
            {
               strDob = data.payload.birthday;
               dobValues = strDob.split("-");
               _data.birthday = strDob;
               dob = new Date(int(dobValues[0]),int(dobValues[1]) - 1,int(dobValues[2]));
               age = new Date(new Date().time - dob.time);
               _data.age = age.fullYear - 1970;
            }
         }
         catch(e:Error)
         {
            loadFailed.dispatch();
            return;
         }
         this._loadedUser = true;
         this.checkLoaded();
      }
      
      private function onFriendsLoaded(param1:Event) : void
      {
         var strData:String = null;
         var data:Object = null;
         var i:int = 0;
         var friendData:Object = null;
         var e:Event = param1;
         try
         {
            strData = URLLoader(e.currentTarget).data;
            data = JSON.parse(strData);
            if(data == null || data.code != 200 || !(data.payload is Array))
            {
               loadFailed.dispatch();
               return;
            }
            i = 0;
            while(i < data.payload.length)
            {
               friendData = data.payload[i];
               i++;
            }
         }
         catch(e:Error)
         {
            loadFailed.dispatch();
            return;
         }
         this._loadedFriends = true;
         this.checkLoaded();
      }
      
      private function onAuthComplete(param1:Event) : void
      {
         var loader:URLLoader = null;
         var strData:String = null;
         var data:Array = null;
         var e:Event = param1;
         try
         {
            loader = URLLoader(e.currentTarget);
            strData = String(loader.data);
            if(strData.substr(0,6) == "error:")
            {
               switch(strData.substr(6))
               {
                  case "timeout":
                     this.authTimeout.dispatch();
                     break;
                  case "no userid":
                  case "authentication token has expired":
                  case "unknown error":
                  default:
                     this.authFailed.dispatch();
               }
               return;
            }
            data = strData.split("\n");
            this._userName = String(data[0]);
            this._authenticated = true;
            this.authSuccess.dispatch(this._userName,String(data[1]));
         }
         catch(e:Error)
         {
            authFailed.dispatch();
         }
      }
      
      private function onAuthFailed(param1:Event) : void
      {
         this.authFailed.dispatch();
      }
      
      private function onDataFailed(param1:IOErrorEvent) : void
      {
         loadFailed.dispatch();
      }
      
      private function onFriendsFailed(param1:Event) : void
      {
         this._loadedFriends = true;
         this.checkLoaded();
      }
   }
}

