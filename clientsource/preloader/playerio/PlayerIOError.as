package playerio
{
   public class PlayerIOError extends Error
   {
      
      public static const UnsupportedMethod:PlayerIOError = new PlayerIOError("The method requested is not supported",0);
      
      public static const GeneralError:PlayerIOError = new PlayerIOError("A general error occurred",1);
      
      public static const InternalError:PlayerIOError = new PlayerIOError("An unexpected error occurred inside the Player.IO webservice. Please try again.",2);
      
      public static const AccessDenied:PlayerIOError = new PlayerIOError("Access is denied",3);
      
      public static const InvalidMessageFormat:PlayerIOError = new PlayerIOError("The message is malformatted",4);
      
      public static const MissingValue:PlayerIOError = new PlayerIOError("A value is missing",5);
      
      public static const GameRequired:PlayerIOError = new PlayerIOError("A game is required to do this action",6);
      
      public static const ExternalError:PlayerIOError = new PlayerIOError("An error occurred while contacting an external service",7);
      
      public static const ArgumentOutOfRange:PlayerIOError = new PlayerIOError("The given argument value is outside the range of allowed values.",8);
      
      public static const GameDisabled:PlayerIOError = new PlayerIOError("The game has been disabled, most likely because of missing payment.",9);
      
      public static const UnknownGame:PlayerIOError = new PlayerIOError("The game requested is not known by the server",10);
      
      public static const UnknownConnection:PlayerIOError = new PlayerIOError("The connection requested is not known by the server",11);
      
      public static const InvalidAuth:PlayerIOError = new PlayerIOError("The auth given is invalid or malformatted",12);
      
      public static const NoServersAvailable:PlayerIOError = new PlayerIOError("There is no server in any of the selected server clusters for the game that are eligible to start a new room in (they\'re all at full capacity or there are no servers in any of the clusters). Either change the selected clusters for your game in the admin panel, try again later or start some more servers for one of your clusters.",13);
      
      public static const RoomDataTooLarge:PlayerIOError = new PlayerIOError("The room data for the room was over the allowed size limit",14);
      
      public static const RoomAlreadyExists:PlayerIOError = new PlayerIOError("You are unable to create room because there is already a room with the specified id",15);
      
      public static const UnknownRoomType:PlayerIOError = new PlayerIOError("The game you\'re connected to does not have a room type with the specified name",16);
      
      public static const UnknownRoom:PlayerIOError = new PlayerIOError("There is no room running with that id",17);
      
      public static const MissingRoomId:PlayerIOError = new PlayerIOError("You can\'t join the room when the RoomID is null or the empty string",18);
      
      public static const RoomIsFull:PlayerIOError = new PlayerIOError("The room already has the maxmium amount of users in it.",19);
      
      public static const NotASearchColumn:PlayerIOError = new PlayerIOError("The key you specified is not set as searchable. You can change the searchable keys in the admin panel for the server type",20);
      
      public static const QuickConnectMethodNotEnabled:PlayerIOError = new PlayerIOError("The QuickConnect method (simple, facebook, kongregate...) is not enabled for the game. You can enable the various methods in the admin panel for the game",21);
      
      public static const UnknownUser:PlayerIOError = new PlayerIOError("The user is unknown",22);
      
      public static const InvalidPassword:PlayerIOError = new PlayerIOError("The password supplied is incorrect",23);
      
      public static const InvalidRegistrationData:PlayerIOError = new PlayerIOError("The supplied data is incorrect",24);
      
      public static const InvalidBigDBKey:PlayerIOError = new PlayerIOError("The key given for the BigDB object is not a valid BigDB key. Keys must be between 1 and 50 characters. Only letters, numbers, hyphens, underbars, and spaces are allowed.",25);
      
      public static const BigDBObjectTooLarge:PlayerIOError = new PlayerIOError("The object exceeds the maximum allowed size for BigDB objects.",26);
      
      public static const BigDBObjectDoesNotExist:PlayerIOError = new PlayerIOError("Could not locate the database object.",27);
      
      public static const UnknownTable:PlayerIOError = new PlayerIOError("The specified table does not exist.",28);
      
      public static const UnknownIndex:PlayerIOError = new PlayerIOError("The specified index does not exist.",29);
      
      public static const InvalidIndexValue:PlayerIOError = new PlayerIOError("The value given for the index, does not match the expected type.",30);
      
      public static const NotObjectCreator:PlayerIOError = new PlayerIOError("The operation was aborted because the user attempting the operation was not the original creator of the object accessed.",31);
      
      public static const KeyAlreadyUsed:PlayerIOError = new PlayerIOError("The key is in use by another database object",32);
      
      public static const StaleVersion:PlayerIOError = new PlayerIOError("BigDB object could not be saved using optimistic locks as it\'s out of date.",33);
      
      public static const CircularReference:PlayerIOError = new PlayerIOError("Cannot create circular references inside database objects",34);
      
      public static const HeartbeatFailed:PlayerIOError = new PlayerIOError("The server could not complete the heartbeat",40);
      
      public static const InvalidGameCode:PlayerIOError = new PlayerIOError("The game code is invalid",41);
      
      public static const VaultNotLoaded:PlayerIOError = new PlayerIOError("Cannot access coins or items before vault has been loaded. Please refresh the vault first.",50);
      
      public static const UnknownPayVaultProvider:PlayerIOError = new PlayerIOError("There is no PayVault provider with the specified id",51);
      
      public static const DirectPurchaseNotSupportedByProvider:PlayerIOError = new PlayerIOError("The specified PayVault provider does not support direct purchase",52);
      
      public static const BuyingCoinsNotSupportedByProvider:PlayerIOError = new PlayerIOError("The specified PayVault provider does not support buying coins",54);
      
      public static const NotEnoughCoins:PlayerIOError = new PlayerIOError("The user does not have enough coins in the PayVault to complete the purchase or debit.",55);
      
      public static const ItemNotInVault:PlayerIOError = new PlayerIOError("The item does not exist in the vault.",56);
      
      public static const InvalidPurchaseArguments:PlayerIOError = new PlayerIOError("The chosen provider rejected one or more of the purchase arguments",57);
      
      public static const InvalidPayVaultProviderSetup:PlayerIOError = new PlayerIOError("The chosen provider is not configured correctly in the admin panel",58);
      
      public static const UnknownPartnerPayAction:PlayerIOError = new PlayerIOError("Unable to locate the custom PartnerPay action with the given key",70);
      
      public static const InvalidType:PlayerIOError = new PlayerIOError("The given type was invalid",80);
      
      public static const IndexOutOfBounds:PlayerIOError = new PlayerIOError("The index was out of bounds from the range of acceptable values",81);
      
      public static const InvalidIdentifier:PlayerIOError = new PlayerIOError("The given identifier does not match the expected format",82);
      
      public static const InvalidArgument:PlayerIOError = new PlayerIOError("The given argument did not have the expected value",83);
      
      public static const LoggedOut:PlayerIOError = new PlayerIOError("This client has been logged out",84);
      
      public static const InvalidSegment:PlayerIOError = new PlayerIOError("The given segment was invalid.",90);
      
      public static const GameRequestsNotLoaded:PlayerIOError = new PlayerIOError("Cannot access requests before Refresh() has been called.",100);
      
      public static const AchievementsNotLoaded:PlayerIOError = new PlayerIOError("Cannot access achievements before Refresh() has been called.",110);
      
      public static const UnknownAchievement:PlayerIOError = new PlayerIOError("Cannot find the achievement with the specified id.",111);
      
      public static const NotificationsNotLoaded:PlayerIOError = new PlayerIOError("Cannot access notification endpoints before Refresh() has been called.",120);
      
      public static const InvalidNotificationsEndpoint:PlayerIOError = new PlayerIOError("The given notifications endpoint is invalid",121);
      
      public static const NetworkIssue:PlayerIOError = new PlayerIOError("There is an issue with the network",130);
      
      public static const OneScoreNotLoaded:PlayerIOError = new PlayerIOError("Cannot access OneScore before Refresh() has been called.",131);
      
      public static const PublishingNetworkNotAvailable:PlayerIOError = new PlayerIOError("The Publishing Network features are only avaliable when authenticated to PlayerIO using Publishing Network authentication. Authentication methods are managed in the connections setting of your game in the admin panel on PlayerIO.",200);
      
      public static const PublishingNetworkNotLoaded:PlayerIOError = new PlayerIOError("Cannot access profile, friends, ignored before Publishing Network has been loaded. Please refresh Publishing Network first.",201);
      
      public static const DialogClosed:PlayerIOError = new PlayerIOError("The dialog was closed by the user",301);
      
      public static const AdTrackCheckCookie:PlayerIOError = new PlayerIOError("Check cookie required.",302);
      
      protected var _type:PlayerIOError = GeneralError;
      
      public function PlayerIOError(param1:String, param2:int)
      {
         super(param1,param2);
      }
      
      public function get type() : PlayerIOError
      {
         return _type;
      }
   }
}

