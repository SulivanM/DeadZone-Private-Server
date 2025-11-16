package versions.version2.a3d.objects
{
   import alternativa.types.Long;
   
   public class A3D2DirectionalLight
   {
      
      private var _boundBoxId:int;
      
      private var _color:uint;
      
      private var _id:Long;
      
      private var _intensity:Number;
      
      private var _name:String;
      
      private var _parentId:Long;
      
      private var _transform:A3D2Transform;
      
      private var _visible:Boolean;
      
      public function A3D2DirectionalLight(param1:int, param2:uint, param3:Long, param4:Number, param5:String, param6:Long, param7:A3D2Transform, param8:Boolean)
      {
         super();
         this._boundBoxId = param1;
         this._color = param2;
         this._id = param3;
         this._intensity = param4;
         this._name = param5;
         this._parentId = param6;
         this._transform = param7;
         this._visible = param8;
      }
      
      public function get boundBoxId() : int
      {
         return this._boundBoxId;
      }
      
      public function set boundBoxId(param1:int) : void
      {
         this._boundBoxId = param1;
      }
      
      public function get color() : uint
      {
         return this._color;
      }
      
      public function set color(param1:uint) : void
      {
         this._color = param1;
      }
      
      public function get id() : Long
      {
         return this._id;
      }
      
      public function set id(param1:Long) : void
      {
         this._id = param1;
      }
      
      public function get intensity() : Number
      {
         return this._intensity;
      }
      
      public function set intensity(param1:Number) : void
      {
         this._intensity = param1;
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function set name(param1:String) : void
      {
         this._name = param1;
      }
      
      public function get parentId() : Long
      {
         return this._parentId;
      }
      
      public function set parentId(param1:Long) : void
      {
         this._parentId = param1;
      }
      
      public function get transform() : A3D2Transform
      {
         return this._transform;
      }
      
      public function set transform(param1:A3D2Transform) : void
      {
         this._transform = param1;
      }
      
      public function get visible() : Boolean
      {
         return this._visible;
      }
      
      public function set visible(param1:Boolean) : void
      {
         this._visible = param1;
      }
      
      public function toString() : String
      {
         var _loc1_:String = "A3D2DirectionalLight [";
         _loc1_ += "boundBoxId = " + this.boundBoxId + " ";
         _loc1_ += "color = " + this.color + " ";
         _loc1_ += "id = " + this.id + " ";
         _loc1_ += "intensity = " + this.intensity + " ";
         _loc1_ += "name = " + this.name + " ";
         _loc1_ += "parentId = " + this.parentId + " ";
         _loc1_ += "transform = " + this.transform + " ";
         _loc1_ += "visible = " + this.visible + " ";
         return _loc1_ + "]";
      }
   }
}

