package versions.version1.a3d.id
{
   public class ParentId
   {
      
      private var _id:uint;
      
      public function ParentId(param1:uint)
      {
         super();
         this._id = param1;
      }
      
      public function get id() : uint
      {
         return this._id;
      }
      
      public function set id(param1:uint) : void
      {
         this._id = param1;
      }
      
      public function toString() : String
      {
         var _loc1_:String = "ParentId [";
         _loc1_ += "id = " + this.id + " ";
         return _loc1_ + "]";
      }
   }
}

