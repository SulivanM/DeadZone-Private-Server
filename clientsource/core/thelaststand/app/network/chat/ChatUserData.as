package thelaststand.app.network.chat
{
   public class ChatUserData
   {
      
      public var nickName:String;
      
      public var userId:String;
      
      public var level:int;
      
      public var online:Boolean = true;
      
      public var allianceId:String;
      
      public var allianceTag:String;
      
      public var isAdmin:Boolean = false;
      
      public function ChatUserData()
      {
         super();
      }
   }
}

