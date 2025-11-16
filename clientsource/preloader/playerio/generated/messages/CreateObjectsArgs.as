package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class CreateObjectsArgs extends Message
   {
      
      public var objects:Array = [];
      
      public var objectsDummy:NewBigDBObject = null;
      
      public var loadExisting:Boolean;
      
      public function CreateObjectsArgs(param1:Array, param2:Boolean)
      {
         super();
         registerField("objects","playerio.generated.messages.NewBigDBObject",11,3,1);
         registerField("loadExisting","",8,1,2);
         this.objects = param1;
         this.loadExisting = param2;
      }
   }
}

