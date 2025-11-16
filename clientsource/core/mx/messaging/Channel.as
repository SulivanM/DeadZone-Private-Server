package mx.messaging
{
   import flash.errors.IllegalOperationError;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import flash.utils.getDefinitionByName;
   import mx.collections.ArrayCollection;
   import mx.core.IMXMLObject;
   import mx.core.mx_internal;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import mx.messaging.config.LoaderConfig;
   import mx.messaging.config.ServerConfig;
   import mx.messaging.errors.InvalidChannelError;
   import mx.messaging.errors.InvalidDestinationError;
   import mx.messaging.events.ChannelEvent;
   import mx.messaging.events.ChannelFaultEvent;
   import mx.messaging.messages.AbstractMessage;
   import mx.messaging.messages.CommandMessage;
   import mx.messaging.messages.IMessage;
   import mx.resources.IResourceManager;
   import mx.resources.ResourceManager;
   import mx.rpc.AsyncDispatcher;
   import mx.utils.URLUtil;
   
   use namespace mx_internal;
   
   public class Channel extends EventDispatcher implements IMXMLObject
   {
      
      protected static const CLIENT_LOAD_BALANCING:String = "client-load-balancing";
      
      protected static const CONNECT_TIMEOUT_SECONDS:String = "connect-timeout-seconds";
      
      protected static const ENABLE_SMALL_MESSAGES:String = "enable-small-messages";
      
      protected static const FALSE:String = "false";
      
      protected static const RECORD_MESSAGE_TIMES:String = "record-message-times";
      
      protected static const RECORD_MESSAGE_SIZES:String = "record-message-sizes";
      
      protected static const REQUEST_TIMEOUT_SECONDS:String = "request-timeout-seconds";
      
      protected static const SERIALIZATION:String = "serialization";
      
      protected static const TRUE:String = "true";
      
      public static const SMALL_MESSAGES_FEATURE:String = "small_messages";
      
      private static const dep:ArrayCollection = null;
      
      mx_internal var authenticating:Boolean;
      
      protected var credentials:String;
      
      public var enableSmallMessages:Boolean = true;
      
      protected var _log:ILogger;
      
      protected var _connecting:Boolean;
      
      private var _connectTimer:Timer;
      
      private var _failoverIndex:int;
      
      private var _isEndpointCalculated:Boolean;
      
      protected var messagingVersion:Number = 1;
      
      private var _ownsWaitGuard:Boolean;
      
      private var _previouslyConnected:Boolean;
      
      private var _primaryURI:String;
      
      mx_internal var reliableReconnectDuration:int = -1;
      
      private var _reliableReconnectBeginTimestamp:Number;
      
      private var _reliableReconnectLastTimestamp:Number;
      
      private var _reliableReconnectAttempts:int;
      
      private var resourceManager:IResourceManager = ResourceManager.getInstance();
      
      private var _channelSets:Array = [];
      
      private var _connected:Boolean = false;
      
      private var _connectTimeout:int = -1;
      
      private var _endpoint:String;
      
      protected var _recordMessageTimes:Boolean = false;
      
      protected var _recordMessageSizes:Boolean = false;
      
      private var _reconnecting:Boolean = false;
      
      private var _failoverURIs:Array;
      
      private var _id:String;
      
      private var _authenticated:Boolean = false;
      
      private var _requestTimeout:int = -1;
      
      private var _shouldBeConnected:Boolean;
      
      private var _uri:String;
      
      private var _smallMessagesSupported:Boolean;
      
      public function Channel(param1:String = null, param2:String = null)
      {
         super();
         this._log = Log.getLogger("mx.messaging.Channel");
         this._failoverIndex = -1;
         this.id = param1;
         this._primaryURI = param2;
         this.uri = param2;
      }
      
      public function initialized(param1:Object, param2:String) : void
      {
         this.id = param2;
      }
      
      public function get channelSets() : Array
      {
         return this._channelSets;
      }
      
      [Bindable(event="propertyChange")]
      public function get connected() : Boolean
      {
         return this._connected;
      }
      
      protected function setConnected(param1:Boolean) : void
      {
         var _loc2_:PropertyChangeEvent = null;
         if(this._connected != param1)
         {
            if(this._connected)
            {
               this._previouslyConnected = true;
            }
            _loc2_ = PropertyChangeEvent.createUpdateEvent(this,"connected",this._connected,param1);
            this._connected = param1;
            dispatchEvent(_loc2_);
            if(!param1)
            {
               this.mx_internal::setAuthenticated(false);
            }
         }
      }
      
      public function get connectTimeout() : int
      {
         return this._connectTimeout;
      }
      
      public function set connectTimeout(param1:int) : void
      {
         this._connectTimeout = param1;
      }
      
      public function get endpoint() : String
      {
         if(!this._isEndpointCalculated)
         {
            this.calculateEndpoint();
         }
         return this._endpoint;
      }
      
      public function get recordMessageTimes() : Boolean
      {
         return this._recordMessageTimes;
      }
      
      public function get recordMessageSizes() : Boolean
      {
         return this._recordMessageSizes;
      }
      
      [Bindable(event="propertyChange")]
      public function get reconnecting() : Boolean
      {
         return this._reconnecting;
      }
      
      private function setReconnecting(param1:Boolean) : void
      {
         var _loc2_:PropertyChangeEvent = null;
         if(this._reconnecting != param1)
         {
            _loc2_ = PropertyChangeEvent.createUpdateEvent(this,"reconnecting",this._reconnecting,param1);
            this._reconnecting = param1;
            dispatchEvent(_loc2_);
         }
      }
      
      public function get failoverURIs() : Array
      {
         return this._failoverURIs != null ? this._failoverURIs : [];
      }
      
      public function set failoverURIs(param1:Array) : void
      {
         if(param1 != null)
         {
            this._failoverURIs = param1;
            this._failoverIndex = -1;
         }
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function set id(param1:String) : void
      {
         if(this._id != param1)
         {
            this._id = param1;
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get authenticated() : Boolean
      {
         return this._authenticated;
      }
      
      mx_internal function setAuthenticated(param1:Boolean) : void
      {
         var _loc2_:PropertyChangeEvent = null;
         var _loc3_:ChannelSet = null;
         var _loc4_:int = 0;
         if(param1 != this._authenticated)
         {
            _loc2_ = PropertyChangeEvent.createUpdateEvent(this,"authenticated",this._authenticated,param1);
            this._authenticated = param1;
            _loc4_ = 0;
            while(_loc4_ < this._channelSets.length)
            {
               _loc3_ = ChannelSet(this._channelSets[_loc4_]);
               _loc3_.mx_internal::setAuthenticated(this.authenticated,this.credentials);
               _loc4_++;
            }
            dispatchEvent(_loc2_);
         }
      }
      
      public function get protocol() : String
      {
         throw new IllegalOperationError("Channel subclasses must override " + "the get function for \'protocol\' to return the proper protocol " + "string.");
      }
      
      mx_internal function get realtime() : Boolean
      {
         return false;
      }
      
      public function get requestTimeout() : int
      {
         return this._requestTimeout;
      }
      
      public function set requestTimeout(param1:int) : void
      {
         this._requestTimeout = param1;
      }
      
      protected function get shouldBeConnected() : Boolean
      {
         return this._shouldBeConnected;
      }
      
      public function get uri() : String
      {
         return this._uri;
      }
      
      public function set uri(param1:String) : void
      {
         if(param1 != null)
         {
            this._uri = param1;
            this.calculateEndpoint();
         }
      }
      
      public function get url() : String
      {
         return this.uri;
      }
      
      public function set url(param1:String) : void
      {
         this.uri = param1;
      }
      
      public function get useSmallMessages() : Boolean
      {
         return this._smallMessagesSupported && this.enableSmallMessages;
      }
      
      public function set useSmallMessages(param1:Boolean) : void
      {
         this._smallMessagesSupported = param1;
      }
      
      public function applySettings(param1:XML) : void
      {
         if(Log.isInfo())
         {
            this._log.info("\'{0}\' channel settings are:\n{1}",this.id,param1);
         }
         if(param1.properties.length() == 0)
         {
            return;
         }
         var _loc2_:XML = param1.properties[0];
         this.applyClientLoadBalancingSettings(_loc2_);
         if(_loc2_[CONNECT_TIMEOUT_SECONDS].length() != 0)
         {
            this.connectTimeout = _loc2_[CONNECT_TIMEOUT_SECONDS].toString();
         }
         if(_loc2_[RECORD_MESSAGE_TIMES].length() != 0)
         {
            this._recordMessageTimes = _loc2_[RECORD_MESSAGE_TIMES].toString() == TRUE;
         }
         if(_loc2_[RECORD_MESSAGE_SIZES].length() != 0)
         {
            this._recordMessageSizes = _loc2_[RECORD_MESSAGE_SIZES].toString() == TRUE;
         }
         if(_loc2_[REQUEST_TIMEOUT_SECONDS].length() != 0)
         {
            this.requestTimeout = _loc2_[REQUEST_TIMEOUT_SECONDS].toString();
         }
         var _loc3_:XMLList = _loc2_[SERIALIZATION];
         if(_loc3_.length() != 0 && _loc3_[ENABLE_SMALL_MESSAGES].toString() == FALSE)
         {
            this.enableSmallMessages = false;
         }
      }
      
      protected function applyClientLoadBalancingSettings(param1:XML) : void
      {
         var _loc5_:XML = null;
         var _loc2_:XMLList = param1[CLIENT_LOAD_BALANCING];
         if(_loc2_.length() == 0)
         {
            return;
         }
         var _loc3_:int = int(_loc2_.url.length());
         if(_loc3_ == 0)
         {
            return;
         }
         var _loc4_:Array = new Array();
         for each(_loc5_ in _loc2_.url)
         {
            _loc4_.push(_loc5_.toString());
         }
         this.shuffle(_loc4_);
         if(Log.isInfo())
         {
            this._log.info("\'{0}\' channel picked {1} as its main url.",this.id,_loc4_[0]);
         }
         this.url = _loc4_[0];
         var _loc6_:Array = _loc4_.slice(1);
         if(_loc6_.length > 0)
         {
            this.failoverURIs = _loc6_;
         }
      }
      
      final public function connect(param1:ChannelSet) : void
      {
         var _loc5_:FlexClient = null;
         var _loc2_:Boolean = false;
         var _loc3_:int = int(this._channelSets.length);
         var _loc4_:int = 0;
         while(_loc4_ < this._channelSets.length)
         {
            if(this._channelSets[_loc4_] == param1)
            {
               _loc2_ = true;
               break;
            }
            _loc4_++;
         }
         this._shouldBeConnected = true;
         if(!_loc2_)
         {
            this._channelSets.push(param1);
            addEventListener(ChannelEvent.CONNECT,param1.channelConnectHandler);
            addEventListener(ChannelEvent.DISCONNECT,param1.channelDisconnectHandler);
            addEventListener(ChannelFaultEvent.FAULT,param1.channelFaultHandler);
         }
         if(this.connected)
         {
            param1.channelConnectHandler(ChannelEvent.createEvent(ChannelEvent.CONNECT,this,false,false,this.connected));
         }
         else if(!this._connecting)
         {
            this._connecting = true;
            if(this.connectTimeout > 0)
            {
               this._connectTimer = new Timer(this.connectTimeout * 1000,1);
               this._connectTimer.addEventListener(TimerEvent.TIMER,this.connectTimeoutHandler);
               this._connectTimer.start();
            }
            if(FlexClient.getInstance().id == null)
            {
               _loc5_ = FlexClient.getInstance();
               if(!_loc5_.mx_internal::waitForFlexClientId)
               {
                  _loc5_.mx_internal::waitForFlexClientId = true;
                  this._ownsWaitGuard = true;
                  this.internalConnect();
               }
               else
               {
                  _loc5_.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,this.flexClientWaitHandler);
               }
            }
            else
            {
               this.internalConnect();
            }
         }
      }
      
      final public function disconnect(param1:ChannelSet) : void
      {
         if(this._ownsWaitGuard)
         {
            this._ownsWaitGuard = false;
            FlexClient.getInstance().mx_internal::waitForFlexClientId = false;
         }
         var _loc2_:int = param1 != null ? int(this._channelSets.indexOf(param1)) : -1;
         if(_loc2_ != -1)
         {
            this._channelSets.splice(_loc2_,1);
            removeEventListener(ChannelEvent.CONNECT,param1.channelConnectHandler,false);
            removeEventListener(ChannelEvent.DISCONNECT,param1.channelDisconnectHandler,false);
            removeEventListener(ChannelFaultEvent.FAULT,param1.channelFaultHandler,false);
            if(this.connected)
            {
               param1.channelDisconnectHandler(ChannelEvent.createEvent(ChannelEvent.DISCONNECT,this,false));
            }
            if(this._channelSets.length == 0)
            {
               this._shouldBeConnected = false;
               if(this.connected)
               {
                  this.internalDisconnect();
               }
            }
         }
      }
      
      public function logout(param1:MessageAgent) : void
      {
         var _loc2_:CommandMessage = null;
         if(this.connected && this.authenticated && this.credentials || this.mx_internal::authenticating && this.credentials)
         {
            _loc2_ = new CommandMessage();
            _loc2_.operation = CommandMessage.LOGOUT_OPERATION;
            this.internalSend(new AuthenticationMessageResponder(param1,_loc2_,this,this._log));
            this.mx_internal::authenticating = true;
         }
         this.credentials = null;
      }
      
      public function send(param1:MessageAgent, param2:IMessage) : void
      {
         var _loc4_:String = null;
         if(param2.destination.length == 0)
         {
            if(param1.destination.length == 0)
            {
               _loc4_ = this.resourceManager.getString("messaging","noDestinationSpecified");
               throw new InvalidDestinationError(_loc4_);
            }
            param2.destination = param1.destination;
         }
         if(Log.isDebug())
         {
            this._log.debug("\'{0}\' channel sending message:\n{1}",this.id,param2.toString());
         }
         param2.headers[AbstractMessage.ENDPOINT_HEADER] = this.id;
         var _loc3_:MessageResponder = this.getMessageResponder(param1,param2);
         this.initializeRequestTimeout(_loc3_);
         this.internalSend(_loc3_);
      }
      
      public function setCredentials(param1:String, param2:MessageAgent = null, param3:String = null) : void
      {
         var _loc5_:CommandMessage = null;
         var _loc4_:* = this.credentials !== param1;
         if(this.mx_internal::authenticating && _loc4_)
         {
            throw new IllegalOperationError("Credentials cannot be set while authenticating or logging out.");
         }
         if(this.authenticated && _loc4_)
         {
            throw new IllegalOperationError("Credentials cannot be set when already authenticated. Logout must be performed before changing credentials.");
         }
         this.credentials = param1;
         if(this.connected && _loc4_ && param1 != null)
         {
            this.mx_internal::authenticating = true;
            _loc5_ = new CommandMessage();
            _loc5_.operation = CommandMessage.LOGIN_OPERATION;
            _loc5_.body = param1;
            if(param3 != null)
            {
               _loc5_.headers[CommandMessage.CREDENTIALS_CHARSET_HEADER] = param3;
            }
            this.internalSend(new AuthenticationMessageResponder(param2,_loc5_,this,this._log));
         }
      }
      
      public function get mpiEnabled() : Boolean
      {
         return this._recordMessageSizes || this._recordMessageTimes;
      }
      
      mx_internal function internalSetCredentials(param1:String) : void
      {
         this.credentials = param1;
      }
      
      mx_internal function sendInternalMessage(param1:MessageResponder) : void
      {
         this.internalSend(param1);
      }
      
      protected function connectFailed(param1:ChannelFaultEvent) : void
      {
         this.shutdownConnectTimer();
         this.setConnected(false);
         if(Log.isError())
         {
            this._log.error("\'{0}\' channel connect failed.",this.id);
         }
         if(!param1.rejected && this.shouldAttemptFailover())
         {
            this._connecting = true;
            this.failover();
         }
         else
         {
            this.connectCleanup();
         }
         if(this.reconnecting)
         {
            param1.reconnecting = true;
         }
         dispatchEvent(param1);
      }
      
      protected function connectSuccess() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         this.shutdownConnectTimer();
         if(ServerConfig.mx_internal::fetchedConfig(this.endpoint))
         {
            _loc1_ = 0;
            while(_loc1_ < this.channelSets.length)
            {
               _loc2_ = ChannelSet(this.channelSets[_loc1_]).messageAgents;
               _loc3_ = 0;
               while(_loc3_ < _loc2_.length)
               {
                  _loc2_[_loc3_].needsConfig = false;
                  _loc3_++;
               }
               _loc1_++;
            }
         }
         this.setConnected(true);
         this._failoverIndex = -1;
         if(Log.isInfo())
         {
            this._log.info("\'{0}\' channel is connected.",this.id);
         }
         dispatchEvent(ChannelEvent.createEvent(ChannelEvent.CONNECT,this,this.reconnecting));
         this.connectCleanup();
      }
      
      protected function connectTimeoutHandler(param1:TimerEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:ChannelFaultEvent = null;
         this.shutdownConnectTimer();
         if(!this.connected)
         {
            this._shouldBeConnected = false;
            _loc2_ = this.resourceManager.getString("messaging","connectTimedOut");
            _loc3_ = ChannelFaultEvent.createEvent(this,false,"Channel.Connect.Failed","error",_loc2_);
            this.connectFailed(_loc3_);
         }
      }
      
      protected function disconnectSuccess(param1:Boolean = false) : void
      {
         this.setConnected(false);
         if(Log.isInfo())
         {
            this._log.info("\'{0}\' channel disconnected.",this.id);
         }
         if(!param1 && this.shouldAttemptFailover())
         {
            this._connecting = true;
            this.failover();
         }
         else
         {
            this.connectCleanup();
         }
         dispatchEvent(ChannelEvent.createEvent(ChannelEvent.DISCONNECT,this,this.reconnecting,param1));
      }
      
      protected function disconnectFailed(param1:ChannelFaultEvent) : void
      {
         this._connecting = false;
         this.setConnected(false);
         if(Log.isError())
         {
            this._log.error("\'{0}\' channel disconnect failed.",this.id);
         }
         if(this.reconnecting)
         {
            this.resetToPrimaryURI();
            param1.reconnecting = false;
         }
         dispatchEvent(param1);
      }
      
      protected function flexClientWaitHandler(param1:PropertyChangeEvent) : void
      {
         var _loc2_:FlexClient = null;
         if(param1.property == "waitForFlexClientId")
         {
            _loc2_ = param1.source as FlexClient;
            if(_loc2_.mx_internal::waitForFlexClientId == false)
            {
               _loc2_.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE,this.flexClientWaitHandler);
               _loc2_.mx_internal::waitForFlexClientId = true;
               this._ownsWaitGuard = true;
               this.internalConnect();
            }
         }
      }
      
      protected function getMessageResponder(param1:MessageAgent, param2:IMessage) : MessageResponder
      {
         throw new IllegalOperationError("Channel subclasses must override " + " getMessageResponder().");
      }
      
      protected function internalConnect() : void
      {
      }
      
      protected function internalDisconnect(param1:Boolean = false) : void
      {
      }
      
      protected function internalSend(param1:MessageResponder) : void
      {
      }
      
      protected function handleServerMessagingVersion(param1:Number) : void
      {
         this.useSmallMessages = param1 >= this.messagingVersion;
      }
      
      protected function setFlexClientIdOnMessage(param1:IMessage) : void
      {
         var _loc2_:String = FlexClient.getInstance().id;
         param1.headers[AbstractMessage.FLEX_CLIENT_ID_HEADER] = _loc2_ != null ? _loc2_ : FlexClient.mx_internal::NULL_FLEXCLIENT_ID;
      }
      
      private function calculateEndpoint() : void
      {
         var _loc3_:String = null;
         if(this.uri == null)
         {
            _loc3_ = this.resourceManager.getString("messaging","noURLSpecified");
            throw new InvalidChannelError(_loc3_);
         }
         var _loc1_:String = this.uri;
         var _loc2_:String = URLUtil.getProtocol(_loc1_);
         if(_loc2_.length == 0)
         {
            _loc1_ = URLUtil.getFullURL(LoaderConfig.url,_loc1_);
         }
         if(URLUtil.hasTokens(_loc1_) && !URLUtil.hasUnresolvableTokens())
         {
            this._isEndpointCalculated = false;
            return;
         }
         _loc1_ = URLUtil.replaceTokens(_loc1_);
         _loc2_ = URLUtil.getProtocol(_loc1_);
         if(_loc2_.length > 0)
         {
            this._endpoint = URLUtil.replaceProtocol(_loc1_,this.protocol);
         }
         else
         {
            this._endpoint = this.protocol + ":" + _loc1_;
         }
         this._isEndpointCalculated = true;
         if(Log.isInfo())
         {
            this._log.info("\'{0}\' channel endpoint set to {1}",this.id,this._endpoint);
         }
      }
      
      private function initializeRequestTimeout(param1:MessageResponder) : void
      {
         var _loc2_:IMessage = param1.message;
         if(_loc2_.headers[AbstractMessage.REQUEST_TIMEOUT_HEADER] != null)
         {
            param1.startRequestTimeout(_loc2_.headers[AbstractMessage.REQUEST_TIMEOUT_HEADER]);
         }
         else if(this.requestTimeout > 0)
         {
            param1.startRequestTimeout(this.requestTimeout);
         }
      }
      
      private function shouldAttemptFailover() : Boolean
      {
         return this._shouldBeConnected && (this._previouslyConnected || this.mx_internal::reliableReconnectDuration != -1 || this._failoverURIs != null && this._failoverURIs.length > 0);
      }
      
      private function failover() : void
      {
         var _loc1_:Class = null;
         var _loc2_:int = 0;
         var _loc3_:ChannelSet = null;
         var _loc4_:int = 0;
         var _loc5_:Number = NaN;
         var _loc6_:int = 0;
         if(this._previouslyConnected)
         {
            this._previouslyConnected = false;
            _loc1_ = null;
            try
            {
               _loc1_ = getDefinitionByName("mx.messaging.AdvancedChannelSet") as Class;
            }
            catch(ignore:Error)
            {
            }
            _loc2_ = -1;
            if(_loc1_ != null)
            {
               for each(_loc3_ in this.channelSets)
               {
                  if(_loc3_ is _loc1_)
                  {
                     _loc4_ = int((_loc3_ as _loc1_)["reliableReconnectDuration"]);
                     if(_loc4_ > _loc2_)
                     {
                        _loc2_ = _loc4_;
                     }
                  }
               }
            }
            if(_loc2_ != -1)
            {
               this.setReconnecting(true);
               this.mx_internal::reliableReconnectDuration = _loc2_;
               this._reliableReconnectBeginTimestamp = new Date().valueOf();
               new AsyncDispatcher(this.reconnect,null,1);
               return;
            }
         }
         if(this.mx_internal::reliableReconnectDuration != -1)
         {
            this._reliableReconnectLastTimestamp = new Date().valueOf();
            _loc5_ = this.mx_internal::reliableReconnectDuration - (this._reliableReconnectLastTimestamp - this._reliableReconnectBeginTimestamp);
            if(_loc5_ > 0)
            {
               _loc6_ = 1000;
               _loc6_ << ++this._reliableReconnectAttempts;
               if(_loc6_ < _loc5_)
               {
                  new AsyncDispatcher(this.reconnect,null,_loc6_);
                  return;
               }
            }
            this.reliableReconnectCleanup();
         }
         ++this._failoverIndex;
         if(this._failoverIndex + 1 <= this.failoverURIs.length)
         {
            this.setReconnecting(true);
            this.uri = this.failoverURIs[this._failoverIndex];
            if(Log.isInfo())
            {
               this._log.info("\'{0}\' channel attempting to connect to {1}.",this.id,this.endpoint);
            }
            new AsyncDispatcher(this.reconnect,null,1);
         }
         else
         {
            if(Log.isInfo())
            {
               this._log.info("\'{0}\' channel has exhausted failover options and has reset to its primary endpoint.",this.id);
            }
            this.resetToPrimaryURI();
         }
      }
      
      private function connectCleanup() : void
      {
         if(this._ownsWaitGuard)
         {
            this._ownsWaitGuard = false;
            FlexClient.getInstance().mx_internal::waitForFlexClientId = false;
         }
         this._connecting = false;
         this.setReconnecting(false);
         this.reliableReconnectCleanup();
      }
      
      private function reconnect(param1:TimerEvent = null) : void
      {
         this.internalConnect();
      }
      
      private function reliableReconnectCleanup() : void
      {
         this.mx_internal::reliableReconnectDuration = -1;
         this._reliableReconnectBeginTimestamp = 0;
         this._reliableReconnectLastTimestamp = 0;
         this._reliableReconnectAttempts = 0;
      }
      
      private function resetToPrimaryURI() : void
      {
         this._connecting = false;
         this.setReconnecting(false);
         this.uri = this._primaryURI;
         this._failoverIndex = -1;
      }
      
      private function shuffle(param1:Array) : void
      {
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc2_:int = int(param1.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc4_ = Math.floor(Math.random() * _loc2_);
            if(_loc4_ != _loc3_)
            {
               _loc5_ = param1[_loc3_];
               param1[_loc3_] = param1[_loc4_];
               param1[_loc4_] = _loc5_;
            }
            _loc3_++;
         }
      }
      
      private function shutdownConnectTimer() : void
      {
         if(this._connectTimer != null)
         {
            this._connectTimer.stop();
            this._connectTimer.removeEventListener(TimerEvent.TIMER,this.connectTimeoutHandler);
            this._connectTimer = null;
         }
      }
   }
}

