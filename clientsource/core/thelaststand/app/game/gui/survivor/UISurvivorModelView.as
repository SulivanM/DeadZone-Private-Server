package thelaststand.app.game.gui.survivor
{
   import alternativa.engine3d.core.Object3D;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import org.osflash.signals.Signal;
   import thelaststand.app.display.ModelView;
   import thelaststand.app.display.actor.StandAloneActorMesh;
   import thelaststand.app.game.data.HumanAppearance;
   import thelaststand.app.game.data.IActorAppearance;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorLoadout;
   import thelaststand.app.game.data.Weapon;
   import thelaststand.app.gui.UIBusySpinner;
   import thelaststand.common.resources.AssetLoader;
   import thelaststand.common.resources.ResourceManager;
   import thelaststand.engine.animation.AnimationTable;
   
   public class UISurvivorModelView extends Sprite
   {
      
      private var _width:int;
      
      private var _height:int;
      
      private var _actorMesh:StandAloneActorMesh;
      
      private var _invalid:Boolean;
      
      private var _showWeapon:*;
      
      private var _showInjured:Boolean;
      
      private var _survivor:Survivor;
      
      private var _modelLoader:AssetLoader;
      
      private var _modelRotation:Number;
      
      private var _modelOffset:Vector3D = new Vector3D();
      
      private var _modelDragging:Boolean;
      
      private var _modelDragPt:Point;
      
      private var _animation:String;
      
      private var _cameraPosition:Vector3D;
      
      private var _appearance:HumanAppearance;
      
      private var _allowRotation:Boolean = true;
      
      private var bmp_modelBackground:Bitmap;
      
      private var mc_modelView:ModelView;
      
      private var mc_loadingModel:UIBusySpinner;
      
      public var loadCompleted:Signal = new Signal();
      
      public function UISurvivorModelView(param1:int, param2:int, param3:BitmapData = null)
      {
         super();
         this._actorMesh = new StandAloneActorMesh();
         this._modelDragPt = new Point();
         this._modelRotation = -30 * Math.PI / 180;
         this._modelLoader = new AssetLoader();
         this._modelLoader.loadingCompleted.add(this.onModelAssetsLoaded);
         this._cameraPosition = new Vector3D(0,-20,-100);
         this.bmp_modelBackground = new Bitmap(param3 || new BmpSurvivorDisplayBackground());
         addChildAt(this.bmp_modelBackground,0);
         this.mc_loadingModel = new UIBusySpinner();
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         this.setSize(param1,param2);
      }
      
      public function dispose() : void
      {
         removeEventListener(Event.ENTER_FRAME,this.checkViewReady);
         if(parent)
         {
            parent.removeChild(this);
         }
         this.mc_loadingModel.dispose();
         this.mc_loadingModel = null;
         this.mc_modelView.dispose();
         this.mc_modelView = null;
         this._appearance = null;
         this._actorMesh.dispose();
         this._actorMesh = null;
         this._modelLoader.loadingCompleted.remove(this.onModelAssetsLoaded);
         this._modelLoader.dispose();
         this._modelLoader = null;
         this.bmp_modelBackground.bitmapData.dispose();
         this.bmp_modelBackground.bitmapData = null;
         this.bmp_modelBackground = null;
         this._cameraPosition = null;
         this.loadCompleted.removeAll();
      }
      
      public function update() : void
      {
         this._invalid = true;
      }
      
      public function showLoader() : void
      {
         this.mc_loadingModel.x = int(this._width * 0.5);
         this.mc_loadingModel.y = int(this._height * 0.5);
         this.mc_loadingModel.scaleX = this.mc_loadingModel.scaleY = 1.75;
         this.mc_loadingModel.alpha = 0.75;
         addChild(this.mc_loadingModel);
      }
      
      public function hideLoader() : void
      {
         if(this.mc_loadingModel.parent != null)
         {
            this.mc_loadingModel.parent.removeChild(this.mc_loadingModel);
         }
      }
      
      public function updateCamera() : void
      {
         if(this.mc_modelView != null)
         {
            this.mc_modelView.camera.x = this._cameraPosition.x;
            this.mc_modelView.camera.y = this._cameraPosition.y;
            this.mc_modelView.camera.z = this._cameraPosition.z;
         }
      }
      
      private function updateModel() : void
      {
         var _loc3_:XML = null;
         var _loc4_:String = null;
         removeEventListener(Event.ENTER_FRAME,this.checkViewReady);
         this._invalid = false;
         this._actorMesh.clear();
         if(this.mc_modelView != null)
         {
            this.mc_modelView.clear();
         }
         if(this._survivor == null)
         {
            return;
         }
         var _loc1_:SurvivorLoadout = this._showWeapon == SurvivorLoadout.TYPE_DEFENCE ? this._survivor.loadoutDefence : this._survivor.loadoutOffence;
         var _loc2_:Array = this._appearance != null ? this._appearance.getResourceURIs() : this._survivor.appearance.getResourceURIs();
         _loc2_.push("models/characters/shadow.png");
         if(this._showWeapon && _loc1_.weapon.item != null)
         {
            _loc3_ = _loc1_.weapon.item.xml;
            _loc4_ = _loc3_.weap.anim.toString();
            _loc2_.push("models/anim/human-weapons-" + _loc4_ + ".anim");
            _loc2_.push(_loc3_.mdl.@uri.toString());
         }
         else
         {
            _loc2_.push("models/anim/human.anim");
         }
         this.showLoader();
         this._modelLoader.clear(true);
         this._modelLoader.loadAssets(_loc2_);
      }
      
      private function setSize(param1:int, param2:int) : void
      {
         this._width = param1;
         this._height = param2;
         scaleX = scaleY = 1;
         if(this.mc_modelView != null)
         {
            this.mc_modelView.width = this._width;
            this.mc_modelView.height = this._height;
         }
         this.mc_loadingModel.x = int(this._width * 0.5);
         this.mc_loadingModel.y = int(this._height * 0.5);
         this.bmp_modelBackground.scaleX = this.bmp_modelBackground.scaleY = 1;
         this.bmp_modelBackground.width = Math.min(this._width,this.bmp_modelBackground.width);
         this.bmp_modelBackground.height = Math.min(this._height,this.bmp_modelBackground.height);
         this.bmp_modelBackground.x = int((this._width - this.bmp_modelBackground.width) * 0.5);
         this.bmp_modelBackground.y = int((this._height - this.bmp_modelBackground.height) * 0.5);
      }
      
      private function checkViewReady(param1:Event = null) : void
      {
         this.mc_modelView.addObject(this._actorMesh);
         this.hideLoader();
         removeEventListener(Event.ENTER_FRAME,this.checkViewReady);
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         if(this.mc_modelView == null)
         {
            this.mc_modelView = new ModelView(stage.stage3Ds[1],this._width,this._height,0);
            addChildAt(this.mc_modelView,getChildIndex(this.bmp_modelBackground) + 1);
            this.mc_modelView.viewport.antiAlias = 4;
            this.mc_modelView.camera.x = this._cameraPosition.x;
            this.mc_modelView.camera.y = this._cameraPosition.y;
            this.mc_modelView.camera.z = this._cameraPosition.z;
            this.mc_modelView.camera.rotationX = -15 * Math.PI / 180;
            this.mc_modelView.camera.orthographic = true;
            this.mc_modelView.directionalLight.x = -100;
            this.mc_modelView.directionalLight.y = -100;
            this.mc_modelView.directionalLight.lookAt(0,0,0);
            this.mc_modelView.renderStarted.add(this.onModelRender);
            this.updateModel();
            this.mc_modelView.addEventListener(MouseEvent.MOUSE_DOWN,this.onModelMouseDown,false,0,true);
            this.mc_modelView.addEventListener(MouseEvent.MOUSE_UP,this.onModelMouseUp,false,0,true);
         }
      }
      
      private function onModelRender() : void
      {
         var _loc1_:Number = NaN;
         if(this._invalid)
         {
            this.updateModel();
         }
         if(this._actorMesh != null)
         {
            if(this._modelDragging)
            {
               _loc1_ = this._modelDragPt.x - this.mc_modelView.mouseX;
               this._modelRotation += _loc1_ * 0.025;
               this._modelDragPt.x = this.mc_modelView.mouseX;
            }
            if(this._allowRotation)
            {
               this._actorMesh.rotationY += (this._modelRotation - this._actorMesh.rotationY) / 6;
            }
            this._actorMesh.update();
         }
      }
      
      private function onModelAssetsLoaded() : void
      {
         var _loc1_:AnimationTable = null;
         var _loc3_:XML = null;
         var _loc4_:String = null;
         var _loc5_:Vector.<String> = null;
         var _loc6_:Object3D = null;
         var _loc7_:int = 0;
         var _loc8_:Object3D = null;
         var _loc9_:Array = null;
         var _loc10_:String = null;
         this._actorMesh.addShadow();
         this._actorMesh.setAppearance(this._appearance || this._survivor.appearance);
         var _loc2_:SurvivorLoadout = this._showWeapon == SurvivorLoadout.TYPE_DEFENCE ? this._survivor.loadoutDefence : this._survivor.loadoutOffence;
         if(this._animation == null && this._showWeapon && _loc2_.weapon.item != null)
         {
            _loc3_ = _loc2_.weapon.item.xml;
            _loc4_ = _loc3_.weap.anim.toString();
            _loc1_ = ResourceManager.getInstance().animations.getAnimationTable("models/anim/human-weapons-" + _loc4_ + ".anim");
            _loc5_ = Vector.<String>(["muzzleflash_nl"]);
            _loc6_ = this._actorMesh.addMesh(_loc3_.mdl.@uri.toString(),false,_loc5_);
            this._actorMesh.addAnimation("idle",_loc1_.getAnimationByName(_loc4_ + "-idle-standing"));
            _loc7_ = 0;
            while(_loc7_ < _loc6_.numChildren)
            {
               _loc8_ = _loc6_.getChildAt(_loc7_);
               if(_loc8_.name != null)
               {
                  _loc9_ = _loc8_.name.split("_");
                  if(_loc9_[0] == "att" && !Weapon(_loc2_.weapon.item).hasAttachment(_loc9_[1]))
                  {
                     _loc8_.visible = false;
                  }
               }
               _loc7_++;
            }
            this._actorMesh.setAnimation("idle",true,0.03);
         }
         else
         {
            _loc1_ = ResourceManager.getInstance().animations.getAnimationTable("models/anim/human.anim");
            _loc10_ = this._animation == null ? "idle" : this._animation;
            this._actorMesh.addAnimation("idle",_loc1_.getAnimationByName(_loc10_));
            this._actorMesh.setAnimation("idle",true,1);
         }
         this._actorMesh.rotationY = this._modelRotation;
         this._actorMesh.x = this._modelOffset.x;
         this._actorMesh.y = this._modelOffset.y + 90;
         this._actorMesh.z = this._modelOffset.z;
         addEventListener(Event.ENTER_FRAME,this.checkViewReady,false,0,true);
         this.loadCompleted.dispatch();
      }
      
      private function onModelMouseDown(param1:MouseEvent) : void
      {
         if(!mouseEnabled)
         {
            return;
         }
         this._modelDragging = true;
         this._modelDragPt.x = this.mc_modelView.mouseX;
         this._modelDragPt.y = this.mc_modelView.mouseY;
         stage.addEventListener(MouseEvent.MOUSE_UP,this.onModelMouseUp,false,0,true);
      }
      
      private function onModelMouseUp(param1:MouseEvent) : void
      {
         stage.removeEventListener(MouseEvent.MOUSE_UP,this.onModelMouseUp);
         this._modelDragging = false;
      }
      
      public function get actorMesh() : StandAloneActorMesh
      {
         return this._actorMesh;
      }
      
      public function get cameraPosition() : Vector3D
      {
         return this._cameraPosition;
      }
      
      public function set cameraPosition(param1:Vector3D) : void
      {
         this._cameraPosition = param1;
         this.updateCamera();
      }
      
      public function get appearance() : HumanAppearance
      {
         return this._appearance;
      }
      
      public function set appearance(param1:HumanAppearance) : void
      {
         this._appearance = param1;
         if(stage != null && this.mc_modelView != null)
         {
            this._invalid = true;
         }
      }
      
      public function get survivor() : Survivor
      {
         return this._survivor;
      }
      
      public function set survivor(param1:Survivor) : void
      {
         this._survivor = param1;
         if(stage != null && this.mc_modelView != null)
         {
            this._invalid = true;
         }
      }
      
      public function get animation() : String
      {
         return this._animation;
      }
      
      public function set animation(param1:String) : void
      {
         this._animation = param1;
      }
      
      public function get showWeapon() : *
      {
         return this._showWeapon;
      }
      
      public function set showWeapon(param1:*) : void
      {
         this._showWeapon = param1;
         this._invalid = true;
      }
      
      public function get showInjured() : Boolean
      {
         return this._showInjured;
      }
      
      public function set showInjured(param1:Boolean) : void
      {
         this._showInjured = param1;
         this._invalid = true;
      }
      
      public function get modelRotation() : Number
      {
         return this._modelRotation;
      }
      
      public function get allowRotation() : Boolean
      {
         return this._allowRotation;
      }
      
      public function set allowRotation(param1:Boolean) : void
      {
         this._allowRotation = param1;
      }
      
      public function get modelOffset() : Vector3D
      {
         return this._modelOffset;
      }
      
      public function set modelOffset(param1:Vector3D) : void
      {
         this._modelOffset = param1;
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
         this.setSize(param1,this._height);
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
         this.setSize(this._width,param1);
      }
   }
}

