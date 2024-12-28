package playerio
{
   import flash.events.EventDispatcher;
   import playerio.generated.messages.SocialProfile;
   import playerio.utils.HTTPChannel;
   
   public class PublishingNetwork extends EventDispatcher
   {
      private var _client:Client;
      
      private var _profiles:PublishingNetworkProfiles;
      
      private var _payments:PublishingNetworkPayments;
      
      private var _relations:PublishingNetworkRelations;
      
      private var _userToken:String;
      
      public function PublishingNetwork(param1:Client)
      {
         super();
         this._client = param1;
         _profiles = new PublishingNetworkProfiles(param1);
         _relations = new PublishingNetworkRelations(param1,this);
         _payments = new PublishingNetworkPayments(param1);
         _userToken = null;
      }
      
      internal static function _internal_showDialog(param1:String, param2:Object, param3:HTTPChannel, param4:Function) : void
      {
         PublishingNetworkDialog.showDialog(param1,param2,param3,param4);
      }
      
      public function get profiles() : PublishingNetworkProfiles
      {
         return _profiles;
      }
      
      public function get payments() : PublishingNetworkPayments
      {
         return _payments;
      }
      
      public function get relations() : PublishingNetworkRelations
      {
         return _relations;
      }
      
      public function get userToken() : String
      {
         return _userToken;
      }
      
      public function refresh(param1:Function, param2:Function) : void
      {
         var callback:Function = param1;
         var errorCallback:Function = param2;
         _client._internal_social.refresh(function(param1:SocialProfile, param2:Array, param3:Array):void
         {
            var _loc4_:PublishingNetworkProfile = new PublishingNetworkProfile();
            _loc4_._internal_initialize(param1);
            _profiles._internal_refreshed(_loc4_);
            _relations._internal_refreshed(param1,param2,param3);
            _userToken = param1.userToken;
            if(callback != null)
            {
               callback();
            }
         },errorCallback);
      }
   }
}

