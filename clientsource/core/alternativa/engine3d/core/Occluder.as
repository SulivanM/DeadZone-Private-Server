package alternativa.engine3d.core
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.objects.WireFrame;
   import alternativa.engine3d.resources.Geometry;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   
   use namespace alternativa3d;
   
   public class Occluder extends Object3D
   {
      
      private var faceList:Face;
      
      private var edgeList:Edge;
      
      private var vertexList:Vertex;
      
      private var debugWire:WireFrame;
      
      alternativa3d var planeList:CullingPlane;
      
      alternativa3d var enabled:Boolean;
      
      public var minSize:Number = 0;
      
      public function Occluder()
      {
         super();
      }
      
      public function createForm(param1:Geometry, param2:Number = 0, param3:Boolean = true, param4:Number = 0, param5:Number = 0) : void
      {
         var _loc8_:int = 0;
         var _loc14_:Vertex = null;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc18_:Face = null;
         this.destroyForm();
         var _loc6_:int = int(param1.alternativa3d::_indices.length);
         if(param1.alternativa3d::_numVertices == 0 || _loc6_ == 0)
         {
            throw new Error("The supplied geometry is empty.");
         }
         var _loc7_:VertexStream = VertexAttributes.POSITION < param1.alternativa3d::_attributesStreams.length ? param1.alternativa3d::_attributesStreams[VertexAttributes.POSITION] : null;
         if(_loc7_ == null)
         {
            throw new Error("The supplied geometry is empty.");
         }
         var _loc9_:Vector.<Vertex> = new Vector.<Vertex>();
         var _loc10_:int = param1.alternativa3d::_attributesOffsets[VertexAttributes.POSITION];
         var _loc11_:int = int(_loc7_.attributes.length);
         var _loc12_:ByteArray = _loc7_.data;
         _loc8_ = 0;
         while(_loc8_ < param1.alternativa3d::_numVertices)
         {
            _loc12_.position = 4 * (_loc11_ * _loc8_ + _loc10_);
            _loc14_ = new Vertex();
            _loc14_.x = _loc12_.readFloat();
            _loc14_.y = _loc12_.readFloat();
            _loc14_.z = _loc12_.readFloat();
            _loc9_[_loc8_] = _loc14_;
            _loc8_++;
         }
         _loc8_ = 0;
         while(_loc8_ < _loc6_)
         {
            _loc15_ = int(param1.alternativa3d::_indices[_loc8_]);
            _loc8_++;
            _loc16_ = int(param1.alternativa3d::_indices[_loc8_]);
            _loc8_++;
            _loc17_ = int(param1.alternativa3d::_indices[_loc8_]);
            _loc8_++;
            _loc18_ = new Face();
            _loc18_.wrapper = new Wrapper();
            _loc18_.wrapper.vertex = _loc9_[_loc15_];
            _loc18_.wrapper.next = new Wrapper();
            _loc18_.wrapper.next.vertex = _loc9_[_loc16_];
            _loc18_.wrapper.next.next = new Wrapper();
            _loc18_.wrapper.next.next.vertex = _loc9_[_loc17_];
            _loc18_.calculateBestSequenceAndNormal();
            _loc18_.next = this.faceList;
            this.faceList = _loc18_;
         }
         this.vertexList = this.weldVertices(_loc9_,param2);
         if(param3)
         {
            this.weldFaces(param4,param5);
         }
         var _loc13_:String = this.calculateEdges();
         if(_loc13_ != null)
         {
            this.destroyForm();
            throw new ArgumentError(_loc13_);
         }
         calculateBoundBox();
      }
      
      public function destroyForm() : void
      {
         this.faceList = null;
         this.edgeList = null;
         this.vertexList = null;
         if(this.debugWire != null)
         {
            this.debugWire.alternativa3d::geometry.dispose();
            this.debugWire = null;
         }
      }
      
      override alternativa3d function calculateVisibility(param1:Camera3D) : void
      {
         param1.alternativa3d::occluders[param1.alternativa3d::occludersLength] = this;
         ++param1.alternativa3d::occludersLength;
      }
      
      override alternativa3d function collectDraws(param1:Camera3D, param2:Vector.<Light3D>, param3:int, param4:Boolean) : void
      {
         var _loc5_:Edge = null;
         if(param1.debug)
         {
            if(param1.alternativa3d::checkInDebug(this) & Debug.CONTENT)
            {
               if(this.debugWire == null)
               {
                  this.debugWire = new WireFrame(16711935,1,2);
                  _loc5_ = this.edgeList;
                  while(_loc5_ != null)
                  {
                     this.debugWire.alternativa3d::geometry.alternativa3d::addLine(_loc5_.a.x,_loc5_.a.y,_loc5_.a.z,_loc5_.b.x,_loc5_.b.y,_loc5_.b.z);
                     _loc5_ = _loc5_.next;
                  }
                  this.debugWire.alternativa3d::geometry.upload(param1.alternativa3d::context3D);
               }
               this.debugWire.alternativa3d::localToCameraTransform.copy(alternativa3d::localToCameraTransform);
               this.debugWire.alternativa3d::collectDraws(param1,null,0,false);
            }
         }
      }
      
      private function calculateEdges() : String
      {
         var _loc1_:Face = null;
         var _loc2_:Wrapper = null;
         var _loc3_:Edge = null;
         var _loc4_:Vertex = null;
         var _loc5_:Vertex = null;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         _loc1_ = this.faceList;
         while(_loc1_ != null)
         {
            _loc2_ = _loc1_.wrapper;
            while(_loc2_ != null)
            {
               _loc4_ = _loc2_.vertex;
               _loc5_ = _loc2_.next != null ? _loc2_.next.vertex : _loc1_.wrapper.vertex;
               _loc3_ = this.edgeList;
               while(_loc3_ != null)
               {
                  if(_loc3_.a == _loc4_ && _loc3_.b == _loc5_)
                  {
                     return "The supplied geometry is not valid.";
                  }
                  if(_loc3_.a == _loc5_ && _loc3_.b == _loc4_)
                  {
                     break;
                  }
                  _loc3_ = _loc3_.next;
               }
               if(_loc3_ != null)
               {
                  _loc3_.right = _loc1_;
               }
               else
               {
                  _loc3_ = new Edge();
                  _loc3_.a = _loc4_;
                  _loc3_.b = _loc5_;
                  _loc3_.left = _loc1_;
                  _loc3_.next = this.edgeList;
                  this.edgeList = _loc3_;
               }
               _loc2_ = _loc2_.next;
               _loc4_ = _loc5_;
            }
            _loc1_ = _loc1_.next;
         }
         _loc3_ = this.edgeList;
         while(_loc3_ != null)
         {
            if(_loc3_.left == null || _loc3_.right == null)
            {
               return "The supplied geometry is non whole.";
            }
            _loc6_ = _loc3_.b.x - _loc3_.a.x;
            _loc7_ = _loc3_.b.y - _loc3_.a.y;
            _loc8_ = _loc3_.b.z - _loc3_.a.z;
            _loc9_ = _loc3_.right.normalZ * _loc3_.left.normalY - _loc3_.right.normalY * _loc3_.left.normalZ;
            _loc10_ = _loc3_.right.normalX * _loc3_.left.normalZ - _loc3_.right.normalZ * _loc3_.left.normalX;
            _loc11_ = _loc3_.right.normalY * _loc3_.left.normalX - _loc3_.right.normalX * _loc3_.left.normalY;
            if(_loc6_ * _loc9_ + _loc7_ * _loc10_ + _loc8_ * _loc11_ < 0)
            {
            }
            _loc3_ = _loc3_.next;
         }
         return null;
      }
      
      private function weldVertices(param1:Vector.<Vertex>, param2:Number) : Vertex
      {
         var _loc3_:Vertex = null;
         var _loc6_:Vertex = null;
         var _loc8_:Wrapper = null;
         var _loc4_:int = int(param1.length);
         this.group(param1,0,_loc4_,0,param2,new Vector.<int>());
         var _loc5_:Face = this.faceList;
         while(_loc5_ != null)
         {
            _loc8_ = _loc5_.wrapper;
            while(_loc8_ != null)
            {
               if(_loc8_.vertex.value != null)
               {
                  _loc8_.vertex = _loc8_.vertex.value;
               }
               _loc8_ = _loc8_.next;
            }
            _loc5_ = _loc5_.next;
         }
         var _loc7_:int = 0;
         while(_loc7_ < _loc4_)
         {
            _loc3_ = param1[_loc7_];
            if(_loc3_.value == null)
            {
               _loc3_.next = _loc6_;
               _loc6_ = _loc3_;
            }
            _loc7_++;
         }
         return _loc6_;
      }
      
      private function group(param1:Vector.<Vertex>, param2:int, param3:int, param4:int, param5:Number, param6:Vector.<int>) : void
      {
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:Vertex = null;
         var _loc11_:Vertex = null;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:Number = NaN;
         var _loc15_:Vertex = null;
         var _loc16_:Vertex = null;
         switch(param4)
         {
            case 0:
               _loc7_ = param2;
               while(_loc7_ < param3)
               {
                  _loc9_ = param1[_loc7_];
                  _loc9_.offset = _loc9_.x;
                  _loc7_++;
               }
               break;
            case 1:
               _loc7_ = param2;
               while(_loc7_ < param3)
               {
                  _loc9_ = param1[_loc7_];
                  _loc9_.offset = _loc9_.y;
                  _loc7_++;
               }
               break;
            case 2:
               _loc7_ = param2;
               while(_loc7_ < param3)
               {
                  _loc9_ = param1[_loc7_];
                  _loc9_.offset = _loc9_.z;
                  _loc7_++;
               }
         }
         param6[0] = param2;
         param6[1] = param3 - 1;
         var _loc10_:int = 2;
         while(_loc10_ > 0)
         {
            _loc10_--;
            _loc8_ = _loc12_ = param6[_loc10_];
            _loc10_--;
            _loc7_ = _loc13_ = param6[_loc10_];
            _loc9_ = param1[_loc12_ + _loc13_ >> 1];
            _loc14_ = _loc9_.offset;
            while(_loc7_ <= _loc8_)
            {
               _loc15_ = param1[_loc7_];
               while(_loc15_.offset > _loc14_)
               {
                  _loc7_++;
                  _loc15_ = param1[_loc7_];
               }
               _loc16_ = param1[_loc8_];
               while(_loc16_.offset < _loc14_)
               {
                  _loc8_--;
                  _loc16_ = param1[_loc8_];
               }
               if(_loc7_ <= _loc8_)
               {
                  param1[_loc7_] = _loc16_;
                  param1[_loc8_] = _loc15_;
                  _loc7_++;
                  _loc8_--;
               }
            }
            if(_loc13_ < _loc8_)
            {
               param6[_loc10_] = _loc13_;
               _loc10_++;
               param6[_loc10_] = _loc8_;
               _loc10_++;
            }
            if(_loc7_ < _loc12_)
            {
               param6[_loc10_] = _loc7_;
               _loc10_++;
               param6[_loc10_] = _loc12_;
               _loc10_++;
            }
         }
         _loc7_ = param2;
         _loc9_ = param1[_loc7_];
         _loc8_ = _loc7_ + 1;
         while(_loc8_ <= param3)
         {
            if(_loc8_ < param3)
            {
               _loc11_ = param1[_loc8_];
            }
            if(_loc8_ == param3 || _loc9_.offset - _loc11_.offset > param5)
            {
               if(param4 < 2 && _loc8_ - _loc7_ > 1)
               {
                  this.group(param1,_loc7_,_loc8_,param4 + 1,param5,param6);
               }
               if(_loc8_ < param3)
               {
                  _loc7_ = _loc8_;
                  _loc9_ = param1[_loc7_];
               }
            }
            else if(param4 == 2)
            {
               _loc11_.value = _loc9_;
            }
            _loc8_++;
         }
      }
      
      private function weldFaces(param1:Number = 0, param2:Number = 0) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:* = undefined;
         var _loc6_:Face = null;
         var _loc7_:Face = null;
         var _loc8_:Face = null;
         var _loc9_:Wrapper = null;
         var _loc10_:Wrapper = null;
         var _loc11_:Wrapper = null;
         var _loc12_:Wrapper = null;
         var _loc13_:Wrapper = null;
         var _loc14_:Wrapper = null;
         var _loc15_:Wrapper = null;
         var _loc16_:Wrapper = null;
         var _loc17_:Vertex = null;
         var _loc18_:Vertex = null;
         var _loc19_:Vertex = null;
         var _loc20_:Vertex = null;
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
         var _loc31_:Dictionary = null;
         var _loc38_:int = 0;
         var _loc39_:Boolean = false;
         var _loc40_:Face = null;
         var _loc32_:Number = 0.001;
         param1 = Math.cos(param1) - _loc32_;
         param2 = Math.cos(Math.PI - param2) - _loc32_;
         var _loc33_:Dictionary = new Dictionary();
         var _loc34_:Dictionary = new Dictionary();
         _loc7_ = this.faceList;
         while(_loc7_ != null)
         {
            _loc8_ = _loc7_.next;
            _loc7_.next = null;
            _loc33_[_loc7_] = true;
            _loc13_ = _loc7_.wrapper;
            while(_loc13_ != null)
            {
               _loc17_ = _loc13_.vertex;
               _loc31_ = _loc34_[_loc17_];
               if(_loc31_ == null)
               {
                  _loc31_ = new Dictionary();
                  _loc34_[_loc17_] = _loc31_;
               }
               _loc31_[_loc7_] = true;
               _loc13_ = _loc13_.next;
            }
            _loc7_ = _loc8_;
         }
         this.faceList = null;
         var _loc35_:Vector.<Face> = new Vector.<Face>();
         var _loc36_:Dictionary = new Dictionary();
         var _loc37_:Dictionary = new Dictionary();
         while(true)
         {
            _loc7_ = null;
            var _loc41_:int = 0;
            var _loc42_:* = _loc33_;
            for(_loc5_ in _loc42_)
            {
               _loc7_ = _loc5_;
               delete _loc33_[_loc5_];
            }
            if(_loc7_ == null)
            {
               break;
            }
            _loc38_ = 0;
            _loc35_[_loc38_] = _loc7_;
            _loc38_++;
            _loc27_ = _loc7_.normalX;
            _loc28_ = _loc7_.normalY;
            _loc29_ = _loc7_.normalZ;
            for(_loc5_ in _loc37_)
            {
               delete _loc37_[_loc5_];
            }
            _loc3_ = 0;
            while(_loc3_ < _loc38_)
            {
               _loc7_ = _loc35_[_loc3_];
               for(_loc5_ in _loc36_)
               {
                  delete _loc36_[_loc5_];
               }
               _loc11_ = _loc7_.wrapper;
               while(_loc11_ != null)
               {
                  for(_loc5_ in _loc34_[_loc11_.vertex])
                  {
                     if(Boolean(_loc33_[_loc5_]) && !_loc37_[_loc5_])
                     {
                        _loc36_[_loc5_] = true;
                     }
                  }
                  _loc11_ = _loc11_.next;
               }
               for(_loc5_ in _loc36_)
               {
                  _loc6_ = _loc5_;
                  if(_loc27_ * _loc6_.normalX + _loc28_ * _loc6_.normalY + _loc29_ * _loc6_.normalZ >= param1)
                  {
                     _loc11_ = _loc7_.wrapper;
                     while(_loc11_ != null)
                     {
                        _loc13_ = _loc11_.next != null ? _loc11_.next : _loc7_.wrapper;
                        _loc12_ = _loc6_.wrapper;
                        while(_loc12_ != null)
                        {
                           _loc14_ = _loc12_.next != null ? _loc12_.next : _loc6_.wrapper;
                           if(_loc11_.vertex == _loc14_.vertex && _loc13_.vertex == _loc12_.vertex)
                           {
                              break;
                           }
                           _loc12_ = _loc12_.next;
                        }
                        if(_loc12_ != null)
                        {
                           break;
                        }
                        _loc11_ = _loc11_.next;
                     }
                     if(_loc11_ != null)
                     {
                        _loc35_[_loc38_] = _loc6_;
                        _loc38_++;
                        delete _loc33_[_loc6_];
                     }
                  }
                  else
                  {
                     _loc37_[_loc6_] = true;
                  }
               }
               _loc3_++;
            }
            if(_loc38_ == 1)
            {
               _loc7_ = _loc35_[0];
               _loc7_.next = this.faceList;
               this.faceList = _loc7_;
            }
            else
            {
               do
               {
                  _loc39_ = false;
                  _loc3_ = 0;
                  while(_loc3_ < _loc38_ - 1)
                  {
                     _loc7_ = _loc35_[_loc3_];
                     if(_loc7_ != null)
                     {
                        _loc4_ = 1;
                        for(; _loc4_ < _loc38_; _loc4_++)
                        {
                           _loc6_ = _loc35_[_loc4_];
                           if(_loc6_ != null)
                           {
                              _loc11_ = _loc7_.wrapper;
                              while(_loc11_ != null)
                              {
                                 _loc13_ = _loc11_.next != null ? _loc11_.next : _loc7_.wrapper;
                                 _loc12_ = _loc6_.wrapper;
                                 while(_loc12_ != null)
                                 {
                                    _loc14_ = _loc12_.next != null ? _loc12_.next : _loc6_.wrapper;
                                    if(_loc11_.vertex == _loc14_.vertex && _loc13_.vertex == _loc12_.vertex)
                                    {
                                       break;
                                    }
                                    _loc12_ = _loc12_.next;
                                 }
                                 if(_loc12_ != null)
                                 {
                                    break;
                                 }
                                 _loc11_ = _loc11_.next;
                              }
                              if(_loc11_ != null)
                              {
                                 while(true)
                                 {
                                    _loc15_ = _loc13_.next != null ? _loc13_.next : _loc7_.wrapper;
                                    _loc10_ = _loc6_.wrapper;
                                    while(_loc10_.next != _loc12_ && _loc10_.next != null)
                                    {
                                       _loc10_ = _loc10_.next;
                                    }
                                    if(_loc15_.vertex != _loc10_.vertex)
                                    {
                                       break;
                                    }
                                    _loc13_ = _loc15_;
                                    _loc12_ = _loc10_;
                                 }
                                 while(true)
                                 {
                                    _loc9_ = _loc7_.wrapper;
                                    while(_loc9_.next != _loc11_ && _loc9_.next != null)
                                    {
                                       _loc9_ = _loc9_.next;
                                    }
                                    _loc16_ = _loc14_.next != null ? _loc14_.next : _loc6_.wrapper;
                                    if(_loc9_.vertex != _loc16_.vertex)
                                    {
                                       break;
                                    }
                                    _loc11_ = _loc9_;
                                    _loc14_ = _loc16_;
                                 }
                                 _loc18_ = _loc11_.vertex;
                                 _loc19_ = _loc16_.vertex;
                                 _loc20_ = _loc9_.vertex;
                                 _loc21_ = _loc19_.x - _loc18_.x;
                                 _loc22_ = _loc19_.y - _loc18_.y;
                                 _loc23_ = _loc19_.z - _loc18_.z;
                                 _loc24_ = _loc20_.x - _loc18_.x;
                                 _loc25_ = _loc20_.y - _loc18_.y;
                                 _loc26_ = _loc20_.z - _loc18_.z;
                                 _loc27_ = _loc26_ * _loc22_ - _loc25_ * _loc23_;
                                 _loc28_ = _loc24_ * _loc23_ - _loc26_ * _loc21_;
                                 _loc29_ = _loc25_ * _loc21_ - _loc24_ * _loc22_;
                                 if(_loc27_ < _loc32_ && _loc27_ > -_loc32_ && _loc28_ < _loc32_ && _loc28_ > -_loc32_ && _loc29_ < _loc32_ && _loc29_ > -_loc32_)
                                 {
                                    if(_loc21_ * _loc24_ + _loc22_ * _loc25_ + _loc23_ * _loc26_ > 0)
                                    {
                                       continue;
                                    }
                                 }
                                 else if(_loc7_.normalX * _loc27_ + _loc7_.normalY * _loc28_ + _loc7_.normalZ * _loc29_ < 0)
                                 {
                                    continue;
                                 }
                                 _loc30_ = 1 / Math.sqrt(_loc21_ * _loc21_ + _loc22_ * _loc22_ + _loc23_ * _loc23_);
                                 _loc21_ *= _loc30_;
                                 _loc22_ *= _loc30_;
                                 _loc23_ *= _loc30_;
                                 _loc30_ = 1 / Math.sqrt(_loc24_ * _loc24_ + _loc25_ * _loc25_ + _loc26_ * _loc26_);
                                 _loc24_ *= _loc30_;
                                 _loc25_ *= _loc30_;
                                 _loc26_ *= _loc30_;
                                 if(_loc21_ * _loc24_ + _loc22_ * _loc25_ + _loc23_ * _loc26_ >= param2)
                                 {
                                    _loc18_ = _loc12_.vertex;
                                    _loc19_ = _loc15_.vertex;
                                    _loc20_ = _loc10_.vertex;
                                    _loc21_ = _loc19_.x - _loc18_.x;
                                    _loc22_ = _loc19_.y - _loc18_.y;
                                    _loc23_ = _loc19_.z - _loc18_.z;
                                    _loc24_ = _loc20_.x - _loc18_.x;
                                    _loc25_ = _loc20_.y - _loc18_.y;
                                    _loc26_ = _loc20_.z - _loc18_.z;
                                    _loc27_ = _loc26_ * _loc22_ - _loc25_ * _loc23_;
                                    _loc28_ = _loc24_ * _loc23_ - _loc26_ * _loc21_;
                                    _loc29_ = _loc25_ * _loc21_ - _loc24_ * _loc22_;
                                    if(_loc27_ < _loc32_ && _loc27_ > -_loc32_ && _loc28_ < _loc32_ && _loc28_ > -_loc32_ && _loc29_ < _loc32_ && _loc29_ > -_loc32_)
                                    {
                                       if(_loc21_ * _loc24_ + _loc22_ * _loc25_ + _loc23_ * _loc26_ > 0)
                                       {
                                          continue;
                                       }
                                    }
                                    else if(_loc7_.normalX * _loc27_ + _loc7_.normalY * _loc28_ + _loc7_.normalZ * _loc29_ < 0)
                                    {
                                       continue;
                                    }
                                    _loc30_ = 1 / Math.sqrt(_loc21_ * _loc21_ + _loc22_ * _loc22_ + _loc23_ * _loc23_);
                                    _loc21_ *= _loc30_;
                                    _loc22_ *= _loc30_;
                                    _loc23_ *= _loc30_;
                                    _loc30_ = 1 / Math.sqrt(_loc24_ * _loc24_ + _loc25_ * _loc25_ + _loc26_ * _loc26_);
                                    _loc24_ *= _loc30_;
                                    _loc25_ *= _loc30_;
                                    _loc26_ *= _loc30_;
                                    if(_loc21_ * _loc24_ + _loc22_ * _loc25_ + _loc23_ * _loc26_ >= param2)
                                    {
                                       _loc39_ = true;
                                       _loc40_ = new Face();
                                       _loc40_.normalX = _loc7_.normalX;
                                       _loc40_.normalY = _loc7_.normalY;
                                       _loc40_.normalZ = _loc7_.normalZ;
                                       _loc40_.offset = _loc7_.offset;
                                       _loc15_ = null;
                                       while(_loc13_ != _loc11_)
                                       {
                                          _loc16_ = new Wrapper();
                                          _loc16_.vertex = _loc13_.vertex;
                                          if(_loc15_ != null)
                                          {
                                             _loc15_.next = _loc16_;
                                          }
                                          else
                                          {
                                             _loc40_.wrapper = _loc16_;
                                          }
                                          _loc15_ = _loc16_;
                                          _loc13_ = _loc13_.next != null ? _loc13_.next : _loc7_.wrapper;
                                       }
                                       while(_loc14_ != _loc12_)
                                       {
                                          _loc16_ = new Wrapper();
                                          _loc16_.vertex = _loc14_.vertex;
                                          if(_loc15_ != null)
                                          {
                                             _loc15_.next = _loc16_;
                                          }
                                          else
                                          {
                                             _loc40_.wrapper = _loc16_;
                                          }
                                          _loc15_ = _loc16_;
                                          _loc14_ = _loc14_.next != null ? _loc14_.next : _loc6_.wrapper;
                                       }
                                       _loc35_[_loc3_] = _loc40_;
                                       _loc35_[_loc4_] = null;
                                       _loc7_ = _loc40_;
                                    }
                                 }
                              }
                           }
                        }
                     }
                     _loc3_++;
                  }
               }
               while(_loc39_);
               
               _loc3_ = 0;
               while(_loc3_ < _loc38_)
               {
                  _loc7_ = _loc35_[_loc3_];
                  if(_loc7_ != null)
                  {
                     _loc7_.calculateBestSequenceAndNormal();
                     _loc7_.next = this.faceList;
                     this.faceList = _loc7_;
                  }
                  _loc3_++;
               }
            }
         }
      }
      
      alternativa3d function transformVertices(param1:Number, param2:Number) : void
      {
         var _loc3_:Vertex = this.vertexList;
         while(_loc3_ != null)
         {
            _loc3_.cameraX = (alternativa3d::localToCameraTransform.a * _loc3_.x + alternativa3d::localToCameraTransform.b * _loc3_.y + alternativa3d::localToCameraTransform.c * _loc3_.z + alternativa3d::localToCameraTransform.d) / param1;
            _loc3_.cameraY = (alternativa3d::localToCameraTransform.e * _loc3_.x + alternativa3d::localToCameraTransform.f * _loc3_.y + alternativa3d::localToCameraTransform.g * _loc3_.z + alternativa3d::localToCameraTransform.h) / param2;
            _loc3_.cameraZ = alternativa3d::localToCameraTransform.i * _loc3_.x + alternativa3d::localToCameraTransform.j * _loc3_.y + alternativa3d::localToCameraTransform.k * _loc3_.z + alternativa3d::localToCameraTransform.l;
            _loc3_ = _loc3_.next;
         }
      }
      
      alternativa3d function checkOcclusion(param1:Occluder, param2:Number, param3:Number) : Boolean
      {
         var _loc5_:Vertex = null;
         var _loc4_:CullingPlane = param1.alternativa3d::planeList;
         while(_loc4_ != null)
         {
            _loc5_ = this.vertexList;
            while(_loc5_ != null)
            {
               if(_loc4_.x * _loc5_.cameraX * param2 + _loc4_.y * _loc5_.cameraY * param3 + _loc4_.z * _loc5_.cameraZ > _loc4_.offset)
               {
                  return false;
               }
               _loc5_ = _loc5_.next;
            }
            _loc4_ = _loc4_.next;
         }
         return true;
      }
      
      alternativa3d function calculatePlanes(param1:Camera3D) : void
      {
         var _loc2_:Vertex = null;
         var _loc3_:Vertex = null;
         var _loc4_:Vertex = null;
         var _loc5_:Face = null;
         var _loc6_:CullingPlane = null;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc27_:Boolean = false;
         var _loc28_:Wrapper = null;
         if(this.alternativa3d::planeList != null)
         {
            _loc6_ = this.alternativa3d::planeList;
            while(_loc6_.next != null)
            {
               _loc6_ = _loc6_.next;
            }
            _loc6_.next = CullingPlane.collector;
            CullingPlane.collector = this.alternativa3d::planeList;
            this.alternativa3d::planeList = null;
         }
         if(this.faceList == null || this.edgeList == null)
         {
            return;
         }
         if(!param1.orthographic)
         {
            _loc27_ = true;
            _loc5_ = this.faceList;
            while(_loc5_ != null)
            {
               if(_loc5_.normalX * alternativa3d::cameraToLocalTransform.d + _loc5_.normalY * alternativa3d::cameraToLocalTransform.h + _loc5_.normalZ * alternativa3d::cameraToLocalTransform.l > _loc5_.offset)
               {
                  _loc5_.visible = true;
                  _loc27_ = false;
               }
               else
               {
                  _loc5_.visible = false;
               }
               _loc5_ = _loc5_.next;
            }
            if(_loc27_)
            {
               return;
            }
         }
         else
         {
            _loc2_ = this.vertexList;
            while(_loc2_ != null)
            {
               if(_loc2_.cameraZ < param1.nearClipping)
               {
                  return;
               }
               _loc2_ = _loc2_.next;
            }
            _loc5_ = this.faceList;
            while(_loc5_ != null)
            {
               _loc5_.visible = _loc5_.normalX * alternativa3d::cameraToLocalTransform.c + _loc5_.normalY * alternativa3d::cameraToLocalTransform.g + _loc5_.normalZ * alternativa3d::cameraToLocalTransform.k < 0;
               _loc5_ = _loc5_.next;
            }
         }
         var _loc7_:Number = param1.view.alternativa3d::_width * 0.5;
         var _loc8_:Number = param1.view.alternativa3d::_width * 0.5;
         var _loc9_:Number = _loc7_ / param1.alternativa3d::correctionX;
         var _loc10_:Number = -_loc9_;
         var _loc11_:Number = _loc8_ / param1.alternativa3d::correctionY;
         var _loc12_:Number = -_loc11_;
         var _loc22_:CullingPlane = null;
         var _loc23_:Number = 0;
         var _loc24_:Number = _loc7_ * _loc8_ * 4 * 2;
         var _loc25_:Boolean = true;
         var _loc26_:Edge = this.edgeList;
         for(; _loc26_ != null; _loc26_ = _loc26_.next)
         {
            if(_loc26_.left.visible != _loc26_.right.visible)
            {
               if(_loc26_.left.visible)
               {
                  _loc2_ = _loc26_.a;
                  _loc3_ = _loc26_.b;
               }
               else
               {
                  _loc2_ = _loc26_.b;
                  _loc3_ = _loc26_.a;
               }
               _loc14_ = _loc2_.cameraX;
               _loc15_ = _loc2_.cameraY;
               _loc16_ = _loc2_.cameraZ;
               _loc17_ = _loc3_.cameraX;
               _loc18_ = _loc3_.cameraY;
               _loc19_ = _loc3_.cameraZ;
               if(alternativa3d::culling > 3)
               {
                  if(!param1.orthographic)
                  {
                     if(_loc16_ <= -_loc14_ && _loc19_ <= -_loc17_)
                     {
                        if(_loc25_ && _loc18_ * _loc14_ - _loc17_ * _loc15_ > 0)
                        {
                           _loc25_ = false;
                        }
                        continue;
                     }
                     if(_loc19_ > -_loc17_ && _loc16_ <= -_loc14_)
                     {
                        _loc13_ = (_loc14_ + _loc16_) / (_loc14_ + _loc16_ - _loc17_ - _loc19_);
                        _loc14_ += (_loc17_ - _loc14_) * _loc13_;
                        _loc15_ += (_loc18_ - _loc15_) * _loc13_;
                        _loc16_ += (_loc19_ - _loc16_) * _loc13_;
                     }
                     else if(_loc19_ <= -_loc17_ && _loc16_ > -_loc14_)
                     {
                        _loc13_ = (_loc14_ + _loc16_) / (_loc14_ + _loc16_ - _loc17_ - _loc19_);
                        _loc17_ = _loc14_ + (_loc17_ - _loc14_) * _loc13_;
                        _loc18_ = _loc15_ + (_loc18_ - _loc15_) * _loc13_;
                        _loc19_ = _loc16_ + (_loc19_ - _loc16_) * _loc13_;
                     }
                     if(_loc16_ <= _loc14_ && _loc19_ <= _loc17_)
                     {
                        if(_loc25_ && _loc18_ * _loc14_ - _loc17_ * _loc15_ > 0)
                        {
                           _loc25_ = false;
                        }
                        continue;
                     }
                     if(_loc19_ > _loc17_ && _loc16_ <= _loc14_)
                     {
                        _loc13_ = (_loc16_ - _loc14_) / (_loc16_ - _loc14_ + _loc17_ - _loc19_);
                        _loc14_ += (_loc17_ - _loc14_) * _loc13_;
                        _loc15_ += (_loc18_ - _loc15_) * _loc13_;
                        _loc16_ += (_loc19_ - _loc16_) * _loc13_;
                     }
                     else if(_loc19_ <= _loc17_ && _loc16_ > _loc14_)
                     {
                        _loc13_ = (_loc16_ - _loc14_) / (_loc16_ - _loc14_ + _loc17_ - _loc19_);
                        _loc17_ = _loc14_ + (_loc17_ - _loc14_) * _loc13_;
                        _loc18_ = _loc15_ + (_loc18_ - _loc15_) * _loc13_;
                        _loc19_ = _loc16_ + (_loc19_ - _loc16_) * _loc13_;
                     }
                     if(_loc16_ <= -_loc15_ && _loc19_ <= -_loc18_)
                     {
                        if(_loc25_ && _loc18_ * _loc14_ - _loc17_ * _loc15_ > 0)
                        {
                           _loc25_ = false;
                        }
                        continue;
                     }
                     if(_loc19_ > -_loc18_ && _loc16_ <= -_loc15_)
                     {
                        _loc13_ = (_loc15_ + _loc16_) / (_loc15_ + _loc16_ - _loc18_ - _loc19_);
                        _loc14_ += (_loc17_ - _loc14_) * _loc13_;
                        _loc15_ += (_loc18_ - _loc15_) * _loc13_;
                        _loc16_ += (_loc19_ - _loc16_) * _loc13_;
                     }
                     else if(_loc19_ <= -_loc18_ && _loc16_ > -_loc15_)
                     {
                        _loc13_ = (_loc15_ + _loc16_) / (_loc15_ + _loc16_ - _loc18_ - _loc19_);
                        _loc17_ = _loc14_ + (_loc17_ - _loc14_) * _loc13_;
                        _loc18_ = _loc15_ + (_loc18_ - _loc15_) * _loc13_;
                        _loc19_ = _loc16_ + (_loc19_ - _loc16_) * _loc13_;
                     }
                     if(_loc16_ <= _loc15_ && _loc19_ <= _loc18_)
                     {
                        if(_loc25_ && _loc18_ * _loc14_ - _loc17_ * _loc15_ > 0)
                        {
                           _loc25_ = false;
                        }
                        continue;
                     }
                     if(_loc19_ > _loc18_ && _loc16_ <= _loc15_)
                     {
                        _loc13_ = (_loc16_ - _loc15_) / (_loc16_ - _loc15_ + _loc18_ - _loc19_);
                        _loc14_ += (_loc17_ - _loc14_) * _loc13_;
                        _loc15_ += (_loc18_ - _loc15_) * _loc13_;
                        _loc16_ += (_loc19_ - _loc16_) * _loc13_;
                     }
                     else if(_loc19_ <= _loc18_ && _loc16_ > _loc15_)
                     {
                        _loc13_ = (_loc16_ - _loc15_) / (_loc16_ - _loc15_ + _loc18_ - _loc19_);
                        _loc17_ = _loc14_ + (_loc17_ - _loc14_) * _loc13_;
                        _loc18_ = _loc15_ + (_loc18_ - _loc15_) * _loc13_;
                        _loc19_ = _loc16_ + (_loc19_ - _loc16_) * _loc13_;
                     }
                  }
                  else
                  {
                     if(_loc14_ <= _loc10_ && _loc17_ <= _loc10_)
                     {
                        if(_loc25_ && _loc18_ * _loc14_ - _loc17_ * _loc15_ > 0)
                        {
                           _loc25_ = false;
                        }
                        continue;
                     }
                     if(_loc17_ > _loc10_ && _loc14_ <= _loc10_)
                     {
                        _loc13_ = (_loc10_ - _loc14_) / (_loc17_ - _loc14_);
                        _loc14_ += (_loc17_ - _loc14_) * _loc13_;
                        _loc15_ += (_loc18_ - _loc15_) * _loc13_;
                        _loc16_ += (_loc19_ - _loc16_) * _loc13_;
                     }
                     else if(_loc17_ <= _loc10_ && _loc14_ > _loc10_)
                     {
                        _loc13_ = (_loc10_ - _loc14_) / (_loc17_ - _loc14_);
                        _loc17_ = _loc14_ + (_loc17_ - _loc14_) * _loc13_;
                        _loc18_ = _loc15_ + (_loc18_ - _loc15_) * _loc13_;
                        _loc19_ = _loc16_ + (_loc19_ - _loc16_) * _loc13_;
                     }
                     if(_loc14_ >= _loc9_ && _loc17_ >= _loc9_)
                     {
                        if(_loc25_ && _loc18_ * _loc14_ - _loc17_ * _loc15_ > 0)
                        {
                           _loc25_ = false;
                        }
                        continue;
                     }
                     if(_loc17_ < _loc9_ && _loc14_ >= _loc9_)
                     {
                        _loc13_ = (_loc9_ - _loc14_) / (_loc17_ - _loc14_);
                        _loc14_ += (_loc17_ - _loc14_) * _loc13_;
                        _loc15_ += (_loc18_ - _loc15_) * _loc13_;
                        _loc16_ += (_loc19_ - _loc16_) * _loc13_;
                     }
                     else if(_loc17_ >= _loc9_ && _loc14_ < _loc9_)
                     {
                        _loc13_ = (_loc9_ - _loc14_) / (_loc17_ - _loc14_);
                        _loc17_ = _loc14_ + (_loc17_ - _loc14_) * _loc13_;
                        _loc18_ = _loc15_ + (_loc18_ - _loc15_) * _loc13_;
                        _loc19_ = _loc16_ + (_loc19_ - _loc16_) * _loc13_;
                     }
                     if(_loc15_ <= _loc12_ && _loc18_ <= _loc12_)
                     {
                        if(_loc25_ && _loc18_ * _loc14_ - _loc17_ * _loc15_ > 0)
                        {
                           _loc25_ = false;
                        }
                        continue;
                     }
                     if(_loc18_ > _loc12_ && _loc15_ <= _loc12_)
                     {
                        _loc13_ = (_loc12_ - _loc15_) / (_loc18_ - _loc15_);
                        _loc14_ += (_loc17_ - _loc14_) * _loc13_;
                        _loc15_ += (_loc18_ - _loc15_) * _loc13_;
                        _loc16_ += (_loc19_ - _loc16_) * _loc13_;
                     }
                     else if(_loc18_ <= _loc12_ && _loc15_ > _loc12_)
                     {
                        _loc13_ = (_loc12_ - _loc15_) / (_loc18_ - _loc15_);
                        _loc17_ = _loc14_ + (_loc17_ - _loc14_) * _loc13_;
                        _loc18_ = _loc15_ + (_loc18_ - _loc15_) * _loc13_;
                        _loc19_ = _loc16_ + (_loc19_ - _loc16_) * _loc13_;
                     }
                     if(_loc15_ >= _loc11_ && _loc18_ >= _loc11_)
                     {
                        if(_loc25_ && _loc18_ * _loc14_ - _loc17_ * _loc15_ > 0)
                        {
                           _loc25_ = false;
                        }
                        continue;
                     }
                     if(_loc18_ < _loc11_ && _loc15_ >= _loc11_)
                     {
                        _loc13_ = (_loc11_ - _loc15_) / (_loc18_ - _loc15_);
                        _loc14_ += (_loc17_ - _loc14_) * _loc13_;
                        _loc15_ += (_loc18_ - _loc15_) * _loc13_;
                        _loc16_ += (_loc19_ - _loc16_) * _loc13_;
                     }
                     else if(_loc18_ >= _loc11_ && _loc15_ < _loc11_)
                     {
                        _loc13_ = (_loc11_ - _loc15_) / (_loc18_ - _loc15_);
                        _loc17_ = _loc14_ + (_loc17_ - _loc14_) * _loc13_;
                        _loc18_ = _loc15_ + (_loc18_ - _loc15_) * _loc13_;
                        _loc19_ = _loc16_ + (_loc19_ - _loc16_) * _loc13_;
                     }
                  }
                  _loc25_ = false;
               }
               _loc6_ = CullingPlane.create();
               _loc6_.next = this.alternativa3d::planeList;
               this.alternativa3d::planeList = _loc6_;
               if(!param1.orthographic)
               {
                  _loc6_.x = (_loc3_.cameraZ * _loc2_.cameraY - _loc3_.cameraY * _loc2_.cameraZ) * param1.alternativa3d::correctionY;
                  _loc6_.y = (_loc3_.cameraX * _loc2_.cameraZ - _loc3_.cameraZ * _loc2_.cameraX) * param1.alternativa3d::correctionX;
                  _loc6_.z = (_loc3_.cameraY * _loc2_.cameraX - _loc3_.cameraX * _loc2_.cameraY) * param1.alternativa3d::correctionX * param1.alternativa3d::correctionY;
                  _loc6_.offset = 0;
                  if(this.minSize > 0 && _loc23_ / _loc24_ < this.minSize)
                  {
                     _loc14_ = _loc14_ * _loc7_ / _loc16_;
                     _loc15_ = _loc15_ * _loc8_ / _loc16_;
                     _loc17_ = _loc17_ * _loc7_ / _loc19_;
                     _loc18_ = _loc18_ * _loc8_ / _loc19_;
                     if(this.alternativa3d::planeList.next == null)
                     {
                        _loc20_ = _loc14_;
                        _loc21_ = _loc15_;
                     }
                     _loc23_ += (_loc17_ - _loc20_) * (_loc15_ - _loc21_) - (_loc18_ - _loc21_) * (_loc14_ - _loc20_);
                     _loc6_ = _loc6_.create();
                     _loc6_.x = _loc15_ - _loc18_;
                     _loc6_.y = _loc17_ - _loc14_;
                     _loc6_.offset = _loc6_.x * _loc14_ + _loc6_.y * _loc15_;
                     _loc6_.next = _loc22_;
                     _loc22_ = _loc6_;
                  }
               }
               else
               {
                  _loc6_.x = (_loc2_.cameraY - _loc3_.cameraY) * param1.alternativa3d::correctionY;
                  _loc6_.y = (_loc3_.cameraX - _loc2_.cameraX) * param1.alternativa3d::correctionX;
                  _loc6_.z = 0;
                  _loc6_.offset = _loc6_.x * _loc2_.cameraX * param1.alternativa3d::correctionX + _loc6_.y * _loc2_.cameraY * param1.alternativa3d::correctionY;
                  if(this.minSize > 0 && _loc23_ / _loc24_ < this.minSize)
                  {
                     _loc14_ *= param1.alternativa3d::correctionX;
                     _loc15_ *= param1.alternativa3d::correctionY;
                     _loc17_ *= param1.alternativa3d::correctionX;
                     _loc18_ *= param1.alternativa3d::correctionY;
                     if(this.alternativa3d::planeList.next == null)
                     {
                        _loc20_ = _loc14_;
                        _loc21_ = _loc15_;
                     }
                     _loc23_ += (_loc17_ - _loc20_) * (_loc15_ - _loc21_) - (_loc18_ - _loc21_) * (_loc14_ - _loc20_);
                     _loc6_ = _loc6_.create();
                     _loc6_.x = _loc15_ - _loc18_;
                     _loc6_.y = _loc17_ - _loc14_;
                     _loc6_.offset = _loc6_.x * _loc14_ + _loc6_.y * _loc15_;
                     _loc6_.next = _loc22_;
                     _loc22_ = _loc6_;
                  }
               }
            }
         }
         if(this.alternativa3d::planeList == null && !_loc25_)
         {
            return;
         }
         if(this.alternativa3d::planeList != null && this.minSize > 0 && _loc23_ / _loc24_ < this.minSize && (alternativa3d::culling <= 3 || !this.checkSquare(_loc22_,_loc20_,_loc21_,_loc23_,_loc24_,_loc7_,_loc8_)))
         {
            _loc6_ = this.alternativa3d::planeList;
            while(_loc6_.next != null)
            {
               _loc6_ = _loc6_.next;
            }
            _loc6_.next = CullingPlane.collector;
            CullingPlane.collector = this.alternativa3d::planeList;
            this.alternativa3d::planeList = null;
            if(_loc22_ != null)
            {
               _loc6_ = _loc22_;
               while(_loc6_.next != null)
               {
                  _loc6_ = _loc6_.next;
               }
               _loc6_.next = CullingPlane.collector;
               CullingPlane.collector = _loc22_;
            }
            return;
         }
         if(_loc22_ != null)
         {
            _loc6_ = _loc22_;
            while(_loc6_.next != null)
            {
               _loc6_ = _loc6_.next;
            }
            _loc6_.next = CullingPlane.collector;
            CullingPlane.collector = _loc22_;
         }
         _loc5_ = this.faceList;
         for(; _loc5_ != null; _loc5_ = _loc5_.next)
         {
            if(_loc5_.visible)
            {
               if(alternativa3d::culling > 3)
               {
                  _loc25_ = true;
                  _loc28_ = _loc5_.wrapper;
                  for(; _loc28_ != null; _loc28_ = _loc28_.next)
                  {
                     _loc2_ = _loc28_.vertex;
                     _loc3_ = _loc28_.next != null ? _loc28_.next.vertex : _loc5_.wrapper.vertex;
                     _loc14_ = _loc2_.cameraX;
                     _loc15_ = _loc2_.cameraY;
                     _loc16_ = _loc2_.cameraZ;
                     _loc17_ = _loc3_.cameraX;
                     _loc18_ = _loc3_.cameraY;
                     _loc19_ = _loc3_.cameraZ;
                     if(!param1.orthographic)
                     {
                        if(_loc16_ <= -_loc14_ && _loc19_ <= -_loc17_)
                        {
                           if(_loc25_ && _loc18_ * _loc14_ - _loc17_ * _loc15_ > 0)
                           {
                              _loc25_ = false;
                           }
                           continue;
                        }
                        if(_loc19_ > -_loc17_ && _loc16_ <= -_loc14_)
                        {
                           _loc13_ = (_loc14_ + _loc16_) / (_loc14_ + _loc16_ - _loc17_ - _loc19_);
                           _loc14_ += (_loc17_ - _loc14_) * _loc13_;
                           _loc15_ += (_loc18_ - _loc15_) * _loc13_;
                           _loc16_ += (_loc19_ - _loc16_) * _loc13_;
                        }
                        else if(_loc19_ <= -_loc17_ && _loc16_ > -_loc14_)
                        {
                           _loc13_ = (_loc14_ + _loc16_) / (_loc14_ + _loc16_ - _loc17_ - _loc19_);
                           _loc17_ = _loc14_ + (_loc17_ - _loc14_) * _loc13_;
                           _loc18_ = _loc15_ + (_loc18_ - _loc15_) * _loc13_;
                           _loc19_ = _loc16_ + (_loc19_ - _loc16_) * _loc13_;
                        }
                        if(_loc16_ <= _loc14_ && _loc19_ <= _loc17_)
                        {
                           if(_loc25_ && _loc18_ * _loc14_ - _loc17_ * _loc15_ > 0)
                           {
                              _loc25_ = false;
                           }
                           continue;
                        }
                        if(_loc19_ > _loc17_ && _loc16_ <= _loc14_)
                        {
                           _loc13_ = (_loc16_ - _loc14_) / (_loc16_ - _loc14_ + _loc17_ - _loc19_);
                           _loc14_ += (_loc17_ - _loc14_) * _loc13_;
                           _loc15_ += (_loc18_ - _loc15_) * _loc13_;
                           _loc16_ += (_loc19_ - _loc16_) * _loc13_;
                        }
                        else if(_loc19_ <= _loc17_ && _loc16_ > _loc14_)
                        {
                           _loc13_ = (_loc16_ - _loc14_) / (_loc16_ - _loc14_ + _loc17_ - _loc19_);
                           _loc17_ = _loc14_ + (_loc17_ - _loc14_) * _loc13_;
                           _loc18_ = _loc15_ + (_loc18_ - _loc15_) * _loc13_;
                           _loc19_ = _loc16_ + (_loc19_ - _loc16_) * _loc13_;
                        }
                        if(_loc16_ <= -_loc15_ && _loc19_ <= -_loc18_)
                        {
                           if(_loc25_ && _loc18_ * _loc14_ - _loc17_ * _loc15_ > 0)
                           {
                              _loc25_ = false;
                           }
                           continue;
                        }
                        if(_loc19_ > -_loc18_ && _loc16_ <= -_loc15_)
                        {
                           _loc13_ = (_loc15_ + _loc16_) / (_loc15_ + _loc16_ - _loc18_ - _loc19_);
                           _loc14_ += (_loc17_ - _loc14_) * _loc13_;
                           _loc15_ += (_loc18_ - _loc15_) * _loc13_;
                           _loc16_ += (_loc19_ - _loc16_) * _loc13_;
                        }
                        else if(_loc19_ <= -_loc18_ && _loc16_ > -_loc15_)
                        {
                           _loc13_ = (_loc15_ + _loc16_) / (_loc15_ + _loc16_ - _loc18_ - _loc19_);
                           _loc17_ = _loc14_ + (_loc17_ - _loc14_) * _loc13_;
                           _loc18_ = _loc15_ + (_loc18_ - _loc15_) * _loc13_;
                           _loc19_ = _loc16_ + (_loc19_ - _loc16_) * _loc13_;
                        }
                        if(_loc16_ <= _loc15_ && _loc19_ <= _loc18_)
                        {
                           if(_loc25_ && _loc18_ * _loc14_ - _loc17_ * _loc15_ > 0)
                           {
                              _loc25_ = false;
                           }
                           continue;
                        }
                        if(_loc19_ > _loc18_ && _loc16_ <= _loc15_)
                        {
                           _loc13_ = (_loc16_ - _loc15_) / (_loc16_ - _loc15_ + _loc18_ - _loc19_);
                           _loc14_ += (_loc17_ - _loc14_) * _loc13_;
                           _loc15_ += (_loc18_ - _loc15_) * _loc13_;
                           _loc16_ += (_loc19_ - _loc16_) * _loc13_;
                        }
                        else if(_loc19_ <= _loc18_ && _loc16_ > _loc15_)
                        {
                           _loc13_ = (_loc16_ - _loc15_) / (_loc16_ - _loc15_ + _loc18_ - _loc19_);
                           _loc17_ = _loc14_ + (_loc17_ - _loc14_) * _loc13_;
                           _loc18_ = _loc15_ + (_loc18_ - _loc15_) * _loc13_;
                           _loc19_ = _loc16_ + (_loc19_ - _loc16_) * _loc13_;
                        }
                     }
                     else
                     {
                        if(_loc14_ <= _loc10_ && _loc17_ <= _loc10_)
                        {
                           if(_loc25_ && _loc18_ * _loc14_ - _loc17_ * _loc15_ > 0)
                           {
                              _loc25_ = false;
                           }
                           continue;
                        }
                        if(_loc17_ > _loc10_ && _loc14_ <= _loc10_)
                        {
                           _loc13_ = (_loc10_ - _loc14_) / (_loc17_ - _loc14_);
                           _loc14_ += (_loc17_ - _loc14_) * _loc13_;
                           _loc15_ += (_loc18_ - _loc15_) * _loc13_;
                           _loc16_ += (_loc19_ - _loc16_) * _loc13_;
                        }
                        else if(_loc17_ <= _loc10_ && _loc14_ > _loc10_)
                        {
                           _loc13_ = (_loc10_ - _loc14_) / (_loc17_ - _loc14_);
                           _loc17_ = _loc14_ + (_loc17_ - _loc14_) * _loc13_;
                           _loc18_ = _loc15_ + (_loc18_ - _loc15_) * _loc13_;
                           _loc19_ = _loc16_ + (_loc19_ - _loc16_) * _loc13_;
                        }
                        if(_loc14_ >= _loc9_ && _loc17_ >= _loc9_)
                        {
                           if(_loc25_ && _loc18_ * _loc14_ - _loc17_ * _loc15_ > 0)
                           {
                              _loc25_ = false;
                           }
                           continue;
                        }
                        if(_loc17_ < _loc9_ && _loc14_ >= _loc9_)
                        {
                           _loc13_ = (_loc9_ - _loc14_) / (_loc17_ - _loc14_);
                           _loc14_ += (_loc17_ - _loc14_) * _loc13_;
                           _loc15_ += (_loc18_ - _loc15_) * _loc13_;
                           _loc16_ += (_loc19_ - _loc16_) * _loc13_;
                        }
                        else if(_loc17_ >= _loc9_ && _loc14_ < _loc9_)
                        {
                           _loc13_ = (_loc9_ - _loc14_) / (_loc17_ - _loc14_);
                           _loc17_ = _loc14_ + (_loc17_ - _loc14_) * _loc13_;
                           _loc18_ = _loc15_ + (_loc18_ - _loc15_) * _loc13_;
                           _loc19_ = _loc16_ + (_loc19_ - _loc16_) * _loc13_;
                        }
                        if(_loc15_ <= _loc12_ && _loc18_ <= _loc12_)
                        {
                           if(_loc25_ && _loc18_ * _loc14_ - _loc17_ * _loc15_ > 0)
                           {
                              _loc25_ = false;
                           }
                           continue;
                        }
                        if(_loc18_ > _loc12_ && _loc15_ <= _loc12_)
                        {
                           _loc13_ = (_loc12_ - _loc15_) / (_loc18_ - _loc15_);
                           _loc14_ += (_loc17_ - _loc14_) * _loc13_;
                           _loc15_ += (_loc18_ - _loc15_) * _loc13_;
                           _loc16_ += (_loc19_ - _loc16_) * _loc13_;
                        }
                        else if(_loc18_ <= _loc12_ && _loc15_ > _loc12_)
                        {
                           _loc13_ = (_loc12_ - _loc15_) / (_loc18_ - _loc15_);
                           _loc17_ = _loc14_ + (_loc17_ - _loc14_) * _loc13_;
                           _loc18_ = _loc15_ + (_loc18_ - _loc15_) * _loc13_;
                           _loc19_ = _loc16_ + (_loc19_ - _loc16_) * _loc13_;
                        }
                        if(_loc15_ >= _loc11_ && _loc18_ >= _loc11_)
                        {
                           if(_loc25_ && _loc18_ * _loc14_ - _loc17_ * _loc15_ > 0)
                           {
                              _loc25_ = false;
                           }
                           continue;
                        }
                        if(_loc18_ < _loc11_ && _loc15_ >= _loc11_)
                        {
                           _loc13_ = (_loc11_ - _loc15_) / (_loc18_ - _loc15_);
                           _loc14_ += (_loc17_ - _loc14_) * _loc13_;
                           _loc15_ += (_loc18_ - _loc15_) * _loc13_;
                           _loc16_ += (_loc19_ - _loc16_) * _loc13_;
                        }
                        else if(_loc18_ >= _loc11_ && _loc15_ < _loc11_)
                        {
                           _loc13_ = (_loc11_ - _loc15_) / (_loc18_ - _loc15_);
                           _loc17_ = _loc14_ + (_loc17_ - _loc14_) * _loc13_;
                           _loc18_ = _loc15_ + (_loc18_ - _loc15_) * _loc13_;
                           _loc19_ = _loc16_ + (_loc19_ - _loc16_) * _loc13_;
                        }
                     }
                     _loc25_ = false;
                     break;
                  }
                  if(_loc28_ == null && !_loc25_)
                  {
                     continue;
                  }
               }
               _loc6_ = CullingPlane.create();
               _loc6_.next = this.alternativa3d::planeList;
               this.alternativa3d::planeList = _loc6_;
               _loc2_ = _loc5_.wrapper.vertex;
               _loc3_ = _loc5_.wrapper.next.vertex;
               _loc4_ = _loc5_.wrapper.next.next.vertex;
               _loc14_ = _loc3_.cameraX - _loc2_.cameraX;
               _loc15_ = _loc3_.cameraY - _loc2_.cameraY;
               _loc16_ = _loc3_.cameraZ - _loc2_.cameraZ;
               _loc17_ = _loc4_.cameraX - _loc2_.cameraX;
               _loc18_ = _loc4_.cameraY - _loc2_.cameraY;
               _loc19_ = _loc4_.cameraZ - _loc2_.cameraZ;
               _loc6_.x = (_loc19_ * _loc15_ - _loc18_ * _loc16_) * param1.alternativa3d::correctionY;
               _loc6_.y = (_loc17_ * _loc16_ - _loc19_ * _loc14_) * param1.alternativa3d::correctionX;
               _loc6_.z = (_loc18_ * _loc14_ - _loc17_ * _loc15_) * param1.alternativa3d::correctionX * param1.alternativa3d::correctionY;
               _loc6_.offset = _loc2_.cameraX * _loc6_.x * param1.alternativa3d::correctionX + _loc2_.cameraY * _loc6_.y * param1.alternativa3d::correctionY + _loc2_.cameraZ * _loc6_.z;
            }
         }
      }
      
      private function checkSquare(param1:CullingPlane, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number, param7:Number) : Boolean
      {
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:CullingPlane = null;
         if(alternativa3d::culling & 4)
         {
            _loc9_ = -param6;
            _loc10_ = -param7;
            _loc12_ = -param6;
            _loc13_ = param7;
            _loc15_ = param1;
            while(_loc15_ != null)
            {
               _loc11_ = _loc9_ * _loc15_.x + _loc10_ * _loc15_.y - _loc15_.offset;
               _loc14_ = _loc12_ * _loc15_.x + _loc13_ * _loc15_.y - _loc15_.offset;
               if(!(_loc11_ < 0 || _loc14_ < 0))
               {
                  break;
               }
               if(_loc11_ >= 0 && _loc14_ < 0)
               {
                  _loc8_ = _loc11_ / (_loc11_ - _loc14_);
                  _loc9_ += (_loc12_ - _loc9_) * _loc8_;
                  _loc10_ += (_loc13_ - _loc10_) * _loc8_;
               }
               else if(_loc11_ < 0 && _loc14_ >= 0)
               {
                  _loc8_ = _loc11_ / (_loc11_ - _loc14_);
                  _loc12_ = _loc9_ + (_loc12_ - _loc9_) * _loc8_;
                  _loc13_ = _loc10_ + (_loc13_ - _loc10_) * _loc8_;
               }
               _loc15_ = _loc15_.next;
            }
            if(_loc15_ == null)
            {
               param4 += (_loc12_ - param2) * (_loc10_ - param3) - (_loc13_ - param3) * (_loc9_ - param2);
               if(param4 / param5 >= this.minSize)
               {
                  return true;
               }
            }
         }
         if(alternativa3d::culling & 8)
         {
            _loc9_ = param6;
            _loc10_ = param7;
            _loc12_ = param6;
            _loc13_ = -param7;
            _loc15_ = param1;
            while(_loc15_ != null)
            {
               _loc11_ = _loc9_ * _loc15_.x + _loc10_ * _loc15_.y - _loc15_.offset;
               _loc14_ = _loc12_ * _loc15_.x + _loc13_ * _loc15_.y - _loc15_.offset;
               if(!(_loc11_ < 0 || _loc14_ < 0))
               {
                  break;
               }
               if(_loc11_ >= 0 && _loc14_ < 0)
               {
                  _loc8_ = _loc11_ / (_loc11_ - _loc14_);
                  _loc9_ += (_loc12_ - _loc9_) * _loc8_;
                  _loc10_ += (_loc13_ - _loc10_) * _loc8_;
               }
               else if(_loc11_ < 0 && _loc14_ >= 0)
               {
                  _loc8_ = _loc11_ / (_loc11_ - _loc14_);
                  _loc12_ = _loc9_ + (_loc12_ - _loc9_) * _loc8_;
                  _loc13_ = _loc10_ + (_loc13_ - _loc10_) * _loc8_;
               }
               _loc15_ = _loc15_.next;
            }
            if(_loc15_ == null)
            {
               param4 += (_loc12_ - param2) * (_loc10_ - param3) - (_loc13_ - param3) * (_loc9_ - param2);
               if(param4 / param5 >= this.minSize)
               {
                  return true;
               }
            }
         }
         if(alternativa3d::culling & 0x10)
         {
            _loc9_ = param6;
            _loc10_ = -param7;
            _loc12_ = -param6;
            _loc13_ = -param7;
            _loc15_ = param1;
            while(_loc15_ != null)
            {
               _loc11_ = _loc9_ * _loc15_.x + _loc10_ * _loc15_.y - _loc15_.offset;
               _loc14_ = _loc12_ * _loc15_.x + _loc13_ * _loc15_.y - _loc15_.offset;
               if(!(_loc11_ < 0 || _loc14_ < 0))
               {
                  break;
               }
               if(_loc11_ >= 0 && _loc14_ < 0)
               {
                  _loc8_ = _loc11_ / (_loc11_ - _loc14_);
                  _loc9_ += (_loc12_ - _loc9_) * _loc8_;
                  _loc10_ += (_loc13_ - _loc10_) * _loc8_;
               }
               else if(_loc11_ < 0 && _loc14_ >= 0)
               {
                  _loc8_ = _loc11_ / (_loc11_ - _loc14_);
                  _loc12_ = _loc9_ + (_loc12_ - _loc9_) * _loc8_;
                  _loc13_ = _loc10_ + (_loc13_ - _loc10_) * _loc8_;
               }
               _loc15_ = _loc15_.next;
            }
            if(_loc15_ == null)
            {
               param4 += (_loc12_ - param2) * (_loc10_ - param3) - (_loc13_ - param3) * (_loc9_ - param2);
               if(param4 / param5 >= this.minSize)
               {
                  return true;
               }
            }
         }
         if(alternativa3d::culling & 0x20)
         {
            _loc9_ = -param6;
            _loc10_ = param7;
            _loc12_ = param6;
            _loc13_ = param7;
            _loc15_ = param1;
            while(_loc15_ != null)
            {
               _loc11_ = _loc9_ * _loc15_.x + _loc10_ * _loc15_.y - _loc15_.offset;
               _loc14_ = _loc12_ * _loc15_.x + _loc13_ * _loc15_.y - _loc15_.offset;
               if(!(_loc11_ < 0 || _loc14_ < 0))
               {
                  break;
               }
               if(_loc11_ >= 0 && _loc14_ < 0)
               {
                  _loc8_ = _loc11_ / (_loc11_ - _loc14_);
                  _loc9_ += (_loc12_ - _loc9_) * _loc8_;
                  _loc10_ += (_loc13_ - _loc10_) * _loc8_;
               }
               else if(_loc11_ < 0 && _loc14_ >= 0)
               {
                  _loc8_ = _loc11_ / (_loc11_ - _loc14_);
                  _loc12_ = _loc9_ + (_loc12_ - _loc9_) * _loc8_;
                  _loc13_ = _loc10_ + (_loc13_ - _loc10_) * _loc8_;
               }
               _loc15_ = _loc15_.next;
            }
            if(_loc15_ == null)
            {
               param4 += (_loc12_ - param2) * (_loc10_ - param3) - (_loc13_ - param3) * (_loc9_ - param2);
               if(param4 / param5 >= this.minSize)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      override alternativa3d function updateBoundBox(param1:BoundBox, param2:Transform3D = null) : void
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc3_:Vertex = this.vertexList;
         while(_loc3_ != null)
         {
            if(param2 != null)
            {
               _loc4_ = param2.a * _loc3_.x + param2.b * _loc3_.y + param2.c * _loc3_.z + param2.d;
               _loc5_ = param2.e * _loc3_.x + param2.f * _loc3_.y + param2.g * _loc3_.z + param2.h;
               _loc6_ = param2.i * _loc3_.x + param2.j * _loc3_.y + param2.k * _loc3_.z + param2.l;
            }
            else
            {
               _loc4_ = _loc3_.x;
               _loc5_ = _loc3_.y;
               _loc6_ = _loc3_.z;
            }
            if(_loc4_ < param1.minX)
            {
               param1.minX = _loc4_;
            }
            if(_loc4_ > param1.maxX)
            {
               param1.maxX = _loc4_;
            }
            if(_loc5_ < param1.minY)
            {
               param1.minY = _loc5_;
            }
            if(_loc5_ > param1.maxY)
            {
               param1.maxY = _loc5_;
            }
            if(_loc6_ < param1.minZ)
            {
               param1.minZ = _loc6_;
            }
            if(_loc6_ > param1.maxZ)
            {
               param1.maxZ = _loc6_;
            }
            _loc3_ = _loc3_.next;
         }
      }
      
      override public function clone() : Object3D
      {
         var _loc1_:Occluder = new Occluder();
         _loc1_.clonePropertiesFrom(this);
         return _loc1_;
      }
      
      override protected function clonePropertiesFrom(param1:Object3D) : void
      {
         var _loc3_:Vertex = null;
         var _loc4_:Face = null;
         var _loc5_:Vertex = null;
         var _loc6_:Face = null;
         var _loc7_:Edge = null;
         var _loc9_:Vertex = null;
         var _loc10_:Face = null;
         var _loc11_:Wrapper = null;
         var _loc12_:Wrapper = null;
         var _loc13_:Wrapper = null;
         var _loc14_:Edge = null;
         super.clonePropertiesFrom(param1);
         var _loc2_:Occluder = param1 as Occluder;
         this.minSize = _loc2_.minSize;
         _loc3_ = _loc2_.vertexList;
         while(_loc3_ != null)
         {
            _loc9_ = new Vertex();
            _loc9_.x = _loc3_.x;
            _loc9_.y = _loc3_.y;
            _loc9_.z = _loc3_.z;
            _loc3_.value = _loc9_;
            if(_loc5_ != null)
            {
               _loc5_.next = _loc9_;
            }
            else
            {
               this.vertexList = _loc9_;
            }
            _loc5_ = _loc9_;
            _loc3_ = _loc3_.next;
         }
         _loc4_ = _loc2_.faceList;
         while(_loc4_ != null)
         {
            _loc10_ = new Face();
            _loc10_.normalX = _loc4_.normalX;
            _loc10_.normalY = _loc4_.normalY;
            _loc10_.normalZ = _loc4_.normalZ;
            _loc10_.offset = _loc4_.offset;
            _loc4_.processNext = _loc10_;
            _loc11_ = null;
            _loc12_ = _loc4_.wrapper;
            while(_loc12_ != null)
            {
               _loc13_ = new Wrapper();
               _loc13_.vertex = _loc12_.vertex.value;
               if(_loc11_ != null)
               {
                  _loc11_.next = _loc13_;
               }
               else
               {
                  _loc10_.wrapper = _loc13_;
               }
               _loc11_ = _loc13_;
               _loc12_ = _loc12_.next;
            }
            if(_loc6_ != null)
            {
               _loc6_.next = _loc10_;
            }
            else
            {
               this.faceList = _loc10_;
            }
            _loc6_ = _loc10_;
            _loc4_ = _loc4_.next;
         }
         var _loc8_:Edge = _loc2_.edgeList;
         while(_loc8_ != null)
         {
            _loc14_ = new Edge();
            _loc14_.a = _loc8_.a.value;
            _loc14_.b = _loc8_.b.value;
            _loc14_.left = _loc8_.left.processNext;
            _loc14_.right = _loc8_.right.processNext;
            if(_loc7_ != null)
            {
               _loc7_.next = _loc14_;
            }
            else
            {
               this.edgeList = _loc14_;
            }
            _loc7_ = _loc14_;
            _loc8_ = _loc8_.next;
         }
         _loc3_ = _loc2_.vertexList;
         while(_loc3_ != null)
         {
            _loc3_.value = null;
            _loc3_ = _loc3_.next;
         }
         _loc4_ = _loc2_.faceList;
         while(_loc4_ != null)
         {
            _loc4_.processNext = null;
            _loc4_ = _loc4_.next;
         }
      }
   }
}

