package alternativa.engine3d.loaders.collada
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.resources.Geometry;
   
   use namespace collada;
   use namespace alternativa3d;
   
   public class DaePrimitive extends DaeElement
   {
      
      internal static const NORMALS:int = 1;
      
      internal static const TANGENT4:int = 2;
      
      internal static const TEXCOORDS:Vector.<uint> = Vector.<uint>([8,16,32,64,128,256,512,1024]);
      
      internal var verticesInput:DaeInput;
      
      internal var texCoordsInputs:Vector.<DaeInput>;
      
      internal var normalsInput:DaeInput;
      
      internal var biNormalsInputs:Vector.<DaeInput>;
      
      internal var tangentsInputs:Vector.<DaeInput>;
      
      internal var indices:Vector.<uint>;
      
      internal var inputsStride:int;
      
      public var indexBegin:int;
      
      public var numTriangles:int;
      
      public function DaePrimitive(param1:XML, param2:DaeDocument)
      {
         super(param1,param2);
      }
      
      override protected function parseImplementation() : Boolean
      {
         this.parseInputs();
         this.parseIndices();
         return true;
      }
      
      private function get type() : String
      {
         return data.localName() as String;
      }
      
      private function parseInputs() : void
      {
         var _loc5_:DaeInput = null;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         this.texCoordsInputs = new Vector.<DaeInput>();
         this.tangentsInputs = new Vector.<DaeInput>();
         this.biNormalsInputs = new Vector.<DaeInput>();
         var _loc1_:XMLList = data.input;
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
               case "VERTEX":
                  if(this.verticesInput == null)
                  {
                     this.verticesInput = _loc5_;
                  }
                  break;
               case "TEXCOORD":
                  this.texCoordsInputs.push(_loc5_);
                  break;
               case "NORMAL":
                  if(this.normalsInput == null)
                  {
                     this.normalsInput = _loc5_;
                  }
                  break;
               case "TEXTANGENT":
                  this.tangentsInputs.push(_loc5_);
                  break;
               case "TEXBINORMAL":
                  this.biNormalsInputs.push(_loc5_);
            }
         }
         this.inputsStride = _loc2_ + 1;
      }
      
      private function parseIndices() : void
      {
         var _loc1_:Array = null;
         var _loc5_:XMLList = null;
         var _loc6_:XMLList = null;
         var _loc7_:int = 0;
         this.indices = new Vector.<uint>();
         var _loc2_:Vector.<int> = new Vector.<int>();
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         switch(data.localName())
         {
            case "polylist":
            case "polygons":
               _loc5_ = data.vcount;
               _loc1_ = parseStringArray(_loc5_[0]);
               _loc3_ = 0;
               _loc4_ = int(_loc1_.length);
               while(true)
               {
                  if(_loc3_ < _loc4_)
                  {
                     _loc2_.push(parseInt(_loc1_[_loc3_]));
                     _loc3_++;
                     continue;
                  }
               }
            case "triangles":
               _loc6_ = data.p;
               _loc3_ = 0;
               _loc4_ = int(_loc6_.length());
               while(_loc3_ < _loc4_)
               {
                  _loc1_ = parseStringArray(_loc6_[_loc3_]);
                  _loc7_ = 0;
                  while(_loc7_ < _loc1_.length)
                  {
                     this.indices.push(parseInt(_loc1_[_loc7_],10));
                     _loc7_++;
                  }
                  if(_loc2_.length > 0)
                  {
                     this.indices = this.triangulate(this.indices,_loc2_);
                  }
                  _loc3_++;
               }
         }
      }
      
      private function triangulate(param1:Vector.<uint>, param2:Vector.<int>) : Vector.<uint>
      {
         var _loc4_:uint = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc3_:Vector.<uint> = new Vector.<uint>();
         var _loc5_:uint = 0;
         _loc6_ = 0;
         _loc9_ = int(param2.length);
         while(_loc6_ < _loc9_)
         {
            _loc10_ = param2[_loc6_];
            _loc11_ = _loc10_ * this.inputsStride;
            if(_loc10_ == 3)
            {
               _loc7_ = 0;
               while(_loc7_ < _loc11_)
               {
                  _loc3_[_loc5_] = param1[_loc4_];
                  _loc7_++;
                  _loc4_++;
                  _loc5_++;
               }
            }
            else
            {
               _loc7_ = 1;
               while(_loc7_ < _loc10_ - 1)
               {
                  _loc8_ = 0;
                  while(_loc8_ < this.inputsStride)
                  {
                     _loc3_[_loc5_] = param1[int(_loc4_ + _loc8_)];
                     _loc8_++;
                     _loc5_++;
                  }
                  _loc8_ = 0;
                  while(_loc8_ < this.inputsStride)
                  {
                     _loc3_[_loc5_] = param1[int(_loc4_ + this.inputsStride * _loc7_ + _loc8_)];
                     _loc8_++;
                     _loc5_++;
                  }
                  _loc8_ = 0;
                  while(_loc8_ < this.inputsStride)
                  {
                     _loc3_[_loc5_] = param1[int(_loc4_ + this.inputsStride * (_loc7_ + 1) + _loc8_)];
                     _loc8_++;
                     _loc5_++;
                  }
                  _loc7_++;
               }
               _loc4_ += this.inputsStride * _loc10_;
            }
            _loc6_++;
         }
         return _loc3_;
      }
      
      public function fillGeometry(param1:Geometry, param2:Vector.<DaeVertex>) : uint
      {
         var _loc9_:DaeSource = null;
         var _loc10_:DaeSource = null;
         var _loc12_:DaeSource = null;
         var _loc18_:uint = 0;
         var _loc19_:DaeVertex = null;
         var _loc20_:DaeSource = null;
         var _loc21_:int = 0;
         if(this.verticesInput == null)
         {
            return 0;
         }
         this.verticesInput.parse();
         var _loc3_:int = int(this.indices.length);
         var _loc4_:DaeVertices = document.findVertices(this.verticesInput.source);
         if(_loc4_ == null)
         {
            document.logger.logNotFoundError(this.verticesInput.source);
            return 0;
         }
         _loc4_.parse();
         var _loc5_:DaeSource = _loc4_.positions;
         var _loc6_:int = 3;
         var _loc7_:DaeSource = _loc5_;
         var _loc8_:DaeInput = this.verticesInput;
         var _loc11_:uint = 0;
         var _loc13_:Vector.<int> = new Vector.<int>();
         _loc13_.push(this.verticesInput.offset);
         if(this.normalsInput != null)
         {
            _loc12_ = this.normalsInput.prepareSource(3);
            _loc13_.push(this.normalsInput.offset);
            _loc6_ += 3;
            _loc11_ |= NORMALS;
            if(this.tangentsInputs.length > 0 && this.biNormalsInputs.length > 0)
            {
               _loc9_ = this.tangentsInputs[0].prepareSource(3);
               _loc13_.push(this.tangentsInputs[0].offset);
               _loc10_ = this.biNormalsInputs[0].prepareSource(3);
               _loc13_.push(this.biNormalsInputs[0].offset);
               _loc6_ += 4;
               _loc11_ |= TANGENT4;
            }
         }
         var _loc14_:Vector.<DaeSource> = new Vector.<DaeSource>();
         var _loc15_:int = int(this.texCoordsInputs.length);
         if(_loc15_ > 8)
         {
            _loc15_ = 8;
         }
         var _loc16_:int = 0;
         while(_loc16_ < _loc15_)
         {
            _loc20_ = this.texCoordsInputs[_loc16_].prepareSource(2);
            _loc14_.push(_loc20_);
            _loc13_.push(this.texCoordsInputs[_loc16_].offset);
            _loc6_ += 2;
            _loc11_ |= TEXCOORDS[_loc16_];
            _loc16_++;
         }
         var _loc17_:int = int(param2.length);
         this.indexBegin = param1.alternativa3d::_indices.length;
         _loc16_ = 0;
         while(_loc16_ < _loc3_)
         {
            _loc18_ = this.indices[int(_loc16_ + _loc8_.offset)];
            _loc19_ = param2[_loc18_];
            if(_loc19_ == null || !this.isEqual(_loc19_,this.indices,_loc16_,_loc13_))
            {
               if(_loc19_ != null)
               {
                  _loc18_ = uint(_loc17_++);
               }
               _loc19_ = new DaeVertex();
               param2[_loc18_] = _loc19_;
               _loc19_.vertexInIndex = this.indices[int(_loc16_ + this.verticesInput.offset)];
               _loc19_.addPosition(_loc5_.numbers,_loc19_.vertexInIndex,_loc5_.stride,document.unitScaleFactor);
               if(_loc12_ != null)
               {
                  _loc19_.addNormal(_loc12_.numbers,this.indices[int(_loc16_ + this.normalsInput.offset)],_loc12_.stride);
               }
               if(_loc9_ != null)
               {
                  _loc19_.addTangentBiDirection(_loc9_.numbers,this.indices[int(_loc16_ + this.tangentsInputs[0].offset)],_loc9_.stride,_loc10_.numbers,this.indices[int(_loc16_ + this.biNormalsInputs[0].offset)],_loc10_.stride);
               }
               _loc21_ = 0;
               while(_loc21_ < _loc14_.length)
               {
                  _loc19_.appendUV(_loc14_[_loc21_].numbers,this.indices[int(_loc16_ + this.texCoordsInputs[_loc21_].offset)],_loc14_[_loc21_].stride);
                  _loc21_++;
               }
            }
            _loc19_.vertexOutIndex = _loc18_;
            param1.alternativa3d::_indices.push(_loc18_);
            _loc16_ += this.inputsStride;
         }
         this.numTriangles = (param1.alternativa3d::_indices.length - this.indexBegin) / 3;
         return _loc11_;
      }
      
      private function isEqual(param1:DaeVertex, param2:Vector.<uint>, param3:int, param4:Vector.<int>) : Boolean
      {
         var _loc5_:int = int(param4.length);
         var _loc6_:int = 0;
         while(_loc6_ < _loc5_)
         {
            if(param1.indices[_loc6_] != param2[int(param3 + param4[_loc6_])])
            {
               return false;
            }
            _loc6_++;
         }
         return true;
      }
      
      private function findInputBySet(param1:Vector.<DaeInput>, param2:int) : DaeInput
      {
         var _loc5_:DaeInput = null;
         var _loc3_:int = 0;
         var _loc4_:int = int(param1.length);
         while(_loc3_ < _loc4_)
         {
            _loc5_ = param1[_loc3_];
            if(_loc5_.setNum == param2)
            {
               return _loc5_;
            }
            _loc3_++;
         }
         return null;
      }
      
      private function getTexCoordsDatas(param1:int) : Vector.<VertexChannelData>
      {
         var _loc3_:int = 0;
         var _loc6_:DaeInput = null;
         var _loc7_:DaeSource = null;
         var _loc8_:VertexChannelData = null;
         var _loc2_:DaeInput = this.findInputBySet(this.texCoordsInputs,param1);
         var _loc4_:int = int(this.texCoordsInputs.length);
         var _loc5_:Vector.<VertexChannelData> = new Vector.<VertexChannelData>();
         _loc3_ = 0;
         while(_loc3_ < _loc4_)
         {
            _loc6_ = this.texCoordsInputs[_loc3_];
            _loc7_ = _loc6_.prepareSource(2);
            if(_loc7_ != null)
            {
               _loc8_ = new VertexChannelData(_loc7_.numbers,_loc7_.stride,_loc6_.offset,_loc6_.setNum);
               if(_loc6_ == _loc2_)
               {
                  _loc5_.unshift(_loc8_);
               }
               else
               {
                  _loc5_.push(_loc8_);
               }
            }
            _loc3_++;
         }
         return _loc5_.length > 0 ? _loc5_ : null;
      }
      
      public function verticesEquals(param1:DaeVertices) : Boolean
      {
         var _loc2_:DaeVertices = document.findVertices(this.verticesInput.source);
         if(_loc2_ == null)
         {
            document.logger.logNotFoundError(this.verticesInput.source);
         }
         return _loc2_ == param1;
      }
      
      public function get materialSymbol() : String
      {
         var _loc1_:XML = data.@material[0];
         return _loc1_ == null ? null : _loc1_.toString();
      }
   }
}

import flash.geom.Point;

class VertexChannelData
{
   
   public var values:Vector.<Number>;
   
   public var stride:int;
   
   public var offset:int;
   
   public var index:int;
   
   public var channel:Vector.<Point>;
   
   public var inputSet:int;
   
   public function VertexChannelData(param1:Vector.<Number>, param2:int, param3:int, param4:int = 0)
   {
      super();
      this.values = param1;
      this.stride = param2;
      this.offset = param3;
      this.inputSet = param4;
   }
}
