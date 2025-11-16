package thelaststand.app.network.chat
{
   public class ChatMessageData
   {
      
      public var uniqueId:String = "";
      
      public var channel:String;
      
      public var messageType:String;
      
      public var posterId:String;
      
      public var posterNickName:String;
      
      public var posterAllianceId:String;
      
      public var posterAllianceTag:String;
      
      public var posterIsAdmin:Boolean;
      
      public var toNickName:String;
      
      public var message:String;
      
      public var customNickName:String = "";
      
      public var customNameColor:String = "";
      
      public var customMsgColor:String = "";
      
      public var linkData:Array;
      
      public function ChatMessageData(param1:String, param2:String)
      {
         super();
         this.channel = param1;
         this.messageType = param2;
      }
   }
}

