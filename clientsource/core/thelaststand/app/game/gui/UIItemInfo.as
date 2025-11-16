package thelaststand.app.game.gui
{
   import flash.display.BitmapData;
   import flash.display.InteractiveObject;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.utils.Timer;
   import org.osflash.signals.Signal;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.ClothingAccessory;
   import thelaststand.app.game.data.CrateItem;
   import thelaststand.app.game.data.EffectItem;
   import thelaststand.app.game.data.Gear;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemCounterType;
   import thelaststand.app.game.data.SchematicItem;
   import thelaststand.app.game.data.SurvivorLoadout;
   import thelaststand.app.game.data.Weapon;
   import thelaststand.app.game.gui.iteminfo.IUIItemInfo;
   import thelaststand.app.game.gui.iteminfo.UIClothingItemTooltipPreview;
   import thelaststand.app.game.gui.iteminfo.UIClothingPreviewLocation;
   import thelaststand.app.game.gui.iteminfo.UICraftKitInfo;
   import thelaststand.app.game.gui.iteminfo.UICrateInfo;
   import thelaststand.app.game.gui.iteminfo.UIEffectItemInfo;
   import thelaststand.app.game.gui.iteminfo.UIGearInfo;
   import thelaststand.app.game.gui.iteminfo.UIGenericItemInfo;
   import thelaststand.app.game.gui.iteminfo.UIItemInfoCounterPanel;
   import thelaststand.app.game.gui.iteminfo.UIItemTitle;
   import thelaststand.app.game.gui.iteminfo.UIResourceInfo;
   import thelaststand.app.game.gui.iteminfo.UISchematicInfo;
   import thelaststand.app.game.gui.iteminfo.UIUpgradeKitInfo;
   import thelaststand.app.game.gui.iteminfo.UIWeaponInfo;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.ResourceManager;
   
   public class UIItemInfo extends Sprite
   {
      
      public static var stage:Stage;
      
      private static const INNER_SHADOW:DropShadowFilter = new DropShadowFilter(0,0,0,1,8,8,5,1,true);
      
      private static const STROKE:GlowFilter = new GlowFilter(6905685,1,1.75,1.75,10,1);
      
      private static const DROP_SHADOW:DropShadowFilter = new DropShadowFilter(1,45,0,1,8,8,1,2);
      
      private static const BMP_TITLEBAR:BitmapData = new BmpTopBarBackground();
      
      public var opened:Signal;
      
      private var _padding:int = 10;
      
      private var _width:int = 264;
      
      private var _height:int;
      
      private var _item:Item;
      
      private var _isSpecialized:Boolean;
      
      private var _resources:ResourceManager;
      
      private var _lang:Language;
      
      private var _displayTarget:InteractiveObject;
      
      private var _rolloverTimer:Timer;
      
      private var _rolloverTarget:InteractiveObject;
      
      private var _rolloverObjects:Vector.<InteractiveObject>;
      
      private var _displaySide:String;
      
      private var _loadout:SurvivorLoadout;
      
      private var _extraInfo:String;
      
      private var _useTimer:Boolean = true;
      
      private var _useCtrlKey:Boolean = false;
      
      private var _displayClothingPreview:Boolean = true;
      
      private var _clothingPreviewLocation:uint = 0;
      
      private var mc_background:Shape;
      
      private var txt_extra:BodyTextField;
      
      private var ui_info:IUIItemInfo;
      
      private var ui_title:UIItemTitle;
      
      private var ui_clothingPreview:UIClothingItemTooltipPreview;
      
      private var ui_counter:UIItemInfoCounterPanel;
      
      public function UIItemInfo()
      {
         super();
         mouseChildren = false;
         mouseEnabled = false;
         this.opened = new Signal(Item);
         this._resources = ResourceManager.getInstance();
         this._lang = Language.getInstance();
         this._rolloverObjects = new Vector.<InteractiveObject>();
         this._rolloverTimer = new Timer(100,1);
         this._rolloverTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onRolloverTimerComplete,false,0,true);
         this.mc_background = new Shape();
         this.mc_background.graphics.beginFill(1184274);
         this.mc_background.graphics.drawRect(0,0,10,10);
         this.mc_background.graphics.endFill();
         this.mc_background.filters = [INNER_SHADOW,STROKE,DROP_SHADOW];
         addChild(this.mc_background);
         this.ui_title = new UIItemTitle();
         addChild(this.ui_title);
         this.txt_extra = new BodyTextField({
            "color":Effects.COLOR_NEUTRAL,
            "size":14,
            "bold":true,
            "multiline":true,
            "leading":6
         });
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
      }
      
      public function dispose() : void
      {
         var _loc1_:InteractiveObject = null;
         if(parent)
         {
            parent.removeChild(this);
         }
         this._resources = null;
         this._lang = null;
         this._loadout = null;
         this._item = null;
         this._displayTarget = null;
         this._rolloverTarget = null;
         this._rolloverTimer.stop();
         for each(_loc1_ in this._rolloverObjects)
         {
            _loc1_.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverTarget);
            _loc1_.removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOutTarget);
            _loc1_.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownTarget);
         }
         this._rolloverObjects = null;
         this.ui_title.dispose();
         if(this.ui_info != null)
         {
            this.ui_info.dispose();
            this.ui_info = null;
         }
         if(this.ui_counter != null)
         {
            this.ui_counter.dispose();
         }
         this.opened.removeAll();
      }
      
      public function setItem(param1:Item, param2:SurvivorLoadout = null, param3:Object = null) : void
      {
         var _loc5_:Sprite = null;
         this._item = param1;
         this._loadout = param2;
         if(this.ui_info != null)
         {
            this.ui_info.dispose();
            this.ui_info = null;
         }
         if(this._item == null)
         {
            return;
         }
         var _loc4_:Item = this._item;
         if(param1.category == "resource")
         {
            this.ui_info = new UIResourceInfo();
         }
         else if(param1.category == "upgradekit")
         {
            this.ui_info = new UIUpgradeKitInfo();
         }
         else if(param1.category == "craftkit")
         {
            this.ui_info = new UICraftKitInfo();
         }
         else if(param1 is Weapon)
         {
            this.ui_info = new UIWeaponInfo();
         }
         else if(param1 is Gear)
         {
            this.ui_info = new UIGearInfo();
         }
         else if(param1 is CrateItem)
         {
            this.ui_info = new UICrateInfo();
         }
         else if(param1 is SchematicItem)
         {
            this.ui_info = new UISchematicInfo();
         }
         else if(param1 is EffectItem)
         {
            this.ui_info = new UIEffectItemInfo();
         }
         else
         {
            this.ui_info = new UIGenericItemInfo();
         }
         this.ui_info.setItem(_loc4_,param2,param3);
         _loc5_ = Sprite(this.ui_info);
         this._width = int(_loc5_.width + this._padding * 2);
         this.ui_title.width = int(this._width - this._padding * 2 + 8);
         this.ui_title.x = int((this._width - this.ui_title.width) * 0.5);
         this.ui_title.y = this.ui_title.x;
         this.ui_title.setItem(this._item,this._loadout,param3);
         _loc5_.x = this._padding;
         _loc5_.y = int(this.ui_title.y + this.ui_title.height + 8);
         addChild(_loc5_);
         this._height = int(_loc5_.y + _loc5_.height + this._padding);
         if(this._extraInfo != null)
         {
            this.txt_extra.htmlText = this._extraInfo;
            this.txt_extra.x = this._padding;
            this.txt_extra.y = int(_loc5_.y + _loc5_.height + 6);
            this.txt_extra.width = int(this._width - this.txt_extra.x * 2);
            addChild(this.txt_extra);
            this._height = int(this.txt_extra.y + this.txt_extra.height + this._padding);
         }
         else if(this.txt_extra.parent != null)
         {
            this.txt_extra.parent.removeChild(this.txt_extra);
         }
         if(param1.counterType != ItemCounterType.None)
         {
            this._height = this.drawCounter(param1.counterType,param1.counterValue,this._height);
         }
         else if(this.ui_counter != null)
         {
            if(this.ui_counter.parent != null)
            {
               this.ui_counter.parent.removeChild(this.ui_counter);
            }
         }
         this.mc_background.width = this._width;
         this.mc_background.height = this._height;
         if(this._item != null && this._item is ClothingAccessory)
         {
            if(this.ui_clothingPreview == null)
            {
               this.ui_clothingPreview = new UIClothingItemTooltipPreview();
            }
            this.ui_clothingPreview.setItem(this._item as ClothingAccessory);
         }
      }
      
      private function drawCounter(param1:uint, param2:int, param3:int) : int
      {
         if(param1 == ItemCounterType.None)
         {
            return param3;
         }
         if(this.ui_counter == null)
         {
            this.ui_counter = new UIItemInfoCounterPanel();
         }
         this.ui_counter.width = this._width - this._padding * 2;
         this.ui_counter.x = this._padding;
         this.ui_counter.y = param3;
         this.ui_counter.setContent(param1,param2);
         addChild(this.ui_counter);
         return param3 + this.ui_counter.height + this._padding;
      }
      
      public function addRolloverTarget(param1:InteractiveObject) : void
      {
         param1.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverTarget,false,0,true);
         param1.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOutTarget,false,0,true);
         param1.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownTarget,false,0,true);
         this._rolloverObjects.push(param1);
      }
      
      public function removeRolloverTarget(param1:InteractiveObject) : void
      {
         param1.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverTarget);
         param1.removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOutTarget);
         param1.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownTarget);
         var _loc2_:int = int(this._rolloverObjects.indexOf(param1));
         if(_loc2_ > -1)
         {
            this._rolloverObjects.splice(_loc2_,1);
         }
      }
      
      public function hide() : void
      {
         this._displayTarget = null;
         this._rolloverTarget = null;
         this._rolloverTimer.stop();
         if(parent != null)
         {
            parent.removeChild(this);
         }
      }
      
      public function show(param1:InteractiveObject) : void
      {
         var _loc6_:Number = NaN;
         this._rolloverTimer.stop();
         if(this._item == null || UIItemInfo.stage == null || param1 == null || param1.parent == null || this._displayTarget == param1)
         {
            return;
         }
         this._displayTarget = param1;
         var _loc2_:int = 10;
         var _loc3_:int = 560;
         var _loc4_:Point = new Point(param1.x,param1.y + param1.height);
         _loc4_ = param1.parent.localToGlobal(_loc4_);
         this._displaySide = "bottom";
         var _loc5_:* = _loc4_.x > UIItemInfo.stage.stageWidth * 0.5;
         if(_loc5_)
         {
            _loc4_.x -= this._width - param1.width;
         }
         if(_loc4_.y + this._height >= _loc3_ - _loc2_)
         {
            _loc4_.y -= param1.height + this._height;
            this._displaySide = "top";
         }
         if(_loc4_.y < _loc2_)
         {
            _loc4_.x = _loc5_ ? param1.x - this._width : param1.x + param1.width;
            _loc4_.y = param1.y;
            _loc4_ = param1.parent.localToGlobal(_loc4_);
            this._displaySide = _loc5_ ? "left" : "right";
            _loc6_ = _loc4_.y + this._height - (_loc3_ - _loc2_);
            if(_loc6_ > 0)
            {
               _loc4_.y -= _loc6_;
            }
         }
         if(_loc4_.x < 0)
         {
            _loc4_.x = 0;
         }
         if(_loc4_.y < 0)
         {
            _loc4_.y = 0;
         }
         x = int(_loc4_.x);
         y = int(_loc4_.y);
         UIItemInfo.stage.addChild(this);
         this.opened.dispatch(this._item);
      }
      
      private function calcClothingPreviewAutoLocation() : uint
      {
         var _loc1_:Point = this.localToGlobal(new Point());
         if(_loc1_.x < stage.stageWidth / 2)
         {
            if(_loc1_.y < stage.stageHeight / 3)
            {
               return UIClothingPreviewLocation.RIGHT_TOP;
            }
            return UIClothingPreviewLocation.RIGHT_BOTTOM;
         }
         if(_loc1_.y < stage.stageHeight / 3)
         {
            return UIClothingPreviewLocation.LEFT_TOP;
         }
         return UIClothingPreviewLocation.LEFT_BOTTOM;
      }
      
      private function updateClothingPreviewLocation(param1:uint) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 4;
         switch(param1)
         {
            case UIClothingPreviewLocation.AUTO:
               this.updateClothingPreviewLocation(this.calcClothingPreviewAutoLocation());
               break;
            case UIClothingPreviewLocation.LEFT_TOP:
               this.ui_clothingPreview.x = -(this.ui_clothingPreview.width + _loc4_);
               this.ui_clothingPreview.y = -1;
               break;
            case UIClothingPreviewLocation.LEFT_BOTTOM:
               this.ui_clothingPreview.x = -(this.ui_clothingPreview.width + _loc4_);
               this.ui_clothingPreview.y = -(this.ui_clothingPreview.height - this._height);
               break;
            case UIClothingPreviewLocation.RIGHT_BOTTOM:
               this.ui_clothingPreview.x = this._width + _loc4_;
               this.ui_clothingPreview.y = -(this.ui_clothingPreview.height - this._height);
               break;
            case UIClothingPreviewLocation.RIGHT_TOP:
               this.ui_clothingPreview.x = this._width + _loc4_;
               this.ui_clothingPreview.y = -1;
               break;
            case UIClothingPreviewLocation.TOP_LEFT:
               this.ui_clothingPreview.x = 0;
               this.ui_clothingPreview.y = -(this.ui_clothingPreview.height + _loc4_);
               break;
            case UIClothingPreviewLocation.TOP_RIGHT:
               this.ui_clothingPreview.x = this._width - this.ui_clothingPreview.width;
               this.ui_clothingPreview.y = -(this.ui_clothingPreview.height + _loc4_);
               break;
            case UIClothingPreviewLocation.BOTTOM_LEFT:
               this.ui_clothingPreview.x = 0;
               this.ui_clothingPreview.y = this._height + _loc4_;
               break;
            case UIClothingPreviewLocation.BOTTOM_RIGHT:
               this.ui_clothingPreview.x = this._width - this.ui_clothingPreview.width;
               this.ui_clothingPreview.y = this._height + _loc4_;
         }
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         Audio.sound.play("sound/interface/int-over.mp3");
         if(this._displayClothingPreview && this._item != null && this._item.category == "clothing")
         {
            addChild(this.ui_clothingPreview);
            this.updateClothingPreviewLocation(this._clothingPreviewLocation);
         }
         else if(this.ui_clothingPreview != null && this.ui_clothingPreview.parent != null)
         {
            this.ui_clothingPreview.parent.removeChild(this.ui_clothingPreview);
         }
      }
      
      private function onMouseOverTarget(param1:MouseEvent) : void
      {
         this._rolloverTarget = param1.currentTarget as InteractiveObject;
         if(this._useCtrlKey && !param1.ctrlKey)
         {
            return;
         }
         if(this._useTimer)
         {
            this._rolloverTimer.reset();
            this._rolloverTimer.start();
         }
         else
         {
            this.show(this._rolloverTarget);
         }
      }
      
      private function onMouseOutTarget(param1:MouseEvent) : void
      {
         this.hide();
      }
      
      private function onMouseDownTarget(param1:MouseEvent) : void
      {
         this.hide();
      }
      
      private function onRolloverTimerComplete(param1:TimerEvent) : void
      {
         this.show(this._rolloverTarget);
      }
      
      public function get displaySide() : String
      {
         return this._displaySide;
      }
      
      public function get item() : Item
      {
         return this._item;
      }
      
      public function get extraInfo() : String
      {
         return this._extraInfo;
      }
      
      public function set extraInfo(param1:String) : void
      {
         this._extraInfo = param1;
      }
      
      public function get useTimer() : Boolean
      {
         return this._useTimer;
      }
      
      public function set useTimer(param1:Boolean) : void
      {
         this._useTimer = param1;
      }
      
      public function get useCtrlKey() : Boolean
      {
         return this._useCtrlKey;
      }
      
      public function set useCtrlKey(param1:Boolean) : void
      {
         this._useCtrlKey = param1;
      }
      
      public function get displayClothingPreview() : Boolean
      {
         return this._displayClothingPreview;
      }
      
      public function set displayClothingPreview(param1:Boolean) : void
      {
         this._displayClothingPreview = param1;
      }
      
      public function get clothingPreviewLocation() : uint
      {
         return this._clothingPreviewLocation;
      }
      
      public function set clothingPreviewLocation(param1:uint) : void
      {
         this._clothingPreviewLocation = param1;
      }
      
      override public function get width() : Number
      {
         return this.mc_background.width;
      }
      
      override public function set width(param1:Number) : void
      {
      }
      
      override public function get height() : Number
      {
         return this.mc_background.height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
   }
}

