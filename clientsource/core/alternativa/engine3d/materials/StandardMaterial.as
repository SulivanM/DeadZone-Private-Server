package alternativa.engine3d.materials
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.Camera3D;
   import alternativa.engine3d.core.DrawUnit;
   import alternativa.engine3d.core.Light3D;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Renderer;
   import alternativa.engine3d.core.Transform3D;
   import alternativa.engine3d.core.VertexAttributes;
   import alternativa.engine3d.lights.DirectionalLight;
   import alternativa.engine3d.lights.OmniLight;
   import alternativa.engine3d.lights.SpotLight;
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
   import flash.display3D.Context3DVertexBufferFormat;
   import flash.display3D.VertexBuffer3D;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   
   use namespace alternativa3d;
   
   public class StandardMaterial extends TextureMaterial
   {
      
      alternativa3d static var fogTexture:TextureResource;
      
      private static const LIGHT_MAP_BIT:int = 1;
      
      private static const GLOSSINESS_MAP_BIT:int = 2;
      
      private static const SPECULAR_MAP_BIT:int = 4;
      
      private static const OPACITY_MAP_BIT:int = 8;
      
      private static const NORMAL_MAP_SPACE_OFFSET:int = 4;
      
      private static const ALPHA_TEST_OFFSET:int = 6;
      
      private static const OMNI_LIGHT_OFFSET:int = 8;
      
      private static const DIRECTIONAL_LIGHT_OFFSET:int = 11;
      
      private static const SPOT_LIGHT_OFFSET:int = 14;
      
      private static const SHADOW_OFFSET:int = 17;
      
      private static var caches:Dictionary = new Dictionary(true);
      
      alternativa3d static const DISABLED:int = 0;
      
      alternativa3d static const SIMPLE:int = 1;
      
      alternativa3d static const ADVANCED:int = 2;
      
      alternativa3d static var fogMode:int = alternativa3d::DISABLED;
      
      alternativa3d static var fogNear:Number = 1000;
      
      alternativa3d static var fogFar:Number = 5000;
      
      alternativa3d static var fogMaxDensity:Number = 1;
      
      alternativa3d static var fogColorR:Number = 200 / 255;
      
      alternativa3d static var fogColorG:Number = 162 / 255;
      
      alternativa3d static var fogColorB:Number = 200 / 255;
      
      private static const _passVaryingsProcedure:Procedure = new Procedure(["#v0=vPosition","#v1=vViewVector","#c0=cCameraPosition","mov v0, i0","sub t0, c0, i0","mov v1.xyz, t0.xyz","mov v1.w, c0.w"]);
      
      private static const _passTBNRightProcedure:Procedure = getPassTBNProcedure(true);
      
      private static const _passTBNLeftProcedure:Procedure = getPassTBNProcedure(false);
      
      private static const _ambientLightProcedure:Procedure = new Procedure(["#c0=cSurface","mov o0, i0","mov o1, c0.xxxx"],"ambientLightProcedure");
      
      private static const _setGlossinessFromConstantProcedure:Procedure = new Procedure(["#c0=cSurface","mov o0.w, c0.y"],"setGlossinessFromConstantProcedure");
      
      private static const _setGlossinessFromTextureProcedure:Procedure = new Procedure(["#v0=vUV","#c0=cSurface","#s0=sGlossiness","tex t0, v0, s0 <2d, repeat, linear, miplinear>","mul o0.w, t0.x, c0.y"],"setGlossinessFromTextureProcedure");
      
      private static const _getNormalAndViewTangentProcedure:Procedure = new Procedure(["#v0=vTangent","#v1=vBinormal","#v2=vNormal","#v3=vUV","#v4=vViewVector","#c0=cAmbientColor","#s0=sBump","tex t0, v3, s0 <2d,repeat,linear,miplinear>","add t0, t0, t0","sub t0.xyz, t0.xyz, c0.www","nrm t1.xyz, v0.xyz","dp3 o0.x, t0.xyz, t1.xyz","nrm t1.xyz, v1.xyz","dp3 o0.y, t0.xyz, t1.xyz","nrm t1.xyz, v2.xyz","dp3 o0.z, t0.xyz, t1.xyz","nrm o0.xyz, o0.xyz","nrm o1.xyz, v4"],"getNormalAndViewTangentProcedure");
      
      private static const _getNormalAndViewObjectProcedure:Procedure = new Procedure(["#v3=vUV","#v4=vViewVector","#c0=cAmbientColor","#s0=sBump","tex t0, v3, s0 <2d,repeat,linear,miplinear>","add t0, t0, t0","sub t0.xyz, t0.xyz, c0.www","nrm o0.xyz, t0.xyz","nrm o1.xyz, v4"],"getNormalAndViewObjectProcedure");
      
      private static const _applySpecularProcedure:Procedure = new Procedure(["#v0=vUV","#s0=sSpecular","tex t0, v0, s0 <2d, repeat,linear,miplinear>","mul o0.xyz, o0.xyz, t0.xyz"],"applySpecularProcedure");
      
      private static const _mulLightingProcedure:Procedure = new Procedure(["#c0=cSurface","mul i0.xyz, i0.xyz, i1.xyz","mul t1.xyz, i2.xyz, c0.z","add i0.xyz, i0.xyz, t1.xyz","mov o0, i0"],"mulLightingProcedure");
      
      private static const passSimpleFogConstProcedure:Procedure = new Procedure(["#v0=vZDistance","#c0=cFogSpace","dp4 t0.z, i0, c0","mov v0, t0.zzzz","sub v0.y, i0.w, t0.z"],"passSimpleFogConst");
      
      private static const outputWithSimpleFogProcedure:Procedure = new Procedure(["#v0=vZDistance","#c0=cFogColor","#c1=cFogRange","min t0.xy, v0.xy, c1.xy","max t0.xy, t0.xy, c1.zw","mul i0.xyz, i0.xyz, t0.y","mul t0.xyz, c0.xyz, t0.x","add i0.xyz, i0.xyz, t0.xyz","mov o0, i0"],"outputWithSimpleFog");
      
      private static const postPassAdvancedFogConstProcedure:Procedure = new Procedure(["#v0=vZDistance","#c0=cFogSpace","dp4 t0.z, i0, c0","mov v0, t0.zzzz","sub v0.y, i0.w, t0.z","mov v0.zw, i1.xwxw","mov o0, i1"],"postPassAdvancedFogConst");
      
      private static const outputWithAdvancedFogProcedure:Procedure = new Procedure(["#v0=vZDistance","#c0=cFogConsts","#c1=cFogRange","#s0=sFogTexture","min t0.xy, v0.xy, c1.xy","max t0.xy, t0.xy, c1.zw","mul i0.xyz, i0.xyz, t0.y","mov t1.xyzw, c0.yyzw","div t0.z, v0.z, v0.w","mul t0.z, t0.z, c0.x","add t1.x, t1.x, t0.z","tex t1, t1, s0 <2d, repeat, linear, miplinear>","mul t0.xyz, t1.xyz, t0.x","add i0.xyz, i0.xyz, t0.xyz","mov o0, i0"],"outputWithAdvancedFog");
      
      private static const _addLightMapProcedure:Procedure = new Procedure(["#v0=vUV1","#s0=sLightMap","tex t0, v0, s0 <2d,repeat,linear,miplinear>","add t0, t0, t0","add o0.xyz, i0.xyz, t0.xyz"],"applyLightMapProcedure");
      
      private static const _passLightMapUVProcedure:Procedure = new Procedure(["#a0=aUV1","#v0=vUV1","mov v0, a0"],"passLightMapUVProcedure");
      
      alternativa3d static var fallbackTextureMaterial:TextureMaterial = new TextureMaterial();
      
      alternativa3d static var fallbackLightMapMaterial:LightMapMaterial = new LightMapMaterial();
      
      private static var lightGroup:Vector.<Light3D> = new Vector.<Light3D>();
      
      private static var shadowGroup:Vector.<Light3D> = new Vector.<Light3D>();
      
      private var cachedContext3D:Context3D;
      
      private var programsCache:Dictionary;
      
      private var groups:Vector.<Vector.<Light3D>> = new Vector.<Vector.<Light3D>>();
      
      public var normalMap:TextureResource;
      
      private var _normalMapSpace:int = 0;
      
      public var specularMap:TextureResource;
      
      public var glossinessMap:TextureResource;
      
      public var lightMap:TextureResource;
      
      public var lightMapChannel:uint = 0;
      
      public var glossiness:Number = 100;
      
      public var specularPower:Number = 1;
      
      public function StandardMaterial(param1:TextureResource = null, param2:TextureResource = null, param3:TextureResource = null, param4:TextureResource = null, param5:TextureResource = null)
      {
         super(param1,param5);
         this.normalMap = param2;
         this.specularMap = param3;
         this.glossinessMap = param4;
      }
      
      private static function getPassTBNProcedure(param1:Boolean) : Procedure
      {
         var _loc2_:String = param1 ? "crs t1.xyz, i0, i1" : "crs t1.xyz, i1, i0";
         return new Procedure(["#v0=vTangent","#v1=vBinormal","#v2=vNormal",_loc2_,"mul t1.xyz, t1.xyz, i0.w","mov v0.xyzw, i1.xyxw","mov v0.x, i0.x","mov v0.y, t1.x","mov v1.xyzw, i1.xyyw","mov v1.x, i0.y","mov v1.y, t1.y","mov v2.xyzw, i1.xyzw","mov v2.x, i0.z","mov v2.y, t1.z"],"passTBNProcedure");
      }
      
      public function get normalMapSpace() : int
      {
         return this._normalMapSpace;
      }
      
      public function set normalMapSpace(param1:int) : void
      {
         if(param1 != NormalMapSpace.TANGENT_RIGHT_HANDED && param1 != NormalMapSpace.TANGENT_LEFT_HANDED && param1 != NormalMapSpace.OBJECT)
         {
            throw new ArgumentError("Value must be a constant from the NormalMapSpace class");
         }
         this._normalMapSpace = param1;
      }
      
      override alternativa3d function fillResources(param1:Dictionary, param2:Class) : void
      {
         super.alternativa3d::fillResources(param1,param2);
         if(this.normalMap != null && A3DUtils.alternativa3d::checkParent(getDefinitionByName(getQualifiedClassName(this.normalMap)) as Class,param2))
         {
            param1[this.normalMap] = true;
         }
         if(this.lightMap != null && A3DUtils.alternativa3d::checkParent(getDefinitionByName(getQualifiedClassName(this.lightMap)) as Class,param2))
         {
            param1[this.lightMap] = true;
         }
         if(this.glossinessMap != null && A3DUtils.alternativa3d::checkParent(getDefinitionByName(getQualifiedClassName(this.glossinessMap)) as Class,param2))
         {
            param1[this.glossinessMap] = true;
         }
         if(this.specularMap != null && A3DUtils.alternativa3d::checkParent(getDefinitionByName(getQualifiedClassName(this.specularMap)) as Class,param2))
         {
            param1[this.specularMap] = true;
         }
      }
      
      alternativa3d function getPassUVProcedure() : Procedure
      {
         return alternativa3d::_passUVProcedure;
      }
      
      alternativa3d function setPassUVProcedureConstants(param1:DrawUnit, param2:Linker) : void
      {
      }
      
      private function formDirectionalProcedure(param1:Procedure, param2:int, param3:Boolean) : void
      {
         var _loc4_:Array = ["#c0=c" + param2 + "Position","#c1=c" + param2 + "Color","add t0.xyz, i1.xyz, c0.xyz","mov t0.w, c0.w","nrm t0.xyz,t0.xyz","dp3 t0.w, t0.xyz, i0.xyz","pow t0.w, t0.w, o1.w","dp3 t0.x, i0.xyz, c0.xyz","sat t0.x, t0.x"];
         if(param3)
         {
            _loc4_.push("mul t0.xw, t0.xw, i2.x");
            _loc4_.push("mul t0.xyz, c1.xyz, t0.xxx");
            _loc4_.push("add o0.xyz, t0.xyz, i3.xyz");
            _loc4_.push("mul o1.xyz, c1.xyz, t0.www");
         }
         else
         {
            _loc4_.push("mul t0.xyz, c1.xyz, t0.xxxx");
            _loc4_.push("add o0, o0, t0.xyz");
            _loc4_.push("mul t0.xyz, c1.xyz, t0.w");
            _loc4_.push("add o1.xyz, o1.xyz, t0.xyz");
         }
         param1.compileFromArray(_loc4_);
      }
      
      private function formOmniProcedure(param1:Procedure, param2:int, param3:Boolean) : void
      {
         var _loc4_:Array = ["#c0=c" + param2 + "Position","#c1=c" + param2 + "Color","#c2=c" + param2 + "Radius","#v0=vPosition"];
         if(param3)
         {
            _loc4_.push("sub t0, c0, v0");
            _loc4_.push("dp3 t0.w, t0.xyz, t0.xyz");
            _loc4_.push("nrm t0.xyz, t0.xyz");
            _loc4_.push("add t1.xyz, i1.xyz, t0.xyz");
            _loc4_.push("nrm t1.xyz, t1.xyz");
            _loc4_.push("dp3 t1.w, t1.xyz, i0.xyz");
            _loc4_.push("pow t1.w, t1.w, o1.w");
            _loc4_.push("sqt t1.x, t0.w");
            _loc4_.push("dp3 t0.w, t0.xyz, i0.xyz");
            _loc4_.push("sub t0.x, t1.x, c2.z");
            _loc4_.push("div t0.y, t0.x, c2.y");
            _loc4_.push("sub t0.x, c2.x, t0.y");
            _loc4_.push("sat t0.xw, t0.xw");
            _loc4_.push("mul t0.xw,   t0.xwww,   i2.xxxx");
            _loc4_.push("mul t0.xyz, c1.xyz, t0.xxx");
            _loc4_.push("mul t1.xyz, t0.xyz, t1.w");
            _loc4_.push("add o1.xyz, o1.xyz, t1.xyz");
            _loc4_.push("mul t0.xyz, t0.xyz, t0.www");
            _loc4_.push("add o0.xyz, t0.xyz, i3.xyz");
         }
         else
         {
            _loc4_.push("sub t0, c0, v0");
            _loc4_.push("dp3 t0.w, t0.xyz, t0.xyz");
            _loc4_.push("nrm t0.xyz, t0.xyz");
            _loc4_.push("add t1.xyz, i1.xyz, t0.xyz");
            _loc4_.push("mov t1.w, c0.w");
            _loc4_.push("nrm t1.xyz, t1.xyz");
            _loc4_.push("dp3 t1.w, t1.xyz, i0.xyz");
            _loc4_.push("pow t1.w, t1.w, o1.w");
            _loc4_.push("sqt t1.x, t0.w");
            _loc4_.push("dp3 t0.w, t0.xyz, i0.xyz");
            _loc4_.push("sub t0.x, t1.x, c2.z");
            _loc4_.push("div t0.y, t0.x, c2.y");
            _loc4_.push("sub t0.x, c2.x, t0.y");
            _loc4_.push("sat t0.xw, t0.xw");
            _loc4_.push("mul t0.xyz, c1.xyz, t0.xxx");
            _loc4_.push("mul t1.xyz, t0.xyz, t1.w");
            _loc4_.push("add o1.xyz, o1.xyz, t1.xyz");
            _loc4_.push("mul t0.xyz, t0.xyz, t0.www");
            _loc4_.push("add o0.xyz, o0.xyz, t0.xyz");
         }
         param1.compileFromArray(_loc4_);
      }
      
      private function getProgram(param1:Object3D, param2:Array, param3:Camera3D, param4:int, param5:TextureResource, param6:int, param7:Vector.<Light3D>, param8:int, param9:Boolean, param10:Light3D) : StandardMaterialProgram
      {
         var _loc13_:Linker = null;
         var _loc14_:Linker = null;
         var _loc15_:int = 0;
         var _loc16_:String = null;
         var _loc17_:String = null;
         var _loc18_:String = null;
         var _loc19_:Procedure = null;
         var _loc20_:Procedure = null;
         var _loc21_:Procedure = null;
         var _loc22_:Procedure = null;
         var _loc23_:Procedure = null;
         var _loc24_:Procedure = null;
         var _loc25_:Light3D = null;
         var _loc26_:Procedure = null;
         var _loc11_:* = param4 | (param5 != null ? OPACITY_MAP_BIT : 0) | param6 << ALPHA_TEST_OFFSET;
         var _loc12_:StandardMaterialProgram = param2[_loc11_];
         if(_loc12_ == null)
         {
            _loc13_ = new Linker(Context3DProgramType.VERTEX);
            _loc14_ = new Linker(Context3DProgramType.FRAGMENT);
            _loc14_.declareVariable("tTotalLight");
            _loc14_.declareVariable("tTotalHighLight");
            _loc14_.declareVariable("tNormal");
            if(param9)
            {
               _loc14_.declareVariable("cAmbientColor",VariableType.CONSTANT);
               _loc14_.addProcedure(_ambientLightProcedure);
               _loc14_.setInputParams(_ambientLightProcedure,"cAmbientColor");
               _loc14_.setOutputParams(_ambientLightProcedure,"tTotalLight","tTotalHighLight");
               if(this.lightMap != null)
               {
                  _loc13_.addProcedure(_passLightMapUVProcedure);
                  _loc14_.addProcedure(_addLightMapProcedure);
                  _loc14_.setInputParams(_addLightMapProcedure,"tTotalLight");
                  _loc14_.setOutputParams(_addLightMapProcedure,"tTotalLight");
               }
            }
            else
            {
               _loc14_.declareVariable("cAmbientColor",VariableType.CONSTANT);
               _loc14_.addProcedure(_ambientLightProcedure);
               _loc14_.setInputParams(_ambientLightProcedure,"cAmbientColor");
               _loc14_.setOutputParams(_ambientLightProcedure,"tTotalLight","tTotalHighLight");
            }
            _loc16_ = "aPosition";
            _loc17_ = "aNormal";
            _loc18_ = "aTangent";
            _loc13_.declareVariable(_loc16_,VariableType.ATTRIBUTE);
            _loc13_.declareVariable(_loc18_,VariableType.ATTRIBUTE);
            _loc13_.declareVariable(_loc17_,VariableType.ATTRIBUTE);
            if(param1.alternativa3d::transformProcedure != null)
            {
               _loc16_ = alternativa3d::appendPositionTransformProcedure(param1.alternativa3d::transformProcedure,_loc13_);
            }
            _loc13_.addProcedure(alternativa3d::_projectProcedure);
            _loc13_.setInputParams(alternativa3d::_projectProcedure,_loc16_);
            _loc13_.addProcedure(this.alternativa3d::getPassUVProcedure());
            if(this.glossinessMap != null)
            {
               _loc14_.addProcedure(_setGlossinessFromTextureProcedure);
               _loc14_.setOutputParams(_setGlossinessFromTextureProcedure,"tTotalHighLight");
            }
            else
            {
               _loc14_.addProcedure(_setGlossinessFromConstantProcedure);
               _loc14_.setOutputParams(_setGlossinessFromConstantProcedure,"tTotalHighLight");
            }
            if(param8 > 0 || Boolean(param10))
            {
               if(param1.alternativa3d::deltaTransformProcedure != null)
               {
                  _loc13_.declareVariable("tTransformedNormal");
                  _loc20_ = param1.alternativa3d::deltaTransformProcedure.newInstance();
                  _loc13_.addProcedure(_loc20_);
                  _loc13_.setInputParams(_loc20_,_loc17_);
                  _loc13_.setOutputParams(_loc20_,"tTransformedNormal");
                  _loc17_ = "tTransformedNormal";
                  _loc13_.declareVariable("tTransformedTangent");
                  _loc20_ = param1.alternativa3d::deltaTransformProcedure.newInstance();
                  _loc13_.addProcedure(_loc20_);
                  _loc13_.setInputParams(_loc20_,_loc18_);
                  _loc13_.setOutputParams(_loc20_,"tTransformedTangent");
                  _loc18_ = "tTransformedTangent";
               }
               _loc13_.addProcedure(_passVaryingsProcedure);
               _loc13_.setInputParams(_passVaryingsProcedure,_loc16_);
               _loc14_.declareVariable("tViewVector");
               if(this._normalMapSpace == NormalMapSpace.TANGENT_RIGHT_HANDED || this._normalMapSpace == NormalMapSpace.TANGENT_LEFT_HANDED)
               {
                  _loc21_ = this._normalMapSpace == NormalMapSpace.TANGENT_RIGHT_HANDED ? _passTBNRightProcedure : _passTBNLeftProcedure;
                  _loc13_.addProcedure(_loc21_);
                  _loc13_.setInputParams(_loc21_,_loc18_,_loc17_);
                  _loc14_.addProcedure(_getNormalAndViewTangentProcedure);
                  _loc14_.setOutputParams(_getNormalAndViewTangentProcedure,"tNormal","tViewVector");
               }
               else
               {
                  _loc14_.addProcedure(_getNormalAndViewObjectProcedure);
                  _loc14_.setOutputParams(_getNormalAndViewObjectProcedure,"tNormal","tViewVector");
               }
               if(param10 != null)
               {
                  if(param10 is DirectionalLight)
                  {
                     _loc13_.addProcedure(param10.shadow.alternativa3d::vertexShadowProcedure,_loc16_);
                     _loc22_ = param10.shadow.alternativa3d::fragmentShadowProcedure;
                     _loc14_.addProcedure(_loc22_);
                     _loc14_.setOutputParams(_loc22_,"tTotalLight");
                     _loc23_ = new Procedure(null,"lightShadowDirectional");
                     this.formDirectionalProcedure(_loc23_,0,true);
                     _loc14_.addProcedure(_loc23_);
                     _loc14_.setInputParams(_loc23_,"tNormal","tViewVector","tTotalLight","cAmbientColor");
                     _loc14_.setOutputParams(_loc23_,"tTotalLight","tTotalHighLight");
                  }
                  if(param10 is OmniLight)
                  {
                     _loc13_.addProcedure(param10.shadow.alternativa3d::vertexShadowProcedure,_loc16_);
                     _loc22_ = param10.shadow.alternativa3d::fragmentShadowProcedure;
                     _loc14_.addProcedure(_loc22_);
                     _loc14_.setOutputParams(_loc22_,"tTotalLight");
                     _loc24_ = new Procedure(null,"lightShadowDirectional");
                     this.formOmniProcedure(_loc24_,0,true);
                     _loc14_.addProcedure(_loc24_);
                     _loc14_.setInputParams(_loc24_,"tNormal","tViewVector","tTotalLight","cAmbientColor");
                     _loc14_.setOutputParams(_loc24_,"tTotalLight","tTotalHighLight");
                  }
               }
               _loc15_ = 0;
               while(_loc15_ < param8)
               {
                  _loc25_ = param7[_loc15_];
                  if(!(_loc25_ == param10 && (param10 is DirectionalLight || param10 is OmniLight)))
                  {
                     _loc26_ = new Procedure();
                     _loc26_.name = "light" + _loc15_.toString();
                     if(_loc25_ is DirectionalLight)
                     {
                        this.formDirectionalProcedure(_loc26_,_loc15_,false);
                        _loc26_.name += "Directional";
                     }
                     else if(_loc25_ is OmniLight)
                     {
                        this.formOmniProcedure(_loc26_,_loc15_,false);
                        _loc26_.name += "Omni";
                     }
                     else if(_loc25_ is SpotLight)
                     {
                        _loc26_.compileFromArray(["#c0=c" + _loc15_ + "Position","#c1=c" + _loc15_ + "Color","#c2=c" + _loc15_ + "Radius","#c3=c" + _loc15_ + "Axis","#v0=vPosition","sub t0, c0, v0","dp3 t0.w, t0, t0","nrm t0.xyz,t0.xyz","add t2.xyz, i1.xyz, t0.xyz","nrm t2.xyz, t2.xyz","dp3 t2.x, t2.xyz, i0.xyz","pow t2.x, t2.x, o1.w","dp3 t1.x, t0.xyz, c3.xyz","dp3 t0.x, t0, i0.xyz","sqt t0.w, t0.w","sub t0.w, t0.w, c2.y","div t0.y, t0.w, c2.x","sub t0.w, c0.w, t0.y","sub t0.y, t1.x, c2.w","div t0.y, t0.y, c2.z","sat t0.xyw,t0.xyw","mul t1.xyz,c1.xyz,t0.yyy","mul t1.xyz,t1.xyz,t0.www","mul t2.xyz, t2.x, t1.xyz","add o1.xyz, o1.xyz, t2.xyz","mul t1.xyz, t1.xyz, t0.xxx","add o0.xyz, o0.xyz, t1.xyz"]);
                        _loc26_.name += "Spot";
                     }
                     _loc14_.addProcedure(_loc26_);
                     _loc14_.setInputParams(_loc26_,"tNormal","tViewVector");
                     _loc14_.setOutputParams(_loc26_,"tTotalLight","tTotalHighLight");
                  }
                  _loc15_++;
               }
            }
            if(this.specularMap != null)
            {
               _loc14_.addProcedure(_applySpecularProcedure);
               _loc14_.setOutputParams(_applySpecularProcedure,"tTotalHighLight");
               _loc19_ = _applySpecularProcedure;
            }
            _loc14_.declareVariable("tColor");
            _loc19_ = param5 != null ? alternativa3d::getDiffuseOpacityProcedure : alternativa3d::getDiffuseProcedure;
            _loc14_.addProcedure(_loc19_);
            _loc14_.setOutputParams(_loc19_,"tColor");
            if(param6 > 0)
            {
               _loc19_ = param6 == 1 ? alternativa3d::thresholdOpaqueAlphaProcedure : alternativa3d::thresholdTransparentAlphaProcedure;
               _loc14_.addProcedure(_loc19_,"tColor");
               _loc14_.setOutputParams(_loc19_,"tColor");
            }
            _loc14_.addProcedure(_mulLightingProcedure,"tColor","tTotalLight","tTotalHighLight");
            _loc14_.varyings = _loc13_.varyings;
            _loc12_ = new StandardMaterialProgram(_loc13_,_loc14_,param10 != null ? 1 : param8);
            _loc12_.upload(param3.alternativa3d::context3D);
            param2[_loc11_] = _loc12_;
         }
         return _loc12_;
      }
      
      private function addDrawUnits(param1:StandardMaterialProgram, param2:Camera3D, param3:Surface, param4:Geometry, param5:TextureResource, param6:Vector.<Light3D>, param7:int, param8:Boolean, param9:Light3D, param10:Boolean, param11:Boolean, param12:int) : void
      {
         var _loc19_:Light3D = null;
         var _loc20_:Number = NaN;
         var _loc21_:Transform3D = null;
         var _loc22_:Number = NaN;
         var _loc23_:OmniLight = null;
         var _loc24_:SpotLight = null;
         var _loc25_:Number = NaN;
         var _loc26_:Number = NaN;
         var _loc27_:Transform3D = null;
         var _loc28_:int = 0;
         var _loc13_:VertexBuffer3D = param4.alternativa3d::getVertexBuffer(VertexAttributes.POSITION);
         var _loc14_:VertexBuffer3D = param4.alternativa3d::getVertexBuffer(VertexAttributes.TEXCOORDS[0]);
         var _loc15_:VertexBuffer3D = param4.alternativa3d::getVertexBuffer(VertexAttributes.NORMAL);
         var _loc16_:VertexBuffer3D = param4.alternativa3d::getVertexBuffer(VertexAttributes.TANGENT4);
         if(_loc13_ == null || _loc14_ == null)
         {
            return;
         }
         if((param7 > 0 || param9 != null) && (_loc15_ == null || _loc16_ == null))
         {
            return;
         }
         var _loc17_:Object3D = param3.alternativa3d::object;
         var _loc18_:DrawUnit = param2.renderer.alternativa3d::createDrawUnit(_loc17_,param1.program,param4.alternativa3d::_indexBuffer,param3.indexBegin,param3.numTriangles,param1);
         _loc18_.alternativa3d::setVertexBufferAt(param1.aPosition,_loc13_,param4.alternativa3d::_attributesOffsets[VertexAttributes.POSITION],VertexAttributes.alternativa3d::FORMATS[VertexAttributes.POSITION]);
         _loc18_.alternativa3d::setVertexBufferAt(param1.aUV,_loc14_,param4.alternativa3d::_attributesOffsets[VertexAttributes.TEXCOORDS[0]],VertexAttributes.alternativa3d::FORMATS[VertexAttributes.TEXCOORDS[0]]);
         _loc17_.alternativa3d::setTransformConstants(_loc18_,param3,param1.vertexShader,param2);
         _loc18_.alternativa3d::setProjectionConstants(param2,param1.cProjMatrix,_loc17_.alternativa3d::localToCameraTransform);
         _loc18_.alternativa3d::setFragmentConstantsFromNumbers(param1.cSurface,0,this.glossiness,this.specularPower,1);
         _loc18_.alternativa3d::setFragmentConstantsFromNumbers(param1.cThresholdAlpha,alphaThreshold,0,0,alpha);
         if(param7 > 0 || param9 != null)
         {
            if(this._normalMapSpace == NormalMapSpace.TANGENT_RIGHT_HANDED || this._normalMapSpace == NormalMapSpace.TANGENT_LEFT_HANDED)
            {
               _loc18_.alternativa3d::setVertexBufferAt(param1.aNormal,_loc15_,param4.alternativa3d::_attributesOffsets[VertexAttributes.NORMAL],VertexAttributes.alternativa3d::FORMATS[VertexAttributes.NORMAL]);
               _loc18_.alternativa3d::setVertexBufferAt(param1.aTangent,_loc16_,param4.alternativa3d::_attributesOffsets[VertexAttributes.TANGENT4],VertexAttributes.alternativa3d::FORMATS[VertexAttributes.TANGENT4]);
            }
            _loc18_.alternativa3d::setTextureAt(param1.sBump,this.normalMap.alternativa3d::_texture);
            _loc27_ = _loc17_.alternativa3d::cameraToLocalTransform;
            _loc18_.alternativa3d::setVertexConstantsFromNumbers(param1.cCameraPosition,_loc27_.d,_loc27_.h,_loc27_.l);
            _loc28_ = 0;
            while(_loc28_ < param7)
            {
               _loc19_ = param6[_loc28_];
               if(_loc19_ is DirectionalLight)
               {
                  _loc21_ = _loc19_.alternativa3d::lightToObjectTransform;
                  _loc20_ = Math.sqrt(_loc21_.c * _loc21_.c + _loc21_.g * _loc21_.g + _loc21_.k * _loc21_.k);
                  _loc18_.alternativa3d::setFragmentConstantsFromNumbers(param1.cPosition[_loc28_],-_loc21_.c / _loc20_,-_loc21_.g / _loc20_,-_loc21_.k / _loc20_,1);
                  _loc18_.alternativa3d::setFragmentConstantsFromNumbers(param1.cColor[_loc28_],_loc19_.alternativa3d::red,_loc19_.alternativa3d::green,_loc19_.alternativa3d::blue);
               }
               else if(_loc19_ is OmniLight)
               {
                  _loc23_ = _loc19_ as OmniLight;
                  _loc21_ = _loc19_.alternativa3d::lightToObjectTransform;
                  _loc22_ = Math.sqrt(_loc21_.a * _loc21_.a + _loc21_.e * _loc21_.e + _loc21_.i * _loc21_.i);
                  _loc22_ = _loc22_ + Math.sqrt(_loc21_.b * _loc21_.b + _loc21_.f * _loc21_.f + _loc21_.j * _loc21_.j);
                  _loc22_ = _loc22_ + Math.sqrt(_loc21_.c * _loc21_.c + _loc21_.g * _loc21_.g + _loc21_.k * _loc21_.k);
                  _loc22_ = _loc22_ / 3;
                  _loc18_.alternativa3d::setFragmentConstantsFromNumbers(param1.cPosition[_loc28_],_loc21_.d,_loc21_.h,_loc21_.l);
                  _loc18_.alternativa3d::setFragmentConstantsFromNumbers(param1.cRadius[_loc28_],1,_loc23_.attenuationEnd * _loc22_ - _loc23_.attenuationBegin * _loc22_,_loc23_.attenuationBegin * _loc22_);
                  _loc18_.alternativa3d::setFragmentConstantsFromNumbers(param1.cColor[_loc28_],_loc19_.alternativa3d::red,_loc19_.alternativa3d::green,_loc19_.alternativa3d::blue);
               }
               else if(_loc19_ is SpotLight)
               {
                  _loc24_ = _loc19_ as SpotLight;
                  _loc21_ = _loc19_.alternativa3d::lightToObjectTransform;
                  _loc22_ = Math.sqrt(_loc21_.a * _loc21_.a + _loc21_.e * _loc21_.e + _loc21_.i * _loc21_.i);
                  _loc22_ = _loc22_ + Math.sqrt(_loc21_.b * _loc21_.b + _loc21_.f * _loc21_.f + _loc21_.j * _loc21_.j);
                  _loc22_ = _loc22_ + (_loc20_ = Math.sqrt(_loc21_.c * _loc21_.c + _loc21_.g * _loc21_.g + _loc21_.k * _loc21_.k));
                  _loc22_ = _loc22_ / 3;
                  _loc25_ = Math.cos(_loc24_.falloff * 0.5);
                  _loc26_ = Math.cos(_loc24_.hotspot * 0.5);
                  _loc18_.alternativa3d::setFragmentConstantsFromNumbers(param1.cPosition[_loc28_],_loc21_.d,_loc21_.h,_loc21_.l);
                  _loc18_.alternativa3d::setFragmentConstantsFromNumbers(param1.cAxis[_loc28_],-_loc21_.c / _loc20_,-_loc21_.g / _loc20_,-_loc21_.k / _loc20_);
                  _loc18_.alternativa3d::setFragmentConstantsFromNumbers(param1.cRadius[_loc28_],_loc24_.attenuationEnd * _loc22_ - _loc24_.attenuationBegin * _loc22_,_loc24_.attenuationBegin * _loc22_,_loc26_ == _loc25_ ? 0.000001 : _loc26_ - _loc25_,_loc25_);
                  _loc18_.alternativa3d::setFragmentConstantsFromNumbers(param1.cColor[_loc28_],_loc19_.alternativa3d::red,_loc19_.alternativa3d::green,_loc19_.alternativa3d::blue);
               }
               _loc28_++;
            }
         }
         if(param9 != null)
         {
            _loc19_ = param9;
            if(_loc19_ is DirectionalLight)
            {
               _loc21_ = _loc19_.alternativa3d::lightToObjectTransform;
               _loc20_ = Math.sqrt(_loc21_.c * _loc21_.c + _loc21_.g * _loc21_.g + _loc21_.k * _loc21_.k);
               _loc18_.alternativa3d::setFragmentConstantsFromNumbers(param1.cPosition[0],-_loc21_.c / _loc20_,-_loc21_.g / _loc20_,-_loc21_.k / _loc20_,1);
               _loc18_.alternativa3d::setFragmentConstantsFromNumbers(param1.cColor[0],_loc19_.alternativa3d::red,_loc19_.alternativa3d::green,_loc19_.alternativa3d::blue);
            }
            else if(_loc19_ is OmniLight)
            {
               _loc23_ = _loc19_ as OmniLight;
               _loc21_ = _loc19_.alternativa3d::lightToObjectTransform;
               _loc22_ = Math.sqrt(_loc21_.a * _loc21_.a + _loc21_.e * _loc21_.e + _loc21_.i * _loc21_.i);
               _loc22_ = _loc22_ + Math.sqrt(_loc21_.b * _loc21_.b + _loc21_.f * _loc21_.f + _loc21_.j * _loc21_.j);
               _loc22_ = _loc22_ + Math.sqrt(_loc21_.c * _loc21_.c + _loc21_.g * _loc21_.g + _loc21_.k * _loc21_.k);
               _loc22_ = _loc22_ / 3;
               _loc18_.alternativa3d::setFragmentConstantsFromNumbers(param1.cPosition[0],_loc21_.d,_loc21_.h,_loc21_.l);
               _loc18_.alternativa3d::setFragmentConstantsFromNumbers(param1.cRadius[0],1,_loc23_.attenuationEnd * _loc22_ - _loc23_.attenuationBegin * _loc22_,_loc23_.attenuationBegin * _loc22_);
               _loc18_.alternativa3d::setFragmentConstantsFromNumbers(param1.cColor[0],_loc19_.alternativa3d::red,_loc19_.alternativa3d::green,_loc19_.alternativa3d::blue);
            }
            else if(_loc19_ is SpotLight)
            {
               _loc24_ = _loc19_ as SpotLight;
               _loc21_ = _loc19_.alternativa3d::lightToObjectTransform;
               _loc22_ = Math.sqrt(_loc21_.a * _loc21_.a + _loc21_.e * _loc21_.e + _loc21_.i * _loc21_.i);
               _loc22_ = _loc22_ + Math.sqrt(_loc21_.b * _loc21_.b + _loc21_.f * _loc21_.f + _loc21_.j * _loc21_.j);
               _loc22_ = _loc22_ + (_loc20_ = Math.sqrt(_loc21_.c * _loc21_.c + _loc21_.g * _loc21_.g + _loc21_.k * _loc21_.k));
               _loc22_ = _loc22_ / 3;
               _loc25_ = Math.cos(_loc24_.falloff * 0.5);
               _loc26_ = Math.cos(_loc24_.hotspot * 0.5);
               _loc18_.alternativa3d::setFragmentConstantsFromNumbers(param1.cPosition[0],_loc21_.d,_loc21_.h,_loc21_.l);
               _loc18_.alternativa3d::setFragmentConstantsFromNumbers(param1.cAxis[0],-_loc21_.c / _loc20_,-_loc21_.g / _loc20_,-_loc21_.k / _loc20_);
               _loc18_.alternativa3d::setFragmentConstantsFromNumbers(param1.cRadius[0],_loc24_.attenuationEnd * _loc22_ - _loc24_.attenuationBegin * _loc22_,_loc24_.attenuationBegin * _loc22_,_loc26_ == _loc25_ ? 0.000001 : _loc26_ - _loc25_,_loc25_);
               _loc18_.alternativa3d::setFragmentConstantsFromNumbers(param1.cColor[0],_loc19_.alternativa3d::red,_loc19_.alternativa3d::green,_loc19_.alternativa3d::blue);
            }
         }
         _loc18_.alternativa3d::setTextureAt(param1.sDiffuse,diffuseMap.alternativa3d::_texture);
         if(param5 != null)
         {
            _loc18_.alternativa3d::setTextureAt(param1.sOpacity,param5.alternativa3d::_texture);
         }
         if(this.glossinessMap != null)
         {
            _loc18_.alternativa3d::setTextureAt(param1.sGlossiness,this.glossinessMap.alternativa3d::_texture);
         }
         if(this.specularMap != null)
         {
            _loc18_.alternativa3d::setTextureAt(param1.sSpecular,this.specularMap.alternativa3d::_texture);
         }
         if(param8)
         {
            if(this.lightMap != null)
            {
               _loc18_.alternativa3d::setVertexBufferAt(param1.aUV1,param4.alternativa3d::getVertexBuffer(VertexAttributes.TEXCOORDS[this.lightMapChannel]),param4.alternativa3d::_attributesOffsets[VertexAttributes.TEXCOORDS[this.lightMapChannel]],Context3DVertexBufferFormat.FLOAT_2);
               _loc18_.alternativa3d::setFragmentConstantsFromNumbers(param1.cAmbientColor,0,0,0,1);
               _loc18_.alternativa3d::setTextureAt(param1.sLightMap,this.lightMap.alternativa3d::_texture);
            }
            else
            {
               _loc18_.alternativa3d::setFragmentConstantsFromVector(param1.cAmbientColor,param2.alternativa3d::ambient,1);
            }
         }
         else
         {
            _loc18_.alternativa3d::setFragmentConstantsFromNumbers(param1.cAmbientColor,0,0,0,1);
         }
         this.alternativa3d::setPassUVProcedureConstants(_loc18_,param1.vertexShader);
         if(param9 != null && (param9 is DirectionalLight || param9 is OmniLight))
         {
            param9.shadow.alternativa3d::setup(_loc18_,param1.vertexShader,param1.fragmentShader,param3);
         }
         if(param10)
         {
            if(param8)
            {
               _loc18_.alternativa3d::blendSource = Context3DBlendFactor.ONE;
               _loc18_.alternativa3d::blendDestination = Context3DBlendFactor.ZERO;
               param2.renderer.alternativa3d::addDrawUnit(_loc18_,param12 >= 0 ? param12 : Renderer.OPAQUE);
            }
            else
            {
               _loc18_.alternativa3d::blendSource = Context3DBlendFactor.ONE;
               _loc18_.alternativa3d::blendDestination = Context3DBlendFactor.ONE;
               param2.renderer.alternativa3d::addDrawUnit(_loc18_,param12 >= 0 ? param12 : Renderer.OPAQUE_OVERHEAD);
            }
         }
         if(param11)
         {
            if(param8)
            {
               _loc18_.alternativa3d::blendSource = Context3DBlendFactor.SOURCE_ALPHA;
               _loc18_.alternativa3d::blendDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
            }
            else
            {
               _loc18_.alternativa3d::blendSource = Context3DBlendFactor.SOURCE_ALPHA;
               _loc18_.alternativa3d::blendDestination = Context3DBlendFactor.ONE;
            }
            param2.renderer.alternativa3d::addDrawUnit(_loc18_,param12 >= 0 ? param12 : Renderer.TRANSPARENT_SORT);
         }
      }
      
      override alternativa3d function collectDraws(param1:Camera3D, param2:Surface, param3:Geometry, param4:Vector.<Light3D>, param5:int, param6:Boolean, param7:int = -1) : void
      {
         var _loc13_:int = 0;
         var _loc14_:Light3D = null;
         var _loc19_:* = 0;
         var _loc20_:StandardMaterialProgram = null;
         var _loc21_:int = 0;
         var _loc22_:Boolean = false;
         var _loc23_:int = 0;
         var _loc24_:int = 0;
         var _loc25_:int = 0;
         if(diffuseMap == null || this.normalMap == null || diffuseMap.alternativa3d::_texture == null || this.normalMap.alternativa3d::_texture == null)
         {
            return;
         }
         if(opacityMap != null && opacityMap.alternativa3d::_texture == null || this.glossinessMap != null && this.glossinessMap.alternativa3d::_texture == null || this.specularMap != null && this.specularMap.alternativa3d::_texture == null || this.lightMap != null && this.lightMap.alternativa3d::_texture == null)
         {
            return;
         }
         if(param1.alternativa3d::context3DProperties.isConstrained)
         {
            if(this.lightMap == null)
            {
               alternativa3d::fallbackTextureMaterial.diffuseMap = diffuseMap;
               alternativa3d::fallbackTextureMaterial.opacityMap = opacityMap;
               alternativa3d::fallbackTextureMaterial.alphaThreshold = alphaThreshold;
               alternativa3d::fallbackTextureMaterial.alpha = alpha;
               alternativa3d::fallbackTextureMaterial.opaquePass = opaquePass;
               alternativa3d::fallbackTextureMaterial.transparentPass = transparentPass;
               alternativa3d::fallbackTextureMaterial.alternativa3d::collectDraws(param1,param2,param3,param4,param5,param6,param7);
            }
            else
            {
               alternativa3d::fallbackLightMapMaterial.diffuseMap = diffuseMap;
               alternativa3d::fallbackLightMapMaterial.lightMap = this.lightMap;
               alternativa3d::fallbackLightMapMaterial.lightMapChannel = this.lightMapChannel;
               alternativa3d::fallbackLightMapMaterial.opacityMap = opacityMap;
               alternativa3d::fallbackLightMapMaterial.alphaThreshold = alphaThreshold;
               alternativa3d::fallbackLightMapMaterial.alpha = alpha;
               alternativa3d::fallbackLightMapMaterial.opaquePass = opaquePass;
               alternativa3d::fallbackLightMapMaterial.transparentPass = transparentPass;
               alternativa3d::fallbackLightMapMaterial.alternativa3d::collectDraws(param1,param2,param3,param4,param5,param6,param7);
            }
            return;
         }
         var _loc8_:Object3D = param2.alternativa3d::object;
         var _loc9_:VertexBuffer3D = param3.alternativa3d::getVertexBuffer(VertexAttributes.POSITION);
         var _loc10_:VertexBuffer3D = param3.alternativa3d::getVertexBuffer(VertexAttributes.TEXCOORDS[0]);
         var _loc11_:VertexBuffer3D = param3.alternativa3d::getVertexBuffer(VertexAttributes.NORMAL);
         var _loc12_:VertexBuffer3D = param3.alternativa3d::getVertexBuffer(VertexAttributes.TANGENT4);
         if(_loc9_ == null || _loc10_ == null)
         {
            return;
         }
         if(param5 > 0 && (this._normalMapSpace == NormalMapSpace.TANGENT_RIGHT_HANDED || this._normalMapSpace == NormalMapSpace.TANGENT_LEFT_HANDED))
         {
            if(_loc11_ == null || _loc12_ == null)
            {
               return;
            }
         }
         if(param1.alternativa3d::context3D != this.cachedContext3D)
         {
            this.cachedContext3D = param1.alternativa3d::context3D;
            this.programsCache = caches[this.cachedContext3D];
            if(this.programsCache == null)
            {
               this.programsCache = new Dictionary(false);
               caches[this.cachedContext3D] = this.programsCache;
            }
         }
         var _loc15_:Array = this.programsCache[_loc8_.alternativa3d::transformProcedure];
         if(_loc15_ == null)
         {
            _loc15_ = [];
            this.programsCache[_loc8_.alternativa3d::transformProcedure] = _loc15_;
         }
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc18_:int = 0;
         _loc13_ = 0;
         while(_loc13_ < param5)
         {
            _loc14_ = param4[_loc13_];
            if(_loc14_.shadow != null && param6)
            {
               shadowGroup[int(_loc18_++)] = _loc14_;
            }
            else
            {
               if(_loc17_ == 6)
               {
                  this.groups[int(_loc16_++)] = lightGroup;
                  lightGroup = new Vector.<Light3D>();
                  _loc17_ = 0;
               }
               lightGroup[int(_loc17_++)] = _loc14_;
            }
            _loc13_++;
         }
         if(_loc17_ != 0)
         {
            this.groups[int(_loc16_++)] = lightGroup;
         }
         if(_loc16_ == 0 && _loc18_ == 0)
         {
            _loc19_ = (this.lightMap != null ? LIGHT_MAP_BIT : 0) | (this.glossinessMap != null ? GLOSSINESS_MAP_BIT : 0) | (this.specularMap != null ? SPECULAR_MAP_BIT : 0);
            if(opaquePass && alphaThreshold <= alpha)
            {
               if(alphaThreshold > 0)
               {
                  _loc20_ = this.getProgram(_loc8_,_loc15_,param1,_loc19_,opacityMap,1,null,0,true,null);
                  this.addDrawUnits(_loc20_,param1,param2,param3,opacityMap,null,0,true,null,true,false,param7);
               }
               else
               {
                  _loc20_ = this.getProgram(_loc8_,_loc15_,param1,_loc19_,null,0,null,0,true,null);
                  this.addDrawUnits(_loc20_,param1,param2,param3,null,null,0,true,null,true,false,param7);
               }
            }
            if(transparentPass && alphaThreshold > 0 && alpha > 0)
            {
               if(alphaThreshold <= alpha && !opaquePass)
               {
                  _loc20_ = this.getProgram(_loc8_,_loc15_,param1,_loc19_,opacityMap,2,null,0,true,null);
                  this.addDrawUnits(_loc20_,param1,param2,param3,opacityMap,null,0,true,null,false,true,param7);
               }
               else
               {
                  _loc20_ = this.getProgram(_loc8_,_loc15_,param1,_loc19_,opacityMap,0,null,0,true,null);
                  this.addDrawUnits(_loc20_,param1,param2,param3,opacityMap,null,0,true,null,false,true,param7);
               }
            }
         }
         else
         {
            _loc22_ = true;
            _loc13_ = 0;
            while(_loc13_ < _loc16_)
            {
               lightGroup = this.groups[_loc13_];
               _loc17_ = int(lightGroup.length);
               _loc19_ = _loc22_ ? (this.lightMap != null ? LIGHT_MAP_BIT : 0) : 0;
               _loc19_ = _loc19_ | (this._normalMapSpace << NORMAL_MAP_SPACE_OFFSET | (this.glossinessMap != null ? GLOSSINESS_MAP_BIT : 0) | (this.specularMap != null ? SPECULAR_MAP_BIT : 0));
               _loc23_ = 0;
               _loc24_ = 0;
               _loc25_ = 0;
               _loc21_ = 0;
               while(_loc21_ < _loc17_)
               {
                  _loc14_ = lightGroup[_loc21_];
                  if(_loc14_ is OmniLight)
                  {
                     _loc23_++;
                  }
                  else if(_loc14_ is DirectionalLight)
                  {
                     _loc24_++;
                  }
                  else if(_loc14_ is SpotLight)
                  {
                     _loc25_++;
                  }
                  _loc21_++;
               }
               _loc19_ |= _loc23_ << OMNI_LIGHT_OFFSET;
               _loc19_ = _loc19_ | _loc24_ << DIRECTIONAL_LIGHT_OFFSET;
               _loc19_ = _loc19_ | _loc25_ << SPOT_LIGHT_OFFSET;
               if(opaquePass && alphaThreshold <= alpha)
               {
                  if(alphaThreshold > 0)
                  {
                     _loc20_ = this.getProgram(_loc8_,_loc15_,param1,_loc19_,opacityMap,1,lightGroup,_loc17_,_loc22_,null);
                     this.addDrawUnits(_loc20_,param1,param2,param3,opacityMap,lightGroup,_loc17_,_loc22_,null,true,false,param7);
                  }
                  else
                  {
                     _loc20_ = this.getProgram(_loc8_,_loc15_,param1,_loc19_,null,0,lightGroup,_loc17_,_loc22_,null);
                     this.addDrawUnits(_loc20_,param1,param2,param3,null,lightGroup,_loc17_,_loc22_,null,true,false,param7);
                  }
               }
               if(transparentPass && alphaThreshold > 0 && alpha > 0)
               {
                  if(alphaThreshold <= alpha && !opaquePass)
                  {
                     _loc20_ = this.getProgram(_loc8_,_loc15_,param1,_loc19_,opacityMap,2,lightGroup,_loc17_,_loc22_,null);
                     this.addDrawUnits(_loc20_,param1,param2,param3,opacityMap,lightGroup,_loc17_,_loc22_,null,false,true,param7);
                  }
                  else
                  {
                     _loc20_ = this.getProgram(_loc8_,_loc15_,param1,_loc19_,opacityMap,0,lightGroup,_loc17_,_loc22_,null);
                     this.addDrawUnits(_loc20_,param1,param2,param3,opacityMap,lightGroup,_loc17_,_loc22_,null,false,true,param7);
                  }
               }
               _loc22_ = false;
               lightGroup.length = 0;
               _loc13_++;
            }
            if(_loc18_ > 0)
            {
               _loc21_ = 0;
               while(_loc21_ < _loc18_)
               {
                  _loc14_ = shadowGroup[_loc21_];
                  _loc19_ = _loc22_ ? (this.lightMap != null ? LIGHT_MAP_BIT : 0) : 0;
                  _loc19_ = _loc19_ | (this._normalMapSpace << NORMAL_MAP_SPACE_OFFSET | (this.glossinessMap != null ? GLOSSINESS_MAP_BIT : 0) | (this.specularMap != null ? SPECULAR_MAP_BIT : 0));
                  _loc19_ = _loc19_ | _loc14_.shadow.alternativa3d::type << SHADOW_OFFSET;
                  if(_loc14_ is OmniLight)
                  {
                     _loc19_ |= 1 << OMNI_LIGHT_OFFSET;
                  }
                  else if(_loc14_ is DirectionalLight)
                  {
                     _loc19_ |= 1 << DIRECTIONAL_LIGHT_OFFSET;
                  }
                  else if(_loc14_ is SpotLight)
                  {
                     _loc19_ |= 1 << SPOT_LIGHT_OFFSET;
                  }
                  if(opaquePass && alphaThreshold <= alpha)
                  {
                     if(alphaThreshold > 0)
                     {
                        _loc20_ = this.getProgram(_loc8_,_loc15_,param1,_loc19_,opacityMap,1,null,0,_loc22_,_loc14_);
                        this.addDrawUnits(_loc20_,param1,param2,param3,opacityMap,null,0,_loc22_,_loc14_,true,false,param7);
                     }
                     else
                     {
                        _loc20_ = this.getProgram(_loc8_,_loc15_,param1,_loc19_,null,0,null,0,_loc22_,_loc14_);
                        this.addDrawUnits(_loc20_,param1,param2,param3,null,null,0,_loc22_,_loc14_,true,false,param7);
                     }
                  }
                  if(transparentPass && alphaThreshold > 0 && alpha > 0)
                  {
                     if(alphaThreshold <= alpha && !opaquePass)
                     {
                        _loc20_ = this.getProgram(_loc8_,_loc15_,param1,_loc19_,opacityMap,2,null,0,_loc22_,_loc14_);
                        this.addDrawUnits(_loc20_,param1,param2,param3,opacityMap,null,0,_loc22_,_loc14_,false,true,param7);
                     }
                     else
                     {
                        _loc20_ = this.getProgram(_loc8_,_loc15_,param1,_loc19_,opacityMap,0,null,0,_loc22_,_loc14_);
                        this.addDrawUnits(_loc20_,param1,param2,param3,opacityMap,null,0,_loc22_,_loc14_,false,true,param7);
                     }
                  }
                  _loc22_ = false;
                  _loc21_++;
               }
            }
            shadowGroup.length = 0;
         }
         this.groups.length = 0;
      }
      
      override public function clone() : Material
      {
         var _loc1_:StandardMaterial = new StandardMaterial(diffuseMap,this.normalMap,this.specularMap,this.glossinessMap,opacityMap);
         _loc1_.clonePropertiesFrom(this);
         return _loc1_;
      }
      
      override protected function clonePropertiesFrom(param1:Material) : void
      {
         super.clonePropertiesFrom(param1);
         var _loc2_:StandardMaterial = StandardMaterial(param1);
         this.glossiness = _loc2_.glossiness;
         this.specularPower = _loc2_.specularPower;
         this._normalMapSpace = _loc2_._normalMapSpace;
         this.lightMap = _loc2_.lightMap;
         this.lightMapChannel = _loc2_.lightMapChannel;
      }
   }
}

