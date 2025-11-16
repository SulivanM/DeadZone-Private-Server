package playerio.generated.messages
{
   import com.protobuf.Message;
   
   public final class SaveObjectChangesArgs extends Message
   {
      
      public var lockType:int;
      
      public var changesets:Array = [];
      
      public var changesetsDummy:BigDBChangeset = null;
      
      public var createIfMissing:Boolean;
      
      public function SaveObjectChangesArgs(param1:int, param2:Array, param3:Boolean)
      {
         super();
         registerField("lockType","",14,1,1);
         registerField("changesets","playerio.generated.messages.BigDBChangeset",11,3,2);
         registerField("createIfMissing","",8,1,3);
         this.lockType = param1;
         this.changesets = param2;
         this.createIfMissing = param3;
      }
   }
}

