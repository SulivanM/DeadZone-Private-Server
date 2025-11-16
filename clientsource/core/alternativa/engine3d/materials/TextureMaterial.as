package alternativa.engine3d.materials
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.Camera3D;
   import alternativa.engine3d.core.DrawUnit;
   import alternativa.engine3d.core.Light3D;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Renderer;
   import alternativa.engine3d.core.VertexAttributes;
   import alternativa.engine3d.materials.compiler.Linker;
   import alternativa.engine3d.materials.compiler.Procedure;
   import alternativa.engine3d.materials.compiler.VariableType;
   import alternativa.engine3d.objects.Surface;
   import alternativa.engine3d.resources.Geometry;
   import alternativa.engine3d.resources.TextureResource;
   import avmplus.getQualifiedClassName;
   import flash.display3D.Context3D;
   import flash.display3D.Context3DBlendFactor;
   import flash.display3D.Context3DProgramType;
   import flash.display3D.VertexBuffer3D;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   
   use namespace alternativa3d;
   
   public class TextureMaterial extends Material
   {
      
      private static var caches:Dictionary = new Dictionary(true);
      
      alternativa3d static const getDiffuseProcedure:Procedure = new Procedure(["#v0=vUV","#s0=sDiffuse","#c0=cThresholdAlpha","tex t0, v0, s0 <2d, linear,repeat, miplinear>","mul t0.w, t0.w, c0.w","mov o0, t0"],"getDiffuseProcedure");
      
      alternativa3d static const getDiffuseOpacityProcedure:Procedure = new Procedure(["#v0=vUV","#s0=sDiffuse","#s1=sOpacity","#c0=cThresholdAlpha","tex t0, v0, s0 <2d, linear,repeat, miplinear>","tex t1, v0, s1 <2d, linear,repeat, miplinear>","mul t0.w, t1.x, c0.w","mov o0, t0"],"getDiffuseOpacityProcedure");
      
      alternativa3d static const thresholdOpaqueAlphaProcedure:Procedure = new Procedure(["#c0=cThresholdAlpha","sub t0.w, i0.w, c0.x","kil t0.w","mov o0, i0"],"thresholdOpaqueAlphaProcedure");
      
      alternativa3d static const thresholdTransparentAlphaProcedure:Procedure = new Procedure(["#c0=cThresholdAlpha","slt t0.w, i0.w, c0.x","mul i0.w, t0.w, i0.w","mov o0, i0"],"thresholdTransparentAlphaProcedure");
      
      alternativa3d static const _passUVProcedure:Procedure = new Procedure(["#v0=vUV","#a0=aUV","mov v0, a0"],"passUVProcedure");
      
      private var cachedContext3D:Context3D;
      
      private var programsCache:Dictionary;
      
      public var diffuseMap:TextureResource;
      
      public var opacityMap:TextureResource;
      
      public var transparentPass:Boolean = true;
      
      public var opaquePass:Boolean = true;
      
      public var alphaThreshold:Number = 0;
      
      public var alpha:Number = 1;
      
      public function TextureMaterial(param1:TextureResource = null, param2:TextureResource = null, param3:Number = 1)
      {
         super();
         this.diffuseMap = param1;
         this.opacityMap = param2;
         this.alpha = param3;
      }
      
      override alternativa3d function fillResources(param1:Dictionary, param2:Class) : void
      {
         super.alternativa3d::fillResources(param1,param2);
         if(this.diffuseMap != null && A3DUtils.alternativa3d::checkParent(getDefinitionByName(getQualifiedClassName(this.diffuseMap)) as Class,param2))
         {
            param1[this.diffuseMap] = true;
         }
         if(this.opacityMap != null && A3DUtils.alternativa3d::checkParent(getDefinitionByName(getQualifiedClassName(this.opacityMap)) as Class,param2))
         {
            param1[this.opacityMap] = true;
         }
      }
      
      private function getProgram(param1:Object3D, param2:Vector.<TextureMaterialProgram>, param3:Camera3D, param4:TextureResource, param5:int) : TextureMaterialProgram
      {
         var _loc8_:Linker = null;
         var _loc9_:String = null;
         var _loc10_:Linker = null;
         var _loc11_:Procedure = null;
         var _loc6_:int = (param4 != null ? 3 : 0) + param5;
         var _loc7_:TextureMaterialProgram = param2[_loc6_];
         if(_loc7_ == null)
         {
            _loc8_ = new Linker(Context3DProgramType.VERTEX);
            _loc9_ = "aPosition";
            _loc8_.declareVariable(_loc9_,VariableType.ATTRIBUTE);
            if(param1.alternativa3d::transformProcedure != null)
            {
               _loc9_ = alternativa3d::appendPositionTransformProcedure(param1.alternativa3d::transformProcedure,_loc8_);
            }
            _loc8_.addProcedure(alternativa3d::_projectProcedure);
            _loc8_.setInputParams(alternativa3d::_projectProcedure,_loc9_);
            _loc8_.addProcedure(alternativa3d::_passUVProcedure);
            _loc10_ = new Linker(Context3DProgramType.FRAGMENT);
            _loc11_ = param4 != null ? alternativa3d::getDiffuseOpacityProcedure : alternativa3d::getDiffuseProcedure;
            _loc10_.addProcedure(_loc11_);
            if(param5 > 0)
            {
               _loc10_.declareVariable("tColor");
               _loc10_.setOutputParams(_loc11_,"tColor");
               if(param5 == 1)
               {
                  _loc10_.addProcedure(alternativa3d::thresholdOpaqueAlphaProcedure,"tColor");
               }
               else
               {
                  _loc10_.addProcedure(alternativa3d::thresholdTransparentAlphaProcedure,"tColor");
               }
            }
            _loc10_.varyings = _loc8_.varyings;
            _loc7_ = new TextureMaterialProgram(_loc8_,_loc10_);
            _loc7_.upload(param3.alternativa3d::context3D);
            param2[_loc6_] = _loc7_;
         }
         return _loc7_;
      }
      
      private function getDrawUnit(param1:TextureMaterialProgram, param2:Camera3D, param3:Surface, param4:Geometry, param5:TextureResource) : DrawUnit
      {
         var _loc6_:VertexBuffer3D = param4.alternativa3d::getVertexBuffer(VertexAttributes.POSITION);
         var _loc7_:VertexBuffer3D = param4.alternativa3d::getVertexBuffer(VertexAttributes.TEXCOORDS[0]);
         var _loc8_:Object3D = param3.alternativa3d::object;
         var _loc9_:DrawUnit = param2.renderer.alternativa3d::createDrawUnit(_loc8_,param1.program,param4.alternativa3d::_indexBuffer,param3.indexBegin,param3.numTriangles,param1);
         _loc9_.alternativa3d::setVertexBufferAt(param1.aPosition,_loc6_,param4.alternativa3d::_attributesOffsets[VertexAttributes.POSITION],VertexAttributes.alternativa3d::FORMATS[VertexAttributes.POSITION]);
         _loc9_.alternativa3d::setVertexBufferAt(param1.aUV,_loc7_,param4.alternativa3d::_attributesOffsets[VertexAttributes.TEXCOORDS[0]],VertexAttributes.alternativa3d::FORMATS[VertexAttributes.TEXCOORDS[0]]);
         _loc8_.alternativa3d::setTransformConstants(_loc9_,param3,param1.vertexShader,param2);
         _loc9_.alternativa3d::setProjectionConstants(param2,param1.cProjMatrix,_loc8_.alternativa3d::localToCameraTransform);
         _loc9_.alternativa3d::setFragmentConstantsFromNumbers(param1.cThresholdAlpha,this.alphaThreshold,0,0,this.alpha);
         _loc9_.alternativa3d::setTextureAt(param1.sDiffuse,this.diffuseMap.alternativa3d::_texture);
         if(param5 != null)
         {
            _loc9_.alternativa3d::setTextureAt(param1.sOpacity,param5.alternativa3d::_texture);
         }
         return _loc9_;
      }
      
      override alternativa3d function collectDraws(param1:Camera3D, param2:Surface, param3:Geometry, param4:Vector.<Light3D>, param5:int, param6:Boolean, param7:int = -1) : void
      {
         var _loc12_:TextureMaterialProgram = null;
         var _loc13_:DrawUnit = null;
         var _loc8_:Object3D = param2.alternativa3d::object;
         var _loc9_:VertexBuffer3D = param3.alternativa3d::getVertexBuffer(VertexAttributes.POSITION);
         var _loc10_:VertexBuffer3D = param3.alternativa3d::getVertexBuffer(VertexAttributes.TEXCOORDS[0]);
         if(_loc9_ == null || _loc10_ == null || this.diffuseMap == null || this.diffuseMap.alternativa3d::_texture == null || this.opacityMap != null && this.opacityMap.alternativa3d::_texture == null)
         {
            return;
         }
         if(param1.alternativa3d::context3D != this.cachedContext3D)
         {
            this.cachedContext3D = param1.alternativa3d::context3D;
            this.programsCache = caches[this.cachedContext3D];
            if(this.programsCache == null)
            {
               this.programsCache = new Dictionary();
               caches[this.cachedContext3D] = this.programsCache;
            }
         }
         var _loc11_:Vector.<TextureMaterialProgram> = this.programsCache[_loc8_.alternativa3d::transformProcedure];
         if(_loc11_ == null)
         {
            _loc11_ = new Vector.<TextureMaterialProgram>(6,true);
            this.programsCache[_loc8_.alternativa3d::transformProcedure] = _loc11_;
         }
         if(this.opaquePass && this.alphaThreshold <= this.alpha)
         {
            if(this.alphaThreshold > 0)
            {
               _loc12_ = this.getProgram(_loc8_,_loc11_,param1,this.opacityMap,1);
               _loc13_ = this.getDrawUnit(_loc12_,param1,param2,param3,this.opacityMap);
            }
            else
            {
               _loc12_ = this.getProgram(_loc8_,_loc11_,param1,null,0);
               _loc13_ = this.getDrawUnit(_loc12_,param1,param2,param3,null);
            }
            param1.renderer.alternativa3d::addDrawUnit(_loc13_,param7 >= 0 ? param7 : Renderer.OPAQUE);
         }
         if(this.transparentPass && this.alphaThreshold > 0 && this.alpha > 0)
         {
            if(this.alphaThreshold <= this.alpha && !this.opaquePass)
            {
               _loc12_ = this.getProgram(_loc8_,_loc11_,param1,this.opacityMap,2);
               _loc13_ = this.getDrawUnit(_loc12_,param1,param2,param3,this.opacityMap);
            }
            else
            {
               _loc12_ = this.getProgram(_loc8_,_loc11_,param1,this.opacityMap,0);
               _loc13_ = this.getDrawUnit(_loc12_,param1,param2,param3,this.opacityMap);
            }
            _loc13_.alternativa3d::blendSource = Context3DBlendFactor.SOURCE_ALPHA;
            _loc13_.alternativa3d::blendDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
            param1.renderer.alternativa3d::addDrawUnit(_loc13_,param7 >= 0 ? param7 : Renderer.TRANSPARENT_SORT);
         }
      }
      
      override public function clone() : Material
      {
         var _loc1_:TextureMaterial = new TextureMaterial(this.diffuseMap,this.opacityMap,this.alpha);
         _loc1_.clonePropertiesFrom(this);
         return _loc1_;
      }
      
      override protected function clonePropertiesFrom(param1:Material) : void
      {
         super.clonePropertiesFrom(param1);
         var _loc2_:TextureMaterial = param1 as TextureMaterial;
         this.diffuseMap = _loc2_.diffuseMap;
         this.opacityMap = _loc2_.opacityMap;
         this.opaquePass = _loc2_.opaquePass;
         this.transparentPass = _loc2_.transparentPass;
         this.alphaThreshold = _loc2_.alphaThreshold;
         this.alpha = _loc2_.alpha;
      }
   }
}

import alternativa.engine3d.materials.compiler.Linker;
import flash.display3D.Context3D;

class TextureMaterialProgram extends ShaderProgram
{
   
   public var aPosition:int = -1;
   
   public var aUV:int = -1;
   
   public var cProjMatrix:int = -1;
   
   public var cThresholdAlpha:int = -1;
   
   public var sDiffuse:int = -1;
   
   public var sOpacity:int = -1;
   
   public function TextureMaterialProgram(param1:Linker, param2:Linker)
   {
      super(param1,param2);
   }
   
   override public function upload(param1:Context3D) : void
   {
      super.upload(param1);
      this.aPosition = vertexShader.findVariable("aPosition");
      this.aUV = vertexShader.findVariable("aUV");
      this.cProjMatrix = vertexShader.findVariable("cProjMatrix");
      this.cThresholdAlpha = fragmentShader.findVariable("cThresholdAlpha");
      this.sDiffuse = fragmentShader.findVariable("sDiffuse");
      this.sOpacity = fragmentShader.findVariable("sOpacity");
   }
}
