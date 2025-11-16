package thelaststand.app.network.users
{
   import playerio.PublishingNetworkProfile;
   import thelaststand.app.data.Currency;
   import thelaststand.app.network.PlayerIOConnector;
   
   public class PlayerIOUser extends AbstractUser
   {
      
      private var _profile:PublishingNetworkProfile;
      
      public function PlayerIOUser()
      {
         super();
         this._profile = PlayerIOConnector.getInstance().client.publishingnetwork.profiles.myProfile;
         _defaultCurrency = Currency.US_DOLLARS;
      }
      
      public function get userId() : String
      {
         return this._profile.userId;
      }
      
      public function get userName() : String
      {
         return this._profile.displayName;
      }
      
      public function get avatarURL() : String
      {
         return this._profile.avatarUrl;
      }
      
      override public function getJoinData() : Object
      {
         return {
            "serviceUserId":this._profile.userId,
            "serviceAvatar":this._profile.avatarUrl,
            "service":PlayerIOConnector.SERVICE_PLAYER_IO
         };
      }
      
      override public function load() : void
      {
         loaded.dispatch();
      }
   }
}

