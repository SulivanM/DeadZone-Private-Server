package mx.messaging.errors
{
   import mx.messaging.messages.ErrorMessage;
   
   public class MessageSerializationError extends MessagingError
   {
      
      public var fault:ErrorMessage;
      
      public function MessageSerializationError(param1:String, param2:ErrorMessage)
      {
         super(param1);
         this.fault = param2;
      }
   }
}

