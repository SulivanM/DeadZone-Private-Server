package mx.messaging.errors
{
   public class MessagingError extends Error
   {
      
      public function MessagingError(param1:String)
      {
         super(param1);
      }
      
      public function toString() : String
      {
         var _loc1_:* = "[MessagingError";
         if(message != null)
         {
            _loc1_ += " message=\'" + message + "\']";
         }
         else
         {
            _loc1_ += "]";
         }
         return _loc1_;
      }
   }
}

