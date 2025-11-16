package versions.version1.a3d.objects
{
   import commons.Id;
   import versions.version1.a3d.id.ParentId;
   
   public class A3DObject
   {
      
      private var _boundBoxId:Id;
      
      private var _geometryId:Id;
      
      private var _id:Id;
      
      private var _name:String;
      
      private var _parentId:ParentId;
      
      private var _surfaces:Vector.<A3DSurface>;
      
      private var _transformation:A3DTransformation;
      
      private var _visible:Boolean;
      
      public function A3DObject(param1:Id, param2:Id, param3:Id, param4:String, param5:ParentId, param6:Vector.<A3DSurface>, param7:A3DTransformation, param8:Boolean)
      {
         super();
         this._boundBoxId = param1;
         this._geometryId = param2;
         this._id = param3;
         this._name = param4;
         this._parentId = param5;
         this._surfaces = param6;
         this._transformation = param7;
         this._visible = param8;
      }
      
      public function get boundBoxId() : Id
      {
         return this._boundBoxId;
      }
      
      public function set boundBoxId(param1:Id) : void
      {
         this._boundBoxId = param1;
      }
      
      public function get geometryId() : Id
      {
         return this._geometryId;
      }
      
      public function set geometryId(param1:Id) : void
      {
         this._geometryId = param1;
      }
      
      public function get id() : Id
      {
         return this._id;
      }
      
      public function set id(param1:Id) : void
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
      
      public function get parentId() : ParentId
      {
         return this._parentId;
      }
      
      public function set parentId(param1:ParentId) : void
      {
         this._parentId = param1;
      }
      
      public function get surfaces() : Vector.<A3DSurface>
      {
         return this._surfaces;
      }
      
      public function set surfaces(param1:Vector.<A3DSurface>) : void
      {
         this._surfaces = param1;
      }
      
      public function get transformation() : A3DTransformation
      {
         return this._transformation;
      }
      
      public function set transformation(param1:A3DTransformation) : void
      {
         this._transformation = param1;
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
         var _loc1_:String = "A3DObject [";
         _loc1_ += "boundBoxId = " + this.boundBoxId + " ";
         _loc1_ += "geometryId = " + this.geometryId + " ";
         _loc1_ += "id = " + this.id + " ";
         _loc1_ += "name = " + this.name + " ";
         _loc1_ += "parentId = " + this.parentId + " ";
         _loc1_ += "surfaces = " + this.surfaces + " ";
         _loc1_ += "transformation = " + this.transformation + " ";
         _loc1_ += "visible = " + this.visible + " ";
         return _loc1_ + "]";
      }
   }
}