import alternativa.engine3d.materials.compiler.Linker;
import flash.display3D.Context3D;

class StandardMaterialProgram extends ShaderProgram
{
   
   public var aPosition:int = -1;
   
   public var aUV:int = -1;
   
   public var aUV1:int = -1;
   
   public var aNormal:int = -1;
   
   public var aTangent:int = -1;
   
   public var cProjMatrix:int = -1;
   
   public var cCameraPosition:int = -1;
   
   public var cAmbientColor:int = -1;
   
   public var cSurface:int = -1;
   
   public var cThresholdAlpha:int = -1;
   
   public var sDiffuse:int = -1;
   
   public var sOpacity:int = -1;
   
   public var sBump:int = -1;
   
   public var sGlossiness:int = -1;
   
   public var sSpecular:int = -1;
   
   public var sLightMap:int = -1;
   
   public var cPosition:Vector.<int>;
   
   public var cRadius:Vector.<int>;
   
   public var cAxis:Vector.<int>;
   
   public var cColor:Vector.<int>;
   
   public function StandardMaterialProgram(param1:Linker, param2:Linker, param3:int)
   {
      super(param1,param2);
      this.cPosition = new Vector.<int>(param3);
      this.cRadius = new Vector.<int>(param3);
      this.cAxis = new Vector.<int>(param3);
      this.cColor = new Vector.<int>(param3);
   }
   
