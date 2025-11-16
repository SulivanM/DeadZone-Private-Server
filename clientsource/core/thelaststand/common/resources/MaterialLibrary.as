package thelaststand.common.resources
{
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.loaders.ParserMaterial;
   import alternativa.engine3d.materials.Material;
   import alternativa.engine3d.materials.StandardMaterial;
   import alternativa.engine3d.materials.TextureMaterial;
   import alternativa.engine3d.objects.Mesh;
   import alternativa.engine3d.objects.Surface;
   import alternativa.engine3d.resources.BitmapTextureResource;
   import alternativa.engine3d.resources.ExternalTextureResource;
   import flash.display.BitmapData;
   import flash.utils.Dictionary;
   
   public class MaterialLibrary
   {
      
      public static const NORMAL_FLAT_URI:String = "textures/normal-flat";
      
      public static const NULL_URI:String = "textures/null";
      
      private var _bitmapResourcesByURI:Dictionary;
      
      public function MaterialLibrary()
      {
         super();
         this._bitmapResourcesByURI = new Dictionary(true);
      }
      
      public static function formatColladaURL(param1:String) : String
      {
         return param1.substr(param1.indexOf("models/")).replace(/\\/g,"/");
      }
      
      public static function createFlatNormal(param1:int = 2) : BitmapData
      {
         return new BitmapData(2,2,false,8421375);
      }
      
      public static function setTransparentPassToChildren(param1:Object3D, param2:Number) : void
      {
         var _loc4_:int = 0;
         var _loc5_:Surface = null;
         var _loc6_:StandardMaterial = null;
         var _loc3_:Mesh = param1 as Mesh;
         if(_loc3_ != null)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc3_.numSurfaces)
            {
               _loc5_ = _loc3_.getSurface(_loc4_);
               if(_loc5_ != null)
               {
                  _loc6_ = _loc5_.material as StandardMaterial;
                  if(_loc6_ != null)
                  {
                     _loc6_.transparentPass = true;
                     _loc6_.alphaThreshold = param2;
                  }
               }
               _loc4_++;
            }
         }
         _loc4_ = 0;
         while(_loc4_ < param1.numChildren)
         {
            setTransparentPassToChildren(param1.getChildAt(_loc4_),param2);
            _loc4_++;
         }
      }
      
      public function dispose() : void
      {
         this.purge();
         this._bitmapResourcesByURI = null;
      }
      
      public function getBitmapTextureResource(param1:String) : BitmapTextureResource
      {
         var texRes:BitmapTextureResource = null;
         var bmd:BitmapData = null;
         var res:Resource = null;
         var width:int = 0;
         var uri:String = param1;
         texRes = this._bitmapResourcesByURI[uri];
         if(texRes == null)
         {
            if(uri == NORMAL_FLAT_URI)
            {
               bmd = createFlatNormal();
            }
            else if(uri == NULL_URI)
            {
               bmd = new BitmapData(2,2,false,16711680);
            }
            else
            {
               res = ResourceManager.getInstance().getResource(uri);
               if(res != null)
               {
                  bmd = res.content;
               }
            }
            if(bmd != null)
            {
               texRes = new BitmapTextureResource(bmd);
               this._bitmapResourcesByURI[uri] = texRes;
               return texRes;
            }
            return null;
         }
         if(texRes.data == null)
         {
            texRes.dispose();
            this._bitmapResourcesByURI[uri] = null;
            delete this._bitmapResourcesByURI[uri];
            return this.getBitmapTextureResource(uri);
         }
         try
         {
            width = texRes.data.width;
         }
         catch(e:Error)
         {
            texRes.dispose();
            _bitmapResourcesByURI[uri] = null;
            delete _bitmapResourcesByURI[uri];
            return getBitmapTextureResource(uri);
         }
         return texRes;
      }
      
      public function getMaterialFromParser(param1:ParserMaterial, param2:Class = null) : Material
      {
         var _loc3_:String = null;
         var _loc5_:String = null;
         var _loc6_:Material = null;
         var _loc7_:ExternalTextureResource = null;
         var _loc8_:String = null;
         var _loc4_:Dictionary = new Dictionary(true);
         for(_loc5_ in param1.textures)
         {
            _loc7_ = ExternalTextureResource(param1.textures[_loc5_]);
            _loc8_ = formatColladaURL(_loc7_.url);
            _loc4_[_loc5_] = _loc8_;
         }
         if(_loc4_.diffuse == null)
         {
            return null;
         }
         if(_loc4_.bump == null)
         {
            _loc4_.bump = NORMAL_FLAT_URI;
         }
         switch(param2)
         {
            case TextureMaterial:
               _loc6_ = this.getTextureMaterial(param1.name,_loc4_.diffuse,_loc4_.transparent);
               break;
            default:
               _loc6_ = this.getStandardMaterial(param1.name,_loc4_.diffuse,_loc4_.bump,_loc4_.specular,_loc4_.shininess,_loc4_.transparent);
         }
         return _loc6_;
      }
      
      public function getStandardMaterial(param1:String, param2:String, param3:String = "textures/normal-flat", param4:String = null, param5:String = null, param6:String = null, param7:Boolean = false) : StandardMaterial
      {
         var _loc8_:BitmapTextureResource = param2 ? this.getBitmapTextureResource(param2) : this.getBitmapTextureResource(NULL_URI);
         var _loc9_:BitmapTextureResource = param3 ? this.getBitmapTextureResource(param3) : this.getBitmapTextureResource(NORMAL_FLAT_URI);
         var _loc10_:BitmapTextureResource = param4 ? this.getBitmapTextureResource(param4) : null;
         var _loc11_:BitmapTextureResource = param5 ? this.getBitmapTextureResource(param5) : null;
         var _loc12_:BitmapTextureResource = param6 ? this.getBitmapTextureResource(param6) : null;
         var _loc13_:StandardMaterial = new StandardMaterial(_loc8_,_loc9_,_loc10_,_loc11_,_loc12_);
         _loc13_.name = param1;
         _loc13_.specularPower = 0;
         if(_loc12_ != null || param2.indexOf(".png") > -1)
         {
            _loc13_.transparentPass = true;
            _loc13_.alphaThreshold = 0.9;
         }
         else
         {
            _loc13_.transparentPass = false;
            _loc13_.alphaThreshold = 0;
         }
         return _loc13_;
      }
      
      public function getTextureMaterial(param1:String, param2:String = null, param3:String = null) : TextureMaterial
      {
         var _loc4_:BitmapTextureResource = param2 ? this.getBitmapTextureResource(param2) : this.getBitmapTextureResource(NULL_URI);
         var _loc5_:BitmapTextureResource = param3 ? this.getBitmapTextureResource(param3) : null;
         var _loc6_:TextureMaterial = new TextureMaterial(_loc4_,_loc5_);
         _loc6_.name = param1;
         if(_loc5_ != null || param2.indexOf(".png") > -1)
         {
            _loc6_.transparentPass = true;
            _loc6_.alphaThreshold = 0.9;
         }
         else
         {
            _loc6_.transparentPass = false;
            _loc6_.alphaThreshold = 0;
         }
         return _loc6_;
      }
      
      public function purge(param1:String = null) : void
      {
         if(param1 != null)
         {
            if(this._bitmapResourcesByURI[param1] != null)
            {
               BitmapTextureResource(this._bitmapResourcesByURI[param1]).dispose();
            }
            this._bitmapResourcesByURI[param1] = null;
            delete this._bitmapResourcesByURI[param1];
            return;
         }
         for(param1 in this._bitmapResourcesByURI)
         {
            if(this._bitmapResourcesByURI[param1] != null)
            {
               BitmapTextureResource(this._bitmapResourcesByURI[param1]).dispose();
            }
         }
         this._bitmapResourcesByURI = new Dictionary(true);
      }
   }
}

