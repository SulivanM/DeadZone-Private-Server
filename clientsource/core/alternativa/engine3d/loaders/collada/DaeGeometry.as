package alternativa.engine3d.loaders.collada
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.VertexAttributes;
   import alternativa.engine3d.loaders.ParserMaterial;
   import alternativa.engine3d.objects.Mesh;
   import alternativa.engine3d.resources.Geometry;
   import flash.utils.ByteArray;
   import flash.utils.Endian;
   
   use namespace collada;
   use namespace alternativa3d;
   
   public class DaeGeometry extends DaeElement
   {
      
      internal var geometryVertices:Vector.<DaeVertex>;
      
      public var primitives:Vector.<DaePrimitive>;
      
      internal var geometry:Geometry;
      
      private var vertices:DaeVertices;
      
      public function DaeGeometry(param1:XML, param2:DaeDocument)
      {
         super(param1,param2);
         this.constructVertices();
      }
      
      private function constructVertices() : void
      {
         var _loc1_:XML = data.mesh.vertices[0];
         if(_loc1_ != null)
         {
            this.vertices = new DaeVertices(_loc1_,document);
            document.vertices[this.vertices.id] = this.vertices;
            this.parsePrimitives();
         }
      }
      
      override protected function parseImplementation() : Boolean
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:DaePrimitive = null;
         var _loc4_:uint = 0;
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         var _loc7_:ByteArray = null;
         var _loc8_:int = 0;
         var _loc9_:DaeVertex = null;
         var _loc10_:int = 0;
         if(this.vertices != null)
         {
            this.vertices.parse();
            _loc1_ = this.vertices.positions.numbers.length / this.vertices.positions.stride;
            this.geometry = new Geometry();
            this.geometryVertices = new Vector.<DaeVertex>(_loc1_);
            _loc4_ = 0;
            _loc2_ = 0;
            while(_loc2_ < this.primitives.length)
            {
               _loc3_ = this.primitives[_loc2_];
               _loc3_.parse();
               if(_loc3_.verticesEquals(this.vertices))
               {
                  _loc1_ = int(this.geometryVertices.length);
                  _loc4_ |= _loc3_.fillGeometry(this.geometry,this.geometryVertices);
               }
               _loc2_++;
            }
            _loc5_ = new Array(3);
            _loc5_[0] = VertexAttributes.POSITION;
            _loc5_[1] = VertexAttributes.POSITION;
            _loc5_[2] = VertexAttributes.POSITION;
            _loc6_ = 3;
            if(_loc4_ & DaePrimitive.NORMALS)
            {
               var _loc11_:*;
               _loc5_[_loc11_ = _loc6_++] = VertexAttributes.NORMAL;
               var _loc12_:*;
               _loc5_[_loc12_ = _loc6_++] = VertexAttributes.NORMAL;
               var _loc13_:*;
               _loc5_[_loc13_ = _loc6_++] = VertexAttributes.NORMAL;
            }
            if(_loc4_ & DaePrimitive.TANGENT4)
            {
               _loc5_[_loc11_ = _loc6_++] = VertexAttributes.TANGENT4;
               _loc5_[_loc12_ = _loc6_++] = VertexAttributes.TANGENT4;
               _loc5_[_loc13_ = _loc6_++] = VertexAttributes.TANGENT4;
               var _loc14_:*;
               _loc5_[_loc14_ = _loc6_++] = VertexAttributes.TANGENT4;
            }
            _loc2_ = 0;
            while(_loc2_ < 8)
            {
               if(_loc4_ & DaePrimitive.TEXCOORDS[_loc2_])
               {
                  _loc5_[_loc11_ = _loc6_++] = VertexAttributes.TEXCOORDS[_loc2_];
                  _loc5_[_loc12_ = _loc6_++] = VertexAttributes.TEXCOORDS[_loc2_];
               }
               _loc2_++;
            }
            this.geometry.addVertexStream(_loc5_);
            _loc1_ = int(this.geometryVertices.length);
            _loc7_ = new ByteArray();
            _loc7_.endian = Endian.LITTLE_ENDIAN;
            _loc8_ = int(_loc5_.length);
            _loc7_.length = 4 * _loc8_ * _loc1_;
            _loc2_ = 0;
            while(_loc2_ < _loc1_)
            {
               _loc9_ = this.geometryVertices[_loc2_];
               if(_loc9_ != null)
               {
                  _loc7_.position = 4 * _loc8_ * _loc2_;
                  _loc7_.writeFloat(_loc9_.x);
                  _loc7_.writeFloat(_loc9_.y);
                  _loc7_.writeFloat(_loc9_.z);
                  if(_loc9_.normal != null)
                  {
                     _loc7_.writeFloat(_loc9_.normal.x);
                     _loc7_.writeFloat(_loc9_.normal.y);
                     _loc7_.writeFloat(_loc9_.normal.z);
                  }
                  if(_loc9_.tangent != null)
                  {
                     _loc7_.writeFloat(_loc9_.tangent.x);
                     _loc7_.writeFloat(_loc9_.tangent.y);
                     _loc7_.writeFloat(_loc9_.tangent.z);
                     _loc7_.writeFloat(_loc9_.tangent.w);
                  }
                  _loc10_ = 0;
                  while(_loc10_ < _loc9_.uvs.length)
                  {
                     _loc7_.writeFloat(_loc9_.uvs[_loc10_]);
                     _loc10_++;
                  }
               }
               _loc2_++;
            }
            this.geometry.alternativa3d::_vertexStreams[0].data = _loc7_;
            this.geometry.alternativa3d::_numVertices = _loc1_;
            return true;
         }
         return false;
      }
      
      private function parsePrimitives() : void
      {
         var _loc4_:XML = null;
         var _loc5_:DaePrimitive = null;
         this.primitives = new Vector.<DaePrimitive>();
         var _loc1_:XMLList = data.mesh.children();
         var _loc2_:int = 0;
         var _loc3_:int = int(_loc1_.length());
         while(_loc2_ < _loc3_)
         {
            _loc4_ = _loc1_[_loc2_];
            switch(_loc4_.localName())
            {
               case "polygons":
               case "polylist":
               case "triangles":
               case "trifans":
               case "tristrips":
                  _loc5_ = new DaePrimitive(_loc4_,document);
                  this.primitives.push(_loc5_);
            }
            _loc2_++;
         }
      }
      
      public function parseMesh(param1:Object) : Mesh
      {
         var _loc2_:Mesh = null;
         var _loc3_:int = 0;
         var _loc4_:DaePrimitive = null;
         var _loc5_:DaeInstanceMaterial = null;
         var _loc6_:ParserMaterial = null;
         var _loc7_:DaeMaterial = null;
         if(data.mesh.length() > 0)
         {
            _loc2_ = new Mesh();
            _loc2_.geometry = this.geometry;
            _loc3_ = 0;
            while(_loc3_ < this.primitives.length)
            {
               _loc4_ = this.primitives[_loc3_];
               _loc5_ = param1[_loc4_.materialSymbol];
               if(_loc5_ != null)
               {
                  _loc7_ = _loc5_.material;
                  if(_loc7_ != null)
                  {
                     _loc7_.parse();
                     _loc6_ = _loc7_.material;
                     _loc7_.used = true;
                  }
               }
               _loc2_.addSurface(_loc6_,_loc4_.indexBegin,_loc4_.numTriangles);
               _loc3_++;
            }
            _loc2_.calculateBoundBox();
            return _loc2_;
         }
         return null;
      }
   }
}

