package thelaststand.app.game.entities.actors
{
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.lights.OmniLight;
   import alternativa.engine3d.objects.Mesh;
   import alternativa.engine3d.objects.Surface;
   import alternativa.engine3d.utils.Object3DUtils;
   import thelaststand.app.core.Global;
   import thelaststand.app.core.Settings;
   import thelaststand.app.game.data.AttireData;
   import thelaststand.app.game.data.AttireFlags;
   import thelaststand.app.game.data.HumanAppearance;
   import thelaststand.common.resources.MaterialLibrary;
   import thelaststand.common.resources.ResourceManager;
   import thelaststand.engine.utils.TextureBuilder;
   import thelaststand.engine.utils.TweenMaxDelta;
   
   public class HumanActor extends Actor
   {
      
      public static const SURFACE_CLOTHING:int = 0;
      
      public static const SURFACE_SKIN:int = 1;
      
      private var _accessories:Vector.<Object3D>;
      
      private var _muzzleflashInterval:int = -1;
      
      private var _invalidAttire:Boolean;
      
      private var _height:Number = 0;
      
      private var _propRightVisible:Boolean = true;
      
      protected var _appearance:HumanAppearance;
      
      private var mesh_muzzleflash:Mesh;
      
      private var mesh_magazine:Mesh;
      
      private var light_muzzleflash:OmniLight;
      
      public var obj_handRight:Object3D;
      
      public function HumanActor()
      {
         super();
         this._accessories = new Vector.<Object3D>();
      }
      
      override public function clear() : void
      {
         super.clear();
         TweenMaxDelta.killDelayedCallsTo(this.killMuzzleflash);
         this._appearance = null;
         this._invalidAttire = false;
         this.obj_handRight = null;
         this.mesh_magazine = null;
         this.mesh_muzzleflash = null;
      }
      
      override public function dispose() : void
      {
         super.dispose();
         if(this.light_muzzleflash != null)
         {
            if(this.light_muzzleflash.parent != null)
            {
               this.light_muzzleflash.parent.removeChild(this.light_muzzleflash);
            }
            this.light_muzzleflash = null;
         }
         this._accessories = null;
      }
      
      override public function getHeight() : Number
      {
         return this._height;
      }
      
      public function setAppearance(param1:HumanAppearance) : void
      {
         this._appearance = param1;
         this._invalidAttire = true;
      }
      
      public function applyAppearance() : void
      {
         var _loc1_:int = 0;
         var _loc3_:AttireData = null;
         var _loc6_:Mesh = null;
         var _loc7_:Object3D = null;
         if(!this._invalidAttire)
         {
            return;
         }
         _asset.removeAllAnimations();
         _asset.removeChildren();
         this._accessories.length = 0;
         _asset.addChild(mesh_hitArea);
         if(this.obj_handRight != null)
         {
            _asset.addChild(this.obj_handRight);
         }
         var _loc2_:int = int(this._appearance.data.length);
         var _loc4_:Boolean = false;
         var _loc5_:Boolean = false;
         _loc1_ = 0;
         for(; _loc1_ < _loc2_; _loc1_++)
         {
            _loc3_ = this._appearance.data[_loc1_];
            if(_loc3_.model != null)
            {
               _loc7_ = addSubAssetFromResource(_loc3_.id + "-" + _loc3_.type,_loc3_.model,true);
               if(_loc7_ != null)
               {
                  if(_loc7_ is Mesh)
                  {
                     _loc6_ = Mesh(_loc7_);
                  }
                  else
                  {
                     if(_loc7_.numChildren == 0)
                     {
                        continue;
                     }
                     _loc6_ = _loc7_.getChildAt(0) as Mesh;
                  }
                  if(_loc6_ != null)
                  {
                     switch(_loc3_.type)
                     {
                        case "upper":
                           this.setSkinAndClothingTextures(_loc6_,_loc3_);
                           break;
                        case "lower":
                           this.setSkinAndClothingTextures(_loc6_,_loc3_);
                           break;
                        case "hair":
                        case "fhair":
                           this.setAppearanceTextures(_loc6_,_loc3_);
                           break;
                        case "acc":
                           if((_loc3_.flags & AttireFlags.CLOTHING) != 0)
                           {
                              this.setSkinAndClothingTextures(_loc6_,_loc3_);
                           }
                           else
                           {
                              this.setAppearanceTextures(_loc6_,_loc3_);
                           }
                     }
                     this._accessories.push(_loc6_);
                  }
               }
            }
         }
         refreshAnimations();
         Object3DUtils.calculateHierarchyBoundBox(_asset,_asset,_asset.boundBox);
         this._height = 160 * defaultScale;
         _asset.replay();
         this._invalidAttire = false;
         assetInvalidated.dispatch(this);
      }
      
      public function setPropVisibility(param1:Boolean) : void
      {
         this._propRightVisible = param1;
         if(this.obj_handRight != null)
         {
            this.obj_handRight.visible = this._propRightVisible;
         }
      }
      
      public function setRightHandItem(param1:String, param2:Vector.<String> = null) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object3D = null;
         var _loc5_:Array = null;
         this.obj_handRight = addSubAssetFromResource("rightHand",param1);
         this._propRightVisible = true;
         if(this.obj_handRight != null)
         {
            this.obj_handRight.visible = this._propRightVisible;
            MaterialLibrary.setTransparentPassToChildren(this.obj_handRight,0.9);
            if(param2 != null)
            {
               _loc3_ = 0;
               while(_loc3_ < this.obj_handRight.numChildren)
               {
                  _loc4_ = this.obj_handRight.getChildAt(_loc3_);
                  if(_loc4_.name != null)
                  {
                     _loc5_ = _loc4_.name.split("_");
                     if(_loc5_[0] == "att")
                     {
                        _loc4_.visible = param2.indexOf(_loc5_[1]) > -1;
                     }
                  }
                  _loc3_++;
               }
            }
            this.mesh_magazine = this.obj_handRight.getChildByName("magazine") as Mesh;
            this.mesh_muzzleflash = this.obj_handRight.getChildByName("muzzleflash") as Mesh;
            if(this.mesh_muzzleflash != null)
            {
               if(this.light_muzzleflash == null)
               {
                  this.light_muzzleflash = new OmniLight(16770688,0,700);
                  this.light_muzzleflash.y = -120;
                  this.light_muzzleflash.z = 80;
                  this.light_muzzleflash.intensity = 2;
                  _asset.addChild(this.light_muzzleflash);
               }
               this.mesh_muzzleflash.visible = false;
               this.light_muzzleflash.visible = false;
            }
            else if(this.light_muzzleflash != null)
            {
               if(this.light_muzzleflash.parent != null)
               {
                  this.light_muzzleflash.parent.removeChild(this.light_muzzleflash);
               }
               this.light_muzzleflash = null;
            }
         }
         else
         {
            this.mesh_magazine = null;
            this.mesh_muzzleflash = null;
         }
         if(scene != null)
         {
            assetInvalidated.dispatch(this);
         }
      }
      
      public function showMuzzleflash(param1:Number = 0.025) : void
      {
         if(this.mesh_muzzleflash == null)
         {
            return;
         }
         TweenMaxDelta.killDelayedCallsTo(this.killMuzzleflash);
         this.mesh_muzzleflash.visible = true;
         if(!Global.lowFPS && Global.activeMuzzleFlashCount < 2 && Settings.getInstance().dynamicLights && this.light_muzzleflash != null && scene != null)
         {
            this.light_muzzleflash.visible = true;
            ++Global.activeMuzzleFlashCount;
         }
         TweenMaxDelta.delayedCall(param1,this.killMuzzleflash);
      }
      
      private function killMuzzleflash() : void
      {
         TweenMaxDelta.killDelayedCallsTo(this.killMuzzleflash);
         if(this.mesh_muzzleflash != null)
         {
            this.mesh_muzzleflash.visible = false;
         }
         if(this.light_muzzleflash != null && this.light_muzzleflash.visible)
         {
            this.light_muzzleflash.visible = false;
            --Global.activeMuzzleFlashCount;
         }
      }
      
      private function setAppearanceTextures(param1:Mesh, param2:AttireData) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc3_:ResourceManager = ResourceManager.getInstance();
         var _loc4_:Surface = param1.getSurface(0);
         if(_loc4_ != null)
         {
            _loc4_.material = _loc3_.materials.getStandardMaterial("",TextureBuilder.buildTexture(param2,this._appearance.getOverlays(param2.type)));
         }
      }
      
      protected function setSkinAndClothingTextures(param1:Mesh, param2:AttireData) : void
      {
         var _loc4_:Surface = null;
         if(param1 == null)
         {
            return;
         }
         var _loc3_:ResourceManager = ResourceManager.getInstance();
         var _loc5_:int = SURFACE_SKIN;
         var _loc6_:int = SURFACE_CLOTHING;
         if(this._appearance.skin.texture != null && param1.numSurfaces > _loc5_)
         {
            _loc4_ = param1.getSurface(_loc5_);
            if(_loc4_ != null)
            {
               _loc4_.material = _loc3_.materials.getStandardMaterial("",TextureBuilder.buildTexture(this._appearance.skin,this._appearance.getOverlays(this._appearance.skin.type)));
            }
         }
         if(param2.texture != null && param1.numSurfaces > _loc6_)
         {
            _loc4_ = param1.getSurface(_loc6_);
            if(_loc4_ != null)
            {
               _loc4_.material = _loc3_.materials.getStandardMaterial("",TextureBuilder.buildTexture(param2,this._appearance.getOverlays(param2.type)));
            }
         }
      }
      
      override protected function onAnimationNotified(param1:String, param2:String) : void
      {
         switch(param2)
         {
            case "magOut":
               if(this.mesh_magazine != null)
               {
                  this.mesh_magazine.visible = false;
               }
               break;
            case "magIn":
               if(this.mesh_magazine != null)
               {
                  this.mesh_magazine.visible = true;
               }
         }
      }
   }
}

