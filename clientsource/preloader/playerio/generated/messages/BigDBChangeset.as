package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class BigDBChangeset extends Message
   {
      
      public var table:String;
      
      public var key:String;
      
      public var onlyIfVersion:String;
      
      public var changes:Array = [];
      
      public var changesDummy:ObjectProperty = null;
      
      public var fullOverwrite:Boolean;
      
      public function BigDBChangeset()
      {
         super();
         registerField("table","",9,1,1);
         registerField("key","",9,1,2);
         registerField("onlyIfVersion","",9,1,3);
         registerField("changes","playerio.generated.messages.ObjectProperty",11,3,4);
         registerField("fullOverwrite","",8,1,5);
      }
   }
}

