package thelaststand.app.network.users
{
   import flash.events.Event;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import thelaststand.app.core.SharedResources;
   import thelaststand.app.data.Currency;
   import thelaststand.app.network.PlayerIOConnector;
   
   public class KongregateUser extends AbstractUser
   {
      
      private var _friends:Object;
      
      private var _userId:String;
      
      private var _accessToken:String;
      
      private var _avatarURL:String;
      
      public function KongregateUser(param1:String, param2:String)
      {
         super();
         this._userId = param1;
         this._accessToken = param2;
         _defaultCurrency = Currency.KONGREGATE_KREDS;
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
         return SharedResources.kongregateAPI.services.getUsername();
      }
      
      override public function getJoinData() : Object
      {
         return {
            "serviceUserId":this._userId,
            "serviceAvatar":this._avatarURL,
            "service":PlayerIOConnector.SERVICE_KONGREGATE,
            "auth":this._accessToken,
            "user":JSON.stringify(_data),
            "friends":JSON.stringify(this._friends),
            "nickname":this.userName
         };
      }
      
      override public function load() : void
      {
         var _loc1_:URLLoader = new URLLoader();
         _loc1_.addEventListener(Event.COMPLETE,this.onLoadDataCompleted);
         _loc1_.load(new URLRequest("http://api.kongregate.com/api/user_info.json?user_id=" + this._userId));
      }
      
      private function onLoadDataCompleted(param1:Event) : void
      {
         var loader:URLLoader = null;
         var userData:Object = null;
         var e:Event = param1;
         try
         {
            loader = URLLoader(e.currentTarget);
            userData = JSON.parse(loader.data);
            if(userData.success === "false")
            {
               loadFailed.dispatch();
               return;
            }
            _data = {};
            _data.username = userData.user_vars.username;
            if("gender" in userData.user_vars)
            {
               _data.gender = String(userData.user_vars.gender).toLowerCase();
            }
            if("age" in userData.user_vars)
            {
               _data.age = userData.user_vars.age;
            }
            this._avatarURL = userData.user_vars.avatar_url;
            loaded.dispatch();
         }
         catch(e:Error)
         {
            loadFailed.dispatch();
         }
      }
   }
}

