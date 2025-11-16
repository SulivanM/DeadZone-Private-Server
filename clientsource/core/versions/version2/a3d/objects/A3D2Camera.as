package versions.version2.a3d.objects
{
   import alternativa.types.Long;
   
   public class A3D2Camera
   {
      
      private var _boundBoxId:int;
      
      private var _farClipping:Number;
      
      private var _fov:Number;
      
      private var _id:Long;
      
      private var _name:String;
      
      private var _nearClipping:Number;
      
      private var _orthographic:Boolean;
      
      private var _parentId:Long;
      
      private var _transform:A3D2Transform;
      
      private var _visible:Boolean;
      
      public function A3D2Camera(param1:int, param2:Number, param3:Number, param4:Long, param5:String, param6:Number, param7:Boolean, param8:Long, param9:A3D2Transform, param10:Boolean)
      {
         super();
         this._boundBoxId = param1;
         this._farClipping = param2;
         this._fov = param3;
         this._id = param4;
         this._name = param5;
         this._nearClipping = param6;
         this._orthographic = param7;
         this._parentId = param8;
         this._transform = param9;
         this._visible = param10;
      }
      
      public function get boundBoxId() : int
      {
         return this._boundBoxId;
      }
      
      public function set boundBoxId(param1:int) : void
      {
         this._boundBoxId = param1;
      }
      
      public function get farClipping() : Number
      {
         return this._farClipping;
      }
      
      public function set farClipping(param1:Number) : void
      {
         this._farClipping = param1;
      }
      
      public function get fov() : Number
      {
         return this._fov;
      }
      
      public function set fov(param1:Number) : void
      {
         this._fov = param1;
      }
      
      public function get id() : Long
      {
         return this._id;
      }
      
      public function set id(param1:Long) : void
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
      
      public function get nearClipping() : Number
      {
         return this._nearClipping;
      }
      
      public function set nearClipping(param1:Number) : void
      {
         this._nearClipping = param1;
      }
      
      public function get orthographic() : Boolean
      {
         return this._orthographic;
      }
      
      public function set orthographic(param1:Boolean) : void
      {
         this._orthographic = param1;
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
         var _loc1_:String = "A3D2Camera [";
         _loc1_ += "boundBoxId = " + this.boundBoxId + " ";
         _loc1_ += "farClipping = " + this.farClipping + " ";
         _loc1_ += "fov = " + this.fov + " ";
         _loc1_ += "id = " + this.id + " ";
         _loc1_ += "name = " + this.name + " ";
         _loc1_ += "nearClipping = " + this.nearClipping + " ";
         _loc1_ += "orthographic = " + this.orthographic + " ";
         _loc1_ += "parentId = " + this.parentId + " ";
         _loc1_ += "transform = " + this.transform + " ";
         _loc1_ += "visible = " + this.visible + " ";
         return _loc1_ + "]";
      }
   }
}

