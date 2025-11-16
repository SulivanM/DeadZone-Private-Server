package alternativa.engine3d.core
{
   import alternativa.engine3d.alternativa3d;
   import flash.display3D.Context3DBlendFactor;
   import flash.display3D.Context3DTriangleFace;
   import flash.display3D.IndexBuffer3D;
   import flash.display3D.Program3D;
   import flash.display3D.VertexBuffer3D;
   import flash.display3D.textures.TextureBase;
   
   use namespace alternativa3d;
   
   public class DrawUnit
   {
      
      alternativa3d var next:DrawUnit;
      
      alternativa3d var object:Object3D;
      
      alternativa3d var program:Program3D;
      
      alternativa3d var indexBuffer:IndexBuffer3D;
      
      alternativa3d var firstIndex:int;
      
      alternativa3d var numTriangles:int;
      
      alternativa3d var blendSource:String = "one";
      
      alternativa3d var blendDestination:String = "zero";
      
      alternativa3d var culling:String = "front";
      
      alternativa3d var textures:Vector.<TextureBase> = new Vector.<TextureBase>();
      
      alternativa3d var texturesSamplers:Vector.<int> = new Vector.<int>();
      
      alternativa3d var texturesLength:int = 0;
      
      alternativa3d var vertexBuffers:Vector.<VertexBuffer3D> = new Vector.<VertexBuffer3D>();
      
      alternativa3d var vertexBuffersIndexes:Vector.<int> = new Vector.<int>();
      
      alternativa3d var vertexBuffersOffsets:Vector.<int> = new Vector.<int>();
      
      alternativa3d var vertexBuffersFormats:Vector.<String> = new Vector.<String>();
      
      alternativa3d var vertexBuffersLength:int = 0;
      
      alternativa3d var vertexConstants:Vector.<Number> = new Vector.<Number>();
      
      alternativa3d var vertexConstantsRegistersCount:int = 0;
      
      alternativa3d var fragmentConstants:Vector.<Number> = new Vector.<Number>(28 * 4,true);
      
      alternativa3d var fragmentConstantsRegistersCount:int = 0;
      
      public function DrawUnit()
      {
         super();
      }
      
      alternativa3d function clear() : void
      {
         this.alternativa3d::object = null;
         this.alternativa3d::program = null;
         this.alternativa3d::indexBuffer = null;
         this.alternativa3d::blendSource = Context3DBlendFactor.ONE;
         this.alternativa3d::blendDestination = Context3DBlendFactor.ZERO;
         this.alternativa3d::culling = Context3DTriangleFace.FRONT;
         this.alternativa3d::textures.length = 0;
         this.alternativa3d::texturesLength = 0;
         this.alternativa3d::vertexBuffers.length = 0;
         this.alternativa3d::vertexBuffersLength = 0;
         this.alternativa3d::vertexConstantsRegistersCount = 0;
         this.alternativa3d::fragmentConstantsRegistersCount = 0;
      }
      
      alternativa3d function setTextureAt(param1:int, param2:TextureBase) : void
      {
         if(uint(param1) > 8)
         {
            throw new Error("Sampler index " + param1 + " is out of bounds.");
         }
         if(param2 == null)
         {
            throw new Error("Texture is null");
         }
         this.alternativa3d::texturesSamplers[this.alternativa3d::texturesLength] = param1;
         this.alternativa3d::textures[this.alternativa3d::texturesLength] = param2;
         ++this.alternativa3d::texturesLength;
      }
      
      alternativa3d function setVertexBufferAt(param1:int, param2:VertexBuffer3D, param3:int, param4:String) : void
      {
         if(uint(param1) > 8)
         {
            throw new Error("VertexBuffer index " + param1 + " is out of bounds.");
         }
         if(param2 == null)
         {
            throw new Error("Buffer is null");
         }
         this.alternativa3d::vertexBuffersIndexes[this.alternativa3d::vertexBuffersLength] = param1;
         this.alternativa3d::vertexBuffers[this.alternativa3d::vertexBuffersLength] = param2;
         this.alternativa3d::vertexBuffersOffsets[this.alternativa3d::vertexBuffersLength] = param3;
         this.alternativa3d::vertexBuffersFormats[this.alternativa3d::vertexBuffersLength] = param4;
         ++this.alternativa3d::vertexBuffersLength;
      }
      
      alternativa3d function setVertexConstantsFromVector(param1:int, param2:Vector.<Number>, param3:int) : void
      {
         if(uint(param1) > 128 - param3)
         {
            throw new Error("Register index " + param1 + " is out of bounds.");
         }
         var _loc4_:* = param1 << 2;
         if(param1 + param3 > this.alternativa3d::vertexConstantsRegistersCount)
         {
            this.alternativa3d::vertexConstantsRegistersCount = param1 + param3;
            this.alternativa3d::vertexConstants.length = this.alternativa3d::vertexConstantsRegistersCount << 2;
         }
         var _loc5_:int = 0;
         var _loc6_:* = param3 << 2;
         while(_loc5_ < _loc6_)
         {
            this.alternativa3d::vertexConstants[_loc4_] = param2[_loc5_];
            _loc4_++;
            _loc5_++;
         }
      }
      
      alternativa3d function setVertexConstantsFromNumbers(param1:int, param2:Number, param3:Number, param4:Number, param5:Number = 1) : void
      {
         if(uint(param1) > 127)
         {
            throw new Error("Register index " + param1 + " is out of bounds.");
         }
         var _loc6_:* = param1 << 2;
         if(param1 + 1 > this.alternativa3d::vertexConstantsRegistersCount)
         {
            this.alternativa3d::vertexConstantsRegistersCount = param1 + 1;
            this.alternativa3d::vertexConstants.length = this.alternativa3d::vertexConstantsRegistersCount << 2;
         }
         this.alternativa3d::vertexConstants[_loc6_] = param2;
         _loc6_++;
         this.alternativa3d::vertexConstants[_loc6_] = param3;
         _loc6_++;
         this.alternativa3d::vertexConstants[_loc6_] = param4;
         _loc6_++;
         this.alternativa3d::vertexConstants[_loc6_] = param5;
      }
      
      alternativa3d function setVertexConstantsFromTransform(param1:int, param2:Transform3D) : void
      {
         if(uint(param1) > 125)
         {
            throw new Error("Register index " + param1 + " is out of bounds.");
         }
         var _loc3_:* = param1 << 2;
         if(param1 + 3 > this.alternativa3d::vertexConstantsRegistersCount)
         {
            this.alternativa3d::vertexConstantsRegistersCount = param1 + 3;
            this.alternativa3d::vertexConstants.length = this.alternativa3d::vertexConstantsRegistersCount << 2;
         }
         this.alternativa3d::vertexConstants[_loc3_] = param2.a;
         _loc3_++;
         this.alternativa3d::vertexConstants[_loc3_] = param2.b;
         _loc3_++;
         this.alternativa3d::vertexConstants[_loc3_] = param2.c;
         _loc3_++;
         this.alternativa3d::vertexConstants[_loc3_] = param2.d;
         _loc3_++;
         this.alternativa3d::vertexConstants[_loc3_] = param2.e;
         _loc3_++;
         this.alternativa3d::vertexConstants[_loc3_] = param2.f;
         _loc3_++;
         this.alternativa3d::vertexConstants[_loc3_] = param2.g;
         _loc3_++;
         this.alternativa3d::vertexConstants[_loc3_] = param2.h;
         _loc3_++;
         this.alternativa3d::vertexConstants[_loc3_] = param2.i;
         _loc3_++;
         this.alternativa3d::vertexConstants[_loc3_] = param2.j;
         _loc3_++;
         this.alternativa3d::vertexConstants[_loc3_] = param2.k;
         _loc3_++;
         this.alternativa3d::vertexConstants[_loc3_] = param2.l;
      }
      
      alternativa3d function setProjectionConstants(param1:Camera3D, param2:int, param3:Transform3D = null) : void
      {
         if(uint(param2) > 124)
         {
            throw new Error("Register index is out of bounds.");
         }
         var _loc4_:* = param2 << 2;
         if(param2 + 4 > this.alternativa3d::vertexConstantsRegistersCount)
         {
            this.alternativa3d::vertexConstantsRegistersCount = param2 + 4;
            this.alternativa3d::vertexConstants.length = this.alternativa3d::vertexConstantsRegistersCount << 2;
         }
         if(param3 != null)
         {
            this.alternativa3d::vertexConstants[_loc4_] = param3.a * param1.alternativa3d::m0;
            _loc4_++;
            this.alternativa3d::vertexConstants[_loc4_] = param3.b * param1.alternativa3d::m0;
            _loc4_++;
            this.alternativa3d::vertexConstants[_loc4_] = param3.c * param1.alternativa3d::m0;
            _loc4_++;
            this.alternativa3d::vertexConstants[_loc4_] = param3.d * param1.alternativa3d::m0;
            _loc4_++;
            this.alternativa3d::vertexConstants[_loc4_] = param3.e * param1.alternativa3d::m5;
            _loc4_++;
            this.alternativa3d::vertexConstants[_loc4_] = param3.f * param1.alternativa3d::m5;
            _loc4_++;
            this.alternativa3d::vertexConstants[_loc4_] = param3.g * param1.alternativa3d::m5;
            _loc4_++;
            this.alternativa3d::vertexConstants[_loc4_] = param3.h * param1.alternativa3d::m5;
            _loc4_++;
            this.alternativa3d::vertexConstants[_loc4_] = param3.i * param1.alternativa3d::m10;
            _loc4_++;
            this.alternativa3d::vertexConstants[_loc4_] = param3.j * param1.alternativa3d::m10;
            _loc4_++;
            this.alternativa3d::vertexConstants[_loc4_] = param3.k * param1.alternativa3d::m10;
            _loc4_++;
            this.alternativa3d::vertexConstants[_loc4_] = param3.l * param1.alternativa3d::m10 + param1.alternativa3d::m14;
            _loc4_++;
            if(!param1.orthographic)
            {
               this.alternativa3d::vertexConstants[_loc4_] = param3.i;
               _loc4_++;
               this.alternativa3d::vertexConstants[_loc4_] = param3.j;
               _loc4_++;
               this.alternativa3d::vertexConstants[_loc4_] = param3.k;
               _loc4_++;
               this.alternativa3d::vertexConstants[_loc4_] = param3.l;
            }
            else
            {
               this.alternativa3d::vertexConstants[_loc4_] = 0;
               _loc4_++;
               this.alternativa3d::vertexConstants[_loc4_] = 0;
               _loc4_++;
               this.alternativa3d::vertexConstants[_loc4_] = 0;
               _loc4_++;
               this.alternativa3d::vertexConstants[_loc4_] = 1;
            }
         }
         else
         {
            this.alternativa3d::vertexConstants[_loc4_] = param1.alternativa3d::m0;
            _loc4_++;
            this.alternativa3d::vertexConstants[_loc4_] = 0;
            _loc4_++;
            this.alternativa3d::vertexConstants[_loc4_] = 0;
            _loc4_++;
            this.alternativa3d::vertexConstants[_loc4_] = 0;
            _loc4_++;
            this.alternativa3d::vertexConstants[_loc4_] = 0;
            _loc4_++;
            this.alternativa3d::vertexConstants[_loc4_] = param1.alternativa3d::m5;
            _loc4_++;
            this.alternativa3d::vertexConstants[_loc4_] = 0;
            _loc4_++;
            this.alternativa3d::vertexConstants[_loc4_] = 0;
            _loc4_++;
            this.alternativa3d::vertexConstants[_loc4_] = 0;
            _loc4_++;
            this.alternativa3d::vertexConstants[_loc4_] = 0;
            _loc4_++;
            this.alternativa3d::vertexConstants[_loc4_] = param1.alternativa3d::m10;
            _loc4_++;
            this.alternativa3d::vertexConstants[_loc4_] = param1.alternativa3d::m14;
            _loc4_++;
            this.alternativa3d::vertexConstants[_loc4_] = 0;
            _loc4_++;
            this.alternativa3d::vertexConstants[_loc4_] = 0;
            _loc4_++;
            if(!param1.orthographic)
            {
               this.alternativa3d::vertexConstants[_loc4_] = 1;
               _loc4_++;
               this.alternativa3d::vertexConstants[_loc4_] = 0;
            }
            else
            {
               this.alternativa3d::vertexConstants[_loc4_] = 0;
               _loc4_++;
               this.alternativa3d::vertexConstants[_loc4_] = 1;
            }
         }
      }
      
      alternativa3d function setFragmentConstantsFromVector(param1:int, param2:Vector.<Number>, param3:int) : void
      {
         if(uint(param1) > 28 - param3)
         {
            throw new Error("Register index " + param1 + " is out of bounds.");
         }
         var _loc4_:* = param1 << 2;
         if(param1 + param3 > this.alternativa3d::fragmentConstantsRegistersCount)
         {
            this.alternativa3d::fragmentConstantsRegistersCount = param1 + param3;
         }
         var _loc5_:int = 0;
         var _loc6_:* = param3 << 2;
         while(_loc5_ < _loc6_)
         {
            this.alternativa3d::fragmentConstants[_loc4_] = param2[_loc5_];
            _loc4_++;
            _loc5_++;
         }
      }
      
      alternativa3d function setFragmentConstantsFromNumbers(param1:int, param2:Number, param3:Number, param4:Number, param5:Number = 1) : void
      {
         if(uint(param1) > 27)
         {
            throw new Error("Register index " + param1 + " is out of bounds.");
         }
         var _loc6_:* = param1 << 2;
         if(param1 + 1 > this.alternativa3d::fragmentConstantsRegistersCount)
         {
            this.alternativa3d::fragmentConstantsRegistersCount = param1 + 1;
         }
         this.alternativa3d::fragmentConstants[_loc6_] = param2;
         _loc6_++;
         this.alternativa3d::fragmentConstants[_loc6_] = param3;
         _loc6_++;
         this.alternativa3d::fragmentConstants[_loc6_] = param4;
         _loc6_++;
         this.alternativa3d::fragmentConstants[_loc6_] = param5;
      }
      
      alternativa3d function setFragmentConstantsFromTransform(param1:int, param2:Transform3D) : void
      {
         if(uint(param1) > 25)
         {
            throw new Error("Register index " + param1 + " is out of bounds.");
         }
         var _loc3_:* = param1 << 2;
         if(param1 + 3 > this.alternativa3d::fragmentConstantsRegistersCount)
         {
            this.alternativa3d::fragmentConstantsRegistersCount = param1 + 3;
         }
         this.alternativa3d::fragmentConstants[_loc3_] = param2.a;
         _loc3_++;
         this.alternativa3d::fragmentConstants[_loc3_] = param2.b;
         _loc3_++;
         this.alternativa3d::fragmentConstants[_loc3_] = param2.c;
         _loc3_++;
         this.alternativa3d::fragmentConstants[_loc3_] = param2.d;
         _loc3_++;
         this.alternativa3d::fragmentConstants[_loc3_] = param2.e;
         _loc3_++;
         this.alternativa3d::fragmentConstants[_loc3_] = param2.f;
         _loc3_++;
         this.alternativa3d::fragmentConstants[_loc3_] = param2.g;
         _loc3_++;
         this.alternativa3d::fragmentConstants[_loc3_] = param2.h;
         _loc3_++;
         this.alternativa3d::fragmentConstants[_loc3_] = param2.i;
         _loc3_++;
         this.alternativa3d::fragmentConstants[_loc3_] = param2.j;
         _loc3_++;
         this.alternativa3d::fragmentConstants[_loc3_] = param2.k;
         _loc3_++;
         this.alternativa3d::fragmentConstants[_loc3_] = param2.l;
      }
   }
}

