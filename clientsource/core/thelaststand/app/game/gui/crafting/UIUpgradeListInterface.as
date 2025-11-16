package thelaststand.app.game.gui.crafting
{
   import com.deadreckoned.threshold.display.Color;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import org.osflash.signals.Signal;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemQualityType;
   import thelaststand.app.game.data.Weapon;
   import thelaststand.app.game.data.WeaponClass;
   import thelaststand.app.game.data.WeaponData;
   import thelaststand.app.game.gui.dialogues.ClothingPreviewDisplayOptions;
   import thelaststand.app.game.gui.dialogues.ItemListOptions;
   import thelaststand.app.game.gui.lists.UIInventoryList;
   import thelaststand.app.game.gui.lists.UIInventoryListItem;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIPagination;
   import thelaststand.app.gui.UISpinner;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class UIUpgradeListInterface extends Sprite
   {
      
      private static var _defaultSortOption:String = "level";
      
      private static const _qualityList:Array = ["all","grey","white","green","blue","purple","rare","unique","infamous","premium"];
      
      private const FILTER_LOCKED:uint = 1;
      
      private const FILTER_MELEE:uint = 2;
      
      private const FILTER_FIREARMS:uint = 4;
      
      private const FILTER_GEAR:uint = 8;
      
      private var _filter:uint;
      
      private var _filterQuality:int;
      
      private var _lang:Language;
      
      private var _tooltip:TooltipManager;
      
      private var _filterButtons:Vector.<PushButton>;
      
      private var _maxWeaponUpgradeLevel:int = -1;
      
      private var _maxGearUpgradeLevel:int = -1;
      
      private var _sortButtons:Vector.<PushButton>;
      
      private var _selectedSortButton:PushButton;
      
      private var _selectedFilterButtons:PushButton;
      
      private var _selectedItem:Item;
      
      private var _itemList:Vector.<Item>;
      
      private var _width:int = 398;
      
      private var _height:int = 0;
      
      private var btn_filter_melee:PushButton;
      
      private var btn_filter_firearms:PushButton;
      
      private var btn_filter_gear:PushButton;
      
      private var ui_filterBg:Shape;
      
      private var ui_page:UIPagination;
      
      private var ui_list:UIInventoryList;
      
      private var spin_quality:UISpinner;
      
      public var itemSelected:Signal;
      
      private var _weaponData:WeaponData;
      
      public function UIUpgradeListInterface()
      {
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:uint = 0;
         var _loc10_:* = null;
         this._filter = this.FILTER_LOCKED | this.FILTER_MELEE | this.FILTER_FIREARMS | this.FILTER_GEAR;
         this._weaponData = new WeaponData();
         super();
         this.itemSelected = new Signal(Item);
         this._lang = Language.getInstance();
         this._tooltip = TooltipManager.getInstance();
         var _loc1_:ItemListOptions = new ItemListOptions();
         _loc1_.clothingPreviews = ClothingPreviewDisplayOptions.DISABLED;
         _loc1_.allowSelectionOfUnequippable = true;
         _loc1_.showEquippedIcons = true;
         _loc1_.showNewIcons = false;
         _loc1_.sortItems = false;
         _loc1_.showMaxUpgradeLevel = true;
         this.ui_list = new UIInventoryList(64,10,_loc1_);
         this.ui_list.width = this._width;
         this.ui_list.height = 316;
         this.ui_list.y = 34;
         this.ui_list.changed.add(this.onItemSelected);
         addChild(this.ui_list);
         this.ui_page = new UIPagination();
         this.ui_page.maxWidth = this.ui_list.width;
         this.ui_page.maxDots = 12;
         this.ui_page.x = int(this.ui_list.x + (this.ui_list.width - this.ui_page.width) * 0.5);
         this.ui_page.y = int(this.ui_list.y + this.ui_list.height + 14);
         this.ui_page.changed.add(this.onPageChanged);
         addChild(this.ui_page);
         this.ui_filterBg = new Shape();
         GraphicUtils.drawUIBlock(this.ui_filterBg.graphics,this._width,40);
         this.ui_filterBg.x = int(this.ui_list.x);
         this.ui_filterBg.y = int(this.ui_list.y - this.ui_filterBg.height + 1);
         addChildAt(this.ui_filterBg,0);
         this._height = int(this.ui_page.y + this.ui_page.height);
         var _loc2_:PushButton = new PushButton("",new BmpIconItemLocked());
         _loc2_.data = "locked";
         _loc2_.showBorder = false;
         this._tooltip.add(_loc2_,this._lang.getString("crafting_filter_locked_upgrade"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         this.btn_filter_melee = new PushButton("",new BmpIconMelee());
         this.btn_filter_melee.data = "melee";
         this.btn_filter_melee.showBorder = false;
         this._tooltip.add(this.btn_filter_melee,this._lang.getString("crafting_filter_melee"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         this.btn_filter_firearms = new PushButton("",new BmpIconFirearms());
         this.btn_filter_firearms.data = "firearms";
         this.btn_filter_firearms.showBorder = false;
         this._tooltip.add(this.btn_filter_firearms,this._lang.getString("crafting_filter_firearms"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         this.btn_filter_gear = new PushButton("",new BmpIconGear());
         this.btn_filter_gear.data = "gear";
         this.btn_filter_gear.showBorder = false;
         this._tooltip.add(this.btn_filter_gear,this._lang.getString("crafting_filter_gear"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         this._filterButtons = new Vector.<PushButton>();
         this._filterButtons.push(_loc2_);
         this._filterButtons.push(this.btn_filter_firearms);
         this._filterButtons.push(this.btn_filter_melee);
         this._filterButtons.push(this.btn_filter_gear);
         var _loc3_:PushButton = new PushButton("",new BmpIconSortAlpha());
         _loc3_.data = "alpha";
         _loc3_.showBorder = false;
         this._tooltip.add(_loc3_,this._lang.getString("crafting_sort_alpha"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         var _loc4_:PushButton = new PushButton("",new BmpIconLevel());
         _loc4_.data = "level";
         _loc4_.showBorder = false;
         this._tooltip.add(_loc4_,this._lang.getString("crafting_sort_level"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         var _loc5_:PushButton = new PushButton("",new BmpIconDPS());
         _loc5_.data = "dps";
         _loc5_.showBorder = false;
         this._tooltip.add(_loc5_,this._lang.getString("crafting_sort_dps"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         this._sortButtons = new Vector.<PushButton>();
         this._sortButtons.push(_loc4_);
         this._sortButtons.push(_loc3_);
         this._sortButtons.push(_loc5_);
         this.spin_quality = new UISpinner();
         this.spin_quality.width = 130;
         this.spin_quality.changed.add(this.onQualityChanged);
         var _loc6_:int = 0;
         while(_loc6_ < _qualityList.length)
         {
            _loc7_ = _qualityList[_loc6_];
            _loc8_ = "COLOR_" + _loc7_.toUpperCase();
            _loc9_ = _loc8_ in Effects ? uint(Effects[_loc8_]) : 16777215;
            _loc10_ = "<font color=\'" + Color.colorToHex(_loc9_) + "\'>" + Language.getInstance().getString("itm_quality." + _loc7_) + "</font>";
            this.spin_quality.addItem(_loc10_,_loc7_);
            _loc6_++;
         }
         this.spin_quality.selectItem(0);
         addChild(this.spin_quality);
         this.updateMaxUpgradeLevels();
         this.updateOptions();
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         this.ui_list.dispose();
         this.ui_page.dispose();
         this.spin_quality.dispose();
         this.btn_filter_firearms.dispose();
         this.btn_filter_gear.dispose();
         this.btn_filter_melee.dispose();
         this.itemSelected.removeAll();
         this._filterButtons = null;
         this._sortButtons = null;
         this._selectedItem = null;
      }
      
      public function update() : void
      {
         this.updateLockedItems();
      }
      
      private function updateOptions() : void
      {
         var _loc1_:PushButton = null;
         var _loc4_:int = 0;
         var _loc7_:int = 0;
         var _loc2_:int = 26;
         var _loc3_:int = 10;
         var _loc5_:int = int(this.ui_filterBg.y + (this.ui_filterBg.height - this.btn_filter_firearms.height) / 2);
         var _loc6_:int = 8;
         for each(_loc1_ in this._filterButtons)
         {
            _loc1_.clicked.add(this.onFilterSelected);
            _loc1_.width = _loc2_;
            _loc1_.x = _loc6_;
            _loc1_.y = _loc5_;
            _loc1_.selected = (this._filter & this.getFilterValue(_loc1_.data)) != 0;
            _loc6_ += _loc1_.width + _loc3_;
            addChild(_loc1_);
         }
         _loc7_ = this.ui_list.x + this.ui_list.width - 8;
         for each(_loc1_ in this._sortButtons)
         {
            _loc1_.clicked.add(this.onSortSelected);
            _loc1_.width = _loc2_;
            _loc1_.x = _loc7_ - _loc2_;
            _loc1_.y = _loc5_;
            if(_loc1_.data == _defaultSortOption)
            {
               this._selectedSortButton = _loc1_;
               _loc1_.selected = true;
            }
            else
            {
               _loc1_.selected = false;
            }
            _loc7_ -= _loc1_.width + _loc3_;
            addChild(_loc1_);
         }
         this.spin_quality.y = int(this.ui_filterBg.y + (this.ui_filterBg.height - this.spin_quality.height) / 2);
         this.spin_quality.x = int(_loc6_ + (_loc7_ - _loc6_ - this.spin_quality.width) / 2);
         this.updateFilterQuality();
         this._itemList = this.applyFilter();
         this.applySort();
         this.ui_list.itemList = this._itemList;
         if(this._itemList.length > 0)
         {
            this.ui_list.selectItem(0);
         }
         this.updateLockedItems();
         this.updatePagination();
         this.onItemSelected();
      }
      
      private function updatePagination() : void
      {
         this.ui_page.numPages = this.ui_list.numPages;
         this.ui_page.x = int(this.ui_list.x + (this.ui_list.width - this.ui_page.width) * 0.5);
      }
      
      private function updateLockedItems() : void
      {
         var _loc3_:UIInventoryListItem = null;
         var _loc4_:int = 0;
         if(!(this._filter & this.FILTER_LOCKED))
         {
            return;
         }
         var _loc1_:int = 0;
         var _loc2_:int = this.ui_list.numItems;
         while(_loc1_ < _loc2_)
         {
            _loc3_ = this.ui_list.getItem(_loc1_) as UIInventoryListItem;
            if(_loc3_.itemData != null)
            {
               _loc4_ = _loc3_.itemData is Weapon ? this._maxWeaponUpgradeLevel : this._maxGearUpgradeLevel;
               _loc3_.unequippable = _loc3_.itemData.level > _loc4_ - 1 || !_loc3_.itemData.isUpgradable;
            }
            else
            {
               _loc3_.unequippable = false;
            }
            _loc1_++;
         }
      }
      
      private function updateMaxUpgradeLevels() : void
      {
         var _loc1_:Building = Network.getInstance().playerData.compound.buildings.getHighestLevelBuilding("bench-weapon");
         this._maxWeaponUpgradeLevel = _loc1_ != null ? int(_loc1_.getLevelXML().max_upgrade_level) : -1;
         var _loc2_:Building = Network.getInstance().playerData.compound.buildings.getHighestLevelBuilding("bench-gear");
         this._maxGearUpgradeLevel = _loc2_ != null ? int(_loc2_.getLevelXML().max_upgrade_level) : -1;
      }
      
      private function sortByLevel(param1:Item, param2:Item) : int
      {
         if(param1.level < param2.level)
         {
            return 1;
         }
         if(param1.level > param2.level)
         {
            return -1;
         }
         return this.sortByName(param1,param2);
      }
      
      private function sortByDPS(param1:Item, param2:Item) : int
      {
         var _loc3_:Weapon = param1 as Weapon;
         var _loc4_:Weapon = param2 as Weapon;
         if(_loc3_ == null && _loc4_ != null)
         {
            return 1;
         }
         if(_loc4_ == null && _loc3_ != null)
         {
            return -1;
         }
         if(_loc3_ == null && _loc4_ == null)
         {
            return 1;
         }
         this._weaponData.populate(null,_loc3_);
         var _loc5_:Number = this._weaponData.getDPS();
         this._weaponData.populate(null,_loc4_);
         var _loc6_:Number = this._weaponData.getDPS();
         if(_loc5_ < _loc6_)
         {
            return 1;
         }
         if(_loc5_ > _loc6_)
         {
            return -1;
         }
         return this.sortByLevel(param1,param2);
      }
      
      private function sortByName(param1:Item, param2:Item) : int
      {
         var _loc3_:String = param1.getName().toLowerCase();
         var _loc4_:String = param2.getName().toLowerCase();
         var _loc5_:int = int(_loc3_.localeCompare(_loc4_));
         if(_loc5_ < 0)
         {
            return -1;
         }
         if(_loc5_ > 0)
         {
            return 1;
         }
         return 0;
      }
      
      private function applySort() : void
      {
         switch(this._selectedSortButton.data)
         {
            case "alpha":
               this._itemList.sort(this.sortByName);
               break;
            case "level":
               this._itemList.sort(this.sortByLevel);
               break;
            case "dps":
               this._itemList.sort(this.sortByDPS);
         }
      }
      
      private function updateFilterQuality() : void
      {
         var _loc1_:String = String(this.spin_quality.selectedData);
         this._filterQuality = _loc1_ == "all" ? int.MIN_VALUE : int(ItemQualityType.getValue(_loc1_.toUpperCase()));
      }
      
      private function applyFilter() : Vector.<Item>
      {
         var _loc1_:Vector.<Item> = null;
         var _loc3_:Vector.<Item> = null;
         var _loc4_:Vector.<Item> = null;
         var _loc5_:Item = null;
         var _loc6_:Weapon = null;
         var _loc7_:int = 0;
         if(!(this._filter & this.FILTER_GEAR))
         {
            _loc1_ = Network.getInstance().playerData.inventory.getItemsOfCategory("weapon");
         }
         else if(!(this._filter & this.FILTER_FIREARMS) && !(this._filter & this.FILTER_MELEE))
         {
            _loc1_ = Network.getInstance().playerData.inventory.getItemsOfCategory("gear");
         }
         else
         {
            _loc3_ = Network.getInstance().playerData.inventory.getItemsOfCategory("weapon");
            _loc4_ = Network.getInstance().playerData.inventory.getItemsOfCategory("gear");
            _loc1_ = _loc3_.concat(_loc4_);
         }
         var _loc2_:int = int(_loc1_.length - 1);
         for(; _loc2_ >= 0; _loc2_--)
         {
            _loc5_ = _loc1_[_loc2_];
            if(!_loc5_.isUpgradable)
            {
               _loc1_.splice(_loc2_,1);
            }
            else
            {
               if(!(this._filter & this.FILTER_LOCKED))
               {
                  _loc7_ = _loc5_ is Weapon ? this._maxWeaponUpgradeLevel : this._maxGearUpgradeLevel;
                  if(_loc5_.level > _loc7_ - 1)
                  {
                     _loc1_.splice(_loc2_,1);
                     continue;
                  }
               }
               _loc6_ = _loc5_ as Weapon;
               if(!(this._filter & this.FILTER_MELEE))
               {
                  if(_loc6_ != null && _loc6_.weaponClass == WeaponClass.MELEE)
                  {
                     _loc1_.splice(_loc2_,1);
                     continue;
                  }
               }
               if(!(this._filter & this.FILTER_FIREARMS))
               {
                  if(_loc6_ != null && _loc6_.weaponClass != WeaponClass.MELEE)
                  {
                     _loc1_.splice(_loc2_,1);
                     continue;
                  }
               }
               if(this._filterQuality > int.MIN_VALUE && _loc5_.qualityType != this._filterQuality)
               {
                  _loc1_.splice(_loc2_,1);
               }
            }
         }
         return _loc1_;
      }
      
      private function getFilterValue(param1:String) : uint
      {
         switch(param1)
         {
            case "locked":
               return this.FILTER_LOCKED;
            case "melee":
               return this.FILTER_MELEE;
            case "firearms":
               return this.FILTER_FIREARMS;
            case "gear":
               return this.FILTER_GEAR;
            default:
               return 0;
         }
      }
      
      private function onFilterSelected(param1:MouseEvent) : void
      {
         var _loc2_:PushButton = PushButton(param1.currentTarget);
         var _loc3_:uint = this.getFilterValue(_loc2_.data);
         if(_loc3_ > 0)
         {
            _loc2_.selected = !_loc2_.selected;
            if(_loc2_.selected)
            {
               this._filter |= _loc3_;
            }
            else
            {
               this._filter &= ~_loc3_;
            }
         }
         if(!(this._filter & this.FILTER_MELEE) && !(this._filter & this.FILTER_FIREARMS) && !(this._filter & this.FILTER_GEAR))
         {
            switch(_loc3_)
            {
               case this.FILTER_FIREARMS:
                  this._filter |= this.FILTER_MELEE;
                  this.btn_filter_melee.selected = true;
                  break;
               case this.FILTER_MELEE:
               case this.FILTER_GEAR:
                  this._filter |= this.FILTER_FIREARMS;
                  this.btn_filter_firearms.selected = true;
            }
         }
         this.updateFilterQuality();
         this._itemList = this.applyFilter();
         this.applySort();
         this.ui_list.itemList = this._itemList;
         this.updateLockedItems();
         this.updatePagination();
      }
      
      private function onSortSelected(param1:MouseEvent) : void
      {
         var _loc2_:PushButton = PushButton(param1.currentTarget);
         if(this._selectedSortButton == _loc2_)
         {
            return;
         }
         if(this._selectedSortButton != null)
         {
            this._selectedSortButton.selected = false;
            this._selectedSortButton = null;
         }
         this._selectedSortButton = _loc2_;
         this._selectedSortButton.selected = true;
         this.applySort();
         this.ui_list.itemList = this._itemList;
         this.updateLockedItems();
         this.updatePagination();
      }
      
      private function onQualityChanged() : void
      {
         this.updateFilterQuality();
         this._itemList = this.applyFilter();
         this.applySort();
         this.ui_list.itemList = this._itemList;
         this.updateLockedItems();
         this.updatePagination();
      }
      
      private function onItemSelected() : void
      {
         var _loc1_:UIInventoryListItem = this.ui_list.selectedItem as UIInventoryListItem;
         this._selectedItem = _loc1_ != null ? _loc1_.itemData : null;
         this.itemSelected.dispatch(this._selectedItem);
      }
      
      private function onPageChanged(param1:int) : void
      {
         this.ui_list.gotoPage(param1);
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
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
      
      public function get selectedItem() : Item
      {
         return this._selectedItem;
      }
   }
}

