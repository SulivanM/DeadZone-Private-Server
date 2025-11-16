package mx.messaging
{
   import flash.errors.IllegalOperationError;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import mx.core.mx_internal;
   import mx.events.PropertyChangeEvent;
   import mx.messaging.channels.NetConnectionChannel;
   import mx.messaging.channels.PollingChannel;
   import mx.messaging.config.ServerConfig;
   import mx.messaging.errors.NoChannelAvailableError;
   import mx.messaging.events.ChannelEvent;
   import mx.messaging.events.ChannelFaultEvent;
   import mx.messaging.events.MessageEvent;
   import mx.messaging.events.MessageFaultEvent;
   import mx.messaging.messages.AcknowledgeMessage;
   import mx.messaging.messages.CommandMessage;
   import mx.messaging.messages.ErrorMessage;
   import mx.messaging.messages.IMessage;
   import mx.resources.IResourceManager;
   import mx.resources.ResourceManager;
   import mx.rpc.AsyncDispatcher;
   import mx.rpc.AsyncToken;
   import mx.rpc.events.AbstractEvent;
   import mx.rpc.events.FaultEvent;
   import mx.rpc.events.ResultEvent;
   import mx.utils.Base64Encoder;
   
   use namespace mx_internal;
   
   public class ChannelSet extends EventDispatcher
   {
      
      private var _authAgent:AuthenticationAgent;
      
      private var _connecting:Boolean;
      
      private var _credentials:String;
      
      private var _credentialsCharset:String;
      
      private var _currentChannelIndex:int;
      
      private var _hasRequestedClusterEndpoints:Boolean;
      
      private var _heartbeatTimer:Timer;
      
      private var _hunting:Boolean;
      
      private var _pendingMessages:Dictionary;
      
      private var _pendingSends:Array;
      
      private var _reconnectTimer:Timer = null;
      
      private var _shouldBeConnected:Boolean;
      
      private var _shouldHunt:Boolean;
      
      private var resourceManager:IResourceManager = ResourceManager.getInstance();
      
      private var _authenticated:Boolean;
      
      private var _channels:Array;
      
      private var _channelIds:Array;
      
      private var _currentChannel:Channel;
      
      private var _channelFailoverURIs:Object;
      
      private var _configured:Boolean;
      
      private var _connected:Boolean;
      
      private var _clustered:Boolean;
      
      private var _heartbeatInterval:int = 0;
      
      private var _initialDestinationId:String;
      
      private var _messageAgents:Array;
      
      public function ChannelSet(param1:Array = null, param2:Boolean = false)
      {
         super();
         this._clustered = param2;
         this._connected = false;
         this._connecting = false;
         this._currentChannelIndex = -1;
         if(param1 != null)
         {
            this._channelIds = param1;
            this._channels = new Array(this._channelIds.length);
            this._configured = true;
         }
         else
         {
            this._channels = [];
            this._configured = false;
         }
         this._hasRequestedClusterEndpoints = false;
         this._hunting = false;
         this._messageAgents = [];
         this._pendingMessages = new Dictionary();
         this._pendingSends = [];
         this._shouldBeConnected = false;
         this._shouldHunt = true;
      }
      
      [Bindable(event="propertyChange")]
      public function get authenticated() : Boolean
      {
         return this._authenticated;
      }
      
      mx_internal function setAuthenticated(param1:Boolean, param2:String, param3:Boolean = true) : void
      {
         var _loc4_:PropertyChangeEvent = null;
         var _loc5_:MessageAgent = null;
         var _loc6_:int = 0;
         if(this._authenticated != param1)
         {
            _loc4_ = PropertyChangeEvent.createUpdateEvent(this,"authenticated",this._authenticated,param1);
            this._authenticated = param1;
            if(param3)
            {
               _loc6_ = 0;
               while(_loc6_ < this._messageAgents.length)
               {
                  _loc5_ = MessageAgent(this._messageAgents[_loc6_]);
                  _loc5_.mx_internal::setAuthenticated(param1,param2);
                  _loc6_++;
               }
            }
            if(!param1 && this._authAgent != null)
            {
               this._authAgent.state = AuthenticationAgent.LOGGED_OUT_STATE;
            }
            dispatchEvent(_loc4_);
         }
      }
      
      public function get channels() : Array
      {
         return this._channels;
      }
      
      public function set channels(param1:Array) : void
      {
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         if(this.mx_internal::configured)
         {
            _loc5_ = this.resourceManager.getString("messaging","cannotAddWhenConfigured");
            throw new IllegalOperationError(_loc5_);
         }
         var _loc2_:Array = this._channels.slice();
         var _loc3_:int = int(_loc2_.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            this.removeChannel(_loc2_[_loc4_]);
            _loc4_++;
         }
         if(param1 != null && param1.length > 0)
         {
            _loc6_ = int(param1.length);
            _loc7_ = 0;
            while(_loc7_ < _loc6_)
            {
               this.addChannel(param1[_loc7_]);
               _loc7_++;
            }
         }
      }
      
      public function get channelIds() : Array
      {
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(this._channelIds != null)
         {
            return this._channelIds;
         }
         _loc1_ = [];
         _loc2_ = int(this._channels.length);
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            if(this._channels[_loc3_] != null)
            {
               _loc1_.push(this._channels[_loc3_].id);
            }
            else
            {
               _loc1_.push(null);
            }
            _loc3_++;
         }
         return _loc1_;
      }
      
      public function get currentChannel() : Channel
      {
         return this._currentChannel;
      }
      
      mx_internal function get channelFailoverURIs() : Object
      {
         return this._channelFailoverURIs;
      }
      
      mx_internal function set channelFailoverURIs(param1:Object) : void
      {
         var _loc4_:Channel = null;
         this._channelFailoverURIs = param1;
         var _loc2_:int = int(this._channels.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc4_ = this._channels[_loc3_];
            if(_loc4_ == null)
            {
               break;
            }
            if(this._channelFailoverURIs[_loc4_.id] != null)
            {
               _loc4_.failoverURIs = this._channelFailoverURIs[_loc4_.id];
            }
            _loc3_++;
         }
      }
      
      mx_internal function get configured() : Boolean
      {
         return this._configured;
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
            _loc2_ = PropertyChangeEvent.createUpdateEvent(this,"connected",this._connected,param1);
            this._connected = param1;
            dispatchEvent(_loc2_);
            this.mx_internal::setAuthenticated(param1 && Boolean(this.currentChannel) && this.currentChannel.authenticated,this._credentials,false);
            if(!this.connected)
            {
               this.unscheduleHeartbeat();
            }
            else if(this.heartbeatInterval > 0)
            {
               this.scheduleHeartbeat();
            }
         }
      }
      
      public function get clustered() : Boolean
      {
         return this._clustered;
      }
      
      public function set clustered(param1:Boolean) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         if(this._clustered != param1)
         {
            if(param1)
            {
               _loc2_ = this.channelIds;
               _loc3_ = int(_loc2_.length);
               _loc4_ = 0;
               while(_loc4_ < _loc3_)
               {
                  if(_loc2_[_loc4_] == null)
                  {
                     _loc5_ = this.resourceManager.getString("messaging","cannotSetClusteredWithdNullChannelIds");
                     throw new IllegalOperationError(_loc5_);
                  }
                  _loc4_++;
               }
            }
            this._clustered = param1;
         }
      }
      
      public function get heartbeatInterval() : int
      {
         return this._heartbeatInterval;
      }
      
      public function set heartbeatInterval(param1:int) : void
      {
         var _loc2_:PropertyChangeEvent = null;
         if(this._heartbeatInterval != param1)
         {
            _loc2_ = PropertyChangeEvent.createUpdateEvent(this,"heartbeatInterval",this._heartbeatInterval,param1);
            this._heartbeatInterval = param1;
            dispatchEvent(_loc2_);
            if(this._heartbeatInterval > 0 && this.connected)
            {
               this.scheduleHeartbeat();
            }
         }
      }
      
      public function get initialDestinationId() : String
      {
         return this._initialDestinationId;
      }
      
      public function set initialDestinationId(param1:String) : void
      {
         this._initialDestinationId = param1;
      }
      
      public function get messageAgents() : Array
      {
         return this._messageAgents;
      }
      
      override public function toString() : String
      {
         var _loc1_:String = "[ChannelSet ";
         var _loc2_:uint = 0;
         while(_loc2_ < this._channels.length)
         {
            if(this._channels[_loc2_] != null)
            {
               _loc1_ += this._channels[_loc2_].id + " ";
            }
            _loc2_++;
         }
         return _loc1_ + "]";
      }
      
      public function addChannel(param1:Channel) : void
      {
         var _loc2_:String = null;
         if(param1 == null)
         {
            return;
         }
         if(this.mx_internal::configured)
         {
            _loc2_ = this.resourceManager.getString("messaging","cannotAddWhenConfigured");
            throw new IllegalOperationError(_loc2_);
         }
         if(this.clustered && param1.id == null)
         {
            _loc2_ = this.resourceManager.getString("messaging","cannotAddNullIdChannelWhenClustered");
            throw new IllegalOperationError(_loc2_);
         }
         if(this._channels.indexOf(param1) != -1)
         {
            return;
         }
         this._channels.push(param1);
         if(this._credentials)
         {
            param1.setCredentials(this._credentials,null,this._credentialsCharset);
         }
      }
      
      public function removeChannel(param1:Channel) : void
      {
         var _loc3_:String = null;
         if(this.mx_internal::configured)
         {
            _loc3_ = this.resourceManager.getString("messaging","cannotRemoveWhenConfigured");
            throw new IllegalOperationError(_loc3_);
         }
         var _loc2_:int = int(this._channels.indexOf(param1));
         if(_loc2_ > -1)
         {
            this._channels.splice(_loc2_,1);
            if(this._currentChannel != null && this._currentChannel == param1)
            {
               if(this.connected)
               {
                  this._shouldHunt = false;
                  this.disconnectChannel();
               }
               this._currentChannel = null;
               this._currentChannelIndex = -1;
            }
         }
      }
      
      public function connect(param1:MessageAgent) : void
      {
         if(param1 != null && this._messageAgents.indexOf(param1) == -1)
         {
            this._shouldBeConnected = true;
            this._messageAgents.push(param1);
            param1.mx_internal::internalSetChannelSet(this);
            addEventListener(ChannelEvent.CONNECT,param1.channelConnectHandler);
            addEventListener(ChannelEvent.DISCONNECT,param1.channelDisconnectHandler);
            addEventListener(ChannelFaultEvent.FAULT,param1.channelFaultHandler);
            if(this.connected && !param1.mx_internal::needsConfig)
            {
               param1.channelConnectHandler(ChannelEvent.createEvent(ChannelEvent.CONNECT,this._currentChannel,false,false,this.connected));
            }
         }
      }
      
      public function disconnect(param1:MessageAgent) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:PendingSend = null;
         if(param1 == null)
         {
            _loc2_ = this._messageAgents.slice();
            _loc3_ = int(_loc2_.length);
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               _loc2_[_loc4_].disconnect();
               _loc4_++;
            }
            if(this._authAgent != null)
            {
               this._authAgent.state = AuthenticationAgent.SHUTDOWN_STATE;
               this._authAgent = null;
            }
         }
         else
         {
            _loc5_ = param1 != null ? int(this._messageAgents.indexOf(param1)) : -1;
            if(_loc5_ != -1)
            {
               this._messageAgents.splice(_loc5_,1);
               removeEventListener(ChannelEvent.CONNECT,param1.channelConnectHandler);
               removeEventListener(ChannelEvent.DISCONNECT,param1.channelDisconnectHandler);
               removeEventListener(ChannelFaultEvent.FAULT,param1.channelFaultHandler);
               if(this.connected || this._connecting)
               {
                  param1.channelDisconnectHandler(ChannelEvent.createEvent(ChannelEvent.DISCONNECT,this._currentChannel,false));
               }
               else
               {
                  _loc6_ = int(this._pendingSends.length);
                  _loc7_ = 0;
                  while(_loc7_ < _loc6_)
                  {
                     _loc8_ = PendingSend(this._pendingSends[_loc7_]);
                     if(_loc8_.agent == param1)
                     {
                        this._pendingSends.splice(_loc7_,1);
                        _loc7_--;
                        _loc6_--;
                        delete this._pendingMessages[_loc8_.message];
                     }
                     _loc7_++;
                  }
               }
               if(this._messageAgents.length == 0)
               {
                  this._shouldBeConnected = false;
                  this._currentChannelIndex = -1;
                  if(this.connected)
                  {
                     this.disconnectChannel();
                  }
               }
               if(param1.mx_internal::channelSetMode == MessageAgent.mx_internal::AUTO_CONFIGURED_CHANNELSET)
               {
                  param1.mx_internal::internalSetChannelSet(null);
               }
            }
         }
      }
      
      public function disconnectAll() : void
      {
         this.disconnect(null);
      }
      
      public function channelConnectHandler(param1:ChannelEvent) : void
      {
         var _loc3_:PendingSend = null;
         var _loc4_:CommandMessage = null;
         var _loc5_:AcknowledgeMessage = null;
         this._connecting = false;
         this._connected = true;
         this._currentChannelIndex = -1;
         while(this._pendingSends.length > 0)
         {
            _loc3_ = PendingSend(this._pendingSends.shift());
            delete this._pendingMessages[_loc3_.message];
            _loc4_ = _loc3_.message as CommandMessage;
            if(_loc4_ != null)
            {
               if(_loc4_.operation == CommandMessage.TRIGGER_CONNECT_OPERATION)
               {
                  _loc5_ = new AcknowledgeMessage();
                  _loc5_.clientId = _loc3_.agent.clientId;
                  _loc5_.correlationId = _loc4_.messageId;
                  _loc3_.agent.acknowledge(_loc5_,_loc4_);
                  continue;
               }
               if(!_loc3_.agent.mx_internal::configRequested && _loc3_.agent.mx_internal::needsConfig && _loc4_.operation == CommandMessage.CLIENT_PING_OPERATION)
               {
                  _loc4_.headers[CommandMessage.NEEDS_CONFIG_HEADER] = true;
                  _loc3_.agent.mx_internal::configRequested = true;
               }
            }
            this.send(_loc3_.agent,_loc3_.message);
         }
         if(this._hunting)
         {
            param1.reconnecting = true;
            this._hunting = false;
         }
         dispatchEvent(param1);
         var _loc2_:PropertyChangeEvent = PropertyChangeEvent.createUpdateEvent(this,"connected",false,true);
         dispatchEvent(_loc2_);
      }
      
      public function channelDisconnectHandler(param1:ChannelEvent) : void
      {
         this._connecting = false;
         this.setConnected(false);
         if(this._shouldBeConnected && !param1.reconnecting && !param1.rejected)
         {
            if(this._shouldHunt && this.hunt())
            {
               param1.reconnecting = true;
               dispatchEvent(param1);
               if(this._currentChannel is NetConnectionChannel)
               {
                  if(this._reconnectTimer == null)
                  {
                     this._reconnectTimer = new Timer(1,1);
                     this._reconnectTimer.addEventListener(TimerEvent.TIMER,this.reconnectChannel);
                     this._reconnectTimer.start();
                  }
               }
               else
               {
                  this.connectChannel();
               }
            }
            else
            {
               dispatchEvent(param1);
               this.faultPendingSends(param1);
            }
         }
         else
         {
            dispatchEvent(param1);
            if(param1.rejected)
            {
               this.faultPendingSends(param1);
            }
         }
         this._shouldHunt = true;
      }
      
      public function channelFaultHandler(param1:ChannelFaultEvent) : void
      {
         if(param1.channel.connected)
         {
            dispatchEvent(param1);
         }
         else
         {
            this._connecting = false;
            this.setConnected(false);
            if(this._shouldBeConnected && !param1.reconnecting && !param1.rejected)
            {
               if(this.hunt())
               {
                  param1.reconnecting = true;
                  dispatchEvent(param1);
                  if(this._currentChannel is NetConnectionChannel)
                  {
                     if(this._reconnectTimer == null)
                     {
                        this._reconnectTimer = new Timer(1,1);
                        this._reconnectTimer.addEventListener(TimerEvent.TIMER,this.reconnectChannel);
                        this._reconnectTimer.start();
                     }
                  }
                  else
                  {
                     this.connectChannel();
                  }
               }
               else
               {
                  dispatchEvent(param1);
                  this.faultPendingSends(param1);
               }
            }
            else
            {
               dispatchEvent(param1);
               if(param1.rejected)
               {
                  this.faultPendingSends(param1);
               }
            }
         }
      }
      
      public function login(param1:String, param2:String, param3:String = null) : AsyncToken
      {
         var _loc7_:String = null;
         var _loc8_:Base64Encoder = null;
         if(this.authenticated)
         {
            throw new IllegalOperationError("ChannelSet is already authenticated.");
         }
         if(this._authAgent != null && this._authAgent.state != AuthenticationAgent.LOGGED_OUT_STATE)
         {
            throw new IllegalOperationError("ChannelSet is in the process of logging in or logging out.");
         }
         if(param3 != Base64Encoder.CHARSET_UTF_8)
         {
            param3 = null;
         }
         var _loc4_:String = null;
         if(param1 != null && param2 != null)
         {
            _loc7_ = param1 + ":" + param2;
            _loc8_ = new Base64Encoder();
            if(param3 == Base64Encoder.CHARSET_UTF_8)
            {
               _loc8_.encodeUTFBytes(_loc7_);
            }
            else
            {
               _loc8_.encode(_loc7_);
            }
            _loc4_ = _loc8_.drain();
         }
         var _loc5_:CommandMessage = new CommandMessage();
         _loc5_.operation = CommandMessage.LOGIN_OPERATION;
         _loc5_.body = _loc4_;
         if(param3 != null)
         {
            _loc5_.headers[CommandMessage.CREDENTIALS_CHARSET_HEADER] = param3;
         }
         _loc5_.destination = "auth";
         var _loc6_:AsyncToken = new AsyncToken(_loc5_);
         if(this._authAgent == null)
         {
            this._authAgent = new AuthenticationAgent(this);
         }
         this._authAgent.registerToken(_loc6_);
         this._authAgent.state = AuthenticationAgent.LOGGING_IN_STATE;
         this.send(this._authAgent,_loc5_);
         return _loc6_;
      }
      
      public function logout(param1:MessageAgent = null) : AsyncToken
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:CommandMessage = null;
         var _loc5_:AsyncToken = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         this._credentials = null;
         if(param1 == null)
         {
            if(this._authAgent != null && (this._authAgent.state == AuthenticationAgent.LOGGING_OUT_STATE || this._authAgent.state == AuthenticationAgent.LOGGING_IN_STATE))
            {
               throw new IllegalOperationError("ChannelSet is in the process of logging in or logging out.");
            }
            _loc2_ = int(this._messageAgents.length);
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               this._messageAgents[_loc3_].internalSetCredentials(null);
               _loc3_++;
            }
            _loc2_ = int(this._channels.length);
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               if(this._channels[_loc3_] != null)
               {
                  this._channels[_loc3_].internalSetCredentials(null);
                  if(this._channels[_loc3_] is PollingChannel)
                  {
                     PollingChannel(this._channels[_loc3_]).disablePolling();
                  }
               }
               _loc3_++;
            }
            _loc4_ = new CommandMessage();
            _loc4_.operation = CommandMessage.LOGOUT_OPERATION;
            _loc4_.destination = "auth";
            _loc5_ = new AsyncToken(_loc4_);
            if(this._authAgent == null)
            {
               this._authAgent = new AuthenticationAgent(this);
            }
            this._authAgent.registerToken(_loc5_);
            this._authAgent.state = AuthenticationAgent.LOGGING_OUT_STATE;
            this.send(this._authAgent,_loc4_);
            return _loc5_;
         }
         _loc6_ = int(this._channels.length);
         _loc7_ = 0;
         while(_loc7_ < _loc6_)
         {
            if(this._channels[_loc7_] != null)
            {
               this._channels[_loc7_].logout(param1);
            }
            _loc7_++;
         }
         return null;
      }
      
      public function send(param1:MessageAgent, param2:IMessage) : void
      {
         var _loc3_:AcknowledgeMessage = null;
         var _loc4_:CommandMessage = null;
         if(this._currentChannel != null && this._currentChannel.connected)
         {
            if(param2 is CommandMessage && CommandMessage(param2).operation == CommandMessage.TRIGGER_CONNECT_OPERATION && !param1.mx_internal::needsConfig)
            {
               _loc3_ = new AcknowledgeMessage();
               _loc3_.clientId = param1.clientId;
               _loc3_.correlationId = param2.messageId;
               new AsyncDispatcher(param1.acknowledge,[_loc3_,param2],1);
               return;
            }
            if(!this._hasRequestedClusterEndpoints && this.clustered)
            {
               _loc4_ = new CommandMessage();
               if(param1 is AuthenticationAgent)
               {
                  _loc4_.destination = this.initialDestinationId;
               }
               else
               {
                  _loc4_.destination = param1.destination;
               }
               _loc4_.operation = CommandMessage.CLUSTER_REQUEST_OPERATION;
               this._currentChannel.mx_internal::sendInternalMessage(new ClusterMessageResponder(_loc4_,this));
               this._hasRequestedClusterEndpoints = true;
            }
            this.unscheduleHeartbeat();
            this._currentChannel.send(param1,param2);
            this.scheduleHeartbeat();
         }
         else
         {
            if(this._pendingMessages[param2] == null)
            {
               this._pendingMessages[param2] = true;
               this._pendingSends.push(new PendingSend(param1,param2));
            }
            if(!this._connecting)
            {
               if(this._currentChannel == null || this._currentChannelIndex == -1)
               {
                  this.hunt();
               }
               if(this._currentChannel is NetConnectionChannel)
               {
                  if(this._reconnectTimer == null)
                  {
                     this._reconnectTimer = new Timer(1,1);
                     this._reconnectTimer.addEventListener(TimerEvent.TIMER,this.reconnectChannel);
                     this._reconnectTimer.start();
                  }
               }
               else
               {
                  this.connectChannel();
               }
            }
         }
      }
      
      public function setCredentials(param1:String, param2:MessageAgent, param3:String = null) : void
      {
         this._credentials = param1;
         var _loc4_:int = int(this._channels.length);
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            if(this._channels[_loc5_] != null)
            {
               this._channels[_loc5_].setCredentials(this._credentials,param2,param3);
            }
            _loc5_++;
         }
      }
      
      mx_internal function authenticationSuccess(param1:AuthenticationAgent, param2:AsyncToken, param3:AcknowledgeMessage) : void
      {
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc4_:CommandMessage = CommandMessage(param2.message);
         var _loc5_:* = _loc4_.operation == CommandMessage.LOGIN_OPERATION;
         var _loc6_:String = _loc5_ ? String(_loc4_.body) : null;
         var _loc7_:Number = 0;
         if(_loc5_)
         {
            this._credentials = _loc6_;
            _loc9_ = int(this._messageAgents.length);
            _loc10_ = 0;
            while(_loc10_ < _loc9_)
            {
               this._messageAgents[_loc10_].internalSetCredentials(_loc6_);
               _loc10_++;
            }
            _loc9_ = int(this._channels.length);
            _loc10_ = 0;
            while(_loc10_ < _loc9_)
            {
               if(this._channels[_loc10_] != null)
               {
                  this._channels[_loc10_].internalSetCredentials(_loc6_);
               }
               _loc10_++;
            }
            param1.state = AuthenticationAgent.LOGGED_IN_STATE;
            this.currentChannel.mx_internal::setAuthenticated(true);
         }
         else
         {
            param1.state = AuthenticationAgent.SHUTDOWN_STATE;
            this._authAgent = null;
            _loc7_ = 250;
            this.disconnect(param1);
            this.currentChannel.mx_internal::setAuthenticated(false);
         }
         var _loc8_:ResultEvent = ResultEvent.createEvent(param3.body,param2,param3);
         if(_loc7_ > 0)
         {
            new AsyncDispatcher(this.dispatchRPCEvent,[_loc8_],_loc7_);
         }
         else
         {
            this.dispatchRPCEvent(_loc8_);
         }
      }
      
      mx_internal function authenticationFailure(param1:AuthenticationAgent, param2:AsyncToken, param3:ErrorMessage) : void
      {
         var _loc4_:MessageFaultEvent = MessageFaultEvent.createEvent(param3);
         var _loc5_:FaultEvent = FaultEvent.createEventFromMessageFault(_loc4_,param2);
         param1.state = AuthenticationAgent.SHUTDOWN_STATE;
         this._authAgent = null;
         this.disconnect(param1);
         this.dispatchRPCEvent(_loc5_);
      }
      
      protected function faultPendingSends(param1:ChannelEvent) : void
      {
         var _loc2_:PendingSend = null;
         var _loc3_:IMessage = null;
         var _loc4_:ErrorMessage = null;
         var _loc5_:ChannelFaultEvent = null;
         while(this._pendingSends.length > 0)
         {
            _loc2_ = this._pendingSends.shift() as PendingSend;
            _loc3_ = _loc2_.message;
            delete this._pendingMessages[_loc3_];
            _loc4_ = new ErrorMessage();
            _loc4_.correlationId = _loc3_.messageId;
            _loc4_.headers[ErrorMessage.RETRYABLE_HINT_HEADER] = true;
            _loc4_.faultCode = "Client.Error.MessageSend";
            _loc4_.faultString = this.resourceManager.getString("messaging","sendFailed");
            if(param1 is ChannelFaultEvent)
            {
               _loc5_ = param1 as ChannelFaultEvent;
               _loc4_.faultDetail = _loc5_.faultCode + " " + _loc5_.faultString + " " + _loc5_.faultDetail;
               if(_loc5_.faultCode == "Channel.Authentication.Error")
               {
                  _loc4_.faultCode = _loc5_.faultCode;
               }
            }
            else
            {
               _loc4_.faultDetail = this.resourceManager.getString("messaging","cannotConnectToDestination");
            }
            _loc4_.rootCause = param1;
            _loc2_.agent.fault(_loc4_,_loc3_);
         }
      }
      
      protected function messageHandler(param1:MessageEvent) : void
      {
         dispatchEvent(param1);
      }
      
      protected function scheduleHeartbeat() : void
      {
         if(this._heartbeatTimer == null && this.heartbeatInterval > 0)
         {
            this._heartbeatTimer = new Timer(this.heartbeatInterval,1);
            this._heartbeatTimer.addEventListener(TimerEvent.TIMER,this.sendHeartbeatHandler);
            this._heartbeatTimer.start();
         }
      }
      
      protected function sendHeartbeatHandler(param1:TimerEvent) : void
      {
         this.unscheduleHeartbeat();
         if(this.currentChannel != null)
         {
            this.sendHeartbeat();
            this.scheduleHeartbeat();
         }
      }
      
      protected function sendHeartbeat() : void
      {
         var _loc1_:PollingChannel = this.currentChannel as PollingChannel;
         if(_loc1_ != null && _loc1_.mx_internal::_shouldPoll)
         {
            return;
         }
         var _loc2_:CommandMessage = new CommandMessage();
         _loc2_.operation = CommandMessage.CLIENT_PING_OPERATION;
         _loc2_.headers[CommandMessage.HEARTBEAT_HEADER] = true;
         this.currentChannel.mx_internal::sendInternalMessage(new MessageResponder(null,_loc2_));
      }
      
      protected function unscheduleHeartbeat() : void
      {
         if(this._heartbeatTimer != null)
         {
            this._heartbeatTimer.stop();
            this._heartbeatTimer.removeEventListener(TimerEvent.TIMER,this.sendHeartbeatHandler);
            this._heartbeatTimer = null;
         }
      }
      
      private function connectChannel() : void
      {
         this._connecting = true;
         this._currentChannel.connect(this);
         this._currentChannel.addEventListener(MessageEvent.MESSAGE,this.messageHandler);
      }
      
      private function disconnectChannel() : void
      {
         this._connecting = false;
         this._currentChannel.removeEventListener(MessageEvent.MESSAGE,this.messageHandler);
         this._currentChannel.disconnect(this);
      }
      
      private function dispatchRPCEvent(param1:AbstractEvent) : void
      {
         param1.mx_internal::callTokenResponders();
         dispatchEvent(param1);
      }
      
      private function hunt() : Boolean
      {
         var _loc1_:String = null;
         if(this._channels.length == 0)
         {
            _loc1_ = this.resourceManager.getString("messaging","noAvailableChannels");
            throw new NoChannelAvailableError(_loc1_);
         }
         if(this._currentChannel != null)
         {
            this.disconnectChannel();
         }
         if(++this._currentChannelIndex >= this._channels.length)
         {
            this._currentChannelIndex = -1;
            return false;
         }
         if(this._currentChannelIndex > 0)
         {
            this._hunting = true;
         }
         if(this.mx_internal::configured)
         {
            if(this._channels[this._currentChannelIndex] != null)
            {
               this._currentChannel = this._channels[this._currentChannelIndex];
            }
            else
            {
               this._currentChannel = ServerConfig.getChannel(this._channelIds[this._currentChannelIndex],this._clustered);
               this._currentChannel.setCredentials(this._credentials);
               this._channels[this._currentChannelIndex] = this._currentChannel;
            }
         }
         else
         {
            this._currentChannel = this._channels[this._currentChannelIndex];
         }
         if(this._channelFailoverURIs != null && this._channelFailoverURIs[this._currentChannel.id] != null)
         {
            this._currentChannel.failoverURIs = this._channelFailoverURIs[this._currentChannel.id];
         }
         return true;
      }
      
      private function reconnectChannel(param1:TimerEvent) : void
      {
         this._reconnectTimer.stop();
         this._reconnectTimer.removeEventListener(TimerEvent.TIMER,this.reconnectChannel);
         this._reconnectTimer = null;
         this.connectChannel();
      }
   }
}

