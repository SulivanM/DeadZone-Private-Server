package alternativa.engine3d.objects
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.BoundBox;
   import alternativa.engine3d.core.Camera3D;
   import alternativa.engine3d.core.DrawUnit;
   import alternativa.engine3d.core.Light3D;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Transform3D;
   import alternativa.engine3d.core.VertexAttributes;
   import alternativa.engine3d.core.VertexStream;
   import alternativa.engine3d.materials.Material;
   import alternativa.engine3d.materials.compiler.Linker;
   import alternativa.engine3d.materials.compiler.Procedure;
   import alternativa.engine3d.materials.compiler.VariableType;
   import alternativa.engine3d.resources.Geometry;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.Endian;
   
   use namespace alternativa3d;
   
   public class Skin extends Mesh
   {
      
      private static var _transformProcedures:Dictionary = new Dictionary();
      
      private static var _deltaTransformProcedures:Vector.<Procedure> = new Vector.<Procedure>(9);
      
      alternativa3d var _renderedJoints:Vector.<Joint>;
      
      alternativa3d var surfaceJoints:Vector.<Vector.<Joint>>;
      
      alternativa3d var surfaceTransformProcedures:Vector.<Procedure>;
      
      alternativa3d var surfaceDeltaTransformProcedures:Vector.<Procedure>;
      
      alternativa3d var maxInfluences:int = 0;
      
      public function Skin(param1:int)
      {
         super();
         this.alternativa3d::maxInfluences = param1;
         this.alternativa3d::surfaceJoints = new Vector.<Vector.<Joint>>();
         this.alternativa3d::surfaceTransformProcedures = new Vector.<Procedure>();
         this.alternativa3d::surfaceDeltaTransformProcedures = new Vector.<Procedure>();
      }
      
      public function calculateBindingMatrices() : void
      {
         var _loc2_:Joint = null;
         var _loc1_:Object3D = alternativa3d::childrenList;
         while(_loc1_ != null)
         {
            _loc2_ = _loc1_ as Joint;
            if(_loc2_ != null)
            {
               if(_loc2_.alternativa3d::transformChanged)
               {
                  _loc2_.alternativa3d::composeTransforms();
               }
               _loc2_.alternativa3d::bindPoseTransform.copy(_loc2_.alternativa3d::inverseTransform);
               _loc2_.alternativa3d::calculateBindingMatrices();
            }
            _loc1_ = _loc1_.alternativa3d::next;
         }
      }
      
      override public function addSurface(param1:Material, param2:uint, param3:uint) : Surface
      {
         this.alternativa3d::surfaceJoints[alternativa3d::_surfacesLength] = this.alternativa3d::_renderedJoints;
         this.alternativa3d::surfaceTransformProcedures[alternativa3d::_surfacesLength] = alternativa3d::transformProcedure;
         this.alternativa3d::surfaceDeltaTransformProcedures[alternativa3d::_surfacesLength] = alternativa3d::deltaTransformProcedure;
         return super.addSurface(param1,param2,param3);
      }
      
      private function divideSurface(param1:uint, param2:uint, param3:Surface, param4:Vector.<uint>, param5:uint, param6:ByteArray, param7:ByteArray, param8:Vector.<uint>, param9:Vector.<Surface>, param10:Vector.<Dictionary>) : uint
      {
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc17_:uint = 0;
         var _loc20_:Dictionary = null;
         var _loc21_:* = undefined;
         var _loc22_:* = undefined;
         var _loc23_:uint = 0;
         var _loc24_:Number = NaN;
         var _loc25_:uint = 0;
         var _loc28_:uint = 0;
         var _loc29_:uint = 0;
         var _loc30_:int = 0;
         var _loc31_:Dictionary = null;
         var _loc32_:Dictionary = null;
         var _loc33_:Surface = null;
         var _loc34_:uint = 0;
         var _loc35_:Number = NaN;
         var _loc11_:uint = uint(param3.indexBegin);
         var _loc12_:uint = uint(param3.numTriangles * 3);
         var _loc18_:Vector.<uint> = geometry.alternativa3d::_indices;
         var _loc19_:Dictionary = new Dictionary();
         _loc13_ = int(_loc11_);
         _loc15_ = int(_loc11_ + _loc12_);
         while(_loc13_ < _loc15_)
         {
            _loc20_ = _loc19_[_loc13_] = new Dictionary();
            _loc29_ = 0;
            _loc30_ = 0;
            while(_loc30_ < 3)
            {
               _loc17_ = _loc18_[int(_loc13_ + _loc30_)];
               _loc14_ = 0;
               _loc16_ = int(param4.length);
               while(_loc14_ < _loc16_)
               {
                  param6.position = param5 * _loc17_ + param4[_loc14_];
                  _loc23_ = uint(param6.readFloat());
                  _loc24_ = param6.readFloat();
                  if(_loc24_ > 0)
                  {
                     _loc20_[_loc23_] = true;
                  }
                  _loc14_++;
               }
               _loc30_++;
            }
            for(_loc21_ in _loc20_)
            {
               _loc29_++;
            }
            if(_loc29_ > param1)
            {
               throw new Error("Unable to divide Skin.");
            }
            _loc13_ += 3;
         }
         var _loc26_:Dictionary = this.optimizeGroups(_loc19_,param1,param2);
         var _loc27_:uint = 0;
         for(_loc21_ in _loc26_)
         {
            _loc31_ = _loc26_[_loc21_];
            _loc25_ = 0;
            _loc20_ = _loc19_[_loc21_];
            for(_loc22_ in _loc20_)
            {
               if(_loc20_[_loc22_] is Boolean)
               {
                  _loc20_[_loc22_] = 3 * _loc25_++;
               }
            }
            _loc32_ = new Dictionary();
            for(_loc22_ in _loc31_)
            {
               _loc13_ = 0;
               while(_loc13_ < 3)
               {
                  _loc17_ = _loc18_[int(_loc22_ + _loc13_)];
                  if(_loc32_[_loc17_] != null)
                  {
                     param8.push(_loc32_[_loc17_]);
                  }
                  else
                  {
                     _loc32_[_loc17_] = _loc27_;
                     param8.push(_loc27_++);
                     param7.writeBytes(param6,_loc17_ * param5,param5);
                     param7.position -= param5;
                     _loc34_ = param7.position;
                     _loc35_ = 0;
                     _loc14_ = 0;
                     while(_loc14_ < _loc16_)
                     {
                        param7.position = _loc34_ + param4[_loc14_];
                        _loc23_ = uint(param7.readFloat());
                        _loc24_ = param7.readFloat();
                        param7.position -= 8;
                        if(_loc24_ > 0)
                        {
                           param7.writeFloat(_loc20_[_loc23_]);
                           param7.writeFloat(_loc24_);
                           _loc35_ += _loc24_;
                        }
                        _loc14_++;
                     }
                     if(_loc35_ != 1)
                     {
                        _loc14_ = 0;
                        while(_loc14_ < _loc16_)
                        {
                           param7.position = _loc34_ + param4[_loc14_] + 4;
                           _loc24_ = param7.readFloat();
                           if(_loc24_ > 0)
                           {
                              param7.position -= 4;
                              param7.writeFloat(_loc24_ / _loc35_);
                           }
                           _loc14_++;
                        }
                     }
                     param7.position = _loc34_ + param5;
                  }
                  _loc13_++;
               }
            }
            _loc33_ = new Surface();
            _loc33_.alternativa3d::object = this;
            _loc33_.material = param3.material;
            _loc33_.indexBegin = _loc28_;
            _loc33_.numTriangles = (param8.length - _loc28_) / 3;
            param9.push(_loc33_);
            param10.push(_loc20_);
            _loc28_ = param8.length;
         }
         return _loc27_;
      }
      
      private function optimizeGroups(param1:Dictionary, param2:uint, param3:uint = 1) : Dictionary
      {
         var _loc4_:* = undefined;
         var _loc5_:* = undefined;
         var _loc8_:Number = NaN;
         var _loc9_:Dictionary = null;
         var _loc10_:Dictionary = null;
         var _loc11_:Number = NaN;
         var _loc12_:* = undefined;
         var _loc13_:Dictionary = null;
         var _loc14_:Dictionary = null;
         var _loc6_:Dictionary = new Dictionary();
         var _loc7_:int = 1;
         while(_loc7_ < param3 + 1)
         {
            _loc8_ = 1 - _loc7_ / param3;
            for(_loc4_ in param1)
            {
               _loc9_ = param1[_loc4_];
               for(_loc5_ in param1)
               {
                  if(_loc4_ != _loc5_)
                  {
                     _loc10_ = param1[_loc5_];
                     _loc11_ = this.calculateLikeFactor(_loc9_,_loc10_,param2);
                     if(_loc11_ >= _loc8_)
                     {
                        delete param1[_loc5_];
                        for(_loc12_ in _loc10_)
                        {
                           _loc9_[_loc12_] = true;
                        }
                        _loc13_ = _loc6_[_loc4_];
                        if(_loc13_ == null)
                        {
                           _loc13_ = _loc6_[_loc4_] = new Dictionary();
                           _loc13_[_loc4_] = true;
                        }
                        _loc14_ = _loc6_[_loc5_];
                        if(_loc14_ != null)
                        {
                           delete _loc6_[_loc5_];
                           for(_loc12_ in _loc14_)
                           {
                              _loc13_[_loc12_] = true;
                           }
                        }
                        else
                        {
                           _loc13_[_loc5_] = true;
                        }
                     }
                  }
               }
            }
            _loc7_++;
         }
         return _loc6_;
      }
      
      private function calculateLikeFactor(param1:Dictionary, param2:Dictionary, param3:uint) : Number
      {
         var _loc4_:* = undefined;
         var _loc5_:uint = 0;
         var _loc6_:uint = 0;
         var _loc7_:uint = 0;
         var _loc8_:uint = 0;
         for(_loc4_ in param1)
         {
            _loc5_++;
            if(param2[_loc4_] != null)
            {
               _loc6_++;
            }
            _loc7_++;
         }
         for(_loc4_ in param2)
         {
            if(param1[_loc4_] == null)
            {
               _loc5_++;
            }
            _loc8_++;
         }
         if(_loc5_ > param3)
         {
            return -1;
         }
         return _loc6_ / _loc5_;
      }
      
      public function divide(param1:uint, param2:uint = 1) : void
      {
         var _loc12_:* = undefined;
         var _loc19_:Vector.<uint> = null;
         var _loc20_:ByteArray = null;
         var _loc21_:Vector.<Dictionary> = null;
         var _loc22_:uint = 0;
         var _loc23_:int = 0;
         var _loc24_:int = 0;
         var _loc25_:uint = 0;
         var _loc26_:Vector.<Joint> = null;
         var _loc27_:Dictionary = null;
         var _loc28_:uint = 0;
         var _loc29_:Array = null;
         var _loc30_:ByteArray = null;
         if(this.alternativa3d::_renderedJoints == null || this.alternativa3d::maxInfluences <= 0)
         {
            return;
         }
         var _loc3_:int = geometry.findVertexStreamByAttribute(VertexAttributes.JOINTS[0]);
         var _loc4_:Vector.<uint> = new Vector.<uint>();
         var _loc5_:int = 0;
         if(_loc3_ >= 0)
         {
            _loc5_ = geometry.getAttributeOffset(VertexAttributes.JOINTS[0]) * 4;
            _loc4_.push(_loc5_);
            _loc4_.push(_loc5_ + 8);
            var _loc6_:int = geometry.findVertexStreamByAttribute(VertexAttributes.JOINTS[1]);
            if(_loc6_ >= 0)
            {
               _loc5_ = geometry.getAttributeOffset(VertexAttributes.JOINTS[1]) * 4;
               _loc4_.push(_loc5_);
               _loc4_.push(_loc5_ + 8);
               if(_loc3_ != _loc6_)
               {
                  throw new Error("Cannot divide skin, all joinst must be in the same buffer");
               }
            }
            _loc6_ = geometry.findVertexStreamByAttribute(VertexAttributes.JOINTS[2]);
            if(_loc6_ >= 0)
            {
               _loc5_ = geometry.getAttributeOffset(VertexAttributes.JOINTS[2]) * 4;
               _loc4_.push(_loc5_);
               _loc4_.push(_loc5_ + 8);
               if(_loc3_ != _loc6_)
               {
                  throw new Error("Cannot divide skin, all joinst must be in the same buffer");
               }
            }
            _loc6_ = geometry.findVertexStreamByAttribute(VertexAttributes.JOINTS[3]);
            if(_loc6_ >= 0)
            {
               _loc5_ = geometry.getAttributeOffset(VertexAttributes.JOINTS[3]) * 4;
               _loc4_.push(_loc5_);
               _loc4_.push(_loc5_ + 8);
               if(_loc3_ != _loc6_)
               {
                  throw new Error("Cannot divide skin, all joinst must be in the same buffer");
               }
            }
            var _loc7_:Vector.<Surface> = new Vector.<Surface>();
            var _loc8_:ByteArray = new ByteArray();
            _loc8_.endian = Endian.LITTLE_ENDIAN;
            var _loc9_:Vector.<uint> = new Vector.<uint>();
            var _loc10_:uint = 0;
            var _loc11_:uint = 0;
            var _loc13_:uint = 0;
            var _loc14_:uint = 0;
            this.alternativa3d::surfaceJoints.length = 0;
            var _loc15_:int = int(geometry.alternativa3d::_vertexStreams[_loc3_].attributes.length);
            var _loc16_:ByteArray = geometry.alternativa3d::_vertexStreams[_loc3_].data;
            var _loc17_:int = 0;
            while(_loc17_ < alternativa3d::_surfacesLength)
            {
               _loc19_ = new Vector.<uint>();
               _loc20_ = new ByteArray();
               _loc21_ = new Vector.<Dictionary>();
               _loc20_.endian = Endian.LITTLE_ENDIAN;
               _loc22_ = this.divideSurface(param1,param2,alternativa3d::_surfaces[_loc17_],_loc4_,_loc15_ * 4,_loc16_,_loc20_,_loc19_,_loc7_,_loc21_);
               _loc23_ = 0;
               _loc24_ = int(_loc19_.length);
               while(_loc23_ < _loc24_)
               {
                  var _loc31_:*;
                  _loc9_[_loc31_ = _loc10_++] = _loc11_ + _loc19_[_loc23_];
                  _loc23_++;
               }
               _loc23_ = 0;
               _loc24_ = int(_loc21_.length);
               while(_loc23_ < _loc24_)
               {
                  _loc25_ = 0;
                  _loc26_ = this.alternativa3d::surfaceJoints[_loc23_ + _loc13_] = new Vector.<Joint>();
                  _loc27_ = _loc21_[_loc23_];
                  for(_loc12_ in _loc27_)
                  {
                     _loc28_ = uint(_loc27_[_loc12_] / 3);
                     if(_loc26_.length < _loc28_)
                     {
                        _loc26_.length = _loc28_ + 1;
                     }
                     _loc26_[_loc28_] = this.alternativa3d::_renderedJoints[uint(_loc12_ / 3)];
                     _loc25_++;
                  }
                  _loc23_++;
               }
               _loc23_ = int(_loc13_);
               while(_loc23_ < _loc7_.length)
               {
                  _loc7_[_loc23_].indexBegin += _loc14_;
                  _loc23_++;
               }
               _loc13_ += _loc21_.length;
               _loc14_ += _loc19_.length;
               _loc8_.writeBytes(_loc20_,0,_loc20_.length);
               _loc11_ += _loc22_;
               _loc17_++;
            }
            alternativa3d::_surfaces = _loc7_;
            alternativa3d::_surfacesLength = _loc7_.length;
            this.alternativa3d::surfaceTransformProcedures.length = alternativa3d::_surfacesLength;
            this.alternativa3d::surfaceDeltaTransformProcedures.length = alternativa3d::_surfacesLength;
            this.alternativa3d::calculateSurfacesProcedures();
            var _loc18_:Geometry = new Geometry();
            _loc18_.alternativa3d::_indices = _loc9_;
            _loc17_ = 0;
            while(_loc17_ < geometry.alternativa3d::_vertexStreams.length)
            {
               _loc29_ = geometry.alternativa3d::_vertexStreams[_loc17_].attributes;
               _loc18_.addVertexStream(_loc29_);
               if(_loc17_ == _loc3_)
               {
                  _loc18_.alternativa3d::_vertexStreams[_loc17_].data = _loc8_;
               }
               else
               {
                  _loc30_ = new ByteArray();
                  _loc30_.endian = Endian.LITTLE_ENDIAN;
                  _loc30_.writeBytes(geometry.alternativa3d::_vertexStreams[_loc17_].data);
                  _loc18_.alternativa3d::_vertexStreams[_loc17_].data = _loc30_;
               }
               _loc17_++;
            }
            _loc18_.alternativa3d::_numVertices = _loc8_.length / (_loc18_.alternativa3d::_vertexStreams[0].attributes.length << 2);
            geometry = _loc18_;
            return;
         }
         throw new Error("Cannot divide skin, joints[0] must be binded");
      }
      
      alternativa3d function calculateJointsTransforms(param1:Object3D) : void
      {
         var _loc2_:Object3D = param1.alternativa3d::childrenList;
         while(_loc2_ != null)
         {
            if(_loc2_.alternativa3d::transformChanged)
            {
               _loc2_.alternativa3d::composeTransforms();
            }
            _loc2_.alternativa3d::localToGlobalTransform.combine(param1.alternativa3d::localToGlobalTransform,_loc2_.alternativa3d::transform);
            if(_loc2_ is Joint)
            {
               Joint(_loc2_).alternativa3d::calculateTransform();
            }
            this.alternativa3d::calculateJointsTransforms(_loc2_);
            _loc2_ = _loc2_.alternativa3d::next;
         }
      }
      
      override alternativa3d function updateBoundBox(param1:BoundBox, param2:Transform3D = null) : void
      {
         var _loc7_:Vector.<Joint> = null;
         var _loc13_:Surface = null;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:ByteArray = null;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc25_:Number = NaN;
         var _loc26_:int = 0;
         var _loc27_:Number = NaN;
         var _loc28_:int = 0;
         var _loc29_:Number = NaN;
         var _loc30_:Joint = null;
         var _loc31_:Transform3D = null;
         var _loc3_:Object3D = alternativa3d::childrenList;
         while(_loc3_ != null)
         {
            if(_loc3_.alternativa3d::transformChanged)
            {
               _loc3_.alternativa3d::composeTransforms();
            }
            _loc3_.alternativa3d::localToGlobalTransform.copy(_loc3_.alternativa3d::transform);
            if(_loc3_ is Joint)
            {
               Joint(_loc3_).alternativa3d::calculateTransform();
            }
            this.alternativa3d::calculateJointsTransforms(_loc3_);
            _loc3_ = _loc3_.alternativa3d::next;
         }
         var _loc4_:Dictionary = new Dictionary();
         var _loc5_:Vector.<uint> = geometry.alternativa3d::_indices;
         var _loc6_:int = 0;
         while(_loc6_ < alternativa3d::_surfacesLength)
         {
            _loc13_ = alternativa3d::_surfaces[_loc6_];
            _loc14_ = _loc13_.indexBegin;
            _loc15_ = _loc13_.indexBegin + _loc13_.numTriangles * 3;
            while(_loc14_ < _loc15_)
            {
               _loc4_[_loc5_[_loc14_]] = _loc6_;
               _loc14_++;
            }
            _loc6_++;
         }
         var _loc8_:VertexStream = geometry.alternativa3d::_attributesStreams[VertexAttributes.POSITION];
         var _loc9_:int = geometry.alternativa3d::_attributesOffsets[VertexAttributes.POSITION] * 4;
         var _loc10_:Vector.<VertexStream> = new Vector.<VertexStream>();
         var _loc11_:Vector.<int> = new Vector.<int>();
         _loc6_ = 0;
         while(_loc6_ < 4)
         {
            if(geometry.hasAttribute(VertexAttributes.JOINTS[_loc6_]))
            {
               _loc10_.push(geometry.alternativa3d::_attributesStreams[VertexAttributes.JOINTS[_loc6_]]);
               _loc11_.push(geometry.alternativa3d::_attributesOffsets[VertexAttributes.JOINTS[_loc6_]] * 4);
            }
            _loc6_++;
         }
         var _loc12_:uint = _loc10_.length;
         _loc6_ = 0;
         while(_loc6_ < geometry.alternativa3d::_numVertices)
         {
            _loc7_ = this.alternativa3d::surfaceJoints[_loc4_[_loc6_]];
            _loc16_ = _loc8_.data;
            _loc16_.position = _loc9_ + _loc6_ * _loc8_.attributes.length * 4;
            _loc17_ = _loc16_.readFloat();
            _loc18_ = _loc16_.readFloat();
            _loc19_ = _loc16_.readFloat();
            _loc20_ = 0;
            _loc21_ = 0;
            _loc22_ = 0;
            _loc14_ = 0;
            while(_loc14_ < _loc12_)
            {
               _loc16_ = _loc10_[_loc14_].data;
               _loc16_.position = _loc11_[_loc14_] + _loc6_ * _loc10_[_loc14_].attributes.length * 4;
               _loc26_ = _loc16_.readFloat();
               _loc27_ = _loc16_.readFloat();
               _loc28_ = _loc16_.readFloat();
               _loc29_ = _loc16_.readFloat();
               if(_loc27_ > 0)
               {
                  _loc30_ = _loc7_[int(_loc26_ / 3)];
                  _loc31_ = _loc30_.alternativa3d::jointTransform;
                  _loc23_ = _loc17_ * _loc31_.a + _loc18_ * _loc31_.b + _loc19_ * _loc31_.c + _loc31_.d;
                  _loc24_ = _loc17_ * _loc31_.e + _loc18_ * _loc31_.f + _loc19_ * _loc31_.g + _loc31_.h;
                  _loc25_ = _loc17_ * _loc31_.i + _loc18_ * _loc31_.j + _loc19_ * _loc31_.k + _loc31_.l;
                  _loc20_ += _loc23_ * _loc27_;
                  _loc21_ += _loc24_ * _loc27_;
                  _loc22_ += _loc25_ * _loc27_;
               }
               if(_loc29_ > 0)
               {
                  _loc30_ = _loc7_[int(_loc28_ / 3)];
                  _loc31_ = _loc30_.alternativa3d::jointTransform;
                  _loc23_ = _loc17_ * _loc31_.a + _loc18_ * _loc31_.b + _loc19_ * _loc31_.c + _loc31_.d;
                  _loc24_ = _loc17_ * _loc31_.e + _loc18_ * _loc31_.f + _loc19_ * _loc31_.g + _loc31_.h;
                  _loc25_ = _loc17_ * _loc31_.i + _loc18_ * _loc31_.j + _loc19_ * _loc31_.k + _loc31_.l;
                  _loc20_ += _loc23_ * _loc29_;
                  _loc21_ += _loc24_ * _loc29_;
                  _loc22_ += _loc25_ * _loc29_;
               }
               _loc14_++;
            }
            if(param2 != null)
            {
               _loc23_ = _loc20_ * param2.a + _loc21_ * param2.b + _loc22_ * param2.c + param2.d;
               _loc24_ = _loc20_ * param2.e + _loc21_ * param2.f + _loc22_ * param2.g + param2.h;
               _loc25_ = _loc20_ * param2.i + _loc21_ * param2.j + _loc22_ * param2.k + param2.l;
               _loc20_ = _loc23_;
               _loc21_ = _loc24_;
               _loc22_ = _loc25_;
            }
            if(_loc20_ < param1.minX)
            {
               param1.minX = _loc20_;
            }
            if(_loc21_ < param1.minY)
            {
               param1.minY = _loc21_;
            }
            if(_loc22_ < param1.minZ)
            {
               param1.minZ = _loc22_;
            }
            if(_loc20_ > param1.maxX)
            {
               param1.maxX = _loc20_;
            }
            if(_loc21_ > param1.maxY)
            {
               param1.maxY = _loc21_;
            }
            if(_loc22_ > param1.maxZ)
            {
               param1.maxZ = _loc22_;
            }
            _loc6_++;
         }
      }
      
      public function get renderedJoints() : Vector.<Joint>
      {
         return this.alternativa3d::_renderedJoints;
      }
      
      public function set renderedJoints(param1:Vector.<Joint>) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < alternativa3d::_surfacesLength)
         {
            if(this.alternativa3d::surfaceJoints[_loc2_] == this.alternativa3d::_renderedJoints)
            {
               this.alternativa3d::surfaceJoints[_loc2_] = param1;
            }
            _loc2_++;
         }
         this.alternativa3d::_renderedJoints = param1;
         this.alternativa3d::calculateSurfacesProcedures();
      }
      
      alternativa3d function calculateSurfacesProcedures() : void
      {
         var _loc1_:int = this.alternativa3d::_renderedJoints != null ? int(this.alternativa3d::_renderedJoints.length) : 0;
         alternativa3d::transformProcedure = this.calculateTransformProcedure(this.alternativa3d::maxInfluences,_loc1_);
         alternativa3d::deltaTransformProcedure = this.calculateDeltaTransformProcedure(this.alternativa3d::maxInfluences);
         var _loc2_:int = 0;
         while(_loc2_ < alternativa3d::_surfacesLength)
         {
            _loc1_ = this.alternativa3d::surfaceJoints[_loc2_] != null ? int(this.alternativa3d::surfaceJoints[_loc2_].length) : 0;
            this.alternativa3d::surfaceTransformProcedures[_loc2_] = this.calculateTransformProcedure(this.alternativa3d::maxInfluences,_loc1_);
            this.alternativa3d::surfaceDeltaTransformProcedures[_loc2_] = this.calculateDeltaTransformProcedure(this.alternativa3d::maxInfluences);
            _loc2_++;
         }
      }
      
      override alternativa3d function collectDraws(param1:Camera3D, param2:Vector.<Light3D>, param3:int, param4:Boolean) : void
      {
         var _loc7_:Surface = null;
         if(geometry == null)
         {
            return;
         }
         var _loc5_:Object3D = alternativa3d::childrenList;
         while(_loc5_ != null)
         {
            if(_loc5_.alternativa3d::transformChanged)
            {
               _loc5_.alternativa3d::composeTransforms();
            }
            _loc5_.alternativa3d::localToGlobalTransform.copy(_loc5_.alternativa3d::transform);
            if(_loc5_ is Joint)
            {
               Joint(_loc5_).alternativa3d::calculateTransform();
            }
            this.alternativa3d::calculateJointsTransforms(_loc5_);
            _loc5_ = _loc5_.alternativa3d::next;
         }
         var _loc6_:int = 0;
         while(_loc6_ < alternativa3d::_surfacesLength)
         {
            _loc7_ = alternativa3d::_surfaces[_loc6_];
            alternativa3d::transformProcedure = this.alternativa3d::surfaceTransformProcedures[_loc6_];
            alternativa3d::deltaTransformProcedure = this.alternativa3d::surfaceDeltaTransformProcedures[_loc6_];
            if(_loc7_.material != null)
            {
               _loc7_.material.alternativa3d::collectDraws(param1,_loc7_,geometry,param2,param3,param4);
            }
            if(alternativa3d::listening)
            {
               param1.view.alternativa3d::addSurfaceToMouseEvents(_loc7_,geometry,alternativa3d::transformProcedure);
            }
            _loc6_++;
         }
      }
      
      override alternativa3d function setTransformConstants(param1:DrawUnit, param2:Surface, param3:Linker, param4:Camera3D) : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:Joint = null;
         _loc5_ = 0;
         while(_loc5_ < this.alternativa3d::maxInfluences)
         {
            _loc9_ = int(VertexAttributes.JOINTS[_loc5_ >> 1]);
            param1.alternativa3d::setVertexBufferAt(param3.getVariableIndex("joint" + _loc5_.toString()),geometry.alternativa3d::getVertexBuffer(_loc9_),geometry.alternativa3d::_attributesOffsets[_loc9_],VertexAttributes.alternativa3d::FORMATS[_loc9_]);
            _loc5_ += 2;
         }
         var _loc7_:int = int(alternativa3d::_surfaces.indexOf(param2));
         var _loc8_:Vector.<Joint> = this.alternativa3d::surfaceJoints[_loc7_];
         _loc5_ = 0;
         _loc6_ = int(_loc8_.length);
         while(_loc5_ < _loc6_)
         {
            _loc10_ = _loc8_[_loc5_];
            param1.alternativa3d::setVertexConstantsFromTransform(_loc5_ * 3,_loc10_.alternativa3d::jointTransform);
            _loc5_++;
         }
      }
      
      private function calculateTransformProcedure(param1:int, param2:int) : Procedure
      {
         var _loc7_:int = 0;
         var _loc3_:Procedure = _transformProcedures[param1 | param2 << 16];
         if(_loc3_ != null)
         {
            return _loc3_;
         }
         _loc3_ = _transformProcedures[param1 | param2 << 16] = new Procedure(null,"SkinTransformProcedure");
         var _loc4_:Array = [];
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         while(_loc6_ < param1)
         {
            _loc7_ = int(_loc6_ / 2);
            if(_loc6_ % 2 == 0)
            {
               if(_loc6_ == 0)
               {
                  var _loc8_:*;
                  _loc4_[_loc8_ = _loc5_++] = "m34 t0.xyz, i0, c[a" + _loc7_ + ".x]";
                  var _loc9_:*;
                  _loc4_[_loc9_ = _loc5_++] = "mul o0, t0.xyz, a" + _loc7_ + ".y";
               }
               else
               {
                  _loc4_[_loc8_ = _loc5_++] = "m34 t0.xyz, i0, c[a" + _loc7_ + ".x]";
                  _loc4_[_loc9_ = _loc5_++] = "mul t0.xyz, t0.xyz, a" + _loc7_ + ".y";
                  var _loc10_:*;
                  _loc4_[_loc10_ = _loc5_++] = "add o0, o0, t0.xyz";
               }
            }
            else
            {
               _loc4_[_loc8_ = _loc5_++] = "m34 t0.xyz, i0, c[a" + _loc7_ + ".z]";
               _loc4_[_loc9_ = _loc5_++] = "mul t0.xyz, t0.xyz, a" + _loc7_ + ".w";
               _loc4_[_loc10_ = _loc5_++] = "add o0, o0, t0.xyz";
            }
            _loc6_++;
         }
         _loc4_[_loc8_ = _loc5_++] = "mov o0.w, i0.w";
         _loc3_.compileFromArray(_loc4_);
         _loc3_.assignConstantsArray(param2 * 3);
         _loc6_ = 0;
         while(_loc6_ < param1)
         {
            _loc3_.assignVariableName(VariableType.ATTRIBUTE,int(_loc6_ / 2),"joint" + _loc6_);
            _loc6_ += 2;
         }
         return _loc3_;
      }
      
      private function calculateDeltaTransformProcedure(param1:int) : Procedure
      {
         var _loc6_:int = 0;
         var _loc2_:Procedure = _deltaTransformProcedures[param1];
         if(_loc2_ != null)
         {
            return _loc2_;
         }
         _loc2_ = new Procedure(null,"SkinDeltaTransformProcedure");
         _deltaTransformProcedures[param1] = _loc2_;
         var _loc3_:Array = [];
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         while(_loc5_ < param1)
         {
            _loc6_ = int(_loc5_ / 2);
            if(_loc5_ % 2 == 0)
            {
               if(_loc5_ == 0)
               {
                  var _loc7_:*;
                  _loc3_[_loc7_ = _loc4_++] = "m33 t0.xyz, i0, c[a" + _loc6_ + ".x]";
                  var _loc8_:*;
                  _loc3_[_loc8_ = _loc4_++] = "mul o0, t0.xyz, a" + _loc6_ + ".y";
               }
               else
               {
                  _loc3_[_loc7_ = _loc4_++] = "m33 t0.xyz, i0, c[a" + _loc6_ + ".x]";
                  _loc3_[_loc8_ = _loc4_++] = "mul t0.xyz, t0.xyz, a" + _loc6_ + ".y";
                  var _loc9_:*;
                  _loc3_[_loc9_ = _loc4_++] = "add o0, o0, t0.xyz";
               }
            }
            else
            {
               _loc3_[_loc7_ = _loc4_++] = "m33 t0.xyz, i0, c[a" + _loc6_ + ".z]";
               _loc3_[_loc8_ = _loc4_++] = "mul t0.xyz, t0.xyz, a" + _loc6_ + ".w";
               _loc3_[_loc9_ = _loc4_++] = "add o0, o0, t0.xyz";
            }
            _loc5_++;
         }
         _loc3_[_loc7_ = _loc4_++] = "mov o0.w, i0.w";
         _loc3_[_loc8_ = _loc4_++] = "nrm o0.xyz, o0.xyz";
         _loc2_.compileFromArray(_loc3_);
         _loc5_ = 0;
         while(_loc5_ < param1)
         {
            _loc2_.assignVariableName(VariableType.ATTRIBUTE,int(_loc5_ / 2),"joint" + _loc5_);
            _loc5_ += 2;
         }
         return _loc2_;
      }
      
      override public function clone() : Object3D
      {
         var _loc1_:Skin = new Skin(this.alternativa3d::maxInfluences);
         _loc1_.clonePropertiesFrom(this);
         return _loc1_;
      }
      
      override protected function clonePropertiesFrom(param1:Object3D) : void
      {
         super.clonePropertiesFrom(param1);
         var _loc2_:Skin = Skin(param1);
         this.alternativa3d::maxInfluences = _loc2_.alternativa3d::maxInfluences;
         if(_loc2_.alternativa3d::_renderedJoints != null)
         {
            this.alternativa3d::_renderedJoints = this.cloneJointsVector(_loc2_.alternativa3d::_renderedJoints,_loc2_);
         }
         this.alternativa3d::transformProcedure = _loc2_.alternativa3d::transformProcedure;
         this.alternativa3d::deltaTransformProcedure = _loc2_.alternativa3d::deltaTransformProcedure;
         var _loc3_:int = 0;
         while(_loc3_ < alternativa3d::_surfacesLength)
         {
            this.alternativa3d::surfaceJoints[_loc3_] = this.cloneJointsVector(_loc2_.alternativa3d::surfaceJoints[_loc3_],_loc2_);
            this.alternativa3d::surfaceTransformProcedures[_loc3_] = _loc2_.alternativa3d::surfaceTransformProcedures[_loc3_];
            this.alternativa3d::surfaceDeltaTransformProcedures[_loc3_] = _loc2_.alternativa3d::surfaceDeltaTransformProcedures[_loc3_];
            _loc3_++;
         }
      }
      
      private function cloneJointsVector(param1:Vector.<Joint>, param2:Skin) : Vector.<Joint>
      {
         var _loc6_:Joint = null;
         var _loc3_:int = int(param1.length);
         var _loc4_:Vector.<Joint> = new Vector.<Joint>();
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_)
         {
            _loc6_ = param1[_loc5_];
            _loc4_[_loc5_] = Joint(this.findClonedJoint(_loc6_,param2,this));
            _loc5_++;
         }
         return _loc4_;
      }
      
      private function findClonedJoint(param1:Joint, param2:Object3D, param3:Object3D) : Object3D
      {
         var _loc6_:Object3D = null;
         var _loc4_:Object3D = param2.alternativa3d::childrenList;
         var _loc5_:Object3D = param3.alternativa3d::childrenList;
         while(_loc4_ != null)
         {
            if(_loc4_ == param1)
            {
               return _loc5_;
            }
            if(_loc4_.alternativa3d::childrenList != null)
            {
               _loc6_ = this.findClonedJoint(param1,_loc4_,_loc5_);
               if(_loc6_ != null)
               {
                  return _loc6_;
               }
            }
            _loc4_ = _loc4_.alternativa3d::next;
            _loc5_ = _loc5_.alternativa3d::next;
         }
         return null;
      }
   }
}

