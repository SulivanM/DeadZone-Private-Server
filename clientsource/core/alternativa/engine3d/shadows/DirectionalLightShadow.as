package alternativa.engine3d.shadows
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.BoundBox;
   import alternativa.engine3d.core.Camera3D;
   import alternativa.engine3d.core.Debug;
   import alternativa.engine3d.core.DrawUnit;
   import alternativa.engine3d.core.Light3D;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Renderer;
   import alternativa.engine3d.core.Transform3D;
   import alternativa.engine3d.core.VertexAttributes;
   import alternativa.engine3d.materials.Material;
   import alternativa.engine3d.materials.ShaderProgram;
   import alternativa.engine3d.materials.TextureMaterial;
   import alternativa.engine3d.materials.compiler.Linker;
   import alternativa.engine3d.materials.compiler.Procedure;
   import alternativa.engine3d.materials.compiler.VariableType;
   import alternativa.engine3d.objects.Joint;
   import alternativa.engine3d.objects.Mesh;
   import alternativa.engine3d.objects.Skin;
   import alternativa.engine3d.objects.Surface;
   import alternativa.engine3d.resources.ExternalTextureResource;
   import alternativa.engine3d.resources.Geometry;
   import alternativa.engine3d.resources.TextureResource;
   import flash.display3D.Context3D;
   import flash.display3D.Context3DProgramType;
   import flash.display3D.Context3DTextureFormat;
   import flash.display3D.VertexBuffer3D;
   import flash.display3D.textures.Texture;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;
   
   use namespace alternativa3d;
   
   public class DirectionalLightShadow extends Shadow
   {
      
      private static const DIFFERENCE_MULTIPLIER:Number = 32768;
      
      private static const passUVProcedure:Procedure = new Procedure(["#v0=vUV","#a0=aUV","mov v0, a0"],"passUVProcedure");
      
      private static const diffuseAlphaTestProcedure:Procedure = new Procedure(["#v0=vUV","#s0=sTexture","#c0=cThresholdAlpha","tex t0, v0, s0 <2d, linear,repeat, miplinear>","mul t0.w, t0.w, c0.w","sub t0.w, t0.w, c0.x","kil t0.w"],"diffuseAlphaTestProcedure");
      
      private static const opacityAlphaTestProcedure:Procedure = new Procedure(["#v0=vUV","#s0=sTexture","#c0=cThresholdAlpha","tex t0, v0, s0 <2d, linear,repeat, miplinear>","mul t0.w, t0.x, c0.w","sub t0.w, t0.w, c0.x","kil t0.w"],"opacityAlphaTestProcedure");
      
      private static const pcfOffsetRegisters:Array = ["xx","xy","xz","xw","yx","yy","yz","yw","zx","zy","zz","zw","wx","wy","wz","ww"];
      
      private static const componentByIndex:Array = ["x","y","z","w"];
      
      private var renderer:Renderer = new Renderer();
      
      public var biasMultiplier:Number = 0.97;
      
      public var centerX:Number = 0;
      
      public var centerY:Number = 0;
      
      public var centerZ:Number = 0;
      
      public var width:Number;
      
      public var height:Number;
      
      public var nearBoundPosition:Number = 0;
      
      public var farBoundPosition:Number = 0;
      
      private var _casters:Vector.<Object3D> = new Vector.<Object3D>();
      
      private var actualCasters:Vector.<Object3D> = new Vector.<Object3D>();
      
      private var programs:Dictionary = new Dictionary();
      
      private var cachedContext:Context3D;
      
      private var shadowMap:Texture;
      
      private var _mapSize:int;
      
      private var _pcfOffset:Number;
      
      public var calculateParametersByVolume:Boolean = false;
      
      public var volume:BoundBox = null;
      
      private var debugTexture:ExternalTextureResource = new ExternalTextureResource("debug");
      
      private var debugMaterial:TextureMaterial;
      
      private var emptyLightVector:Vector.<Light3D> = new Vector.<Light3D>();
      
      private var debugPlane:Mesh;
      
      private var cameraToShadowMapContextProjection:Transform3D = new Transform3D();
      
      private var cameraToShadowMapUVProjection:Transform3D = new Transform3D();
      
      private var objectToShadowMapTransform:Transform3D = new Transform3D();
      
      private var globalToLightTransform:Transform3D = new Transform3D();
      
      private var tempBounds:BoundBox = new BoundBox();
      
      private var rect:Rectangle = new Rectangle();
      
      private var tmpPoints:Vector.<Vector3D> = Vector.<Vector3D>([new Vector3D(),new Vector3D(),new Vector3D(),new Vector3D()]);
      
      private var localTmpPoints:Vector.<Vector3D> = Vector.<Vector3D>([new Vector3D(),new Vector3D(),new Vector3D(),new Vector3D()]);
      
      public function DirectionalLightShadow(param1:Number, param2:Number, param3:Number, param4:Number, param5:int = 512, param6:Number = 0)
      {
         super();
         this.width = param1;
         this.height = param2;
         this.nearBoundPosition = param3;
         this.farBoundPosition = param4;
         if(param5 < 2)
         {
            throw new ArgumentError("Map size cannot be less than 2.");
         }
         if(param5 > 2048)
         {
            throw new ArgumentError("Map size exceeds maximum value 2048.");
         }
         if(Math.log(param5) / Math.LN2 % 1 != 0)
         {
            throw new ArgumentError("Map size must be power of two.");
         }
         this._mapSize = param5;
         this._pcfOffset = param6;
         this.alternativa3d::type = this._pcfOffset > 0 ? Shadow.alternativa3d::PCF_MODE : Shadow.alternativa3d::SIMPLE_MODE;
         alternativa3d::vertexShadowProcedure = getVShader();
         alternativa3d::fragmentShadowProcedure = this._pcfOffset > 0 ? getFShaderPCF() : getFShader();
         this.debugMaterial = new TextureMaterial(this.debugTexture);
         this.debugMaterial.alphaThreshold = 1.1;
         this.debugMaterial.opaquePass = false;
         this.debugMaterial.alpha = 0.7;
      }
      
      private static function getVShader() : Procedure
      {
         var _loc1_:Procedure = Procedure.compileFromArray(["#v0=vSample","m34 v0.xyz, i0, c0","mov v0.w, i0.w"],"DirectionalShadowMapVertex");
         _loc1_.assignVariableName(VariableType.CONSTANT,0,"cUVProjection",3);
         return _loc1_;
      }
      
      private static function getFShader() : Procedure
      {
         var _loc1_:Array = ["#v0=vSample","#c0=cConstants","#c1=cDist","#s0=sShadowMap"];
         var _loc2_:int = 4;
         _loc1_[_loc2_++] = "mov t0.zw, v0.zz";
         var _loc4_:*;
         _loc1_[_loc4_ = _loc2_++] = "tex t0.xy, v0, s0 <2d,clamp,near,nomip>";
         var _loc5_:*;
         _loc1_[_loc5_ = _loc2_++] = "dp3 t0.x, t0.xyz, c0.xyz";
         var _loc6_:*;
         _loc1_[_loc6_ = _loc2_++] = "sub t0.y, c1.x, t0.z";
         var _loc7_:*;
         _loc1_[_loc7_ = _loc2_++] = "mul t0.y, t0.y, c1.y";
         var _loc8_:*;
         _loc1_[_loc8_ = _loc2_++] = "sat t0.xy, t0.xy";
         var _loc9_:*;
         _loc1_[_loc9_ = _loc2_++] = "mul t0.x, t0.x, t0.y";
         var _loc10_:*;
         _loc1_[_loc10_ = _loc2_++] = "sub o0, c1.z, t0.x";
         return Procedure.compileFromArray(_loc1_,"DirectionalShadowMapFragment");
      }
      
      private static function getFShaderPCF() : Procedure
      {
         var _loc4_:* = 0;
         var _loc1_:Array = ["#v0=vSample","#c0=cConstants","#c1=cPCFOffsets","#c2=cDist","#s0=sShadowMap"];
         var _loc2_:int = 5;
         var _loc5_:*;
         _loc1_[_loc5_ = _loc2_++] = "mov t0.zw, v0.zz";
         var _loc3_:int = 0;
         while(_loc3_ < 16)
         {
            _loc4_ = _loc3_ & 3;
            var _loc6_:*;
            _loc1_[_loc6_ = _loc2_++] = "add t0.xy, v0.xy, c1." + pcfOffsetRegisters[_loc3_];
            var _loc7_:*;
            _loc1_[_loc7_ = _loc2_++] = "tex t0.xy, t0, s0 <2d,clamp,near,nomip>";
            var _loc8_:*;
            _loc1_[_loc8_ = _loc2_++] = "dp3 t1." + componentByIndex[_loc4_] + ", t0.xyz, c0.xyz";
            if(_loc4_ == 3)
            {
               var _loc9_:*;
               _loc1_[_loc9_ = _loc2_++] = "sat t1, t1";
               var _loc10_:*;
               _loc1_[_loc10_ = _loc2_++] = "dp4 t2." + componentByIndex[int(_loc3_ >> 2)] + ", t1, c0.w";
            }
            _loc3_++;
         }
         _loc1_[_loc6_ = _loc2_++] = "dp4 t0.x, t2, v0.w";
         _loc1_[_loc7_ = _loc2_++] = "sub t0.y, c2.x, t0.z";
         _loc1_[_loc8_ = _loc2_++] = "mul t0.y, t0.y, c2.y";
         _loc1_[_loc9_ = _loc2_++] = "sat t0.y, t0.y";
         _loc1_[_loc10_ = _loc2_++] = "mul t0.x, t0.x, t0.y";
         var _loc11_:*;
         _loc1_[_loc11_ = _loc2_++] = "sub o0, c2.z, t0.x";
         return Procedure.compileFromArray(_loc1_,"DirectionalShadowMapFragment");
      }
      
      private function createDebugPlane(param1:Material, param2:Context3D) : Mesh
      {
         var _loc3_:Mesh = new Mesh();
         var _loc4_:Geometry = new Geometry(4);
         _loc3_.geometry = _loc4_;
         var _loc5_:Array = [];
         _loc5_[0] = VertexAttributes.POSITION;
         _loc5_[1] = VertexAttributes.POSITION;
         _loc5_[2] = VertexAttributes.POSITION;
         _loc5_[3] = VertexAttributes.TEXCOORDS[0];
         _loc5_[4] = VertexAttributes.TEXCOORDS[0];
         _loc4_.addVertexStream(_loc5_);
         _loc4_.setAttributeValues(VertexAttributes.POSITION,Vector.<Number>([-0.5,-0.5,0,-0.5,0.5,0,0.5,0.5,0,0.5,-0.5,0]));
         _loc4_.setAttributeValues(VertexAttributes.TEXCOORDS[0],Vector.<Number>([0,0,0,1,1,1,1,0]));
         _loc4_.indices = Vector.<uint>([0,1,3,2,3,1,0,3,1,2,1,3]);
         _loc3_.addSurface(param1,0,4);
         _loc4_.upload(param2);
         return _loc3_;
      }
      
      override alternativa3d function process(param1:Camera3D) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object3D = null;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc17_:Boolean = false;
         var _loc18_:Object3D = null;
         var _loc19_:Surface = null;
         var _loc4_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < this._casters.length)
         {
            _loc3_ = this._casters[_loc2_];
            _loc17_ = _loc3_.visible;
            _loc18_ = _loc3_.alternativa3d::_parent;
            while(_loc17_ && _loc18_ != null)
            {
               _loc17_ = _loc18_.visible;
               _loc18_ = _loc18_.alternativa3d::_parent;
            }
            if(_loc17_)
            {
               var _loc20_:*;
               this.actualCasters[_loc20_ = _loc4_++] = _loc3_;
            }
            _loc2_++;
         }
         if(param1.alternativa3d::context3D != this.cachedContext)
         {
            this.programs = new Dictionary();
            this.shadowMap = null;
            this.debugPlane = null;
            this.cachedContext = param1.alternativa3d::context3D;
         }
         this.globalToLightTransform.combine(alternativa3d::_light.alternativa3d::cameraToLocalTransform,param1.alternativa3d::globalToLocalTransform);
         if(this.calculateParametersByVolume)
         {
            this.updateParametersByVolume();
         }
         var _loc11_:Number = this.centerX * this.globalToLightTransform.a + this.centerY * this.globalToLightTransform.b + this.centerZ * this.globalToLightTransform.c + this.globalToLightTransform.d;
         var _loc12_:Number = this.centerX * this.globalToLightTransform.e + this.centerY * this.globalToLightTransform.f + this.centerZ * this.globalToLightTransform.g + this.globalToLightTransform.h;
         var _loc13_:Number = this.centerX * this.globalToLightTransform.i + this.centerY * this.globalToLightTransform.j + this.centerZ * this.globalToLightTransform.k + this.globalToLightTransform.l;
         var _loc14_:Number = this.width / this._mapSize;
         var _loc15_:Number = this.height / this._mapSize;
         _loc11_ = Math.round(_loc11_ / _loc14_) * _loc14_;
         _loc12_ = Math.round(_loc12_ / _loc15_) * _loc15_;
         _loc5_ = _loc11_ - this.width * 0.5;
         _loc6_ = _loc11_ + this.width * 0.5;
         _loc7_ = _loc12_ - this.height * 0.5;
         _loc8_ = _loc12_ + this.height * 0.5;
         _loc9_ = _loc13_ + this.nearBoundPosition;
         _loc10_ = _loc13_ + this.farBoundPosition;
         var _loc16_:Number = (this._mapSize - 2) / this._mapSize;
         this.cameraToShadowMapContextProjection.a = 2 / (_loc6_ - _loc5_) * _loc16_;
         this.cameraToShadowMapContextProjection.b = 0;
         this.cameraToShadowMapContextProjection.c = 0;
         this.cameraToShadowMapContextProjection.e = 0;
         this.cameraToShadowMapContextProjection.f = -2 / (_loc8_ - _loc7_) * _loc16_;
         this.cameraToShadowMapContextProjection.g = 0;
         this.cameraToShadowMapContextProjection.h = 0;
         this.cameraToShadowMapContextProjection.i = 0;
         this.cameraToShadowMapContextProjection.j = 0;
         this.cameraToShadowMapContextProjection.k = 1 / (_loc10_ - _loc9_);
         this.cameraToShadowMapContextProjection.d = -0.5 * (_loc6_ + _loc5_) * this.cameraToShadowMapContextProjection.a;
         this.cameraToShadowMapContextProjection.h = -0.5 * (_loc8_ + _loc7_) * this.cameraToShadowMapContextProjection.f;
         this.cameraToShadowMapContextProjection.l = -_loc9_ / (_loc10_ - _loc9_);
         this.cameraToShadowMapUVProjection.copy(this.cameraToShadowMapContextProjection);
         this.cameraToShadowMapUVProjection.a = 1 / (_loc6_ - _loc5_) * _loc16_;
         this.cameraToShadowMapUVProjection.f = 1 / (_loc8_ - _loc7_) * _loc16_;
         this.cameraToShadowMapUVProjection.d = 0.5 - 0.5 * (_loc6_ + _loc5_) * this.cameraToShadowMapUVProjection.a;
         this.cameraToShadowMapUVProjection.h = 0.5 - 0.5 * (_loc8_ + _loc7_) * this.cameraToShadowMapUVProjection.f;
         this.cameraToShadowMapContextProjection.prepend(alternativa3d::_light.alternativa3d::cameraToLocalTransform);
         this.cameraToShadowMapUVProjection.prepend(alternativa3d::_light.alternativa3d::cameraToLocalTransform);
         _loc2_ = 0;
         while(_loc2_ < _loc4_)
         {
            _loc3_ = this.actualCasters[_loc2_];
            this.collectDraws(param1.alternativa3d::context3D,_loc3_);
            _loc2_++;
         }
         if(this.shadowMap == null)
         {
            this.shadowMap = param1.alternativa3d::context3D.createTexture(this._mapSize,this._mapSize,Context3DTextureFormat.BGRA,true);
            this.debugTexture.alternativa3d::_texture = this.shadowMap;
         }
         param1.alternativa3d::context3D.setRenderToTexture(this.shadowMap,true);
         param1.alternativa3d::context3D.clear(1,0,0,0.3);
         this.renderer.alternativa3d::camera = param1;
         this.rect.x = 1;
         this.rect.y = 1;
         this.rect.width = this._mapSize - 2;
         this.rect.height = this._mapSize - 2;
         param1.alternativa3d::context3D.setScissorRectangle(this.rect);
         this.renderer.alternativa3d::render(param1.alternativa3d::context3D);
         param1.alternativa3d::context3D.setScissorRectangle(null);
         param1.alternativa3d::context3D.setRenderToBackBuffer();
         if(debug)
         {
            if(this.debugPlane == null)
            {
               this.debugPlane = this.createDebugPlane(this.debugMaterial,param1.alternativa3d::context3D);
            }
            this.debugPlane.alternativa3d::transform.compose((_loc5_ + _loc6_) / 2,(_loc7_ + _loc8_) / 2,_loc9_,0,0,0,_loc6_ - _loc5_,_loc8_ - _loc7_,1);
            this.debugPlane.alternativa3d::localToCameraTransform.combine(alternativa3d::_light.alternativa3d::localToCameraTransform,this.debugPlane.alternativa3d::transform);
            _loc19_ = this.debugPlane.alternativa3d::_surfaces[0];
            _loc19_.material.alternativa3d::collectDraws(param1,_loc19_,this.debugPlane.geometry,this.emptyLightVector,0,false,-1);
            this.debugPlane.alternativa3d::transform.compose((_loc5_ + _loc6_) / 2,(_loc7_ + _loc8_) / 2,_loc10_,0,0,0,_loc6_ - _loc5_,_loc8_ - _loc7_,1);
            this.debugPlane.alternativa3d::localToCameraTransform.combine(alternativa3d::_light.alternativa3d::localToCameraTransform,this.debugPlane.alternativa3d::transform);
            _loc19_.material.alternativa3d::collectDraws(param1,_loc19_,this.debugPlane.geometry,this.emptyLightVector,0,false,-1);
            this.tempBounds.minX = _loc5_;
            this.tempBounds.maxX = _loc6_;
            this.tempBounds.minY = _loc7_;
            this.tempBounds.maxY = _loc8_;
            this.tempBounds.minZ = _loc9_;
            this.tempBounds.maxZ = _loc10_;
            Debug.alternativa3d::drawBoundBox(param1,this.tempBounds,alternativa3d::_light.alternativa3d::localToCameraTransform,14798119);
         }
      }
      
      private function updateParametersByVolume() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Vector3D = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Vector3D = null;
         var _loc10_:Vector3D = null;
         var _loc11_:Vector3D = null;
         var _loc12_:Vector3D = null;
         if(this.volume != null)
         {
            this.tmpPoints[0].x = this.tmpPoints[2].x = this.tmpPoints[3].x = this.volume.minX;
            this.tmpPoints[1].x = this.volume.maxX;
            this.tmpPoints[2].y = this.volume.minY;
            this.tmpPoints[0].y = this.tmpPoints[1].y = this.tmpPoints[3].y = this.volume.maxY;
            this.tmpPoints[0].z = this.tmpPoints[1].z = this.tmpPoints[2].z = this.volume.minZ;
            this.tmpPoints[3].z = this.volume.maxZ;
            _loc2_ = this.tmpPoints[0];
            _loc3_ = _loc2_.x;
            _loc4_ = _loc2_.y;
            _loc5_ = _loc2_.z;
            _loc6_ = _loc3_ * this.globalToLightTransform.a + _loc4_ * this.globalToLightTransform.b + _loc5_ * this.globalToLightTransform.c + this.globalToLightTransform.d;
            _loc7_ = _loc3_ * this.globalToLightTransform.e + _loc4_ * this.globalToLightTransform.f + _loc5_ * this.globalToLightTransform.g + this.globalToLightTransform.h;
            _loc8_ = _loc3_ * this.globalToLightTransform.i + _loc4_ * this.globalToLightTransform.j + _loc5_ * this.globalToLightTransform.k + this.globalToLightTransform.l;
            this.tempBounds.minX = _loc6_;
            this.tempBounds.maxX = _loc6_;
            this.tempBounds.minY = _loc7_;
            this.tempBounds.maxY = _loc7_;
            this.tempBounds.minZ = _loc8_;
            this.tempBounds.maxZ = _loc8_;
            _loc2_ = this.localTmpPoints[0];
            _loc2_.x = _loc6_;
            _loc2_.y = _loc7_;
            _loc2_.z = _loc8_;
            _loc1_ = 1;
            while(_loc1_ < 4)
            {
               _loc2_ = this.tmpPoints[_loc1_];
               _loc3_ = _loc2_.x;
               _loc4_ = _loc2_.y;
               _loc5_ = _loc2_.z;
               _loc6_ = _loc3_ * this.globalToLightTransform.a + _loc4_ * this.globalToLightTransform.b + _loc5_ * this.globalToLightTransform.c + this.globalToLightTransform.d;
               _loc7_ = _loc3_ * this.globalToLightTransform.e + _loc4_ * this.globalToLightTransform.f + _loc5_ * this.globalToLightTransform.g + this.globalToLightTransform.h;
               _loc8_ = _loc3_ * this.globalToLightTransform.i + _loc4_ * this.globalToLightTransform.j + _loc5_ * this.globalToLightTransform.k + this.globalToLightTransform.l;
               if(this.tempBounds.minX > _loc6_)
               {
                  this.tempBounds.minX = _loc6_;
               }
               if(this.tempBounds.maxX < _loc6_)
               {
                  this.tempBounds.maxX = _loc6_;
               }
               if(this.tempBounds.minY > _loc7_)
               {
                  this.tempBounds.minY = _loc7_;
               }
               if(this.tempBounds.maxY < _loc7_)
               {
                  this.tempBounds.maxY = _loc7_;
               }
               if(this.tempBounds.minZ > _loc8_)
               {
                  this.tempBounds.minZ = _loc8_;
               }
               if(this.tempBounds.maxZ < _loc8_)
               {
                  this.tempBounds.maxZ = _loc8_;
               }
               _loc2_ = this.localTmpPoints[_loc1_];
               _loc2_.x = _loc6_;
               _loc2_.y = _loc7_;
               _loc2_.z = _loc8_;
               _loc1_++;
            }
            _loc9_ = this.localTmpPoints[0];
            _loc10_ = this.localTmpPoints[1];
            _loc11_ = this.localTmpPoints[2];
            _loc12_ = this.localTmpPoints[3];
            _loc6_ = _loc11_.x + _loc12_.x - _loc9_.x;
            _loc7_ = _loc11_.y + _loc12_.y - _loc9_.y;
            _loc8_ = _loc11_.z + _loc12_.z - _loc9_.z;
            if(this.tempBounds.minX > _loc6_)
            {
               this.tempBounds.minX = _loc6_;
            }
            if(this.tempBounds.maxX < _loc6_)
            {
               this.tempBounds.maxX = _loc6_;
            }
            if(this.tempBounds.minY > _loc7_)
            {
               this.tempBounds.minY = _loc7_;
            }
            if(this.tempBounds.maxY < _loc7_)
            {
               this.tempBounds.maxY = _loc7_;
            }
            if(this.tempBounds.minZ > _loc8_)
            {
               this.tempBounds.minZ = _loc8_;
            }
            if(this.tempBounds.maxZ < _loc8_)
            {
               this.tempBounds.maxZ = _loc8_;
            }
            _loc6_ = _loc12_.x + _loc10_.x - _loc9_.x;
            _loc7_ = _loc12_.y + _loc10_.y - _loc9_.y;
            _loc8_ = _loc12_.z + _loc10_.z - _loc9_.z;
            if(this.tempBounds.minX > _loc6_)
            {
               this.tempBounds.minX = _loc6_;
            }
            if(this.tempBounds.maxX < _loc6_)
            {
               this.tempBounds.maxX = _loc6_;
            }
            if(this.tempBounds.minY > _loc7_)
            {
               this.tempBounds.minY = _loc7_;
            }
            if(this.tempBounds.maxY < _loc7_)
            {
               this.tempBounds.maxY = _loc7_;
            }
            if(this.tempBounds.minZ > _loc8_)
            {
               this.tempBounds.minZ = _loc8_;
            }
            if(this.tempBounds.maxZ < _loc8_)
            {
               this.tempBounds.maxZ = _loc8_;
            }
            _loc6_ = _loc11_.x + _loc10_.x - _loc9_.x;
            _loc7_ = _loc11_.y + _loc10_.y - _loc9_.y;
            _loc8_ = _loc11_.z + _loc10_.z - _loc9_.z;
            if(this.tempBounds.minX > _loc6_)
            {
               this.tempBounds.minX = _loc6_;
            }
            if(this.tempBounds.maxX < _loc6_)
            {
               this.tempBounds.maxX = _loc6_;
            }
            if(this.tempBounds.minY > _loc7_)
            {
               this.tempBounds.minY = _loc7_;
            }
            if(this.tempBounds.maxY < _loc7_)
            {
               this.tempBounds.maxY = _loc7_;
            }
            if(this.tempBounds.minZ > _loc8_)
            {
               this.tempBounds.minZ = _loc8_;
            }
            if(this.tempBounds.maxZ < _loc8_)
            {
               this.tempBounds.maxZ = _loc8_;
            }
            _loc6_ = _loc6_ + _loc12_.x - _loc9_.x;
            _loc7_ = _loc7_ + _loc12_.y - _loc9_.y;
            _loc8_ = _loc8_ + _loc12_.z - _loc9_.z;
            if(this.tempBounds.minX > _loc6_)
            {
               this.tempBounds.minX = _loc6_;
            }
            if(this.tempBounds.maxX < _loc6_)
            {
               this.tempBounds.maxX = _loc6_;
            }
            if(this.tempBounds.minY > _loc7_)
            {
               this.tempBounds.minY = _loc7_;
            }
            if(this.tempBounds.maxY < _loc7_)
            {
               this.tempBounds.maxY = _loc7_;
            }
            if(this.tempBounds.minZ > _loc8_)
            {
               this.tempBounds.minZ = _loc8_;
            }
            if(this.tempBounds.maxZ < _loc8_)
            {
               this.tempBounds.maxZ = _loc8_;
            }
            this.width = this.tempBounds.maxX - this.tempBounds.minX;
            this.height = this.tempBounds.maxY - this.tempBounds.minY;
            this.nearBoundPosition = (this.tempBounds.minZ - this.tempBounds.maxZ) / 2;
            this.farBoundPosition = -this.nearBoundPosition;
            this.centerX = (this.volume.minX + this.volume.maxX) / 2;
            this.centerY = (this.volume.minY + this.volume.maxY) / 2;
            this.centerZ = (this.volume.minZ + this.volume.maxZ) / 2;
         }
      }
      
      private function getProgram(param1:Procedure, param2:Vector.<ShaderProgram>, param3:Context3D, param4:Boolean, param5:Boolean) : ShaderProgram
      {
         var _loc8_:Linker = null;
         var _loc9_:Linker = null;
         var _loc10_:String = null;
         var _loc11_:Procedure = null;
         var _loc12_:String = null;
         var _loc6_:int = param4 ? (param5 ? 1 : 2) : 0;
         var _loc7_:ShaderProgram = param2[_loc6_];
         if(_loc7_ == null)
         {
            _loc8_ = new Linker(Context3DProgramType.VERTEX);
            _loc9_ = new Linker(Context3DProgramType.FRAGMENT);
            _loc10_ = "aPosition";
            _loc8_.declareVariable(_loc10_,VariableType.ATTRIBUTE);
            if(param4)
            {
               _loc8_.addProcedure(passUVProcedure);
            }
            if(param1 != null)
            {
               _loc12_ = "tTransformedPosition";
               _loc8_.declareVariable(_loc12_);
               _loc8_.addProcedure(param1,_loc10_);
               _loc8_.setOutputParams(param1,_loc12_);
               _loc10_ = _loc12_;
            }
            _loc11_ = Procedure.compileFromArray(["#c3=cScale","#v0=vDistance","m34 t0.xyz, i0, c0","mov t0.w, c3.w","mul v0, t0, c3.x","mov o0, t0"]);
            _loc11_.assignVariableName(VariableType.CONSTANT,0,"cTransform",3);
            _loc8_.addProcedure(_loc11_,_loc10_);
            if(param4)
            {
               if(param5)
               {
                  _loc9_.addProcedure(diffuseAlphaTestProcedure);
               }
               else
               {
                  _loc9_.addProcedure(opacityAlphaTestProcedure);
               }
            }
            _loc9_.addProcedure(Procedure.compileFromArray(["#v0=vDistance","#c0=cConstants","frc t0.y, v0.z","sub t0.x, v0.z, t0.y","mul t0.x, t0.x, c0.x","mov t0.z, c0.z","mov t0.w, c0.w","mov o0, t0"]));
            _loc7_ = new ShaderProgram(_loc8_,_loc9_);
            _loc9_.varyings = _loc8_.varyings;
            param2[_loc6_] = _loc7_;
            _loc7_.upload(param3);
         }
         return _loc7_;
      }
      
      private function collectDraws(param1:Context3D, param2:Object3D) : void
      {
         var _loc3_:Object3D = null;
         var _loc5_:ShaderProgram = null;
         var _loc6_:Vector.<ShaderProgram> = null;
         var _loc7_:Skin = null;
         var _loc8_:int = 0;
         var _loc9_:Surface = null;
         var _loc10_:Material = null;
         var _loc11_:Geometry = null;
         var _loc12_:* = false;
         var _loc13_:* = false;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:TextureResource = null;
         var _loc17_:TextureResource = null;
         var _loc18_:VertexBuffer3D = null;
         var _loc19_:VertexBuffer3D = null;
         var _loc20_:DrawUnit = null;
         var _loc4_:Mesh = param2 as Mesh;
         if(_loc4_ != null && _loc4_.geometry != null)
         {
            _loc7_ = _loc4_ as Skin;
            if(_loc7_ != null)
            {
               _loc3_ = _loc7_.alternativa3d::childrenList;
               while(_loc3_ != null)
               {
                  if(_loc3_.alternativa3d::transformChanged)
                  {
                     _loc3_.alternativa3d::composeTransforms();
                  }
                  _loc3_.alternativa3d::localToGlobalTransform.copy(_loc3_.alternativa3d::transform);
                  if(_loc3_ is Joint)
                  {
                     Joint(_loc3_).alternativa3d::calculateTransform();
                  }
                  _loc7_.alternativa3d::calculateJointsTransforms(_loc3_);
                  _loc3_ = _loc3_.alternativa3d::next;
               }
            }
            this.objectToShadowMapTransform.combine(this.cameraToShadowMapContextProjection,param2.alternativa3d::localToCameraTransform);
            _loc8_ = 0;
            for(; _loc8_ < _loc4_.alternativa3d::_surfacesLength; _loc8_++)
            {
               _loc9_ = _loc4_.alternativa3d::_surfaces[_loc8_];
               if(_loc9_.material != null)
               {
                  _loc10_ = _loc9_.material;
                  _loc11_ = _loc4_.geometry;
                  if(_loc10_ is TextureMaterial)
                  {
                     _loc14_ = TextureMaterial(_loc10_).alphaThreshold;
                     _loc15_ = TextureMaterial(_loc10_).alpha;
                     _loc16_ = TextureMaterial(_loc10_).diffuseMap;
                     _loc17_ = TextureMaterial(_loc10_).opacityMap;
                     _loc12_ = _loc14_ > 0;
                     _loc13_ = TextureMaterial(_loc10_).opacityMap == null;
                     _loc18_ = _loc11_.alternativa3d::getVertexBuffer(VertexAttributes.TEXCOORDS[0]);
                     if(_loc18_ == null)
                     {
                        continue;
                     }
                  }
                  else
                  {
                     _loc12_ = false;
                     _loc13_ = false;
                  }
                  _loc19_ = _loc4_.geometry.alternativa3d::getVertexBuffer(VertexAttributes.POSITION);
                  if(_loc19_ != null)
                  {
                     if(_loc7_ != null)
                     {
                        param2.alternativa3d::transformProcedure = _loc7_.alternativa3d::surfaceTransformProcedures[_loc8_];
                     }
                     _loc6_ = this.programs[param2.alternativa3d::transformProcedure];
                     if(_loc6_ == null)
                     {
                        _loc6_ = new Vector.<ShaderProgram>(3,true);
                        this.programs[param2.alternativa3d::transformProcedure] = _loc6_;
                     }
                     _loc5_ = this.getProgram(param2.alternativa3d::transformProcedure,_loc6_,param1,_loc12_,_loc13_);
                     _loc20_ = this.renderer.alternativa3d::createDrawUnit(param2,_loc5_.program,_loc4_.geometry.alternativa3d::_indexBuffer,_loc9_.indexBegin,_loc9_.numTriangles,_loc5_);
                     param2.alternativa3d::setTransformConstants(_loc20_,_loc9_,_loc5_.vertexShader,null);
                     _loc20_.alternativa3d::setVertexBufferAt(_loc5_.vertexShader.getVariableIndex("aPosition"),_loc19_,_loc4_.geometry.alternativa3d::_attributesOffsets[VertexAttributes.POSITION],VertexAttributes.alternativa3d::FORMATS[VertexAttributes.POSITION]);
                     if(_loc12_)
                     {
                        _loc20_.alternativa3d::setVertexBufferAt(_loc5_.vertexShader.getVariableIndex("aUV"),_loc18_,_loc11_.alternativa3d::_attributesOffsets[VertexAttributes.TEXCOORDS[0]],VertexAttributes.alternativa3d::FORMATS[VertexAttributes.TEXCOORDS[0]]);
                        _loc20_.alternativa3d::setFragmentConstantsFromNumbers(_loc5_.fragmentShader.getVariableIndex("cThresholdAlpha"),_loc14_,0,0,_loc15_);
                        if(_loc13_)
                        {
                           _loc20_.alternativa3d::setTextureAt(_loc5_.fragmentShader.getVariableIndex("sTexture"),_loc16_.alternativa3d::_texture);
                        }
                        else
                        {
                           _loc20_.alternativa3d::setTextureAt(_loc5_.fragmentShader.getVariableIndex("sTexture"),_loc17_.alternativa3d::_texture);
                        }
                     }
                     _loc20_.alternativa3d::setVertexConstantsFromTransform(_loc5_.vertexShader.getVariableIndex("cTransform"),this.objectToShadowMapTransform);
                     _loc20_.alternativa3d::setVertexConstantsFromNumbers(_loc5_.vertexShader.getVariableIndex("cScale"),255,0,0,1);
                     _loc20_.alternativa3d::setFragmentConstantsFromNumbers(_loc5_.fragmentShader.getVariableIndex("cConstants"),1 / 255,0,0,1);
                     this.renderer.alternativa3d::addDrawUnit(_loc20_,Renderer.OPAQUE);
                  }
               }
            }
         }
         _loc3_ = param2.alternativa3d::childrenList;
         while(_loc3_ != null)
         {
            if(_loc3_.visible)
            {
               this.collectDraws(param1,_loc3_);
            }
            _loc3_ = _loc3_.alternativa3d::next;
         }
      }
      
      override alternativa3d function setup(param1:DrawUnit, param2:Linker, param3:Linker, param4:Surface) : void
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         this.objectToShadowMapTransform.combine(this.cameraToShadowMapUVProjection,param4.alternativa3d::object.alternativa3d::localToCameraTransform);
         param1.alternativa3d::setVertexConstantsFromTransform(param2.getVariableIndex("cUVProjection"),this.objectToShadowMapTransform);
         param1.alternativa3d::setTextureAt(param3.getVariableIndex("sShadowMap"),this.shadowMap);
         param1.alternativa3d::setFragmentConstantsFromNumbers(param3.getVariableIndex("cConstants"),-255 * DIFFERENCE_MULTIPLIER,-DIFFERENCE_MULTIPLIER,this.biasMultiplier * 255 * DIFFERENCE_MULTIPLIER,1 / 16);
         if(this._pcfOffset > 0)
         {
            _loc5_ = this._pcfOffset / this._mapSize;
            _loc6_ = _loc5_ / 3;
            param1.alternativa3d::setFragmentConstantsFromNumbers(param3.getVariableIndex("cPCFOffsets"),-_loc5_,-_loc6_,_loc6_,_loc5_);
         }
         param1.alternativa3d::setFragmentConstantsFromNumbers(param3.getVariableIndex("cDist"),0.9999,DIFFERENCE_MULTIPLIER,1);
      }
      
      public function addCaster(param1:Object3D) : void
      {
         if(this._casters.indexOf(param1) < 0)
         {
            this._casters.push(param1);
         }
      }
      
      public function removeCaster(param1:Object3D) : void
      {
         var _loc2_:int = int(this._casters.indexOf(param1));
         if(_loc2_ < 0)
         {
            throw new Error("Caster not found");
         }
         this._casters[_loc2_] = this._casters.pop();
      }
      
      public function clearCasters() : void
      {
         this._casters.length = 0;
      }
      
      public function get mapSize() : int
      {
         return this._mapSize;
      }
      
      public function set mapSize(param1:int) : void
      {
         if(param1 != this._mapSize)
         {
            this._mapSize = param1;
            if(param1 < 2)
            {
               throw new ArgumentError("Map size cannot be less than 2.");
            }
            if(param1 > 2048)
            {
               throw new ArgumentError("Map size exceeds maximum value 2048.");
            }
            if(Math.log(param1) / Math.LN2 % 1 != 0)
            {
               throw new ArgumentError("Map size must be power of two.");
            }
            if(this.shadowMap != null)
            {
               this.shadowMap.dispose();
            }
            this.shadowMap = null;
         }
      }
      
      public function get pcfOffset() : Number
      {
         return this._pcfOffset;
      }
      
      public function set pcfOffset(param1:Number) : void
      {
         this._pcfOffset = param1;
         alternativa3d::type = this._pcfOffset > 0 ? Shadow.alternativa3d::PCF_MODE : Shadow.alternativa3d::SIMPLE_MODE;
         alternativa3d::fragmentShadowProcedure = this._pcfOffset > 0 ? getFShaderPCF() : getFShader();
      }
   }
}

