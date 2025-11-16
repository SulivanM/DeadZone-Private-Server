package versions.version1.a3d.objects
{
   import commons.Id;
   
   public class A3DBox
   {
      
      private var _box:Vector.<Number>;
      
      private var _id:Id;
      
      public function A3DBox(param1:Vector.<Number>, param2:Id)
      {
         super();
         this._box = param1;
         this._id = param2;
      }
      
      public function get box() : Vector.<Number>
      {
         return this._box;
      }
      
      public function set box(param1:Vector.<Number>) : void
      {
         this._box = param1;
      }
      
      public function get id() : Id
      {
         return this._id;
      }
      
      public function set id(param1:Id) : void
      {
         this._id = param1;
      }
      
      public function toString() : String
      {
         var _loc1_:String = "A3DBox [";
         _loc1_ += "box = " + this.box + " ";
         _loc1_ += "id = " + this.id + " ";
         return _loc1_ + "]";
      }
   }
}

