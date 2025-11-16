package versions.version2.a3d.objects
{
   public class A3D2Box
   {
      
      private var _box:Vector.<Number>;
      
      private var _id:int;
      
      public function A3D2Box(param1:Vector.<Number>, param2:int)
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
      
      public function get id() : int
      {
         return this._id;
      }
      
      public function set id(param1:int) : void
      {
         this._id = param1;
      }
      
      public function toString() : String
      {
         var _loc1_:String = "A3D2Box [";
         _loc1_ += "box = " + this.box + " ";
         _loc1_ += "id = " + this.id + " ";
         return _loc1_ + "]";
      }
   }
}

