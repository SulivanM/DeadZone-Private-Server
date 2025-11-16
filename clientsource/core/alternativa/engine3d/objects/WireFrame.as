package alternativa.engine3d.objects
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.BoundBox;
   import alternativa.engine3d.core.Camera3D;
   import alternativa.engine3d.core.Light3D;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Transform3D;
   import alternativa.engine3d.core.VertexAttributes;
   import alternativa.engine3d.materials.A3DUtils;
   import alternativa.engine3d.materials.ShaderProgram;
   import alternativa.engine3d.materials.compiler.Linker;
   import alternativa.engine3d.materials.compiler.Procedure;
   import alternativa.engine3d.materials.compiler.VariableType;
   import alternativa.engine3d.resources.Geometry;
   import alternativa.engine3d.resources.WireGeometry;
   import flash.display3D.Context3D;
   import flash.display3D.Context3DProgramType;
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   use namespace alternativa3d;
   
   public class WireFrame extends Object3D
   {
      
      private static const cachedPrograms:Dictionary = new Dictionary(true);
      
      alternativa3d var shaderProgram:ShaderProgram;
      
      private var cachedContext3D:Context3D;
      
      public var thickness:Number = 1;
      
      alternativa3d var _colorVec:Vector.<Number> = new Vector.<Number>(4,true);
      
      alternativa3d var geometry:WireGeometry;
      
      public function WireFrame(param1:uint = 0, param2:Number = 1, param3:Number = 0.5)
      {
         super();
         this.color = param1;
         this.alpha = param2;
         this.thickness = param3;
         this.alternativa3d::geometry = new WireGeometry();
      }
      
      private static function initProgram() : ShaderProgram
      {
         var _loc1_:Linker = new Linker(Context3DProgramType.VERTEX);
         var _loc2_:Procedure = new Procedure();
         _loc2_.compileFromArray(["mov t0, a0","mov t0.w, c0.y","m34 t0.xyz, t0, c2","m34 t1.xyz, a1, c2","sub t2, t1.xyz, t0.xyz","slt t5.x, t0.z, c1.z","sub t5.y, c0.y, t5.x","add t4.x, t0.z, c0.z","sub t4.y, t0.z, t1.z","add t4.y, t4.y, c0.w","div t4.z, t4.x, t4.y","mul t4.xyz, t4.zzz, t2.xyz","add t3.xyz, t0.xyz, t4.xyz","mul t0, t0, t5.y","mul t3.xyz, t3.xyz, t5.x","add t0, t0, t3.xyz","sub t2, t1.xyz, t0.xyz","crs t3.xyz, t2, t0","nrm t3.xyz, t3.xyz","mul t3.xyz, t3.xyz, a0.w","mul t3.xyz, t3.xyz, c1.w","mul t4.x, t0.z, c1.x","mul t3.xyz, t3.xyz, t4.xxx","add t0.xyz, t0.xyz, t3.xyz","m44 o0, t0, c5"]);
         _loc2_.assignVariableName(VariableType.ATTRIBUTE,0,"pos1");
         _loc2_.assignVariableName(VariableType.ATTRIBUTE,1,"pos2");
         _loc2_.assignVariableName(VariableType.CONSTANT,0,"ZERO");
         _loc2_.assignVariableName(VariableType.CONSTANT,1,"consts");
         _loc2_.assignVariableName(VariableType.CONSTANT,2,"worldView",3);
         _loc2_.assignVariableName(VariableType.CONSTANT,5,"proj",4);
         _loc1_.addProcedure(_loc2_);
         _loc1_.link();
         var _loc3_:Linker = new Linker(Context3DProgramType.FRAGMENT);
         var _loc4_:Procedure = new Procedure();
         _loc4_.compileFromArray(["mov o0, c0"]);
         _loc4_.assignVariableName(VariableType.CONSTANT,0,"color");
         _loc3_.addProcedure(_loc4_);
         _loc3_.link();
         return new ShaderProgram(_loc1_,_loc3_);
      }
      
      public static function createLinesList(param1:Vector.<Vector3D>, param2:uint = 0, param3:Number = 1, param4:Number = 1) : WireFrame
      {
         var _loc6_:Vector3D = null;
         var _loc7_:Vector3D = null;
         var _loc5_:WireFrame = new WireFrame(param2,param3,param4);
         var _loc8_:WireGeometry = _loc5_.alternativa3d::geometry;
         var _loc9_:uint = 0;
         var _loc10_:uint = param1.length - 1;
         while(_loc9_ < _loc10_)
         {
            _loc6_ = param1[_loc9_];
            _loc7_ = param1[_loc9_ + 1];
            _loc8_.alternativa3d::addLine(_loc6_.x,_loc6_.y,_loc6_.z,_loc7_.x,_loc7_.y,_loc7_.z);
            _loc9_ += 2;
         }
         _loc5_.calculateBoundBox();
         return _loc5_;
      }
      
      public static function createLineStrip(param1:Vector.<Vector3D>, param2:uint = 0, param3:Number = 1, param4:Number = 1) : WireFrame
      {
         var _loc6_:Vector3D = null;
         var _loc7_:Vector3D = null;
         var _loc5_:WireFrame = new WireFrame(param2,param3,param4);
         var _loc8_:WireGeometry = _loc5_.alternativa3d::geometry;
         var _loc9_:uint = 0;
         var _loc10_:uint = param1.length - 1;
         while(_loc9_ < _loc10_)
         {
            _loc6_ = param1[_loc9_];
            _loc7_ = param1[_loc9_ + 1];
            _loc8_.alternativa3d::addLine(_loc6_.x,_loc6_.y,_loc6_.z,_loc7_.x,_loc7_.y,_loc7_.z);
            _loc9_++;
         }
         _loc5_.calculateBoundBox();
         return _loc5_;
      }
      
      public static function createEdges(param1:Mesh, param2:uint = 0, param3:Number = 1, param4:Number = 1) : WireFrame
      {
         var _loc13_:uint = 0;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc5_:WireFrame = new WireFrame(param2,param3,param4);
         var _loc6_:Geometry = param1.geometry;
         var _loc7_:WireGeometry = _loc5_.alternativa3d::geometry;
         var _loc8_:Dictionary = new Dictionary();
         var _loc9_:Vector.<uint> = _loc6_.indices;
         var _loc10_:Vector.<Number> = _loc6_.getAttributeValues(VertexAttributes.POSITION);
         var _loc11_:int = 0;
         var _loc12_:int = int(_loc9_.length);
         while(_loc11_ < _loc12_)
         {
            _loc13_ = _loc9_[_loc11_] * 3;
            _loc14_ = _loc10_[_loc13_];
            _loc13_++;
            _loc15_ = _loc10_[_loc13_];
            _loc13_++;
            _loc16_ = _loc10_[_loc13_];
            _loc13_ = _loc9_[int(_loc11_ + 1)] * 3;
            _loc17_ = _loc10_[_loc13_];
            _loc13_++;
            _loc18_ = _loc10_[_loc13_];
            _loc13_++;
            _loc19_ = _loc10_[_loc13_];
            _loc13_ = _loc9_[int(_loc11_ + 2)] * 3;
            _loc20_ = _loc10_[_loc13_];
            _loc13_++;
            _loc21_ = _loc10_[_loc13_];
            _loc13_++;
            _loc22_ = _loc10_[_loc13_];
            if(checkEdge(_loc8_,_loc14_,_loc15_,_loc16_,_loc17_,_loc18_,_loc19_))
            {
               _loc7_.alternativa3d::addLine(_loc14_,_loc15_,_loc16_,_loc17_,_loc18_,_loc19_);
            }
            if(checkEdge(_loc8_,_loc17_,_loc18_,_loc19_,_loc20_,_loc21_,_loc22_))
            {
               _loc7_.alternativa3d::addLine(_loc17_,_loc18_,_loc19_,_loc20_,_loc21_,_loc22_);
            }
            if(checkEdge(_loc8_,_loc14_,_loc15_,_loc16_,_loc20_,_loc21_,_loc22_))
            {
               _loc7_.alternativa3d::addLine(_loc14_,_loc15_,_loc16_,_loc20_,_loc21_,_loc22_);
            }
            _loc11_ += 3;
         }
         _loc5_.calculateBoundBox();
         _loc5_.alternativa3d::_x = param1.alternativa3d::_x;
         _loc5_.alternativa3d::_y = param1.alternativa3d::_y;
         _loc5_.alternativa3d::_z = param1.alternativa3d::_z;
         _loc5_.alternativa3d::_rotationX = param1.alternativa3d::_rotationX;
         _loc5_.alternativa3d::_rotationY = param1.alternativa3d::_rotationY;
         _loc5_.alternativa3d::_rotationZ = param1.alternativa3d::_rotationZ;
         _loc5_.alternativa3d::_scaleX = param1.alternativa3d::_scaleX;
         _loc5_.alternativa3d::_scaleY = param1.alternativa3d::_scaleY;
         _loc5_.alternativa3d::_scaleZ = param1.alternativa3d::_scaleZ;
         return _loc5_;
      }
      
      alternativa3d static function createNormals(param1:Mesh, param2:uint = 0, param3:Number = 1, param4:Number = 1, param5:Number = 1) : WireFrame
      {
         var _loc13_:uint = 0;
         var _loc6_:WireFrame = new WireFrame(param2,param3,param4);
         var _loc7_:Geometry = param1.geometry;
         var _loc8_:WireGeometry = _loc6_.alternativa3d::geometry;
         var _loc9_:Vector.<Number> = _loc7_.getAttributeValues(VertexAttributes.POSITION);
         var _loc10_:Vector.<Number> = _loc7_.getAttributeValues(VertexAttributes.NORMAL);
         var _loc11_:uint = uint(_loc7_.alternativa3d::_numVertices);
         var _loc12_:int = 0;
         while(_loc12_ < _loc11_)
         {
            _loc13_ = uint(_loc12_ * 3);
            _loc8_.alternativa3d::addLine(_loc9_[_loc13_],_loc9_[int(_loc13_ + 1)],_loc9_[int(_loc13_ + 2)],_loc9_[_loc13_] + _loc10_[_loc13_] * param5,_loc9_[int(_loc13_ + 1)] + _loc10_[int(_loc13_ + 1)] * param5,_loc9_[int(_loc13_ + 2)] + _loc10_[int(_loc13_ + 2)] * param5);
            _loc12_++;
         }
         _loc6_.calculateBoundBox();
         _loc6_.alternativa3d::_x = param1.alternativa3d::_x;
         _loc6_.alternativa3d::_y = param1.alternativa3d::_y;
         _loc6_.alternativa3d::_z = param1.alternativa3d::_z;
         _loc6_.alternativa3d::_rotationX = param1.alternativa3d::_rotationX;
         _loc6_.alternativa3d::_rotationY = param1.alternativa3d::_rotationY;
         _loc6_.alternativa3d::_rotationZ = param1.alternativa3d::_rotationZ;
         _loc6_.alternativa3d::_scaleX = param1.alternativa3d::_scaleX;
         _loc6_.alternativa3d::_scaleY = param1.alternativa3d::_scaleY;
         _loc6_.alternativa3d::_scaleZ = param1.alternativa3d::_scaleZ;
         return _loc6_;
      }
      
      alternativa3d static function createTangents(param1:Mesh, param2:uint = 0, param3:Number = 1, param4:Number = 1, param5:Number = 1) : WireFrame
      {
         var _loc13_:uint = 0;
         var _loc6_:WireFrame = new WireFrame(param2,param3,param4);
         var _loc7_:Geometry = param1.geometry;
         var _loc8_:WireGeometry = _loc6_.alternativa3d::geometry;
         var _loc9_:Vector.<Number> = _loc7_.getAttributeValues(VertexAttributes.POSITION);
         var _loc10_:Vector.<Number> = _loc7_.getAttributeValues(VertexAttributes.TANGENT4);
         var _loc11_:uint = uint(_loc7_.alternativa3d::_numVertices);
         var _loc12_:int = 0;
         while(_loc12_ < _loc11_)
         {
            _loc13_ = uint(_loc12_ * 3);
            _loc8_.alternativa3d::addLine(_loc9_[_loc13_],_loc9_[int(_loc13_ + 1)],_loc9_[int(_loc13_ + 2)],_loc9_[_loc13_] + _loc10_[int(_loc12_ * 4)] * param5,_loc9_[int(_loc13_ + 1)] + _loc10_[int(_loc12_ * 4 + 1)] * param5,_loc9_[int(_loc13_ + 2)] + _loc10_[int(_loc12_ * 4 + 2)] * param5);
            _loc12_++;
         }
         _loc6_.calculateBoundBox();
         _loc6_.alternativa3d::_x = param1.alternativa3d::_x;
         _loc6_.alternativa3d::_y = param1.alternativa3d::_y;
         _loc6_.alternativa3d::_z = param1.alternativa3d::_z;
         _loc6_.alternativa3d::_rotationX = param1.alternativa3d::_rotationX;
         _loc6_.alternativa3d::_rotationY = param1.alternativa3d::_rotationY;
         _loc6_.alternativa3d::_rotationZ = param1.alternativa3d::_rotationZ;
         _loc6_.alternativa3d::_scaleX = param1.alternativa3d::_scaleX;
         _loc6_.alternativa3d::_scaleY = param1.alternativa3d::_scaleY;
         _loc6_.alternativa3d::_scaleZ = param1.alternativa3d::_scaleZ;
         return _loc6_;
      }
      
      alternativa3d static function createBinormals(param1:Mesh, param2:uint = 0, param3:Number = 1, param4:Number = 1, param5:Number = 1) : WireFrame
      {
         var _loc14_:uint = 0;
         var _loc15_:Vector3D = null;
         var _loc16_:Vector3D = null;
         var _loc17_:Vector3D = null;
         var _loc6_:WireFrame = new WireFrame(param2,param3,param4);
         var _loc7_:Geometry = param1.geometry;
         var _loc8_:WireGeometry = _loc6_.alternativa3d::geometry;
         var _loc9_:Vector.<Number> = _loc7_.getAttributeValues(VertexAttributes.POSITION);
         var _loc10_:Vector.<Number> = _loc7_.getAttributeValues(VertexAttributes.TANGENT4);
         var _loc11_:Vector.<Number> = _loc7_.getAttributeValues(VertexAttributes.NORMAL);
         var _loc12_:uint = uint(_loc7_.alternativa3d::_numVertices);
         var _loc13_:int = 0;
         while(_loc13_ < _loc12_)
         {
            _loc14_ = uint(_loc13_ * 3);
            _loc15_ = new Vector3D(_loc11_[_loc14_],_loc11_[int(_loc14_ + 1)],_loc11_[int(_loc14_ + 2)]);
            _loc16_ = new Vector3D(_loc10_[int(_loc13_ * 4)],_loc10_[int(_loc13_ * 4 + 1)],_loc10_[int(_loc13_ * 4 + 2)]);
            _loc17_ = _loc15_.crossProduct(_loc16_);
            _loc17_.scaleBy(_loc10_[int(_loc13_ * 4 + 3)]);
            _loc17_.normalize();
            _loc8_.alternativa3d::addLine(_loc9_[_loc14_],_loc9_[int(_loc14_ + 1)],_loc9_[int(_loc14_ + 2)],_loc9_[_loc14_] + _loc17_.x * param5,_loc9_[int(_loc14_ + 1)] + _loc17_.y * param5,_loc9_[int(_loc14_ + 2)] + _loc17_.z * param5);
            _loc13_++;
         }
         _loc6_.calculateBoundBox();
         _loc6_.alternativa3d::_x = param1.alternativa3d::_x;
         _loc6_.alternativa3d::_y = param1.alternativa3d::_y;
         _loc6_.alternativa3d::_z = param1.alternativa3d::_z;
         _loc6_.alternativa3d::_rotationX = param1.alternativa3d::_rotationX;
         _loc6_.alternativa3d::_rotationY = param1.alternativa3d::_rotationY;
         _loc6_.alternativa3d::_rotationZ = param1.alternativa3d::_rotationZ;
         _loc6_.alternativa3d::_scaleX = param1.alternativa3d::_scaleX;
         _loc6_.alternativa3d::_scaleY = param1.alternativa3d::_scaleY;
         _loc6_.alternativa3d::_scaleZ = param1.alternativa3d::_scaleZ;
         return _loc6_;
      }
      
      private static function checkEdge(param1:Dictionary, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number, param7:Number) : Boolean
      {
         var _loc8_:String = null;
         if(param2 * param2 + param3 * param3 + param4 * param4 < param5 * param5 + param6 * param6 + param7 * param7)
         {
            _loc8_ = param2.toString() + param3.toString() + param4.toString() + param5.toString() + param6.toString() + param7.toString();
         }
         else
         {
            _loc8_ = param5.toString() + param6.toString() + param7.toString() + param2.toString() + param3.toString() + param4.toString();
         }
         if(param1[_loc8_])
         {
            return false;
         }
         param1[_loc8_] = true;
         return true;
      }
      
      public function get alpha() : Number
      {
         return this.alternativa3d::_colorVec[3];
      }
      
      public function set alpha(param1:Number) : void
      {
         this.alternativa3d::_colorVec[3] = param1;
      }
      
      public function get color() : uint
      {
         return this.alternativa3d::_colorVec[0] * 255 << 16 | this.alternativa3d::_colorVec[1] * 255 << 8 | this.alternativa3d::_colorVec[2] * 255;
      }
      
      public function set color(param1:uint) : void
      {
         this.alternativa3d::_colorVec[0] = (param1 >> 16 & 0xFF) / 255;
         this.alternativa3d::_colorVec[1] = (param1 >> 8 & 0xFF) / 255;
         this.alternativa3d::_colorVec[2] = (param1 & 0xFF) / 255;
      }
      
      override alternativa3d function updateBoundBox(param1:BoundBox, param2:Transform3D = null) : void
      {
         if(this.alternativa3d::geometry != null)
         {
            this.alternativa3d::geometry.alternativa3d::updateBoundBox(param1,param2);
         }
      }
      
      override alternativa3d function collectDraws(param1:Camera3D, param2:Vector.<Light3D>, param3:int, param4:Boolean) : void
      {
         if(param1.alternativa3d::context3D != this.cachedContext3D)
         {
            this.cachedContext3D = param1.alternativa3d::context3D;
            this.alternativa3d::shaderProgram = cachedPrograms[this.cachedContext3D];
            if(this.alternativa3d::shaderProgram == null)
            {
               this.alternativa3d::shaderProgram = initProgram();
               this.alternativa3d::shaderProgram.upload(this.cachedContext3D);
               cachedPrograms[this.cachedContext3D] = this.alternativa3d::shaderProgram;
            }
         }
         this.alternativa3d::geometry.alternativa3d::getDrawUnits(param1,this.alternativa3d::_colorVec,this.thickness,this,this.alternativa3d::shaderProgram);
      }
      
      override alternativa3d function fillResources(param1:Dictionary, param2:Boolean = false, param3:Class = null) : void
      {
         super.alternativa3d::fillResources(param1,param2,param3);
         if(A3DUtils.alternativa3d::checkParent(getDefinitionByName(getQualifiedClassName(this.alternativa3d::geometry)) as Class,param3))
         {
            param1[this.alternativa3d::geometry] = true;
         }
      }
   }
}

