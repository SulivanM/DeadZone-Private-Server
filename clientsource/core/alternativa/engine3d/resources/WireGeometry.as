package alternativa.engine3d.resources
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.BoundBox;
   import alternativa.engine3d.core.Camera3D;
   import alternativa.engine3d.core.DrawUnit;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Renderer;
   import alternativa.engine3d.core.Resource;
   import alternativa.engine3d.core.Transform3D;
   import alternativa.engine3d.materials.ShaderProgram;
   import flash.display3D.Context3D;
   import flash.display3D.Context3DBlendFactor;
   import flash.display3D.Context3DVertexBufferFormat;
   import flash.display3D.IndexBuffer3D;
   import flash.display3D.VertexBuffer3D;
   
   use namespace alternativa3d;
   
   public class WireGeometry extends Resource
   {
      
      private const MAX_VERTICES_COUNT:uint = 65500;
      
      private const VERTEX_STRIDE:uint = 7;
      
      alternativa3d var vertexBuffers:Vector.<VertexBuffer3D>;
      
      alternativa3d var indexBuffers:Vector.<IndexBuffer3D>;
      
      private var nTriangles:Vector.<int>;
      
      private var vertices:Vector.<Vector.<Number>>;
      
      private var indices:Vector.<Vector.<uint>>;
      
      private var currentSetIndex:int = 0;
      
      private var currentSetVertexOffset:uint = 0;
      
      public function WireGeometry()
      {
         super();
         this.alternativa3d::vertexBuffers = new Vector.<VertexBuffer3D>(1);
         this.alternativa3d::indexBuffers = new Vector.<IndexBuffer3D>(1);
         this.clear();
      }
      
      override public function upload(param1:Context3D) : void
      {
         var _loc3_:Vector.<Number> = null;
         var _loc4_:Vector.<uint> = null;
         var _loc5_:VertexBuffer3D = null;
         var _loc6_:IndexBuffer3D = null;
         var _loc2_:int = 0;
         while(_loc2_ <= this.currentSetIndex)
         {
            if(this.alternativa3d::vertexBuffers[_loc2_] != null)
            {
               this.alternativa3d::vertexBuffers[_loc2_].dispose();
            }
            if(this.alternativa3d::indexBuffers[_loc2_] != null)
            {
               this.alternativa3d::indexBuffers[_loc2_].dispose();
            }
            if(this.nTriangles[_loc2_] > 0)
            {
               _loc3_ = this.vertices[_loc2_];
               _loc4_ = this.indices[_loc2_];
               _loc5_ = this.alternativa3d::vertexBuffers[_loc2_] = param1.createVertexBuffer(_loc3_.length / this.VERTEX_STRIDE,this.VERTEX_STRIDE);
               _loc5_.uploadFromVector(_loc3_,0,_loc3_.length / this.VERTEX_STRIDE);
               _loc6_ = this.alternativa3d::indexBuffers[_loc2_] = param1.createIndexBuffer(_loc4_.length);
               _loc6_.uploadFromVector(_loc4_,0,_loc4_.length);
            }
            _loc2_++;
         }
      }
      
      override public function dispose() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ <= this.currentSetIndex)
         {
            if(this.alternativa3d::vertexBuffers[_loc1_] != null)
            {
               this.alternativa3d::vertexBuffers[_loc1_].dispose();
               this.alternativa3d::vertexBuffers[_loc1_] = null;
            }
            if(this.alternativa3d::indexBuffers[_loc1_] != null)
            {
               this.alternativa3d::indexBuffers[_loc1_].dispose();
               this.alternativa3d::indexBuffers[_loc1_] = null;
            }
            _loc1_++;
         }
      }
      
      override public function get isUploaded() : Boolean
      {
         var _loc1_:int = 0;
         while(_loc1_ <= this.currentSetIndex)
         {
            if(this.alternativa3d::vertexBuffers[_loc1_] == null)
            {
               return false;
            }
            if(this.alternativa3d::indexBuffers[_loc1_] == null)
            {
               return false;
            }
            _loc1_++;
         }
         return true;
      }
      
      public function clear() : void
      {
         this.dispose();
         this.vertices = new Vector.<Vector.<Number>>();
         this.indices = new Vector.<Vector.<uint>>();
         this.vertices[0] = new Vector.<Number>();
         this.indices[0] = new Vector.<uint>();
         this.nTriangles = new Vector.<int>(1);
         this.currentSetVertexOffset = 0;
      }
      
      alternativa3d function updateBoundBox(param1:BoundBox, param2:Transform3D = null) : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Vector.<Number> = null;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc3_:int = 0;
         var _loc4_:int = int(this.vertices.length);
         while(_loc3_ < _loc4_)
         {
            _loc5_ = 0;
            _loc6_ = int(this.vertices[_loc3_].length);
            while(_loc5_ < _loc6_)
            {
               _loc7_ = this.vertices[_loc3_];
               _loc8_ = _loc7_[_loc5_];
               _loc9_ = _loc7_[int(_loc5_ + 1)];
               _loc10_ = _loc7_[int(_loc5_ + 2)];
               if(param2 != null)
               {
                  _loc11_ = param2.a * _loc8_ + param2.b * _loc9_ + param2.c * _loc10_ + param2.d;
                  _loc12_ = param2.e * _loc8_ + param2.f * _loc9_ + param2.g * _loc10_ + param2.h;
                  _loc13_ = param2.i * _loc8_ + param2.j * _loc9_ + param2.k * _loc10_ + param2.l;
               }
               else
               {
                  _loc11_ = _loc8_;
                  _loc12_ = _loc9_;
                  _loc13_ = _loc10_;
               }
               if(_loc11_ < param1.minX)
               {
                  param1.minX = _loc11_;
               }
               if(_loc11_ > param1.maxX)
               {
                  param1.maxX = _loc11_;
               }
               if(_loc12_ < param1.minY)
               {
                  param1.minY = _loc12_;
               }
               if(_loc12_ > param1.maxY)
               {
                  param1.maxY = _loc12_;
               }
               if(_loc13_ < param1.minZ)
               {
                  param1.minZ = _loc13_;
               }
               if(_loc13_ > param1.maxZ)
               {
                  param1.maxZ = _loc13_;
               }
               _loc5_ += this.VERTEX_STRIDE;
            }
            _loc3_++;
         }
      }
      
      alternativa3d function getDrawUnits(param1:Camera3D, param2:Vector.<Number>, param3:Number, param4:Object3D, param5:ShaderProgram) : void
      {
         var _loc7_:IndexBuffer3D = null;
         var _loc8_:VertexBuffer3D = null;
         var _loc9_:DrawUnit = null;
         var _loc6_:int = 0;
         while(_loc6_ <= this.currentSetIndex)
         {
            _loc7_ = this.alternativa3d::indexBuffers[_loc6_];
            _loc8_ = this.alternativa3d::vertexBuffers[_loc6_];
            if(_loc7_ != null && _loc8_ != null)
            {
               _loc9_ = param1.renderer.alternativa3d::createDrawUnit(param4,param5.program,_loc7_,0,this.nTriangles[_loc6_],param5);
               _loc9_.alternativa3d::setVertexBufferAt(0,_loc8_,0,Context3DVertexBufferFormat.FLOAT_4);
               _loc9_.alternativa3d::setVertexBufferAt(1,_loc8_,4,Context3DVertexBufferFormat.FLOAT_3);
               _loc9_.alternativa3d::setVertexConstantsFromNumbers(0,0,1,-1,0.000001);
               _loc9_.alternativa3d::setVertexConstantsFromNumbers(1,-1 / param1.alternativa3d::focalLength,0,param1.nearClipping,param3);
               _loc9_.alternativa3d::setVertexConstantsFromTransform(2,param4.alternativa3d::localToCameraTransform);
               _loc9_.alternativa3d::setProjectionConstants(param1,5);
               _loc9_.alternativa3d::setFragmentConstantsFromNumbers(0,param2[0],param2[1],param2[2],param2[3]);
               if(param2[3] < 1)
               {
                  _loc9_.alternativa3d::blendSource = Context3DBlendFactor.SOURCE_ALPHA;
                  _loc9_.alternativa3d::blendDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
                  param1.renderer.alternativa3d::addDrawUnit(_loc9_,Renderer.TRANSPARENT_SORT);
               }
               else
               {
                  param1.renderer.alternativa3d::addDrawUnit(_loc9_,Renderer.OPAQUE);
               }
            }
            _loc6_++;
         }
      }
      
      alternativa3d function addLine(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number) : void
      {
         var _loc7_:Vector.<Number> = this.vertices[this.currentSetIndex];
         var _loc8_:Vector.<uint> = this.indices[this.currentSetIndex];
         var _loc9_:uint = _loc7_.length / this.VERTEX_STRIDE;
         if(_loc9_ > this.MAX_VERTICES_COUNT - 4)
         {
            this.currentSetVertexOffset = 0;
            ++this.currentSetIndex;
            this.nTriangles[this.currentSetIndex] = 0;
            _loc7_ = this.vertices[this.currentSetIndex] = new Vector.<Number>();
            _loc8_ = this.indices[this.currentSetIndex] = new Vector.<uint>();
            this.alternativa3d::vertexBuffers.length = this.currentSetIndex + 1;
            this.alternativa3d::indexBuffers.length = this.currentSetIndex + 1;
         }
         else
         {
            this.nTriangles[this.currentSetIndex] += 2;
         }
         _loc7_.push(param1,param2,param3,0.5,param4,param5,param6,param4,param5,param6,-0.5,param1,param2,param3,param1,param2,param3,-0.5,param4,param5,param6,param4,param5,param6,0.5,param1,param2,param3);
         _loc8_.push(this.currentSetVertexOffset,this.currentSetVertexOffset + 1,this.currentSetVertexOffset + 2,this.currentSetVertexOffset + 3,this.currentSetVertexOffset + 2,this.currentSetVertexOffset + 1);
         this.currentSetVertexOffset += 4;
      }
   }
}

