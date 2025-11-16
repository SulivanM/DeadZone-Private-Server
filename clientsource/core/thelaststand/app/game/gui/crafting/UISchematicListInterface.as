package thelaststand.app.game.gui.crafting
{
   import com.deadreckoned.threshold.display.Color;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import org.osflash.signals.Signal;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.ItemQualityType;
   import thelaststand.app.game.data.MedicalItem;
   import thelaststand.app.game.data.Schematic;
   import thelaststand.app.game.data.Weapon;
   import thelaststand.app.game.data.WeaponClass;
   import thelaststand.app.game.data.WeaponData;
   import thelaststand.app.game.gui.lists.UISchematicList;
   import thelaststand.app.game.gui.lists.UISchematicListItem;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIPagination;
   import thelaststand.app.gui.UISpinner;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class UISchematicListInterface extends Sprite
   {
      
      private static var _defaultSortOption:String = "level";
      
      private static const _qualityList:Array = ["all","white","green","blue","purple","infamous","premium"];
      
      private static const _medGradeList:Array = [0,1,2,3,4,5];
      
      private const FILTER_LOCKED:uint = 1;
      
      private const FILTER_MELEE:uint = 2;
      
      private const FILTER_FIREARMS:uint = 4;
      
      private var _filter:uint = this.FILTER_LOCKED | this.FILTER_MELEE | this.FILTER_FIREARMS;
      
      private var _filterQuality:int;
      
      private var _schematicList:Vector.<Schematic>;
      
      private var _selectedCategory:String;
      
      private var _selectedSchematic:Schematic;
      
      private var _selectedSortButton:PushButton;
      
      private var _currentFilterButtons:Vector.<PushButton>;
      
      private var _currentSortButtons:Vector.<PushButton>;
      
      private var _globalFilterButtons:Vector.<PushButton>;
      
      private var _globalSortButtons:Vector.<PushButton>;
      
      private var _weaponFilterButtons:Vector.<PushButton>;
      
      private var _weaponSortButtons:Vector.<PushButton>;
      
      private var _width:int = 398;
      
      private var _height:int = 0;
      
      private var _lang:Language;
      
      private var _tooltip:TooltipManager;
      
      private var _weaponData:WeaponData;
      
      private var btn_filter_melee:PushButton;
      
      private var btn_filter_firearms:PushButton;
      
      private var btn_sortNew:PushButton;
      
      private var btn_sortAlpha:PushButton;
      
      private var btn_sortLevel:PushButton;
      
      private var ui_filterBg:Shape;
      
      private var ui_page:UIPagination;
      
      private var ui_list:UISchematicList;
      
      private var spin_quality:UISpinner;
      
      public var schematicSelected:Signal;
      
      public function UISchematicListInterface()
      {
         super();
         this._lang = Language.getInstance();
         this._tooltip = TooltipManager.getInstance();
         this._weaponData = new WeaponData();
         this.schematicSelected = new Signal(Schematic);
         this.ui_list = new UISchematicList();
         this.ui_list.width = this._width;
         this.ui_list.height = 316;
         this.ui_list.y = 34;
         this.ui_list.changed.add(this.onSchematicSelected);
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
         var _loc1_:PushButton = new PushButton("",new BmpIconItemLocked());
         _loc1_.data = "locked";
         _loc1_.showBorder = false;
         this._tooltip.add(_loc1_,this._lang.getString("crafting_filter_locked"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         this._globalFilterButtons = new Vector.<PushButton>();
         this._globalFilterButtons.push(_loc1_);
         this.btn_filter_melee = new PushButton("",new BmpIconMelee());
         this.btn_filter_melee.data = "melee";
         this.btn_filter_melee.showBorder = false;
         this._tooltip.add(this.btn_filter_melee,this._lang.getString("inv_filter.melee"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         this.btn_filter_firearms = new PushButton("",new BmpIconFirearms());
         this.btn_filter_firearms.data = "firearms";
         this.btn_filter_firearms.showBorder = false;
         this._tooltip.add(this.btn_filter_firearms,this._lang.getString("inv_filter.firearms"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         this._weaponFilterButtons = new Vector.<PushButton>();
         this._weaponFilterButtons.push(this.btn_filter_firearms);
         this._weaponFilterButtons.push(this.btn_filter_melee);
         this.spin_quality = new UISpinner();
         this.spin_quality.visible = false;
         this.spin_quality.width = 154;
         this.spin_quality.changed.add(this.onQualityChanged);
         addChild(this.spin_quality);
         this.btn_sortNew = new PushButton("",new BmpIconStar());
         this.btn_sortNew.data = "new";
         this.btn_sortNew.showBorder = false;
         this._tooltip.add(this.btn_sortNew,this._lang.getString("crafting_sort_new"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         this.btn_sortAlpha = new PushButton("",new BmpIconSortAlpha());
         this.btn_sortAlpha.data = "alpha";
         this.btn_sortAlpha.showBorder = false;
         this._tooltip.add(this.btn_sortAlpha,this._lang.getString("crafting_sort_alpha"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         this.btn_sortLevel = new PushButton("",new BmpIconLevel());
         this.btn_sortLevel.data = "level";
         this.btn_sortLevel.showBorder = false;
         this._tooltip.add(this.btn_sortLevel,this._lang.getString("crafting_sort_level"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         this._globalSortButtons = new Vector.<PushButton>();
         this._globalSortButtons.push(this.btn_sortNew);
         this._globalSortButtons.push(this.btn_sortLevel);
         this._globalSortButtons.push(this.btn_sortAlpha);
         var _loc2_:PushButton = new PushButton("",new BmpIconDPS());
         _loc2_.data = "dps";
         _loc2_.showBorder = false;
         this._tooltip.add(_loc2_,this._lang.getString("crafting_sort_dps"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         this._weaponSortButtons = new Vector.<PushButton>();
         this._weaponSortButtons.push(_loc2_);
      }
      
      public function dispose() : void
      {
         var _loc1_:PushButton = null;
         if(parent != null)
         {
            parent.removeChild(this);
         }
         this._tooltip.removeAllFromParent(this);
         this._tooltip = null;
         this._lang = null;
         this.ui_list.dispose();
         this.ui_page.dispose();
         this.spin_quality.dispose();
         this.schematicSelected.removeAll();
         this._selectedSchematic = null;
         this._selectedSortButton = null;
         if(this._currentFilterButtons != null)
         {
            for each(_loc1_ in this._currentFilterButtons)
            {
               _loc1_.clicked.remove(this.onFilterSelected);
            }
            this._currentFilterButtons = null;
         }
         if(this._currentSortButtons != null)
         {
            for each(_loc1_ in this._currentSortButtons)
            {
               _loc1_.clicked.remove(this.onSortSelected);
            }
            this._currentSortButtons = null;
         }
      }
      
      public function setCategory(param1:String) : void
      {
         var _loc2_:PushButton = null;
         var _loc5_:int = 0;
         if(this._selectedCategory == param1)
         {
            return;
         }
         if(this._currentFilterButtons != null)
         {
            for each(_loc2_ in this._currentFilterButtons)
            {
               _loc2_.clicked.remove(this.onFilterSelected);
               if(_loc2_.parent != null)
               {
                  _loc2_.parent.removeChild(_loc2_);
               }
            }
         }
         if(this._currentSortButtons != null)
         {
            for each(_loc2_ in this._currentSortButtons)
            {
               _loc2_.clicked.remove(this.onSortSelected);
               if(_loc2_.parent != null)
               {
                  _loc2_.parent.removeChild(_loc2_);
               }
            }
         }
         this._selectedCategory = param1;
         var _loc3_:Vector.<PushButton> = this._globalFilterButtons.concat();
         var _loc4_:Vector.<PushButton> = this._globalSortButtons.concat();
         switch(this._selectedCategory)
         {
            case "weapon":
               _loc3_ = _loc3_.concat(this._weaponFilterButtons);
               _loc4_ = _loc4_.concat(this._weaponSortButtons);
         }
         this._currentFilterButtons = _loc3_;
         this._currentSortButtons = _loc4_;
         var _loc6_:int = 26;
         var _loc7_:int = 6;
         var _loc8_:int = int(this.ui_filterBg.y + (this.ui_filterBg.height - this.btn_filter_firearms.height) / 2);
         var _loc9_:int = 8;
         _loc5_ = 0;
         while(_loc5_ < this._currentFilterButtons.length)
         {
            _loc2_ = this._currentFilterButtons[_loc5_];
            _loc2_.clicked.add(this.onFilterSelected);
            _loc2_.width = _loc6_;
            _loc2_.x = _loc9_;
            _loc2_.y = _loc8_;
            _loc2_.selected = (this._filter & this.getFilterValue(_loc2_.data)) != 0;
            _loc9_ += _loc2_.width + _loc7_;
            addChild(_loc2_);
            _loc5_++;
         }
         var _loc10_:int = this.ui_filterBg.x + this.ui_filterBg.width - 8;
         _loc5_ = int(this._currentSortButtons.length - 1);
         while(_loc5_ >= 0)
         {
            _loc2_ = this._currentSortButtons[_loc5_];
            _loc2_.clicked.add(this.onSortSelected);
            _loc2_.width = _loc6_;
            _loc2_.x = _loc10_ - _loc2_.width;
            _loc2_.y = _loc8_;
            if(_loc2_.data == _defaultSortOption)
            {
               this._selectedSortButton = _loc2_;
               _loc2_.selected = true;
            }
            else
            {
               _loc2_.selected = false;
            }
            _loc10_ -= _loc2_.width + _loc7_;
            addChild(_loc2_);
            _loc5_--;
         }
         this.setQualityFilterForCategory(this._selectedCategory);
         if(this.spin_quality.visible)
         {
            this.spin_quality.y = int(this.ui_filterBg.y + (this.ui_filterBg.height - this.spin_quality.height) / 2);
            this.spin_quality.x = int(_loc9_ + (_loc10_ - _loc9_ - this.spin_quality.width) / 2);
         }
         this.updateFilterQuality();
         this._schematicList = this.applyFilter();
         this.applySort();
         this.ui_filterBg.visible = this.spin_quality.visible || this._currentSortButtons.length > 0 || this._currentSortButtons.length > 0;
         this.ui_list.schematics = this._schematicList;
         if(this._schematicList.length > 0)
         {
            this.ui_list.selectItem(0);
         }
         this.updatePagination();
         this.onSchematicSelected();
      }
      
      public function selectSchematic(param1:Schematic) : void
      {
         var _loc2_:int = int(this._schematicList.indexOf(param1));
         if(_loc2_ == -1)
         {
            return;
         }
         this.ui_list.selectItem(_loc2_);
         var _loc3_:int = this.ui_list.getSelectedItemPage();
         if(_loc3_ != this.ui_list.currentPage)
         {
            this.ui_page.currentPage = _loc3_;
            this.ui_list.gotoPage(_loc3_);
         }
         this.onSchematicSelected();
      }
      
      private function updatePagination() : void
      {
         this.ui_page.numPages = this.ui_list.numPages;
         this.ui_page.x = int(this.ui_list.x + (this.ui_list.width - this.ui_page.width) * 0.5);
      }
      
      private function updateFilterQuality() : void
      {
         var _loc1_:String = null;
         if(this._selectedCategory == "medical")
         {
            this._filterQuality = int(this.spin_quality.selectedData);
         }
         else
         {
            _loc1_ = String(this.spin_quality.selectedData);
            this._filterQuality = _loc1_ == "all" ? int.MIN_VALUE : int(ItemQualityType.getValue(_loc1_.toUpperCase()));
         }
      }
      
      private function setQualityFilterForCategory(param1:String) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         var _loc4_:* = null;
         var _loc5_:String = null;
         var _loc6_:uint = 0;
         this.spin_quality.clear();
         switch(param1)
         {
            case "weapon":
            case "gear":
            case "crafting":
            case "tactics":
               _loc2_ = 0;
               while(_loc2_ < _qualityList.length)
               {
                  _loc3_ = _qualityList[_loc2_];
                  _loc5_ = "COLOR_" + _loc3_.toUpperCase();
                  _loc6_ = _loc5_ in Effects ? uint(Effects[_loc5_]) : 16777215;
                  _loc4_ = "<font color=\'" + Color.colorToHex(_loc6_) + "\'>" + Language.getInstance().getString("itm_quality." + _loc3_) + "</font>";
                  this.spin_quality.addItem(_loc4_,_loc3_);
                  _loc2_++;
               }
               this.spin_quality.selectItem(0);
               this.spin_quality.visible = true;
               break;
            case "medical":
               _loc2_ = 0;
               while(_loc2_ < _medGradeList.length)
               {
                  _loc3_ = _medGradeList[_loc2_];
                  _loc4_ = int(_loc3_) <= 0 ? Language.getInstance().getString("med_grade_all") : Language.getInstance().getString("med_grade",_loc3_.toString());
                  this.spin_quality.addItem(_loc4_,_loc3_);
                  _loc2_++;
               }
               this.spin_quality.selectItem(0);
               this.spin_quality.visible = true;
               break;
            default:
               this.spin_quality.visible = false;
         }
      }
      
      private function sortByLimited(param1:Schematic, param2:Schematic) : int
      {
         var _loc5_:int = 0;
         var _loc3_:Date = param1.getExpiryDate();
         var _loc4_:Date = param2.getExpiryDate();
         if(_loc3_ != null && _loc4_ == null)
         {
            return -1;
         }
         if(_loc3_ == null && _loc4_ != null)
         {
            return 1;
         }
         if(_loc3_ != null && _loc4_ != null)
         {
            _loc5_ = int(_loc3_.time / 1000) - int(_loc4_.time / 1000);
            if(_loc5_ != 0)
            {
               return _loc5_;
            }
         }
         return param1.getMaxLevel() - param2.getMaxLevel();
      }
      
      private function sortByNew(param1:Schematic, param2:Schematic) : int
      {
         if(param1.isNew && !param2.isNew)
         {
            return -1;
         }
         if(!param1.isNew && param2.isNew)
         {
            return 1;
         }
         return 0;
      }
      
      private function sortByLevel(param1:Schematic, param2:Schematic) : int
      {
         return param2.outputItem.level - param1.outputItem.level;
      }
      
      private function sortByDPS(param1:Schematic, param2:Schematic) : int
      {
         this._weaponData.populate(null,Weapon(param1.outputItem));
         var _loc3_:int = int(this._weaponData.getDPS() * 1000);
         this._weaponData.populate(null,Weapon(param2.outputItem));
         var _loc4_:int = int(this._weaponData.getDPS() * 1000);
         return _loc4_ - _loc3_;
      }
      
      private function sortByName(param1:Schematic, param2:Schematic) : int
      {
         var _loc3_:String = param1.outputItem.getBaseName().toLowerCase();
         var _loc4_:String = param2.outputItem.getBaseName().toLowerCase();
         return _loc3_.localeCompare(_loc4_);
      }
      
      private function sortByQuantity(param1:Schematic, param2:Schematic) : int
      {
         return param2.outputItem.quantity - param1.outputItem.quantity;
      }
      
      private function applySort() : void
      {
         switch(this._selectedSortButton.data)
         {
            case "new":
               this._schematicList.sort(this.buildSortFunction(this.sortByLimited,this.sortByNew,this.sortByLevel,this.sortByName,this.sortByQuantity));
               break;
            case "alpha":
               this._schematicList.sort(this.buildSortFunction(this.sortByLimited,this.sortByName,this.sortByQuantity));
               break;
            case "level":
               this._schematicList.sort(this.buildSortFunction(this.sortByLimited,this.sortByLevel,this.sortByName,this.sortByQuantity));
               break;
            case "dps":
               this._schematicList.sort(this.buildSortFunction(this.sortByLimited,this.sortByDPS,this.sortByLevel,this.sortByName,this.sortByQuantity));
         }
      }
      
      private function buildSortFunction(... rest) : Function
      {
         var funcList:Array = rest;
         return function(param1:Schematic, param2:Schematic):int
         {
            var _loc4_:* = undefined;
            var _loc3_:* = 0;
            while(_loc3_ < funcList.length)
            {
               _loc4_ = funcList[_loc3_](param1,param2);
               if(_loc4_ != 0)
               {
                  return _loc4_;
               }
               _loc3_++;
            }
            return 0;
         };
      }
      
      private function applyFilter() : Vector.<Schematic>
      {
         var _loc6_:Schematic = null;
         var _loc7_:Date = null;
         var _loc8_:int = 0;
         var _loc9_:String = null;
         var _loc10_:Weapon = null;
         var _loc11_:MedicalItem = null;
         var _loc1_:Network = Network.getInstance();
         var _loc2_:Vector.<Schematic> = _loc1_.playerData.inventory.getSchematicsOfCategory(this._selectedCategory);
         var _loc3_:int = int(_loc1_.playerData.getPlayerSurvivor().level);
         var _loc4_:Vector.<Schematic> = new Vector.<Schematic>();
         var _loc5_:int = 0;
         for(; _loc5_ < _loc2_.length; _loc5_++)
         {
            _loc6_ = _loc2_[_loc5_];
            _loc7_ = _loc6_.getExpiryDate();
            if(!(_loc7_ != null && _loc1_.serverTime > _loc7_.time))
            {
               _loc8_ = _loc6_.getMaxLevel();
               if(!(_loc8_ > 0 && _loc3_ > _loc8_))
               {
                  if(!(this._filter & this.FILTER_LOCKED))
                  {
                     if(!_loc1_.playerData.meetsRequirements(_loc6_.getNonItemRequirements()))
                     {
                        continue;
                     }
                  }
                  _loc9_ = _loc6_.outputItem.category;
                  if(_loc9_ == "weapon")
                  {
                     _loc10_ = _loc6_.outputItem as Weapon;
                     if(!(this._filter & this.FILTER_MELEE) && _loc10_.weaponClass == WeaponClass.MELEE)
                     {
                        continue;
                     }
                     if(!(this._filter & this.FILTER_FIREARMS) && _loc10_.weaponClass != WeaponClass.MELEE)
                     {
                        continue;
                     }
                  }
                  if(_loc9_ == "medical")
                  {
                     _loc11_ = MedicalItem(_loc6_.outputItem);
                     if(this._filterQuality > 0 && _loc11_.medicalGrade != this._filterQuality)
                     {
                        continue;
                     }
                  }
                  else if(this._filterQuality > int.MIN_VALUE && _loc6_.outputItem.qualityType != this._filterQuality)
                  {
                     continue;
                  }
                  _loc4_.push(_loc6_);
               }
            }
         }
         return _loc4_;
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
         if(this._selectedCategory == "weapon" && !(this._filter & this.FILTER_MELEE) && !(this._filter & this.FILTER_FIREARMS))
         {
            if(_loc3_ == this.FILTER_FIREARMS)
            {
               this._filter |= this.FILTER_MELEE;
               this.btn_filter_melee.selected = true;
            }
            else
            {
               this._filter |= this.FILTER_FIREARMS;
               this.btn_filter_firearms.selected = true;
            }
         }
         this.updateFilterQuality();
         this._schematicList = this.applyFilter();
         this.applySort();
         this.ui_list.schematics = this._schematicList;
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
         this.ui_list.schematics = this._schematicList;
         this.updatePagination();
      }
      
      private function onQualityChanged() : void
      {
         this.updateFilterQuality();
         this._schematicList = this.applyFilter();
         this.applySort();
         this.ui_list.schematics = this._schematicList;
         this.updatePagination();
      }
      
      private function onSchematicSelected() : void
      {
         var _loc1_:UISchematicListItem = this.ui_list.selectedItem as UISchematicListItem;
         this._selectedSchematic = _loc1_ != null ? _loc1_.schematic : null;
         this.schematicSelected.dispatch(this._selectedSchematic);
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
      
      public function get schematicList() : Vector.<Schematic>
      {
         return this._schematicList;
      }
      
      public function get selectedSchematic() : Schematic
      {
         return this._selectedSchematic;
      }
   }
}

