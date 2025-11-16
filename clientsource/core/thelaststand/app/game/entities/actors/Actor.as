package thelaststand.app.game.entities.actors
{
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.materials.StandardMaterial;
   import alternativa.engine3d.objects.Mesh;
   import alternativa.engine3d.primitives.Box;
   import flash.geom.Matrix3D;
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;
   import thelaststand.app.core.Global;
   import thelaststand.common.resources.ResourceManager;
   import thelaststand.engine.animation.AnimationTable;
   import thelaststand.engine.geom.Transform;
   import thelaststand.engine.geom.primitives.Primitives;
   import thelaststand.engine.meshes.AnimatedMeshGroup;
   import thelaststand.engine.meshes.MeshGroup;
   import thelaststand.engine.objects.GameEntity;
   import thelaststand.engine.utils.TweenMaxDelta;
   
   public class Actor extends GameEntity
   {
      
      private var _alpha:Number = 1;
      
      private var _fadeTarget:Number = NaN;
      
      private var _targetForward:Vector3D;
      
      private var _tmpForwardRotationMatrix:Matrix3D;
      
      private var _subAssetsById:Dictionary = new Dictionary(true);
      
      protected var _asset:AnimatedMeshGroup;
      
      protected var _assetAnims:Vector.<AnimationTable>;
      
      protected var mesh_hitArea:Box;
      
      public var defaultScale:Number = 1.25;
      
      public function Actor()
      {
         super();
         this._asset = new AnimatedMeshGroup();
         this._asset.mouseEnabled = false;
         this._asset.mouseChildren = true;
         this._asset.animationNotified.add(this.onAnimationNotified);
         this._assetAnims = new Vector.<AnimationTable>();
         this.mesh_hitArea = Primitives.BOX.clone() as Box;
         this.mesh_hitArea.mouseEnabled = true;
         this.mesh_hitArea.mouseChildren = false;
         this._asset.addChild(this.mesh_hitArea);
         boundingBoxMesh = this.mesh_hitArea;
         this.setHitAreaSize(90,210);
         this.setInteractionBoundBoxActiveState(true);
         this.asset = this._asset;
         castsShadows = true;
         losVisible = false;
         addedToScene.add(this.onAddedToScene);
      }
      
      public function addAnimation(param1:String) : Boolean
      {
         if(this._assetAnims == null)
         {
            return false;
         }
         var _loc2_:AnimationTable = ResourceManager.getInstance().animations.getAnimationTable(param1);
         if(_loc2_ == null || this._assetAnims.indexOf(_loc2_) > -1)
         {
            return false;
         }
         this._assetAnims.push(_loc2_);
         if(this._asset != null)
         {
            this._asset.addAnimationTable(_loc2_);
         }
         return true;
      }
      
      public function removeAnimation(param1:String) : Boolean
      {
         if(this._assetAnims == null)
         {
            return false;
         }
         var _loc2_:AnimationTable = ResourceManager.getInstance().animations.getAnimationTable(param1);
         var _loc3_:int = int(this._assetAnims.indexOf(_loc2_));
         if(_loc2_ == null || _loc3_ == -1)
         {
            return false;
         }
         this._assetAnims.splice(_loc3_,1);
         if(this._asset != null)
         {
            this._asset.removeAnimationTable(_loc2_);
         }
         return true;
      }
      
      public function clear() : void
      {
         TweenMaxDelta.killTweensOf(this._asset);
         this.killFade();
         this._asset.removeAllAnimations();
         this._asset.removeChildren();
         this._asset.visible = true;
         this._alpha = 1;
      }
      
      override public function dispose() : void
      {
         this.clear();
         addedToScene.remove(this.onAddedToScene);
         this.mesh_hitArea.geometry = null;
         this.mesh_hitArea = null;
         boundingBoxMesh = null;
         this._assetAnims = null;
         if(this._asset != null)
         {
            this._asset.animationNotified.remove(this.onAnimationNotified);
            this._asset = null;
         }
         super.dispose();
      }
      
      public function fade(param1:Number, param2:Number = 0.5, param3:Number = 0, param4:Function = null) : void
      {
         if(this._fadeTarget == param1)
         {
            return;
         }
         this.killFade();
         this._fadeTarget = param1;
         if(this._fadeTarget > 0)
         {
            this._asset.visible = true;
         }
         var _loc5_:Actor = this;
         if(Global.softwareRendering)
         {
            TweenMaxDelta.delayedCall(param3,this.onFadeComplete,[param1,param4]);
         }
         else
         {
            TweenMaxDelta.to(this,param2,{
               "delay":param3,
               "alpha":this._fadeTarget + 0.01,
               "onComplete":this.onFadeComplete,
               "onCompleteParams":[param1,param4]
            });
         }
      }
      
      public function killFade() : void
      {
         TweenMaxDelta.killTweensOf(this);
         TweenMaxDelta.killDelayedCallsTo(this.onFadeComplete);
      }
      
      public function refreshAnimations() : void
      {
         var _loc1_:AnimationTable = null;
         if(this._asset == null)
         {
            return;
         }
         this._asset.removeAllAnimations();
         if(this._assetAnims != null)
         {
            for each(_loc1_ in this._assetAnims)
            {
               this._asset.addAnimationTable(_loc1_);
            }
         }
         if(scene != null)
         {
            this._asset.attachAnimations();
         }
      }
      
      public function setHitAreaSize(param1:int, param2:int) : void
      {
         this.mesh_hitArea.scaleX = this.mesh_hitArea.scaleY = param1;
         this.mesh_hitArea.scaleZ = param2;
         this.mesh_hitArea.z = int(param2 * 0.5);
      }
      
      public function setInteractionBoundBoxActiveState(param1:Boolean) : void
      {
         this._asset.mouseEnabled = false;
         this._asset.mouseChildren = param1;
         this.mesh_hitArea.visible = param1;
      }
      
      override public function updateTransform(param1:Number = 1) : void
      {
         var _loc2_:Number = NaN;
         if(this._targetForward != null)
         {
            _loc2_ = this._targetForward.x * this._targetForward.x + this._targetForward.y * this._targetForward.y + this._targetForward.z * this._targetForward.z;
            if(_loc2_ > 0)
            {
               if(this._tmpForwardRotationMatrix == null)
               {
                  this._tmpForwardRotationMatrix = new Matrix3D();
               }
               transform.rotation.interpolateTo(Transform.buildForwardRotationMatrix(this._targetForward,null,true,this._tmpForwardRotationMatrix),Math.min(param1 * 6,1));
            }
         }
         super.updateTransform(param1);
      }
      
      protected function addSubAsset(param1:String, param2:Object3D) : Object3D
      {
         this.removeSubAsset(param1);
         if(asset == null)
         {
            return null;
         }
         param2.name = param1;
         param2.scaleX = param2.scaleY = param2.scaleZ = this.defaultScale;
         param2.mouseEnabled = param2.mouseChildren = false;
         if(param2.parent != this._asset)
         {
            this._asset.addChild(param2);
         }
         this._subAssetsById[param1] = param2;
         return param2;
      }
      
      protected function addSubAssetFromResource(param1:String, param2:String, param3:Boolean = true, param4:Boolean = false) : Object3D
      {
         var _loc5_:Object3D = null;
         this.removeSubAsset(param1);
         if(!param2)
         {
            return null;
         }
         if(param3)
         {
            _loc5_ = new Object3D();
            MeshGroup.addChildren(param2,_loc5_,param4);
         }
         else
         {
            MeshGroup.addChildren(param2,this._asset,param4);
            _loc5_ = this._asset.getChildAt(this._asset.numChildren - 1);
         }
         return this.addSubAsset(param1,_loc5_);
      }
      
      protected function getSubAsset(param1:String) : Object3D
      {
         return this._subAssetsById[param1];
      }
      
      protected function removeSubAsset(param1:String) : void
      {
         var _loc2_:Object3D = this._subAssetsById[param1];
         if(_loc2_ != null)
         {
            this._asset.removeObject(_loc2_);
            TweenMaxDelta.killTweensOf(_loc2_);
         }
         delete this._subAssetsById[param1];
      }
      
      private function onAddedToScene(param1:GameEntity) : void
      {
         this._asset.attachAnimations();
      }
      
      protected function onAnimationNotified(param1:String, param2:String) : void
      {
      }
      
      private function onFadeComplete(param1:Number, param2:Function = null) : void
      {
         this.alpha = param1;
         if(this._asset != null)
         {
            this._asset.visible = this.alpha > 0;
         }
         if(param2 != null)
         {
            param2();
         }
      }
      
      public function get animatedAsset() : AnimatedMeshGroup
      {
         return this._asset;
      }
      
      public function get mouseEnabled() : Boolean
      {
         return this._asset.mouseChildren;
      }
      
      public function set mouseEnabled(param1:Boolean) : void
      {
         if(param1 == this._asset.mouseChildren)
         {
            return;
         }
         this.setInteractionBoundBoxActiveState(param1);
      }
      
      public function get alpha() : Number
      {
         return this._alpha;
      }
      
      public function set alpha(param1:Number) : void
      {
         var _loc4_:Mesh = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:StandardMaterial = null;
         if(param1 == this._alpha)
         {
            return;
         }
         this._alpha = param1;
         if(this._asset == null)
         {
            return;
         }
         var _loc2_:int = 0;
         var _loc3_:int = this._asset.numChildren;
         while(_loc2_ < _loc3_)
         {
            _loc4_ = this._asset.getChildAt(_loc2_) as Mesh;
            if(_loc4_ != null)
            {
               _loc5_ = 0;
               _loc6_ = _loc4_.numSurfaces;
               while(_loc5_ < _loc6_)
               {
                  _loc7_ = _loc4_.getSurface(_loc5_).material as StandardMaterial;
                  if(_loc7_ != null)
                  {
                     _loc7_.alpha = this._alpha;
                     _loc7_.transparentPass = this._alpha < 1;
                     _loc7_.alphaThreshold = this._alpha < 1 ? 0.9 : 0;
                     _loc7_.opaquePass = true;
                  }
                  _loc5_++;
               }
            }
            _loc2_++;
         }
      }
      
      public function get targetForward() : Vector3D
      {
         return this._targetForward;
      }
      
      public function set targetForward(param1:Vector3D) : void
      {
         this._targetForward = param1;
      }
   }
}

