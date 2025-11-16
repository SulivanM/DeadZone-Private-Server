package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.data.NavigationLocation;
   import thelaststand.app.game.data.EffectCollection;
   import thelaststand.app.game.data.EffectItem;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.TimerData;
   import thelaststand.app.game.data.effects.CooldownType;
   import thelaststand.app.game.data.effects.Effect;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.game.data.store.StoreItem;
   import thelaststand.app.game.gui.header.UIEffectSlot;
   import thelaststand.app.game.gui.lists.UIInventoryList;
   import thelaststand.app.game.gui.lists.UIInventoryListItem;
   import thelaststand.app.game.logic.TimerManager;
   import thelaststand.app.gui.UIPagination;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class EffectItemListDialogue extends BaseDialogue
   {
      
      private static var _promoData:Array;
      
      private var _itemList:Vector.<Item>;
      
      private var _showNoneItem:Boolean;
      
      private var _lang:Language;
      
      private var _slot:UIEffectSlot;
      
      private var _effectList:EffectCollection;
      
      private var _gameLocation:String;
      
      private var _network:Network;
      
      private var mc_container:Sprite;
      
      private var ui_list:UIInventoryList;
      
      private var ui_page:UIPagination;
      
      private var ui_promo:SalePanel;
      
      public var selected:Signal;
      
      public function EffectItemListDialogue(param1:UIEffectSlot, param2:EffectCollection, param3:Vector.<Item>, param4:String)
      {
         var title:String;
         var ty:int;
         var options:ItemListOptions;
         var slot:UIEffectSlot = param1;
         var effectList:EffectCollection = param2;
         var itemList:Vector.<Item> = param3;
         var gameLocation:String = param4;
         this.mc_container = new Sprite();
         super("effect-item-list-dialogue",this.mc_container,true);
         _autoSize = false;
         _width = 358;
         _height = 438;
         _padding = 20;
         this._lang = Language.getInstance();
         this._itemList = itemList;
         this._slot = slot;
         this._effectList = effectList;
         this._gameLocation = gameLocation;
         this.selected = new Signal(Item);
         this._itemList = this._itemList.concat();
         this._itemList.unshift(null);
         title = this._lang.getString("select_effect_title-" + slot.group);
         if(!title || title == "?")
         {
            title = this._lang.getString("select_effect_title");
         }
         addTitle(title,4934477);
         ty = 0;
         if(!slot.group)
         {
            this.ui_promo = new SalePanel();
            this.ui_promo.x = -20;
            this.ui_promo.busy = true;
            this.ui_promo.clicked.add(this.onPromoClicked);
            this.mc_container.addChild(this.ui_promo);
            ty += this.ui_promo.height + 6;
         }
         options = new ItemListOptions();
         options.clothingPreviews = ClothingPreviewDisplayOptions.DISABLED;
         options.showEquippedIcons = true;
         options.showNewIcons = false;
         this.ui_list = new UIInventoryList(48,10,options);
         this.ui_list.y = ty;
         this.ui_list.width = 310;
         this.ui_list.height = 300;
         this.ui_list.itemList = this._itemList;
         this.ui_list.changed.add(this.onItemSelected);
         this.mc_container.addChild(this.ui_list);
         this.ui_page = new UIPagination(this.ui_list.numPages);
         this.ui_page.maxWidth = this.ui_list.width;
         this.ui_page.changed.add(this.onPageChanged);
         this.ui_page.x = int(this.ui_list.x + (this.ui_list.width - this.ui_page.width) * 0.5);
         this.ui_page.y = int(this.ui_list.y + this.ui_list.height + 10);
         this.mc_container.addChild(this.ui_page);
         _height = int(this.ui_page.y + this.ui_page.height + _padding * 2);
         this.updateDisabledStates();
         this.loadPromoData();
         TimerManager.getInstance().timerCompleted.add(this.onTimerCompleted);
         this._network = Network.getInstance();
         if(this._network.shutdownInEffect)
         {
            opened.addOnce(function(param1:Dialogue):void
            {
               onShutdownInEffectChange(true);
            });
         }
         else
         {
            this._network.onShutdownInEffectChange.add(this.onShutdownInEffectChange);
         }
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._lang = null;
         this._itemList = null;
         this._slot = null;
         this._effectList = null;
         this.selected.removeAll();
         this._network.onShutdownInEffectChange.remove(this.onShutdownInEffectChange);
         this._network = null;
         this.ui_list.dispose();
         this.ui_page.dispose();
         if(this.ui_promo != null)
         {
            this.ui_promo.dispose();
         }
         TimerManager.getInstance().timerCompleted.remove(this.onTimerCompleted);
      }
      
      public function selectItem(param1:Item, param2:Boolean = true) : void
      {
         if(param1 == null)
         {
            this.ui_list.selectItem(-1);
         }
         else
         {
            this.ui_list.selectItemById(param1.id.toUpperCase());
         }
         if(param2)
         {
            this.ui_list.gotoPage(this.ui_list.getSelectedItemPage());
            this.ui_page.currentPage = this.ui_list.currentPage;
         }
      }
      
      override public function open() : void
      {
         var _loc1_:EffectInfoDialogue = null;
         super.open();
         if(this._itemList.length == 1)
         {
            if(this._slot.group == null)
            {
               _loc1_ = new EffectInfoDialogue();
               _loc1_.open();
            }
         }
      }
      
      private function loadPromoData() : void
      {
         if(this.ui_promo == null)
         {
            return;
         }
         if(_promoData == null)
         {
            Network.getInstance().client.bigDB.loadRange("PayVaultItems","ByPromoTypeEnabled",["effectBooks"],true,true,1000,function(param1:Array):void
            {
               _promoData = param1;
               if(_promoData == null || _promoData.length == 0)
               {
                  return;
               }
               ui_promo.data = new StoreItem(_promoData[int(Math.random() * _promoData.length)]);
            });
         }
         else
         {
            this.ui_promo.data = new StoreItem(_promoData[int(Math.random() * _promoData.length)]);
         }
      }
      
      private function updateDisabledStates() : void
      {
         var _loc3_:EffectItem = null;
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc1_:int = int(Network.getInstance().playerData.getPlayerSurvivor().level);
         var _loc2_:int = 0;
         for(; _loc2_ < this._itemList.length; _loc2_++)
         {
            _loc3_ = this._itemList[_loc2_] as EffectItem;
            if(_loc3_ != null)
            {
               if(this._effectList.containsEffect(_loc3_.effect))
               {
                  this.ui_list.setEnabledStateByItemId(_loc3_.id,false);
               }
               else if(_loc3_.effect.group == "tactics" && _loc3_.level > _loc1_)
               {
                  this.ui_list.setEnabledStateByItemId(_loc3_.id,false);
               }
               else
               {
                  if(this._effectList.containsEffectOfType(_loc3_.effect.type))
                  {
                     if(this._slot.effect == null || this._slot.effect.timer == null || this._slot.effect.timer.hasEnded())
                     {
                        this.ui_list.setEnabledStateByItemId(_loc3_.id,false);
                        continue;
                     }
                  }
                  if(this._slot.effect != null && this._slot.effect.lockoutTimer != null && !this._slot.effect.lockoutTimer.hasEnded())
                  {
                     this.ui_list.setEnabledStateByItemId(_loc3_.id,false);
                  }
                  else
                  {
                     _loc4_ = _loc3_.effect.group;
                     _loc5_ = this._effectList.getMaxEffectsOfGroup(_loc4_) + _loc3_.effect.getValue(EffectType.getTypeValue("EffectGroupLimit"));
                     _loc6_ = this._effectList.getNumEffectsOfGroup(_loc4_);
                     if(this._slot.effect != null && this._slot.effect.group == _loc4_)
                     {
                        _loc5_ -= this._slot.effect.getValue(EffectType.getTypeValue("EffectGroupLimit"));
                        _loc6_--;
                     }
                     if(_loc6_ >= _loc5_)
                     {
                        this.ui_list.setEnabledStateByItemId(_loc3_.id,false);
                     }
                     else if(_loc3_.effect.hasEffectType(EffectType.getTypeValue("DisablePvP")))
                     {
                        if(this._effectList.compound.player.cooldowns.hasActive(CooldownType.DisablePvP))
                        {
                           this.ui_list.setEnabledStateByItemId(_loc3_.id,false);
                        }
                        else if(this._gameLocation != NavigationLocation.PLAYER_COMPOUND && this._gameLocation != NavigationLocation.WORLD_MAP)
                        {
                           this.ui_list.setEnabledStateByItemId(_loc3_.id,false);
                        }
                     }
                  }
               }
            }
         }
      }
      
      private function onShutdownInEffectChange(param1:Boolean) : void
      {
         if(param1 == false)
         {
            return;
         }
         var _loc2_:MessageBox = new MessageBox(this._lang.getString("effects_shutdownWarn_msg"),"effectLockdownMessage");
         _loc2_.addTitle(this._lang.getString("effects_shutdownWarn_title"),BaseDialogue.TITLE_COLOR_RUST);
         _loc2_.addButton(this._lang.getString("effects_shutdownWarn_btn"));
         _loc2_.open();
      }
      
      private function onItemSelected() : void
      {
         this.selected.dispatch(UIInventoryListItem(this.ui_list.selectedItem).itemData);
      }
      
      private function onPageChanged(param1:int) : void
      {
         this.ui_list.gotoPage(param1);
      }
      
      private function onTimerCompleted(param1:TimerData) : void
      {
         if(param1.target is Effect)
         {
            this.updateDisabledStates();
         }
      }
      
      private function onPromoClicked(param1:MouseEvent) : void
      {
         var _loc2_:StoreDialogue = new StoreDialogue("effect");
         _loc2_.open();
         Tracking.trackPageview("effects/store");
      }
   }
}