import mx.collections.ArrayCollection;
import mx.core.mx_internal;
import mx.logging.Log;
import mx.messaging.events.ChannelEvent;
import mx.messaging.messages.AcknowledgeMessage;
import mx.messaging.messages.ErrorMessage;
import mx.messaging.messages.IMessage;
import mx.rpc.AsyncToken;

use namespace mx_internal;

class ClusterMessageResponder extends MessageResponder
{
   
   private var _channelSet:ChannelSet;
   
   public function ClusterMessageResponder(param1:IMessage, param2:ChannelSet)
   {
      super(null,param1);
      this._channelSet = param2;
   }
   
   override protected function resultHandler(param1:IMessage) : void
   {
      var _loc2_:Object = null;
      var _loc3_:Array = null;
      var _loc4_:int = 0;
      var _loc5_:int = 0;
      var _loc6_:Object = null;
      var _loc7_:Object = null;
      if(param1.body != null && (param1.body is Array || param1.body is ArrayCollection))
      {
         _loc2_ = {};
         _loc3_ = param1.body is Array ? param1.body as Array : (param1.body as ArrayCollection).toArray();
         _loc4_ = int(_loc3_.length);
         _loc5_ = 0;
         while(_loc5_ < _loc4_)
         {
            _loc6_ = _loc3_[_loc5_];
            for(_loc7_ in _loc6_)
            {
               if(_loc2_[_loc7_] == null)
               {
                  _loc2_[_loc7_] = [];
               }
               _loc2_[_loc7_].push(_loc6_[_loc7_]);
            }
            _loc5_++;
         }
         this._channelSet.mx_internal::channelFailoverURIs = _loc2_;
      }
   }
}