class Vertex
{
   
   public var next:Vertex;
   
   public var value:Vertex;
   
   public var x:Number;
   
   public var y:Number;
   
   public var z:Number;
   
   public var offset:Number;
   
   public var cameraX:Number;
   
   public var cameraY:Number;
   
   public var cameraZ:Number;
   
   public function Vertex()
   {
      super();
   }
}

class Face
{
   
   public var next:Face;
   
   public var processNext:Face;
   
   public var normalX:Number;
   
   public var normalY:Number;
   
   public var normalZ:Number;
   
   public var offset:Number;
   
   public var wrapper:Wrapper;
   
   public var visible:Boolean;
   
   public function Face()
   {
      super();
   }
   
   public function calculateBestSequenceAndNormal() : void
   {
      var _loc1_:Wrapper = null;
      var _loc2_:Vertex = null;
      var _loc3_:Vertex = null;
      var _loc4_:Vertex = null;
      var _loc5_:Number = NaN;
      var _loc6_:Number = NaN;
      var _loc7_:Number = NaN;
      var _loc8_:Number = NaN;
      var _loc9_:Number = NaN;
      var _loc10_:Number = NaN;
      var _loc11_:Number = NaN;
      var _loc12_:Number = NaN;
      var _loc13_:Number = NaN;
      var _loc14_:Number = NaN;
      var _loc15_:Number = NaN;
      var _loc16_:Wrapper = null;
      var _loc17_:Wrapper = null;
      var _loc18_:Wrapper = null;
      var _loc19_:Wrapper = null;
      var _loc20_:Wrapper = null;
      if(this.wrapper.next.next.next != null)
      {
         _loc15_ = -1e+22;
         _loc1_ = this.wrapper;
         while(_loc1_ != null)
         {
            _loc19_ = _loc1_.next != null ? _loc1_.next : this.wrapper;
            _loc20_ = _loc19_.next != null ? _loc19_.next : this.wrapper;
            _loc2_ = _loc1_.vertex;
            _loc3_ = _loc19_.vertex;
            _loc4_ = _loc20_.vertex;
            _loc5_ = _loc3_.x - _loc2_.x;
            _loc6_ = _loc3_.y - _loc2_.y;
            _loc7_ = _loc3_.z - _loc2_.z;
            _loc8_ = _loc4_.x - _loc2_.x;
            _loc9_ = _loc4_.y - _loc2_.y;
            _loc10_ = _loc4_.z - _loc2_.z;
            _loc11_ = _loc10_ * _loc6_ - _loc9_ * _loc7_;
            _loc12_ = _loc8_ * _loc7_ - _loc10_ * _loc5_;
            _loc13_ = _loc9_ * _loc5_ - _loc8_ * _loc6_;
            _loc14_ = _loc11_ * _loc11_ + _loc12_ * _loc12_ + _loc13_ * _loc13_;
            if(_loc14_ > _loc15_)
            {
               _loc15_ = _loc14_;
               _loc16_ = _loc1_;
            }
            _loc1_ = _loc1_.next;
         }
         if(_loc16_ != this.wrapper)
         {
            _loc17_ = this.wrapper.next.next.next;
            while(_loc17_.next != null)
            {
               _loc17_ = _loc17_.next;
            }
            _loc18_ = this.wrapper;
            while(_loc18_.next != _loc16_ && _loc18_.next != null)
            {
               _loc18_ = _loc18_.next;
            }
            _loc17_.next = this.wrapper;
            _loc18_.next = null;
            this.wrapper = _loc16_;
         }
      }
      _loc1_ = this.wrapper;
      _loc2_ = _loc1_.vertex;
      _loc1_ = _loc1_.next;
      _loc3_ = _loc1_.vertex;
      _loc1_ = _loc1_.next;
      _loc4_ = _loc1_.vertex;
      _loc5_ = _loc3_.x - _loc2_.x;
      _loc6_ = _loc3_.y - _loc2_.y;
      _loc7_ = _loc3_.z - _loc2_.z;
      _loc8_ = _loc4_.x - _loc2_.x;
      _loc9_ = _loc4_.y - _loc2_.y;
      _loc10_ = _loc4_.z - _loc2_.z;
      _loc11_ = _loc10_ * _loc6_ - _loc9_ * _loc7_;
      _loc12_ = _loc8_ * _loc7_ - _loc10_ * _loc5_;
      _loc13_ = _loc9_ * _loc5_ - _loc8_ * _loc6_;
      _loc14_ = _loc11_ * _loc11_ + _loc12_ * _loc12_ + _loc13_ * _loc13_;
      if(_loc14_ > 0)
      {
         _loc14_ = 1 / Math.sqrt(_loc14_);
         _loc11_ *= _loc14_;
         _loc12_ *= _loc14_;
         _loc13_ *= _loc14_;
         this.normalX = _loc11_;
         this.normalY = _loc12_;
         this.normalZ = _loc13_;
      }
      this.offset = _loc2_.x * _loc11_ + _loc2_.y * _loc12_ + _loc2_.z * _loc13_;
   }
}

class Wrapper
{
   
   public var next:Wrapper;
   
   public var vertex:Vertex;
   
   public function Wrapper()
   {
      super();
   }
}

class Edge
{
   
   public var next:Edge;
   
   public var a:Vertex;
   
   public var b:Vertex;
   
   public var left:Face;
   
   public var right:Face;
   
   public function Edge()
   {
      super();
   }
}