import flash.display.Sprite;
import thelaststand.app.display.BodyTextField;

class ItemDetails extends Sprite
{
   
   private var _ty:int;
   
   private var _rowCount:int = 0;
   
   private var _rowColor:uint = 2763563;
   
   private var _rowHeight:int = 20;
   
   private var _width:int;
   
   public function ItemDetails(param1:int)
   {
      super();
      this._width = param1;
      mouseEnabled = mouseChildren = false;
   }
   
   public function addRow(param1:String, param2:*, param3:uint) : void
   {
      if(this._rowCount % 2 == 0)
      {
         graphics.beginFill(this._rowColor);
         graphics.drawRect(0,this._ty,this._width,this._rowHeight);
         graphics.endFill();
      }
      var _loc4_:BodyTextField = new BodyTextField({
         "color":param3,
         "size":14
      });
      _loc4_.text = param1;
      _loc4_.x = 2;
      _loc4_.y = this._ty - 1;
      addChild(_loc4_);
      var _loc5_:BodyTextField = new BodyTextField({
         "color":param3,
         "size":14
      });
      _loc5_.text = String(param2);
      _loc5_.x = int(this._width - _loc5_.width - 2);
      _loc5_.y = _loc4_.y;
      addChild(_loc5_);
      ++this._rowCount;
      this._ty += this._rowHeight;
   }
   
   public function dispose() : void
   {
      if(parent != null)
      {
         parent.removeChild(this);
      }
      var _loc1_:int = numChildren - 1;
      while(_loc1_ >= 0)
      {
         removeChildAt(_loc1_);
         _loc1_--;
      }
   }
   
   override public function get width() : Number
   {
      return this._width;
   }
   
   override public function set width(param1:Number) : void
   {
   }
   
   override public function get height() : Number
   {
      return this._ty;
   }
   
   override public function set height(param1:Number) : void
   {
   }
}
