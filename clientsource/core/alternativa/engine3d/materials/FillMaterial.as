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
   import flash.display3D.Context3D;
   import flash.display3D.Context3DBlendFactor;
   import flash.display3D.Context3DProgramType;
   import flash.display3D.VertexBuffer3D;
   import flash.utils.Dictionary;
   
   use namespace alternativa3d;
   
   public class FillMaterial extends Material
   {
      
      private static var caches:Dictionary = new Dictionary(true);
      
      private static var outColorProcedure:Procedure = new Procedure(["#c0=cColor","mov o0, c0"],"outColorProcedure");
      
      private var cachedContext3D:Context3D;
      
      private var programsCache:Dictionary;
      
      public var alpha:Number = 1;
      
      private var red:Number;
      
      private var green:Number;
      
      private var blue:Number;
      
      public function FillMaterial(param1:uint = 8355711, param2:Number = 1)
      {
         super();
         this.color = param1;
         this.alpha = param2;
      }
      
      public function get color() : uint
      {
         return (this.red * 255 << 16) + (this.green * 255 << 8) + this.blue * 255;
      }
      
      public function set color(param1:uint) : void
      {
         this.red = (param1 >> 16 & 0xFF) / 255;
         this.green = (param1 >> 8 & 0xFF) / 255;
         this.blue = (param1 & 0xFF) / 255;
      }
      
      private function setupProgram(param1:Object3D) : FillMaterialProgram
      {
         var _loc2_:Linker = new Linker(Context3DProgramType.VERTEX);
         var _loc3_:String = "aPosition";
         _loc2_.declareVariable(_loc3_,VariableType.ATTRIBUTE);
         if(param1.alternativa3d::transformProcedure != null)
         {
            _loc3_ = alternativa3d::appendPositionTransformProcedure(param1.alternativa3d::transformProcedure,_loc2_);
         }
         _loc2_.addProcedure(alternativa3d::_projectProcedure);
         _loc2_.setInputParams(alternativa3d::_projectProcedure,_loc3_);
         var _loc4_:Linker = new Linker(Context3DProgramType.FRAGMENT);
         _loc4_.addProcedure(outColorProcedure);
         _loc4_.varyings = _loc2_.varyings;
         return new FillMaterialProgram(_loc2_,_loc4_);
      }
      
      override alternativa3d function collectDraws(param1:Camera3D, param2:Surface, param3:Geometry, param4:Vector.<Light3D>, param5:int, param6:Boolean, param7:int = -1) : void
      {
         var _loc8_:Object3D = param2.alternativa3d::object;
         var _loc9_:VertexBuffer3D = param3.alternativa3d::getVertexBuffer(VertexAttributes.POSITION);
         if(_loc9_ == null)
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
         var _loc10_:FillMaterialProgram = this.programsCache[_loc8_.alternativa3d::transformProcedure];
         if(_loc10_ == null)
         {
            _loc10_ = this.setupProgram(_loc8_);
            _loc10_.upload(param1.alternativa3d::context3D);
            this.programsCache[_loc8_.alternativa3d::transformProcedure] = _loc10_;
         }
         var _loc11_:DrawUnit = param1.renderer.alternativa3d::createDrawUnit(_loc8_,_loc10_.program,param3.alternativa3d::_indexBuffer,param2.indexBegin,param2.numTriangles,_loc10_);
         _loc11_.alternativa3d::setVertexBufferAt(_loc10_.aPosition,_loc9_,param3.alternativa3d::_attributesOffsets[VertexAttributes.POSITION],VertexAttributes.alternativa3d::FORMATS[VertexAttributes.POSITION]);
         _loc8_.alternativa3d::setTransformConstants(_loc11_,param2,_loc10_.vertexShader,param1);
         _loc11_.alternativa3d::setProjectionConstants(param1,_loc10_.cProjMatrix,_loc8_.alternativa3d::localToCameraTransform);
         _loc11_.alternativa3d::setFragmentConstantsFromNumbers(_loc10_.cColor,this.red,this.green,this.blue,this.alpha);
         if(this.alpha < 1)
         {
            _loc11_.alternativa3d::blendSource = Context3DBlendFactor.SOURCE_ALPHA;
            _loc11_.alternativa3d::blendDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
            param1.renderer.alternativa3d::addDrawUnit(_loc11_,param7 >= 0 ? param7 : Renderer.TRANSPARENT_SORT);
         }
         else
         {
            param1.renderer.alternativa3d::addDrawUnit(_loc11_,param7 >= 0 ? param7 : Renderer.OPAQUE);
         }
      }
      
      override public function clone() : Material
      {
         var _loc1_:FillMaterial = new FillMaterial(this.color,this.alpha);
         _loc1_.clonePropertiesFrom(this);
         return _loc1_;
      }
   }
}

import alternativa.engine3d.materials.compiler.Linker;
import flash.display3D.Context3D;

class FillMaterialProgram extends ShaderProgram
{
   
   public var aPosition:int = -1;
   
   public var cProjMatrix:int = -1;
   
   public var cColor:int = -1;
   
   public function FillMaterialProgram(param1:Linker, param2:Linker)
   {
      super(param1,param2);
   }
   
   override public function upload(param1:Context3D) : void
   {
      super.upload(param1);
      this.aPosition = vertexShader.findVariable("aPosition");
      this.cProjMatrix = vertexShader.findVariable("cProjMatrix");
      this.cColor = fragmentShader.findVariable("cColor");
   }
}
