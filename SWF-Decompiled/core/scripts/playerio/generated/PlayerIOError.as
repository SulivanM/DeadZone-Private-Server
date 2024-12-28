package playerio.generated
{
   import playerio.PlayerIOError;
   
   public class PlayerIOError extends playerio.PlayerIOError
   {
      public function PlayerIOError(param1:String, param2:int)
      {
         super(param1,param2);
         switch(param2)
         {
            case 0:
               this._type = playerio.PlayerIOError.UnsupportedMethod;
               break;
            case 1:
               this._type = playerio.PlayerIOError.GeneralError;
               break;
            case 2:
               this._type = playerio.PlayerIOError.InternalError;
               break;
            case 3:
               this._type = playerio.PlayerIOError.AccessDenied;
               break;
            case 4:
               this._type = playerio.PlayerIOError.InvalidMessageFormat;
               break;
            case 5:
               this._type = playerio.PlayerIOError.MissingValue;
               break;
            case 6:
               this._type = playerio.PlayerIOError.GameRequired;
               break;
            case 7:
               this._type = playerio.PlayerIOError.ExternalError;
               break;
            case 8:
               this._type = playerio.PlayerIOError.ArgumentOutOfRange;
               break;
            case 9:
               this._type = playerio.PlayerIOError.GameDisabled;
               break;
            case 10:
               this._type = playerio.PlayerIOError.UnknownGame;
               break;
            case 11:
               this._type = playerio.PlayerIOError.UnknownConnection;
               break;
            case 12:
               this._type = playerio.PlayerIOError.InvalidAuth;
               break;
            case 13:
               this._type = playerio.PlayerIOError.NoServersAvailable;
               break;
            case 14:
               this._type = playerio.PlayerIOError.RoomDataTooLarge;
               break;
            case 15:
               this._type = playerio.PlayerIOError.RoomAlreadyExists;
               break;
            case 16:
               this._type = playerio.PlayerIOError.UnknownRoomType;
               break;
            case 17:
               this._type = playerio.PlayerIOError.UnknownRoom;
               break;
            case 18:
               this._type = playerio.PlayerIOError.MissingRoomId;
               break;
            case 19:
               this._type = playerio.PlayerIOError.RoomIsFull;
               break;
            case 20:
               this._type = playerio.PlayerIOError.NotASearchColumn;
               break;
            case 21:
               this._type = playerio.PlayerIOError.QuickConnectMethodNotEnabled;
               break;
            case 22:
               this._type = playerio.PlayerIOError.UnknownUser;
               break;
            case 23:
               this._type = playerio.PlayerIOError.InvalidPassword;
               break;
            case 24:
               this._type = playerio.PlayerIOError.InvalidRegistrationData;
               break;
            case 25:
               this._type = playerio.PlayerIOError.InvalidBigDBKey;
               break;
            case 26:
               this._type = playerio.PlayerIOError.BigDBObjectTooLarge;
               break;
            case 27:
               this._type = playerio.PlayerIOError.BigDBObjectDoesNotExist;
               break;
            case 28:
               this._type = playerio.PlayerIOError.UnknownTable;
               break;
            case 29:
               this._type = playerio.PlayerIOError.UnknownIndex;
               break;
            case 30:
               this._type = playerio.PlayerIOError.InvalidIndexValue;
               break;
            case 31:
               this._type = playerio.PlayerIOError.NotObjectCreator;
               break;
            case 32:
               this._type = playerio.PlayerIOError.KeyAlreadyUsed;
               break;
            case 33:
               this._type = playerio.PlayerIOError.StaleVersion;
               break;
            case 34:
               this._type = playerio.PlayerIOError.CircularReference;
               break;
            case 40:
               this._type = playerio.PlayerIOError.HeartbeatFailed;
               break;
            case 41:
               this._type = playerio.PlayerIOError.InvalidGameCode;
               break;
            case 50:
               this._type = playerio.PlayerIOError.VaultNotLoaded;
               break;
            case 51:
               this._type = playerio.PlayerIOError.UnknownPayVaultProvider;
               break;
            case 52:
               this._type = playerio.PlayerIOError.DirectPurchaseNotSupportedByProvider;
               break;
            case 54:
               this._type = playerio.PlayerIOError.BuyingCoinsNotSupportedByProvider;
               break;
            case 55:
               this._type = playerio.PlayerIOError.NotEnoughCoins;
               break;
            case 56:
               this._type = playerio.PlayerIOError.ItemNotInVault;
               break;
            case 57:
               this._type = playerio.PlayerIOError.InvalidPurchaseArguments;
               break;
            case 58:
               this._type = playerio.PlayerIOError.InvalidPayVaultProviderSetup;
               break;
            case 70:
               this._type = playerio.PlayerIOError.UnknownPartnerPayAction;
               break;
            case 80:
               this._type = playerio.PlayerIOError.InvalidType;
               break;
            case 81:
               this._type = playerio.PlayerIOError.IndexOutOfBounds;
               break;
            case 82:
               this._type = playerio.PlayerIOError.InvalidIdentifier;
               break;
            case 83:
               this._type = playerio.PlayerIOError.InvalidArgument;
               break;
            case 84:
               this._type = playerio.PlayerIOError.LoggedOut;
               break;
            case 90:
               this._type = playerio.PlayerIOError.InvalidSegment;
               break;
            case 100:
               this._type = playerio.PlayerIOError.GameRequestsNotLoaded;
               break;
            case 110:
               this._type = playerio.PlayerIOError.AchievementsNotLoaded;
               break;
            case 111:
               this._type = playerio.PlayerIOError.UnknownAchievement;
               break;
            case 120:
               this._type = playerio.PlayerIOError.NotificationsNotLoaded;
               break;
            case 121:
               this._type = playerio.PlayerIOError.InvalidNotificationsEndpoint;
               break;
            case 130:
               this._type = playerio.PlayerIOError.NetworkIssue;
               break;
            case 131:
               this._type = playerio.PlayerIOError.OneScoreNotLoaded;
               break;
            case 200:
               this._type = playerio.PlayerIOError.PublishingNetworkNotAvailable;
               break;
            case 201:
               this._type = playerio.PlayerIOError.PublishingNetworkNotLoaded;
               break;
            case 301:
               this._type = playerio.PlayerIOError.DialogClosed;
               break;
            case 302:
               this._type = playerio.PlayerIOError.AdTrackCheckCookie;
         }
      }
   }
}

