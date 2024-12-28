package playerio
{
   import playerio.generated.PlayerIOError;
   import playerio.generated.messages.SocialProfile;
   import playerio.utils.Utilities;
   
   internal class PublishingNetworkRelations
   {
      private var _client:Client;
      
      private var _friends:Array;
      
      private var _friendLookup:Object;
      
      private var _blockedLookup:Object;
      
      private var _publishingnetwork:PublishingNetwork;
      
      public function PublishingNetworkRelations(param1:Client, param2:PublishingNetwork)
      {
         super();
         this._client = param1;
         this._publishingnetwork = param2;
      }
      
      internal function _internal_refreshed(param1:SocialProfile, param2:Array, param3:Array) : void
      {
         var friend:PublishingNetworkProfile;
         var ignored:String;
         var myProfile:SocialProfile = param1;
         var friends:Array = param2;
         var blocked:Array = param3;
         this._friends = Utilities.converter(friends,function(param1:SocialProfile):PublishingNetworkProfile
         {
            var _loc2_:PublishingNetworkProfile = new PublishingNetworkProfile();
            _loc2_._internal_initialize(param1);
            return _loc2_;
         });
         _friendLookup = {};
         for each(friend in this._friends)
         {
            _friendLookup[friend.userId] = true;
         }
         _blockedLookup = {};
         if(blocked != null)
         {
            for each(ignored in blocked)
            {
               _blockedLookup[ignored] = true;
            }
         }
      }
      
      public function get friends() : Array
      {
         if(_friends == null)
         {
            throw new playerio.generated.PlayerIOError("Cannot access friends before Publishing Network has loaded. Please call client.publishingnetwork.refresh() first.",playerio.PlayerIOError.PublishingNetworkNotLoaded.errorID);
         }
         return _friends;
      }
      
      public function isFriend(param1:String) : Boolean
      {
         if(_friendLookup == null)
         {
            throw new playerio.generated.PlayerIOError("Cannot access friends before Publishing Network has loaded. Please call client.publishingnetwork.refresh() first.",playerio.PlayerIOError.PublishingNetworkNotLoaded.errorID);
         }
         return _friendLookup[param1] != undefined;
      }
      
      public function isBlocked(param1:String) : Boolean
      {
         if(_blockedLookup == null)
         {
            throw new playerio.generated.PlayerIOError("Cannot access friends before Publishing Network has loaded. Please call client.publishingnetwork.refresh() first.",playerio.PlayerIOError.PublishingNetworkNotLoaded.errorID);
         }
         return _blockedLookup[param1] != undefined;
      }
      
      public function showRequestFriendshipDialog(param1:String, param2:Function) : void
      {
         var userId:String = param1;
         var closedCallback:Function = param2;
         PublishingNetwork._internal_showDialog("requestfriendship",{"userId":userId},_client.channel,function():void
         {
            if(closedCallback != null)
            {
               closedCallback();
            }
         });
      }
      
      public function showRequestBlockUserDialog(param1:String, param2:Function) : void
      {
         var userId:String = param1;
         var closedCallback:Function = param2;
         PublishingNetwork._internal_showDialog("requestblockuser",{"userId":userId},_client.channel,function():void
         {
            _publishingnetwork.refresh(function():void
            {
               if(closedCallback != null)
               {
                  closedCallback();
               }
            },function():void
            {
               if(closedCallback != null)
               {
                  closedCallback();
               }
            });
         });
      }
      
      public function showFriendsManager(param1:Function) : void
      {
         var closedCallback:Function = param1;
         PublishingNetwork._internal_showDialog("friendsmanager",{},_client.channel,function(param1:Object):void
         {
            var result:Object = param1;
            if(result["updated"] != undefined)
            {
               _publishingnetwork.refresh(function():void
               {
                  if(closedCallback != null)
                  {
                     closedCallback();
                  }
               },function():void
               {
                  if(closedCallback != null)
                  {
                     closedCallback();
                  }
               });
            }
            else if(closedCallback != null)
            {
               closedCallback();
            }
         });
      }
      
      public function showBlockedUsersManager(param1:Function) : void
      {
         var closedCallback:Function = param1;
         PublishingNetwork._internal_showDialog("blockedusersmanager",{},_client.channel,function(param1:Object):void
         {
            var result:Object = param1;
            if(result["updated"] != undefined)
            {
               _publishingnetwork.refresh(function():void
               {
                  if(closedCallback != null)
                  {
                     closedCallback();
                  }
               },function():void
               {
                  if(closedCallback != null)
                  {
                     closedCallback();
                  }
               });
            }
            else if(closedCallback != null)
            {
               closedCallback();
            }
         });
      }
   }
}

