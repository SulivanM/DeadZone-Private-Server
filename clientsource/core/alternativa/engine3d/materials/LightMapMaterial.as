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
   
   public class LightMapMaterial extends TextureMaterial
   {
      
      private static var caches:Dictionary = new Dictionary(true);
      
      private static const _applyLightMapProcedure:Procedure = new Procedure(["#v0=vUV1","#s0=sLightMap","tex t0, v0, s0 <2d,repeat,linear,miplinear>","add t0, t0, t0","mul i0.xyz, i0.xyz, t0.xyz","mov o0, i0"],"applyLightMapProcedure");
      
      private static const _passLightMapUVProcedure:Procedure = new Procedure(["#a0=aUV1","#v0=vUV1","mov v0, a0"],"passLightMapUVProcedure");
      
      private var cachedContext3D:Context3D;
      
      private var programsCache:Dictionary;
      
      public var lightMap:TextureResource;
      
      public var lightMapChannel:uint = 0;
      
      public function LightMapMaterial(param1:TextureResource = null, param2:TextureResource = null, param3:uint = 0, param4:TextureResource = null)
      {
         super(param1,param4);
         this.lightMap = param2;
         this.lightMapChannel = param3;
      }
      
      override public function clone() : Material
      {
         var _loc1_:LightMapMaterial = new LightMapMaterial(diffuseMap,this.lightMap,this.lightMapChannel,opacityMap);
         _loc1_.clonePropertiesFrom(this);
         return _loc1_;
      }
      
      override alternativa3d function fillResources(param1:Dictionary, param2:Class) : void
      {
         super.alternativa3d::fillResources(param1,param2);
         if(this.lightMap != null && A3DUtils.alternativa3d::checkParent(getDefinitionByName(getQualifiedClassName(this.lightMap)) as Class,param2))
         {
            param1[this.lightMap] = true;
         }
      }
      
      private function getProgram(param1:Object3D, param2:Vector.<LightMapMaterialProgram>, param3:Camera3D, param4:TextureResource, param5:int) : LightMapMaterialProgram
      {
         var _loc8_:Linker = null;
         var _loc9_:String = null;
         var _loc10_:Linker = null;
         var _loc11_:Procedure = null;
         var _loc6_:int = (param4 != null ? 3 : 0) + param5;
         var _loc7_:LightMapMaterialProgram = param2[_loc6_];
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
            _loc8_.addProcedure(_passLightMapUVProcedure);
            _loc10_ = new Linker(Context3DProgramType.FRAGMENT);
            _loc10_.declareVariable("tColor");
            _loc11_ = param4 != null ? alternativa3d::getDiffuseOpacityProcedure : alternativa3d::getDiffuseProcedure;
            _loc10_.addProcedure(_loc11_);
            _loc10_.setOutputParams(_loc11_,"tColor");
            if(param5 > 0)
            {
               _loc11_ = param5 == 1 ? alternativa3d::thresholdOpaqueAlphaProcedure : alternativa3d::thresholdTransparentAlphaProcedure;
               _loc10_.addProcedure(_loc11_,"tColor");
               _loc10_.setOutputParams(_loc11_,"tColor");
            }
            _loc10_.addProcedure(_applyLightMapProcedure,"tColor");
            _loc10_.varyings = _loc8_.varyings;
            _loc7_ = new LightMapMaterialProgram(_loc8_,_loc10_);
            _loc7_.upload(param3.alternativa3d::context3D);
            param2[_loc6_] = _loc7_;
         }
         return _loc7_;
      }
      
      private function getDrawUnit(param1:LightMapMaterialProgram, param2:Camera3D, param3:Surface, param4:Geometry, param5:TextureResource) : DrawUnit
      {
         var _loc6_:VertexBuffer3D = param4.alternativa3d::getVertexBuffer(VertexAttributes.POSITION);
         var _loc7_:VertexBuffer3D = param4.alternativa3d::getVertexBuffer(VertexAttributes.TEXCOORDS[0]);
         var _loc8_:VertexBuffer3D = param4.alternativa3d::getVertexBuffer(VertexAttributes.TEXCOORDS[this.lightMapChannel]);
         var _loc9_:Object3D = param3.alternativa3d::object;
         var _loc10_:DrawUnit = param2.renderer.alternativa3d::createDrawUnit(_loc9_,param1.program,param4.alternativa3d::_indexBuffer,param3.indexBegin,param3.numTriangles,param1);
         _loc10_.alternativa3d::setVertexBufferAt(param1.aPosition,_loc6_,param4.alternativa3d::_attributesOffsets[VertexAttributes.POSITION],VertexAttributes.alternativa3d::FORMATS[VertexAttributes.POSITION]);
         _loc10_.alternativa3d::setVertexBufferAt(param1.aUV,_loc7_,param4.alternativa3d::_attributesOffsets[VertexAttributes.TEXCOORDS[0]],VertexAttributes.alternativa3d::FORMATS[VertexAttributes.TEXCOORDS[0]]);
         _loc10_.alternativa3d::setVertexBufferAt(param1.aUV1,_loc8_,param4.alternativa3d::_attributesOffsets[VertexAttributes.TEXCOORDS[this.lightMapChannel]],VertexAttributes.alternativa3d::FORMATS[VertexAttributes.TEXCOORDS[this.lightMapChannel]]);
         _loc9_.alternativa3d::setTransformConstants(_loc10_,param3,param1.vertexShader,param2);
         _loc10_.alternativa3d::setProjectionConstants(param2,param1.cProjMatrix,_loc9_.alternativa3d::localToCameraTransform);
         _loc10_.alternativa3d::setFragmentConstantsFromNumbers(param1.cThresholdAlpha,alphaThreshold,0,0,alpha);
         _loc10_.alternativa3d::setTextureAt(param1.sDiffuse,diffuseMap.alternativa3d::_texture);
         _loc10_.alternativa3d::setTextureAt(param1.sLightMap,this.lightMap.alternativa3d::_texture);
         if(param5 != null)
         {
            _loc10_.alternativa3d::setTextureAt(param1.sOpacity,param5.alternativa3d::_texture);
         }
         return _loc10_;
      }
      
      override alternativa3d function collectDraws(param1:Camera3D, param2:Surface, param3:Geometry, param4:Vector.<Light3D>, param5:int, param6:Boolean, param7:int = -1) : void
      {
         var _loc13_:LightMapMaterialProgram = null;
         var _loc14_:DrawUnit = null;
         if(diffuseMap == null || this.lightMap == null || diffuseMap.alternativa3d::_texture == null || this.lightMap.alternativa3d::_texture == null)
         {
            return;
         }
         if(opacityMap != null && opacityMap.alternativa3d::_texture == null)
         {
            return;
         }
         var _loc8_:Object3D = param2.alternativa3d::object;
         var _loc9_:VertexBuffer3D = param3.alternativa3d::getVertexBuffer(VertexAttributes.POSITION);
         var _loc10_:VertexBuffer3D = param3.alternativa3d::getVertexBuffer(VertexAttributes.TEXCOORDS[0]);
         var _loc11_:VertexBuffer3D = param3.alternativa3d::getVertexBuffer(VertexAttributes.TEXCOORDS[this.lightMapChannel]);
         if(_loc9_ == null || _loc10_ == null || _loc11_ == null)
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
         var _loc12_:Vector.<LightMapMaterialProgram> = this.programsCache[_loc8_.alternativa3d::transformProcedure];
         if(_loc12_ == null)
         {
            _loc12_ = new Vector.<LightMapMaterialProgram>(6,true);
            this.programsCache[_loc8_.alternativa3d::transformProcedure] = _loc12_;
         }
         if(opaquePass && alphaThreshold <= alpha)
         {
            if(alphaThreshold > 0)
            {
               _loc13_ = this.getProgram(_loc8_,_loc12_,param1,opacityMap,1);
               _loc14_ = this.getDrawUnit(_loc13_,param1,param2,param3,opacityMap);
            }
            else
            {
               _loc13_ = this.getProgram(_loc8_,_loc12_,param1,null,0);
               _loc14_ = this.getDrawUnit(_loc13_,param1,param2,param3,null);
            }
            param1.renderer.alternativa3d::addDrawUnit(_loc14_,param7 >= 0 ? param7 : Renderer.OPAQUE);
         }
         if(transparentPass && alphaThreshold > 0 && alpha > 0)
         {
            if(alphaThreshold <= alpha && !opaquePass)
            {
               _loc13_ = this.getProgram(_loc8_,_loc12_,param1,opacityMap,2);
               _loc14_ = this.getDrawUnit(_loc13_,param1,param2,param3,opacityMap);
            }
            else
            {
               _loc13_ = this.getProgram(_loc8_,_loc12_,param1,opacityMap,0);
               _loc14_ = this.getDrawUnit(_loc13_,param1,param2,param3,opacityMap);
            }
            _loc14_.alternativa3d::blendSource = Context3DBlendFactor.SOURCE_ALPHA;
            _loc14_.alternativa3d::blendDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
            param1.renderer.alternativa3d::addDrawUnit(_loc14_,param7 >= 0 ? param7 : Renderer.TRANSPARENT_SORT);
         }
      }
   }
}

