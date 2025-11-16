package versions.version2.a3d.objects
{
   import alternativa.types.Long;
   
   public class A3D2Sprite
   {
      
      private var _alwaysOnTop:Boolean;
      
      private var _boundBoxId:int;
      
      private var _height:Number;
      
      private var _id:Long;
      
      private var _materialId:int;
      
      private var _name:String;
      
      private var _originX:Number;
      
      private var _originY:Number;
      
      private var _parentId:Long;
      
      private var _perspectiveScale:Boolean;
      
      private var _rotation:Number;
      
      private var _transform:A3D2Transform;
      
      private var _visible:Boolean;
      
      private var _width:Number;
      
      public function A3D2Sprite(param1:Boolean, param2:int, param3:Number, param4:Long, param5:int, param6:String, param7:Number, param8:Number, param9:Long, param10:Boolean, param11:Number, param12:A3D2Transform, param13:Boolean, param14:Number)
      {
         super();
         this._alwaysOnTop = param1;
         this._boundBoxId = param2;
         this._height = param3;
         this._id = param4;
         this._materialId = param5;
         this._name = param6;
         this._originX = param7;
         this._originY = param8;
         this._parentId = param9;
         this._perspectiveScale = param10;
         this._rotation = param11;
         this._transform = param12;
         this._visible = param13;
         this._width = param14;
      }
      
      public function get alwaysOnTop() : Boolean
      {
         return this._alwaysOnTop;
      }
      
      public function set alwaysOnTop(param1:Boolean) : void
      {
         this._alwaysOnTop = param1;
      }
      
      public function get boundBoxId() : int
      {
         return this._boundBoxId;
      }
      
      public function set boundBoxId(param1:int) : void
      {
         this._boundBoxId = param1;
      }
      
      public function get height() : Number
      {
         return this._height;
      }
      
      public function set height(param1:Number) : void
      {
         this._height = param1;
      }
      
      public function get id() : Long
      {
         return this._id;
      }
      
      public function set id(param1:Long) : void
      {
         this._id = param1;
      }
      
      public function get materialId() : int
      {
         return this._materialId;
      }
      
      public function set materialId(param1:int) : void
      {
         this._materialId = param1;
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function set name(param1:String) : void
      {
         this._name = param1;
      }
      
      public function get originX() : Number
      {
         return this._originX;
      }
      
      public function set originX(param1:Number) : void
      {
         this._originX = param1;
      }
      
      public function get originY() : Number
      {
         return this._originY;
      }
      
      public function set originY(param1:Number) : void
      {
         this._originY = param1;
      }
      
      public function get parentId() : Long
      {
         return this._parentId;
      }
      
      public function set parentId(param1:Long) : void
      {
         this._parentId = param1;
      }
      
      public function get perspectiveScale() : Boolean
      {
         return this._perspectiveScale;
      }
      
      public function set perspectiveScale(param1:Boolean) : void
      {
         this._perspectiveScale = param1;
      }
      
      public function get rotation() : Number
      {
         return this._rotation;
      }
      
      public function set rotation(param1:Number) : void
      {
         this._rotation = param1;
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
      
      public function get width() : Number
      {
         return this._width;
      }
      
      public function set width(param1:Number) : void
      {
         this._width = param1;
      }
      
      public function toString() : String
      {
         var _loc1_:String = "A3D2Sprite [";
         _loc1_ += "alwaysOnTop = " + this.alwaysOnTop + " ";
         _loc1_ += "boundBoxId = " + this.boundBoxId + " ";
         _loc1_ += "height = " + this.height + " ";
         _loc1_ += "id = " + this.id + " ";
         _loc1_ += "materialId = " + this.materialId + " ";
         _loc1_ += "name = " + this.name + " ";
         _loc1_ += "originX = " + this.originX + " ";
         _loc1_ += "originY = " + this.originY + " ";
         _loc1_ += "parentId = " + this.parentId + " ";
         _loc1_ += "perspectiveScale = " + this.perspectiveScale + " ";
         _loc1_ += "rotation = " + this.rotation + " ";
         _loc1_ += "transform = " + this.transform + " ";
         _loc1_ += "visible = " + this.visible + " ";
         _loc1_ += "width = " + this.width + " ";
         return _loc1_ + "]";
      }
   }
}