class PendingSend
{
   
   public var agent:MessageAgent;
   
   public var message:IMessage;
   
   public function PendingSend(param1:MessageAgent, param2:IMessage)
   {
      super();
      this.agent = param1;
      this.message = param2;
   }
}

class AuthenticationAgent extends MessageAgent
{
   
   public static const LOGGED_OUT_STATE:int = 0;
   
   public static const LOGGING_IN_STATE:int = 1;
   
   public static const LOGGED_IN_STATE:int = 2;
   
   public static const LOGGING_OUT_STATE:int = 3;
   
   public static const SHUTDOWN_STATE:int = 4;
   
   private var tokens:Object = {};
   
   private var _state:int = 0;
   
   public function AuthenticationAgent(param1:ChannelSet)
   {
      super();
      _log = Log.getLogger("ChannelSet.AuthenticationAgent");
      _agentType = "authentication agent";
      this.channelSet = param1;
   }
   
   public function get state() : int
   {
      return this._state;
   }
   
   public function set state(param1:int) : void
   {
      this._state = param1;
      if(param1 == SHUTDOWN_STATE)
      {
         this.tokens = null;
      }
   }
   
   public function registerToken(param1:AsyncToken) : void
   {
      this.tokens[param1.message.messageId] = param1;
   }
   
