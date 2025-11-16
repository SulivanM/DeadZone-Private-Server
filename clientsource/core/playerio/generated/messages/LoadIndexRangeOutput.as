package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class LoadIndexRangeOutput extends Message
   {
      
      public var objects:Array = [];
      
      public var objectsDummy:BigDBObject = null;
      
      public function LoadIndexRangeOutput()
      {
         super();
         registerField("objects","playerio.generated.messages.BigDBObject",11,3,1);
      }
   }
}

