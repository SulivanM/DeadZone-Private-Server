package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class SimpleRegisterArgs extends Message
   {
      
      public var gameId:String;
      
      public var username:String;
      
      public var password:String;
      
      public var email:String;
      
      public var captchaKey:String;
      
      public var captchaValue:String;
      
      public var extraData:Array = [];
      
      public var extraDataDummy:KeyValuePair = null;
      
      public var partnerId:String;
      
      public var playerInsightSegments:Array = [];
      
      public var clientAPI:String;
      
      public var clientInfo:Array = [];
      
      public var clientInfoDummy:KeyValuePair = null;
      
      public function SimpleRegisterArgs(param1:String, param2:String, param3:String, param4:String, param5:String, param6:String, param7:Array, param8:String, param9:Array, param10:String, param11:Array)
      {
         super();
         registerField("gameId","",9,1,1);
         registerField("username","",9,1,2);
         registerField("password","",9,1,3);
         registerField("email","",9,1,4);
         registerField("captchaKey","",9,1,6);
         registerField("captchaValue","",9,1,7);
         registerField("extraData","playerio.generated.messages.KeyValuePair",11,3,5);
         registerField("partnerId","",9,1,8);
         registerField("playerInsightSegments","",9,3,9);
         registerField("clientAPI","",9,1,10);
         registerField("clientInfo","playerio.generated.messages.KeyValuePair",11,3,11);
         this.gameId = param1;
         this.username = param2;
         this.password = param3;
         this.email = param4;
         this.captchaKey = param5;
         this.captchaValue = param6;
         this.extraData = param7;
         this.partnerId = param8;
         this.playerInsightSegments = param9;
         this.clientAPI = param10;
         this.clientInfo = param11;
      }
   }
}

