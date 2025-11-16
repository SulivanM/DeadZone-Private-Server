package alternativa.engine3d.primitives
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.BoundBox;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.VertexAttributes;
   import alternativa.engine3d.materials.Material;
   import alternativa.engine3d.objects.Mesh;
   import alternativa.engine3d.resources.Geometry;
   import flash.utils.ByteArray;
   import flash.utils.Endian;
   
   use namespace alternativa3d;
   
   public class Box extends Mesh
   {
      
      public function Box(param1:Number = 100, param2:Number = 100, param3:Number = 100, param4:uint = 1, param5:uint = 1, param6:uint = 1, param7:Boolean = false, param8:Material = null)
      {
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc18_:Number = NaN;
         super();
         if(param4 <= 0 || param5 <= 0 || param6 <= 0)
         {
            return;
         }
         var _loc9_:Vector.<uint> = new Vector.<uint>();
         var _loc13_:int = param4 + 1;
         var _loc14_:int = param5 + 1;
         var _loc15_:int = param6 + 1;
         var _loc16_:Number = param1 * 0.5;
         var _loc17_:Number = param2 * 0.5;
         _loc18_ = param3 * 0.5;
         var _loc19_:Number = 1 / param4;
         var _loc20_:Number = 1 / param5;
         var _loc21_:Number = 1 / param6;
         var _loc22_:Number = param1 / param4;
         var _loc23_:Number = param2 / param5;
         var _loc24_:Number = param3 / param6;
         var _loc25_:ByteArray = new ByteArray();
         _loc25_.endian = Endian.LITTLE_ENDIAN;
         var _loc26_:uint = 0;
         var _loc27_:Number = 28;
         _loc10_ = 0;
         while(_loc10_ < _loc13_)
         {
            _loc11_ = 0;
            while(_loc11_ < _loc14_)
            {
               _loc25_.writeFloat(_loc10_ * _loc22_ - _loc16_);
               _loc25_.writeFloat(_loc11_ * _loc23_ - _loc17_);
               _loc25_.writeFloat(-_loc18_);
               _loc25_.writeFloat((param4 - _loc10_) * _loc19_);
               _loc25_.writeFloat((param5 - _loc11_) * _loc20_);
               _loc25_.length = _loc25_.position = _loc25_.position + _loc27_;
               _loc11_++;
            }
            _loc10_++;
         }
         _loc26_ = _loc25_.position;
         _loc10_ = 0;
         while(_loc10_ < _loc13_)
         {
            _loc11_ = 0;
            while(_loc11_ < _loc14_)
            {
               if(_loc10_ < param4 && _loc11_ < param5)
               {
                  this.createFace(_loc9_,_loc25_,(_loc10_ + 1) * _loc14_ + _loc11_ + 1,(_loc10_ + 1) * _loc14_ + _loc11_,_loc10_ * _loc14_ + _loc11_,_loc10_ * _loc14_ + _loc11_ + 1,0,0,-1,_loc18_,-1,0,0,-1,param7);
               }
               _loc11_++;
            }
            _loc10_++;
         }
         _loc25_.position = _loc26_;
         var _loc28_:uint = uint(_loc13_ * _loc14_);
         _loc10_ = 0;
         while(_loc10_ < _loc13_)
         {
            _loc11_ = 0;
            while(_loc11_ < _loc14_)
            {
               _loc25_.writeFloat(_loc10_ * _loc22_ - _loc16_);
               _loc25_.writeFloat(_loc11_ * _loc23_ - _loc17_);
               _loc25_.writeFloat(_loc18_);
               _loc25_.writeFloat(_loc10_ * _loc19_);
               _loc25_.writeFloat((param5 - _loc11_) * _loc20_);
               _loc25_.length = _loc25_.position = _loc25_.position + _loc27_;
               _loc11_++;
            }
            _loc10_++;
         }
         _loc26_ = _loc25_.position;
         _loc10_ = 0;
         while(_loc10_ < _loc13_)
         {
            _loc11_ = 0;
            while(_loc11_ < _loc14_)
            {
               if(_loc10_ < param4 && _loc11_ < param5)
               {
                  this.createFace(_loc9_,_loc25_,_loc28_ + _loc10_ * _loc14_ + _loc11_,_loc28_ + (_loc10_ + 1) * _loc14_ + _loc11_,_loc28_ + (_loc10_ + 1) * _loc14_ + _loc11_ + 1,_loc28_ + _loc10_ * _loc14_ + _loc11_ + 1,0,0,1,_loc18_,1,0,0,-1,param7);
               }
               _loc11_++;
            }
            _loc10_++;
         }
         _loc25_.position = _loc26_;
         _loc28_ += _loc13_ * _loc14_;
         _loc10_ = 0;
         while(_loc10_ < _loc13_)
         {
            _loc12_ = 0;
            while(_loc12_ < _loc15_)
            {
               _loc25_.writeFloat(_loc10_ * _loc22_ - _loc16_);
               _loc25_.writeFloat(-_loc17_);
               _loc25_.writeFloat(_loc12_ * _loc24_ - _loc18_);
               _loc25_.writeFloat(_loc10_ * _loc19_);
               _loc25_.writeFloat((param6 - _loc12_) * _loc21_);
               _loc25_.length = _loc25_.position = _loc25_.position + _loc27_;
               _loc12_++;
            }
            _loc10_++;
         }
         _loc26_ = _loc25_.position;
         _loc10_ = 0;
         while(_loc10_ < _loc13_)
         {
            _loc12_ = 0;
            while(_loc12_ < _loc15_)
            {
               if(_loc10_ < param4 && _loc12_ < param6)
               {
                  this.createFace(_loc9_,_loc25_,_loc28_ + _loc10_ * _loc15_ + _loc12_,_loc28_ + (_loc10_ + 1) * _loc15_ + _loc12_,_loc28_ + (_loc10_ + 1) * _loc15_ + _loc12_ + 1,_loc28_ + _loc10_ * _loc15_ + _loc12_ + 1,0,-1,0,_loc17_,1,0,0,-1,param7);
               }
               _loc12_++;
            }
            _loc10_++;
         }
         _loc25_.position = _loc26_;
         _loc28_ += _loc13_ * _loc15_;
         _loc10_ = 0;
         while(_loc10_ < _loc13_)
         {
            _loc12_ = 0;
            while(_loc12_ < _loc15_)
            {
               _loc25_.writeFloat(_loc10_ * _loc22_ - _loc16_);
               _loc25_.writeFloat(_loc17_);
               _loc25_.writeFloat(_loc12_ * _loc24_ - _loc18_);
               _loc25_.writeFloat((param4 - _loc10_) * _loc19_);
               _loc25_.writeFloat((param6 - _loc12_) * _loc21_);
               _loc25_.length = _loc25_.position = _loc25_.position + _loc27_;
               _loc12_++;
            }
            _loc10_++;
         }
         _loc26_ = _loc25_.position;
         _loc10_ = 0;
         while(_loc10_ < _loc13_)
         {
            _loc12_ = 0;
            while(_loc12_ < _loc15_)
            {
               if(_loc10_ < param4 && _loc12_ < param6)
               {
                  this.createFace(_loc9_,_loc25_,_loc28_ + _loc10_ * _loc15_ + _loc12_,_loc28_ + _loc10_ * _loc15_ + _loc12_ + 1,_loc28_ + (_loc10_ + 1) * _loc15_ + _loc12_ + 1,_loc28_ + (_loc10_ + 1) * _loc15_ + _loc12_,0,1,0,_loc17_,-1,0,0,-1,param7);
               }
               _loc12_++;
            }
            _loc10_++;
         }
         _loc25_.position = _loc26_;
         _loc28_ += _loc13_ * _loc15_;
         _loc11_ = 0;
         while(_loc11_ < _loc14_)
         {
            _loc12_ = 0;
            while(_loc12_ < _loc15_)
            {
               _loc25_.writeFloat(-_loc16_);
               _loc25_.writeFloat(_loc11_ * _loc23_ - _loc17_);
               _loc25_.writeFloat(_loc12_ * _loc24_ - _loc18_);
               _loc25_.writeFloat((param5 - _loc11_) * _loc20_);
               _loc25_.writeFloat((param6 - _loc12_) * _loc21_);
               _loc25_.length = _loc25_.position = _loc25_.position + _loc27_;
               _loc12_++;
            }
            _loc11_++;
         }
         _loc26_ = _loc25_.position;
         _loc11_ = 0;
         while(_loc11_ < _loc14_)
         {
            _loc12_ = 0;
            while(_loc12_ < _loc15_)
            {
               if(_loc11_ < param5 && _loc12_ < param6)
               {
                  this.createFace(_loc9_,_loc25_,_loc28_ + _loc11_ * _loc15_ + _loc12_,_loc28_ + _loc11_ * _loc15_ + _loc12_ + 1,_loc28_ + (_loc11_ + 1) * _loc15_ + _loc12_ + 1,_loc28_ + (_loc11_ + 1) * _loc15_ + _loc12_,-1,0,0,_loc16_,0,-1,0,-1,param7);
               }
               _loc12_++;
            }
            _loc11_++;
         }
         _loc25_.position = _loc26_;
         _loc28_ += _loc14_ * _loc15_;
         _loc11_ = 0;
         while(_loc11_ < _loc14_)
         {
            _loc12_ = 0;
            while(_loc12_ < _loc15_)
            {
               _loc25_.writeFloat(_loc16_);
               _loc25_.writeFloat(_loc11_ * _loc23_ - _loc17_);
               _loc25_.writeFloat(_loc12_ * _loc24_ - _loc18_);
               _loc25_.writeFloat(_loc11_ * _loc20_);
               _loc25_.writeFloat((param6 - _loc12_) * _loc21_);
               _loc25_.length = _loc25_.position = _loc25_.position + _loc27_;
               _loc12_++;
            }
            _loc11_++;
         }
         _loc11_ = 0;
         while(_loc11_ < _loc14_)
         {
            _loc12_ = 0;
            while(_loc12_ < _loc15_)
            {
               if(_loc11_ < param5 && _loc12_ < param6)
               {
                  this.createFace(_loc9_,_loc25_,_loc28_ + _loc11_ * _loc15_ + _loc12_,_loc28_ + (_loc11_ + 1) * _loc15_ + _loc12_,_loc28_ + (_loc11_ + 1) * _loc15_ + _loc12_ + 1,_loc28_ + _loc11_ * _loc15_ + _loc12_ + 1,1,0,0,_loc16_,0,1,0,-1,param7);
               }
               _loc12_++;
            }
            _loc11_++;
         }
         geometry = new Geometry();
         geometry.alternativa3d::_indices = _loc9_;
         var _loc29_:Array = [];
         _loc29_[0] = VertexAttributes.POSITION;
         _loc29_[1] = VertexAttributes.POSITION;
         _loc29_[2] = VertexAttributes.POSITION;
         _loc29_[3] = VertexAttributes.TEXCOORDS[0];
         _loc29_[4] = VertexAttributes.TEXCOORDS[0];
         _loc29_[5] = VertexAttributes.NORMAL;
         _loc29_[6] = VertexAttributes.NORMAL;
         _loc29_[7] = VertexAttributes.NORMAL;
         _loc29_[8] = VertexAttributes.TANGENT4;
         _loc29_[9] = VertexAttributes.TANGENT4;
         _loc29_[10] = VertexAttributes.TANGENT4;
         _loc29_[11] = VertexAttributes.TANGENT4;
         geometry.addVertexStream(_loc29_);
         geometry.alternativa3d::_vertexStreams[0].data = _loc25_;
         geometry.alternativa3d::_numVertices = _loc25_.length / 48;
         addSurface(param8,0,_loc9_.length / 3);
         boundBox = new BoundBox();
         boundBox.minX = -_loc16_;
         boundBox.minY = -_loc17_;
         boundBox.minZ = -_loc18_;
         boundBox.maxX = _loc16_;
         boundBox.maxY = _loc17_;
         boundBox.maxZ = _loc18_;
      }
      
      private function createFace(param1:Vector.<uint>, param2:ByteArray, param3:int, param4:int, param5:int, param6:int, param7:Number, param8:Number, param9:Number, param10:Number, param11:Number, param12:Number, param13:Number, param14:Number, param15:Boolean) : void
      {
         var _loc16_:int = 0;
         if(param15)
         {
            param7 = -param7;
            param8 = -param8;
            param9 = -param9;
            param10 = -param10;
            _loc16_ = param3;
            param3 = param6;
            param6 = _loc16_;
            _loc16_ = param4;
            param4 = param5;
            param5 = _loc16_;
         }
         param1.push(param3);
         param1.push(param4);
         param1.push(param5);
         param1.push(param3);
         param1.push(param5);
         param1.push(param6);
         param2.position = param3 * 48 + 20;
         param2.writeFloat(param7);
         param2.writeFloat(param8);
         param2.writeFloat(param9);
         param2.writeFloat(param11);
         param2.writeFloat(param12);
         param2.writeFloat(param13);
         param2.writeFloat(param14);
         param2.position = param4 * 48 + 20;
         param2.writeFloat(param7);
         param2.writeFloat(param8);
         param2.writeFloat(param9);
         param2.writeFloat(param11);
         param2.writeFloat(param12);
         param2.writeFloat(param13);
         param2.writeFloat(param14);
         param2.position = param5 * 48 + 20;
         param2.writeFloat(param7);
         param2.writeFloat(param8);
         param2.writeFloat(param9);
         param2.writeFloat(param11);
         param2.writeFloat(param12);
         param2.writeFloat(param13);
         param2.writeFloat(param14);
         param2.position = param6 * 48 + 20;
         param2.writeFloat(param7);
         param2.writeFloat(param8);
         param2.writeFloat(param9);
         param2.writeFloat(param11);
         param2.writeFloat(param12);
         param2.writeFloat(param13);
         param2.writeFloat(param14);
      }
      
      override public function clone() : Object3D
      {
         var _loc1_:Box = new Box(0,0,0,0,0,0);
         _loc1_.clonePropertiesFrom(this);
         return _loc1_;
      }
   }
}

