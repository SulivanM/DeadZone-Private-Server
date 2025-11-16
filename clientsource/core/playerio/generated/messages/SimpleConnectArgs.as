package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class SimpleConnectArgs extends Message
   {
      
      public var gameId:String;
      
      public var usernameOrEmail:String;
      
      public var password:String;
      
      public var playerInsightSegments:Array = [];
      
      public var clientAPI:String;
      
      public var clientInfo:Array = [];
      
      public var clientInfoDummy:KeyValuePair = null;
      
      public function SimpleConnectArgs(param1:String, param2:String, param3:String, param4:Array, param5:String, param6:Array)
      {
         super();
         registerField("gameId","",9,1,1);
         registerField("usernameOrEmail","",9,1,2);
         registerField("password","",9,1,3);
         registerField("playerInsightSegments","",9,3,4);
         registerField("clientAPI","",9,1,5);
         registerField("clientInfo","playerio.generated.messages.KeyValuePair",11,3,6);
         this.gameId = param1;
         this.usernameOrEmail = param2;
         this.password = param3;
         this.playerInsightSegments = param4;
         this.clientAPI = param5;
         this.clientInfo = param6;
      }
   }
}