import com.greensock.TweenMax;
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import org.osflash.signals.natives.NativeSignal;
import thelaststand.app.display.BodyTextField;
import thelaststand.app.display.Effects;
import thelaststand.app.display.TitleTextField;
import thelaststand.app.game.data.EffectItem;
import thelaststand.app.game.data.store.StoreItem;
import thelaststand.app.game.gui.UIItemImage;
import thelaststand.app.game.gui.UIItemInfo;
import thelaststand.app.gui.UIBusySpinner;
import thelaststand.app.gui.buttons.PushButton;
import thelaststand.common.lang.Language;

class SalePanel extends Sprite
{
   
   private var _width:int;
   
   private var _height:int;
   
   private var _busy:Boolean = false;
   
   private var _data:StoreItem;
   
   private var _item:EffectItem;
   
   private var bmp_background:Bitmap;
   
   private var bmp_star:Bitmap;
   
   private var txt_promo:BodyTextField;
   
   private var txt_name:TitleTextField;
   
   private var btn_store:PushButton;
   
   private var ui_image:UIItemImage;
   
   private var ui_busy:UIBusySpinner;
   
   private var ui_itemInfo:UIItemInfo;
   
   public var clicked:NativeSignal;
   
   public function SalePanel()
   {
      super();
      this.bmp_background = new Bitmap(new BmpBookPromoBg());
      addChild(this.bmp_background);
      this._width = this.bmp_background.width;
      this._height = this.bmp_background.height;
      this.ui_busy = new UIBusySpinner();
      this.ui_image = new UIItemImage(36,36);
      this.ui_image.filters = [new GlowFilter(5395026,1,2,2,10,1)];
      this.ui_image.x = 21;
      this.ui_image.y = 9;
      this.ui_image.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverImage,false,0,true);
      addChild(this.ui_image);
      this.ui_itemInfo = new UIItemInfo();
      this.ui_itemInfo.addRolloverTarget(this.ui_image);
      this.btn_store = new PushButton("",new BmpIconStore());
      this.btn_store.width = 36;
      this.btn_store.height = 24;
      this.btn_store.x = int(this._width - 32 - this.btn_store.width);
      this.btn_store.y = int((this._height - this.btn_store.height) * 0.5);
      addChild(this.btn_store);
      this.bmp_star = new Bitmap(new BmpIconNewItem());
      this.bmp_star.x = int(this.ui_image.x + this.ui_image.width + 6);
      this.bmp_star.y = int(this.ui_image.y);
      this.bmp_star.filters = [Effects.ICON_SHADOW];
      addChild(this.bmp_star);
      this.txt_promo = new BodyTextField({
         "text":" ",
         "color":8034649,
         "size":13,
         "bold":true,
         "filters":[Effects.TEXT_SHADOW_DARK]
      });
      this.txt_promo.x = int(this.bmp_star.x + this.bmp_star.width);
      this.txt_promo.y = int(this.bmp_star.y + (this.bmp_star.height - this.txt_promo.height) * 0.5);
      addChild(this.txt_promo);
      this.txt_name = new TitleTextField({
         "text":" ",
         "color":12895428,
         "size":21,
         "filters":[Effects.TEXT_SHADOW_DARK]
      });
      this.txt_name.x = int(this.ui_image.x + this.ui_image.width + 6);
      this.txt_name.maxWidth = int(this.btn_store.x - this.txt_name.x - 10);
      addChild(this.txt_name);
      this.clicked = new NativeSignal(this,MouseEvent.CLICK,MouseEvent);
      addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
      addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
   }
   
   public function get busy() : Boolean
   {
      return this._busy;
   }
   
   public function set busy(param1:Boolean) : void
   {
      this.setBusyState(param1);
   }
   
   public function get data() : StoreItem
   {
      return this._data;
   }
   
   public function set data(param1:StoreItem) : void
   {
      this._data = param1;
      this.setBusyState(false);
      this.update();
   }
   
   public function dispose() : void
   {
      if(parent != null)
      {
         parent.removeChild(this);
      }
      if(this._item != null)
      {
         this._item.dispose();
      }
      this.clicked.removeAll();
      this.bmp_background.bitmapData.dispose();
      this.bmp_background.bitmapData = null;
      this.bmp_star.bitmapData.dispose();
      this.bmp_star.bitmapData = null;
      this.txt_name.dispose();
      this.txt_promo.dispose();
      this.btn_store.dispose();
      this.ui_image.dispose();
      this.ui_busy.dispose();
   }
   
   private function setBusyState(param1:Boolean) : void
   {
      var _loc2_:int = 0;
      var _loc3_:DisplayObject = null;
      this._busy = param1;
      if(this._busy)
      {
         _loc2_ = 0;
         while(_loc2_ < numChildren)
         {
            _loc3_ = getChildAt(_loc2_);
            if(_loc3_ != this.bmp_background)
            {
               _loc3_.visible = false;
            }
            _loc2_++;
         }
         addChild(this.ui_busy);
         this.ui_busy.x = int(this._width * 0.5);
         this.ui_busy.y = int(this._height * 0.5);
         this.ui_busy.visible = true;
      }
      else
      {
         if(this.ui_busy.parent != null)
         {
            this.ui_busy.parent.removeChild(this.ui_busy);
         }
         _loc2_ = 0;
         while(_loc2_ < numChildren)
         {
            getChildAt(_loc2_).visible = true;
            _loc2_++;
         }
      }
   }
   
   private function update() : void
   {
      var lang:Language = null;
      try
      {
         this._item = EffectItem(this._data.item);
         lang = Language.getInstance();
         this.txt_promo.text = lang.getString("effect_promo_title");
         this.txt_name.text = Language.getInstance().getString("effect_names." + this._item.effect.type).toUpperCase();
         this.txt_name.y = int(this.ui_image.y + this.ui_image.height - this.txt_promo.height - 4);
         this.ui_image.item = this._item;
      }
      catch(err:Error)
      {
         busy = true;
      }
   }
   
   private function onMouseOverImage(param1:MouseEvent) : void
   {
      this.ui_itemInfo.setItem(this._item);
   }
   
   private function onMouseOver(param1:MouseEvent) : void
   {
      TweenMax.to(this.bmp_background,0.01,{"colorTransform":{"exposure":1.1}});
   }
   
   private function onMouseOut(param1:MouseEvent) : void
   {
      TweenMax.to(this.bmp_background,0.25,{"colorTransform":{"exposure":1}});
   }
}
