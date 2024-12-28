package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class SocialProfile extends Message
   {
      public var userId:String;
      
      public var displayName:String;
      
      public var avatarUrl:String;
      
      public var lastOnline:Number;
      
      public var countryCode:String;
      
      public var userToken:String;
      
      public function SocialProfile()
      {
         super();
         registerField("userId","",9,1,1);
         registerField("displayName","",9,1,2);
         registerField("avatarUrl","",9,1,3);
         registerField("lastOnline","",3,1,4);
         registerField("countryCode","",9,1,5);
         registerField("userToken","",9,1,6);
      }
   }
}

