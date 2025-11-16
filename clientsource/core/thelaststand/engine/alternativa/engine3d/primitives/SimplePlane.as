package thelaststand.engine.alternativa.engine3d.primitives
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.VertexAttributes;
   import alternativa.engine3d.materials.Material;
   import alternativa.engine3d.objects.Mesh;
   import alternativa.engine3d.resources.Geometry;
   
   public class SimplePlane extends Mesh
   {
      
      private var _doubleSided:Boolean;
      
      public function SimplePlane(param1:Number = 1, param2:Number = 1, param3:Boolean = false, param4:Material = null)
      {
         super();
         this._doubleSided = param3;
         var _loc5_:Array = [VertexAttributes.POSITION,VertexAttributes.POSITION,VertexAttributes.POSITION,VertexAttributes.TEXCOORDS[0],VertexAttributes.TEXCOORDS[0]];
         geometry = new Geometry();
         geometry.addVertexStream(_loc5_);
         geometry.numVertices = 4;
         var _loc6_:Number = param1 * 0.5;
         var _loc7_:Number = param2 * 0.5;
         var _loc8_:Array = [-_loc6_,_loc7_,0,_loc6_,_loc7_,0,_loc6_,-_loc7_,0,-_loc6_,-_loc7_,0];
         var _loc9_:Array = [0,0,1,0,1,1,0,1];
         var _loc10_:Array = param3 ? [0,2,1,0,3,2,0,1,2,0,2,3] : [0,2,1,0,3,2];
         geometry.setAttributeValues(VertexAttributes.POSITION,Vector.<Number>(_loc8_));
         geometry.setAttributeValues(VertexAttributes.TEXCOORDS[0],Vector.<Number>(_loc9_));
         geometry.indices = Vector.<uint>(_loc10_);
         addSurface(param4,0,param3 ? 4 : 2);
         calculateBoundBox();
      }
      
      override public function clone() : Object3D
      {
         var _loc1_:SimplePlane = new SimplePlane();
         var _loc2_:Material = _loc1_.getSurface(0).material;
         _loc1_.geometry = this.geometry;
         _loc1_.alternativa3d::_surfaces.length = 0;
         _loc1_.alternativa3d::_surfacesLength = 0;
         _loc1_.addSurface(_loc2_,0,this._doubleSided ? 4 : 2);
         _loc1_.calculateBoundBox();
         return _loc1_;
      }
   }
}

