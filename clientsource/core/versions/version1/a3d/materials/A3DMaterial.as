package versions.version1.a3d.materials
{
   import commons.Id;
   
   public class A3DMaterial
   {
      
      private var _diffuseMapId:Id;
      
      private var _glossinessMapId:Id;
      
      private var _id:Id;
      
      private var _lightMapId:Id;
      
      private var _normalMapId:Id;
      
      private var _opacityMapId:Id;
      
      private var _specularMapId:Id;
      
      public function A3DMaterial(param1:Id, param2:Id, param3:Id, param4:Id, param5:Id, param6:Id, param7:Id)
      {
         super();
         this._diffuseMapId = param1;
         this._glossinessMapId = param2;
         this._id = param3;
         this._lightMapId = param4;
         this._normalMapId = param5;
         this._opacityMapId = param6;
         this._specularMapId = param7;
      }
      
      public function get diffuseMapId() : Id
      {
         return this._diffuseMapId;
      }
      
      public function set diffuseMapId(param1:Id) : void
      {
         this._diffuseMapId = param1;
      }
      
      public function get glossinessMapId() : Id
      {
         return this._glossinessMapId;
      }
      
      public function set glossinessMapId(param1:Id) : void
      {
         this._glossinessMapId = param1;
      }
      
      public function get id() : Id
      {
         return this._id;
      }
      
      public function set id(param1:Id) : void
      {
         this._id = param1;
      }
      
      public function get lightMapId() : Id
      {
         return this._lightMapId;
      }
      
      public function set lightMapId(param1:Id) : void
      {
         this._lightMapId = param1;
      }
      
      public function get normalMapId() : Id
      {
         return this._normalMapId;
      }
      
      public function set normalMapId(param1:Id) : void
      {
         this._normalMapId = param1;
      }
      
      public function get opacityMapId() : Id
      {
         return this._opacityMapId;
      }
      
      public function set opacityMapId(param1:Id) : void
      {
         this._opacityMapId = param1;
      }
      
      public function get specularMapId() : Id
      {
         return this._specularMapId;
      }
      
      public function set specularMapId(param1:Id) : void
      {
         this._specularMapId = param1;
      }
      
      public function toString() : String
      {
         var _loc1_:String = "A3DMaterial [";
         _loc1_ += "diffuseMapId = " + this.diffuseMapId + " ";
         _loc1_ += "glossinessMapId = " + this.glossinessMapId + " ";
         _loc1_ += "id = " + this.id + " ";
         _loc1_ += "lightMapId = " + this.lightMapId + " ";
         _loc1_ += "normalMapId = " + this.normalMapId + " ";
         _loc1_ += "opacityMapId = " + this.opacityMapId + " ";
         _loc1_ += "specularMapId = " + this.specularMapId + " ";
         return _loc1_ + "]";
      }
   }
}

