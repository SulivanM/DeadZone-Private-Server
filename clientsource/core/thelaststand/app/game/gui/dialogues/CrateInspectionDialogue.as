package thelaststand.app.game.gui.dialogues
{
   import com.deadreckoned.threshold.display.Color;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.CrateItem;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemFactory;
   import thelaststand.app.game.gui.UIItemInfo;
   import thelaststand.app.game.gui.lists.UIInventoryList;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class CrateInspectionDialogue extends BaseDialogue
   {
      
      private var _crate:CrateItem;
      
      private var _lang:Language;
      
      private var _numCols:int = 4;
      
      private var _items:Vector.<Item>;
      
      private var _keyItem:Item;
      
      private var _hasKey:Boolean;
      
      private var mc_container:Sprite = new Sprite();
      
      private var txt_desc:BodyTextField;
      
      private var ui_items:UIInventoryList;
      
      private var ui_keyImage:UIImage;
      
      private var ui_itemInfo:UIItemInfo;
      
      private var btn_unlock:PushButton;
      
      public function CrateInspectionDialogue(param1:CrateItem, param2:Boolean = true)
      {
         super("crate-inspection-dialogue",this.mc_container,param2);
         _autoSize = false;
         _width = 268;
         _height = 252;
         this._lang = Language.getInstance();
         this._crate = param1;
         this._items = this._crate.contents.concat();
         this._items.push(new RareItem());
         addTitle(this._lang.getString("crate_inspect_title"),BaseDialogue.TITLE_COLOR_GREY);
         this.txt_desc = new BodyTextField({
            "color":10790052,
            "size":11,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_desc.htmlText = this._lang.getString("crate_inspect_desc").toUpperCase();
         this.txt_desc.y = int(_padding * 0.5);
         this.mc_container.addChild(this.txt_desc);
         var _loc3_:ItemListOptions = new ItemListOptions();
         _loc3_.clothingPreviews = ClothingPreviewDisplayOptions.ENABLED;
         _loc3_.allowSelection = false;
         _loc3_.showNewIcons = false;
         _loc3_.sortItems = false;
         var _loc4_:int = Math.max(1,Math.ceil(this._items.length / this._numCols));
         this.ui_items = new UIInventoryList(48,10,_loc3_);
         this.ui_items.y = int(this.txt_desc.y + this.txt_desc.height + 6);
         this.ui_items.width = (this._numCols + 1) * 48;
         this.ui_items.height = Math.max(72,_loc4_ * 72 - 18);
         this.ui_items.itemList = this._items;
         this.mc_container.addChild(this.ui_items);
         this.txt_desc.maxWidth = this.ui_items.width;
         this.ui_keyImage = new UIImage(48,48);
         this.ui_keyImage.x = int(this.ui_items.x + 4);
         this.ui_keyImage.y = int(this.ui_items.y + this.ui_items.height + 10);
         this.ui_keyImage.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverKey,false,0,true);
         this.mc_container.addChild(this.ui_keyImage);
         this.btn_unlock = new PushButton(" ",null,-1,null,4226049);
         this.btn_unlock.x = int(this.ui_keyImage.x + this.ui_keyImage.width + 12);
         this.btn_unlock.y = int(this.ui_keyImage.y + (this.ui_keyImage.height - this.btn_unlock.height) * 0.5);
         this.btn_unlock.width = int(this.ui_items.width - this.btn_unlock.x - 6);
         this.btn_unlock.clicked.add(this.onUnlockClicked);
         this.mc_container.addChild(this.btn_unlock);
         this.ui_itemInfo = new UIItemInfo();
         this.ui_itemInfo.addRolloverTarget(this.ui_keyImage);
         this.updateKeyState();
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._lang = null;
         this._crate = null;
         this._items = null;
         this._keyItem = null;
         this.txt_desc.dispose();
         this.btn_unlock.dispose();
         this.ui_items.dispose();
         this.ui_keyImage.dispose();
         this.ui_itemInfo.dispose();
      }
      
      private function updateKeyState() : void
      {
         var _loc1_:String = null;
         var _loc2_:uint = 0;
         var _loc4_:String = null;
         var _loc5_:Vector.<Item> = null;
         var _loc3_:Vector.<String> = CrateItem.getKeyListForCrate(this._crate);
         if(this._crate.type == "crate-tutorial")
         {
            this._hasKey = true;
            this._keyItem = ItemFactory.createItemFromTypeId(_loc3_[0]);
         }
         else
         {
            this._hasKey = false;
            for each(_loc4_ in _loc3_)
            {
               _loc5_ = Network.getInstance().playerData.inventory.getItemsOfType(_loc4_);
               if(_loc5_.length > 0)
               {
                  this._hasKey = true;
                  this._keyItem = _loc5_[0];
                  break;
               }
            }
         }
         if(!this._hasKey)
         {
            this._keyItem = ItemFactory.createItemFromTypeId(_loc3_[0]);
            _loc1_ = this._keyItem.getImageURI();
            _loc2_ = 9371648;
         }
         else
         {
            _loc1_ = this._keyItem.getImageURI();
            _loc2_ = new Color(Color.hexToColor(this._keyItem.xml.key.color)).tint(0,0.5).RGB;
         }
         this.ui_keyImage.uri = _loc1_;
         this.ui_keyImage.filters = [new GlowFilter(new Color(Effects.COLOR_PREMIUM).tint(0,0.5).RGB,1,4,4,10,1)];
         this.btn_unlock.label = this._lang.getString(this._hasKey ? "crate_inspect_unlock" : "crate_inspect_getkeys");
      }
      
      private function openMiniStoreForKey() : void
      {
         var storeDlg:MiniStoreDialogue = new MiniStoreDialogue(this._keyItem.type);
         storeDlg.closed.addOnce(function(param1:Dialogue):void
         {
            updateKeyState();
         });
         storeDlg.open();
      }
      
      private function onUnlockClicked(param1:MouseEvent) : void
      {
         if(!this._hasKey)
         {
            this.openMiniStoreForKey();
            return;
         }
         var _loc2_:CrateUnlockDialogue = new CrateUnlockDialogue(this._crate);
         close();
         _loc2_.open();
      }
      
      private function onMouseOverKey(param1:MouseEvent) : void
      {
         this.ui_itemInfo.setItem(this._keyItem);
      }
   }
}

import thelaststand.app.game.data.Item;
import thelaststand.common.lang.Language;

class RareItem extends Item
{
   
   public function RareItem()
   {
      super();
      _type = "crate-rare-item";
      _itemType = "unknown";
      _baseLevel = _level = -1;
   }
   
   override public function getName() : String
   {
      return Language.getInstance().getString("itm_types.unknown");
   }
   
   override public function getImageURI() : String
   {
      return "images/items/rare.jpg";
   }
}
