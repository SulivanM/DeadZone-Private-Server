package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class SimpleGetCaptchaArgs extends Message
   {
      public var gameId:String;
      
      public var width:int;
      
      public var height:int;
      
      public function SimpleGetCaptchaArgs(param1:String, param2:int, param3:int)
      {
         super();
         registerField("gameId","",9,1,1);
         registerField("width","",5,1,2);
         registerField("height","",5,1,3);
         this.gameId = param1;
         this.width = param2;
         this.height = param3;
      }
   }
}

