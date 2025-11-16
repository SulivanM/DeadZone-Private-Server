package alternativa.engine3d.loaders
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.Camera3D;
   import alternativa.engine3d.core.Light3D;
   import alternativa.engine3d.materials.*;
   import alternativa.engine3d.objects.Surface;
   import alternativa.engine3d.resources.ExternalTextureResource;
   import alternativa.engine3d.resources.Geometry;
   import alternativa.engine3d.resources.TextureResource;
   import avmplus.getQualifiedClassName;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   
   use namespace alternativa3d;
   
   public class ParserMaterial extends Material
   {
      
      public var colors:Object;
      
      public var textures:Object;
      
      public var glossiness:Number = 0;
      
      public var transparency:Number = 0;
      
      public var renderChannel:String = "diffuse";
      
      private var textureMaterial:TextureMaterial;
      
      private var fillMaterial:FillMaterial;
      
      public function ParserMaterial()
      {
         super();
         this.textures = {};
         this.colors = {};
      }
      
      override alternativa3d function fillResources(param1:Dictionary, param2:Class) : void
      {
         var _loc3_:TextureResource = null;
         super.alternativa3d::fillResources(param1,param2);
         for each(_loc3_ in this.textures)
         {
            if(_loc3_ != null && A3DUtils.alternativa3d::checkParent(getDefinitionByName(getQualifiedClassName(_loc3_)) as Class,param2))
            {
               param1[_loc3_] = true;
            }
         }
      }
      
      override alternativa3d function collectDraws(param1:Camera3D, param2:Surface, param3:Geometry, param4:Vector.<Light3D>, param5:int, param6:Boolean, param7:int = -1) : void
      {
         var _loc9_:ExternalTextureResource = null;
         var _loc8_:Object = this.colors[this.renderChannel];
         if(_loc8_ != null)
         {
            if(this.fillMaterial == null)
            {
               this.fillMaterial = new FillMaterial(int(_loc8_));
            }
            else
            {
               this.fillMaterial.color = int(_loc8_);
            }
            this.fillMaterial.alternativa3d::collectDraws(param1,param2,param3,param4,param5,false,param7);
         }
         else
         {
            _loc9_ = this.textures[this.renderChannel];
            if(_loc9_ != null)
            {
               if(this.textureMaterial == null)
               {
                  this.textureMaterial = new TextureMaterial(_loc9_);
               }
               else
               {
                  this.textureMaterial.diffuseMap = _loc9_;
               }
               this.textureMaterial.alternativa3d::collectDraws(param1,param2,param3,param4,param5,false,param7);
            }
         }
      }
   }
}

