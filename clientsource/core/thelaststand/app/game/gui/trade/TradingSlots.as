package thelaststand.app.game.gui.trade
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import org.osflash.signals.Signal;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.GameResources;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.gui.UIItemInfo;
   import thelaststand.app.game.gui.lists.UIInventoryListItem;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.network.Network;
   
   public class TradingSlots extends Sprite
   {
      
      private var nameBG:Shape;
      
      private var txt_name:BodyTextField;
      
      private var stripes:Bitmap;
      
      private var slots:Vector.<UIInventoryListItem>;
      
      private var highlights:Vector.<Shape>;
      
      private var _accepted:Boolean = false;
      
      private var _faded:Boolean = false;
      
      public var onSlotClicked:Signal;
      
      public var onUnlockFreeSlots:Signal;
      
      private var itemInfo:UIItemInfo;
      
      private var _isRemoteSlots:Boolean;
      
      private var lock0:Bitmap;
      
      private var lock1:Bitmap;
      
      private var btn_unlock:PushButton;
      
      private var _freeSlotsUnlocked:Boolean;
      
      public function TradingSlots(param1:String, param2:Boolean = false)
      {
         var _loc6_:UIInventoryListItem = null;
         var _loc7_:Shape = null;
         this.onSlotClicked = new Signal(int);
         this.onUnlockFreeSlots = new Signal();
         super();
         this._isRemoteSlots = param2;
         this.nameBG = new Shape();
         this.nameBG.graphics.beginFill(6949900,1);
         this.nameBG.graphics.drawRect(0,0,169,25);
         addChild(this.nameBG);
         this.txt_name = new BodyTextField({
            "width":this.nameBG.width,
            "size":14,
            "autoSize":TextFieldAutoSize.NONE,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         var _loc3_:TextFormat = this.txt_name.getTextFormat();
         _loc3_.align = TextFormatAlign.CENTER;
         this.txt_name.defaultTextFormat = _loc3_;
         this.txt_name.text = param1;
         this.txt_name.y = int((this.nameBG.height - this.txt_name.height) * 0.5);
         addChild(this.txt_name);
         this.stripes = new Bitmap(new BmpTradeGreenHazard());
         this.stripes.x = 0;
         this.stripes.y = 30;
         addChild(this.stripes);
         TweenMax.to(this.stripes,0,{"colorMatrixFilter":{"saturation":0}});
         this.itemInfo = new UIItemInfo();
         if(this._isRemoteSlots)
         {
            this.itemInfo.opened.add(this.onItemInfoOpened);
         }
         var _loc4_:Number = this.stripes.y + 6;
         this.slots = new Vector.<UIInventoryListItem>(6);
         this.highlights = new Vector.<Shape>(6);
         var _loc5_:int = 0;
         while(_loc5_ < this.slots.length)
         {
            _loc6_ = new UIInventoryListItem(65);
            this.slots[_loc5_] = _loc6_;
            _loc6_.x = _loc5_ % 2 == 0 ? 12 : 87;
            _loc6_.y = _loc4_;
            addChild(_loc6_);
            _loc6_.clicked.add(this.handleItemClicked);
            _loc6_.displayRollOver = !this._isRemoteSlots;
            this.itemInfo.addRolloverTarget(_loc6_);
            _loc6_.mouseOver.add(this.onItemOver);
            if(_loc5_ % 2 == 1)
            {
               _loc4_ += 65;
               _loc4_ = _loc4_ + (_loc5_ == 1 ? 12 : 10);
            }
            _loc7_ = new Shape();
            _loc7_.graphics.beginFill(16759296,1);
            _loc7_.graphics.drawRect(-2,-2,_loc6_.width + 4,_loc6_.height + 4);
            _loc7_.graphics.drawRect(0,0,_loc6_.width,_loc6_.height);
            _loc7_.graphics.endFill();
            _loc7_.graphics.beginFill(16759296,0.3);
            _loc7_.graphics.drawRect(0,0,_loc6_.width,_loc6_.height);
            _loc7_.graphics.endFill();
            _loc7_.x = _loc6_.x;
            _loc7_.y = _loc6_.y;
            _loc7_.visible = false;
            addChild(_loc7_);
            this.highlights[_loc5_] = _loc7_;
            _loc5_++;
         }
         this.btn_unlock = new PushButton("",new UnlockBtnIcon());
         this.btn_unlock.width = 150;
         this.btn_unlock.height = 46;
         this.btn_unlock.x = this.slots[0].x + (this.slots[1].x + this.slots[1].width - this.slots[0].x - this.btn_unlock.width) * 0.5;
         this.btn_unlock.y = this.slots[0].y + (this.slots[1].y + this.slots[1].height - this.slots[0].y - this.btn_unlock.height) * 0.5;
         if(param2 == false)
         {
            addChild(this.btn_unlock);
         }
         this.btn_unlock.clicked.add(this.unlockCliked);
         this.lock0 = new Bitmap(new BmpIconItemLocked());
         this.lock0.x = int(this.slots[0].x + (this.slots[0].width - this.lock0.width) * 0.5);
         this.lock0.y = int(this.slots[0].y + (this.slots[0].height - this.lock0.height) * 0.5);
         if(!this.btn_unlock.parent)
         {
            addChild(this.lock0);
         }
         this.slots[0].enabled = false;
         this.lock1 = new Bitmap(new BmpIconItemLocked());
         this.lock1.x = int(this.slots[1].x + (this.slots[1].width - this.lock1.width) * 0.5);
         this.lock1.y = int(this.slots[1].y + (this.slots[1].height - this.lock1.height) * 0.5);
         if(!this.btn_unlock.parent)
         {
            addChild(this.lock1);
         }
         this.slots[1].enabled = false;
         this.accepted = false;
      }
      
      public function dispose() : void
      {
         var _loc1_:UIInventoryListItem = null;
         if(parent)
         {
            parent.removeChild(this);
         }
         this.txt_name.dispose();
         this.stripes.bitmapData.dispose();
         for each(_loc1_ in this.slots)
         {
            _loc1_.clicked.removeAll();
            _loc1_.dispose();
         }
         this.slots = null;
         this.onSlotClicked.removeAll();
         this.onUnlockFreeSlots.removeAll();
         this.itemInfo.dispose();
         this.lock0.bitmapData.dispose();
         this.lock1.bitmapData.dispose();
         UnlockBtnIcon(this.btn_unlock.icon).dispose();
         this.btn_unlock.dispose();
      }
      
      public function setItemAt(param1:int, param2:Item) : void
      {
         this.slots[param1].itemData = param2;
         if(this._isRemoteSlots && param2 != null)
         {
            this.slots[param1].forceNewIconDisplay(true);
            this.highlights[param1].visible = true;
         }
         if(this._isRemoteSlots && param2 && param2.category == "resource")
         {
            this.slots[param1].unequippable = param2.type != GameResources.CASH && Network.getInstance().playerData.compound.resources.getAvailableStorageCapacity(param2.type) <= param2.quantity;
         }
         else
         {
            this.slots[param1].unequippable = false;
         }
      }
      
      public function getItemAt(param1:int) : Item
      {
         return this.slots[param1] ? this.slots[param1].itemData : null;
      }
      
      public function disable() : void
      {
         var _loc2_:UIInventoryListItem = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.slots.length)
         {
            _loc2_ = this.slots[_loc1_];
            _loc2_.displayRollOver = false;
            _loc1_++;
         }
      }
      
      public function updateFreeSlotUpgrade(param1:Boolean) : void
      {
         this._freeSlotsUnlocked = param1;
         this.slots[0].enabled = this.slots[1].enabled = param1;
         this.lock0.visible = this.lock1.visible = !param1;
         this.slots[0].alpha = this.slots[1].alpha = this._isRemoteSlots && (this._faded || !param1) ? 0.3 : 1;
         this.btn_unlock.visible = !param1;
         TweenMax.to(this.stripes,0.5,{"colorMatrixFilter":{
            "saturation":(this._accepted || this._freeSlotsUnlocked ? 1 : 0),
            "remove":this._accepted
         }});
      }
      
      private function handleItemClicked(param1:MouseEvent) : void
      {
         var _loc2_:int = int(this.slots.indexOf(param1.target));
         this.onSlotClicked.dispatch(_loc2_);
      }
      
      private function onItemOver(param1:MouseEvent) : void
      {
         var _loc2_:UIInventoryListItem = UIInventoryListItem(param1.target);
         this.itemInfo.setItem(_loc2_.itemData,null,{
            "showResourceLimited":this._isRemoteSlots,
            "showAction":false
         });
      }
      
      private function unlockCliked(param1:MouseEvent) : void
      {
         this.onUnlockFreeSlots.dispatch();
      }
      
      private function onItemInfoOpened(param1:Item) : void
      {
         var _loc3_:UIInventoryListItem = null;
         if(param1 == null)
         {
            return;
         }
         var _loc2_:int = 0;
         while(_loc2_ < this.slots.length)
         {
            _loc3_ = this.slots[_loc2_];
            if(_loc3_.itemData == param1)
            {
               _loc3_.forceNewIconDisplay(false);
               this.highlights[_loc2_].visible = false;
               return;
            }
            _loc2_++;
         }
      }
      
      public function get accepted() : Boolean
      {
         return this._accepted;
      }
      
      public function set accepted(param1:Boolean) : void
      {
         var _loc2_:Number = stage ? 0.2 : 0;
         this._accepted = param1;
         TweenMax.to(this.stripes,_loc2_,{"colorMatrixFilter":{
            "saturation":(this._accepted || this._freeSlotsUnlocked ? 1 : 0),
            "remove":this._accepted
         }});
         TweenMax.to(this.nameBG,_loc2_,{"tint":(this._accepted ? 2703888 : 6949900)});
      }
      
      public function get faded() : Boolean
      {
         return this._faded;
      }
      
      public function set faded(param1:Boolean) : void
      {
         if(this._faded == param1)
         {
            return;
         }
         this._faded = param1;
         var _loc2_:int = 0;
         while(_loc2_ < this.slots.length)
         {
            if(!(_loc2_ < 2 && !this._freeSlotsUnlocked && this._faded == false))
            {
               this.slots[_loc2_].alpha = this._faded ? 0.3 : 1;
            }
            _loc2_++;
         }
      }
   }
}

import flash.display.Bitmap;
import flash.display.Sprite;
import thelaststand.app.display.BodyTextField;
import thelaststand.app.display.Effects;
import thelaststand.common.lang.Language;

class UnlockBtnIcon extends Sprite
{
   
   private var icon:Bitmap;
   
   private var txt_label:BodyTextField;
   
   public function UnlockBtnIcon()
   {
      super();
      this.icon = new Bitmap(new BmpIconUnlocked());
      addChild(this.icon);
      this.txt_label = new BodyTextField({
         "color":14408667,
         "size":13
      });
      this.txt_label.text = Language.getInstance().getString("trade.unlockSlots");
      this.txt_label.filters = [Effects.STROKE];
      addChild(this.txt_label);
      this.txt_label.x = this.icon.width + 5;
      this.txt_label.y = (this.icon.height - this.txt_label.height) * 0.5;
   }
   
   public function dispose() : void
   {
      this.icon.bitmapData.dispose();
      this.txt_label.dispose();
   }
}
