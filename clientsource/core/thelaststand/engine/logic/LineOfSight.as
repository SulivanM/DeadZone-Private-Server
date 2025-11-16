package thelaststand.engine.logic
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.BoundBox;
   import alternativa.engine3d.core.Object3D;
   import flash.geom.Vector3D;
   import thelaststand.engine.geom.LineSegment;
   import thelaststand.engine.scenes.Scene;
   
   public class LineOfSight
   {
      
      private var _line:LineSegment;
      
      public function LineOfSight()
      {
         super();
         this._line = new LineSegment();
      }
      
      public function dispose() : void
      {
         this._line.dispose();
         this._line = null;
      }
      
      public function sqDistPointAABB(param1:Vector3D, param2:BoundBox) : Number
      {
         var _loc3_:Number = 0;
         if(param1.x < param2.minX)
         {
            _loc3_ += (param2.minX - param1.x) * (param2.minX - param1.x);
         }
         if(param1.x > param2.maxX)
         {
            _loc3_ += (param1.x - param2.maxX) * (param1.x - param2.maxX);
         }
         if(param1.y < param2.minY)
         {
            _loc3_ += (param2.minY - param1.y) * (param2.minY - param1.y);
         }
         if(param1.y > param2.maxY)
         {
            _loc3_ += (param1.y - param2.maxY) * (param1.y - param2.maxY);
         }
         if(param1.z < param2.minZ)
         {
            _loc3_ += (param2.minZ - param1.z) * (param2.minZ - param1.z);
         }
         if(param1.z > param2.maxZ)
         {
            _loc3_ += (param1.z - param2.maxZ) * (param1.z - param2.maxZ);
         }
         return _loc3_;
      }
      
      public function testSphereToBounds(param1:Vector3D, param2:Number, param3:BoundBox) : Boolean
      {
         return this.sqDistPointAABB(param1,param3) <= param2 * param2;
      }
      
      public function isPointVisible(param1:Scene, param2:Vector3D, param3:Vector3D, param4:uint = 1048575) : Boolean
      {
         var _loc8_:Object3D = null;
         var _loc9_:Boolean = false;
         var _loc10_:uint = 0;
         var _loc11_:Object3D = null;
         var _loc5_:Vector.<Object3D> = param1.losObjects;
         var _loc6_:int = int(_loc5_.length);
         var _loc7_:int = 0;
         while(_loc7_ < _loc6_)
         {
            _loc8_ = _loc5_[_loc7_];
            _loc9_ = false;
            _loc10_ = uint(_loc8_.userData.losFlags);
            if(!(_loc10_ != 0 && (_loc10_ & param4) == 0))
            {
               _loc11_ = _loc8_.alternativa3d::childrenList;
               while(_loc11_ != null)
               {
                  _loc9_ = true;
                  this._line.start = param2;
                  this._line.end = param3;
                  if(this._line.intersectsObject3D(_loc11_))
                  {
                     return false;
                  }
                  _loc11_ = _loc11_.alternativa3d::next;
               }
               if(!_loc9_)
               {
                  this._line.start = param2;
                  this._line.end = param3;
                  if(this._line.intersectsObject3D(_loc8_))
                  {
                     return false;
                  }
               }
            }
            _loc7_++;
         }
         return true;
      }
      
      public function rayCastHit(param1:Scene, param2:Vector3D, param3:Vector3D, param4:uint = 1048575) : Object3D
      {
         var _loc8_:Object3D = null;
         var _loc9_:Boolean = false;
         var _loc10_:uint = 0;
         var _loc11_:Object3D = null;
         var _loc5_:Vector.<Object3D> = param1.losObjects;
         var _loc6_:int = int(_loc5_.length);
         var _loc7_:int = 0;
         while(_loc7_ < _loc6_)
         {
            _loc8_ = _loc5_[_loc7_];
            _loc9_ = false;
            _loc10_ = uint(_loc8_.userData.losFlags);
            if(!(_loc10_ != 0 && (_loc10_ & param4) == 0))
            {
               _loc11_ = _loc8_.alternativa3d::childrenList;
               while(_loc11_ != null)
               {
                  _loc9_ = true;
                  this._line.start = param2;
                  this._line.end = param3;
                  if(this._line.intersectsObject3D(_loc11_))
                  {
                     return _loc8_;
                  }
                  _loc11_ = _loc11_.alternativa3d::next;
               }
               if(!_loc9_)
               {
                  this._line.start = param2;
                  this._line.end = param3;
                  if(this._line.intersectsObject3D(_loc8_))
                  {
                     return _loc8_;
                  }
               }
            }
            _loc7_++;
         }
         return null;
      }
      
      public function isPointVisible2(param1:Scene, param2:Vector3D, param3:Vector3D, param4:Number) : Boolean
      {
         var _loc7_:Number = NaN;
         var _loc9_:Object3D = null;
         var _loc10_:Boolean = false;
         var _loc11_:Object3D = null;
         var _loc5_:Vector.<Object3D> = param1.losObjects;
         var _loc6_:int = int(_loc5_.length);
         var _loc8_:int = 0;
         while(_loc8_ < _loc6_)
         {
            _loc9_ = _loc5_[_loc8_];
            _loc10_ = false;
            _loc11_ = _loc9_.alternativa3d::childrenList;
            while(_loc11_ != null)
            {
               _loc10_ = true;
               this._line.start = param2;
               this._line.end = param3;
               _loc7_ = _loc11_.boundBox.maxZ - _loc11_.boundBox.minZ;
               if(_loc7_ >= param4)
               {
                  if(this._line.intersectsObject3D(_loc11_))
                  {
                     return false;
                  }
               }
               _loc11_ = _loc11_.alternativa3d::next;
            }
            if(!_loc10_)
            {
               _loc7_ = _loc9_.boundBox.maxZ - _loc9_.boundBox.minZ;
               if(_loc7_ >= param4)
               {
                  this._line.start = param2;
                  this._line.end = param3;
                  if(this._line.intersectsObject3D(_loc9_))
                  {
                     return false;
                  }
               }
            }
            _loc8_++;
         }
         return true;
      }
   }
}

