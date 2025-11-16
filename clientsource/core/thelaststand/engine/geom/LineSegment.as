package thelaststand.engine.geom
{
   import alternativa.engine3d.core.BoundBox;
   import alternativa.engine3d.core.Object3D;
   import flash.geom.Vector3D;
   
   public class LineSegment
   {
      
      private const EPSILON:Number = 0.000001;
      
      private var _tmpVec1:Vector3D;
      
      private var _tmpVec2:Vector3D;
      
      public var start:Vector3D;
      
      public var end:Vector3D;
      
      public function LineSegment(param1:Vector3D = null, param2:Vector3D = null)
      {
         super();
         this.start = param1;
         this.end = param2;
         this._tmpVec1 = new Vector3D();
         this._tmpVec2 = new Vector3D();
      }
      
      public function dispose() : void
      {
         this._tmpVec1 = null;
         this._tmpVec2 = null;
         this.start = null;
         this.end = null;
      }
      
      public function getIntersectionObject3D(param1:Object3D, param2:BoundBox = null) : Vector3D
      {
         var _loc3_:Number = this.testSegmentAABB2(param1.globalToLocal(this.start,this._tmpVec1),param1.globalToLocal(this.end,this._tmpVec2),param2 || param1.boundBox);
         if(_loc3_ == -1)
         {
            return null;
         }
         return new Vector3D(this.start.x + (this.end.x - this.start.x) * _loc3_,this.start.y + (this.end.y - this.start.y) * _loc3_,this.start.z + (this.end.z - this.start.z) * _loc3_);
      }
      
      public function intersectsObject3D(param1:Object3D) : Boolean
      {
         if(param1.boundBox == null)
         {
            return false;
         }
         return this.testSegmentAABB(param1.globalToLocal(this.start,this._tmpVec1),param1.globalToLocal(this.end,this._tmpVec2),param1.boundBox);
      }
      
      public function getDirection() : Vector3D
      {
         var _loc1_:Vector3D = new Vector3D(this.end.x - this.start.x,this.end.y - this.start.y,this.end.z - this.start.z);
         _loc1_.normalize();
         return _loc1_;
      }
      
      public function testSegmentAABB(param1:Vector3D, param2:Vector3D, param3:BoundBox) : Boolean
      {
         var _loc4_:Number = param3.maxX - param3.minX;
         var _loc5_:Number = param3.maxY - param3.minY;
         var _loc6_:Number = param3.maxZ - param3.minZ;
         var _loc7_:Number = param2.x - param1.x;
         var _loc8_:Number = param2.y - param1.y;
         var _loc9_:Number = param2.z - param1.z;
         var _loc10_:Number = param1.x + param2.x - param3.minX - param3.maxX;
         var _loc11_:Number = param1.y + param2.y - param3.minY - param3.maxY;
         var _loc12_:Number = param1.z + param2.z - param3.minZ - param3.maxZ;
         var _loc13_:Number = _loc7_ < 0 ? -_loc7_ : _loc7_;
         if(this.abs(_loc10_) > _loc4_ + _loc13_)
         {
            return false;
         }
         var _loc14_:Number = _loc8_ < 0 ? -_loc8_ : _loc8_;
         if(this.abs(_loc11_) > _loc5_ + _loc14_)
         {
            return false;
         }
         var _loc15_:Number = _loc9_ < 0 ? -_loc9_ : _loc9_;
         if(this.abs(_loc12_) > _loc6_ + _loc15_)
         {
            return false;
         }
         _loc13_ += this.EPSILON;
         _loc14_ += this.EPSILON;
         _loc15_ += this.EPSILON;
         if(this.abs(_loc11_ * _loc9_ - _loc12_ * _loc8_) > _loc5_ * _loc15_ + _loc6_ * _loc14_)
         {
            return false;
         }
         if(this.abs(_loc12_ * _loc7_ - _loc10_ * _loc9_) > _loc4_ * _loc15_ + _loc6_ * _loc13_)
         {
            return false;
         }
         if(this.abs(_loc10_ * _loc8_ - _loc11_ * _loc7_) > _loc4_ * _loc14_ + _loc5_ * _loc13_)
         {
            return false;
         }
         return true;
      }
      
      private function testSegmentAABB2(param1:Vector3D, param2:Vector3D, param3:BoundBox) : Number
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = 0;
         var _loc8_:Number = 1;
         _loc4_ = param2.x - param1.x;
         if(param1.x < param2.x)
         {
            if(param1.x > param3.maxX || param2.x < param3.minX)
            {
               return -1;
            }
            _loc5_ = param1.x < param3.minX ? (param3.minX - param1.x) / _loc4_ : 0;
            _loc6_ = param2.x > param3.maxX ? (param3.maxX - param1.x) / _loc4_ : 1;
         }
         else
         {
            if(param2.x > param3.maxX || param1.x < param3.minX)
            {
               return -1;
            }
            _loc5_ = param1.x > param3.maxX ? (param3.maxX - param1.x) / _loc4_ : 0;
            _loc6_ = param2.x < param3.minX ? (param3.minX - param1.x) / _loc4_ : 1;
         }
         if(_loc5_ > _loc7_)
         {
            _loc7_ = _loc5_;
         }
         if(_loc6_ < _loc8_)
         {
            _loc8_ = _loc6_;
         }
         _loc4_ = param2.y - param1.y;
         if(param1.y < param2.y)
         {
            if(param1.y > param3.maxY || param2.y < param3.minY)
            {
               return -1;
            }
            _loc5_ = param1.y < param3.minY ? (param3.minY - param1.y) / _loc4_ : 0;
            _loc6_ = param2.y > param3.maxY ? (param3.maxY - param1.y) / _loc4_ : 1;
         }
         else
         {
            if(param2.y > param3.maxY || param1.y < param3.minY)
            {
               return -1;
            }
            _loc5_ = param1.y > param3.maxY ? (param3.maxY - param1.y) / _loc4_ : 0;
            _loc6_ = param2.y < param3.minY ? (param3.minY - param1.y) / _loc4_ : 1;
         }
         if(_loc5_ > _loc7_)
         {
            _loc7_ = _loc5_;
         }
         if(_loc6_ < _loc8_)
         {
            _loc8_ = _loc6_;
         }
         _loc4_ = param2.z - param1.z;
         if(param1.z < param2.z)
         {
            if(param1.z > param3.maxZ || param2.z < param3.minZ)
            {
               return -1;
            }
            _loc5_ = param1.z < param3.minZ ? (param3.minZ - param1.z) / _loc4_ : 0;
            _loc6_ = param2.z > param3.maxZ ? (param3.maxZ - param1.z) / _loc4_ : 1;
         }
         else
         {
            if(param2.z > param3.maxZ || param1.z < param3.minZ)
            {
               return -1;
            }
            _loc5_ = param1.z > param3.maxZ ? (param3.maxZ - param1.z) / _loc4_ : 0;
            _loc6_ = param2.z < param3.minZ ? (param3.minZ - param1.z) / _loc4_ : 1;
         }
         if(_loc5_ > _loc7_)
         {
            _loc7_ = _loc5_;
         }
         if(_loc6_ < _loc8_)
         {
            _loc8_ = _loc6_;
         }
         return _loc8_ < _loc7_ ? -1 : _loc7_;
      }
      
      private function abs(param1:Number) : Number
      {
         return param1 < 0 ? -param1 : param1;
      }
   }
}

