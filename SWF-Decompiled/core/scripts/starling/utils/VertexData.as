package starling.utils
{
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class VertexData
   {
      public static const ELEMENTS_PER_VERTEX:int = 8;
      
      public static const POSITION_OFFSET:int = 0;
      
      public static const COLOR_OFFSET:int = 2;
      
      public static const TEXCOORD_OFFSET:int = 6;
      
      private static var sHelperPoint:Point = new Point();
      
      private var mRawData:Vector.<Number>;
      
      private var mPremultipliedAlpha:Boolean;
      
      private var mNumVertices:int;
      
      public function VertexData(param1:int, param2:Boolean = false)
      {
         super();
         this.mRawData = new Vector.<Number>(0);
         this.mPremultipliedAlpha = param2;
         this.numVertices = param1;
      }
      
      public function clone(param1:int = 0, param2:int = -1) : VertexData
      {
         if(param2 < 0 || param1 + param2 > this.mNumVertices)
         {
            param2 = this.mNumVertices - param1;
         }
         var _loc3_:VertexData = new VertexData(0,this.mPremultipliedAlpha);
         _loc3_.mNumVertices = param2;
         _loc3_.mRawData = this.mRawData.slice(param1 * ELEMENTS_PER_VERTEX,param2 * ELEMENTS_PER_VERTEX);
         _loc3_.mRawData.fixed = true;
         return _loc3_;
      }
      
      public function copyTo(param1:VertexData, param2:int = 0, param3:int = 0, param4:int = -1) : void
      {
         if(param4 < 0 || param3 + param4 > this.mNumVertices)
         {
            param4 = this.mNumVertices - param3;
         }
         var _loc5_:Vector.<Number> = param1.mRawData;
         var _loc6_:int = param2 * ELEMENTS_PER_VERTEX;
         var _loc7_:int = param3 * ELEMENTS_PER_VERTEX;
         var _loc8_:int = param4 * ELEMENTS_PER_VERTEX;
         var _loc9_:int = _loc7_;
         while(_loc9_ < _loc8_)
         {
            var _loc10_:*;
            _loc5_[_loc10_ = _loc6_++] = this.mRawData[_loc9_];
            _loc9_++;
         }
      }
      
      public function append(param1:VertexData) : void
      {
         this.mRawData.fixed = false;
         var _loc2_:Vector.<Number> = param1.mRawData;
         var _loc3_:int = int(_loc2_.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            this.mRawData.push(_loc2_[_loc4_]);
            _loc4_++;
         }
         this.mNumVertices += param1.numVertices;
         this.mRawData.fixed = true;
      }
      
      public function setPosition(param1:int, param2:Number, param3:Number) : void
      {
         var _loc4_:int = this.getOffset(param1) + POSITION_OFFSET;
         this.mRawData[_loc4_] = param2;
         this.mRawData[int(_loc4_ + 1)] = param3;
      }
      
      public function getPosition(param1:int, param2:Point) : void
      {
         var _loc3_:int = this.getOffset(param1) + POSITION_OFFSET;
         param2.x = this.mRawData[_loc3_];
         param2.y = this.mRawData[int(_loc3_ + 1)];
      }
      
      public function setColor(param1:int, param2:uint) : void
      {
         var _loc3_:int = this.getOffset(param1) + COLOR_OFFSET;
         var _loc4_:Number = this.mPremultipliedAlpha ? this.mRawData[int(_loc3_ + 3)] : 1;
         this.mRawData[_loc3_] = (param2 >> 16 & 0xFF) / 255 * _loc4_;
         this.mRawData[int(_loc3_ + 1)] = (param2 >> 8 & 0xFF) / 255 * _loc4_;
         this.mRawData[int(_loc3_ + 2)] = (param2 & 0xFF) / 255 * _loc4_;
      }
      
      public function getColor(param1:int) : uint
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc2_:int = this.getOffset(param1) + COLOR_OFFSET;
         var _loc3_:Number = this.mPremultipliedAlpha ? this.mRawData[_loc2_ + 3] : 1;
         if(_loc3_ == 0)
         {
            return 0;
         }
         _loc4_ = this.mRawData[_loc2_] / _loc3_;
         _loc5_ = this.mRawData[int(_loc2_ + 1)] / _loc3_;
         _loc6_ = this.mRawData[int(_loc2_ + 2)] / _loc3_;
         return int(_loc4_ * 255) << 16 | int(_loc5_ * 255) << 8 | int(_loc6_ * 255);
      }
      
      public function setAlpha(param1:int, param2:Number) : void
      {
         var _loc4_:uint = 0;
         var _loc3_:int = this.getOffset(param1) + COLOR_OFFSET + 3;
         if(this.mPremultipliedAlpha)
         {
            if(param2 < 0.001)
            {
               param2 = 0.001;
            }
            _loc4_ = this.getColor(param1);
            this.mRawData[_loc3_] = param2;
            this.setColor(param1,_loc4_);
         }
         else
         {
            this.mRawData[_loc3_] = param2;
         }
      }
      
      public function getAlpha(param1:int) : Number
      {
         var _loc2_:int = this.getOffset(param1) + COLOR_OFFSET + 3;
         return this.mRawData[_loc2_];
      }
      
      public function setTexCoords(param1:int, param2:Number, param3:Number) : void
      {
         var _loc4_:int = this.getOffset(param1) + TEXCOORD_OFFSET;
         this.mRawData[_loc4_] = param2;
         this.mRawData[int(_loc4_ + 1)] = param3;
      }
      
      public function getTexCoords(param1:int, param2:Point) : void
      {
         var _loc3_:int = this.getOffset(param1) + TEXCOORD_OFFSET;
         param2.x = this.mRawData[_loc3_];
         param2.y = this.mRawData[int(_loc3_ + 1)];
      }
      
      public function translateVertex(param1:int, param2:Number, param3:Number) : void
      {
         var _loc4_:int = this.getOffset(param1) + POSITION_OFFSET;
         this.mRawData[_loc4_] += param2;
         this.mRawData[int(_loc4_ + 1)] = this.mRawData[int(_loc4_ + 1)] + param3;
      }
      
      public function transformVertex(param1:int, param2:Matrix, param3:int = 1) : void
      {
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc4_:int = this.getOffset(param1) + POSITION_OFFSET;
         var _loc5_:int = 0;
         while(_loc5_ < param3)
         {
            _loc6_ = this.mRawData[_loc4_];
            _loc7_ = this.mRawData[int(_loc4_ + 1)];
            this.mRawData[_loc4_] = param2.a * _loc6_ + param2.c * _loc7_ + param2.tx;
            this.mRawData[int(_loc4_ + 1)] = param2.d * _loc7_ + param2.b * _loc6_ + param2.ty;
            _loc4_ += ELEMENTS_PER_VERTEX;
            _loc5_++;
         }
      }
      
      public function setUniformColor(param1:uint) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.mNumVertices)
         {
            this.setColor(_loc2_,param1);
            _loc2_++;
         }
      }
      
      public function setUniformAlpha(param1:Number) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.mNumVertices)
         {
            this.setAlpha(_loc2_,param1);
            _loc2_++;
         }
      }
      
      public function scaleAlpha(param1:int, param2:Number, param3:int = 1) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(param2 == 1)
         {
            return;
         }
         if(param3 < 0 || param1 + param3 > this.mNumVertices)
         {
            param3 = this.mNumVertices - param1;
         }
         if(this.mPremultipliedAlpha)
         {
            _loc4_ = 0;
            while(_loc4_ < param3)
            {
               this.setAlpha(param1 + _loc4_,this.getAlpha(param1 + _loc4_) * param2);
               _loc4_++;
            }
         }
         else
         {
            _loc5_ = this.getOffset(param1) + COLOR_OFFSET + 3;
            _loc4_ = 0;
            while(_loc4_ < param3)
            {
               this.mRawData[int(_loc5_ + _loc4_ * ELEMENTS_PER_VERTEX)] = this.mRawData[int(_loc5_ + _loc4_ * ELEMENTS_PER_VERTEX)] * param2;
               _loc4_++;
            }
         }
      }
      
      private function getOffset(param1:int) : int
      {
         return param1 * ELEMENTS_PER_VERTEX;
      }
      
      public function getBounds(param1:Matrix = null, param2:int = 0, param3:int = -1, param4:Rectangle = null) : Rectangle
      {
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:int = 0;
         if(param4 == null)
         {
            param4 = new Rectangle();
         }
         if(param3 < 0 || param2 + param3 > this.mNumVertices)
         {
            param3 = this.mNumVertices - param2;
         }
         var _loc5_:Number = Number.MAX_VALUE;
         var _loc6_:Number = -Number.MAX_VALUE;
         var _loc7_:Number = Number.MAX_VALUE;
         var _loc8_:Number = -Number.MAX_VALUE;
         var _loc9_:int = this.getOffset(param2) + POSITION_OFFSET;
         if(param1 == null)
         {
            _loc12_ = param2;
            while(_loc12_ < param3)
            {
               _loc10_ = this.mRawData[_loc9_];
               _loc11_ = this.mRawData[int(_loc9_ + 1)];
               _loc9_ += ELEMENTS_PER_VERTEX;
               _loc5_ = _loc5_ < _loc10_ ? _loc5_ : _loc10_;
               _loc6_ = _loc6_ > _loc10_ ? _loc6_ : _loc10_;
               _loc7_ = _loc7_ < _loc11_ ? _loc7_ : _loc11_;
               _loc8_ = _loc8_ > _loc11_ ? _loc8_ : _loc11_;
               _loc12_++;
            }
         }
         else
         {
            _loc12_ = param2;
            while(_loc12_ < param3)
            {
               _loc10_ = this.mRawData[_loc9_];
               _loc11_ = this.mRawData[int(_loc9_ + 1)];
               _loc9_ += ELEMENTS_PER_VERTEX;
               MatrixUtil.transformCoords(param1,_loc10_,_loc11_,sHelperPoint);
               _loc5_ = _loc5_ < sHelperPoint.x ? _loc5_ : sHelperPoint.x;
               _loc6_ = _loc6_ > sHelperPoint.x ? _loc6_ : sHelperPoint.x;
               _loc7_ = _loc7_ < sHelperPoint.y ? _loc7_ : sHelperPoint.y;
               _loc8_ = _loc8_ > sHelperPoint.y ? _loc8_ : sHelperPoint.y;
               _loc12_++;
            }
         }
         param4.setTo(_loc5_,_loc7_,_loc6_ - _loc5_,_loc8_ - _loc7_);
         return param4;
      }
      
      public function get tinted() : Boolean
      {
         var _loc3_:int = 0;
         var _loc1_:int = COLOR_OFFSET;
         var _loc2_:int = 0;
         while(_loc2_ < this.mNumVertices)
         {
            _loc3_ = 0;
            while(_loc3_ < 4)
            {
               if(this.mRawData[int(_loc1_ + _loc3_)] != 1)
               {
                  return true;
               }
               _loc3_++;
            }
            _loc1_ += ELEMENTS_PER_VERTEX;
            _loc2_++;
         }
         return false;
      }
      
      public function setPremultipliedAlpha(param1:Boolean, param2:Boolean = true) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         if(param1 == this.mPremultipliedAlpha)
         {
            return;
         }
         if(param2)
         {
            _loc3_ = this.mNumVertices * ELEMENTS_PER_VERTEX;
            _loc4_ = COLOR_OFFSET;
            while(_loc4_ < _loc3_)
            {
               _loc5_ = this.mRawData[_loc4_ + 3];
               _loc6_ = this.mPremultipliedAlpha ? _loc5_ : 1;
               _loc7_ = param1 ? _loc5_ : 1;
               if(_loc6_ != 0)
               {
                  this.mRawData[_loc4_] = this.mRawData[_loc4_] / _loc6_ * _loc7_;
                  this.mRawData[int(_loc4_ + 1)] = this.mRawData[int(_loc4_ + 1)] / _loc6_ * _loc7_;
                  this.mRawData[int(_loc4_ + 2)] = this.mRawData[int(_loc4_ + 2)] / _loc6_ * _loc7_;
               }
               _loc4_ += ELEMENTS_PER_VERTEX;
            }
         }
         this.mPremultipliedAlpha = param1;
      }
      
      public function get premultipliedAlpha() : Boolean
      {
         return this.mPremultipliedAlpha;
      }
      
      public function get numVertices() : int
      {
         return this.mNumVertices;
      }
      
      public function set numVertices(param1:int) : void
      {
         var _loc2_:int = 0;
         this.mRawData.fixed = false;
         var _loc3_:int = param1 - this.mNumVertices;
         _loc2_ = 0;
         while(_loc2_ < _loc3_)
         {
            this.mRawData.push(0,0,0,0,0,1,0,0);
            _loc2_++;
         }
         _loc2_ = 0;
         while(_loc2_ < -(_loc3_ * ELEMENTS_PER_VERTEX))
         {
            this.mRawData.pop();
            _loc2_++;
         }
         this.mNumVertices = param1;
         this.mRawData.fixed = true;
      }
      
      public function get rawData() : Vector.<Number>
      {
         return this.mRawData;
      }
   }
}
