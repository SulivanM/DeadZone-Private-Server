package thelaststand.common.error
{
   public class CustomError extends Error
   {
      
      public var data:*;
      
      public function CustomError(param1:* = "", param2:* = null, param3:* = 0)
      {
         super(param1,param3);
         this.data = param2;
      }
   }
}

