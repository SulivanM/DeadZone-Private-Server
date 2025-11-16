package mx.rpc.events
{
   import flash.events.Event;
   import mx.core.mx_internal;
   import mx.messaging.messages.AbstractMessage;
   import mx.messaging.messages.IMessage;
   import mx.rpc.AsyncToken;
   
   use namespace mx_internal;
   
   public class ResultEvent extends AbstractEvent
   {
      
      public static const RESULT:String = "result";
      
      private var _result:Object;
      
      private var _headers:Object;
      
      private var _statusCode:int;
      
      public function ResultEvent(param1:String, param2:Boolean = false, param3:Boolean = true, param4:Object = null, param5:AsyncToken = null, param6:IMessage = null)
      {
         super(param1,param2,param3,param5,param6);
         if(param6 != null && param6.headers != null)
         {
            this._statusCode = param6.headers[AbstractMessage.STATUS_CODE_HEADER] as int;
         }
         this._result = param4;
      }
      
      public static function createEvent(param1:Object = null, param2:AsyncToken = null, param3:IMessage = null) : ResultEvent
      {
         return new ResultEvent(ResultEvent.RESULT,false,true,param1,param2,param3);
      }
      
      public function get headers() : Object
      {
         return this._headers;
      }
      
      public function set headers(param1:Object) : void
      {
         this._headers = param1;
      }
      
      public function get result() : Object
      {
         return this._result;
      }
      
      public function get statusCode() : int
      {
         return this._statusCode;
      }
      
      override public function clone() : Event
      {
         return new ResultEvent(type,bubbles,cancelable,this.result,token,message);
      }
      
      override public function toString() : String
      {
         return formatToString("ResultEvent","messageId","type","bubbles","cancelable","eventPhase");
      }
      
      override mx_internal function callTokenResponders() : void
      {
         if(token != null)
         {
            token.mx_internal::applyResult(this);
         }
      }
      
      mx_internal function setResult(param1:Object) : void
      {
         this._result = param1;
      }
   }
}

