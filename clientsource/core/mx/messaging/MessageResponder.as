package mx.messaging
{
   import flash.events.TimerEvent;
   import flash.net.Responder;
   import flash.utils.Timer;
   import mx.messaging.messages.ErrorMessage;
   import mx.messaging.messages.IMessage;
   import mx.resources.IResourceManager;
   import mx.resources.ResourceManager;
   
   public class MessageResponder extends Responder
   {
      
      private var _requestTimedOut:Boolean;
      
      private var _requestTimer:Timer;
      
      private var resourceManager:IResourceManager = ResourceManager.getInstance();
      
      private var _agent:MessageAgent;
      
      private var _channel:Channel;
      
      private var _message:IMessage;
      
      public function MessageResponder(param1:MessageAgent, param2:IMessage, param3:Channel = null)
      {
         super(this.result,this.status);
         this._agent = param1;
         this._channel = param3;
         this._message = param2;
         this._requestTimedOut = false;
      }
      
      public function get agent() : MessageAgent
      {
         return this._agent;
      }
      
      public function get channel() : Channel
      {
         return this._channel;
      }
      
      public function get message() : IMessage
      {
         return this._message;
      }
      
      public function set message(param1:IMessage) : void
      {
         this._message = param1;
      }
      
      final public function startRequestTimeout(param1:int) : void
      {
         this._requestTimer = new Timer(param1 * 1000,1);
         this._requestTimer.addEventListener(TimerEvent.TIMER,this.timeoutRequest);
         this._requestTimer.start();
      }
      
      final public function result(param1:IMessage) : void
      {
         if(!this._requestTimedOut)
         {
            if(this._requestTimer != null)
            {
               this.releaseTimer();
            }
            this.resultHandler(param1);
         }
      }
      
      final public function status(param1:IMessage) : void
      {
         if(!this._requestTimedOut)
         {
            if(this._requestTimer != null)
            {
               this.releaseTimer();
            }
            this.statusHandler(param1);
         }
      }
      
      protected function createRequestTimeoutErrorMessage() : ErrorMessage
      {
         var _loc1_:ErrorMessage = new ErrorMessage();
         _loc1_.correlationId = this.message.messageId;
         _loc1_.faultCode = "Client.Error.RequestTimeout";
         _loc1_.faultString = this.resourceManager.getString("messaging","requestTimedOut");
         _loc1_.faultDetail = this.resourceManager.getString("messaging","requestTimedOut.details");
         return _loc1_;
      }
      
      protected function resultHandler(param1:IMessage) : void
      {
      }
      
      protected function requestTimedOut() : void
      {
      }
      
      protected function statusHandler(param1:IMessage) : void
      {
      }
      
      private function timeoutRequest(param1:TimerEvent) : void
      {
         this._requestTimedOut = true;
         this.releaseTimer();
         this.requestTimedOut();
      }
      
      private function releaseTimer() : void
      {
         this._requestTimer.stop();
         this._requestTimer.removeEventListener(TimerEvent.TIMER,this.timeoutRequest);
         this._requestTimer = null;
      }
   }
}

