package thelaststand.app.game.entities.actors
{
   import alternativa.engine3d.materials.StandardMaterial;
   import alternativa.engine3d.objects.Mesh;
   import alternativa.engine3d.objects.Surface;
   import alternativa.engine3d.utils.Object3DUtils;
   import thelaststand.app.game.data.AnimalAppearance;
   import thelaststand.common.resources.ResourceManager;
   import thelaststand.engine.utils.TextureBuilder;
   
   public class AnimalActor extends Actor
   {
      
      private var _appearance:AnimalAppearance;
      
      private var _invalidAttire:Boolean;
      
      private var _height:Number = 0;
      
      private var mesh_body:Mesh;
      
      public function AnimalActor()
      {
         super();
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._appearance = null;
         this.mesh_body = null;
      }
      
      override public function clear() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Surface = null;
         var _loc3_:StandardMaterial = null;
         if(this.mesh_body != null)
         {
            _loc1_ = 0;
            while(_loc1_ < this.mesh_body.numSurfaces)
            {
               _loc2_ = this.mesh_body.getSurface(_loc1_);
               if(_loc2_ != null)
               {
                  _loc3_ = _loc2_.material as StandardMaterial;
                  if(_loc3_ != null && _loc3_.diffuseMap != null)
                  {
                     _loc3_.diffuseMap.dispose();
                     _loc3_.diffuseMap = null;
                  }
               }
               _loc1_++;
            }
            this.mesh_body = null;
         }
         if(this._appearance != null && this._appearance.body.modifiedTexture)
         {
            ResourceManager.getInstance().purge(this._appearance.body.modifiedTextureURI);
         }
         this._appearance = null;
         super.clear();
      }
      
      override public function getHeight() : Number
      {
         return this._height;
      }
      
      public function setAppearance(param1:AnimalAppearance) : void
      {
         this._appearance = param1;
         this._invalidAttire = true;
      }
      
      public function applyAppearance() : void
      {
         var _loc1_:StandardMaterial = null;
         if(!this._invalidAttire)
         {
            return;
         }
         _asset.removeAllAnimations();
         _asset.removeChildren();
         _asset.addChild(mesh_hitArea);
         this.mesh_body = addSubAssetFromResource("body",this._appearance.body.model) as Mesh;
         if(this.mesh_body != null)
         {
            _loc1_ = ResourceManager.getInstance().materials.getStandardMaterial("",TextureBuilder.buildTexture(this._appearance.body,this._appearance.getOverlays(this._appearance.body.type)));
            this.mesh_body.setMaterialToAllSurfaces(_loc1_);
            this._height = this.mesh_body.boundBox.minZ + (this.mesh_body.boundBox.maxZ - this.mesh_body.boundBox.minZ);
         }
         refreshAnimations();
         Object3DUtils.calculateHierarchyBoundBox(_asset,_asset,_asset.boundBox);
         _asset.replay();
         this._invalidAttire = false;
         assetInvalidated.dispatch(this);
      }
   }
}

