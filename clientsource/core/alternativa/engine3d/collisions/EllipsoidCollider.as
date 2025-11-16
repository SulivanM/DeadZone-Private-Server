package alternativa.engine3d.collisions
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.*;
   import alternativa.engine3d.resources.Geometry;
   import flash.geom.Vector3D;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   
   use namespace alternativa3d;
   
   public class EllipsoidCollider
   {
      
      public var radiusX:Number;
      
      public var radiusY:Number;
      
      public var radiusZ:Number;
      
      public var threshold:Number = 0.001;
      
      private var matrix:Transform3D = new Transform3D();
      
      private var inverseMatrix:Transform3D = new Transform3D();
      
      alternativa3d var geometries:Vector.<Geometry> = new Vector.<Geometry>();
      
      alternativa3d var transforms:Vector.<Transform3D> = new Vector.<Transform3D>();
      
      private var vertices:Vector.<Number> = new Vector.<Number>();
      
      private var normals:Vector.<Number> = new Vector.<Number>();
      
      private var indices:Vector.<int> = new Vector.<int>();
      
      private var numTriangles:int;
      
      private var radius:Number;
      
      private var src:Vector3D = new Vector3D();
      
      private var displ:Vector3D = new Vector3D();
      
      private var dest:Vector3D = new Vector3D();
      
      private var collisionPoint:Vector3D = new Vector3D();
      
      private var collisionPlane:Vector3D = new Vector3D();
      
      alternativa3d var sphere:Vector3D = new Vector3D();
      
      private var cornerA:Vector3D = new Vector3D();
      
      private var cornerB:Vector3D = new Vector3D();
      
      private var cornerC:Vector3D = new Vector3D();
      
      private var cornerD:Vector3D = new Vector3D();
      
      public function EllipsoidCollider(param1:Number, param2:Number, param3:Number)
      {
         super();
         this.radiusX = param1;
         this.radiusY = param2;
         this.radiusZ = param3;
      }
      
      alternativa3d function calculateSphere(param1:Transform3D) : void
      {
         this.alternativa3d::sphere.x = param1.d;
         this.alternativa3d::sphere.y = param1.h;
         this.alternativa3d::sphere.z = param1.l;
         var _loc2_:Number = param1.a * this.cornerA.x + param1.b * this.cornerA.y + param1.c * this.cornerA.z + param1.d;
         var _loc3_:Number = param1.e * this.cornerA.x + param1.f * this.cornerA.y + param1.g * this.cornerA.z + param1.h;
         var _loc4_:Number = param1.i * this.cornerA.x + param1.j * this.cornerA.y + param1.k * this.cornerA.z + param1.l;
         var _loc5_:Number = param1.a * this.cornerB.x + param1.b * this.cornerB.y + param1.c * this.cornerB.z + param1.d;
         var _loc6_:Number = param1.e * this.cornerB.x + param1.f * this.cornerB.y + param1.g * this.cornerB.z + param1.h;
         var _loc7_:Number = param1.i * this.cornerB.x + param1.j * this.cornerB.y + param1.k * this.cornerB.z + param1.l;
         var _loc8_:Number = param1.a * this.cornerC.x + param1.b * this.cornerC.y + param1.c * this.cornerC.z + param1.d;
         var _loc9_:Number = param1.e * this.cornerC.x + param1.f * this.cornerC.y + param1.g * this.cornerC.z + param1.h;
         var _loc10_:Number = param1.i * this.cornerC.x + param1.j * this.cornerC.y + param1.k * this.cornerC.z + param1.l;
         var _loc11_:Number = param1.a * this.cornerD.x + param1.b * this.cornerD.y + param1.c * this.cornerD.z + param1.d;
         var _loc12_:Number = param1.e * this.cornerD.x + param1.f * this.cornerD.y + param1.g * this.cornerD.z + param1.h;
         var _loc13_:Number = param1.i * this.cornerD.x + param1.j * this.cornerD.y + param1.k * this.cornerD.z + param1.l;
         var _loc14_:Number = _loc2_ - this.alternativa3d::sphere.x;
         var _loc15_:Number = _loc3_ - this.alternativa3d::sphere.y;
         var _loc16_:Number = _loc4_ - this.alternativa3d::sphere.z;
         this.alternativa3d::sphere.w = _loc14_ * _loc14_ + _loc15_ * _loc15_ + _loc16_ * _loc16_;
         _loc14_ = _loc5_ - this.alternativa3d::sphere.x;
         _loc15_ = _loc6_ - this.alternativa3d::sphere.y;
         _loc16_ = _loc7_ - this.alternativa3d::sphere.z;
         var _loc17_:Number = _loc14_ * _loc14_ + _loc15_ * _loc15_ + _loc16_ * _loc16_;
         if(_loc17_ > this.alternativa3d::sphere.w)
         {
            this.alternativa3d::sphere.w = _loc17_;
         }
         _loc14_ = _loc8_ - this.alternativa3d::sphere.x;
         _loc15_ = _loc9_ - this.alternativa3d::sphere.y;
         _loc16_ = _loc10_ - this.alternativa3d::sphere.z;
         _loc17_ = _loc14_ * _loc14_ + _loc15_ * _loc15_ + _loc16_ * _loc16_;
         if(_loc17_ > this.alternativa3d::sphere.w)
         {
            this.alternativa3d::sphere.w = _loc17_;
         }
         _loc14_ = _loc11_ - this.alternativa3d::sphere.x;
         _loc15_ = _loc12_ - this.alternativa3d::sphere.y;
         _loc16_ = _loc13_ - this.alternativa3d::sphere.z;
         _loc17_ = _loc14_ * _loc14_ + _loc15_ * _loc15_ + _loc16_ * _loc16_;
         if(_loc17_ > this.alternativa3d::sphere.w)
         {
            this.alternativa3d::sphere.w = _loc17_;
         }
         this.alternativa3d::sphere.w = Math.sqrt(this.alternativa3d::sphere.w);
      }
      
      private function prepare(param1:Vector3D, param2:Vector3D, param3:Object3D, param4:Dictionary) : void
      {
         var _loc8_:int = 0;
         var _loc13_:Boolean = false;
         var _loc14_:Geometry = null;
         var _loc15_:Transform3D = null;
         var _loc16_:int = 0;
         var _loc17_:VertexStream = null;
         var _loc18_:Vector.<uint> = null;
         var _loc19_:int = 0;
         var _loc20_:int = 0;
         var _loc21_:ByteArray = null;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc25_:int = 0;
         var _loc26_:int = 0;
         var _loc27_:Number = NaN;
         var _loc28_:Number = NaN;
         var _loc29_:Number = NaN;
         var _loc30_:int = 0;
         var _loc31_:Number = NaN;
         var _loc32_:Number = NaN;
         var _loc33_:Number = NaN;
         var _loc34_:int = 0;
         var _loc35_:Number = NaN;
         var _loc36_:Number = NaN;
         var _loc37_:Number = NaN;
         var _loc38_:Number = NaN;
         var _loc39_:Number = NaN;
         var _loc40_:Number = NaN;
         var _loc41_:Number = NaN;
         var _loc42_:Number = NaN;
         var _loc43_:Number = NaN;
         var _loc44_:Number = NaN;
         var _loc45_:Number = NaN;
         var _loc46_:Number = NaN;
         var _loc47_:Number = NaN;
         var _loc48_:Number = NaN;
         this.radius = this.radiusX;
         if(this.radiusY > this.radius)
         {
            this.radius = this.radiusY;
         }
         if(this.radiusZ > this.radius)
         {
            this.radius = this.radiusZ;
         }
         this.matrix.compose(param1.x,param1.y,param1.z,0,0,0,this.radiusX / this.radius,this.radiusY / this.radius,this.radiusZ / this.radius);
         this.inverseMatrix.copy(this.matrix);
         this.inverseMatrix.invert();
         this.src.x = 0;
         this.src.y = 0;
         this.src.z = 0;
         this.displ.x = this.inverseMatrix.a * param2.x + this.inverseMatrix.b * param2.y + this.inverseMatrix.c * param2.z;
         this.displ.y = this.inverseMatrix.e * param2.x + this.inverseMatrix.f * param2.y + this.inverseMatrix.g * param2.z;
         this.displ.z = this.inverseMatrix.i * param2.x + this.inverseMatrix.j * param2.y + this.inverseMatrix.k * param2.z;
         this.dest.x = this.src.x + this.displ.x;
         this.dest.y = this.src.y + this.displ.y;
         this.dest.z = this.src.z + this.displ.z;
         var _loc5_:Number = this.radius + this.displ.length;
         this.cornerA.x = -_loc5_;
         this.cornerA.y = -_loc5_;
         this.cornerA.z = -_loc5_;
         this.cornerB.x = _loc5_;
         this.cornerB.y = -_loc5_;
         this.cornerB.z = -_loc5_;
         this.cornerC.x = _loc5_;
         this.cornerC.y = _loc5_;
         this.cornerC.z = -_loc5_;
         this.cornerD.x = -_loc5_;
         this.cornerD.y = _loc5_;
         this.cornerD.z = -_loc5_;
         if(param4 == null || !param4[param3])
         {
            if(param3.alternativa3d::transformChanged)
            {
               param3.alternativa3d::composeTransforms();
            }
            param3.alternativa3d::globalToLocalTransform.combine(param3.alternativa3d::inverseTransform,this.matrix);
            _loc13_ = true;
            if(param3.boundBox != null)
            {
               this.alternativa3d::calculateSphere(param3.alternativa3d::globalToLocalTransform);
               _loc13_ = param3.boundBox.alternativa3d::checkSphere(this.alternativa3d::sphere);
            }
            if(_loc13_)
            {
               param3.alternativa3d::localToGlobalTransform.combine(this.inverseMatrix,param3.alternativa3d::transform);
               param3.alternativa3d::collectGeometry(this,param4);
            }
            if(param3.alternativa3d::childrenList != null)
            {
               param3.alternativa3d::collectChildrenGeometry(this,param4);
            }
         }
         this.numTriangles = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = int(this.alternativa3d::geometries.length);
         var _loc12_:int = 0;
         while(_loc12_ < _loc11_)
         {
            _loc14_ = this.alternativa3d::geometries[_loc12_];
            _loc15_ = this.alternativa3d::transforms[_loc12_];
            _loc16_ = int(_loc14_.alternativa3d::_indices.length);
            if(!(_loc14_.alternativa3d::_numVertices == 0 || _loc16_ == 0))
            {
               _loc17_ = VertexAttributes.POSITION < _loc14_.alternativa3d::_attributesStreams.length ? _loc14_.alternativa3d::_attributesStreams[VertexAttributes.POSITION] : null;
               if(_loc17_ != null)
               {
                  _loc19_ = _loc14_.alternativa3d::_attributesOffsets[VertexAttributes.POSITION];
                  _loc20_ = int(_loc17_.attributes.length);
                  _loc21_ = _loc17_.data;
                  _loc8_ = 0;
                  while(_loc8_ < _loc14_.alternativa3d::_numVertices)
                  {
                     _loc21_.position = 4 * (_loc20_ * _loc8_ + _loc19_);
                     _loc22_ = _loc21_.readFloat();
                     _loc23_ = _loc21_.readFloat();
                     _loc24_ = _loc21_.readFloat();
                     this.vertices[_loc10_] = _loc15_.a * _loc22_ + _loc15_.b * _loc23_ + _loc15_.c * _loc24_ + _loc15_.d;
                     _loc10_++;
                     this.vertices[_loc10_] = _loc15_.e * _loc22_ + _loc15_.f * _loc23_ + _loc15_.g * _loc24_ + _loc15_.h;
                     _loc10_++;
                     this.vertices[_loc10_] = _loc15_.i * _loc22_ + _loc15_.j * _loc23_ + _loc15_.k * _loc24_ + _loc15_.l;
                     _loc10_++;
                     _loc8_++;
                  }
               }
               _loc18_ = _loc14_.alternativa3d::_indices;
               _loc8_ = 0;
               while(_loc8_ < _loc16_)
               {
                  _loc25_ = _loc18_[_loc8_] + _loc9_;
                  _loc8_++;
                  _loc26_ = _loc25_ * 3;
                  _loc27_ = this.vertices[_loc26_];
                  _loc26_++;
                  _loc28_ = this.vertices[_loc26_];
                  _loc26_++;
                  _loc29_ = this.vertices[_loc26_];
                  _loc30_ = _loc18_[_loc8_] + _loc9_;
                  _loc8_++;
                  _loc26_ = _loc30_ * 3;
                  _loc31_ = this.vertices[_loc26_];
                  _loc26_++;
                  _loc32_ = this.vertices[_loc26_];
                  _loc26_++;
                  _loc33_ = this.vertices[_loc26_];
                  _loc34_ = _loc18_[_loc8_] + _loc9_;
                  _loc8_++;
                  _loc26_ = _loc34_ * 3;
                  _loc35_ = this.vertices[_loc26_];
                  _loc26_++;
                  _loc36_ = this.vertices[_loc26_];
                  _loc26_++;
                  _loc37_ = this.vertices[_loc26_];
                  if(!(_loc27_ > _loc5_ && _loc31_ > _loc5_ && _loc35_ > _loc5_ || _loc27_ < -_loc5_ && _loc31_ < -_loc5_ && _loc35_ < -_loc5_))
                  {
                     if(!(_loc28_ > _loc5_ && _loc32_ > _loc5_ && _loc36_ > _loc5_ || _loc28_ < -_loc5_ && _loc32_ < -_loc5_ && _loc36_ < -_loc5_))
                     {
                        if(!(_loc29_ > _loc5_ && _loc33_ > _loc5_ && _loc37_ > _loc5_ || _loc29_ < -_loc5_ && _loc33_ < -_loc5_ && _loc37_ < -_loc5_))
                        {
                           _loc38_ = _loc31_ - _loc27_;
                           _loc39_ = _loc32_ - _loc28_;
                           _loc40_ = _loc33_ - _loc29_;
                           _loc41_ = _loc35_ - _loc27_;
                           _loc42_ = _loc36_ - _loc28_;
                           _loc43_ = _loc37_ - _loc29_;
                           _loc44_ = _loc43_ * _loc39_ - _loc42_ * _loc40_;
                           _loc45_ = _loc41_ * _loc40_ - _loc43_ * _loc38_;
                           _loc46_ = _loc42_ * _loc38_ - _loc41_ * _loc39_;
                           _loc47_ = _loc44_ * _loc44_ + _loc45_ * _loc45_ + _loc46_ * _loc46_;
                           if(_loc47_ >= 0.001)
                           {
                              _loc47_ = 1 / Math.sqrt(_loc47_);
                              _loc44_ *= _loc47_;
                              _loc45_ *= _loc47_;
                              _loc46_ *= _loc47_;
                              _loc48_ = _loc27_ * _loc44_ + _loc28_ * _loc45_ + _loc29_ * _loc46_;
                              if(!(_loc48_ > _loc5_ || _loc48_ < -_loc5_))
                              {
                                 this.indices[_loc6_] = _loc25_;
                                 _loc6_++;
                                 this.indices[_loc6_] = _loc30_;
                                 _loc6_++;
                                 this.indices[_loc6_] = _loc34_;
                                 _loc6_++;
                                 this.normals[_loc7_] = _loc44_;
                                 _loc7_++;
                                 this.normals[_loc7_] = _loc45_;
                                 _loc7_++;
                                 this.normals[_loc7_] = _loc46_;
                                 _loc7_++;
                                 this.normals[_loc7_] = _loc48_;
                                 _loc7_++;
                                 ++this.numTriangles;
                              }
                           }
                        }
                     }
                  }
               }
               _loc9_ += _loc14_.alternativa3d::_numVertices;
            }
            _loc12_++;
         }
         this.alternativa3d::geometries.length = 0;
         this.alternativa3d::transforms.length = 0;
      }
      
      public function calculateDestination(param1:Vector3D, param2:Vector3D, param3:Object3D, param4:Dictionary = null) : Vector3D
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Number = NaN;
         if(param2.length <= this.threshold)
         {
            return param1.clone();
         }
         this.prepare(param1,param2,param3,param4);
         if(this.numTriangles > 0)
         {
            _loc5_ = 50;
            _loc6_ = 0;
            while(_loc6_ < _loc5_)
            {
               if(!this.checkCollision())
               {
                  break;
               }
               _loc7_ = this.radius + this.threshold + this.collisionPlane.w - this.dest.x * this.collisionPlane.x - this.dest.y * this.collisionPlane.y - this.dest.z * this.collisionPlane.z;
               this.dest.x += this.collisionPlane.x * _loc7_;
               this.dest.y += this.collisionPlane.y * _loc7_;
               this.dest.z += this.collisionPlane.z * _loc7_;
               this.src.x = this.collisionPoint.x + this.collisionPlane.x * (this.radius + this.threshold);
               this.src.y = this.collisionPoint.y + this.collisionPlane.y * (this.radius + this.threshold);
               this.src.z = this.collisionPoint.z + this.collisionPlane.z * (this.radius + this.threshold);
               this.displ.x = this.dest.x - this.src.x;
               this.displ.y = this.dest.y - this.src.y;
               this.displ.z = this.dest.z - this.src.z;
               if(this.displ.length < this.threshold)
               {
                  break;
               }
               _loc6_++;
            }
            return new Vector3D(this.matrix.a * this.dest.x + this.matrix.b * this.dest.y + this.matrix.c * this.dest.z + this.matrix.d,this.matrix.e * this.dest.x + this.matrix.f * this.dest.y + this.matrix.g * this.dest.z + this.matrix.h,this.matrix.i * this.dest.x + this.matrix.j * this.dest.y + this.matrix.k * this.dest.z + this.matrix.l);
         }
         return new Vector3D(param1.x + param2.x,param1.y + param2.y,param1.z + param2.z);
      }
      
      public function getCollision(param1:Vector3D, param2:Vector3D, param3:Vector3D, param4:Vector3D, param5:Object3D, param6:Dictionary = null) : Boolean
      {
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         if(param2.length <= this.threshold)
         {
            return false;
         }
         this.prepare(param1,param2,param5,param6);
         if(this.numTriangles > 0)
         {
            if(this.checkCollision())
            {
               param3.x = this.matrix.a * this.collisionPoint.x + this.matrix.b * this.collisionPoint.y + this.matrix.c * this.collisionPoint.z + this.matrix.d;
               param3.y = this.matrix.e * this.collisionPoint.x + this.matrix.f * this.collisionPoint.y + this.matrix.g * this.collisionPoint.z + this.matrix.h;
               param3.z = this.matrix.i * this.collisionPoint.x + this.matrix.j * this.collisionPoint.y + this.matrix.k * this.collisionPoint.z + this.matrix.l;
               if(this.collisionPlane.x < this.collisionPlane.y)
               {
                  if(this.collisionPlane.x < this.collisionPlane.z)
                  {
                     _loc7_ = 0;
                     _loc8_ = -this.collisionPlane.z;
                     _loc9_ = this.collisionPlane.y;
                  }
                  else
                  {
                     _loc7_ = -this.collisionPlane.y;
                     _loc8_ = this.collisionPlane.x;
                     _loc9_ = 0;
                  }
               }
               else if(this.collisionPlane.y < this.collisionPlane.z)
               {
                  _loc7_ = this.collisionPlane.z;
                  _loc8_ = 0;
                  _loc9_ = -this.collisionPlane.x;
               }
               else
               {
                  _loc7_ = -this.collisionPlane.y;
                  _loc8_ = this.collisionPlane.x;
                  _loc9_ = 0;
               }
               _loc10_ = this.collisionPlane.z * _loc8_ - this.collisionPlane.y * _loc9_;
               _loc11_ = this.collisionPlane.x * _loc9_ - this.collisionPlane.z * _loc7_;
               _loc12_ = this.collisionPlane.y * _loc7_ - this.collisionPlane.x * _loc8_;
               _loc13_ = this.matrix.a * _loc7_ + this.matrix.b * _loc8_ + this.matrix.c * _loc9_;
               _loc14_ = this.matrix.e * _loc7_ + this.matrix.f * _loc8_ + this.matrix.g * _loc9_;
               _loc15_ = this.matrix.i * _loc7_ + this.matrix.j * _loc8_ + this.matrix.k * _loc9_;
               _loc16_ = this.matrix.a * _loc10_ + this.matrix.b * _loc11_ + this.matrix.c * _loc12_;
               _loc17_ = this.matrix.e * _loc10_ + this.matrix.f * _loc11_ + this.matrix.g * _loc12_;
               _loc18_ = this.matrix.i * _loc10_ + this.matrix.j * _loc11_ + this.matrix.k * _loc12_;
               param4.x = _loc15_ * _loc17_ - _loc14_ * _loc18_;
               param4.y = _loc13_ * _loc18_ - _loc15_ * _loc16_;
               param4.z = _loc14_ * _loc16_ - _loc13_ * _loc17_;
               param4.normalize();
               param4.w = param3.x * param4.x + param3.y * param4.y + param3.z * param4.z;
               return true;
            }
            return false;
         }
         return false;
      }
      
      private function checkCollision() : Boolean
      {
         var _loc6_:int = 0;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc25_:Number = NaN;
         var _loc26_:Number = NaN;
         var _loc27_:Number = NaN;
         var _loc28_:Boolean = false;
         var _loc29_:int = 0;
         var _loc30_:Number = NaN;
         var _loc31_:Number = NaN;
         var _loc32_:Number = NaN;
         var _loc33_:Number = NaN;
         var _loc34_:Number = NaN;
         var _loc35_:Number = NaN;
         var _loc36_:Number = NaN;
         var _loc37_:Number = NaN;
         var _loc38_:Number = NaN;
         var _loc39_:Number = NaN;
         var _loc40_:Number = NaN;
         var _loc41_:Number = NaN;
         var _loc42_:Number = NaN;
         var _loc43_:Number = NaN;
         var _loc44_:Number = NaN;
         var _loc45_:Number = NaN;
         var _loc46_:Number = NaN;
         var _loc47_:Number = NaN;
         var _loc48_:Number = NaN;
         var _loc49_:Number = NaN;
         var _loc50_:Number = NaN;
         var _loc51_:Number = NaN;
         var _loc52_:Number = NaN;
         var _loc53_:Number = NaN;
         var _loc54_:Number = NaN;
         var _loc55_:Number = NaN;
         var _loc56_:Number = NaN;
         var _loc57_:Number = NaN;
         var _loc58_:Number = NaN;
         var _loc1_:Number = 1;
         var _loc2_:Number = this.displ.length;
         var _loc3_:int = this.numTriangles * 3;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc6_ = this.indices[_loc4_] * 3;
            _loc4_++;
            _loc7_ = this.vertices[_loc6_];
            _loc6_++;
            _loc8_ = this.vertices[_loc6_];
            _loc6_++;
            _loc9_ = this.vertices[_loc6_];
            _loc6_ = this.indices[_loc4_] * 3;
            _loc4_++;
            _loc10_ = this.vertices[_loc6_];
            _loc6_++;
            _loc11_ = this.vertices[_loc6_];
            _loc6_++;
            _loc12_ = this.vertices[_loc6_];
            _loc6_ = this.indices[_loc4_] * 3;
            _loc4_++;
            _loc13_ = this.vertices[_loc6_];
            _loc6_++;
            _loc14_ = this.vertices[_loc6_];
            _loc6_++;
            _loc15_ = this.vertices[_loc6_];
            _loc16_ = this.normals[_loc5_];
            _loc5_++;
            _loc17_ = this.normals[_loc5_];
            _loc5_++;
            _loc18_ = this.normals[_loc5_];
            _loc5_++;
            _loc19_ = this.normals[_loc5_];
            _loc5_++;
            _loc20_ = this.src.x * _loc16_ + this.src.y * _loc17_ + this.src.z * _loc18_ - _loc19_;
            if(_loc20_ < this.radius)
            {
               _loc21_ = this.src.x - _loc16_ * _loc20_;
               _loc22_ = this.src.y - _loc17_ * _loc20_;
               _loc23_ = this.src.z - _loc18_ * _loc20_;
            }
            else
            {
               _loc33_ = (_loc20_ - this.radius) / (_loc20_ - this.dest.x * _loc16_ - this.dest.y * _loc17_ - this.dest.z * _loc18_ + _loc19_);
               _loc21_ = this.src.x + this.displ.x * _loc33_ - _loc16_ * this.radius;
               _loc22_ = this.src.y + this.displ.y * _loc33_ - _loc17_ * this.radius;
               _loc23_ = this.src.z + this.displ.z * _loc33_ - _loc18_ * this.radius;
            }
            _loc27_ = 1e+22;
            _loc28_ = true;
            _loc29_ = 0;
            while(_loc29_ < 3)
            {
               if(_loc29_ == 0)
               {
                  _loc34_ = _loc7_;
                  _loc35_ = _loc8_;
                  _loc36_ = _loc9_;
                  _loc37_ = _loc10_;
                  _loc38_ = _loc11_;
                  _loc39_ = _loc12_;
               }
               else if(_loc29_ == 1)
               {
                  _loc34_ = _loc10_;
                  _loc35_ = _loc11_;
                  _loc36_ = _loc12_;
                  _loc37_ = _loc13_;
                  _loc38_ = _loc14_;
                  _loc39_ = _loc15_;
               }
               else
               {
                  _loc34_ = _loc13_;
                  _loc35_ = _loc14_;
                  _loc36_ = _loc15_;
                  _loc37_ = _loc7_;
                  _loc38_ = _loc8_;
                  _loc39_ = _loc9_;
               }
               _loc40_ = _loc37_ - _loc34_;
               _loc41_ = _loc38_ - _loc35_;
               _loc42_ = _loc39_ - _loc36_;
               _loc43_ = _loc21_ - _loc34_;
               _loc44_ = _loc22_ - _loc35_;
               _loc45_ = _loc23_ - _loc36_;
               _loc46_ = _loc45_ * _loc41_ - _loc44_ * _loc42_;
               _loc47_ = _loc43_ * _loc42_ - _loc45_ * _loc40_;
               _loc48_ = _loc44_ * _loc40_ - _loc43_ * _loc41_;
               if(_loc46_ * _loc16_ + _loc47_ * _loc17_ + _loc48_ * _loc18_ < 0)
               {
                  _loc49_ = _loc40_ * _loc40_ + _loc41_ * _loc41_ + _loc42_ * _loc42_;
                  _loc50_ = (_loc46_ * _loc46_ + _loc47_ * _loc47_ + _loc48_ * _loc48_) / _loc49_;
                  if(_loc50_ < _loc27_)
                  {
                     _loc49_ = Math.sqrt(_loc49_);
                     _loc40_ /= _loc49_;
                     _loc41_ /= _loc49_;
                     _loc42_ /= _loc49_;
                     _loc33_ = _loc40_ * _loc43_ + _loc41_ * _loc44_ + _loc42_ * _loc45_;
                     if(_loc33_ < 0)
                     {
                        _loc51_ = _loc43_ * _loc43_ + _loc44_ * _loc44_ + _loc45_ * _loc45_;
                        if(_loc51_ < _loc27_)
                        {
                           _loc27_ = _loc51_;
                           _loc24_ = _loc34_;
                           _loc25_ = _loc35_;
                           _loc26_ = _loc36_;
                        }
                     }
                     else if(_loc33_ > _loc49_)
                     {
                        _loc43_ = _loc21_ - _loc37_;
                        _loc44_ = _loc22_ - _loc38_;
                        _loc45_ = _loc23_ - _loc39_;
                        _loc51_ = _loc43_ * _loc43_ + _loc44_ * _loc44_ + _loc45_ * _loc45_;
                        if(_loc51_ < _loc27_)
                        {
                           _loc27_ = _loc51_;
                           _loc24_ = _loc37_;
                           _loc25_ = _loc38_;
                           _loc26_ = _loc39_;
                        }
                     }
                     else
                     {
                        _loc27_ = _loc50_;
                        _loc24_ = _loc34_ + _loc40_ * _loc33_;
                        _loc25_ = _loc35_ + _loc41_ * _loc33_;
                        _loc26_ = _loc36_ + _loc42_ * _loc33_;
                     }
                  }
                  _loc28_ = false;
               }
               _loc29_++;
            }
            if(_loc28_)
            {
               _loc24_ = _loc21_;
               _loc25_ = _loc22_;
               _loc26_ = _loc23_;
            }
            _loc30_ = this.src.x - _loc24_;
            _loc31_ = this.src.y - _loc25_;
            _loc32_ = this.src.z - _loc26_;
            if(_loc30_ * this.displ.x + _loc31_ * this.displ.y + _loc32_ * this.displ.z <= 0)
            {
               _loc52_ = -this.displ.x / _loc2_;
               _loc53_ = -this.displ.y / _loc2_;
               _loc54_ = -this.displ.z / _loc2_;
               _loc55_ = _loc30_ * _loc30_ + _loc31_ * _loc31_ + _loc32_ * _loc32_;
               _loc56_ = _loc30_ * _loc52_ + _loc31_ * _loc53_ + _loc32_ * _loc54_;
               _loc57_ = this.radius * this.radius - _loc55_ + _loc56_ * _loc56_;
               if(_loc57_ > 0)
               {
                  _loc58_ = (_loc56_ - Math.sqrt(_loc57_)) / _loc2_;
                  if(_loc58_ < _loc1_)
                  {
                     _loc1_ = _loc58_;
                     this.collisionPoint.x = _loc24_;
                     this.collisionPoint.y = _loc25_;
                     this.collisionPoint.z = _loc26_;
                     if(_loc28_)
                     {
                        this.collisionPlane.x = _loc16_;
                        this.collisionPlane.y = _loc17_;
                        this.collisionPlane.z = _loc18_;
                        this.collisionPlane.w = _loc19_;
                     }
                     else
                     {
                        _loc55_ = Math.sqrt(_loc55_);
                        this.collisionPlane.x = _loc30_ / _loc55_;
                        this.collisionPlane.y = _loc31_ / _loc55_;
                        this.collisionPlane.z = _loc32_ / _loc55_;
                        this.collisionPlane.w = this.collisionPoint.x * this.collisionPlane.x + this.collisionPoint.y * this.collisionPlane.y + this.collisionPoint.z * this.collisionPlane.z;
                     }
                  }
               }
            }
         }
         return _loc1_ < 1;
      }
   }
}