import alternativa.engine3d.materials.compiler.Linker;
import flash.display3D.Context3D;

class LightMapMaterialProgram extends ShaderProgram
{
   
   public var aPosition:int = -1;
   
   public var aUV:int = -1;
   
   public var aUV1:int = -1;
   
   public var cProjMatrix:int = -1;
   
   public var cThresholdAlpha:int = -1;
   
   public var sDiffuse:int = -1;
   
   public var sLightMap:int = -1;
   
   public var sOpacity:int = -1;
   
   public function LightMapMaterialProgram(param1:Linker, param2:Linker)
   {
      super(param1,param2);
   }
   
   override public function upload(param1:Context3D) : void
   {
      super.upload(param1);
      this.aPosition = vertexShader.findVariable("aPosition");
      this.aUV = vertexShader.findVariable("aUV");
      this.aUV1 = vertexShader.findVariable("aUV1");
      this.cProjMatrix = vertexShader.findVariable("cProjMatrix");
      this.cThresholdAlpha = fragmentShader.findVariable("cThresholdAlpha");
      this.sDiffuse = fragmentShader.findVariable("sDiffuse");
      this.sLightMap = fragmentShader.findVariable("sLightMap");
      this.sOpacity = fragmentShader.findVariable("sOpacity");
   }
}
