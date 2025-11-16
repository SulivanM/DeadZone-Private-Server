package thelaststand.app.network
{
   import com.junkbyte.console.Cc;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.events.TimerEvent;
   import flash.net.Socket;
   import flash.utils.Timer;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Settings;
   
   public class BroadcastSystem
   {
      
      private const TIMEOUT:uint = 30000;
      
      private const RETRY:uint = 60000;
      
      private const HEARTBEAT:uint = 120000;
      
      private var _host:String = "127.0.0.1";
      
      private var _portStart:int;
      
      private var _portMax:int;
      
      private var _portNext:int;
      
      private var _socket:Socket;
      
      private var _connection:Socket;
      
      private var _connected:Boolean;
      
      private var _timeoutTimer:Timer;
      
      private var _retryTimer:Timer;
      
      private var _heartbeatTimer:Timer;
      
      private var _enabled:Boolean = true;
      
      public var failed:Signal;
      
      public var connected:Signal;
      
      public var disconnected:Signal;
      
      public var messageReceived:Signal;
      
      public var tempid:String = "Default";
      
      public function BroadcastSystem()
      {
         super();
         switch(Network.getInstance().service)
         {
            case PlayerIOConnector.SERVICE_FACEBOOK:
            case PlayerIOConnector.SERVICE_ARMOR_GAMES:
            case PlayerIOConnector.SERVICE_PLAYER_IO:
               this._portStart = 2121;
               break;
            case PlayerIOConnector.SERVICE_KONGREGATE:
               this._portStart = 2122;
               break;
            case PlayerIOConnector.SERVICE_YAHOO:
               this._portStart = 2123;
               break;
            default:
               this._portStart = 1;
         }
         this._portMax = this._portStart;
         this._timeoutTimer = new Timer(this.TIMEOUT,1);
         this._timeoutTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onTimeout,false,0,true);
         this._retryTimer = new Timer(this.RETRY,1);
         this._retryTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onRetryTimeout,false,0,true);
         this._heartbeatTimer = new Timer(this.HEARTBEAT,3);
         this._heartbeatTimer.addEventListener(TimerEvent.TIMER,this.onHeartbeat,false,0,true);
         this.failed = new Signal();
         this.connected = new Signal();
         this.disconnected = new Signal();
         this.messageReceived = new Signal(String,Array);
         this._enabled = Settings.getInstance().broadcastEnabled;
      }
      
      public function connect() : void
      {
         if(this._connected)
         {
            return;
         }
         this._retryTimer.stop();
         this._timeoutTimer.stop();
         if(this._heartbeatTimer.running == false)
         {
            this._heartbeatTimer.start();
         }
         this._portNext = this._portStart;
         this.tryNextConnection();
      }
      
      public function disconnect() : void
      {
         if(!this._connected)
         {
            return;
         }
         this._retryTimer.stop();
         this._timeoutTimer.stop();
         this._heartbeatTimer.stop();
         this.killConnection();
         this.disconnected.dispatch();
      }
      
      public function send(param1:String) : void
      {
         if(this._connection == null)
         {
            return;
         }
         param1 += "0";
         this._connection.writeUTFBytes(param1);
         this._connection.flush();
      }
      
      private function killConnection() : void
      {
         if(this._connection != null)
         {
            this._connection.removeEventListener(Event.CONNECT,this.onConnected);
            this._connection.removeEventListener(Event.CLOSE,this.onDisconnected);
            this._connection.removeEventListener(ProgressEvent.SOCKET_DATA,this.onData);
            this._connection.removeEventListener(IOErrorEvent.IO_ERROR,this.onIOError);
            this._connection.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onSandboxError);
            try
            {
               this._connection.close();
            }
            catch(e:Error)
            {
            }
            this._connection = null;
         }
         this._connected = false;
      }
      
      private function tryNextConnection() : void
      {
         if(this._portNext > this._portMax)
         {
            this._portNext = this._portStart;
         }
         var _loc1_:int = this._portNext++;
         if(this._connection)
         {
            this.killConnection();
         }
         Cc.logch("broadcast","[+] BroadcastSystem: Connecting: ",this.tempid,this._host,this._portStart);
         this._connection = new Socket(this._host,_loc1_);
         this._connection.addEventListener(Event.CONNECT,this.onConnected,false,0,true);
         this._connection.addEventListener(Event.CLOSE,this.onDisconnected,false,0,true);
         this._connection.addEventListener(ProgressEvent.SOCKET_DATA,this.onData,false,0,true);
         this._connection.addEventListener(IOErrorEvent.IO_ERROR,this.onIOError,false,0,true);
         this._connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onSandboxError,false,0,true);
         this._timeoutTimer.reset();
         this._timeoutTimer.start();
      }
      
      private function onConnected(param1:Event) : void
      {
         Cc.logch("broadcast","[+] BroadcastSystem: Connected",this.tempid);
         this._enabled = true;
         this._timeoutTimer.stop();
         this._retryTimer.stop();
         this.connected.dispatch();
      }
      
      private function onDisconnected(param1:Event) : void
      {
         Cc.logch("broadcast","[!] BroadcastSystem: Disconnected",this.tempid);
         this._timeoutTimer.stop();
         this.killConnection();
         this.disconnected.dispatch();
         this._retryTimer.reset();
         this._retryTimer.start();
      }
      
      private function onData(param1:ProgressEvent) : void
      {
         var pos:int;
         var protocol:String;
         var body:String;
         var msg:String = null;
         var e:ProgressEvent = param1;
         if(this._enabled == false)
         {
            return;
         }
         try
         {
            msg = this._connection.readUTFBytes(this._connection.bytesAvailable);
         }
         catch(e:Error)
         {
            return;
         }
         pos = int(msg.indexOf(":"));
         protocol = pos > -1 ? msg.substr(0,pos) : msg;
         body = pos > -1 ? msg.substr(pos + 1) : "";
         this.messageReceived.dispatch(protocol,body.length > 0 ? body.split("|") : []);
      }
      
      private function onTimeout(param1:TimerEvent) : void
      {
         Cc.logch("broadcast","[!] Connection timed out",this.tempid);
         this._retryTimer.reset();
         this._retryTimer.start();
      }
      
      private function onRetryTimeout(param1:TimerEvent) : void
      {
         Cc.logch("broadcast","[!] Retrying connection...",this.tempid);
         if(this._connected)
         {
            return;
         }
         this.tryNextConnection();
      }
      
      private function onIOError(param1:IOErrorEvent) : void
      {
         if(this._connected)
         {
            return;
         }
         Cc.logch("broadcast","[!] IOError...",this.tempid);
         this.killConnection();
         this._retryTimer.reset();
         this._retryTimer.start();
      }
      
      private function onSandboxError(param1:SecurityErrorEvent) : void
      {
         Cc.logch("broadcast","[!] Sandbox Violation...",this.tempid);
         this.killConnection();
         this._retryTimer.reset();
         this._retryTimer.start();
      }
      
      private function onHeartbeat(param1:TimerEvent) : void
      {
         this.send("");
         var _loc2_:* = this._enabled != Settings.getInstance().broadcastEnabled;
         if(_loc2_)
         {
            this._enabled = !this._enabled;
            if(this._enabled == false)
            {
               this.disconnected.dispatch();
            }
         }
         if(this._enabled && !this._connected)
         {
            if(this._timeoutTimer.running == false && this._retryTimer.running == false)
            {
               this.connect();
            }
         }
      }
   }
}

