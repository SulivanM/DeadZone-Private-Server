package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class LoadMatchingObjectsArgs extends Message
   {
      
      public var table:String;
      
      public var index:String;
      
      public var indexValue:Array = [];
      
      public var indexValueDummy:ValueObject = null;
      
      public var limit:int;
      
      public function LoadMatchingObjectsArgs(param1:String, param2:String, param3:Array, param4:int)
      {
         super();
         registerField("table","",9,1,1);
         registerField("index","",9,1,2);
         registerField("indexValue","playerio.generated.messages.ValueObject",11,3,3);
         registerField("limit","",5,1,4);
         this.table = param1;
         this.index = param2;
         this.indexValue = param3;
         this.limit = param4;
      }
   }
}

