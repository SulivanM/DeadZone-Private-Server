package alternativa.engine3d.objects
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.BoundBox;
   import alternativa.engine3d.core.Camera3D;
   import alternativa.engine3d.core.DrawUnit;
   import alternativa.engine3d.core.Light3D;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Renderer;
   import alternativa.engine3d.core.Transform3D;
   import alternativa.engine3d.core.VertexAttributes;
   import alternativa.engine3d.materials.Material;
   import alternativa.engine3d.materials.compiler.Linker;
   import alternativa.engine3d.materials.compiler.Procedure;
   import alternativa.engine3d.resources.Geometry;
   import flash.display3D.Context3D;
   import flash.utils.Dictionary;
   
   use namespace alternativa3d;
   
   public class Sprite3D extends Object3D
   {
      
      private static const geometries:Dictionary = new Dictionary();
      
      private static var transformProcedureStatic:Procedure = new Procedure(["sub t0.z, i0.x, c3.x","sub t0.w, i0.y, c3.y","mul t0.z, t0.z, c3.z","mul t0.w, t0.w, c3.w","mov t1.z, c4.w","sin t1.x, t1.z","cos t1.y, t1.z","mul t1.z, t0.z, t1.y","mul t1.w, t0.w, t1.x","sub t0.x, t1.z, t1.w","mul t1.z, t0.z, t1.x","mul t1.w, t0.w, t1.y","add t0.y, t1.z, t1.w","add t0.x, t0.x, c4.x","add t0.y, t0.y, c4.y","add t0.z, i0.z, c4.z","mov t0.w, i0.w","dp4 o0.x, t0, c0","dp4 o0.y, t0, c1","dp4 o0.z, t0, c2","mov o0.w, t0.w","#c0=trans1","#c1=trans2","#c2=trans3","#c3=size","#c4=coords"]);
      
      private static var deltaTransformProcedureStatic:Procedure = new Procedure(["mov t1.z, c4.w","sin t1.x, t1.z","cos t1.y, t1.z","mul t1.z, i0.x, t1.y","mul t1.w, i0.y, t1.x","sub t0.x, t1.z, t1.w","mul t1.z, i0.x, t1.x","mul t1.w, i0.y, t1.y","add t0.y, t1.z, t1.w","mov t0.z, i0.z","mov t0.w, i0.w","dp3 o0.x, t0, c0","dp3 o0.y, t0, c1","dp3 o0.z, t0, c2","#c0=trans1","#c1=trans2","#c2=trans3","#c3=size","#c4=coords"]);
      
      public var originX:Number = 0.5;
      
      public var originY:Number = 0.5;
      
      public var rotation:Number = 0;
      
      public var width:Number;
      
      public var height:Number;
      
      public var perspectiveScale:Boolean = true;
      
      public var alwaysOnTop:Boolean = false;
      
      alternativa3d var surface:Surface;
      
      public function Sprite3D(param1:Number, param2:Number, param3:Material = null)
      {
         super();
         this.width = param1;
         this.height = param2;
         this.alternativa3d::surface = new Surface();
         this.alternativa3d::surface.alternativa3d::object = this;
         this.material = param3;
         this.alternativa3d::surface.indexBegin = 0;
         this.alternativa3d::surface.numTriangles = 2;
         alternativa3d::transformProcedure = transformProcedureStatic;
         alternativa3d::deltaTransformProcedure = deltaTransformProcedureStatic;
      }
      
      public function get material() : Material
      {
         return this.alternativa3d::surface.material;
      }
      
      public function set material(param1:Material) : void
      {
         this.alternativa3d::surface.material = param1;
      }
      
      override alternativa3d function fillResources(param1:Dictionary, param2:Boolean = false, param3:Class = null) : void
      {
         if(this.alternativa3d::surface.material != null)
         {
            this.alternativa3d::surface.material.alternativa3d::fillResources(param1,param3);
         }
         super.alternativa3d::fillResources(param1,param2,param3);
      }
      
      override alternativa3d function collectDraws(param1:Camera3D, param2:Vector.<Light3D>, param3:int, param4:Boolean) : void
      {
         var _loc5_:Geometry = this.alternativa3d::getGeometry(param1.alternativa3d::context3D);
         if(this.alternativa3d::surface.material != null)
         {
            this.alternativa3d::surface.material.alternativa3d::collectDraws(param1,this.alternativa3d::surface,_loc5_,param2,param3,param4,this.alwaysOnTop ? Renderer.NEXT_LAYER : -1);
         }
         if(alternativa3d::listening)
         {
            param1.view.alternativa3d::addSurfaceToMouseEvents(this.alternativa3d::surface,_loc5_,alternativa3d::transformProcedure);
         }
      }
      
      override alternativa3d function setTransformConstants(param1:DrawUnit, param2:Surface, param3:Linker, param4:Camera3D) : void
      {
         var _loc5_:Number = Math.sqrt(alternativa3d::localToCameraTransform.a * alternativa3d::localToCameraTransform.a + alternativa3d::localToCameraTransform.e * alternativa3d::localToCameraTransform.e + alternativa3d::localToCameraTransform.i * alternativa3d::localToCameraTransform.i);
         _loc5_ = _loc5_ + Math.sqrt(alternativa3d::localToCameraTransform.b * alternativa3d::localToCameraTransform.b + alternativa3d::localToCameraTransform.f * alternativa3d::localToCameraTransform.f + alternativa3d::localToCameraTransform.j * alternativa3d::localToCameraTransform.j);
         _loc5_ = _loc5_ + Math.sqrt(alternativa3d::localToCameraTransform.c * alternativa3d::localToCameraTransform.c + alternativa3d::localToCameraTransform.g * alternativa3d::localToCameraTransform.g + alternativa3d::localToCameraTransform.k * alternativa3d::localToCameraTransform.k);
         _loc5_ = _loc5_ / 3;
         if(!this.perspectiveScale && !param4.orthographic)
         {
            _loc5_ *= alternativa3d::localToCameraTransform.l / param4.alternativa3d::focalLength;
         }
         param1.alternativa3d::setVertexConstantsFromTransform(0,alternativa3d::cameraToLocalTransform);
         param1.alternativa3d::setVertexConstantsFromNumbers(3,this.originX,this.originY,this.width * _loc5_,this.height * _loc5_);
         param1.alternativa3d::setVertexConstantsFromNumbers(4,alternativa3d::localToCameraTransform.d,alternativa3d::localToCameraTransform.h,alternativa3d::localToCameraTransform.l,this.rotation);
      }
      
      alternativa3d function getGeometry(param1:Context3D) : Geometry
      {
         var _loc3_:Array = null;
         var _loc2_:Geometry = geometries[param1];
         if(_loc2_ == null)
         {
            _loc2_ = new Geometry(4);
            _loc3_ = [];
            _loc3_[0] = VertexAttributes.POSITION;
            _loc3_[1] = VertexAttributes.POSITION;
            _loc3_[2] = VertexAttributes.POSITION;
            _loc3_[3] = VertexAttributes.NORMAL;
            _loc3_[4] = VertexAttributes.NORMAL;
            _loc3_[5] = VertexAttributes.NORMAL;
            _loc3_[6] = VertexAttributes.TEXCOORDS[0];
            _loc3_[7] = VertexAttributes.TEXCOORDS[0];
            _loc3_[8] = VertexAttributes.TEXCOORDS[1];
            _loc3_[9] = VertexAttributes.TEXCOORDS[1];
            _loc3_[10] = VertexAttributes.TEXCOORDS[2];
            _loc3_[11] = VertexAttributes.TEXCOORDS[2];
            _loc3_[12] = VertexAttributes.TEXCOORDS[3];
            _loc3_[13] = VertexAttributes.TEXCOORDS[3];
            _loc3_[14] = VertexAttributes.TEXCOORDS[4];
            _loc3_[15] = VertexAttributes.TEXCOORDS[4];
            _loc3_[16] = VertexAttributes.TEXCOORDS[5];
            _loc3_[17] = VertexAttributes.TEXCOORDS[5];
            _loc3_[18] = VertexAttributes.TEXCOORDS[6];
            _loc3_[19] = VertexAttributes.TEXCOORDS[6];
            _loc3_[20] = VertexAttributes.TEXCOORDS[7];
            _loc3_[21] = VertexAttributes.TEXCOORDS[7];
            _loc3_[22] = VertexAttributes.TANGENT4;
            _loc3_[23] = VertexAttributes.TANGENT4;
            _loc3_[24] = VertexAttributes.TANGENT4;
            _loc3_[25] = VertexAttributes.TANGENT4;
            _loc2_.addVertexStream(_loc3_);
            _loc2_.setAttributeValues(VertexAttributes.POSITION,Vector.<Number>([0,0,0,0,1,0,1,1,0,1,0,0]));
            _loc2_.setAttributeValues(VertexAttributes.NORMAL,Vector.<Number>([0,0,-1,0,0,-1,0,0,-1,0,0,-1]));
            _loc2_.setAttributeValues(VertexAttributes.TEXCOORDS[0],Vector.<Number>([0,0,0,1,1,1,1,0]));
            _loc2_.setAttributeValues(VertexAttributes.TEXCOORDS[1],Vector.<Number>([0,0,0,1,1,1,1,0]));
            _loc2_.setAttributeValues(VertexAttributes.TEXCOORDS[2],Vector.<Number>([0,0,0,1,1,1,1,0]));
            _loc2_.setAttributeValues(VertexAttributes.TEXCOORDS[3],Vector.<Number>([0,0,0,1,1,1,1,0]));
            _loc2_.setAttributeValues(VertexAttributes.TEXCOORDS[4],Vector.<Number>([0,0,0,1,1,1,1,0]));
            _loc2_.setAttributeValues(VertexAttributes.TEXCOORDS[5],Vector.<Number>([0,0,0,1,1,1,1,0]));
            _loc2_.setAttributeValues(VertexAttributes.TEXCOORDS[6],Vector.<Number>([0,0,0,1,1,1,1,0]));
            _loc2_.setAttributeValues(VertexAttributes.TEXCOORDS[7],Vector.<Number>([0,0,0,1,1,1,1,0]));
            _loc2_.indices = Vector.<uint>([0,1,3,2,3,1]);
            _loc2_.upload(param1);
            geometries[param1] = _loc2_;
         }
         return _loc2_;
      }
      
      override public function clone() : Object3D
      {
         var _loc1_:Sprite3D = new Sprite3D(this.width,this.height);
         _loc1_.clonePropertiesFrom(this);
         return _loc1_;
      }
      
      override protected function clonePropertiesFrom(param1:Object3D) : void
      {
         super.clonePropertiesFrom(param1);
         var _loc2_:Sprite3D = param1 as Sprite3D;
         this.width = _loc2_.width;
         this.height = _loc2_.height;
         this.material = _loc2_.material;
         this.originX = _loc2_.originX;
         this.originY = _loc2_.originY;
         this.rotation = _loc2_.rotation;
         this.perspectiveScale = _loc2_.perspectiveScale;
         this.alwaysOnTop = _loc2_.alwaysOnTop;
      }
      
      override alternativa3d function updateBoundBox(param1:BoundBox, param2:Transform3D = null) : void
      {
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc3_:Number = this.width;
         var _loc4_:Number = this.height;
         var _loc5_:Number = (this.originX >= 0.5 ? this.originX : 1 - this.originX) * _loc3_;
         var _loc6_:Number = (this.originY >= 0.5 ? this.originY : 1 - this.originY) * _loc4_;
         var _loc7_:Number = Math.sqrt(_loc5_ * _loc5_ + _loc6_ * _loc6_);
         var _loc8_:Number = 0;
         var _loc9_:Number = 0;
         var _loc10_:Number = 0;
         if(param2 != null)
         {
            _loc11_ = param2.a;
            _loc12_ = param2.e;
            _loc13_ = param2.i;
            _loc14_ = Math.sqrt(_loc11_ * _loc11_ + _loc12_ * _loc12_ + _loc13_ * _loc13_);
            _loc11_ = param2.b;
            _loc12_ = param2.f;
            _loc13_ = param2.j;
            _loc14_ += Math.sqrt(_loc11_ * _loc11_ + _loc12_ * _loc12_ + _loc13_ * _loc13_);
            _loc11_ = param2.c;
            _loc12_ = param2.g;
            _loc13_ = param2.k;
            _loc14_ += Math.sqrt(_loc11_ * _loc11_ + _loc12_ * _loc12_ + _loc13_ * _loc13_);
            _loc7_ *= _loc14_ / 3;
            _loc8_ = param2.d;
            _loc9_ = param2.h;
            _loc10_ = param2.l;
         }
         if(_loc8_ - _loc7_ < param1.minX)
         {
            param1.minX = _loc8_ - _loc7_;
         }
         if(_loc8_ + _loc7_ > param1.maxX)
         {
            param1.maxX = _loc8_ + _loc7_;
         }
         if(_loc9_ - _loc7_ < param1.minY)
         {
            param1.minY = _loc9_ - _loc7_;
         }
         if(_loc9_ + _loc7_ > param1.maxY)
         {
            param1.maxY = _loc9_ + _loc7_;
         }
         if(_loc10_ - _loc7_ < param1.minZ)
         {
            param1.minZ = _loc10_ - _loc7_;
         }
         if(_loc10_ + _loc7_ > param1.maxZ)
         {
            param1.maxZ = _loc10_ + _loc7_;
         }
      }
   }
}