import mx.core.mx_internal;
import mx.logging.ILogger;
import mx.logging.Log;
import mx.messaging.events.ChannelFaultEvent;
import mx.messaging.messages.CommandMessage;
import mx.messaging.messages.ErrorMessage;
import mx.messaging.messages.IMessage;

use namespace mx_internal;

class AuthenticationMessageResponder extends MessageResponder
{
   
   private var _log:ILogger;
   
   public function AuthenticationMessageResponder(param1:MessageAgent, param2:IMessage, param3:Channel, param4:ILogger)
   {
      super(param1,param2,param3);
      this._log = param4;
   }
   
   override protected function resultHandler(param1:IMessage) : void
   {
      var _loc2_:CommandMessage = message as CommandMessage;
      channel.mx_internal::authenticating = false;
      if(_loc2_.operation == CommandMessage.LOGIN_OPERATION)
      {
         if(Log.isDebug())
         {
            this._log.debug("Login successful");
         }
         channel.mx_internal::setAuthenticated(true);
      }
      else
      {
         if(Log.isDebug())
         {
            this._log.debug("Logout successful");
         }
         channel.mx_internal::setAuthenticated(false);
      }
   }
   
   override protected function statusHandler(param1:IMessage) : void
   {
      var _loc3_:ErrorMessage = null;
      var _loc4_:ChannelFaultEvent = null;
      var _loc2_:CommandMessage = CommandMessage(message);
      if(Log.isDebug())
      {
         this._log.debug("{1} failure: {0}",param1.toString(),_loc2_.operation == CommandMessage.LOGIN_OPERATION ? "Login" : "Logout");
      }
      channel.mx_internal::authenticating = false;
      channel.mx_internal::setAuthenticated(false);
      if(agent != null && Boolean(agent.hasPendingRequestForMessage(message)))
      {
         agent.fault(ErrorMessage(param1),message);
      }
      else
      {
         _loc3_ = ErrorMessage(param1);
         _loc4_ = ChannelFaultEvent.createEvent(channel,false,"Channel.Authentication.Error","warn",_loc3_.faultString);
         _loc4_.rootCause = _loc3_;
         channel.dispatchEvent(_loc4_);
      }
   }
}
