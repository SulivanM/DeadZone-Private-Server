package com.adobe.net.proxies
{
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.net.Socket;
   
   public class RFC2817Socket extends Socket
   {
      
      private var proxyHost:String = null;
      
      private var host:String = null;
      
      private var proxyPort:int = 0;
      
      private var port:int = 0;
      
      private var deferredEventHandlers:Object = new Object();
      
      private var buffer:String = new String();
      
      public function RFC2817Socket(param1:String = null, param2:int = 0)
      {
         super(param1,param2);
      }
      
      public function setProxyInfo(param1:String, param2:int) : void
      {
         this.proxyHost = param1;
         this.proxyPort = param2;
         var _loc3_:Object = this.deferredEventHandlers[ProgressEvent.SOCKET_DATA];
         var _loc4_:Object = this.deferredEventHandlers[Event.CONNECT];
         if(_loc3_ != null)
         {
            super.removeEventListener(ProgressEvent.SOCKET_DATA,_loc3_.listener,_loc3_.useCapture);
         }
         if(_loc4_ != null)
         {
            super.removeEventListener(Event.CONNECT,_loc4_.listener,_loc4_.useCapture);
         }
      }
      
      override public function connect(param1:String, param2:int) : void
      {
         if(this.proxyHost == null)
         {
            this.redirectConnectEvent();
            this.redirectSocketDataEvent();
            super.connect(param1,param2);
         }
         else
         {
            this.host = param1;
            this.port = param2;
            super.addEventListener(Event.CONNECT,this.onConnect);
            super.addEventListener(ProgressEvent.SOCKET_DATA,this.onSocketData);
            super.connect(this.proxyHost,this.proxyPort);
         }
      }
      
      private function onConnect(param1:Event) : void
      {
         this.writeUTFBytes("CONNECT " + this.host + ":" + this.port + " HTTP/1.1\n\n");
         this.flush();
         this.redirectConnectEvent();
      }
      
      private function onSocketData(param1:ProgressEvent) : void
      {
         while(this.bytesAvailable != 0)
         {
            this.buffer += this.readUTFBytes(1);
            if(this.buffer.search(/\r?\n\r?\n$/) != -1)
            {
               this.checkResponse(param1);
               break;
            }
         }
      }
      
      private function checkResponse(param1:ProgressEvent) : void
      {
         var _loc3_:IOErrorEvent = null;
         var _loc2_:String = this.buffer.substr(this.buffer.indexOf(" ") + 1,3);
         if(_loc2_.search(/^2/) == -1)
         {
            _loc3_ = new IOErrorEvent(IOErrorEvent.IO_ERROR);
            _loc3_.text = "Error connecting to the proxy [" + this.proxyHost + "] on port [" + this.proxyPort + "]: " + this.buffer;
            this.dispatchEvent(_loc3_);
         }
         else
         {
            this.redirectSocketDataEvent();
            this.dispatchEvent(new Event(Event.CONNECT));
            if(this.bytesAvailable > 0)
            {
               this.dispatchEvent(param1);
            }
         }
         this.buffer = null;
      }
      
      private function redirectConnectEvent() : void
      {
         super.removeEventListener(Event.CONNECT,this.onConnect);
         var _loc1_:Object = this.deferredEventHandlers[Event.CONNECT];
         if(_loc1_ != null)
         {
            super.addEventListener(Event.CONNECT,_loc1_.listener,_loc1_.useCapture,_loc1_.priority,_loc1_.useWeakReference);
         }
      }
      
      private function redirectSocketDataEvent() : void
      {
         super.removeEventListener(ProgressEvent.SOCKET_DATA,this.onSocketData);
         var _loc1_:Object = this.deferredEventHandlers[ProgressEvent.SOCKET_DATA];
         if(_loc1_ != null)
         {
            super.addEventListener(ProgressEvent.SOCKET_DATA,_loc1_.listener,_loc1_.useCapture,_loc1_.priority,_loc1_.useWeakReference);
         }
      }
      
      override public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         if(param1 == Event.CONNECT || param1 == ProgressEvent.SOCKET_DATA)
         {
            this.deferredEventHandlers[param1] = {
               "listener":param2,
               "useCapture":param3,
               "priority":param4,
               "useWeakReference":param5
            };
         }
         else
         {
            super.addEventListener(param1,param2,param3,param4,param5);
         }
      }
   }
}

