package playerio.generated
{
   import flash.events.EventDispatcher;
   import playerio.Client;
   import playerio.generated.messages.WriteErrorArgs;
   import playerio.generated.messages.WriteErrorError;
   import playerio.generated.messages.WriteErrorOutput;
   import playerio.utils.Converter;
   import playerio.utils.HTTPChannel;
   
   public class ErrorLog extends EventDispatcher
   {
      protected var channel:HTTPChannel;
      
      protected var client:Client;
      
      public function ErrorLog(param1:HTTPChannel, param2:Client)
      {
         super();
         this.channel = param1;
         this.client = param2;
      }
      
      protected function _writeError(param1:String, param2:String, param3:String, param4:String, param5:Object, param6:Function = null, param7:Function = null) : void
      {
         var source:String = param1;
         var error:String = param2;
         var details:String = param3;
         var stacktrace:String = param4;
         var extraData:Object = param5;
         var callback:Function = param6;
         var errorHandler:Function = param7;
         var input:WriteErrorArgs = new WriteErrorArgs(source,error,details,stacktrace,Converter.toKeyValueArray(extraData));
         var output:WriteErrorOutput = new WriteErrorOutput();
         channel.Request(50,input,output,new WriteErrorError(),function(param1:WriteErrorOutput):void
         {
            if(callback != null)
            {
               callback();
            }
         },function(param1:WriteErrorError):void
         {
            var _loc2_:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
            if(errorHandler != null)
            {
               errorHandler(_loc2_);
               return;
            }
            throw _loc2_;
         });
      }
   }
}

