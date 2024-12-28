package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class LoadMyPlayerObjectOutput extends Message
   {
      public var playerObject:BigDBObject;
      
      public var playerObjectDummy:BigDBObject = null;
      
      public function LoadMyPlayerObjectOutput()
      {
         super();
         registerField("playerObject","playerio.generated.messages.BigDBObject",11,1,1);
      }
   }
}

