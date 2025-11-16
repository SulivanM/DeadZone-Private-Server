package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class AuthenticateOutput extends Message
   {
      
      public var token:String;
      
      public var userId:String;
      
      public var showBranding:Boolean;
      
      public var gameFSRedirectMap:String;
      
      public var playerInsightState:PlayerInsightState;
      
      public var playerInsightStateDummy:PlayerInsightState = null;
      
      public var startDialogs:Array = [];
      
      public var startDialogsDummy:AuthenticateStartDialog = null;
      
      public var isSocialNetworkUser:Boolean;
      
      public var newPlayCodes:Array = [];
      
      public var notificationClickPayload:String;
      
      public var isInstalledByPublishingNetwork:Boolean;
      
      public var deprecated1:Array = [];
      
      public var apiSecurity:int;
      
      public var apiServerHosts:Array = [];
      
      public function AuthenticateOutput()
      {
         super();
         registerField("token","",9,1,1);
         registerField("userId","",9,1,2);
         registerField("showBranding","",8,1,3);
         registerField("gameFSRedirectMap","",9,1,4);
         registerField("playerInsightState","playerio.generated.messages.PlayerInsightState",11,1,5);
         registerField("startDialogs","playerio.generated.messages.AuthenticateStartDialog",11,3,6);
         registerField("isSocialNetworkUser","",8,1,7);
         registerField("newPlayCodes","",9,3,8);
         registerField("notificationClickPayload","",9,1,9);
         registerField("isInstalledByPublishingNetwork","",8,1,10);
         registerField("deprecated1","",9,3,11);
         registerField("apiSecurity","",14,1,12);
         registerField("apiServerHosts","",9,3,13);
      }
   }
}

