package thelaststand.app.network.users
{
   import playerio.facebook.FB;
   import thelaststand.app.data.Currency;
   import thelaststand.app.network.PlayerIOConnector;
   
   public class FacebookUser extends AbstractUser
   {
      
      private var _accessToken:String;
      
      private var _userId:String;
      
      private var _friends:Array = [];
      
      public function FacebookUser(param1:String, param2:String)
      {
         super();
         this._userId = param1;
         this._accessToken = param2;
         _defaultCurrency = Currency.US_DOLLARS;
      }
      
      public function get accessToken() : String
      {
         return this._accessToken;
      }
      
      public function get userId() : String
      {
         return this._userId;
      }
      
      public function get friends() : Array
      {
         return this._friends;
      }
      
      override public function getJoinData() : Object
      {
         return {
            "service":PlayerIOConnector.SERVICE_FACEBOOK,
            "user":JSON.stringify(_data),
            "friends":JSON.stringify(this._friends)
         };
      }
      
      override public function load() : void
      {
         try
         {
            FB.api("/v2.6/me",function(param1:Object):void
            {
               var dob:Date = null;
               var age:Date = null;
               var response:Object = param1;
               if(response == null)
               {
                  loadFailed.dispatch();
                  return;
               }
               _data = {};
               if(response.email != undefined)
               {
                  _data.email = response.email;
               }
               _data.timezone = response.timezone;
               _data.firstName = response.first_name;
               _data.lastName = response.last_name;
               _data.gender = response.gender;
               _data.locale = response.locale;
               if(response.hasOwnProperty("birthday"))
               {
                  _data.birthday = response.birthday;
                  dob = new Date(_data.birthday);
                  age = new Date(new Date().time - dob.time);
                  _data.age = age.fullYear - 1970;
               }
               loadAppFriends(function(param1:Array):void
               {
                  _friends = param1;
                  loaded.dispatch();
               });
            });
         }
         catch(e:Error)
         {
            loadFailed.dispatch();
         }
      }
      
      private function loadAppFriends(param1:Function) : void
      {
         var output:Array = null;
         var callback:Function = param1;
         output = [];
         try
         {
            this.loadAppFriendsPage("/v2.6/me/friends",output,function():void
            {
               callback(output);
            });
         }
         catch(e:Error)
         {
            callback(output);
         }
      }
      
      private function loadAppFriendsPage(param1:String, param2:Array, param3:Function) : void
      {
         var url:String = param1;
         var output:Array = param2;
         var onComplete:Function = param3;
         FB.api(url,function(param1:*):void
         {
            var _loc2_:int = 0;
            var _loc3_:int = 0;
            var _loc4_:Object = null;
            var _loc5_:String = null;
            var _loc6_:* = null;
            if(param1 == null)
            {
               onComplete();
               return;
            }
            if(param1.data != null)
            {
               _loc2_ = 0;
               _loc3_ = int(param1.data.length);
               while(_loc2_ < _loc3_)
               {
                  _loc4_ = param1.data[_loc2_];
                  output.push(_loc4_.id);
                  _loc2_++;
               }
            }
            if(param1.paging != null)
            {
               _loc5_ = param1.paging.next;
               if(_loc5_ == null)
               {
                  onComplete();
               }
               else
               {
                  _loc6_ = _loc5_.substr(_loc5_.indexOf("/v2.6")) + "&";
                  loadAppFriendsPage(_loc6_,output,onComplete);
               }
            }
            else
            {
               onComplete();
            }
         });
      }
   }
}

