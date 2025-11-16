package versions.version2.a3d.materials
{
   public class A3D2Material
   {
      
      private var _diffuseMapId:int;
      
      private var _glossinessMapId:int;
      
      private var _id:int;
      
      private var _lightMapId:int;
      
      private var _normalMapId:int;
      
      private var _opacityMapId:int;
      
      private var _reflectionCubeMapId:int;
      
      private var _specularMapId:int;
      
      public function A3D2Material(param1:int, param2:int, param3:int, param4:int, param5:int, param6:int, param7:int, param8:int)
      {
         super();
         this._diffuseMapId = param1;
         this._glossinessMapId = param2;
         this._id = param3;
         this._lightMapId = param4;
         this._normalMapId = param5;
         this._opacityMapId = param6;
         this._reflectionCubeMapId = param7;
         this._specularMapId = param8;
      }
      
      public function get diffuseMapId() : int
      {
         return this._diffuseMapId;
      }
      
      public function set diffuseMapId(param1:int) : void
      {
         this._diffuseMapId = param1;
      }
      
      public function get glossinessMapId() : int
      {
         return this._glossinessMapId;
      }
      
      public function set glossinessMapId(param1:int) : void
      {
         this._glossinessMapId = param1;
      }
      
      public function get id() : int
      {
         return this._id;
      }
      
      public function set id(param1:int) : void
      {
         this._id = param1;
      }
      
      public function get lightMapId() : int
      {
         return this._lightMapId;
      }
      
      public function set lightMapId(param1:int) : void
      {
         this._lightMapId = param1;
      }
      
      public function get normalMapId() : int
      {
         return this._normalMapId;
      }
      
      public function set normalMapId(param1:int) : void
      {
         this._normalMapId = param1;
      }
      
      public function get opacityMapId() : int
      {
         return this._opacityMapId;
      }
      
      public function set opacityMapId(param1:int) : void
      {
         this._opacityMapId = param1;
      }
      
      public function get reflectionCubeMapId() : int
      {
         return this._reflectionCubeMapId;
      }
      
      public function set reflectionCubeMapId(param1:int) : void
      {
         this._reflectionCubeMapId = param1;
      }
      
      public function get specularMapId() : int
      {
         return this._specularMapId;
      }
      
      public function set specularMapId(param1:int) : void
      {
         this._specularMapId = param1;
      }
      
      public function toString() : String
      {
         var _loc1_:String = "A3D2Material [";
         _loc1_ += "diffuseMapId = " + this.diffuseMapId + " ";
         _loc1_ += "glossinessMapId = " + this.glossinessMapId + " ";
         _loc1_ += "id = " + this.id + " ";
         _loc1_ += "lightMapId = " + this.lightMapId + " ";
         _loc1_ += "normalMapId = " + this.normalMapId + " ";
         _loc1_ += "opacityMapId = " + this.opacityMapId + " ";
         _loc1_ += "reflectionCubeMapId = " + this.reflectionCubeMapId + " ";
         _loc1_ += "specularMapId = " + this.specularMapId + " ";
         return _loc1_ + "]";
      }
   }
}

