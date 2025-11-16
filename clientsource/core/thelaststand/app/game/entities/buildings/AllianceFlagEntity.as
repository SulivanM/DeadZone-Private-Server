package thelaststand.app.game.entities.buildings
{
   import alternativa.engine3d.materials.StandardMaterial;
   import alternativa.engine3d.objects.Mesh;
   import alternativa.engine3d.resources.BitmapTextureResource;
   import flash.display.BitmapData;
   import thelaststand.app.game.data.alliance.AllianceBannerData;
   import thelaststand.app.game.gui.alliance.banner.AllianceBannerDisplay;
   import thelaststand.common.resources.MaterialLibrary;
   import thelaststand.common.resources.Resource;
   import thelaststand.common.resources.ResourceManager;
   
   public class AllianceFlagEntity extends BuildingEntity
   {
      
      private var _available:Boolean = true;
      
      private var mesh_banner:Mesh;
      
      private var mesh_nobanner:Mesh;
      
      private var _bannerData:AllianceBannerData;
      
      private var _loadedBannerStr:String = "";
      
      private var _bannerGenerator:AllianceBannerData;
      
      private var _bitmapTextureResource:BitmapTextureResource;
      
      private var _material:StandardMaterial;
      
      public function AllianceFlagEntity()
      {
         super();
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.mesh_banner = null;
         this.mesh_nobanner = null;
         this.disposeTextureResources();
         if(this._bannerData)
         {
            this._bannerData.onChange.remove(this.updateBannerTexture);
            this._bannerData = null;
         }
         AllianceBannerDisplay.getInstance().onReady.remove(this.generateBannerResource);
      }
      
      private function disposeTextureResources() : void
      {
         if(this._bitmapTextureResource)
         {
            this._bitmapTextureResource.dispose();
            this._bitmapTextureResource = null;
         }
         if(this._material)
         {
            this._material = null;
         }
      }
      
      private function updateBannerVisibility() : void
      {
         if(this.mesh_banner == null || this.mesh_nobanner == null)
         {
            return;
         }
         var _loc1_:Boolean = this._available == true && this._bannerData != null;
         this.mesh_banner.visible = _loc1_;
         this.mesh_nobanner.visible = !_loc1_;
      }
      
      private function updateBannerTexture() : void
      {
         var _loc3_:AllianceBannerDisplay = null;
         if(this._bannerData == null)
         {
            this._loadedBannerStr = "";
            return;
         }
         this._loadedBannerStr = "ab_" + this._bannerData.hexString;
         var _loc1_:ResourceManager = ResourceManager.getInstance();
         var _loc2_:Resource = _loc1_.getResource(this._loadedBannerStr);
         if(_loc2_ == null)
         {
            _loc3_ = AllianceBannerDisplay.getInstance();
            if(_loc3_.ready)
            {
               this.generateBannerResource();
            }
            else
            {
               _loc3_.onReady.addOnce(this.generateBannerResource);
            }
            return;
         }
         if(this.mesh_banner == null)
         {
            return;
         }
         this.disposeTextureResources();
         this._bitmapTextureResource = new BitmapTextureResource(_loc2_.content as BitmapData,false);
         this._material = new StandardMaterial(this._bitmapTextureResource,ResourceManager.getInstance().materials.getBitmapTextureResource(MaterialLibrary.NORMAL_FLAT_URI));
         this._material.transparentPass = false;
         this._material.opaquePass = true;
         this._material.specularPower = 0;
         this.mesh_banner.setMaterialToAllSurfaces(this._material);
         assetInvalidated.dispatch(this);
      }
      
      private function generateBannerResource() : void
      {
         if(this._bannerData == null)
         {
            return;
         }
         var _loc1_:AllianceBannerDisplay = AllianceBannerDisplay.getInstance();
         _loc1_.byteArray = this._bannerData.byteArray;
         var _loc2_:BitmapData = _loc1_.generateBannerTexture();
         ResourceManager.getInstance().addResource(_loc2_,this._loadedBannerStr);
         this.updateBannerTexture();
      }
      
      override protected function onMeshReady() : void
      {
         super.onMeshReady();
         this.mesh_banner = mesh_building.getChildByName("banner") as Mesh;
         this.mesh_nobanner = mesh_building.getChildByName("bannernone") as Mesh;
         this.updateBannerTexture();
         this.updateBannerVisibility();
      }
      
      public function get available() : Boolean
      {
         return this._available;
      }
      
      public function set available(param1:Boolean) : void
      {
         this._available = param1;
         this.updateBannerVisibility();
      }
      
      public function get bannerData() : AllianceBannerData
      {
         return this._bannerData;
      }
      
      public function set bannerData(param1:AllianceBannerData) : void
      {
         if(this._bannerData)
         {
            this._bannerData.onChange.remove(this.updateBannerTexture);
         }
         this._bannerData = param1;
         if(this._bannerData)
         {
            this._bannerData.onChange.add(this.updateBannerTexture);
         }
         this.updateBannerTexture();
         this.updateBannerVisibility();
      }
   }
}

