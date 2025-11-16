package versions.version2.a3d.objects
{
   import alternativa.types.Long;
   
   public class A3D2Layer
   {
      
      private var _id:int;
      
      private var _name:String;
      
      private var _objects:Vector.<Long>;
      
      public function A3D2Layer(param1:int, param2:String, param3:Vector.<Long>)
      {
         super();
         this._id = param1;
         this._name = param2;
         this._objects = param3;
      }
      
      public function get id() : int
      {
         return this._id;
      }
      
      public function set id(param1:int) : void
      {
         this._id = param1;
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function set name(param1:String) : void
      {
         this._name = param1;
      }
      
      public function get objects() : Vector.<Long>
      {
         return this._objects;
      }
      
      public function set objects(param1:Vector.<Long>) : void
      {
         this._objects = param1;
      }
      
      public function toString() : String
      {
         var _loc1_:String = "A3D2Layer [";
         _loc1_ += "id = " + this.id + " ";
         _loc1_ += "name = " + this.name + " ";
         _loc1_ += "objects = " + this.objects + " ";
         return _loc1_ + "]";
      }
   }
}

