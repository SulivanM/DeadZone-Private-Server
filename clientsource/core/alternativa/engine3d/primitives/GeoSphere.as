package alternativa.engine3d.primitives
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.VertexAttributes;
   import alternativa.engine3d.materials.Material;
   import alternativa.engine3d.objects.Mesh;
   import alternativa.engine3d.resources.Geometry;
   import flash.geom.Vector3D;
   import flash.utils.ByteArray;
   import flash.utils.Endian;
   
   use namespace alternativa3d;
   
   public class GeoSphere extends Mesh
   {
      
      public function GeoSphere(param1:Number = 100, param2:uint = 2, param3:Boolean = false, param4:Material = null)
      {
         var _loc5_:Vector.<uint> = null;
         var _loc11_:uint = 0;
         var _loc12_:uint = 0;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc20_:uint = 0;
         var _loc21_:uint = 0;
         var _loc22_:uint = 0;
         var _loc23_:uint = 0;
         var _loc24_:uint = 0;
         var _loc25_:Vector3D = null;
         var _loc26_:Vector3D = null;
         var _loc27_:Vector3D = null;
         var _loc28_:Number = NaN;
         var _loc29_:Number = NaN;
         var _loc30_:Number = NaN;
         var _loc31_:Number = NaN;
         var _loc32_:Number = NaN;
         var _loc33_:Number = NaN;
         var _loc34_:Vector3D = null;
         var _loc35_:Number = NaN;
         super();
         if(param2 == 0)
         {
            return;
         }
         param1 = param1 < 0 ? 0 : param1;
         _loc5_ = new Vector.<uint>();
         var _loc6_:uint = 20;
         var _loc7_:Number = Math.PI;
         var _loc8_:Number = Math.PI * 2;
         var _loc9_:Vector.<Vector3D> = new Vector.<Vector3D>();
         var _loc10_:Vector.<Number> = new Vector.<Number>();
         var _loc16_:Number = 0.4472136 * param1;
         var _loc17_:Number = 2 * _loc16_;
         _loc9_.push(new Vector3D(0,0,param1,-1));
         _loc10_.length += 2;
         _loc11_ = 0;
         while(_loc11_ < 5)
         {
            _loc13_ = _loc8_ * _loc11_ / 5;
            _loc14_ = Math.sin(_loc13_);
            _loc15_ = Math.cos(_loc13_);
            _loc9_.push(new Vector3D(_loc17_ * _loc15_,_loc17_ * _loc14_,_loc16_,-1));
            _loc10_.length += 2;
            _loc11_++;
         }
         _loc11_ = 0;
         while(_loc11_ < 5)
         {
            _loc13_ = _loc7_ * ((_loc11_ << 1) + 1) / 5;
            _loc14_ = Math.sin(_loc13_);
            _loc15_ = Math.cos(_loc13_);
            _loc9_.push(new Vector3D(_loc17_ * _loc15_,_loc17_ * _loc14_,-_loc16_,-1));
            _loc10_.length += 2;
            _loc11_++;
         }
         _loc9_.push(new Vector3D(0,0,-param1,-1));
         _loc10_.length += 2;
         _loc11_ = 1;
         while(_loc11_ < 6)
         {
            this.interpolate(0,_loc11_,param2,_loc9_,_loc10_);
            _loc11_++;
         }
         _loc11_ = 1;
         while(_loc11_ < 6)
         {
            this.interpolate(_loc11_,_loc11_ % 5 + 1,param2,_loc9_,_loc10_);
            _loc11_++;
         }
         _loc11_ = 1;
         while(_loc11_ < 6)
         {
            this.interpolate(_loc11_,_loc11_ + 5,param2,_loc9_,_loc10_);
            _loc11_++;
         }
         _loc11_ = 1;
         while(_loc11_ < 6)
         {
            this.interpolate(_loc11_,(_loc11_ + 3) % 5 + 6,param2,_loc9_,_loc10_);
            _loc11_++;
         }
         _loc11_ = 1;
         while(_loc11_ < 6)
         {
            this.interpolate(_loc11_ + 5,_loc11_ % 5 + 6,param2,_loc9_,_loc10_);
            _loc11_++;
         }
         _loc11_ = 6;
         while(_loc11_ < 11)
         {
            this.interpolate(11,_loc11_,param2,_loc9_,_loc10_);
            _loc11_++;
         }
         _loc12_ = 0;
         while(_loc12_ < 5)
         {
            _loc11_ = 1;
            while(_loc11_ <= param2 - 2)
            {
               this.interpolate(12 + _loc12_ * (param2 - 1) + _loc11_,12 + (_loc12_ + 1) % 5 * (param2 - 1) + _loc11_,_loc11_ + 1,_loc9_,_loc10_);
               _loc11_++;
            }
            _loc12_++;
         }
         _loc12_ = 0;
         while(_loc12_ < 5)
         {
            _loc11_ = 1;
            while(_loc11_ <= param2 - 2)
            {
               this.interpolate(12 + (_loc12_ + 15) * (param2 - 1) + _loc11_,12 + (_loc12_ + 10) * (param2 - 1) + _loc11_,_loc11_ + 1,_loc9_,_loc10_);
               _loc11_++;
            }
            _loc12_++;
         }
         _loc12_ = 0;
         while(_loc12_ < 5)
         {
            _loc11_ = 1;
            while(_loc11_ <= param2 - 2)
            {
               this.interpolate(12 + ((_loc12_ + 1) % 5 + 15) * (param2 - 1) + param2 - 2 - _loc11_,12 + (_loc12_ + 10) * (param2 - 1) + param2 - 2 - _loc11_,_loc11_ + 1,_loc9_,_loc10_);
               _loc11_++;
            }
            _loc12_++;
         }
         _loc12_ = 0;
         while(_loc12_ < 5)
         {
            _loc11_ = 1;
            while(_loc11_ <= param2 - 2)
            {
               this.interpolate(12 + ((_loc12_ + 1) % 5 + 25) * (param2 - 1) + _loc11_,12 + (_loc12_ + 25) * (param2 - 1) + _loc11_,_loc11_ + 1,_loc9_,_loc10_);
               _loc11_++;
            }
            _loc12_++;
         }
         _loc12_ = 0;
         while(_loc12_ < _loc6_)
         {
            _loc20_ = 0;
            while(_loc20_ < param2)
            {
               _loc21_ = 0;
               while(_loc21_ <= _loc20_)
               {
                  _loc22_ = this.findVertices(param2,_loc12_,_loc20_,_loc21_);
                  _loc23_ = this.findVertices(param2,_loc12_,_loc20_ + 1,_loc21_);
                  _loc24_ = this.findVertices(param2,_loc12_,_loc20_ + 1,_loc21_ + 1);
                  _loc25_ = _loc9_[_loc22_];
                  _loc26_ = _loc9_[_loc23_];
                  _loc27_ = _loc9_[_loc24_];
                  if(_loc25_.y >= 0 && _loc25_.x < 0 && (_loc26_.y < 0 || _loc27_.y < 0))
                  {
                     _loc28_ = Math.atan2(_loc25_.y,_loc25_.x) / _loc8_ - 0.5;
                  }
                  else
                  {
                     _loc28_ = Math.atan2(_loc25_.y,_loc25_.x) / _loc8_ + 0.5;
                  }
                  _loc29_ = -Math.asin(_loc25_.z / param1) / _loc7_ + 0.5;
                  if(_loc26_.y >= 0 && _loc26_.x < 0 && (_loc25_.y < 0 || _loc27_.y < 0))
                  {
                     _loc30_ = Math.atan2(_loc26_.y,_loc26_.x) / _loc8_ - 0.5;
                  }
                  else
                  {
                     _loc30_ = Math.atan2(_loc26_.y,_loc26_.x) / _loc8_ + 0.5;
                  }
                  _loc31_ = -Math.asin(_loc26_.z / param1) / _loc7_ + 0.5;
                  if(_loc27_.y >= 0 && _loc27_.x < 0 && (_loc25_.y < 0 || _loc26_.y < 0))
                  {
                     _loc32_ = Math.atan2(_loc27_.y,_loc27_.x) / _loc8_ - 0.5;
                  }
                  else
                  {
                     _loc32_ = Math.atan2(_loc27_.y,_loc27_.x) / _loc8_ + 0.5;
                  }
                  _loc33_ = -Math.asin(_loc27_.z / param1) / _loc7_ + 0.5;
                  if(_loc22_ == 0 || _loc22_ == 11)
                  {
                     _loc28_ = _loc30_ + (_loc32_ - _loc30_) * 0.5;
                  }
                  if(_loc23_ == 0 || _loc23_ == 11)
                  {
                     _loc30_ = _loc28_ + (_loc32_ - _loc28_) * 0.5;
                  }
                  if(_loc24_ == 0 || _loc24_ == 11)
                  {
                     _loc32_ = _loc28_ + (_loc30_ - _loc28_) * 0.5;
                  }
                  if(_loc25_.w > 0 && _loc10_[_loc22_ * 2] != _loc28_)
                  {
                     _loc25_ = this.createVertex(_loc25_.x,_loc25_.y,_loc25_.z);
                     _loc22_ = _loc9_.push(_loc25_) - 1;
                  }
                  _loc10_[_loc22_ * 2] = _loc28_;
                  _loc10_[_loc22_ * 2 + 1] = _loc29_;
                  _loc25_.w = 1;
                  if(_loc26_.w > 0 && _loc10_[_loc23_ * 2] != _loc30_)
                  {
                     _loc26_ = this.createVertex(_loc26_.x,_loc26_.y,_loc26_.z);
                     _loc23_ = _loc9_.push(_loc26_) - 1;
                  }
                  _loc10_[_loc23_ * 2] = _loc30_;
                  _loc10_[_loc23_ * 2 + 1] = _loc31_;
                  _loc26_.w = 1;
                  if(_loc27_.w > 0 && _loc10_[_loc24_ * 2] != _loc32_)
                  {
                     _loc27_ = this.createVertex(_loc27_.x,_loc27_.y,_loc27_.z);
                     _loc24_ = _loc9_.push(_loc27_) - 1;
                  }
                  _loc10_[_loc24_ * 2] = _loc32_;
                  _loc10_[_loc24_ * 2 + 1] = _loc33_;
                  _loc27_.w = 1;
                  if(param3)
                  {
                     _loc5_.push(_loc22_,_loc24_,_loc23_);
                  }
                  else
                  {
                     _loc5_.push(_loc22_,_loc23_,_loc24_);
                  }
                  if(_loc21_ < _loc20_)
                  {
                     _loc23_ = this.findVertices(param2,_loc12_,_loc20_,_loc21_ + 1);
                     _loc26_ = _loc9_[_loc23_];
                     if(_loc25_.y >= 0 && _loc25_.x < 0 && (_loc26_.y < 0 || _loc27_.y < 0))
                     {
                        _loc28_ = Math.atan2(_loc25_.y,_loc25_.x) / _loc8_ - 0.5;
                     }
                     else
                     {
                        _loc28_ = Math.atan2(_loc25_.y,_loc25_.x) / _loc8_ + 0.5;
                     }
                     _loc29_ = -Math.asin(_loc25_.z / param1) / _loc7_ + 0.5;
                     if(_loc26_.y >= 0 && _loc26_.x < 0 && (_loc25_.y < 0 || _loc27_.y < 0))
                     {
                        _loc30_ = Math.atan2(_loc26_.y,_loc26_.x) / _loc8_ - 0.5;
                     }
                     else
                     {
                        _loc30_ = Math.atan2(_loc26_.y,_loc26_.x) / _loc8_ + 0.5;
                     }
                     _loc31_ = -Math.asin(_loc26_.z / param1) / _loc7_ + 0.5;
                     if(_loc27_.y >= 0 && _loc27_.x < 0 && (_loc25_.y < 0 || _loc26_.y < 0))
                     {
                        _loc32_ = Math.atan2(_loc27_.y,_loc27_.x) / _loc8_ - 0.5;
                     }
                     else
                     {
                        _loc32_ = Math.atan2(_loc27_.y,_loc27_.x) / _loc8_ + 0.5;
                     }
                     _loc33_ = -Math.asin(_loc27_.z / param1) / _loc7_ + 0.5;
                     if(_loc22_ == 0 || _loc22_ == 11)
                     {
                        _loc28_ = _loc30_ + (_loc32_ - _loc30_) * 0.5;
                     }
                     if(_loc23_ == 0 || _loc23_ == 11)
                     {
                        _loc30_ = _loc28_ + (_loc32_ - _loc28_) * 0.5;
                     }
                     if(_loc24_ == 0 || _loc24_ == 11)
                     {
                        _loc32_ = _loc28_ + (_loc30_ - _loc28_) * 0.5;
                     }
                     if(_loc25_.w > 0 && _loc10_[_loc22_ * 2] != _loc28_)
                     {
                        _loc25_ = this.createVertex(_loc25_.x,_loc25_.y,_loc25_.z);
                        _loc22_ = _loc9_.push(_loc25_) - 1;
                     }
                     _loc10_[_loc22_ * 2] = _loc28_;
                     _loc10_[_loc22_ * 2 + 1] = _loc29_;
                     _loc25_.w = 1;
                     if(_loc26_.w > 0 && _loc10_[_loc23_ * 2] != _loc30_)
                     {
                        _loc26_ = this.createVertex(_loc26_.x,_loc26_.y,_loc26_.z);
                        _loc23_ = _loc9_.push(_loc26_) - 1;
                     }
                     _loc10_[_loc23_ * 2] = _loc30_;
                     _loc10_[_loc23_ * 2 + 1] = _loc31_;
                     _loc26_.w = 1;
                     if(_loc27_.w > 0 && _loc10_[_loc24_ * 2] != _loc32_)
                     {
                        _loc27_ = this.createVertex(_loc27_.x,_loc27_.y,_loc27_.z);
                        _loc24_ = _loc9_.push(_loc27_) - 1;
                     }
                     _loc10_[_loc24_ * 2] = _loc32_;
                     _loc10_[_loc24_ * 2 + 1] = _loc33_;
                     _loc27_.w = 1;
                     if(param3)
                     {
                        _loc5_.push(_loc22_,_loc23_,_loc24_);
                     }
                     else
                     {
                        _loc5_.push(_loc22_,_loc24_,_loc23_);
                     }
                  }
                  _loc21_++;
               }
               _loc20_++;
            }
            _loc12_++;
         }
         var _loc18_:ByteArray = new ByteArray();
         _loc18_.endian = Endian.LITTLE_ENDIAN;
         _loc11_ = 0;
         while(_loc11_ < _loc9_.length)
         {
            _loc34_ = _loc9_[_loc11_];
            _loc18_.writeFloat(_loc34_.x);
            _loc18_.writeFloat(_loc34_.y);
            _loc18_.writeFloat(_loc34_.z);
            _loc18_.writeFloat(_loc10_[_loc11_ * 2]);
            _loc18_.writeFloat(_loc10_[_loc11_ * 2 + 1]);
            _loc18_.writeFloat(_loc34_.x / param1);
            _loc18_.writeFloat(_loc34_.y / param1);
            _loc18_.writeFloat(_loc34_.z / param1);
            _loc35_ = _loc8_ * _loc10_[_loc11_ * 2];
            _loc18_.writeFloat(Math.sin(_loc35_));
            _loc18_.writeFloat(-Math.cos(_loc35_));
            _loc18_.writeFloat(0);
            _loc18_.writeFloat(-1);
            _loc11_++;
         }
         geometry = new Geometry();
         geometry.alternativa3d::_indices = _loc5_;
         var _loc19_:Array = [];
         _loc19_[0] = VertexAttributes.POSITION;
         _loc19_[1] = VertexAttributes.POSITION;
         _loc19_[2] = VertexAttributes.POSITION;
         _loc19_[3] = VertexAttributes.TEXCOORDS[0];
         _loc19_[4] = VertexAttributes.TEXCOORDS[0];
         _loc19_[5] = VertexAttributes.NORMAL;
         _loc19_[6] = VertexAttributes.NORMAL;
         _loc19_[7] = VertexAttributes.NORMAL;
         _loc19_[8] = VertexAttributes.TANGENT4;
         _loc19_[9] = VertexAttributes.TANGENT4;
         _loc19_[10] = VertexAttributes.TANGENT4;
         _loc19_[11] = VertexAttributes.TANGENT4;
         geometry.addVertexStream(_loc19_);
         geometry.alternativa3d::_vertexStreams[0].data = _loc18_;
         geometry.alternativa3d::_numVertices = _loc18_.length / 48;
         addSurface(param4,0,_loc5_.length / 3);
         calculateBoundBox();
      }
      
      private function createVertex(param1:Number, param2:Number, param3:Number) : Vector3D
      {
         var _loc4_:Vector3D = new Vector3D();
         _loc4_.x = param1;
         _loc4_.y = param2;
         _loc4_.z = param3;
         _loc4_.w = -1;
         return _loc4_;
      }
      
      private function interpolate(param1:uint, param2:uint, param3:uint, param4:Vector.<Vector3D>, param5:Vector.<Number>) : void
      {
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         if(param3 < 2)
         {
            return;
         }
         var _loc6_:Vector3D = param4[param1];
         var _loc7_:Vector3D = param4[param2];
         var _loc8_:Number = (_loc6_.x * _loc7_.x + _loc6_.y * _loc7_.y + _loc6_.z * _loc7_.z) / (_loc6_.x * _loc6_.x + _loc6_.y * _loc6_.y + _loc6_.z * _loc6_.z);
         _loc8_ = _loc8_ < -1 ? -1 : (_loc8_ > 1 ? 1 : _loc8_);
         var _loc9_:Number = Math.acos(_loc8_);
         var _loc10_:Number = Math.sin(_loc9_);
         var _loc11_:uint = 1;
         while(_loc11_ < param3)
         {
            _loc12_ = _loc9_ * _loc11_ / param3;
            _loc13_ = _loc9_ * (param3 - _loc11_) / param3;
            _loc14_ = Math.sin(_loc12_);
            _loc15_ = Math.sin(_loc13_);
            param4.push(new Vector3D((_loc6_.x * _loc15_ + _loc7_.x * _loc14_) / _loc10_,(_loc6_.y * _loc15_ + _loc7_.y * _loc14_) / _loc10_,(_loc6_.z * _loc15_ + _loc7_.z * _loc14_) / _loc10_,-1));
            param5.length += 2;
            _loc11_++;
         }
      }
      
      private function findVertices(param1:uint, param2:uint, param3:uint, param4:uint) : uint
      {
         if(param3 == 0)
         {
            if(param2 < 5)
            {
               return 0;
            }
            if(param2 > 14)
            {
               return 11;
            }
            return param2 - 4;
         }
         if(param3 == param1 && param4 == 0)
         {
            if(param2 < 5)
            {
               return param2 + 1;
            }
            if(param2 < 10)
            {
               return (param2 + 4) % 5 + 6;
            }
            if(param2 < 15)
            {
               return (param2 + 1) % 5 + 1;
            }
            return (param2 + 1) % 5 + 6;
         }
         if(param3 == param1 && param4 == param1)
         {
            if(param2 < 5)
            {
               return (param2 + 1) % 5 + 1;
            }
            if(param2 < 10)
            {
               return param2 + 1;
            }
            if(param2 < 15)
            {
               return param2 - 9;
            }
            return param2 - 9;
         }
         if(param3 == param1)
         {
            if(param2 < 5)
            {
               return 12 + (5 + param2) * (param1 - 1) + param4 - 1;
            }
            if(param2 < 10)
            {
               return 12 + (20 + (param2 + 4) % 5) * (param1 - 1) + param4 - 1;
            }
            if(param2 < 15)
            {
               return 12 + (param2 - 5) * (param1 - 1) + param1 - 1 - param4;
            }
            return 12 + (5 + param2) * (param1 - 1) + param1 - 1 - param4;
         }
         if(param4 == 0)
         {
            if(param2 < 5)
            {
               return 12 + param2 * (param1 - 1) + param3 - 1;
            }
            if(param2 < 10)
            {
               return 12 + (param2 % 5 + 15) * (param1 - 1) + param3 - 1;
            }
            if(param2 < 15)
            {
               return 12 + ((param2 + 1) % 5 + 15) * (param1 - 1) + param1 - 1 - param3;
            }
            return 12 + ((param2 + 1) % 5 + 25) * (param1 - 1) + param3 - 1;
         }
         if(param4 == param3)
         {
            if(param2 < 5)
            {
               return 12 + (param2 + 1) % 5 * (param1 - 1) + param3 - 1;
            }
            if(param2 < 10)
            {
               return 12 + (param2 % 5 + 10) * (param1 - 1) + param3 - 1;
            }
            if(param2 < 15)
            {
               return 12 + (param2 % 5 + 10) * (param1 - 1) + param1 - param3 - 1;
            }
            return 12 + (param2 % 5 + 25) * (param1 - 1) + param3 - 1;
         }
         return 12 + 30 * (param1 - 1) + param2 * (param1 - 1) * (param1 - 2) / 2 + (param3 - 1) * (param3 - 2) / 2 + param4 - 1;
      }
      
      override public function clone() : Object3D
      {
         var _loc1_:GeoSphere = new GeoSphere(1,0);
         _loc1_.clonePropertiesFrom(this);
         return _loc1_;
      }
   }
}

