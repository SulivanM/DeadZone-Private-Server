package alternativa.engine3d.core
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.materials.ShaderProgram;
   import flash.display3D.Context3D;
   import flash.display3D.Context3DCompareMode;
   import flash.display3D.Context3DProgramType;
   import flash.display3D.IndexBuffer3D;
   import flash.display3D.Program3D;
   
   use namespace alternativa3d;
   
   public class Renderer
   {
      
      public static const SKY:int = 10;
      
      public static const OPAQUE:int = 20;
      
      public static const OPAQUE_OVERHEAD:int = 25;
      
      public static const DECALS:int = 30;
      
      public static const TRANSPARENT_SORT:int = 40;
      
      public static const NEXT_LAYER:int = 50;
      
      protected var collector:DrawUnit;
      
      alternativa3d var camera:Camera3D;
      
      alternativa3d var drawUnits:Vector.<DrawUnit> = new Vector.<DrawUnit>();
      
      protected var _contextProperties:RendererContext3DProperties;
      
      public function Renderer()
      {
         super();
      }
      
      alternativa3d function render(param1:Context3D) : void
      {
         var _loc4_:DrawUnit = null;
         var _loc5_:DrawUnit = null;
         this.updateContext3D(param1);
         var _loc2_:int = int(this.alternativa3d::drawUnits.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            _loc4_ = this.alternativa3d::drawUnits[_loc3_];
            if(_loc4_ != null)
            {
               switch(_loc3_)
               {
                  case SKY:
                     param1.setDepthTest(false,Context3DCompareMode.ALWAYS);
                     break;
                  case OPAQUE:
                     param1.setDepthTest(true,Context3DCompareMode.LESS);
                     break;
                  case OPAQUE_OVERHEAD:
                     param1.setDepthTest(false,Context3DCompareMode.EQUAL);
                     break;
                  case DECALS:
                     param1.setDepthTest(false,Context3DCompareMode.LESS_EQUAL);
                     break;
                  case TRANSPARENT_SORT:
                     if(_loc4_.alternativa3d::next != null)
                     {
                        _loc4_ = this.alternativa3d::sortByAverageZ(_loc4_);
                     }
                     param1.setDepthTest(false,Context3DCompareMode.LESS);
                     break;
                  case NEXT_LAYER:
                     param1.setDepthTest(false,Context3DCompareMode.ALWAYS);
               }
               continue loop1;
            }
            _loc3_++;
         }
         this.alternativa3d::freeContext3DProperties(param1);
         this.alternativa3d::drawUnits.length = 0;
      }
      
      alternativa3d function createDrawUnit(param1:Object3D, param2:Program3D, param3:IndexBuffer3D, param4:int, param5:int, param6:ShaderProgram = null) : DrawUnit
      {
         var _loc7_:DrawUnit = null;
         if(this.collector != null)
         {
            _loc7_ = this.collector;
            this.collector = this.collector.alternativa3d::next;
            _loc7_.alternativa3d::next = null;
         }
         else
         {
            _loc7_ = new DrawUnit();
         }
         _loc7_.alternativa3d::object = param1;
         _loc7_.alternativa3d::program = param2;
         _loc7_.alternativa3d::indexBuffer = param3;
         _loc7_.alternativa3d::firstIndex = param4;
         _loc7_.alternativa3d::numTriangles = param5;
         return _loc7_;
      }
      
      alternativa3d function addDrawUnit(param1:DrawUnit, param2:int) : void
      {
         if(param2 >= this.alternativa3d::drawUnits.length)
         {
            this.alternativa3d::drawUnits.length = param2 + 1;
         }
         param1.alternativa3d::next = this.alternativa3d::drawUnits[param2];
         this.alternativa3d::drawUnits[param2] = param1;
      }
      
      protected function renderDrawUnit(param1:DrawUnit, param2:Context3D, param3:Camera3D) : void
      {
         var _loc4_:int = 0;
         var _loc5_:* = 0;
         var _loc6_:* = 0;
         var _loc7_:int = 0;
         var _loc8_:* = 0;
         var _loc9_:* = 0;
         if(this._contextProperties.blendSource != param1.alternativa3d::blendSource || this._contextProperties.blendDestination != param1.alternativa3d::blendDestination)
         {
            param2.setBlendFactors(param1.alternativa3d::blendSource,param1.alternativa3d::blendDestination);
            this._contextProperties.blendSource = param1.alternativa3d::blendSource;
            this._contextProperties.blendDestination = param1.alternativa3d::blendDestination;
         }
         if(this._contextProperties.culling != param1.alternativa3d::culling)
         {
            param2.setCulling(param1.alternativa3d::culling);
            this._contextProperties.culling = param1.alternativa3d::culling;
         }
         var _loc10_:int = 0;
         while(_loc10_ < param1.alternativa3d::vertexBuffersLength)
         {
            _loc4_ = param1.alternativa3d::vertexBuffersIndexes[_loc10_];
            _loc5_ = 1 << _loc4_;
            _loc6_ |= _loc5_;
            param2.setVertexBufferAt(_loc4_,param1.alternativa3d::vertexBuffers[_loc10_],param1.alternativa3d::vertexBuffersOffsets[_loc10_],param1.alternativa3d::vertexBuffersFormats[_loc10_]);
            _loc10_++;
         }
         if(param1.alternativa3d::vertexConstantsRegistersCount > 0)
         {
            param2.setProgramConstantsFromVector(Context3DProgramType.VERTEX,0,param1.alternativa3d::vertexConstants,param1.alternativa3d::vertexConstantsRegistersCount);
         }
         if(param1.alternativa3d::fragmentConstantsRegistersCount > 0)
         {
            param2.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT,0,param1.alternativa3d::fragmentConstants,param1.alternativa3d::fragmentConstantsRegistersCount);
         }
         _loc10_ = 0;
         while(_loc10_ < param1.alternativa3d::texturesLength)
         {
            _loc7_ = param1.alternativa3d::texturesSamplers[_loc10_];
            _loc8_ = 1 << _loc7_;
            _loc9_ |= _loc8_;
            param2.setTextureAt(_loc7_,param1.alternativa3d::textures[_loc10_]);
            _loc10_++;
         }
         if(this._contextProperties.program != param1.alternativa3d::program)
         {
            param2.setProgram(param1.alternativa3d::program);
            this._contextProperties.program = param1.alternativa3d::program;
         }
         var _loc11_:uint = uint(this._contextProperties.usedBuffers & ~_loc6_);
         var _loc12_:uint = uint(this._contextProperties.usedTextures & ~_loc9_);
         _loc4_ = 0;
         while(_loc11_ > 0)
         {
            _loc5_ = _loc11_ & 1;
            _loc11_ >>= 1;
            if(_loc5_)
            {
               param2.setVertexBufferAt(_loc4_,null);
            }
            _loc4_++;
         }
         _loc7_ = 0;
         while(_loc12_ > 0)
         {
            _loc8_ = _loc12_ & 1;
            _loc12_ >>= 1;
            if(_loc8_)
            {
               param2.setTextureAt(_loc7_,null);
            }
            _loc7_++;
         }
         param2.drawTriangles(param1.alternativa3d::indexBuffer,param1.alternativa3d::firstIndex,param1.alternativa3d::numTriangles);
         this._contextProperties.usedBuffers = _loc6_;
         this._contextProperties.usedTextures = _loc9_;
         ++param3.alternativa3d::numDraws;
         param3.alternativa3d::numTriangles += param1.alternativa3d::numTriangles;
      }
      
      protected function updateContext3D(param1:Context3D) : void
      {
         this._contextProperties = this.alternativa3d::camera.alternativa3d::context3DProperties;
      }
      
      alternativa3d function freeContext3DProperties(param1:Context3D) : void
      {
         var _loc4_:int = 0;
         var _loc5_:* = 0;
         var _loc6_:int = 0;
         var _loc7_:* = 0;
         this._contextProperties.culling = null;
         this._contextProperties.blendSource = null;
         this._contextProperties.blendDestination = null;
         this._contextProperties.program = null;
         var _loc2_:uint = this._contextProperties.usedBuffers;
         var _loc3_:uint = this._contextProperties.usedTextures;
         _loc4_ = 0;
         while(_loc2_ > 0)
         {
            _loc5_ = _loc2_ & 1;
            _loc2_ >>= 1;
            if(_loc5_)
            {
               param1.setVertexBufferAt(_loc4_,null);
            }
            _loc4_++;
         }
         _loc6_ = 0;
         while(_loc3_ > 0)
         {
            _loc7_ = _loc3_ & 1;
            _loc3_ >>= 1;
            if(_loc7_)
            {
               param1.setTextureAt(_loc6_,null);
            }
            _loc6_++;
         }
         this._contextProperties.usedBuffers = 0;
         this._contextProperties.usedTextures = 0;
      }
      
      alternativa3d function sortByAverageZ(param1:DrawUnit, param2:Boolean = true) : DrawUnit
      {
         var _loc3_:DrawUnit = param1;
         var _loc4_:DrawUnit = param1.alternativa3d::next;
         while(_loc4_ != null && _loc4_.alternativa3d::next != null)
         {
            param1 = param1.alternativa3d::next;
            _loc4_ = _loc4_.alternativa3d::next.alternativa3d::next;
         }
         _loc4_ = param1.alternativa3d::next;
         param1.alternativa3d::next = null;
         if(_loc3_.alternativa3d::next != null)
         {
            _loc3_ = this.alternativa3d::sortByAverageZ(_loc3_,param2);
         }
         if(_loc4_.alternativa3d::next != null)
         {
            _loc4_ = this.alternativa3d::sortByAverageZ(_loc4_,param2);
         }
         var _loc5_:Boolean = param2 ? _loc3_.alternativa3d::object.alternativa3d::localToCameraTransform.l > _loc4_.alternativa3d::object.alternativa3d::localToCameraTransform.l : _loc3_.alternativa3d::object.alternativa3d::localToCameraTransform.l < _loc4_.alternativa3d::object.alternativa3d::localToCameraTransform.l;
         if(_loc5_)
         {
            param1 = _loc3_;
            _loc3_ = _loc3_.alternativa3d::next;
         }
         else
         {
            param1 = _loc4_;
            _loc4_ = _loc4_.alternativa3d::next;
         }
         var _loc6_:DrawUnit = param1;
         while(_loc3_ != null)
         {
            if(_loc4_ == null)
            {
               _loc6_.alternativa3d::next = _loc3_;
               return param1;
            }
            if(_loc5_)
            {
               if(param2 ? _loc3_.alternativa3d::object.alternativa3d::localToCameraTransform.l > _loc4_.alternativa3d::object.alternativa3d::localToCameraTransform.l : _loc3_.alternativa3d::object.alternativa3d::localToCameraTransform.l < _loc4_.alternativa3d::object.alternativa3d::localToCameraTransform.l)
               {
                  _loc6_ = _loc3_;
                  _loc3_ = _loc3_.alternativa3d::next;
               }
               else
               {
                  _loc6_.alternativa3d::next = _loc4_;
                  _loc6_ = _loc4_;
                  _loc4_ = _loc4_.alternativa3d::next;
                  _loc5_ = false;
               }
            }
            else if(param2 ? _loc3_.alternativa3d::object.alternativa3d::localToCameraTransform.l < _loc4_.alternativa3d::object.alternativa3d::localToCameraTransform.l : _loc3_.alternativa3d::object.alternativa3d::localToCameraTransform.l > _loc4_.alternativa3d::object.alternativa3d::localToCameraTransform.l)
            {
               _loc6_ = _loc4_;
               _loc4_ = _loc4_.alternativa3d::next;
            }
            else
            {
               _loc6_.alternativa3d::next = _loc3_;
               _loc6_ = _loc3_;
               _loc3_ = _loc3_.alternativa3d::next;
               _loc5_ = true;
            }
         }
         _loc6_.alternativa3d::next = _loc4_;
         return param1;
      }
   }
}

