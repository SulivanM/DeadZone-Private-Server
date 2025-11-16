package thelaststand.app.game.gui.iteminfo
{
   import com.exileetiquette.math.MathUtils;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   import thelaststand.app.game.data.AttireData;
   import thelaststand.app.game.data.ClothingAccessory;
   import thelaststand.app.game.data.Gender;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.gui.survivor.UISurvivorModelView;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.common.resources.ResourceManager;
   
   public class UIClothingItemTooltipPreview extends UIComponent
   {
      
      private static var _survivor:Survivor;
      
      private const _timerLength:int = 10000;
      
      private const _timerHeight:int = 2;
      
      private const _timerColor:uint = 16777215;
      
      private const _border:int = 1;
      
      private var _item:ClothingAccessory;
      
      private var _width:int = 148;
      
      private var _height:int = 230;
      
      private var _genderTimer:Timer;
      
      private var _timerStart:Number = 0;
      
      private var ui_model:UISurvivorModelView;
      
      private var ui_timerBar:Sprite;
      
      public function UIClothingItemTooltipPreview()
      {
         super();
         if(_survivor == null)
         {
            _survivor = new Survivor();
         }
         this._genderTimer = new Timer(this._timerLength);
         this._genderTimer.addEventListener(TimerEvent.TIMER,this.onGenderTimerTick,false,0,true);
         this.ui_model = new UISurvivorModelView(this._width,height);
         this.ui_model.survivor = _survivor;
         addChild(this.ui_model);
         this.ui_timerBar = new Sprite();
         addChild(this.ui_timerBar);
         addEventListener(Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      private static function setPreviewSurvivorGender(param1:String) : void
      {
         var attireXML:XML = null;
         var hair:String = null;
         var lowerNode:XML = null;
         var skinNode:XML = null;
         var hairNode:XML = null;
         var gender:String = param1;
         attireXML = ResourceManager.getInstance().get("xml/attire.xml");
         hair = gender == Gender.MALE ? "hair3" : "hair1";
         var upperNode:XML = attireXML.item.(@id == "tshirt" && @type == "upper")[0];
         lowerNode = attireXML.item.(@id == "pants" && @type == "lower")[0];
         skinNode = attireXML.item.(@id == "mid1" && @type == "skin")[0];
         hairNode = attireXML.item.(@id == hair && @type == "hair")[0];
         _survivor.gender = gender;
         _survivor.appearance.upperBody.parseXML(upperNode,gender);
         _survivor.appearance.lowerBody.parseXML(lowerNode,gender);
         _survivor.appearance.skin.parseXML(skinNode,gender);
         _survivor.appearance.hair.parseXML(hairNode,gender);
         _survivor.appearance.hairColor = "darkBrown";
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.ui_model.loadCompleted.remove(this.onModelLoadCompleted);
         this.ui_model.dispose();
         this._genderTimer.stop();
         this._item = null;
      }
      
      public function setItem(param1:ClothingAccessory) : void
      {
         var _loc3_:Vector.<AttireData> = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         this._item = param1;
         var _loc2_:String = Math.random() < 0.5 ? Gender.FEMALE : Gender.MALE;
         setPreviewSurvivorGender(_loc2_);
         this.ui_model.appearance = _survivor.appearance.clone();
         this.ui_model.appearance.clearAccessories();
         if(this._item != null)
         {
            _loc3_ = this._item.getAttireList(_survivor.gender);
            _loc4_ = 0;
            _loc5_ = int(_loc3_.length);
            while(_loc4_ < _loc5_)
            {
               this.ui_model.appearance.addAccessory(_loc3_[_loc4_]);
               _loc4_++;
            }
         }
         this.ui_model.loadCompleted.remove(this.onModelLoadCompleted);
         this.ui_model.loadCompleted.add(this.onModelLoadCompleted);
         this.ui_model.update();
         invalidate();
      }
      
      override protected function draw() : void
      {
         graphics.clear();
         graphics.beginFill(6642514);
         graphics.drawRect(0,0,this._width,this._height);
         graphics.endFill();
         graphics.beginFill(2565926);
         graphics.drawRect(this._border,this._border,this._width - this._border * 2,this._height - this._border * 2);
         graphics.endFill();
         this.ui_model.x = this._border;
         this.ui_model.y = this._border;
         this.ui_model.height = this._height - this._border * 2;
         this.ui_model.width = this._width - this._border * 2;
         this.ui_model.actorMesh.scaleX = this.ui_model.actorMesh.scaleY = this.ui_model.actorMesh.scaleZ = 1;
         this.ui_model.actorMesh.rotationY = 0;
         this.ui_model.modelOffset.y = 15;
         this.ui_model.allowRotation = false;
         this.ui_model.updateCamera();
         this.ui_timerBar.x = this._border;
         this.ui_timerBar.y = this._height - this._border - this._timerHeight;
         this.drawTimerBar();
      }
      
      private function drawTimerBar() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         this.ui_timerBar.graphics.clear();
         if(this._genderTimer.running)
         {
            _loc1_ = getTimer() - this._timerStart;
            _loc2_ = MathUtils.clamp01(_loc1_ / this._timerLength);
            _loc3_ = this._width - this._border * 2;
            _loc4_ = int(_loc3_ * _loc2_);
            this.ui_timerBar.graphics.beginFill(this._timerColor,1);
            this.ui_timerBar.graphics.drawRect(0,0,_loc4_,this._timerHeight);
            this.ui_timerBar.graphics.endFill();
            _loc5_ = this._timerLength * 0.75;
            _loc6_ = this._timerLength - _loc5_;
            _loc7_ = MathUtils.clamp01((_loc1_ - _loc6_) / (_loc5_ - _loc6_));
            this.ui_model.actorMesh.rotationY = this.ui_model.modelRotation + _loc7_ * Math.PI * 2;
         }
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         this.drawTimerBar();
      }
      
      private function onGenderTimerTick(param1:TimerEvent) : void
      {
         var _loc3_:Vector.<AttireData> = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc2_:String = _survivor.gender == Gender.MALE ? Gender.FEMALE : Gender.MALE;
         setPreviewSurvivorGender(_loc2_);
         this.ui_model.appearance = _survivor.appearance.clone();
         if(this._item != null)
         {
            _loc3_ = this._item.getAttireList(_survivor.gender);
            _loc4_ = 0;
            _loc5_ = int(_loc3_.length);
            while(_loc4_ < _loc5_)
            {
               this.ui_model.appearance.addAccessory(_loc3_[_loc4_]);
               _loc4_++;
            }
         }
         this.ui_model.update();
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         this._genderTimer.stop();
         this._genderTimer.reset();
      }
      
      private function onModelLoadCompleted() : void
      {
         if(stage != null)
         {
            this._genderTimer.reset();
            this._genderTimer.start();
            this._timerStart = getTimer();
         }
      }
   }
}

