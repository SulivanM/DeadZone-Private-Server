package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class DeleteIndexRangeArgs extends Message
   {
      
      public var table:String;
      
      public var index:String;
      
      public var startIndexValue:Array = [];
      
      public var startIndexValueDummy:ValueObject = null;
      
      public var stopIndexValue:Array = [];
      
      public var stopIndexValueDummy:ValueObject = null;
      
      public function DeleteIndexRangeArgs(param1:String, param2:String, param3:Array, param4:Array)
      {
         super();
         registerField("table","",9,1,1);
         registerField("index","",9,1,2);
         registerField("startIndexValue","playerio.generated.messages.ValueObject",11,3,3);
         registerField("stopIndexValue","playerio.generated.messages.ValueObject",11,3,4);
         this.table = param1;
         this.index = param2;
         this.startIndexValue = param3;
         this.stopIndexValue = param4;
      }
   }
}

