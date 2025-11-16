package alternativa.engine3d.loaders.collada
{
   import alternativa.engine3d.*;
   import alternativa.engine3d.animation.AnimationClip;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.VertexAttributes;
   import alternativa.engine3d.loaders.ParserMaterial;
   import alternativa.engine3d.objects.Joint;
   import alternativa.engine3d.objects.Skin;
   import alternativa.engine3d.resources.Geometry;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.Endian;
   
   use namespace collada;
   use namespace alternativa3d;
   
   public class DaeController extends DaeElement
   {
      
      private var jointsBindMatrices:Vector.<Vector.<Number>>;
      
      private var vcounts:Array;
      
      private var indices:Array;
      
      private var jointsInput:DaeInput;
      
      private var weightsInput:DaeInput;
      
      private var inputsStride:int;
      
      private var geometry:Geometry;
      
      private var primitives:Vector.<DaePrimitive>;
      
      private var maxJointsPerVertex:int = 0;
      
      private var bindShapeMatrix:Vector.<Number>;
      
      public function DaeController(param1:XML, param2:DaeDocument)
      {
         super(param1,param2);
      }
      
      private function get daeGeometry() : DaeGeometry
      {
         var _loc1_:DaeGeometry = document.findGeometry(data.skin.@source[0]);
         if(_loc1_ == null)
         {
            document.logger.logNotFoundError(data.@source[0]);
         }
         return _loc1_;
      }
      
      override protected function parseImplementation() : Boolean
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:Vector.<DaeVertex> = null;
         var _loc9_:Geometry = null;
         var _loc10_:int = 0;
         var _loc11_:Array = null;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:ByteArray = null;
         var _loc16_:ByteArray = null;
         var _loc17_:ByteArray = null;
         var _loc18_:int = 0;
         var _loc1_:XML = this.data.skin.vertex_weights[0];
         if(_loc1_ == null)
         {
            return false;
         }
         var _loc2_:XML = _loc1_.vcount[0];
         if(_loc2_ == null)
         {
            return false;
         }
         this.vcounts = parseIntsArray(_loc2_);
         var _loc3_:XML = _loc1_.v[0];
         if(_loc3_ == null)
         {
            return false;
         }
         this.indices = parseIntsArray(_loc3_);
         this.parseInputs();
         this.parseJointsBindMatrices();
         _loc4_ = 0;
         while(_loc4_ < this.vcounts.length)
         {
            _loc7_ = int(this.vcounts[_loc4_]);
            if(this.maxJointsPerVertex < _loc7_)
            {
               this.maxJointsPerVertex = _loc7_;
            }
            _loc4_++;
         }
         var _loc6_:DaeGeometry = this.daeGeometry;
         this.bindShapeMatrix = this.getBindShapeMatrix();
         if(_loc6_ != null)
         {
            _loc6_.parse();
            _loc8_ = _loc6_.geometryVertices;
            _loc9_ = _loc6_.geometry;
            _loc10_ = this.maxJointsPerVertex % 2 != 0 ? this.maxJointsPerVertex + 1 : this.maxJointsPerVertex;
            this.geometry = new Geometry();
            this.geometry.alternativa3d::_indices = _loc9_.alternativa3d::_indices.slice();
            _loc11_ = _loc9_.getVertexStreamAttributes(0);
            _loc13_ = _loc12_ = int(_loc11_.length);
            _loc4_ = 0;
            while(_loc4_ < _loc10_)
            {
               _loc18_ = int(VertexAttributes.JOINTS[int(_loc4_ / 2)]);
               _loc11_[int(_loc13_++)] = _loc18_;
               _loc11_[int(_loc13_++)] = _loc18_;
               _loc11_[int(_loc13_++)] = _loc18_;
               _loc11_[int(_loc13_++)] = _loc18_;
               _loc4_ += 2;
            }
            _loc14_ = int(_loc11_.length);
            _loc15_ = _loc9_.alternativa3d::_vertexStreams[0].data;
            _loc16_ = new ByteArray();
            _loc16_.endian = Endian.LITTLE_ENDIAN;
            _loc16_.length = 4 * _loc14_ * _loc9_.alternativa3d::_numVertices;
            _loc15_.position = 0;
            _loc4_ = 0;
            while(_loc4_ < _loc9_.alternativa3d::_numVertices)
            {
               _loc16_.position = 4 * _loc14_ * _loc4_;
               _loc5_ = 0;
               while(_loc5_ < _loc12_)
               {
                  _loc16_.writeFloat(_loc15_.readFloat());
                  _loc5_++;
               }
               _loc4_++;
            }
            _loc17_ = this.createVertexBuffer(_loc8_,_loc10_);
            _loc17_.position = 0;
            _loc4_ = 0;
            while(_loc4_ < _loc9_.alternativa3d::_numVertices)
            {
               _loc16_.position = 4 * (_loc14_ * _loc4_ + _loc12_);
               _loc5_ = 0;
               while(_loc5_ < _loc10_)
               {
                  _loc16_.writeFloat(_loc17_.readFloat());
                  _loc16_.writeFloat(_loc17_.readFloat());
                  _loc5_++;
               }
               _loc4_++;
            }
            this.geometry.addVertexStream(_loc11_);
            this.geometry.alternativa3d::_vertexStreams[0].data = _loc16_;
            this.geometry.alternativa3d::_numVertices = _loc9_.alternativa3d::_numVertices;
            this.transformVertices(this.geometry);
            this.primitives = _loc6_.primitives;
         }
         return true;
      }
      
      private function transformVertices(param1:Geometry) : void
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
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc2_:ByteArray = param1.alternativa3d::_vertexStreams[0].data;
         var _loc3_:int = int(param1.alternativa3d::_vertexStreams[0].attributes.length);
         var _loc4_:int = param1.hasAttribute(VertexAttributes.NORMAL) ? param1.getAttributeOffset(VertexAttributes.NORMAL) : -1;
         var _loc5_:int = param1.hasAttribute(VertexAttributes.TANGENT4) ? param1.getAttributeOffset(VertexAttributes.TANGENT4) : -1;
         var _loc6_:int = 0;
         while(_loc6_ < param1.alternativa3d::_numVertices)
         {
            _loc2_.position = 4 * _loc3_ * _loc6_;
            _loc7_ = _loc2_.readFloat();
            _loc8_ = _loc2_.readFloat();
            _loc9_ = _loc2_.readFloat();
            _loc2_.position -= 12;
            _loc2_.writeFloat(_loc7_ * this.bindShapeMatrix[0] + _loc8_ * this.bindShapeMatrix[1] + _loc9_ * this.bindShapeMatrix[2] + this.bindShapeMatrix[3]);
            _loc2_.writeFloat(_loc7_ * this.bindShapeMatrix[4] + _loc8_ * this.bindShapeMatrix[5] + _loc9_ * this.bindShapeMatrix[6] + this.bindShapeMatrix[7]);
            _loc2_.writeFloat(_loc7_ * this.bindShapeMatrix[8] + _loc8_ * this.bindShapeMatrix[9] + _loc9_ * this.bindShapeMatrix[10] + this.bindShapeMatrix[11]);
            if(_loc4_ >= 0)
            {
               _loc2_.position = 4 * (_loc3_ * _loc6_ + _loc4_);
               _loc14_ = _loc2_.readFloat();
               _loc15_ = _loc2_.readFloat();
               _loc16_ = _loc2_.readFloat();
               _loc10_ = _loc14_ * this.bindShapeMatrix[0] + _loc15_ * this.bindShapeMatrix[1] + _loc16_ * this.bindShapeMatrix[2];
               _loc11_ = _loc14_ * this.bindShapeMatrix[4] + _loc15_ * this.bindShapeMatrix[5] + _loc16_ * this.bindShapeMatrix[6];
               _loc12_ = _loc14_ * this.bindShapeMatrix[8] + _loc15_ * this.bindShapeMatrix[9] + _loc16_ * this.bindShapeMatrix[10];
               _loc13_ = Math.sqrt(_loc10_ * _loc10_ + _loc11_ * _loc11_ + _loc12_ * _loc12_);
               _loc2_.position -= 12;
               _loc2_.writeFloat(_loc13_ > 0.0001 ? _loc10_ / _loc13_ : 0);
               _loc2_.writeFloat(_loc13_ > 0.0001 ? _loc11_ / _loc13_ : 0);
               _loc2_.writeFloat(_loc13_ > 0.0001 ? _loc12_ / _loc13_ : 1);
            }
            if(_loc5_ >= 0)
            {
               _loc2_.position = 4 * (_loc3_ * _loc6_ + _loc5_);
               _loc17_ = _loc2_.readFloat();
               _loc18_ = _loc2_.readFloat();
               _loc19_ = _loc2_.readFloat();
               _loc20_ = _loc2_.readFloat();
               _loc10_ = _loc17_ * this.bindShapeMatrix[0] + _loc18_ * this.bindShapeMatrix[1] + _loc19_ * this.bindShapeMatrix[2];
               _loc11_ = _loc17_ * this.bindShapeMatrix[4] + _loc18_ * this.bindShapeMatrix[5] + _loc19_ * this.bindShapeMatrix[6];
               _loc12_ = _loc17_ * this.bindShapeMatrix[8] + _loc18_ * this.bindShapeMatrix[9] + _loc19_ * this.bindShapeMatrix[10];
               _loc13_ = Math.sqrt(_loc10_ * _loc10_ + _loc11_ * _loc11_ + _loc12_ * _loc12_);
               _loc2_.position -= 16;
               _loc2_.writeFloat(_loc13_ > 0.0001 ? _loc10_ / _loc13_ : 0);
               _loc2_.writeFloat(_loc13_ > 0.0001 ? _loc11_ / _loc13_ : 0);
               _loc2_.writeFloat(_loc13_ > 0.0001 ? _loc12_ / _loc13_ : 1);
               _loc2_.writeFloat(_loc20_ < 0 ? -1 : 1);
            }
            _loc6_++;
         }
      }
      
      private function createVertexBuffer(param1:Vector.<DaeVertex>, param2:int) : ByteArray
      {
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc13_:Vector.<uint> = null;
         var _loc14_:DaeVertex = null;
         var _loc15_:Vector.<uint> = null;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc18_:int = 0;
         var _loc19_:int = 0;
         var _loc20_:int = 0;
         var _loc21_:int = 0;
         var _loc3_:int = this.jointsInput.offset;
         var _loc4_:int = this.weightsInput.offset;
         var _loc5_:DaeSource = this.weightsInput.prepareSource(1);
         var _loc6_:Vector.<Number> = _loc5_.numbers;
         var _loc7_:int = _loc5_.stride;
         var _loc10_:Dictionary = new Dictionary();
         var _loc11_:ByteArray = new ByteArray();
         _loc11_.length = param1.length * param2 * 8;
         _loc11_.endian = Endian.LITTLE_ENDIAN;
         _loc8_ = 0;
         _loc9_ = int(param1.length);
         while(_loc8_ < _loc9_)
         {
            _loc14_ = param1[_loc8_];
            if(_loc14_ != null)
            {
               _loc15_ = _loc10_[_loc14_.vertexInIndex];
               if(_loc15_ == null)
               {
                  _loc15_ = _loc10_[_loc14_.vertexInIndex] = new Vector.<uint>();
               }
               _loc15_.push(_loc14_.vertexOutIndex);
            }
            _loc8_++;
         }
         var _loc12_:int = 0;
         _loc8_ = 0;
         _loc9_ = int(this.vcounts.length);
         while(_loc8_ < _loc9_)
         {
            _loc16_ = int(this.vcounts[_loc8_]);
            _loc13_ = _loc10_[_loc8_];
            _loc17_ = 0;
            while(_loc17_ < _loc13_.length)
            {
               _loc11_.position = _loc13_[_loc17_] * param2 * 8;
               _loc18_ = 0;
               while(_loc18_ < _loc16_)
               {
                  _loc19_ = this.inputsStride * (_loc12_ + _loc18_);
                  _loc20_ = int(this.indices[int(_loc19_ + _loc3_)]);
                  if(_loc20_ >= 0)
                  {
                     _loc11_.writeFloat(_loc20_ * 3);
                     _loc21_ = int(this.indices[int(_loc19_ + _loc4_)]);
                     _loc11_.writeFloat(_loc6_[int(_loc7_ * _loc21_)]);
                  }
                  else
                  {
                     _loc11_.position += 8;
                  }
                  _loc18_++;
               }
               _loc17_++;
            }
            _loc12_ += _loc16_;
            _loc8_++;
         }
         _loc11_.position = 0;
         return _loc11_;
      }
      
      private function parseInputs() : void
      {
         var _loc5_:DaeInput = null;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc1_:XMLList = data.skin.vertex_weights.input;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = int(_loc1_.length());
         for(; _loc3_ < _loc4_; _loc7_ = _loc5_.offset,_loc2_ = _loc7_ > _loc2_ ? _loc7_ : _loc2_,_loc3_++)
         {
            _loc5_ = new DaeInput(_loc1_[_loc3_],document);
            _loc6_ = _loc5_.semantic;
            if(_loc6_ == null)
            {
               continue;
            }
            switch(_loc6_)
            {
               case "JOINT":
                  if(this.jointsInput == null)
                  {
                     this.jointsInput = _loc5_;
                  }
                  break;
               case "WEIGHT":
                  if(this.weightsInput == null)
                  {
                     this.weightsInput = _loc5_;
                  }
            }
         }
         this.inputsStride = _loc2_ + 1;
      }
      
      private function parseJointsBindMatrices() : void
      {
         var jointsXML:XML = null;
         var jointsSource:DaeSource = null;
         var stride:int = 0;
         var count:int = 0;
         var i:int = 0;
         var index:int = 0;
         var matrix:Vector.<Number> = null;
         var j:int = 0;
         jointsXML = data.skin.joints.input.(@semantic == "INV_BIND_MATRIX")[0];
         if(jointsXML != null)
         {
            jointsSource = document.findSource(jointsXML.@source[0]);
            if(jointsSource != null)
            {
               if(jointsSource.parse() && jointsSource.numbers != null && jointsSource.stride >= 16)
               {
                  stride = jointsSource.stride;
                  count = jointsSource.numbers.length / stride;
                  this.jointsBindMatrices = new Vector.<Vector.<Number>>(count);
                  i = 0;
                  while(i < count)
                  {
                     index = stride * i;
                     matrix = new Vector.<Number>(16);
                     this.jointsBindMatrices[i] = matrix;
                     j = 0;
                     while(j < 16)
                     {
                        matrix[j] = jointsSource.numbers[int(index + j)];
                        j++;
                     }
                     i++;
                  }
               }
            }
            else
            {
               document.logger.logNotFoundError(jointsXML.@source[0]);
            }
         }
      }
      
      public function parseSkin(param1:Object, param2:Vector.<DaeNode>, param3:Vector.<DaeNode>) : DaeObject
      {
         var _loc5_:int = 0;
         var _loc6_:Skin = null;
         var _loc7_:Vector.<DaeObject> = null;
         var _loc8_:int = 0;
         var _loc9_:DaePrimitive = null;
         var _loc10_:DaeInstanceMaterial = null;
         var _loc11_:ParserMaterial = null;
         var _loc12_:DaeMaterial = null;
         var _loc4_:XML = data.skin[0];
         if(_loc4_ != null)
         {
            this.bindShapeMatrix = this.getBindShapeMatrix();
            _loc5_ = int(this.jointsBindMatrices.length);
            _loc6_ = new Skin(this.maxJointsPerVertex);
            _loc6_.geometry = this.geometry;
            _loc7_ = this.addJointsToSkin(_loc6_,param2,this.findNodes(param3));
            this.setJointsBindMatrices(_loc7_);
            _loc6_.renderedJoints = this.collectRenderedJoints(_loc7_,_loc5_);
            if(this.primitives != null)
            {
               _loc8_ = 0;
               while(_loc8_ < this.primitives.length)
               {
                  _loc9_ = this.primitives[_loc8_];
                  _loc10_ = param1[_loc9_.materialSymbol];
                  if(_loc10_ != null)
                  {
                     _loc12_ = _loc10_.material;
                     if(_loc12_ != null)
                     {
                        _loc12_.parse();
                        _loc11_ = _loc12_.material;
                        _loc12_.used = true;
                     }
                  }
                  _loc6_.addSurface(_loc11_,_loc9_.indexBegin,_loc9_.numTriangles);
                  _loc8_++;
               }
            }
            _loc6_.calculateBoundBox();
            return new DaeObject(_loc6_,this.mergeJointsClips(_loc6_,_loc7_));
         }
         return null;
      }
      
      private function collectRenderedJoints(param1:Vector.<DaeObject>, param2:int) : Vector.<Joint>
      {
         var _loc3_:Vector.<Joint> = new Vector.<Joint>();
         var _loc4_:int = 0;
         while(_loc4_ < param2)
         {
            _loc3_[_loc4_] = Joint(param1[_loc4_].object);
            _loc4_++;
         }
         return _loc3_;
      }
      
      private function mergeJointsClips(param1:Skin, param2:Vector.<DaeObject>) : AnimationClip
      {
         var _loc7_:DaeObject = null;
         var _loc8_:AnimationClip = null;
         var _loc9_:Object3D = null;
         var _loc10_:int = 0;
         if(!this.hasJointsAnimation(param2))
         {
            return null;
         }
         var _loc3_:AnimationClip = new AnimationClip();
         var _loc4_:Array = [param1];
         var _loc5_:int = 0;
         var _loc6_:int = int(param2.length);
         while(_loc5_ < _loc6_)
         {
            _loc7_ = param2[_loc5_];
            _loc8_ = _loc7_.animation;
            if(_loc8_ != null)
            {
               _loc10_ = 0;
               while(_loc10_ < _loc8_.numTracks)
               {
                  _loc3_.addTrack(_loc8_.getTrackAt(_loc10_));
                  _loc10_++;
               }
            }
            else
            {
               _loc3_.addTrack(_loc7_.jointNode.createStaticTransformTrack());
            }
            _loc9_ = _loc7_.object;
            _loc9_.name = _loc7_.jointNode.animName;
            _loc4_.push(_loc9_);
            _loc5_++;
         }
         _loc3_.alternativa3d::_objects = _loc4_;
         return _loc3_;
      }
      
      private function hasJointsAnimation(param1:Vector.<DaeObject>) : Boolean
      {
         var _loc4_:DaeObject = null;
         var _loc2_:int = 0;
         var _loc3_:int = int(param1.length);
         while(_loc2_ < _loc3_)
         {
            _loc4_ = param1[_loc2_];
            if(_loc4_.animation != null)
            {
               return true;
            }
            _loc2_++;
         }
         return false;
      }
      
      private function setJointsBindMatrices(param1:Vector.<DaeObject>) : void
      {
         var _loc4_:DaeObject = null;
         var _loc5_:Vector.<Number> = null;
         var _loc2_:int = 0;
         var _loc3_:int = int(this.jointsBindMatrices.length);
         while(_loc2_ < _loc3_)
         {
            _loc4_ = param1[_loc2_];
            _loc5_ = this.jointsBindMatrices[_loc2_];
            Joint(_loc4_.object).alternativa3d::setBindPoseMatrix(_loc5_);
            _loc2_++;
         }
      }
      
      private function addJointsToSkin(param1:Skin, param2:Vector.<DaeNode>, param3:Vector.<DaeNode>) : Vector.<DaeObject>
      {
         var _loc6_:int = 0;
         var _loc9_:DaeNode = null;
         var _loc10_:DaeObject = null;
         var _loc4_:Dictionary = new Dictionary();
         var _loc5_:int = int(param3.length);
         _loc6_ = 0;
         while(_loc6_ < _loc5_)
         {
            _loc4_[param3[_loc6_]] = _loc6_;
            _loc6_++;
         }
         var _loc7_:Vector.<DaeObject> = new Vector.<DaeObject>(_loc5_);
         var _loc8_:int = int(param2.length);
         _loc6_ = 0;
         while(_loc6_ < _loc8_)
         {
            _loc9_ = param2[_loc6_];
            _loc10_ = this.addRootJointToSkin(param1,_loc9_,_loc7_,_loc4_);
            this.addJointChildren(Joint(_loc10_.object),_loc7_,_loc9_,_loc4_);
            _loc6_++;
         }
         return _loc7_;
      }
      
      private function addRootJointToSkin(param1:Skin, param2:DaeNode, param3:Vector.<DaeObject>, param4:Dictionary) : DaeObject
      {
         var _loc5_:Joint = new Joint();
         _loc5_.name = cloneString(param2.name);
         param1.addChild(_loc5_);
         var _loc6_:DaeObject = param2.applyAnimation(param2.applyTransformations(_loc5_));
         _loc6_.jointNode = param2;
         if(param2 in param4)
         {
            param3[param4[param2]] = _loc6_;
         }
         else
         {
            param3.push(_loc6_);
         }
         return _loc6_;
      }
      
      private function addJointChildren(param1:Joint, param2:Vector.<DaeObject>, param3:DaeNode, param4:Dictionary) : void
      {
         var _loc5_:DaeObject = null;
         var _loc9_:DaeNode = null;
         var _loc10_:Joint = null;
         var _loc6_:Vector.<DaeNode> = param3.nodes;
         var _loc7_:int = 0;
         var _loc8_:int = int(_loc6_.length);
         while(_loc7_ < _loc8_)
         {
            _loc9_ = _loc6_[_loc7_];
            if(_loc9_ in param4)
            {
               _loc10_ = new Joint();
               _loc10_.name = cloneString(_loc9_.name);
               _loc5_ = _loc9_.applyAnimation(_loc9_.applyTransformations(_loc10_));
               _loc5_.jointNode = _loc9_;
               param2[param4[_loc9_]] = _loc5_;
               param1.addChild(_loc10_);
               this.addJointChildren(_loc10_,param2,_loc9_,param4);
            }
            else if(this.hasJointInDescendants(_loc9_,param4))
            {
               _loc10_ = new Joint();
               _loc10_.name = cloneString(_loc9_.name);
               _loc5_ = _loc9_.applyAnimation(_loc9_.applyTransformations(_loc10_));
               _loc5_.jointNode = _loc9_;
               param2.push(_loc5_);
               param1.addChild(_loc10_);
               this.addJointChildren(_loc10_,param2,_loc9_,param4);
            }
            _loc7_++;
         }
      }
      
      private function hasJointInDescendants(param1:DaeNode, param2:Dictionary) : Boolean
      {
         var _loc6_:DaeNode = null;
         var _loc3_:Vector.<DaeNode> = param1.nodes;
         var _loc4_:int = 0;
         var _loc5_:int = int(_loc3_.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc3_[_loc4_];
            if(_loc6_ in param2 || this.hasJointInDescendants(_loc6_,param2))
            {
               return true;
            }
            _loc4_++;
         }
         return false;
      }
      
      private function getBindShapeMatrix() : Vector.<Number>
      {
         var _loc3_:Array = null;
         var _loc4_:int = 0;
         var _loc1_:XML = data.skin.bind_shape_matrix[0];
         var _loc2_:Vector.<Number> = new Vector.<Number>(16,true);
         if(_loc1_ != null)
         {
            _loc3_ = parseStringArray(_loc1_);
            _loc4_ = 0;
            while(_loc4_ < _loc3_.length)
            {
               _loc2_[_loc4_] = Number(_loc3_[_loc4_]);
               _loc4_++;
            }
         }
         return _loc2_;
      }
      
      private function isRootJointNode(param1:DaeNode, param2:Dictionary) : Boolean
      {
         var _loc3_:DaeNode = param1.parent;
         while(_loc3_ != null)
         {
            if(_loc3_ in param2)
            {
               return false;
            }
            _loc3_ = _loc3_.parent;
         }
         return true;
      }
      
      public function findRootJointNodes(param1:Vector.<DaeNode>) : Vector.<DaeNode>
      {
         var _loc5_:Dictionary = null;
         var _loc6_:Vector.<DaeNode> = null;
         var _loc7_:DaeNode = null;
         var _loc2_:Vector.<DaeNode> = this.findNodes(param1);
         var _loc3_:int = 0;
         var _loc4_:int = int(_loc2_.length);
         if(_loc4_ > 0)
         {
            _loc5_ = new Dictionary();
            _loc3_ = 0;
            while(_loc3_ < _loc4_)
            {
               _loc5_[_loc2_[_loc3_]] = _loc3_;
               _loc3_++;
            }
            _loc6_ = new Vector.<DaeNode>();
            _loc3_ = 0;
            while(_loc3_ < _loc4_)
            {
               _loc7_ = _loc2_[_loc3_];
               if(this.isRootJointNode(_loc7_,_loc5_))
               {
                  _loc6_.push(_loc7_);
               }
               _loc3_++;
            }
            return _loc6_;
         }
         return null;
      }
      
      private function findNode(param1:String, param2:Vector.<DaeNode>) : DaeNode
      {
         var _loc5_:DaeNode = null;
         var _loc3_:int = int(param2.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc5_ = param2[_loc4_].getNodeBySid(param1);
            if(_loc5_ != null)
            {
               return _loc5_;
            }
            _loc4_++;
         }
         return null;
      }
      
      private function findNodes(param1:Vector.<DaeNode>) : Vector.<DaeNode>
      {
         var jointsXML:XML = null;
         var jointsSource:DaeSource = null;
         var stride:int = 0;
         var count:int = 0;
         var nodes:Vector.<DaeNode> = null;
         var i:int = 0;
         var node:DaeNode = null;
         var skeletons:Vector.<DaeNode> = param1;
         jointsXML = data.skin.joints.input.(@semantic == "JOINT")[0];
         if(jointsXML != null)
         {
            jointsSource = document.findSource(jointsXML.@source[0]);
            if(jointsSource != null)
            {
               if(jointsSource.parse() && jointsSource.names != null)
               {
                  stride = jointsSource.stride;
                  count = jointsSource.names.length / stride;
                  nodes = new Vector.<DaeNode>(count);
                  i = 0;
                  while(i < count)
                  {
                     node = this.findNode(jointsSource.names[int(stride * i)],skeletons);
                     if(node == null)
                     {
                     }
                     nodes[i] = node;
                     i++;
                  }
                  return nodes;
               }
            }
            else
            {
               document.logger.logNotFoundError(jointsXML.@source[0]);
            }
         }
         return null;
      }
   }
}

