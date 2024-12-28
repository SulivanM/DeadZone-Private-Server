package playerio
{
   import flash.display.Stage;
   import playerio.generated.messages.PlayerInsightState;
   import playerio.utils.HTTPChannel;
   
   public class Client
   {
      private var _connectUserId:String;
      
      private var _gameId:String;
      
      private var _showBranding:Boolean;
      
      private var _multiplayer:Multiplayer;
      
      private var _bigDB:BigDB;
      
      private var _errorLog:ErrorLog;
      
      private var _notifications:Notifications;
      
      private var _gameFS:GameFS;
      
      private var _payVault:PayVault;
      
      private var _playerInsight:PlayerInsight;
      
      private var _gameRequests:GameRequests;
      
      private var _achievements:Achievements;
      
      private var _social:Social;
      
      private var _publishingnetwork:PublishingNetwork;
      
      private var _oneScore:OneScore;
      
      private var _stage:Stage;
      
      private var _channel:HTTPChannel;
      
      private var _isSocialNetworkuser:Boolean;
      
      public function Client(param1:Stage, param2:HTTPChannel, param3:String, param4:String, param5:String, param6:String, param7:Boolean, param8:PlayerInsightState)
      {
         super();
         _multiplayer = new Multiplayer(param2,this);
         _errorLog = new ErrorLog(param2,this);
         _bigDB = new BigDB(param2,this);
         _payVault = new PayVault(param2,this);
         _achievements = new Achievements(param2,this);
         _gameFS = new GameFS(param3,param4);
         _playerInsight = new PlayerInsight(param2,this,param8);
         _gameRequests = new GameRequests(param2,this);
         _notifications = new Notifications(param2,this);
         _publishingnetwork = new PublishingNetwork(this);
         _social = new Social(param2,this);
         _oneScore = new OneScore(param2,this);
         _connectUserId = param6;
         _stage = param1;
         _channel = param2;
      }
      
      public function get connectUserId() : String
      {
         return _connectUserId;
      }
      
      public function get gameId() : String
      {
         return _gameId;
      }
      
      public function get showBranding() : Boolean
      {
         return _showBranding;
      }
      
      public function get multiplayer() : Multiplayer
      {
         return _multiplayer;
      }
      
      public function get bigDB() : BigDB
      {
         return _bigDB;
      }
      
      public function get errorLog() : ErrorLog
      {
         return _errorLog;
      }
      
      public function get notifications() : Notifications
      {
         return _notifications;
      }
      
      public function get gameFS() : GameFS
      {
         return _gameFS;
      }
      
      public function get payVault() : PayVault
      {
         return _payVault;
      }
      
      public function get playerInsight() : PlayerInsight
      {
         return _playerInsight;
      }
      
      public function get gameRequests() : GameRequests
      {
         return _gameRequests;
      }
      
      public function get achievements() : Achievements
      {
         return _achievements;
      }
      
      internal function get _internal_social() : Social
      {
         return _social;
      }
      
      public function get publishingnetwork() : PublishingNetwork
      {
         return _publishingnetwork;
      }
      
      public function get oneScore() : OneScore
      {
         return _oneScore;
      }
      
      public function get channel() : HTTPChannel
      {
         return _channel;
      }
      
      public function handleCallbackError(param1:String, param2:Error) : void
      {
         if(multiplayer.developmentServer == null)
         {
            errorLog.writeError(param2.name,param2.message,(param2.getStackTrace() == null ? "I" : param2.getStackTrace() + "\n i") + "n callback handler for " + param1,{});
         }
      }
      
      public function handleCallbackErrorVerbose(param1:String, param2:Error) : void
      {
         if(multiplayer.developmentServer == null)
         {
            errorLog.writeError(param2.message,param1,param2.getStackTrace() == null ? "" : param2.getStackTrace(),{});
         }
      }
      
      public function handleSystemError(param1:String, param2:Error, param3:Object) : void
      {
         errorLog.writeError(param2.message,param1,param2.getStackTrace() == null ? "" : param2.getStackTrace(),param3);
      }
      
      public function get stage() : Stage
      {
         return _stage;
      }
      
      public function toString() : String
      {
         return "[Player.IO Client]";
      }
   }
}

