package alternativa.engine3d.loaders
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.animation.AnimationClip;
   import alternativa.engine3d.animation.keys.Track;
   import alternativa.engine3d.animation.keys.TransformKey;
   import alternativa.engine3d.animation.keys.TransformTrack;
   import alternativa.engine3d.core.BoundBox;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.VertexAttributes;
   import alternativa.engine3d.core.VertexStream;
   import alternativa.engine3d.lights.AmbientLight;
   import alternativa.engine3d.lights.DirectionalLight;
   import alternativa.engine3d.lights.OmniLight;
   import alternativa.engine3d.lights.SpotLight;
   import alternativa.engine3d.materials.A3DUtils;
   import alternativa.engine3d.objects.Joint;
   import alternativa.engine3d.objects.LOD;
   import alternativa.engine3d.objects.Mesh;
   import alternativa.engine3d.objects.Skin;
   import alternativa.engine3d.objects.Sprite3D;
   import alternativa.engine3d.resources.ExternalTextureResource;
   import alternativa.engine3d.resources.Geometry;
   import alternativa.types.Long;
   import commons.A3DMatrix;
   import commons.Id;
   import flash.geom.Matrix3D;
   import flash.geom.Orientation3D;
   import flash.geom.Vector3D;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.Endian;
   import versions.version1.a3d.A3D;
   import versions.version1.a3d.geometry.A3DGeometry;
   import versions.version1.a3d.geometry.A3DIndexBuffer;
   import versions.version1.a3d.geometry.A3DVertexBuffer;
   import versions.version1.a3d.id.ParentId;
   import versions.version1.a3d.materials.A3DImage;
   import versions.version1.a3d.materials.A3DMap;
   import versions.version1.a3d.materials.A3DMaterial;
   import versions.version1.a3d.objects.A3DBox;
   import versions.version1.a3d.objects.A3DObject;
   import versions.version1.a3d.objects.A3DSurface;
   import versions.version2.a3d.A3D2;
   import versions.version2.a3d.A3D2Extra1;
   import versions.version2.a3d.A3D2Extra2;
   import versions.version2.a3d.animation.A3D2AnimationClip;
   import versions.version2.a3d.animation.A3D2Keyframe;
   import versions.version2.a3d.animation.A3D2Track;
   import versions.version2.a3d.geometry.A3D2IndexBuffer;
   import versions.version2.a3d.geometry.A3D2VertexAttributes;
   import versions.version2.a3d.geometry.A3D2VertexBuffer;
   import versions.version2.a3d.materials.A3D2CubeMap;
   import versions.version2.a3d.materials.A3D2Image;
   import versions.version2.a3d.materials.A3D2Map;
   import versions.version2.a3d.materials.A3D2Material;
   import versions.version2.a3d.objects.A3D2AmbientLight;
   import versions.version2.a3d.objects.A3D2Box;
   import versions.version2.a3d.objects.A3D2DirectionalLight;
   import versions.version2.a3d.objects.A3D2Joint;
   import versions.version2.a3d.objects.A3D2JointBindTransform;
   import versions.version2.a3d.objects.A3D2LOD;
   import versions.version2.a3d.objects.A3D2Layer;
   import versions.version2.a3d.objects.A3D2Mesh;
   import versions.version2.a3d.objects.A3D2Object;
   import versions.version2.a3d.objects.A3D2OmniLight;
   import versions.version2.a3d.objects.A3D2Skin;
   import versions.version2.a3d.objects.A3D2SpotLight;
   import versions.version2.a3d.objects.A3D2Sprite;
   import versions.version2.a3d.objects.A3D2Surface;
   import versions.version2.a3d.objects.A3D2Transform;
   
   use namespace alternativa3d;
   
   public class Parser
   {
      
      public var hierarchy:Vector.<Object3D>;
      
      public var objects:Vector.<Object3D>;
      
      public var animations:Vector.<AnimationClip>;
      
      public var materials:Vector.<ParserMaterial>;
      
      private var maps:Dictionary;
      
      private var cubemaps:Dictionary;
      
      alternativa3d var layersMap:Dictionary;
      
      alternativa3d var layers:Vector.<String>;
      
      alternativa3d var compressedBuffers:Boolean = false;
      
      private var parsedMaterials:Dictionary;
      
      private var parsedGeometries:Object;
      
      private var unpackedBuffers:Dictionary;
      
      private var objectsMap:Dictionary;
      
      private var parents:Dictionary = new Dictionary();
      
      private var a3DBoxes:Dictionary = new Dictionary();
      
      public function Parser()
      {
         super();
      }
      
      private static function convert1_2(param1:A3D) : A3D2
      {
         var _loc20_:int = 0;
         var _loc21_:int = 0;
         var _loc22_:A3DBox = null;
         var _loc23_:A3D2Box = null;
         var _loc24_:A3DGeometry = null;
         var _loc25_:A3DImage = null;
         var _loc26_:A3D2Image = null;
         var _loc27_:A3DMap = null;
         var _loc28_:A3D2Map = null;
         var _loc29_:A3DMaterial = null;
         var _loc30_:A3D2Material = null;
         var _loc31_:A3DObject = null;
         var _loc32_:A3D2Mesh = null;
         var _loc33_:int = 0;
         var _loc34_:Vector.<int> = null;
         var _loc35_:A3DIndexBuffer = null;
         var _loc36_:Vector.<A3DVertexBuffer> = null;
         var _loc37_:A3D2IndexBuffer = null;
         var _loc38_:int = 0;
         var _loc39_:int = 0;
         var _loc40_:A3DVertexBuffer = null;
         var _loc41_:Vector.<int> = null;
         var _loc42_:Vector.<A3D2VertexAttributes> = null;
         var _loc43_:int = 0;
         var _loc44_:int = 0;
         var _loc45_:A3D2VertexBuffer = null;
         var _loc46_:int = 0;
         var _loc47_:A3D2Object = null;
         var _loc2_:Vector.<A3DBox> = param1.boxes;
         var _loc3_:Vector.<A3D2Box> = null;
         if(_loc2_ != null)
         {
            _loc3_ = new Vector.<A3D2Box>();
            _loc20_ = 0;
            _loc21_ = int(_loc2_.length);
            while(_loc20_ < _loc21_)
            {
               _loc22_ = _loc2_[_loc20_];
               _loc23_ = new A3D2Box(_loc22_.box,_loc22_.id.id);
               _loc3_[_loc20_] = _loc23_;
               _loc20_++;
            }
         }
         var _loc4_:Dictionary = new Dictionary();
         if(param1.geometries != null)
         {
            for each(_loc24_ in param1.geometries)
            {
               _loc4_[_loc24_.id.id] = _loc24_;
            }
         }
         var _loc5_:Vector.<A3DImage> = param1.images;
         var _loc6_:Vector.<A3D2Image> = null;
         if(_loc5_ != null)
         {
            _loc6_ = new Vector.<A3D2Image>();
            _loc20_ = 0;
            _loc21_ = int(_loc5_.length);
            while(_loc20_ < _loc21_)
            {
               _loc25_ = _loc5_[_loc20_];
               _loc26_ = new A3D2Image(_loc25_.id.id,_loc25_.url);
               _loc6_[_loc20_] = _loc26_;
               _loc20_++;
            }
         }
         var _loc7_:Vector.<A3DMap> = param1.maps;
         var _loc8_:Vector.<A3D2Map> = null;
         if(_loc7_ != null)
         {
            _loc8_ = new Vector.<A3D2Map>();
            _loc20_ = 0;
            _loc21_ = int(_loc7_.length);
            while(_loc20_ < _loc21_)
            {
               _loc27_ = _loc7_[_loc20_];
               _loc28_ = new A3D2Map(_loc27_.channel,_loc27_.id.id,_loc27_.imageId.id);
               _loc8_[_loc20_] = _loc28_;
               _loc20_++;
            }
         }
         var _loc9_:Vector.<A3DMaterial> = param1.materials;
         var _loc10_:Vector.<A3D2Material> = null;
         if(_loc9_ != null)
         {
            _loc10_ = new Vector.<A3D2Material>();
            _loc20_ = 0;
            _loc21_ = int(_loc9_.length);
            while(_loc20_ < _loc21_)
            {
               _loc29_ = _loc9_[_loc20_];
               _loc30_ = new A3D2Material(idToInt(_loc29_.diffuseMapId),idToInt(_loc29_.glossinessMapId),idToInt(_loc29_.id),idToInt(_loc29_.lightMapId),idToInt(_loc29_.normalMapId),idToInt(_loc29_.opacityMapId),-1,idToInt(_loc29_.specularMapId));
               _loc10_[_loc20_] = _loc30_;
               _loc20_++;
            }
         }
         var _loc11_:Vector.<A3DObject> = param1.objects;
         var _loc12_:Vector.<A3D2Object> = null;
         var _loc13_:Vector.<A3D2Mesh> = null;
         var _loc14_:Vector.<A3D2VertexBuffer> = null;
         var _loc15_:Vector.<A3D2IndexBuffer> = null;
         var _loc16_:uint = 0;
         var _loc17_:uint = 0;
         var _loc18_:Dictionary = new Dictionary();
         if(_loc11_ != null)
         {
            _loc13_ = new Vector.<A3D2Mesh>();
            _loc12_ = new Vector.<A3D2Object>();
            _loc14_ = new Vector.<A3D2VertexBuffer>();
            _loc15_ = new Vector.<A3D2IndexBuffer>();
            _loc20_ = 0;
            _loc21_ = int(_loc11_.length);
            while(_loc20_ < _loc21_)
            {
               _loc31_ = _loc11_[_loc20_];
               if(_loc31_.surfaces != null && _loc31_.surfaces.length > 0)
               {
                  _loc32_ = null;
                  _loc24_ = _loc4_[_loc31_.geometryId.id];
                  _loc33_ = -1;
                  _loc34_ = new Vector.<int>();
                  if(_loc24_ != null)
                  {
                     _loc35_ = _loc24_.indexBuffer;
                     _loc36_ = _loc24_.vertexBuffers;
                     _loc37_ = new A3D2IndexBuffer(_loc35_.byteBuffer,_loc16_++,_loc35_.indexCount);
                     _loc33_ = _loc37_.id;
                     _loc15_.push(_loc37_);
                     _loc38_ = 0;
                     _loc39_ = int(_loc36_.length);
                     while(_loc38_ < _loc39_)
                     {
                        _loc40_ = _loc36_[_loc38_];
                        _loc41_ = _loc40_.attributes;
                        _loc42_ = new Vector.<A3D2VertexAttributes>();
                        _loc43_ = 0;
                        _loc44_ = int(_loc41_.length);
                        while(_loc43_ < _loc44_)
                        {
                           _loc46_ = _loc41_[_loc43_];
                           switch(_loc46_)
                           {
                              case 0:
                                 _loc42_[_loc43_] = A3D2VertexAttributes.POSITION;
                                 break;
                              case 1:
                                 _loc42_[_loc43_] = A3D2VertexAttributes.NORMAL;
                                 break;
                              case 2:
                                 _loc42_[_loc43_] = A3D2VertexAttributes.TANGENT4;
                                 break;
                              case 3:
                                 break;
                              case 4:
                                 break;
                              case 5:
                                 _loc42_[_loc43_] = A3D2VertexAttributes.TEXCOORD;
                           }
                           _loc43_++;
                        }
                        _loc45_ = new A3D2VertexBuffer(_loc42_,_loc40_.byteBuffer,_loc17_++,_loc40_.vertexCount);
                        _loc14_.push(_loc45_);
                        _loc34_.push(_loc45_.id);
                        _loc38_++;
                     }
                  }
                  _loc32_ = new A3D2Mesh(idToInt(_loc31_.boundBoxId),idToLong(_loc31_.id),_loc33_,_loc31_.name,convertParent1_2(_loc31_.parentId),convertSurfaces1_2(_loc31_.surfaces),new A3D2Transform(_loc31_.transformation.matrix),_loc34_,_loc31_.visible);
                  _loc13_.push(_loc32_);
                  _loc18_[_loc31_.id.id] = _loc32_;
               }
               else
               {
                  _loc47_ = new A3D2Object(idToInt(_loc31_.boundBoxId),idToLong(_loc31_.id),_loc31_.name,convertParent1_2(_loc31_.parentId),new A3D2Transform(_loc31_.transformation.matrix),_loc31_.visible);
                  _loc12_.push(_loc47_);
                  _loc18_[_loc31_.id.id] = _loc47_;
               }
               _loc20_++;
            }
         }
         return new A3D2(null,null,null,_loc3_,null,null,null,_loc6_,_loc15_,null,_loc8_,_loc10_,_loc13_ != null && _loc13_.length > 0 ? _loc13_ : null,_loc12_ != null && _loc12_.length > 0 ? _loc12_ : null,null,null,null,null,_loc14_);
      }
      
      private static function idToInt(param1:Id) : int
      {
         return param1 != null ? int(param1.id) : -1;
      }
      
      private static function idToLong(param1:Id) : Long
      {
         return param1 != null ? Long.fromInt(param1.id) : Long.fromInt(-1);
      }
      
      private static function convertParent1_2(param1:ParentId) : Long
      {
         if(param1 == null)
         {
            return null;
         }
         return param1 != null ? Long.fromInt(param1.id) : null;
      }
      
      private static function convertSurfaces1_2(param1:Vector.<A3DSurface>) : Vector.<A3D2Surface>
      {
         var _loc5_:A3DSurface = null;
         var _loc6_:A3D2Surface = null;
         var _loc2_:Vector.<A3D2Surface> = new Vector.<A3D2Surface>();
         var _loc3_:int = 0;
         var _loc4_:int = int(param1.length);
         while(_loc3_ < _loc4_)
         {
            _loc5_ = param1[_loc3_];
            _loc6_ = new A3D2Surface(_loc5_.indexBegin,idToInt(_loc5_.materialId),_loc5_.numTriangles);
            _loc2_[_loc3_] = _loc6_;
            _loc3_++;
         }
         return _loc2_;
      }
      
      alternativa3d static function traceGeometry(param1:Geometry) : void
      {
         var _loc9_:* = null;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc2_:VertexStream = param1.alternativa3d::_vertexStreams[0];
         var _loc3_:int = -1;
         var _loc4_:int = int(_loc2_.attributes.length);
         var _loc5_:int = _loc4_ * 4;
         var _loc6_:int = _loc2_.data.length / _loc5_;
         var _loc7_:ByteArray = _loc2_.data;
         var _loc8_:int = 0;
         while(_loc8_ < _loc6_)
         {
            _loc9_ = "V" + _loc8_ + " ";
            _loc10_ = -4;
            _loc11_ = 0;
            while(_loc11_ < _loc4_)
            {
               _loc12_ = int(_loc2_.attributes[_loc11_]);
               if(_loc12_ != _loc3_)
               {
                  _loc10_ = param1.getAttributeOffset(_loc12_) * 4;
                  switch(_loc12_)
                  {
                     case VertexAttributes.POSITION:
                        _loc7_.position = _loc8_ * _loc5_ + _loc10_;
                        _loc9_ += "P[" + _loc7_.readFloat().toFixed(2) + ", " + _loc7_.readFloat().toFixed(2) + ", " + _loc7_.readFloat().toFixed(2) + "] ";
                        break;
                     case 20:
                        _loc7_.position = _loc8_ * _loc5_ + _loc10_;
                        _loc9_ += "A[" + _loc7_.readFloat().toString(2) + "]";
                        break;
                     case VertexAttributes.NORMAL:
                        _loc7_.position = _loc8_ * _loc5_ + _loc10_;
                        _loc13_ = _loc7_.readFloat();
                        _loc14_ = _loc7_.readFloat();
                        _loc15_ = _loc7_.readFloat();
                        break;
                     case VertexAttributes.TANGENT4:
                        _loc7_.position = _loc8_ * _loc5_ + _loc10_;
                        _loc13_ = _loc7_.readFloat();
                        _loc14_ = _loc7_.readFloat();
                        _loc15_ = _loc7_.readFloat();
                        break;
                     case VertexAttributes.JOINTS[0]:
                        _loc7_.position = _loc8_ * _loc5_ + _loc10_;
                        _loc9_ += "J0[" + _loc7_.readFloat().toFixed(0) + " = " + _loc7_.readFloat().toFixed(2) + ", " + _loc7_.readFloat().toFixed(0) + " = " + _loc7_.readFloat().toFixed(2) + "] ";
                        break;
                     case VertexAttributes.JOINTS[1]:
                        _loc7_.position = _loc8_ * _loc5_ + _loc10_;
                        _loc9_ += "J1[" + _loc7_.readFloat().toFixed(0) + " = " + _loc7_.readFloat().toFixed(2) + ", " + _loc7_.readFloat().toFixed(0) + " = " + _loc7_.readFloat().toFixed(2) + "] ";
                        break;
                     case VertexAttributes.JOINTS[2]:
                        _loc7_.position = _loc8_ * _loc5_ + _loc10_;
                        _loc9_ += "J1[" + _loc7_.readFloat().toFixed(0) + " = " + _loc7_.readFloat().toFixed(2) + ", " + _loc7_.readFloat().toFixed(0) + " = " + _loc7_.readFloat().toFixed(2) + "] ";
                        break;
                     case VertexAttributes.JOINTS[3]:
                        _loc7_.position = _loc8_ * _loc5_ + _loc10_;
                        _loc9_ += "J1[" + _loc7_.readFloat().toFixed(0) + " = " + _loc7_.readFloat().toFixed(2) + ", " + _loc7_.readFloat().toFixed(0) + " = " + _loc7_.readFloat().toFixed(2) + "] ";
                  }
                  _loc3_ = _loc12_;
               }
               _loc11_++;
            }
            _loc8_++;
         }
      }
      
      public function getObjectByName(param1:String) : Object3D
      {
         var _loc2_:Object3D = null;
         for each(_loc2_ in this.objects)
         {
            if(_loc2_.name == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function getLayerByObject(param1:Object3D) : String
      {
         return this.alternativa3d::layersMap[param1];
      }
      
      public function clean() : void
      {
         this.hierarchy = null;
         this.objects = null;
         this.materials = null;
         this.animations = null;
         this.alternativa3d::layersMap = null;
         this.objectsMap = null;
         this.a3DBoxes = null;
         this.parents = null;
         this.alternativa3d::layers = null;
      }
      
      alternativa3d function init() : void
      {
         this.hierarchy = new Vector.<Object3D>();
         this.objects = new Vector.<Object3D>();
         this.materials = new Vector.<ParserMaterial>();
         this.animations = new Vector.<AnimationClip>();
         this.alternativa3d::layersMap = new Dictionary(true);
         this.alternativa3d::layers = new Vector.<String>();
      }
      
      protected function complete(param1:Object) : void
      {
         var _loc2_:Vector.<Object> = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         this.alternativa3d::init();
         if(param1 is A3D)
         {
            this.doParse2_0(convert1_2(A3D(param1)));
         }
         else if(param1 is A3D2)
         {
            this.doParse2_0(A3D2(param1));
         }
         else if(param1 is Vector.<Object>)
         {
            _loc2_ = param1 as Vector.<Object>;
            _loc3_ = int(_loc2_.length);
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               this.doParsePart(_loc2_[_loc4_]);
               _loc4_++;
            }
         }
         this.completeHierarchy();
      }
      
      private function doParsePart(param1:Object) : void
      {
         if(param1 is A3D)
         {
            this.doParse2_0(convert1_2(A3D(param1)));
         }
         else if(param1 is A3D2)
         {
            this.doParse2_0(A3D2(param1));
         }
         else if(param1 is A3D2Extra1)
         {
            this.doParseExtra1(A3D2Extra1(param1));
         }
         else if(param1 is A3D2Extra2)
         {
            this.doParseExtra2(A3D2Extra2(param1));
         }
      }
      
      private function doParseExtra1(param1:A3D2Extra1) : void
      {
         var _loc3_:A3D2Layer = null;
         var _loc4_:String = null;
         var _loc5_:Long = null;
         var _loc2_:Vector.<A3D2Layer> = param1.layers;
         for each(_loc3_ in _loc2_)
         {
            _loc4_ = _loc3_.name == null || _loc3_.name.length == 0 ? "default" : _loc3_.name;
            this.alternativa3d::layers.push(_loc4_);
            for each(_loc5_ in _loc3_.objects)
            {
               if(this.objectsMap[_loc5_] != null)
               {
                  this.alternativa3d::layersMap[this.objectsMap[_loc5_]] = _loc4_;
               }
            }
         }
      }
      
      private function doParseExtra2(param1:A3D2Extra2) : void
      {
         var _loc3_:A3D2LOD = null;
         var _loc4_:LOD = null;
         var _loc5_:uint = 0;
         var _loc6_:int = 0;
         var _loc2_:Vector.<A3D2LOD> = param1.lods;
         for each(_loc3_ in _loc2_)
         {
            _loc4_ = new LOD();
            _loc4_.visible = _loc3_.visible;
            _loc4_.name = _loc3_.name;
            this.parents[_loc4_] = _loc3_.parentId;
            this.objectsMap[_loc3_.id] = _loc4_;
            _loc5_ = _loc3_.objects.length;
            _loc6_ = 0;
            while(_loc6_ < _loc5_)
            {
               _loc4_.addLevel(this.objectsMap[_loc3_.objects[_loc6_]],_loc3_.distances[_loc6_]);
               _loc6_++;
            }
            this.decomposeTransformation(_loc3_.transform,_loc4_);
         }
      }
      
      private function doParse2_0(param1:A3D2) : void
      {
         var _loc9_:A3D2Object = null;
         var _loc10_:A3D2Mesh = null;
         var _loc11_:A3D2IndexBuffer = null;
         var _loc12_:A3D2VertexBuffer = null;
         var _loc13_:A3D2Material = null;
         var _loc14_:A3D2Box = null;
         var _loc15_:A3D2Map = null;
         var _loc16_:A3D2Image = null;
         var _loc17_:A3D2AmbientLight = null;
         var _loc18_:A3D2OmniLight = null;
         var _loc19_:A3D2SpotLight = null;
         var _loc20_:A3D2DirectionalLight = null;
         var _loc21_:A3D2Skin = null;
         var _loc22_:A3D2Joint = null;
         var _loc23_:A3D2Sprite = null;
         var _loc24_:A3D2CubeMap = null;
         var _loc25_:A3D2Track = null;
         var _loc26_:AnimationClip = null;
         var _loc27_:Dictionary = null;
         var _loc28_:TransformTrack = null;
         var _loc29_:A3D2Keyframe = null;
         var _loc30_:TransformKey = null;
         var _loc31_:Vector.<Vector3D> = null;
         var _loc32_:A3D2AnimationClip = null;
         var _loc33_:int = 0;
         var _loc34_:Track = null;
         var _loc35_:Joint = null;
         var _loc36_:Object3D = null;
         var _loc37_:Sprite3D = null;
         var _loc38_:Mesh = null;
         var _loc39_:AmbientLight = null;
         var _loc40_:OmniLight = null;
         var _loc41_:SpotLight = null;
         var _loc42_:DirectionalLight = null;
         var _loc43_:Mesh = null;
         this.maps = new Dictionary();
         this.cubemaps = new Dictionary();
         this.parsedMaterials = new Dictionary();
         this.parsedGeometries = new Dictionary();
         this.unpackedBuffers = new Dictionary();
         this.objectsMap = new Dictionary();
         this.parents = new Dictionary();
         this.a3DBoxes = new Dictionary();
         var _loc2_:Dictionary = new Dictionary();
         var _loc3_:Dictionary = new Dictionary();
         var _loc4_:Dictionary = new Dictionary();
         var _loc5_:Dictionary = new Dictionary();
         var _loc6_:Dictionary = new Dictionary();
         var _loc7_:Dictionary = new Dictionary();
         var _loc8_:Dictionary = new Dictionary();
         for each(_loc11_ in param1.indexBuffers)
         {
            _loc3_[_loc11_.id] = _loc11_;
         }
         for each(_loc25_ in param1.animationTracks)
         {
            _loc28_ = new TransformTrack(_loc25_.objectName);
            for each(_loc29_ in _loc25_.keyframes)
            {
               _loc30_ = new TransformKey();
               _loc30_.alternativa3d::_time = _loc29_.time;
               _loc31_ = this.getMatrix3D(_loc29_.transform).decompose(Orientation3D.QUATERNION);
               _loc30_.alternativa3d::x = _loc31_[0].x;
               _loc30_.alternativa3d::y = _loc31_[0].y;
               _loc30_.alternativa3d::z = _loc31_[0].z;
               _loc30_.alternativa3d::rotation = _loc31_[1];
               _loc30_.alternativa3d::scaleX = _loc31_[2].x;
               _loc30_.alternativa3d::scaleY = _loc31_[2].y;
               _loc30_.alternativa3d::scaleZ = _loc31_[2].z;
               _loc28_.alternativa3d::addKeyToList(_loc30_);
            }
            _loc2_[_loc25_.id] = _loc28_;
         }
         if(param1.animationTracks != null && param1.animationTracks.length > 0)
         {
            if(param1.animationClips == null || param1.animationClips.length == 0)
            {
               _loc26_ = new AnimationClip();
               for each(_loc28_ in _loc2_)
               {
                  _loc26_.addTrack(_loc28_);
               }
               this.animations.push(_loc26_);
            }
            else
            {
               for each(_loc32_ in param1.animationClips)
               {
                  _loc26_ = new AnimationClip(_loc32_.name);
                  _loc26_.loop = _loc32_.loop;
                  for each(_loc33_ in _loc32_.tracks)
                  {
                     _loc34_ = _loc2_[_loc33_];
                     if(_loc34_ != null)
                     {
                        _loc26_.addTrack(_loc34_);
                     }
                  }
                  this.animations.push(_loc26_);
               }
            }
         }
         for each(_loc12_ in param1.vertexBuffers)
         {
            _loc4_[_loc12_.id] = _loc12_;
         }
         for each(_loc14_ in param1.boxes)
         {
            this.a3DBoxes[_loc14_.id] = _loc14_;
         }
         for each(_loc13_ in param1.materials)
         {
            _loc5_[_loc13_.id] = _loc13_;
         }
         for each(_loc15_ in param1.maps)
         {
            _loc6_[_loc15_.id] = _loc15_;
         }
         for each(_loc24_ in param1.cubeMaps)
         {
            _loc8_[_loc24_.id] = _loc24_;
         }
         for each(_loc16_ in param1.images)
         {
            _loc7_[_loc16_.id] = _loc16_;
         }
         _loc27_ = new Dictionary();
         for each(_loc22_ in param1.joints)
         {
            _loc35_ = new Joint();
            _loc35_.visible = _loc22_.visible;
            _loc35_.name = _loc22_.name;
            this.parents[_loc35_] = _loc22_.parentId;
            _loc27_[_loc22_.id] = _loc35_;
            this.decomposeTransformation(_loc22_.transform,_loc35_);
            _loc14_ = this.a3DBoxes[_loc22_.boundBoxId];
            if(_loc14_ != null)
            {
               this.parseBoundBox(_loc14_.box,_loc35_);
            }
         }
         for each(_loc9_ in param1.objects)
         {
            _loc36_ = new Object3D();
            _loc36_.visible = _loc9_.visible;
            _loc36_.name = _loc9_.name;
            this.parents[_loc36_] = _loc9_.parentId;
            this.objectsMap[_loc9_.id] = _loc36_;
            _loc27_[_loc9_.id] = _loc36_;
            this.decomposeTransformation(_loc9_.transform,_loc36_);
            _loc14_ = this.a3DBoxes[_loc9_.boundBoxId];
            if(_loc14_ != null)
            {
               this.parseBoundBox(_loc14_.box,_loc36_);
            }
         }
         for each(_loc23_ in param1.sprites)
         {
            _loc37_ = new Sprite3D(_loc23_.width,_loc23_.height);
            _loc37_.material = this.parseMaterial(_loc5_[_loc23_.materialId],_loc6_,_loc8_,_loc7_);
            _loc37_.originX = _loc23_.originX;
            _loc37_.originY = _loc23_.originY;
            _loc37_.perspectiveScale = _loc23_.perspectiveScale;
            _loc37_.alwaysOnTop = _loc23_.alwaysOnTop;
            _loc37_.rotation = _loc23_.rotation;
            this.objectsMap[_loc23_.id] = _loc37_;
            this.decomposeTransformation(_loc23_.transform,_loc37_);
         }
         for each(_loc21_ in param1.skins)
         {
            _loc38_ = this.parseSkin(_loc21_,_loc27_,this.parents,_loc3_,_loc4_,_loc5_,_loc6_,_loc8_,_loc7_);
            _loc38_.visible = _loc21_.visible;
            _loc38_.name = _loc21_.name;
            this.objectsMap[_loc21_.id] = _loc38_;
            _loc14_ = this.a3DBoxes[_loc21_.boundBoxId];
            if(_loc14_ != null)
            {
               this.parseBoundBox(_loc14_.box,_loc38_);
            }
         }
         for each(_loc17_ in param1.ambientLights)
         {
            _loc39_ = new AmbientLight(_loc17_.color);
            _loc39_.intensity = _loc17_.intensity;
            _loc39_.visible = _loc17_.visible;
            _loc39_.name = _loc17_.name;
            this.parents[_loc39_] = _loc17_.parentId;
            this.objectsMap[_loc17_.id] = _loc39_;
            this.decomposeTransformation(_loc17_.transform,_loc39_);
            _loc14_ = this.a3DBoxes[_loc17_.boundBoxId];
            if(_loc14_ != null)
            {
               this.parseBoundBox(_loc14_.box,_loc39_);
            }
         }
         for each(_loc18_ in param1.omniLights)
         {
            _loc40_ = new OmniLight(_loc18_.color,_loc18_.attenuationBegin,_loc18_.attenuationEnd);
            _loc40_.intensity = _loc18_.intensity;
            _loc40_.visible = _loc18_.visible;
            _loc40_.name = _loc18_.name;
            this.parents[_loc40_] = _loc18_.parentId;
            this.objectsMap[_loc18_.id] = _loc40_;
            this.decomposeTransformation(_loc18_.transform,_loc40_);
         }
         for each(_loc19_ in param1.spotLights)
         {
            _loc41_ = new SpotLight(_loc19_.color,_loc19_.attenuationBegin,_loc19_.attenuationEnd,_loc19_.hotspot,_loc19_.falloff);
            _loc41_.intensity = _loc19_.intensity;
            _loc41_.visible = _loc19_.visible;
            _loc41_.name = _loc19_.name;
            this.parents[_loc41_] = _loc19_.parentId;
            this.objectsMap[_loc19_.id] = _loc41_;
            this.decomposeTransformation(_loc19_.transform,_loc41_);
         }
         for each(_loc20_ in param1.directionalLights)
         {
            _loc42_ = new DirectionalLight(_loc20_.color);
            _loc42_.visible = _loc20_.visible;
            _loc42_.name = _loc20_.name;
            this.parents[_loc42_] = _loc20_.parentId;
            this.objectsMap[_loc20_.id] = _loc42_;
            this.decomposeTransformation(_loc20_.transform,_loc42_);
         }
         for each(_loc10_ in param1.meshes)
         {
            _loc43_ = this.parseMesh(_loc10_,_loc3_,_loc4_,_loc5_,_loc6_,_loc8_,_loc7_);
            _loc43_.visible = _loc10_.visible;
            _loc43_.name = _loc10_.name;
            this.parents[_loc43_] = _loc10_.parentId;
            this.objectsMap[_loc10_.id] = _loc43_;
            this.decomposeTransformation(_loc10_.transform,_loc43_);
            _loc14_ = this.a3DBoxes[_loc10_.boundBoxId];
            if(_loc14_ != null)
            {
               this.parseBoundBox(_loc14_.box,_loc43_);
            }
         }
         this.maps = null;
         this.parsedMaterials = null;
         this.parsedGeometries = null;
      }
      
      private function completeHierarchy() : void
      {
         var _loc1_:Long = null;
         var _loc2_:Object3D = null;
         var _loc3_:Object3D = null;
         for each(_loc3_ in this.objectsMap)
         {
            this.objects.push(_loc3_);
            if(_loc3_.parent == null)
            {
               _loc1_ = this.parents[_loc3_];
               if(_loc1_ != null)
               {
                  _loc2_ = this.objectsMap[_loc1_];
                  if(_loc2_ != null)
                  {
                     _loc2_.addChild(_loc3_);
                  }
                  else
                  {
                     this.hierarchy.push(_loc3_);
                  }
               }
               else
               {
                  this.hierarchy.push(_loc3_);
               }
            }
         }
      }
      
      private function parseBoundBox(param1:Vector.<Number>, param2:Object3D) : void
      {
         param2.boundBox = new BoundBox();
         param2.boundBox.minX = param1[0];
         param2.boundBox.minY = param1[1];
         param2.boundBox.minZ = param1[2];
         param2.boundBox.maxX = param1[3];
         param2.boundBox.maxY = param1[4];
         param2.boundBox.maxZ = param1[5];
      }
      
      final private function unpackVertexBuffer(param1:ByteArray) : void
      {
         var _loc3_:uint = 0;
         var _loc4_:uint = 0;
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.endian = Endian.LITTLE_ENDIAN;
         param1.position = 0;
         while(param1.bytesAvailable > 0)
         {
            _loc3_ = param1.readUnsignedShort();
            _loc4_ = _loc3_;
            _loc4_ = uint(_loc4_ & 0x7FFF);
            _loc4_ ^= _loc4_ + 114688 ^ _loc4_;
            _loc4_ = uint(_loc4_ << 13);
            _loc2_.writeUnsignedInt(_loc3_ > 32768 ? uint(_loc4_ | 0x80000000) : _loc4_);
         }
         param1.position = 0;
         param1.writeBytes(_loc2_);
      }
      
      private function getMatrix3D(param1:A3D2Transform) : Matrix3D
      {
         if(param1 == null)
         {
            return null;
         }
         var _loc2_:A3DMatrix = param1.matrix;
         return new Matrix3D(Vector.<Number>([_loc2_.a,_loc2_.e,_loc2_.i,0,_loc2_.b,_loc2_.f,_loc2_.j,0,_loc2_.c,_loc2_.g,_loc2_.k,0,_loc2_.d,_loc2_.h,_loc2_.l,1]));
      }
      
      private function decomposeTransformation(param1:A3D2Transform, param2:Object3D) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc3_:Matrix3D = this.getMatrix3D(param1);
         var _loc4_:Vector.<Vector3D> = _loc3_.decompose();
         param2.x = _loc4_[0].x;
         param2.y = _loc4_[0].y;
         param2.z = _loc4_[0].z;
         param2.rotationX = _loc4_[1].x;
         param2.rotationY = _loc4_[1].y;
         param2.rotationZ = _loc4_[1].z;
         param2.scaleX = _loc4_[2].x;
         param2.scaleY = _loc4_[2].y;
         param2.scaleZ = _loc4_[2].z;
      }
      
      private function decomposeBindTransformation(param1:A3D2Transform, param2:Joint) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc3_:A3DMatrix = param1.matrix;
         var _loc4_:Vector.<Number> = Vector.<Number>([_loc3_.a,_loc3_.b,_loc3_.c,_loc3_.d,_loc3_.e,_loc3_.f,_loc3_.g,_loc3_.h,_loc3_.i,_loc3_.j,_loc3_.k,_loc3_.l]);
         param2.alternativa3d::setBindPoseMatrix(_loc4_);
      }
      
      private function parseMesh(param1:A3D2Mesh, param2:Dictionary, param3:Dictionary, param4:Dictionary, param5:Dictionary, param6:Dictionary, param7:Dictionary) : Mesh
      {
         var _loc11_:A3D2Surface = null;
         var _loc12_:ParserMaterial = null;
         var _loc8_:Mesh = new Mesh();
         _loc8_.geometry = this.parseGeometry(param1.indexBufferId,param1.vertexBuffers,param2,param3);
         var _loc9_:Vector.<A3D2Surface> = param1.surfaces;
         var _loc10_:int = 0;
         while(_loc10_ < _loc9_.length)
         {
            _loc11_ = _loc9_[_loc10_];
            _loc12_ = this.parseMaterial(param4[_loc11_.materialId],param5,param6,param7);
            _loc8_.addSurface(_loc12_,_loc11_.indexBegin,_loc11_.numTriangles);
            _loc10_++;
         }
         return _loc8_;
      }
      
      private function parseSkin(param1:A3D2Skin, param2:Dictionary, param3:Dictionary, param4:Dictionary, param5:Dictionary, param6:Dictionary, param7:Dictionary, param8:Dictionary, param9:Dictionary) : Skin
      {
         var _loc14_:A3D2Surface = null;
         var _loc15_:ParserMaterial = null;
         var _loc10_:Geometry = this.parseGeometry(param1.indexBufferId,param1.vertexBuffers,param4,param5);
         var _loc11_:Skin = new Skin(this.getNumInfluences(_loc10_));
         _loc11_.geometry = _loc10_;
         var _loc12_:Vector.<A3D2Surface> = param1.surfaces;
         var _loc13_:int = 0;
         while(_loc13_ < _loc12_.length)
         {
            _loc14_ = _loc12_[_loc13_];
            _loc15_ = this.parseMaterial(param6[_loc14_.materialId],param7,param8,param9);
            _loc11_.addSurface(_loc15_,_loc14_.indexBegin,_loc14_.numTriangles);
            _loc13_++;
         }
         this.copyBones(_loc11_,param1,param2,param3);
         return _loc11_;
      }
      
      private function copyBones(param1:Skin, param2:A3D2Skin, param3:Dictionary, param4:Dictionary) : void
      {
         var _loc9_:Joint = null;
         var _loc10_:Object3D = null;
         var _loc12_:Joint = null;
         var _loc13_:uint = 0;
         var _loc14_:* = undefined;
         var _loc15_:int = 0;
         var _loc17_:int = 0;
         var _loc18_:Long = null;
         var _loc19_:int = 0;
         var _loc20_:A3D2JointBindTransform = null;
         var _loc21_:Long = null;
         var _loc22_:Object3D = null;
         var _loc23_:Joint = null;
         var _loc5_:Vector.<Joint> = new Vector.<Joint>();
         var _loc6_:Dictionary = new Dictionary();
         var _loc7_:Dictionary = new Dictionary();
         var _loc8_:Dictionary = new Dictionary();
         var _loc11_:uint = 0;
         for each(_loc13_ in param2.numJoints)
         {
            _loc17_ = 0;
            while(_loc17_ < _loc13_)
            {
               _loc18_ = param2.joints[int(_loc11_ + _loc17_)];
               _loc10_ = param3[_loc18_];
               _loc7_[_loc18_] = _loc10_;
               _loc8_[_loc10_] = _loc18_;
               _loc17_++;
            }
            _loc11_ += _loc13_;
         }
         for(_loc14_ in _loc7_)
         {
            _loc10_ = _loc7_[_loc14_];
            if(_loc10_ == null)
            {
               throw new Error("Joint for skin " + param2.name + " not found");
            }
            delete this.objectsMap[_loc14_];
            _loc6_[_loc10_] = this.cloneJoint(_loc10_);
         }
         _loc11_ = 0;
         _loc17_ = 0;
         _loc15_ = int(param2.numJoints.length);
         while(_loc17_ < _loc15_)
         {
            _loc13_ = param2.numJoints[_loc17_];
            param1.alternativa3d::surfaceJoints[_loc17_] = new Vector.<Joint>();
            _loc19_ = 0;
            while(_loc19_ < _loc13_)
            {
               param1.alternativa3d::surfaceJoints[_loc17_].push(_loc6_[_loc7_[param2.joints[int(_loc11_ + _loc19_)]]]);
               _loc19_++;
            }
            _loc11_ += _loc13_;
            _loc17_++;
         }
         param1.alternativa3d::calculateSurfacesProcedures();
         _loc17_ = 0;
         while(_loc17_ < param2.jointBindTransforms.length)
         {
            _loc20_ = param2.jointBindTransforms[_loc17_];
            if(_loc7_[_loc20_.id] == null)
            {
               _loc10_ = param3[_loc20_.id];
               _loc7_[_loc20_.id] = _loc10_;
               _loc6_[_loc10_] = this.cloneJoint(_loc10_);
            }
            this.decomposeBindTransformation(_loc20_.bindPoseTransform,Joint(_loc6_[_loc7_[_loc20_.id]]));
            _loc17_++;
         }
         var _loc16_:Long = null;
         for each(_loc10_ in _loc7_)
         {
            _loc12_ = _loc6_[_loc10_];
            _loc21_ = param4[_loc10_];
            if(this.isRootJointNode(_loc10_,param4,_loc7_,param3))
            {
               _loc16_ = _loc21_;
               _loc5_.push(_loc12_);
            }
            else
            {
               _loc22_ = param3[_loc21_];
               _loc23_ = _loc6_[_loc22_];
               if(_loc23_ == null)
               {
                  this.attachJoint(_loc12_,_loc10_,param4,param3,_loc6_);
               }
               else
               {
                  _loc23_.addChild(_loc12_);
               }
            }
         }
         if(_loc16_ != null)
         {
            param4[param1] = _loc16_;
         }
         param1.alternativa3d::_renderedJoints = new Vector.<Joint>();
         _loc17_ = 0;
         while(_loc17_ < _loc13_)
         {
            param1.alternativa3d::_renderedJoints.push(_loc6_[_loc7_[param2.joints[_loc17_]]]);
            _loc17_++;
         }
         for each(_loc9_ in _loc5_)
         {
            param1.addChild(_loc9_);
         }
      }
      
      private function attachJoint(param1:Joint, param2:Object3D, param3:Dictionary, param4:Dictionary, param5:Dictionary) : void
      {
         var _loc6_:Long = param3[param2];
         var _loc7_:Object3D = param4[_loc6_];
         var _loc8_:Joint = param5[_loc7_];
         if(_loc8_ == null)
         {
            param5[_loc7_] = _loc8_ = this.cloneJoint(_loc7_);
            delete this.objectsMap[_loc6_];
            this.attachJoint(_loc8_,_loc7_,param3,param4,param5);
         }
         _loc8_.addChild(param1);
      }
      
      private function isRootJointNode(param1:Object3D, param2:Dictionary, param3:Dictionary, param4:Dictionary) : Boolean
      {
         var _loc6_:Object3D = null;
         var _loc5_:Long = param2[param1];
         while(_loc5_ != null)
         {
            _loc6_ = param4[_loc5_];
            if(param3[_loc5_] != null)
            {
               return false;
            }
            _loc5_ = param2[_loc6_];
         }
         return true;
      }
      
      private function cloneJoint(param1:Object3D) : Joint
      {
         var _loc2_:Joint = new Joint();
         _loc2_.name = param1.name;
         _loc2_.visible = param1.visible;
         _loc2_.boundBox = param1.boundBox ? param1.boundBox.clone() : null;
         _loc2_.alternativa3d::_x = param1.alternativa3d::_x;
         _loc2_.alternativa3d::_y = param1.alternativa3d::_y;
         _loc2_.alternativa3d::_z = param1.alternativa3d::_z;
         _loc2_.alternativa3d::_rotationX = param1.alternativa3d::_rotationX;
         _loc2_.alternativa3d::_rotationY = param1.alternativa3d::_rotationY;
         _loc2_.alternativa3d::_rotationZ = param1.alternativa3d::_rotationZ;
         _loc2_.alternativa3d::_scaleX = param1.alternativa3d::_scaleX;
         _loc2_.alternativa3d::_scaleY = param1.alternativa3d::_scaleY;
         _loc2_.alternativa3d::_scaleZ = param1.alternativa3d::_scaleZ;
         _loc2_.alternativa3d::composeTransforms();
         return _loc2_;
      }
      
      private function getNumInfluences(param1:Geometry) : uint
      {
         var _loc2_:uint = 0;
         var _loc3_:int = 0;
         var _loc4_:int = int(VertexAttributes.JOINTS.length);
         while(_loc3_ < _loc4_)
         {
            if(param1.hasAttribute(VertexAttributes.JOINTS[_loc3_]))
            {
               _loc2_ += 2;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      private function parseGeometry(param1:int, param2:Vector.<int>, param3:Dictionary, param4:Dictionary) : Geometry
      {
         var _loc6_:int = 0;
         var _loc7_:Geometry = null;
         var _loc12_:uint = 0;
         var _loc14_:A3D2VertexBuffer = null;
         var _loc15_:ByteArray = null;
         var _loc16_:int = 0;
         var _loc17_:Array = null;
         var _loc18_:int = 0;
         var _loc19_:int = 0;
         var _loc20_:int = 0;
         var _loc21_:int = 0;
         var _loc22_:int = 0;
         var _loc5_:String = "i" + param1.toString();
         for each(_loc6_ in param2)
         {
            _loc5_ += "v" + _loc6_.toString();
         }
         _loc7_ = this.parsedGeometries[_loc5_];
         if(_loc7_ != null)
         {
            return _loc7_;
         }
         _loc7_ = new Geometry();
         var _loc8_:A3D2IndexBuffer = param3[param1];
         var _loc9_:Vector.<uint> = A3DUtils.byteArrayToVectorUint(_loc8_.byteBuffer);
         var _loc10_:int = 0;
         _loc7_.alternativa3d::_indices = _loc9_;
         var _loc11_:Vector.<int> = param2;
         var _loc13_:int = 0;
         while(_loc13_ < _loc11_.length)
         {
            _loc14_ = param4[_loc11_[_loc13_]];
            if(this.alternativa3d::compressedBuffers)
            {
               if(this.unpackedBuffers[_loc14_] == null)
               {
                  this.unpackVertexBuffer(_loc14_.byteBuffer);
                  this.unpackedBuffers[_loc14_] = true;
               }
            }
            _loc12_ = _loc14_.vertexCount;
            _loc15_ = _loc14_.byteBuffer;
            _loc15_.endian = Endian.LITTLE_ENDIAN;
            _loc16_ = 0;
            _loc17_ = [];
            _loc18_ = 0;
            _loc19_ = 0;
            while(_loc19_ < _loc14_.attributes.length)
            {
               switch(_loc14_.attributes[_loc19_])
               {
                  case A3D2VertexAttributes.POSITION:
                     _loc20_ = int(VertexAttributes.POSITION);
                     break;
                  case A3D2VertexAttributes.NORMAL:
                     _loc20_ = int(VertexAttributes.NORMAL);
                     break;
                  case A3D2VertexAttributes.TANGENT4:
                     _loc20_ = int(VertexAttributes.TANGENT4);
                     break;
                  case A3D2VertexAttributes.TEXCOORD:
                     _loc20_ = int(VertexAttributes.TEXCOORDS[_loc10_]);
                     _loc10_++;
                     break;
                  case A3D2VertexAttributes.JOINT:
                     _loc20_ = int(VertexAttributes.JOINTS[_loc18_]);
                     _loc18_++;
               }
               _loc21_ = VertexAttributes.getAttributeStride(_loc20_);
               _loc21_ = _loc21_ < 1 ? 1 : _loc21_;
               _loc22_ = 0;
               while(_loc22_ < _loc21_)
               {
                  _loc17_[_loc16_] = _loc20_;
                  _loc16_++;
                  _loc22_++;
               }
               _loc19_++;
            }
            _loc7_.addVertexStream(_loc17_);
            _loc7_.alternativa3d::_vertexStreams[0].data = _loc15_;
            _loc13_++;
         }
         _loc7_.alternativa3d::_numVertices = _loc11_.length > 0 ? int(_loc12_) : 0;
         this.parsedGeometries[_loc5_] = _loc7_;
         return _loc7_;
      }
      
      private function parseMap(param1:A3D2Map, param2:Dictionary) : ExternalTextureResource
      {
         if(param1 == null)
         {
            return null;
         }
         var _loc3_:ExternalTextureResource = this.maps[param1.imageId];
         if(_loc3_ != null)
         {
            return _loc3_;
         }
         return this.maps[param1.imageId] = new ExternalTextureResource(param2[param1.imageId].url);
      }
      
      private function parseCubeMap(param1:A3D2CubeMap, param2:Dictionary) : ExternalTextureResource
      {
         return null;
      }
      
      private function parseMaterial(param1:A3D2Material, param2:Dictionary, param3:Dictionary, param4:Dictionary) : ParserMaterial
      {
         if(param1 == null)
         {
            return null;
         }
         var _loc5_:ParserMaterial = this.parsedMaterials[param1.id];
         if(_loc5_ != null)
         {
            return _loc5_;
         }
         _loc5_ = this.parsedMaterials[param1.id] = new ParserMaterial();
         _loc5_.textures["diffuse"] = this.parseMap(param2[param1.diffuseMapId],param4);
         _loc5_.textures["emission"] = this.parseMap(param2[param1.lightMapId],param4);
         _loc5_.textures["bump"] = this.parseMap(param2[param1.normalMapId],param4);
         _loc5_.textures["specular"] = this.parseMap(param2[param1.specularMapId],param4);
         _loc5_.textures["glossiness"] = this.parseMap(param2[param1.glossinessMapId],param4);
         _loc5_.textures["transparent"] = this.parseMap(param2[param1.opacityMapId],param4);
         _loc5_.textures["reflection"] = this.parseCubeMap(param3[param1.reflectionCubeMapId],param4);
         this.materials.push(_loc5_);
         return _loc5_;
      }
   }
}

