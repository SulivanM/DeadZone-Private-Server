package mx.messaging
{
   import flash.events.EventDispatcher;
   import mx.core.IMXMLObject;
   import mx.core.mx_internal;
   import mx.events.PropertyChangeEvent;
   import mx.logging.ILogger;
   import mx.logging.Log;
   import mx.messaging.channels.PollingChannel;
   import mx.messaging.config.ConfigMap;
   import mx.messaging.config.ServerConfig;
   import mx.messaging.errors.InvalidDestinationError;
   import mx.messaging.events.ChannelEvent;
   import mx.messaging.events.ChannelFaultEvent;
   import mx.messaging.events.MessageAckEvent;
   import mx.messaging.events.MessageEvent;
   import mx.messaging.events.MessageFaultEvent;
   import mx.messaging.messages.AbstractMessage;
   import mx.messaging.messages.AcknowledgeMessage;
   import mx.messaging.messages.CommandMessage;
   import mx.messaging.messages.ErrorMessage;
   import mx.messaging.messages.IMessage;
   import mx.messaging.messages.MessagePerformanceUtils;
   import mx.netmon.NetworkMonitor;
   import mx.resources.IResourceManager;
   import mx.resources.ResourceManager;
   import mx.utils.Base64Encoder;
   import mx.utils.UIDUtil;
   
   use namespace mx_internal;
   
   public class MessageAgent extends EventDispatcher implements IMXMLObject
   {
      
      mx_internal static const AUTO_CONFIGURED_CHANNELSET:int = 0;
      
      mx_internal static const MANUALLY_ASSIGNED_CHANNELSET:int = 1;
      
      protected var _agentType:String = "mx.messaging.MessageAgent";
      
      protected var _credentials:String;
      
      protected var _credentialsCharset:String;
      
      protected var _disconnectBarrier:Boolean;
      
      private var _pendingConnectEvent:ChannelEvent;
      
      private var _remoteCredentials:String = "";
      
      private var _remoteCredentialsCharset:String;
      
      private var _sendRemoteCredentials:Boolean;
      
      protected var _log:ILogger;
      
      private var _clientIdWaitQueue:Array;
      
      protected var _ignoreFault:Boolean = false;
      
      private var resourceManager:IResourceManager = ResourceManager.getInstance();
      
      private var _authenticated:Boolean;
      
      private var _channelSet:ChannelSet;
      
      private var _clientId:String;
      
      private var _connected:Boolean = false;
      
      private var _destination:String = "";
      
      private var _id:String = UIDUtil.createUID();
      
      private var _requestTimeout:int = -1;
      
      private var _channelSetMode:int = 0;
      
      mx_internal var configRequested:Boolean = false;
      
      private var _needsConfig:Boolean;
      
      public function MessageAgent()
      {
         super();
      }
      
      [Bindable(event="propertyChange")]
      public function get authenticated() : Boolean
      {
         return this._authenticated;
      }
      
      mx_internal function setAuthenticated(param1:Boolean, param2:String) : void
      {
         var _loc3_:PropertyChangeEvent = null;
         if(this._authenticated != param1)
         {
            _loc3_ = PropertyChangeEvent.createUpdateEvent(this,"authenticated",this._authenticated,param1);
            this._authenticated = param1;
            dispatchEvent(_loc3_);
            if(param1)
            {
               this.assertCredentials(param2);
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get channelSet() : ChannelSet
      {
         return this._channelSet;
      }
      
      public function set channelSet(param1:ChannelSet) : void
      {
         this.mx_internal::internalSetChannelSet(param1);
         this._channelSetMode = mx_internal::MANUALLY_ASSIGNED_CHANNELSET;
      }
      
      mx_internal function internalSetChannelSet(param1:ChannelSet) : void
      {
         var _loc2_:PropertyChangeEvent = null;
         if(this._channelSet != param1)
         {
            if(this._channelSet != null)
            {
               this._channelSet.disconnect(this);
            }
            _loc2_ = PropertyChangeEvent.createUpdateEvent(this,"channelSet",this._channelSet,param1);
            this._channelSet = param1;
            if(this._channelSet != null)
            {
               if(this._credentials)
               {
                  this._channelSet.setCredentials(this._credentials,this,this._credentialsCharset);
               }
               this._channelSet.connect(this);
            }
            dispatchEvent(_loc2_);
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get clientId() : String
      {
         return this._clientId;
      }
      
      mx_internal function setClientId(param1:String) : void
      {
         var _loc2_:PropertyChangeEvent = null;
         if(this._clientId != param1)
         {
            _loc2_ = PropertyChangeEvent.createUpdateEvent(this,"clientId",this._clientId,param1);
            this._clientId = param1;
            this.flushClientIdWaitQueue();
            dispatchEvent(_loc2_);
         }
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
            this.mx_internal::setAuthenticated(param1 && Boolean(this.channelSet) && this.channelSet.authenticated,this._credentials);
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get destination() : String
      {
         return this._destination;
      }
      
      public function set destination(param1:String) : void
      {
         var _loc2_:PropertyChangeEvent = null;
         if(param1 == null || param1.length == 0)
         {
            return;
         }
         if(this._destination != param1)
         {
            if(this._channelSetMode == mx_internal::AUTO_CONFIGURED_CHANNELSET && this.channelSet != null)
            {
               this.channelSet.disconnect(this);
               this.channelSet = null;
            }
            _loc2_ = PropertyChangeEvent.createUpdateEvent(this,"destination",this._destination,param1);
            this._destination = param1;
            dispatchEvent(_loc2_);
            if(Log.isInfo())
            {
               this._log.info("\'{0}\' {2} set destination to \'{1}\'.",this.id,this._destination,this._agentType);
            }
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get id() : String
      {
         return this._id;
      }
      
      public function set id(param1:String) : void
      {
         var _loc2_:PropertyChangeEvent = null;
         if(this._id != param1)
         {
            _loc2_ = PropertyChangeEvent.createUpdateEvent(this,"id",this._id,param1);
            this._id = param1;
            dispatchEvent(_loc2_);
         }
      }
      
      [Bindable(event="propertyChange")]
      public function get requestTimeout() : int
      {
         return this._requestTimeout;
      }
      
      public function set requestTimeout(param1:int) : void
      {
         var _loc2_:PropertyChangeEvent = null;
         if(this._requestTimeout != param1)
         {
            _loc2_ = PropertyChangeEvent.createUpdateEvent(this,"requestTimeout",this._requestTimeout,param1);
            this._requestTimeout = param1;
            dispatchEvent(_loc2_);
         }
      }
      
      mx_internal function get channelSetMode() : int
      {
         return this._channelSetMode;
      }
      
      mx_internal function get needsConfig() : Boolean
      {
         return this._needsConfig;
      }
      
      mx_internal function set needsConfig(param1:Boolean) : void
      {
         var cs:ChannelSet = null;
         var value:Boolean = param1;
         if(this._needsConfig == value)
         {
            return;
         }
         this._needsConfig = value;
         if(this._needsConfig)
         {
            cs = this.channelSet;
            try
            {
               this.disconnect();
            }
            finally
            {
               this.mx_internal::internalSetChannelSet(cs);
            }
         }
      }
      
      public function acknowledge(param1:AcknowledgeMessage, param2:IMessage) : void
      {
         var mpiutil:MessagePerformanceUtils = null;
         var ackMsg:AcknowledgeMessage = param1;
         var msg:IMessage = param2;
         if(Log.isInfo())
         {
            this._log.info("\'{0}\' {2} acknowledge of \'{1}\'.",this.id,msg.messageId,this._agentType);
         }
         if(Log.isDebug() && this.isCurrentChannelNotNull() && this.getCurrentChannel().mpiEnabled)
         {
            try
            {
               mpiutil = new MessagePerformanceUtils(ackMsg);
               this._log.debug(mpiutil.prettyPrint());
            }
            catch(e:Error)
            {
               _log.debug("Could not get message performance information for: " + msg.toString());
            }
         }
         if(this.mx_internal::configRequested)
         {
            this.mx_internal::configRequested = false;
            ServerConfig.mx_internal::updateServerConfigData(ackMsg.body as ConfigMap);
            this.mx_internal::needsConfig = false;
            if(this._pendingConnectEvent)
            {
               this.channelConnectHandler(this._pendingConnectEvent);
            }
            this._pendingConnectEvent = null;
         }
         if(this.clientId == null)
         {
            if(ackMsg.clientId != null)
            {
               this.mx_internal::setClientId(ackMsg.clientId);
            }
            else
            {
               this.flushClientIdWaitQueue();
            }
         }
         dispatchEvent(MessageAckEvent.createEvent(ackMsg,msg));
         this.monitorRpcMessage(ackMsg,msg);
      }
      
      public function disconnect() : void
      {
         if(!this._disconnectBarrier)
         {
            this._clientIdWaitQueue = null;
            if(this.connected)
            {
               this._disconnectBarrier = true;
            }
            if(this._channelSetMode == mx_internal::AUTO_CONFIGURED_CHANNELSET)
            {
               this.mx_internal::internalSetChannelSet(null);
            }
            else if(this._channelSet != null)
            {
               this._channelSet.disconnect(this);
            }
         }
      }
      
      public function fault(param1:ErrorMessage, param2:IMessage) : void
      {
         if(Log.isError())
         {
            this._log.error("\'{0}\' {2} fault for \'{1}\'.",this.id,param2.messageId,this._agentType);
         }
         this._ignoreFault = false;
         this.mx_internal::configRequested = false;
         if(param1.headers[ErrorMessage.RETRYABLE_HINT_HEADER])
         {
            delete param1.headers[ErrorMessage.RETRYABLE_HINT_HEADER];
         }
         if(this.clientId == null)
         {
            if(param1.clientId != null)
            {
               this.mx_internal::setClientId(param1.clientId);
            }
            else
            {
               this.flushClientIdWaitQueue();
            }
         }
         dispatchEvent(MessageFaultEvent.createEvent(param1));
         this.monitorRpcMessage(param1,param2);
         this.handleAuthenticationFault(param1,param2);
      }
      
      public function channelConnectHandler(param1:ChannelEvent) : void
      {
         this._disconnectBarrier = false;
         if(this.mx_internal::needsConfig)
         {
            if(Log.isInfo())
            {
               this._log.info("\'{0}\' {1} waiting for configuration information.",this.id,this._agentType);
            }
            this._pendingConnectEvent = param1;
         }
         else
         {
            if(Log.isInfo())
            {
               this._log.info("\'{0}\' {1} connected.",this.id,this._agentType);
            }
            this.setConnected(true);
            dispatchEvent(param1);
         }
      }
      
      public function channelDisconnectHandler(param1:ChannelEvent) : void
      {
         if(Log.isWarn())
         {
            this._log.warn("\'{0}\' {1} channel disconnected.",this.id,this._agentType);
         }
         this.setConnected(false);
         if(this._remoteCredentials != null)
         {
            this._sendRemoteCredentials = true;
         }
         dispatchEvent(param1);
      }
      
      public function channelFaultHandler(param1:ChannelFaultEvent) : void
      {
         if(Log.isWarn())
         {
            this._log.warn("\'{0}\' {1} channel faulted with {2} {3}",this.id,this._agentType,param1.faultCode,param1.faultDetail);
         }
         if(!param1.channel.connected)
         {
            this.setConnected(false);
            if(this._remoteCredentials != null)
            {
               this._sendRemoteCredentials = true;
            }
         }
         dispatchEvent(param1);
      }
      
      public function initialized(param1:Object, param2:String) : void
      {
         this.id = param2;
      }
      
      public function logout() : void
      {
         this._credentials = null;
         if(this.channelSet)
         {
            this.channelSet.logout(this);
         }
      }
      
      public function setCredentials(param1:String, param2:String, param3:String = null) : void
      {
         var _loc4_:String = null;
         var _loc5_:Base64Encoder = null;
         if(param1 == null && param2 == null)
         {
            this._credentials = null;
            this._credentialsCharset = null;
         }
         else
         {
            _loc4_ = param1 + ":" + param2;
            _loc5_ = new Base64Encoder();
            if(param3 == Base64Encoder.CHARSET_UTF_8)
            {
               _loc5_.encodeUTFBytes(_loc4_);
            }
            else
            {
               _loc5_.encode(_loc4_);
            }
            this._credentials = _loc5_.drain();
            this._credentialsCharset = param3;
         }
         if(this.channelSet != null)
         {
            this.channelSet.setCredentials(this._credentials,this,this._credentialsCharset);
         }
      }
      
      public function setRemoteCredentials(param1:String, param2:String, param3:String = null) : void
      {
         var _loc4_:String = null;
         var _loc5_:Base64Encoder = null;
         if(param1 == null && param2 == null)
         {
            this._remoteCredentials = "";
            this._remoteCredentialsCharset = null;
         }
         else
         {
            _loc4_ = param1 + ":" + param2;
            _loc5_ = new Base64Encoder();
            if(param3 == Base64Encoder.CHARSET_UTF_8)
            {
               _loc5_.encodeUTFBytes(_loc4_);
            }
            else
            {
               _loc5_.encode(_loc4_);
            }
            this._remoteCredentials = _loc5_.drain();
            this._remoteCredentialsCharset = param3;
         }
         this._sendRemoteCredentials = true;
      }
      
      public function hasPendingRequestForMessage(param1:IMessage) : Boolean
      {
         return false;
      }
      
      mx_internal function internalSetCredentials(param1:String) : void
      {
         this._credentials = param1;
      }
      
      final protected function assertCredentials(param1:String) : void
      {
         var _loc2_:ErrorMessage = null;
         if(this._credentials != null && this._credentials != param1)
         {
            _loc2_ = new ErrorMessage();
            _loc2_.faultCode = "Client.Authentication.Error";
            _loc2_.faultString = "Credentials specified do not match those used on underlying connection.";
            _loc2_.faultDetail = "Channel was authenticated with a different set of credentials than those used for this agent.";
            dispatchEvent(MessageFaultEvent.createEvent(_loc2_));
         }
      }
      
      final protected function flushClientIdWaitQueue() : void
      {
         var _loc1_:Array = null;
         if(this._clientIdWaitQueue != null)
         {
            if(this.clientId != null)
            {
               while(this._clientIdWaitQueue.length > 0)
               {
                  this.internalSend(this._clientIdWaitQueue.shift() as IMessage);
               }
            }
            if(this.clientId == null)
            {
               if(this._clientIdWaitQueue.length > 0)
               {
                  _loc1_ = this._clientIdWaitQueue;
                  this._clientIdWaitQueue = null;
                  this.internalSend(_loc1_.shift() as IMessage);
                  this._clientIdWaitQueue = _loc1_;
               }
               else
               {
                  this._clientIdWaitQueue = null;
               }
            }
         }
      }
      
      protected function handleAuthenticationFault(param1:ErrorMessage, param2:IMessage) : void
      {
         var _loc3_:Channel = null;
         if(param1.faultCode == "Client.Authentication" && this.authenticated && this.isCurrentChannelNotNull())
         {
            _loc3_ = this.getCurrentChannel();
            _loc3_.mx_internal::setAuthenticated(false);
            if(_loc3_ is PollingChannel && (_loc3_ as PollingChannel).mx_internal::loginAfterDisconnect)
            {
               this.reAuthorize(param2);
               this._ignoreFault = true;
            }
         }
      }
      
      protected function initChannelSet(param1:IMessage) : void
      {
         if(this._channelSet == null)
         {
            this._channelSetMode = mx_internal::AUTO_CONFIGURED_CHANNELSET;
            this.mx_internal::internalSetChannelSet(ServerConfig.getChannelSet(this.destination));
         }
         if(this._channelSet.connected && this.mx_internal::needsConfig && !this.mx_internal::configRequested)
         {
            param1.headers[CommandMessage.NEEDS_CONFIG_HEADER] = true;
            this.mx_internal::configRequested = true;
         }
         this._channelSet.connect(this);
         if(this._credentials != null)
         {
            this.channelSet.setCredentials(this._credentials,this,this._credentialsCharset);
         }
      }
      
      protected function internalSend(param1:IMessage, param2:Boolean = true) : void
      {
         var _loc3_:String = null;
         if(param1.clientId == null && param2 && this.clientId == null)
         {
            if(this._clientIdWaitQueue != null)
            {
               this._clientIdWaitQueue.push(param1);
               return;
            }
            this._clientIdWaitQueue = [];
         }
         if(param1.clientId == null)
         {
            param1.clientId = this.clientId;
         }
         if(this.requestTimeout > 0)
         {
            param1.headers[AbstractMessage.REQUEST_TIMEOUT_HEADER] = this.requestTimeout;
         }
         if(this._sendRemoteCredentials)
         {
            if(!(param1 is CommandMessage && CommandMessage(param1).operation == CommandMessage.TRIGGER_CONNECT_OPERATION))
            {
               param1.headers[AbstractMessage.REMOTE_CREDENTIALS_HEADER] = this._remoteCredentials;
               param1.headers[AbstractMessage.REMOTE_CREDENTIALS_CHARSET_HEADER] = this._remoteCredentialsCharset;
               this._sendRemoteCredentials = false;
            }
         }
         if(this.channelSet != null)
         {
            if(!this.connected && this._channelSetMode == mx_internal::MANUALLY_ASSIGNED_CHANNELSET)
            {
               this._channelSet.connect(this);
            }
            if(this.channelSet.connected && this.mx_internal::needsConfig && !this.mx_internal::configRequested)
            {
               param1.headers[CommandMessage.NEEDS_CONFIG_HEADER] = true;
               this.mx_internal::configRequested = true;
            }
            this.channelSet.send(this,param1);
            this.monitorRpcMessage(param1,param1);
         }
         else
         {
            if(!(this.destination != null && this.destination.length > 0))
            {
               _loc3_ = this.resourceManager.getString("messaging","destinationNotSet");
               throw new InvalidDestinationError(_loc3_);
            }
            this.initChannelSet(param1);
            if(this.channelSet != null)
            {
               this.channelSet.send(this,param1);
               this.monitorRpcMessage(param1,param1);
            }
         }
      }
      
      protected function reAuthorize(param1:IMessage) : void
      {
         if(this.channelSet != null)
         {
            this.channelSet.disconnectAll();
         }
         this.internalSend(param1);
      }
      
      private function getCurrentChannel() : Channel
      {
         return this.channelSet != null ? this.channelSet.currentChannel : null;
      }
      
      private function isCurrentChannelNotNull() : Boolean
      {
         return this.getCurrentChannel() != null;
      }
      
      private function monitorRpcMessage(param1:IMessage, param2:IMessage) : void
      {
         if(NetworkMonitor.isMonitoring())
         {
            if(param1 is ErrorMessage)
            {
               NetworkMonitor.monitorFault(param2,MessageFaultEvent.createEvent(ErrorMessage(param1)));
            }
            else if(param1 is AcknowledgeMessage)
            {
               NetworkMonitor.monitorResult(param1,MessageEvent.createEvent(MessageEvent.RESULT,param2));
            }
            else
            {
               NetworkMonitor.monitorInvocation(this.mx_internal::getNetmonId(),param1,this);
            }
         }
      }
      
      mx_internal function getNetmonId() : String
      {
         return null;
      }
   }
}