   override public function upload(param1:Context3D) : void
   {
      super.upload(param1);
      this.aPosition = vertexShader.findVariable("aPosition");
      this.aUV = vertexShader.findVariable("aUV");
      this.aUV1 = vertexShader.findVariable("aUV1");
      this.aNormal = vertexShader.findVariable("aNormal");
      this.aTangent = vertexShader.findVariable("aTangent");
      this.cProjMatrix = vertexShader.findVariable("cProjMatrix");
      this.cCameraPosition = vertexShader.findVariable("cCameraPosition");
      this.cAmbientColor = fragmentShader.findVariable("cAmbientColor");
      this.cSurface = fragmentShader.findVariable("cSurface");
      this.cThresholdAlpha = fragmentShader.findVariable("cThresholdAlpha");
      this.sDiffuse = fragmentShader.findVariable("sDiffuse");
      this.sOpacity = fragmentShader.findVariable("sOpacity");
      this.sBump = fragmentShader.findVariable("sBump");
      this.sGlossiness = fragmentShader.findVariable("sGlossiness");
      this.sSpecular = fragmentShader.findVariable("sSpecular");
      this.sLightMap = fragmentShader.findVariable("sLightMap");
      var _loc2_:int = int(this.cPosition.length);
      var _loc3_:int = 0;
      while(_loc3_ < _loc2_)
      {
         this.cPosition[_loc3_] = fragmentShader.findVariable("c" + _loc3_ + "Position");
         this.cRadius[_loc3_] = fragmentShader.findVariable("c" + _loc3_ + "Radius");
         this.cAxis[_loc3_] = fragmentShader.findVariable("c" + _loc3_ + "Axis");
         this.cColor[_loc3_] = fragmentShader.findVariable("c" + _loc3_ + "Color");
         _loc3_++;
      }
   }
}
