package alternativa.engine3d.resources
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.BoundBox;
   import alternativa.engine3d.core.RayIntersectionData;
   import alternativa.engine3d.core.Resource;
   import alternativa.engine3d.core.Transform3D;
   import alternativa.engine3d.core.VertexAttributes;
   import alternativa.engine3d.core.VertexStream;
   import flash.display3D.Context3D;
   import flash.display3D.IndexBuffer3D;
   import flash.display3D.VertexBuffer3D;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import flash.utils.ByteArray;
   import flash.utils.Endian;
   
   use namespace alternativa3d;
   
   public class Geometry extends Resource
   {
      
      alternativa3d var _vertexStreams:Vector.<VertexStream> = new Vector.<VertexStream>();
      
      alternativa3d var _indexBuffer:IndexBuffer3D;
      
      alternativa3d var _numVertices:int;
      
      alternativa3d var _indices:Vector.<uint> = new Vector.<uint>();
      
      alternativa3d var _attributesStreams:Vector.<VertexStream> = new Vector.<VertexStream>();
      
      alternativa3d var _attributesOffsets:Vector.<int> = new Vector.<int>();
      
      private var _attributesStrides:Vector.<int> = new Vector.<int>();
      
      public function Geometry(param1:int = 0)
      {
         super();
         this.alternativa3d::_numVertices = param1;
      }
      
      public function get numTriangles() : int
      {
         return this.alternativa3d::_indices.length / 3;
      }
      
      public function get indices() : Vector.<uint>
      {
         return this.alternativa3d::_indices.slice();
      }
      
      public function set indices(param1:Vector.<uint>) : void
      {
         if(param1 == null)
         {
            this.alternativa3d::_indices.length = 0;
         }
         else
         {
            this.alternativa3d::_indices = param1.slice();
         }
      }
      
      public function get numVertices() : int
      {
         return this.alternativa3d::_numVertices;
      }
      
      public function set numVertices(param1:int) : void
      {
         var _loc2_:VertexStream = null;
         var _loc3_:int = 0;
         if(this.alternativa3d::_numVertices != param1)
         {
            for each(_loc2_ in this.alternativa3d::_vertexStreams)
            {
               _loc3_ = int(_loc2_.attributes.length);
               _loc2_.data.length = 4 * _loc3_ * param1;
            }
            this.alternativa3d::_numVertices = param1;
         }
      }
      
      public function calculateNormals() : void
      {
         var _loc7_:Vector3D = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
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
         var _loc28_:Number = NaN;
         var _loc29_:Number = NaN;
         var _loc30_:Number = NaN;
         var _loc31_:int = 0;
         var _loc32_:VertexStream = null;
         var _loc33_:ByteArray = null;
         var _loc34_:uint = 0;
         var _loc35_:ByteArray = null;
         if(!this.hasAttribute(VertexAttributes.POSITION))
         {
            throw new Error("Vertices positions is required to calculate normals");
         }
         var _loc1_:Array = [];
         var _loc2_:VertexStream = this.alternativa3d::_attributesStreams[VertexAttributes.POSITION];
         var _loc3_:ByteArray = _loc2_.data;
         var _loc4_:int = this.alternativa3d::_attributesOffsets[VertexAttributes.POSITION] * 4;
         var _loc5_:int = _loc2_.attributes.length * 4;
         var _loc6_:int = int(this.alternativa3d::_indices.length);
         _loc8_ = 0;
         while(_loc8_ < _loc6_)
         {
            _loc9_ = int(this.alternativa3d::_indices[_loc8_]);
            _loc10_ = int(this.alternativa3d::_indices[_loc8_ + 1]);
            _loc11_ = int(this.alternativa3d::_indices[_loc8_ + 2]);
            _loc3_.position = _loc9_ * _loc5_ + _loc4_;
            _loc12_ = _loc3_.readFloat();
            _loc13_ = _loc3_.readFloat();
            _loc14_ = _loc3_.readFloat();
            _loc3_.position = _loc10_ * _loc5_ + _loc4_;
            _loc15_ = _loc3_.readFloat();
            _loc16_ = _loc3_.readFloat();
            _loc17_ = _loc3_.readFloat();
            _loc3_.position = _loc11_ * _loc5_ + _loc4_;
            _loc18_ = _loc3_.readFloat();
            _loc19_ = _loc3_.readFloat();
            _loc20_ = _loc3_.readFloat();
            _loc21_ = _loc15_ - _loc12_;
            _loc22_ = _loc16_ - _loc13_;
            _loc23_ = _loc17_ - _loc14_;
            _loc24_ = _loc18_ - _loc12_;
            _loc25_ = _loc19_ - _loc13_;
            _loc26_ = _loc20_ - _loc14_;
            _loc27_ = _loc26_ * _loc22_ - _loc25_ * _loc23_;
            _loc28_ = _loc24_ * _loc23_ - _loc26_ * _loc21_;
            _loc29_ = _loc25_ * _loc21_ - _loc24_ * _loc22_;
            _loc30_ = Math.sqrt(_loc27_ * _loc27_ + _loc28_ * _loc28_ + _loc29_ * _loc29_);
            if(_loc30_ > 0)
            {
               _loc27_ /= _loc30_;
               _loc28_ /= _loc30_;
               _loc29_ /= _loc30_;
            }
            _loc7_ = _loc1_[_loc9_];
            if(_loc7_ == null)
            {
               _loc1_[_loc9_] = new Vector3D(_loc27_,_loc28_,_loc29_);
            }
            else
            {
               _loc7_.x += _loc27_;
               _loc7_.y += _loc28_;
               _loc7_.z += _loc29_;
            }
            _loc7_ = _loc1_[_loc10_];
            if(_loc7_ == null)
            {
               _loc1_[_loc10_] = new Vector3D(_loc27_,_loc28_,_loc29_);
            }
            else
            {
               _loc7_.x += _loc27_;
               _loc7_.y += _loc28_;
               _loc7_.z += _loc29_;
            }
            _loc7_ = _loc1_[_loc11_];
            if(_loc7_ == null)
            {
               _loc1_[_loc11_] = new Vector3D(_loc27_,_loc28_,_loc29_);
            }
            else
            {
               _loc7_.x += _loc27_;
               _loc7_.y += _loc28_;
               _loc7_.z += _loc29_;
            }
            _loc8_ += 3;
         }
         if(this.hasAttribute(VertexAttributes.NORMAL))
         {
            _loc31_ = this.alternativa3d::_attributesOffsets[VertexAttributes.NORMAL] * 4;
            _loc32_ = this.alternativa3d::_attributesStreams[VertexAttributes.NORMAL];
            _loc33_ = _loc32_.data;
            _loc34_ = _loc32_.attributes.length * 4;
            _loc8_ = 0;
            while(_loc8_ < this.alternativa3d::_numVertices)
            {
               _loc7_ = _loc1_[_loc8_];
               _loc7_.normalize();
               _loc33_.position = _loc8_ * _loc34_ + _loc31_;
               _loc33_.writeFloat(_loc7_.x);
               _loc33_.writeFloat(_loc7_.y);
               _loc33_.writeFloat(_loc7_.z);
               _loc8_++;
            }
         }
         else
         {
            _loc35_ = new ByteArray();
            _loc35_.endian = Endian.LITTLE_ENDIAN;
            _loc8_ = 0;
            while(_loc8_ < this.alternativa3d::_numVertices)
            {
               _loc7_ = _loc1_[_loc8_];
               _loc7_.normalize();
               _loc35_.writeBytes(_loc3_,_loc8_ * _loc5_,_loc5_);
               _loc35_.writeFloat(_loc7_.x);
               _loc35_.writeFloat(_loc7_.y);
               _loc35_.writeFloat(_loc7_.z);
               _loc8_++;
            }
            _loc2_.attributes.push(VertexAttributes.NORMAL);
            _loc2_.attributes.push(VertexAttributes.NORMAL);
            _loc2_.attributes.push(VertexAttributes.NORMAL);
            _loc2_.data = _loc35_;
            _loc3_.clear();
            this.alternativa3d::_attributesOffsets[VertexAttributes.NORMAL] = _loc5_ / 4;
            this.alternativa3d::_attributesStreams[VertexAttributes.NORMAL] = _loc2_;
            this._attributesStrides[VertexAttributes.NORMAL] = 3;
         }
      }
      
      public function calculateTangents(param1:int) : void
      {
         var _loc16_:Vector3D = null;
         var _loc17_:Vector3D = null;
         var _loc18_:int = 0;
         var _loc19_:int = 0;
         var _loc20_:int = 0;
         var _loc21_:int = 0;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc25_:Number = NaN;
         var _loc26_:Number = NaN;
         var _loc27_:Number = NaN;
         var _loc28_:Number = NaN;
         var _loc29_:Number = NaN;
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
         var _loc59_:Number = NaN;
         var _loc60_:int = 0;
         var _loc61_:VertexStream = null;
         var _loc62_:ByteArray = null;
         var _loc63_:uint = 0;
         var _loc64_:ByteArray = null;
         if(!this.hasAttribute(VertexAttributes.POSITION))
         {
            throw new Error("Vertices positions is required to calculate normals");
         }
         if(!this.hasAttribute(VertexAttributes.NORMAL))
         {
            throw new Error("Vertices normals is required to calculate tangents, call calculateNormals first");
         }
         if(!this.hasAttribute(VertexAttributes.TEXCOORDS[param1]))
         {
            throw new Error("Specified uv channel does not exist in geometry");
         }
         var _loc2_:Array = [];
         var _loc3_:VertexStream = this.alternativa3d::_attributesStreams[VertexAttributes.POSITION];
         var _loc4_:ByteArray = _loc3_.data;
         var _loc5_:int = this.alternativa3d::_attributesOffsets[VertexAttributes.POSITION] * 4;
         var _loc6_:int = _loc3_.attributes.length * 4;
         var _loc7_:VertexStream = this.alternativa3d::_attributesStreams[VertexAttributes.NORMAL];
         var _loc8_:ByteArray = _loc7_.data;
         var _loc9_:int = this.alternativa3d::_attributesOffsets[VertexAttributes.NORMAL] * 4;
         var _loc10_:int = _loc7_.attributes.length * 4;
         var _loc11_:VertexStream = this.alternativa3d::_attributesStreams[VertexAttributes.TEXCOORDS[param1]];
         var _loc12_:ByteArray = _loc11_.data;
         var _loc13_:int = this.alternativa3d::_attributesOffsets[VertexAttributes.TEXCOORDS[param1]] * 4;
         var _loc14_:int = _loc11_.attributes.length * 4;
         var _loc15_:int = int(this.alternativa3d::_indices.length);
         _loc18_ = 0;
         while(_loc18_ < _loc15_)
         {
            _loc19_ = int(this.alternativa3d::_indices[_loc18_]);
            _loc20_ = int(this.alternativa3d::_indices[_loc18_ + 1]);
            _loc21_ = int(this.alternativa3d::_indices[_loc18_ + 2]);
            _loc4_.position = _loc19_ * _loc6_ + _loc5_;
            _loc22_ = _loc4_.readFloat();
            _loc23_ = _loc4_.readFloat();
            _loc24_ = _loc4_.readFloat();
            _loc4_.position = _loc20_ * _loc6_ + _loc5_;
            _loc25_ = _loc4_.readFloat();
            _loc26_ = _loc4_.readFloat();
            _loc27_ = _loc4_.readFloat();
            _loc4_.position = _loc21_ * _loc6_ + _loc5_;
            _loc28_ = _loc4_.readFloat();
            _loc29_ = _loc4_.readFloat();
            _loc30_ = _loc4_.readFloat();
            _loc12_.position = _loc19_ * _loc14_ + _loc13_;
            _loc31_ = _loc12_.readFloat();
            _loc32_ = _loc12_.readFloat();
            _loc12_.position = _loc20_ * _loc14_ + _loc13_;
            _loc33_ = _loc12_.readFloat();
            _loc34_ = _loc12_.readFloat();
            _loc12_.position = _loc21_ * _loc14_ + _loc13_;
            _loc35_ = _loc12_.readFloat();
            _loc36_ = _loc12_.readFloat();
            _loc8_.position = _loc19_ * _loc10_ + _loc9_;
            _loc37_ = _loc8_.readFloat();
            _loc38_ = _loc8_.readFloat();
            _loc39_ = _loc8_.readFloat();
            _loc8_.position = _loc20_ * _loc10_ + _loc9_;
            _loc40_ = _loc8_.readFloat();
            _loc41_ = _loc8_.readFloat();
            _loc42_ = _loc8_.readFloat();
            _loc8_.position = _loc21_ * _loc10_ + _loc9_;
            _loc43_ = _loc8_.readFloat();
            _loc44_ = _loc8_.readFloat();
            _loc45_ = _loc8_.readFloat();
            _loc46_ = _loc25_ - _loc22_;
            _loc47_ = _loc26_ - _loc23_;
            _loc48_ = _loc27_ - _loc24_;
            _loc49_ = _loc28_ - _loc22_;
            _loc50_ = _loc29_ - _loc23_;
            _loc51_ = _loc30_ - _loc24_;
            _loc52_ = _loc33_ - _loc31_;
            _loc53_ = _loc34_ - _loc32_;
            _loc54_ = _loc35_ - _loc31_;
            _loc55_ = _loc36_ - _loc32_;
            _loc56_ = 1 / (_loc52_ * _loc55_ - _loc54_ * _loc53_);
            _loc57_ = _loc56_ * (_loc55_ * _loc46_ - _loc49_ * _loc53_);
            _loc58_ = _loc56_ * (_loc55_ * _loc47_ - _loc53_ * _loc50_);
            _loc59_ = _loc56_ * (_loc55_ * _loc48_ - _loc53_ * _loc51_);
            _loc17_ = _loc2_[_loc19_];
            if(_loc17_ == null)
            {
               _loc2_[_loc19_] = new Vector3D(_loc57_ - _loc37_ * (_loc37_ * _loc57_ + _loc38_ * _loc58_ + _loc39_ * _loc59_),_loc58_ - _loc38_ * (_loc37_ * _loc57_ + _loc38_ * _loc58_ + _loc39_ * _loc59_),_loc59_ - _loc39_ * (_loc37_ * _loc57_ + _loc38_ * _loc58_ + _loc39_ * _loc59_));
            }
            else
            {
               _loc17_.x += _loc57_ - _loc37_ * (_loc37_ * _loc57_ + _loc38_ * _loc58_ + _loc39_ * _loc59_);
               _loc17_.y += _loc58_ - _loc38_ * (_loc37_ * _loc57_ + _loc38_ * _loc58_ + _loc39_ * _loc59_);
               _loc17_.z += _loc59_ - _loc39_ * (_loc37_ * _loc57_ + _loc38_ * _loc58_ + _loc39_ * _loc59_);
            }
            _loc17_ = _loc2_[_loc20_];
            if(_loc17_ == null)
            {
               _loc2_[_loc20_] = new Vector3D(_loc57_ - _loc40_ * (_loc40_ * _loc57_ + _loc41_ * _loc58_ + _loc42_ * _loc59_),_loc58_ - _loc41_ * (_loc40_ * _loc57_ + _loc41_ * _loc58_ + _loc42_ * _loc59_),_loc59_ - _loc42_ * (_loc40_ * _loc57_ + _loc41_ * _loc58_ + _loc42_ * _loc59_));
            }
            else
            {
               _loc17_.x += _loc57_ - _loc40_ * (_loc40_ * _loc57_ + _loc41_ * _loc58_ + _loc42_ * _loc59_);
               _loc17_.y += _loc58_ - _loc41_ * (_loc40_ * _loc57_ + _loc41_ * _loc58_ + _loc42_ * _loc59_);
               _loc17_.z += _loc59_ - _loc42_ * (_loc40_ * _loc57_ + _loc41_ * _loc58_ + _loc42_ * _loc59_);
            }
            _loc17_ = _loc2_[_loc21_];
            if(_loc17_ == null)
            {
               _loc2_[_loc21_] = new Vector3D(_loc57_ - _loc43_ * (_loc43_ * _loc57_ + _loc44_ * _loc58_ + _loc45_ * _loc59_),_loc58_ - _loc44_ * (_loc43_ * _loc57_ + _loc44_ * _loc58_ + _loc45_ * _loc59_),_loc59_ - _loc45_ * (_loc43_ * _loc57_ + _loc44_ * _loc58_ + _loc45_ * _loc59_));
            }
            else
            {
               _loc17_.x += _loc57_ - _loc43_ * (_loc43_ * _loc57_ + _loc44_ * _loc58_ + _loc45_ * _loc59_);
               _loc17_.y += _loc58_ - _loc44_ * (_loc43_ * _loc57_ + _loc44_ * _loc58_ + _loc45_ * _loc59_);
               _loc17_.z += _loc59_ - _loc45_ * (_loc43_ * _loc57_ + _loc44_ * _loc58_ + _loc45_ * _loc59_);
            }
            _loc18_ += 3;
         }
         if(this.hasAttribute(VertexAttributes.TANGENT4))
         {
            _loc60_ = this.alternativa3d::_attributesOffsets[VertexAttributes.TANGENT4] * 4;
            _loc61_ = this.alternativa3d::_attributesStreams[VertexAttributes.TANGENT4];
            _loc62_ = _loc61_.data;
            _loc63_ = _loc61_.attributes.length * 4;
            _loc18_ = 0;
            while(_loc18_ < this.alternativa3d::_numVertices)
            {
               _loc17_ = _loc2_[_loc18_];
               _loc17_.normalize();
               _loc62_.position = _loc18_ * _loc63_ + _loc60_;
               _loc62_.writeFloat(_loc17_.x);
               _loc62_.writeFloat(_loc17_.y);
               _loc62_.writeFloat(_loc17_.z);
               _loc62_.writeFloat(-1);
               _loc18_++;
            }
         }
         else
         {
            _loc64_ = new ByteArray();
            _loc64_.endian = Endian.LITTLE_ENDIAN;
            _loc18_ = 0;
            while(_loc18_ < this.alternativa3d::_numVertices)
            {
               _loc17_ = _loc2_[_loc18_];
               _loc17_.normalize();
               _loc64_.writeBytes(_loc4_,_loc18_ * _loc6_,_loc6_);
               _loc64_.writeFloat(_loc17_.x);
               _loc64_.writeFloat(_loc17_.y);
               _loc64_.writeFloat(_loc17_.z);
               _loc64_.writeFloat(-1);
               _loc18_++;
            }
            _loc3_.attributes.push(VertexAttributes.TANGENT4);
            _loc3_.attributes.push(VertexAttributes.TANGENT4);
            _loc3_.attributes.push(VertexAttributes.TANGENT4);
            _loc3_.attributes.push(VertexAttributes.TANGENT4);
            _loc3_.data = _loc64_;
            _loc4_.clear();
            this.alternativa3d::_attributesOffsets[VertexAttributes.TANGENT4] = _loc6_ / 4;
            this.alternativa3d::_attributesStreams[VertexAttributes.TANGENT4] = _loc3_;
            this._attributesStrides[VertexAttributes.TANGENT4] = 4;
         }
      }
      
      public function addVertexStream(param1:Array) : int
      {
         var _loc8_:uint = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc2_:int = int(param1.length);
         if(_loc2_ < 1)
         {
            throw new Error("Must be at least one attribute ​​to create the buffer.");
         }
         var _loc3_:VertexStream = new VertexStream();
         var _loc4_:int = int(this.alternativa3d::_vertexStreams.length);
         var _loc5_:uint = uint(param1[0]);
         var _loc6_:int = 1;
         var _loc7_:int = 1;
         while(_loc7_ <= _loc2_)
         {
            _loc8_ = _loc7_ < _loc2_ ? uint(param1[_loc7_]) : 0;
            if(_loc8_ != _loc5_)
            {
               if(_loc5_ != 0)
               {
                  if(_loc5_ < this.alternativa3d::_attributesStreams.length && this.alternativa3d::_attributesStreams[_loc5_] != null)
                  {
                     throw new Error("Attribute " + _loc5_ + " already used in this geometry.");
                  }
                  _loc9_ = VertexAttributes.getAttributeStride(_loc5_);
                  if(_loc9_ != 0 && _loc9_ != _loc6_)
                  {
                     throw new Error("Standard attributes must be predefined size.");
                  }
                  if(this.alternativa3d::_attributesStreams.length < _loc5_)
                  {
                     this.alternativa3d::_attributesStreams.length = _loc5_ + 1;
                     this.alternativa3d::_attributesOffsets.length = _loc5_ + 1;
                     this._attributesStrides.length = _loc5_ + 1;
                  }
                  _loc10_ = _loc7_ - _loc6_;
                  this.alternativa3d::_attributesStreams[_loc5_] = _loc3_;
                  this.alternativa3d::_attributesOffsets[_loc5_] = _loc10_;
                  this._attributesStrides[_loc5_] = _loc6_;
               }
               _loc6_ = 1;
            }
            else
            {
               _loc6_++;
            }
            _loc5_ = _loc8_;
            _loc7_++;
         }
         _loc3_.attributes = param1.slice();
         _loc3_.data = new ByteArray();
         _loc3_.data.endian = Endian.LITTLE_ENDIAN;
         _loc3_.data.length = 4 * _loc2_ * this.alternativa3d::_numVertices;
         this.alternativa3d::_vertexStreams[_loc4_] = _loc3_;
         return _loc4_;
      }
      
      public function get numVertexStreams() : int
      {
         return this.alternativa3d::_vertexStreams.length;
      }
      
      public function getVertexStreamAttributes(param1:int) : Array
      {
         return this.alternativa3d::_vertexStreams[param1].attributes.slice();
      }
      
      public function hasAttribute(param1:uint) : Boolean
      {
         return param1 < this.alternativa3d::_attributesStreams.length && this.alternativa3d::_attributesStreams[param1] != null;
      }
      
      public function findVertexStreamByAttribute(param1:uint) : int
      {
         var _loc3_:int = 0;
         var _loc2_:VertexStream = param1 < this.alternativa3d::_attributesStreams.length ? this.alternativa3d::_attributesStreams[param1] : null;
         if(_loc2_ != null)
         {
            _loc3_ = 0;
            while(_loc3_ < this.alternativa3d::_vertexStreams.length)
            {
               if(this.alternativa3d::_vertexStreams[_loc3_] == _loc2_)
               {
                  return _loc3_;
               }
               _loc3_++;
            }
         }
         return -1;
      }
      
      public function getAttributeOffset(param1:uint) : int
      {
         var _loc2_:VertexStream = param1 < this.alternativa3d::_attributesStreams.length ? this.alternativa3d::_attributesStreams[param1] : null;
         if(_loc2_ == null)
         {
            throw new Error("Attribute not found.");
         }
         return this.alternativa3d::_attributesOffsets[param1];
      }
      
      public function setAttributeValues(param1:uint, param2:Vector.<Number>) : void
      {
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc3_:VertexStream = param1 < this.alternativa3d::_attributesStreams.length ? this.alternativa3d::_attributesStreams[param1] : null;
         if(_loc3_ == null)
         {
            throw new Error("Attribute not found.");
         }
         var _loc4_:int = this._attributesStrides[param1];
         if(param2 == null || param2.length != _loc4_ * this.alternativa3d::_numVertices)
         {
            throw new Error("Values count must be the same.");
         }
         var _loc5_:int = int(_loc3_.attributes.length);
         var _loc6_:ByteArray = _loc3_.data;
         var _loc7_:int = this.alternativa3d::_attributesOffsets[param1];
         var _loc8_:int = 0;
         while(_loc8_ < this.alternativa3d::_numVertices)
         {
            _loc9_ = _loc4_ * _loc8_;
            _loc6_.position = 4 * (_loc5_ * _loc8_ + _loc7_);
            _loc10_ = 0;
            while(_loc10_ < _loc4_)
            {
               _loc6_.writeFloat(param2[int(_loc9_ + _loc10_)]);
               _loc10_++;
            }
            _loc8_++;
         }
      }
      
      public function getAttributeValues(param1:uint) : Vector.<Number>
      {
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc2_:VertexStream = param1 < this.alternativa3d::_attributesStreams.length ? this.alternativa3d::_attributesStreams[param1] : null;
         if(_loc2_ == null)
         {
            throw new Error("Attribute not found.");
         }
         var _loc3_:ByteArray = _loc2_.data;
         var _loc4_:int = this._attributesStrides[param1];
         var _loc5_:Vector.<Number> = new Vector.<Number>(_loc4_ * this.alternativa3d::_numVertices);
         var _loc6_:int = int(_loc2_.attributes.length);
         var _loc7_:int = this.alternativa3d::_attributesOffsets[param1];
         var _loc8_:int = 0;
         while(_loc8_ < this.alternativa3d::_numVertices)
         {
            _loc3_.position = 4 * (_loc6_ * _loc8_ + _loc7_);
            _loc9_ = _loc4_ * _loc8_;
            _loc10_ = 0;
            while(_loc10_ < _loc4_)
            {
               _loc5_[int(_loc9_ + _loc10_)] = _loc3_.readFloat();
               _loc10_++;
            }
            _loc8_++;
         }
         return _loc5_;
      }
      
      override public function get isUploaded() : Boolean
      {
         return this.alternativa3d::_indexBuffer != null;
      }
      
      override public function upload(param1:Context3D) : void
      {
         var _loc2_:VertexStream = null;
         var _loc3_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:ByteArray = null;
         var _loc4_:int = int(this.alternativa3d::_vertexStreams.length);
         if(this.alternativa3d::_indexBuffer != null)
         {
            this.alternativa3d::_indexBuffer.dispose();
            this.alternativa3d::_indexBuffer = null;
            _loc3_ = 0;
            while(_loc3_ < _loc4_)
            {
               _loc2_ = this.alternativa3d::_vertexStreams[_loc3_];
               if(_loc2_.buffer != null)
               {
                  _loc2_.buffer.dispose();
                  _loc2_.buffer = null;
               }
               _loc3_++;
            }
         }
         if(this.alternativa3d::_indices.length <= 0 || this.alternativa3d::_numVertices <= 0)
         {
            return;
         }
         _loc3_ = 0;
         while(_loc3_ < _loc4_)
         {
            _loc2_ = this.alternativa3d::_vertexStreams[_loc3_];
            _loc6_ = int(_loc2_.attributes.length);
            _loc7_ = _loc2_.data;
            if(_loc7_ == null)
            {
               throw new Error("Cannot upload without vertex buffer data.");
            }
            _loc2_.buffer = param1.createVertexBuffer(this.alternativa3d::_numVertices,_loc6_);
            _loc2_.buffer.uploadFromByteArray(_loc7_,0,0,this.alternativa3d::_numVertices);
            _loc3_++;
         }
         var _loc5_:int = int(this.alternativa3d::_indices.length);
         this.alternativa3d::_indexBuffer = param1.createIndexBuffer(_loc5_);
         this.alternativa3d::_indexBuffer.uploadFromVector(this.alternativa3d::_indices,0,_loc5_);
         _disposed = false;
      }
      
      override public function dispose() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:VertexStream = null;
         if(this.alternativa3d::_indexBuffer != null)
         {
            this.alternativa3d::_indexBuffer.dispose();
            this.alternativa3d::_indexBuffer = null;
            _loc1_ = int(this.alternativa3d::_vertexStreams.length);
            _loc2_ = 0;
            while(_loc2_ < _loc1_)
            {
               _loc3_ = this.alternativa3d::_vertexStreams[_loc2_];
               _loc3_.buffer.dispose();
               _loc3_.buffer = null;
               _loc2_++;
            }
         }
      }
      
      public function updateIndexBufferInContextFromVector(param1:Vector.<uint>, param2:int, param3:int) : void
      {
         if(this.alternativa3d::_indexBuffer == null)
         {
            throw new Error("Geometry must be uploaded.");
         }
         this.alternativa3d::_indexBuffer.uploadFromVector(param1,param2,param3);
      }
      
      public function updateIndexBufferInContextFromByteArray(param1:ByteArray, param2:int, param3:int, param4:int) : void
      {
         if(this.alternativa3d::_indexBuffer == null)
         {
            throw new Error("Geometry must be uploaded.");
         }
         this.alternativa3d::_indexBuffer.uploadFromByteArray(param1,param2,param3,param4);
      }
      
      public function updateVertexBufferInContextFromVector(param1:int, param2:Vector.<Number>, param3:int, param4:int) : void
      {
         if(this.alternativa3d::_indexBuffer == null)
         {
            throw new Error("Geometry must be uploaded.");
         }
         this.alternativa3d::_vertexStreams[param1].buffer.uploadFromVector(param2,param3,param4);
      }
      
      public function updateVertexBufferInContextFromByteArray(param1:int, param2:ByteArray, param3:int, param4:int, param5:int) : void
      {
         if(this.alternativa3d::_indexBuffer == null)
         {
            throw new Error("Geometry must be uploaded.");
         }
         this.alternativa3d::_vertexStreams[param1].buffer.uploadFromByteArray(param2,param3,param4,param5);
      }
      
      alternativa3d function intersectRay(param1:Vector3D, param2:Vector3D, param3:uint, param4:uint) : RayIntersectionData
      {
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
         var _loc28_:Number = NaN;
         var _loc29_:Vector3D = null;
         var _loc33_:VertexStream = null;
         var _loc37_:VertexStream = null;
         var _loc39_:ByteArray = null;
         var _loc40_:uint = 0;
         var _loc41_:uint = 0;
         var _loc44_:uint = 0;
         var _loc45_:uint = 0;
         var _loc46_:uint = 0;
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
         var _loc59_:Number = NaN;
         var _loc60_:Number = NaN;
         var _loc61_:Number = NaN;
         var _loc62_:Number = NaN;
         var _loc63_:Number = NaN;
         var _loc64_:Number = NaN;
         var _loc65_:Number = NaN;
         var _loc66_:Number = NaN;
         var _loc67_:Number = NaN;
         var _loc68_:Number = NaN;
         var _loc69_:Number = NaN;
         var _loc70_:Number = NaN;
         var _loc71_:Number = NaN;
         var _loc72_:Number = NaN;
         var _loc73_:Number = NaN;
         var _loc74_:Number = NaN;
         var _loc75_:Number = NaN;
         var _loc76_:Number = NaN;
         var _loc77_:Number = NaN;
         var _loc78_:RayIntersectionData = null;
         var _loc79_:Number = NaN;
         var _loc80_:Number = NaN;
         var _loc81_:Number = NaN;
         var _loc82_:Number = NaN;
         var _loc83_:Number = NaN;
         var _loc84_:Number = NaN;
         var _loc85_:Number = NaN;
         var _loc86_:Number = NaN;
         var _loc87_:Number = NaN;
         var _loc88_:Number = NaN;
         var _loc89_:Number = NaN;
         var _loc90_:Number = NaN;
         var _loc91_:Number = NaN;
         var _loc92_:Number = NaN;
         var _loc93_:Number = NaN;
         var _loc94_:Number = NaN;
         var _loc95_:Number = NaN;
         var _loc96_:Number = NaN;
         var _loc97_:Number = NaN;
         var _loc98_:Number = NaN;
         var _loc99_:Number = NaN;
         var _loc5_:Number = param1.x;
         var _loc6_:Number = param1.y;
         var _loc7_:Number = param1.z;
         var _loc8_:Number = param2.x;
         var _loc9_:Number = param2.y;
         var _loc10_:Number = param2.z;
         var _loc30_:Number = 1e+22;
         var _loc31_:int = int(VertexAttributes.POSITION);
         var _loc32_:int = int(VertexAttributes.TEXCOORDS[0]);
         if(VertexAttributes.POSITION >= this.alternativa3d::_attributesStreams.length || (_loc33_ = this.alternativa3d::_attributesStreams[_loc31_]) == null)
         {
            throw new Error("Raycast require POSITION attribute");
         }
         var _loc34_:ByteArray = _loc33_.data;
         var _loc35_:uint = uint(this.alternativa3d::_attributesOffsets[_loc31_] * 4);
         var _loc36_:uint = _loc33_.attributes.length * 4;
         var _loc38_:Boolean = _loc32_ < this.alternativa3d::_attributesStreams.length && (_loc37_ = this.alternativa3d::_attributesStreams[_loc32_]) != null;
         if(_loc38_)
         {
            _loc39_ = _loc37_.data;
            _loc40_ = uint(this.alternativa3d::_attributesOffsets[_loc32_] * 4);
            _loc41_ = _loc37_.attributes.length * 4;
         }
         if(param4 * 3 > this.indices.length)
         {
            throw new ArgumentError("index is out of bounds");
         }
         var _loc42_:int = int(param3);
         var _loc43_:int = param3 + param4 * 3;
         while(_loc42_ < _loc43_)
         {
            _loc44_ = this.indices[_loc42_];
            _loc45_ = this.indices[int(_loc42_ + 1)];
            _loc46_ = this.indices[int(_loc42_ + 2)];
            _loc34_.position = _loc44_ * _loc36_ + _loc35_;
            _loc47_ = _loc34_.readFloat();
            _loc48_ = _loc34_.readFloat();
            _loc49_ = _loc34_.readFloat();
            _loc34_.position = _loc45_ * _loc36_ + _loc35_;
            _loc52_ = _loc34_.readFloat();
            _loc53_ = _loc34_.readFloat();
            _loc54_ = _loc34_.readFloat();
            _loc34_.position = _loc46_ * _loc36_ + _loc35_;
            _loc57_ = _loc34_.readFloat();
            _loc58_ = _loc34_.readFloat();
            _loc59_ = _loc34_.readFloat();
            if(_loc38_)
            {
               _loc39_.position = _loc44_ * _loc41_ + _loc40_;
               _loc50_ = _loc39_.readFloat();
               _loc51_ = _loc39_.readFloat();
               _loc39_.position = _loc45_ * _loc41_ + _loc40_;
               _loc55_ = _loc39_.readFloat();
               _loc56_ = _loc39_.readFloat();
               _loc39_.position = _loc46_ * _loc41_ + _loc40_;
               _loc60_ = _loc39_.readFloat();
               _loc61_ = _loc39_.readFloat();
            }
            _loc62_ = _loc52_ - _loc47_;
            _loc63_ = _loc53_ - _loc48_;
            _loc64_ = _loc54_ - _loc49_;
            _loc65_ = _loc57_ - _loc47_;
            _loc66_ = _loc58_ - _loc48_;
            _loc67_ = _loc59_ - _loc49_;
            _loc68_ = _loc67_ * _loc63_ - _loc66_ * _loc64_;
            _loc69_ = _loc65_ * _loc64_ - _loc67_ * _loc62_;
            _loc70_ = _loc66_ * _loc62_ - _loc65_ * _loc63_;
            _loc71_ = _loc68_ * _loc68_ + _loc69_ * _loc69_ + _loc70_ * _loc70_;
            if(_loc71_ > 0.001)
            {
               _loc71_ = 1 / Math.sqrt(_loc71_);
               _loc68_ *= _loc71_;
               _loc69_ *= _loc71_;
               _loc70_ *= _loc71_;
            }
            _loc72_ = _loc8_ * _loc68_ + _loc9_ * _loc69_ + _loc10_ * _loc70_;
            if(_loc72_ < 0)
            {
               _loc73_ = _loc5_ * _loc68_ + _loc6_ * _loc69_ + _loc7_ * _loc70_ - (_loc47_ * _loc68_ + _loc48_ * _loc69_ + _loc49_ * _loc70_);
               if(_loc73_ > 0)
               {
                  _loc74_ = -_loc73_ / _loc72_;
                  if(_loc29_ == null || _loc74_ < _loc30_)
                  {
                     _loc75_ = _loc5_ + _loc8_ * _loc74_;
                     _loc76_ = _loc6_ + _loc9_ * _loc74_;
                     _loc77_ = _loc7_ + _loc10_ * _loc74_;
                     _loc62_ = _loc52_ - _loc47_;
                     _loc63_ = _loc53_ - _loc48_;
                     _loc64_ = _loc54_ - _loc49_;
                     _loc65_ = _loc75_ - _loc47_;
                     _loc66_ = _loc76_ - _loc48_;
                     _loc67_ = _loc77_ - _loc49_;
                     if((_loc67_ * _loc63_ - _loc66_ * _loc64_) * _loc68_ + (_loc65_ * _loc64_ - _loc67_ * _loc62_) * _loc69_ + (_loc66_ * _loc62_ - _loc65_ * _loc63_) * _loc70_ >= 0)
                     {
                        _loc62_ = _loc57_ - _loc52_;
                        _loc63_ = _loc58_ - _loc53_;
                        _loc64_ = _loc59_ - _loc54_;
                        _loc65_ = _loc75_ - _loc52_;
                        _loc66_ = _loc76_ - _loc53_;
                        _loc67_ = _loc77_ - _loc54_;
                        if((_loc67_ * _loc63_ - _loc66_ * _loc64_) * _loc68_ + (_loc65_ * _loc64_ - _loc67_ * _loc62_) * _loc69_ + (_loc66_ * _loc62_ - _loc65_ * _loc63_) * _loc70_ >= 0)
                        {
                           _loc62_ = _loc47_ - _loc57_;
                           _loc63_ = _loc48_ - _loc58_;
                           _loc64_ = _loc49_ - _loc59_;
                           _loc65_ = _loc75_ - _loc57_;
                           _loc66_ = _loc76_ - _loc58_;
                           _loc67_ = _loc77_ - _loc59_;
                           if((_loc67_ * _loc63_ - _loc66_ * _loc64_) * _loc68_ + (_loc65_ * _loc64_ - _loc67_ * _loc62_) * _loc69_ + (_loc66_ * _loc62_ - _loc65_ * _loc63_) * _loc70_ >= 0)
                           {
                              if(_loc74_ < _loc30_)
                              {
                                 _loc30_ = _loc74_;
                                 if(_loc29_ == null)
                                 {
                                    _loc29_ = new Vector3D();
                                 }
                                 _loc29_.x = _loc75_;
                                 _loc29_.y = _loc76_;
                                 _loc29_.z = _loc77_;
                                 _loc11_ = _loc47_;
                                 _loc12_ = _loc48_;
                                 _loc13_ = _loc49_;
                                 _loc14_ = _loc50_;
                                 _loc15_ = _loc51_;
                                 _loc26_ = _loc68_;
                                 _loc16_ = _loc52_;
                                 _loc17_ = _loc53_;
                                 _loc18_ = _loc54_;
                                 _loc19_ = _loc55_;
                                 _loc20_ = _loc56_;
                                 _loc27_ = _loc69_;
                                 _loc21_ = _loc57_;
                                 _loc22_ = _loc58_;
                                 _loc23_ = _loc59_;
                                 _loc24_ = _loc60_;
                                 _loc25_ = _loc61_;
                                 _loc28_ = _loc70_;
                              }
                           }
                        }
                     }
                  }
               }
            }
            _loc42_ += 3;
         }
         if(_loc29_ != null)
         {
            _loc78_ = new RayIntersectionData();
            _loc78_.point = _loc29_;
            _loc78_.time = _loc30_;
            if(_loc38_)
            {
               _loc62_ = _loc16_ - _loc11_;
               _loc63_ = _loc17_ - _loc12_;
               _loc64_ = _loc18_ - _loc13_;
               _loc79_ = _loc19_ - _loc14_;
               _loc80_ = _loc20_ - _loc15_;
               _loc65_ = _loc21_ - _loc11_;
               _loc66_ = _loc22_ - _loc12_;
               _loc67_ = _loc23_ - _loc13_;
               _loc81_ = _loc24_ - _loc14_;
               _loc82_ = _loc25_ - _loc15_;
               _loc83_ = -_loc26_ * _loc66_ * _loc64_ + _loc65_ * _loc27_ * _loc64_ + _loc26_ * _loc63_ * _loc67_ - _loc62_ * _loc27_ * _loc67_ - _loc65_ * _loc63_ * _loc28_ + _loc62_ * _loc66_ * _loc28_;
               _loc84_ = (-_loc27_ * _loc67_ + _loc66_ * _loc28_) / _loc83_;
               _loc85_ = (_loc26_ * _loc67_ - _loc65_ * _loc28_) / _loc83_;
               _loc86_ = (-_loc26_ * _loc66_ + _loc65_ * _loc27_) / _loc83_;
               _loc87_ = (_loc11_ * _loc27_ * _loc67_ - _loc26_ * _loc12_ * _loc67_ - _loc11_ * _loc66_ * _loc28_ + _loc65_ * _loc12_ * _loc28_ + _loc26_ * _loc66_ * _loc13_ - _loc65_ * _loc27_ * _loc13_) / _loc83_;
               _loc88_ = (_loc27_ * _loc64_ - _loc63_ * _loc28_) / _loc83_;
               _loc89_ = (-_loc26_ * _loc64_ + _loc62_ * _loc28_) / _loc83_;
               _loc90_ = (_loc26_ * _loc63_ - _loc62_ * _loc27_) / _loc83_;
               _loc91_ = (_loc26_ * _loc12_ * _loc64_ - _loc11_ * _loc27_ * _loc64_ + _loc11_ * _loc63_ * _loc28_ - _loc62_ * _loc12_ * _loc28_ - _loc26_ * _loc63_ * _loc13_ + _loc62_ * _loc27_ * _loc13_) / _loc83_;
               _loc92_ = _loc79_ * _loc84_ + _loc81_ * _loc88_;
               _loc93_ = _loc79_ * _loc85_ + _loc81_ * _loc89_;
               _loc94_ = _loc79_ * _loc86_ + _loc81_ * _loc90_;
               _loc95_ = _loc79_ * _loc87_ + _loc81_ * _loc91_ + _loc14_;
               _loc96_ = _loc80_ * _loc84_ + _loc82_ * _loc88_;
               _loc97_ = _loc80_ * _loc85_ + _loc82_ * _loc89_;
               _loc98_ = _loc80_ * _loc86_ + _loc82_ * _loc90_;
               _loc99_ = _loc80_ * _loc87_ + _loc82_ * _loc91_ + _loc15_;
               _loc78_.uv = new Point(_loc92_ * _loc29_.x + _loc93_ * _loc29_.y + _loc94_ * _loc29_.z + _loc95_,_loc96_ * _loc29_.x + _loc97_ * _loc29_.y + _loc98_ * _loc29_.z + _loc99_);
            }
            return _loc78_;
         }
         return null;
      }
      
      alternativa3d function getVertexBuffer(param1:int) : VertexBuffer3D
      {
         var _loc2_:VertexStream = null;
         if(param1 < this.alternativa3d::_attributesStreams.length)
         {
            _loc2_ = this.alternativa3d::_attributesStreams[param1];
            return _loc2_ != null ? _loc2_.buffer : null;
         }
         return null;
      }
      
      alternativa3d function updateBoundBox(param1:BoundBox, param2:Transform3D = null) : void
      {
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc3_:VertexStream = VertexAttributes.POSITION < this.alternativa3d::_attributesStreams.length ? this.alternativa3d::_attributesStreams[VertexAttributes.POSITION] : null;
         if(_loc3_ == null)
         {
            throw new Error("Cannot calculate BoundBox without data.");
         }
         var _loc4_:int = this.alternativa3d::_attributesOffsets[VertexAttributes.POSITION];
         var _loc5_:int = int(_loc3_.attributes.length);
         var _loc6_:ByteArray = _loc3_.data;
         var _loc7_:int = 0;
         while(_loc7_ < this.alternativa3d::_numVertices)
         {
            _loc6_.position = 4 * (_loc5_ * _loc7_ + _loc4_);
            _loc8_ = _loc6_.readFloat();
            _loc9_ = _loc6_.readFloat();
            _loc10_ = _loc6_.readFloat();
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
            _loc7_++;
         }
      }
   }
}

