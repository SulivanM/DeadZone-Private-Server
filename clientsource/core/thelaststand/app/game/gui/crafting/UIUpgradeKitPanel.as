package thelaststand.app.game.gui.crafting
{
   import com.deadreckoned.threshold.display.Color;
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.PixelSnapping;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import org.osflash.signals.Signal;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.Inventory;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemFactory;
   import thelaststand.app.game.data.ItemQualityType;
   import thelaststand.app.game.gui.UIItemImage;
   import thelaststand.app.game.gui.dialogues.ClothingPreviewDisplayOptions;
   import thelaststand.app.game.gui.dialogues.ItemListDialogue;
   import thelaststand.app.game.gui.dialogues.ItemListOptions;
   import thelaststand.app.game.gui.dialogues.MiniStoreDialogue;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.network.Network;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class UIUpgradeKitPanel extends UIComponent
   {
      
      private static var _minKitLevel:int = int.MAX_VALUE;
      
      private static var _minKitQuality:int = int.MAX_VALUE;
      
      private static var _maxKitQuality:int = int.MIN_VALUE;
      
      private var _item:Item;
      
      private var _inputItem:Item;
      
      private var bmp_background:Bitmap;
      
      private var bmp_addIcon:Bitmap;
      
      private var bmp_addButton:Bitmap;
      
      private var ui_itemImage:UIItemImage;
      
      private var ui_hitArea:Sprite;
      
      private var txt_title:BodyTextField;
      
      private var txt_desc:BodyTextField;
      
      public var itemChanged:Signal;
      
      public function UIUpgradeKitPanel()
      {
         var allUpgradeKits:XMLList = null;
         var kitNode:XML = null;
         var kitMinLevel:int = 0;
         var quality:int = 0;
         this.itemChanged = new Signal(Item);
         super();
         mouseChildren = false;
         this.bmp_background = new Bitmap(new BmpUpgradeKitAreaBG(),PixelSnapping.ALWAYS);
         addChild(this.bmp_background);
         this.bmp_addButton = new Bitmap(new BmpUpgradeKitAddBtn(),PixelSnapping.ALWAYS);
         addChild(this.bmp_addButton);
         this.ui_itemImage = new UIItemImage(64,64,2);
         this.ui_itemImage.x = this.ui_itemImage.y = int((this.bmp_background.height - 64) / 2);
         this.ui_itemImage.borderColor = new Color(9417759);
         addChild(this.ui_itemImage);
         this.bmp_addButton.x = int(this.ui_itemImage.x + this.ui_itemImage.width);
         this.bmp_addButton.y = int(this.ui_itemImage.y + (this.ui_itemImage.height - this.bmp_addButton.height) / 2);
         this.bmp_addIcon = new Bitmap(new BmpIconUpgradeKitAdd(),PixelSnapping.ALWAYS);
         this.bmp_addIcon.x = int(this.ui_itemImage.x + (this.ui_itemImage.width - this.bmp_addIcon.width) * 0.5);
         this.bmp_addIcon.y = int(this.ui_itemImage.y + (this.ui_itemImage.height - this.bmp_addIcon.height) * 0.5);
         addChild(this.bmp_addIcon);
         this.txt_title = new BodyTextField({
            "color":13037123,
            "size":14,
            "bold":true,
            "filters":[Effects.stroke(2501901,2)]
         });
         this.txt_title.text = Language.getInstance().getString("crafting_upgradekit_title");
         this.txt_title.x = int(this.ui_itemImage.x + this.ui_itemImage.width + 20);
         this.txt_title.y = int(this.ui_itemImage.y + 6);
         this.txt_title.width = int(this.bmp_background.width - this.txt_title.x - 8);
         addChild(this.txt_title);
         this.txt_desc = new BodyTextField({
            "color":11124820,
            "size":12,
            "bold":true,
            "multiline":true,
            "filters":[Effects.stroke(2501901,1.75)]
         });
         this.txt_desc.text = Language.getInstance().getString("crafting_upgradekit_desc");
         this.txt_desc.x = int(this.txt_title.x);
         this.txt_desc.y = int(this.txt_title.y + this.txt_title.height - 2);
         this.txt_desc.width = int(this.bmp_background.width - this.txt_desc.x - 8);
         addChild(this.txt_desc);
         this.ui_hitArea = new Sprite();
         this.ui_hitArea.graphics.beginFill(0,0);
         this.ui_hitArea.graphics.drawRect(0,0,this.bmp_background.width,this.bmp_background.height);
         this.ui_hitArea.graphics.endFill();
         addChild(this.ui_hitArea);
         hitArea = this.ui_hitArea;
         if(_minKitLevel == int.MAX_VALUE)
         {
            allUpgradeKits = ItemFactory.itemTable.item.(@type == "upgradekit");
            for each(kitNode in allUpgradeKits)
            {
               kitMinLevel = int(kitNode.kit.itm_lvl_min);
               if(kitMinLevel < _minKitLevel)
               {
                  _minKitLevel = kitMinLevel;
               }
               quality = int(ItemQualityType.getValue(kitNode.@quality.toLowerCase()));
               if(quality < _minKitQuality)
               {
                  _minKitQuality = quality;
               }
               else if(quality > _maxKitQuality)
               {
                  _maxKitQuality = quality;
               }
            }
         }
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
      }
      
      public function get upgradeKitItem() : Item
      {
         return this._item;
      }
      
      public function get inputItem() : Item
      {
         return this._inputItem;
      }
      
      public function set inputItem(param1:Item) : void
      {
         if(param1 == this._inputItem)
         {
            return;
         }
         this._inputItem = param1;
         this.setItem(null);
         invalidate();
      }
      
      override public function dispose() : void
      {
         super.dispose();
         filters = [];
         this.bmp_background.bitmapData.dispose();
         this.bmp_addIcon.bitmapData.dispose();
         this.bmp_addButton.bitmapData.dispose();
      }
      
      override protected function draw() : void
      {
         var _loc1_:Boolean = this._inputItem != null && !this._inputItem.isAtMaxLevel() && this._inputItem.qualityType >= _minKitQuality && this._inputItem.qualityType <= _maxKitQuality && this._inputItem.level >= _minKitLevel;
         visible = _loc1_;
         this.bmp_addIcon.visible = this._item == null;
         this.bmp_addButton.visible = this._item == null;
      }
      
      public function clear() : void
      {
         this.setItem(null);
      }
      
      private function setItem(param1:Item) : void
      {
         if(param1 == this._item)
         {
            return;
         }
         this._item = param1;
         this.ui_itemImage.item = this._item;
         invalidate();
         this.itemChanged.dispatch(this._item);
         dispatchEvent(new Event("UpgradeKitChanged",true));
      }
      
      private function inventoryFilter(param1:Item) : Boolean
      {
         if(this._inputItem.qualityType > param1.qualityType)
         {
            return false;
         }
         var _loc2_:int = int(param1.xml.kit.itm_lvl_min);
         var _loc3_:int = int(param1.xml.kit.itm_lvl_max);
         if(this._inputItem.level < _loc2_ || this._inputItem.level > _loc3_)
         {
            return false;
         }
         return true;
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         TweenMax.to(this,0,{"colorTransform":{"exposure":1.05}});
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         TweenMax.to(this,0.25,{"colorTransform":{"exposure":1}});
      }
      
      private function getBestUpgradeKitForInputItem() : String
      {
         var strItemQuality:String;
         var allUpgradeKits:XMLList;
         var bestItem:XML = null;
         var kitNode:XML = null;
         var kitMinLevel:int = 0;
         var kitMaxLevel:int = 0;
         if(this._inputItem == null)
         {
            return null;
         }
         strItemQuality = ItemQualityType.getName(this._inputItem.qualityType).toLowerCase();
         allUpgradeKits = ItemFactory.itemTable.item.(@type == "upgradekit" && @quality == strItemQuality);
         for each(kitNode in allUpgradeKits)
         {
            kitMinLevel = int(kitNode.kit.itm_lvl_min);
            kitMaxLevel = int(kitNode.kit.itm_lvl_max);
            if(this._inputItem.level >= kitMinLevel && this._inputItem.level <= kitMaxLevel)
            {
               bestItem = kitNode;
            }
         }
         return bestItem != null ? bestItem.@id.toString() : null;
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         var itemList:Vector.<Item> = null;
         var bestKitId:String = null;
         var storeDlg:MiniStoreDialogue = null;
         var e:MouseEvent = param1;
         itemList = this.getUpgradeKitsFromInventory();
         if(itemList.length == 0)
         {
            bestKitId = this.getBestUpgradeKitForInputItem();
            if(bestKitId != null)
            {
               storeDlg = new MiniStoreDialogue(bestKitId,false);
               storeDlg.closed.addOnce(function(param1:Dialogue):void
               {
                  openInventory(getUpgradeKitsFromInventory());
               });
               storeDlg.noItemsFound.addOnce(function():void
               {
                  openInventory(itemList);
               });
               storeDlg.open();
               return;
            }
         }
         this.openInventory(itemList);
      }
      
      private function getUpgradeKitsFromInventory() : Vector.<Item>
      {
         var _loc1_:Inventory = Network.getInstance().playerData.inventory;
         return _loc1_.getItemsOfCategoryWhere("upgradekit",this.inventoryFilter);
      }
      
      private function openInventory(param1:Vector.<Item>) : void
      {
         var itemDlg:ItemListDialogue = null;
         var itemList:Vector.<Item> = param1;
         var options:ItemListOptions = new ItemListOptions();
         options.clothingPreviews = ClothingPreviewDisplayOptions.DISABLED;
         options.showNoneItem = true;
         itemDlg = new ItemListDialogue(Language.getInstance().getString("crafting_upgradekit_item_title"),itemList,options);
         itemDlg.selected.add(function(param1:Item):void
         {
            setItem(param1);
            itemDlg.close();
         });
         itemDlg.open();
      }
   }
}

