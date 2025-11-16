package com.adobe.protocols.dict.util
{
   import com.adobe.net.proxies.RFC2817Socket;
   import flash.events.ProgressEvent;
   
   public class SocketHelper extends RFC2817Socket
   {
      
      public static var COMPLETE_RESPONSE:String = "completeResponse";
      
      private var terminator:String = "\r\n.\r\n";
      
      private var buffer:String;
      
      public function SocketHelper()
      {
         super();
         this.buffer = new String();
         addEventListener(ProgressEvent.SOCKET_DATA,this.incomingData);
      }
      
      private function incomingData(param1:ProgressEvent) : void
      {
         var _loc3_:uint = 0;
         var _loc4_:String = null;
         this.buffer += readUTFBytes(bytesAvailable);
         this.buffer = this.buffer.replace(/250[^\r\n]+\r\n/,"");
         var _loc2_:String = this.buffer.substring(0,3);
         if(!isNaN(parseInt(_loc2_)))
         {
            _loc3_ = uint(_loc2_);
            if(_loc3_ == 150 || _loc3_ >= 200)
            {
               this.buffer = this.buffer.replace("\r\n",this.terminator);
            }
         }
         while(this.buffer.indexOf(this.terminator) != -1)
         {
            _loc4_ = this.buffer.substring(0,this.buffer.indexOf(this.terminator));
            this.buffer = this.buffer.substring(_loc4_.length + this.terminator.length,this.buffer.length);
            this.throwResponseEvent(_loc4_);
         }
      }
      
      private function throwResponseEvent(param1:String) : void
      {
         var _loc2_:CompleteResponseEvent = new CompleteResponseEvent();
         _loc2_.response = param1;
         dispatchEvent(_loc2_);
      }
   }
}

