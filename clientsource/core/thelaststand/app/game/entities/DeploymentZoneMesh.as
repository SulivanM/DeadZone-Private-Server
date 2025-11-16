package thelaststand.app.game.entities
{
   import alternativa.engine3d.core.VertexAttributes;
   import alternativa.engine3d.materials.TextureMaterial;
   import alternativa.engine3d.objects.Decal;
   import alternativa.engine3d.resources.Geometry;
   import flash.display.BitmapData;
   import thelaststand.common.resources.ResourceManager;
   
   public class DeploymentZoneMesh extends Decal
   {
      
      private var _material:TextureMaterial;
      
      private var _width:int;
      
      private var _height:int;
      
      public function DeploymentZoneMesh(param1:int, param2:int)
      {
         super();
         this._width = param1;
         this._height = param2;
         mouseEnabled = mouseChildren = false;
         var _loc3_:String = "images/ui/scene-exit-tile.png";
         var _loc4_:BitmapData = ResourceManager.getInstance().getResource(_loc3_).content;
         this._material = ResourceManager.getInstance().materials.getTextureMaterial("deployZoneMaterial",_loc3_);
         this._material.alpha = 0.75;
         var _loc5_:Array = [VertexAttributes.POSITION,VertexAttributes.POSITION,VertexAttributes.POSITION,VertexAttributes.TEXCOORDS[0],VertexAttributes.TEXCOORDS[0]];
         geometry = new Geometry();
         geometry.addVertexStream(_loc5_);
         geometry.numVertices = 4;
         var _loc6_:Array = [0,0,0,param1,0,0,param1,param2,0,0,param2,0];
         var _loc7_:Number = this._width / _loc4_.width * 0.25;
         var _loc8_:Number = this._height / _loc4_.height * 0.25;
         var _loc9_:Array = [0,0,_loc7_,0,_loc7_,_loc8_,0,_loc8_];
         var _loc10_:Array = [0,1,2,0,2,3];
         geometry.setAttributeValues(VertexAttributes.POSITION,Vector.<Number>(_loc6_));
         geometry.setAttributeValues(VertexAttributes.TEXCOORDS[0],Vector.<Number>(_loc9_));
         geometry.indices = Vector.<uint>(_loc10_);
         addSurface(this._material,0,2);
         calculateBoundBox();
      }
      
      public function get width() : int
      {
         return this._width;
      }
      
      public function get height() : int
      {
         return this._height;
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         geometry.dispose();
         geometry = null;
         this._material = null;
      }
   }
}

