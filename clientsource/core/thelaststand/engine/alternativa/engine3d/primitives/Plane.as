package thelaststand.engine.alternativa.engine3d.primitives
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.VertexAttributes;
   import alternativa.engine3d.materials.Material;
   import alternativa.engine3d.objects.Mesh;
   import alternativa.engine3d.resources.Geometry;
   import flash.geom.Vector3D;
   
   public class Plane extends Mesh
   {
      
      private var _doubleSided:Boolean;
      
      public function Plane(param1:Number = 100, param2:Number = 100, param3:Boolean = false, param4:Material = null)
      {
         super();
         this._doubleSided = param3;
         var _loc5_:Array = [VertexAttributes.POSITION,VertexAttributes.POSITION,VertexAttributes.POSITION,VertexAttributes.TEXCOORDS[0],VertexAttributes.TEXCOORDS[0],VertexAttributes.NORMAL,VertexAttributes.NORMAL,VertexAttributes.NORMAL,VertexAttributes.TANGENT4,VertexAttributes.TANGENT4,VertexAttributes.TANGENT4,VertexAttributes.TANGENT4];
         geometry = new Geometry();
         geometry.addVertexStream(_loc5_);
         geometry.numVertices = 4;
         var _loc6_:Number = param1 * 0.5;
         var _loc7_:Number = param2 * 0.5;
         var _loc8_:Array = [-_loc6_,_loc7_,0,_loc6_,_loc7_,0,_loc6_,-_loc7_,0,-_loc6_,-_loc7_,0];
         var _loc9_:Array = [0,0,1,0,1,1,0,1];
         var _loc10_:Array = param3 ? [0,2,1,0,3,2,0,1,2,0,2,3] : [0,2,1,0,3,2];
         var _loc11_:Array = [];
         var _loc12_:Vector3D = this.calcNormals(new Vector3D(_loc8_[0],_loc8_[1],_loc8_[2]),new Vector3D(_loc8_[3],_loc8_[4],_loc8_[5]),new Vector3D(_loc8_[6],_loc8_[7],_loc8_[8]));
         _loc11_.push(_loc12_.x,_loc12_.y,_loc12_.z,_loc12_.x,_loc12_.y,_loc12_.z,_loc12_.x,_loc12_.y,_loc12_.z,_loc12_.x,_loc12_.y,_loc12_.z);
         var _loc13_:Array = [];
         _loc12_ = new Vector3D(_loc8_[0] - _loc8_[6],_loc8_[1] - _loc8_[7],_loc8_[2] - _loc8_[8]);
         _loc12_.normalize();
         _loc13_.push(_loc12_.x,_loc12_.y,_loc12_.z,1,_loc12_.x,_loc12_.y,_loc12_.z,1,_loc12_.x,_loc12_.y,_loc12_.z,1,_loc12_.x,_loc12_.y,_loc12_.z,1);
         geometry.setAttributeValues(VertexAttributes.POSITION,Vector.<Number>(_loc8_));
         geometry.setAttributeValues(VertexAttributes.TEXCOORDS[0],Vector.<Number>(_loc9_));
         geometry.setAttributeValues(VertexAttributes.NORMAL,Vector.<Number>(_loc11_));
         geometry.setAttributeValues(VertexAttributes.TANGENT4,Vector.<Number>(_loc13_));
         geometry.indices = Vector.<uint>(_loc10_);
         addSurface(param4,0,param3 ? 4 : 2);
         calculateBoundBox();
      }
      
      override public function clone() : Object3D
      {
         var _loc1_:thelaststand.engine.alternativa.engine3d.primitives.Plane = new thelaststand.engine.alternativa.engine3d.primitives.Plane();
         var _loc2_:Material = _loc1_.getSurface(0).material;
         _loc1_.geometry = this.geometry;
         _loc1_.alternativa3d::_surfaces.length = 0;
         _loc1_.alternativa3d::_surfacesLength = 0;
         _loc1_.addSurface(_loc2_,0,this._doubleSided ? 4 : 2);
         _loc1_.calculateBoundBox();
         return _loc1_;
      }
      
      private function calcNormals(param1:Vector3D, param2:Vector3D, param3:Vector3D) : Vector3D
      {
         var _loc4_:Vector3D = param1.subtract(param2);
         var _loc5_:Vector3D = param1.subtract(param3);
         var _loc6_:Vector3D = _loc4_.crossProduct(_loc5_);
         _loc6_.normalize();
         return _loc6_;
      }
   }
}