   override public function acknowledge(param1:AcknowledgeMessage, param2:IMessage) : void
   {
      var _loc4_:AsyncToken = null;
      if(this.state == SHUTDOWN_STATE)
      {
         return;
      }
      var _loc3_:Boolean = Boolean(param1.headers[AcknowledgeMessage.ERROR_HINT_HEADER]);
      super.acknowledge(param1,param2);
      if(!_loc3_)
      {
         _loc4_ = this.tokens[param2.messageId];
         delete this.tokens[param2.messageId];
         channelSet.mx_internal::authenticationSuccess(this,_loc4_,param1 as AcknowledgeMessage);
      }
   }
   
   override public function fault(param1:ErrorMessage, param2:IMessage) : void
   {
      var _loc4_:AcknowledgeMessage = null;
      if(this.state == SHUTDOWN_STATE)
      {
         return;
      }
      if(param1.rootCause is ChannelEvent && (param1.rootCause as ChannelEvent).type == ChannelEvent.DISCONNECT)
      {
         _loc4_ = new AcknowledgeMessage();
         _loc4_.clientId = clientId;
         _loc4_.correlationId = param2.messageId;
         this.acknowledge(_loc4_,param2);
         return;
      }
      super.fault(param1,param2);
      var _loc3_:AsyncToken = this.tokens[param2.messageId];
      delete this.tokens[param2.messageId];
      channelSet.mx_internal::authenticationFailure(this,_loc3_,param1 as ErrorMessage);
   }
}
