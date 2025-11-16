package thelaststand.app.game.entities.buildings
{
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.VertexAttributes;
   import alternativa.engine3d.materials.Material;
   import alternativa.engine3d.materials.TextureMaterial;
   import alternativa.engine3d.objects.Decal;
   import alternativa.engine3d.resources.BitmapTextureResource;
   import alternativa.engine3d.resources.Geometry;
   import flash.utils.Dictionary;
   import thelaststand.common.resources.ResourceManager;
   
   public class BuildingFootprint extends Object3D
   {
      
      private static var _materialsSet:Boolean;
      
      private static var _geometryLookup:Dictionary = new Dictionary(true);
      
      public static const MAT_FOOTPRINT_BUFFER:TextureMaterial = new TextureMaterial();
      
      public static const MAT_FOOTPRINT_LEGAL:TextureMaterial = new TextureMaterial();
      
      public static const MAT_FOOTPRINT_ILLEGAL:TextureMaterial = new TextureMaterial();
      
      private var _width:int;
      
      private var _height:int;
      
      private var _bufferX:int;
      
      private var _bufferY:int;
      
      private var _tileSize:int;
      
      private var _valid:Boolean = true;
      
      private var _bufferDecals:Vector.<Decal>;
      
      private var mesh_center:Decal;
      
      public function BuildingFootprint(param1:int, param2:int, param3:int = 1, param4:int = 1, param5:int = 100)
      {
         var _loc7_:ResourceManager = null;
         var _loc8_:Geometry = null;
         var _loc9_:Decal = null;
         var _loc10_:Decal = null;
         var _loc11_:Geometry = null;
         var _loc12_:Decal = null;
         var _loc13_:Decal = null;
         super();
         if(!_materialsSet)
         {
            _materialsSet = false;
            _loc7_ = ResourceManager.getInstance();
            MAT_FOOTPRINT_BUFFER.diffuseMap = _loc7_.materials.getBitmapTextureResource("images/ui/tile-blueprint-blue-feet.jpg");
            MAT_FOOTPRINT_BUFFER.transparentPass = false;
            MAT_FOOTPRINT_BUFFER.alphaThreshold = 0;
            MAT_FOOTPRINT_LEGAL.diffuseMap = _loc7_.materials.getBitmapTextureResource("images/ui/tile-blueprint-blue.jpg");
            MAT_FOOTPRINT_LEGAL.transparentPass = false;
            MAT_FOOTPRINT_LEGAL.alphaThreshold = 0;
            MAT_FOOTPRINT_ILLEGAL.diffuseMap = _loc7_.materials.getBitmapTextureResource("images/ui/tile-blueprint-red.jpg");
            MAT_FOOTPRINT_ILLEGAL.transparentPass = false;
            MAT_FOOTPRINT_ILLEGAL.alphaThreshold = 0;
         }
         this._width = param1;
         this._height = param2;
         this._bufferX = param3;
         this._bufferY = param4;
         this._tileSize = param5;
         mouseEnabled = mouseChildren = false;
         var _loc6_:int = this._tileSize * 0.5;
         this.mesh_center = new Decal();
         this.mesh_center.geometry = getGeometry(this._width * this._tileSize,this._height * this._tileSize,false,this._tileSize);
         this.mesh_center.addSurface(MAT_FOOTPRINT_LEGAL,0,2);
         this.mesh_center.x = -(param1 * this._tileSize) + _loc6_;
         this.mesh_center.y = -_loc6_;
         this.mesh_center.mouseEnabled = this.mesh_center.mouseChildren = false;
         addChild(this.mesh_center);
         this._bufferDecals = new Vector.<Decal>();
         if(this._bufferX > 0)
         {
            _loc8_ = getGeometry(this._bufferX * this._tileSize,(this._height + Math.min(this._bufferY * 2,0)) * this._tileSize,true,this._tileSize);
            _loc9_ = new Decal();
            _loc9_.mouseEnabled = _loc9_.mouseChildren = false;
            _loc9_.geometry = _loc8_;
            _loc9_.addSurface(MAT_FOOTPRINT_BUFFER,0,2);
            _loc9_.useShadow = false;
            _loc9_.x = this.mesh_center.x - this._bufferX * this._tileSize + _loc6_;
            _loc9_.y = this.mesh_center.y + this._height * this._tileSize * 0.5;
            this._bufferDecals.push(_loc9_);
            addChild(_loc9_);
            _loc10_ = new Decal();
            _loc10_.mouseEnabled = _loc10_.mouseChildren = false;
            _loc10_.geometry = _loc8_;
            _loc10_.addSurface(MAT_FOOTPRINT_BUFFER,0,2);
            _loc10_.useShadow = false;
            _loc10_.x = this._bufferX * this._tileSize;
            _loc10_.y = _loc9_.y;
            this._bufferDecals.push(_loc10_);
            addChild(_loc10_);
         }
         if(this._bufferY > 0)
         {
            _loc11_ = getGeometry((this._width + Math.min(this._bufferX * 2,0)) * this._tileSize,this._bufferY * this._tileSize,true,this._tileSize);
            _loc12_ = new Decal();
            _loc12_.mouseEnabled = _loc12_.mouseChildren = false;
            _loc12_.geometry = _loc11_;
            _loc12_.addSurface(MAT_FOOTPRINT_BUFFER,0,2);
            _loc12_.useShadow = false;
            _loc12_.x = this.mesh_center.x + this._width * this._tileSize * 0.5;
            _loc12_.y = this.mesh_center.y + this._height * this._tileSize + _loc6_;
            this._bufferDecals.push(_loc12_);
            addChild(_loc12_);
            _loc13_ = new Decal();
            _loc13_.mouseEnabled = _loc13_.mouseChildren = false;
            _loc13_.geometry = _loc11_;
            _loc13_.addSurface(MAT_FOOTPRINT_BUFFER,0,2);
            _loc13_.useShadow = false;
            _loc13_.x = _loc12_.x;
            _loc13_.y = this.mesh_center.y - _loc6_;
            this._bufferDecals.push(_loc13_);
            addChild(_loc13_);
         }
      }
      
      private static function getGeometry(param1:int, param2:int, param3:Boolean, param4:int) : Geometry
      {
         var _loc5_:String = param1 + "_" + param2 + "_" + param3 + "_" + param4;
         var _loc6_:Geometry = _geometryLookup[_loc5_];
         if(_loc6_ == null)
         {
            _loc6_ = createGeometry(param1,param2,param3,param4);
            _geometryLookup[_loc5_] = _loc6_;
         }
         return _loc6_;
      }
      
      private static function createGeometry(param1:int, param2:int, param3:Boolean, param4:int) : Geometry
      {
         var _loc9_:Array = null;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc5_:Array = [VertexAttributes.POSITION,VertexAttributes.POSITION,VertexAttributes.POSITION,VertexAttributes.TEXCOORDS[0],VertexAttributes.TEXCOORDS[0]];
         var _loc6_:int = BitmapTextureResource(MAT_FOOTPRINT_LEGAL.diffuseMap).data.width;
         var _loc7_:int = BitmapTextureResource(MAT_FOOTPRINT_LEGAL.diffuseMap).data.height;
         var _loc8_:Geometry = new Geometry();
         _loc8_.addVertexStream(_loc5_);
         _loc8_.numVertices = 4;
         if(param3)
         {
            _loc14_ = param1 * 0.5;
            _loc15_ = param2 * 0.5;
            _loc9_ = [-_loc14_,-_loc15_,0,_loc14_,-_loc15_,0,_loc14_,_loc15_,0,-_loc14_,_loc15_,0];
         }
         else
         {
            _loc9_ = [0,0,0,param1,0,0,param1,param2,0,0,param2,0];
         }
         var _loc10_:Number = _loc6_ / (_loc6_ / (param1 / param4));
         var _loc11_:Number = _loc7_ / (_loc7_ / (param2 / param4));
         var _loc12_:Array = [0,0,_loc10_,0,_loc10_,_loc11_,0,_loc11_];
         var _loc13_:Array = [0,1,2,0,2,3];
         _loc8_.setAttributeValues(VertexAttributes.POSITION,Vector.<Number>(_loc9_));
         _loc8_.setAttributeValues(VertexAttributes.TEXCOORDS[0],Vector.<Number>(_loc12_));
         _loc8_.indices = Vector.<uint>(_loc13_);
         return _loc8_;
      }
      
      public function dispose() : void
      {
         var _loc1_:Decal = null;
         if(parent != null)
         {
            parent.removeChild(this);
         }
         if(this._bufferDecals != null)
         {
            for each(_loc1_ in this._bufferDecals)
            {
               _loc1_.setMaterialToAllSurfaces(null);
               _loc1_.geometry = null;
            }
            this._bufferDecals = null;
         }
         this.mesh_center.setMaterialToAllSurfaces(null);
         this.mesh_center.geometry = null;
         this.mesh_center = null;
      }
      
      public function get valid() : Boolean
      {
         return this._valid;
      }
      
      public function set valid(param1:Boolean) : void
      {
         var _loc2_:TextureMaterial = null;
         var _loc3_:Decal = null;
         this._valid = param1;
         if(this._bufferDecals != null)
         {
            _loc2_ = this._valid ? MAT_FOOTPRINT_BUFFER : MAT_FOOTPRINT_ILLEGAL;
            for each(_loc3_ in this._bufferDecals)
            {
               _loc3_.setMaterialToAllSurfaces(_loc2_);
            }
         }
         this.mesh_center.setMaterialToAllSurfaces(this._valid ? MAT_FOOTPRINT_LEGAL : MAT_FOOTPRINT_ILLEGAL);
      }
   }
}

