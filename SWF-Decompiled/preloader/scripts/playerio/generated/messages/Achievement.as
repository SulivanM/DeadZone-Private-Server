package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class Achievement extends Message
   {
      public var identifier:String;
      
      public var title:String;
      
      public var description:String;
      
      public var imageUrl:String;
      
      public var progressGoal:uint;
      
      public var progress:uint;
      
      public var lastUpdated:Number;
      
      public function Achievement()
      {
         super();
         registerField("identifier","",9,1,1);
         registerField("title","",9,1,2);
         registerField("description","",9,1,3);
         registerField("imageUrl","",9,1,4);
         registerField("progressGoal","",13,1,5);
         registerField("progress","",13,1,6);
         registerField("lastUpdated","",3,1,7);
      }
   }
}

