package thelaststand.app.game.gui.inventory
{
   import com.deadreckoned.threshold.display.Color;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.itemfilters.WeaponsFilterData;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIInputField;
   import thelaststand.app.gui.UISpinner;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.network.Network;
   import thelaststand.common.lang.Language;
   
   public class UIInventoryWeaponFilter extends UIInventoryFilter
   {
      
      private static const _qualityList:Array = ["all","grey","white","green","blue","purple","rare","unique","infamous","premium"];
      
      private var txt_level:BodyTextField;
      
      private var txt_levelDash:BodyTextField;
      
      private var txt_quality:BodyTextField;
      
      private var input_levelMin:UIInputField;
      
      private var input_levelMax:UIInputField;
      
      private var spin_quality:UISpinner;
      
      private var btn_melee:PushButton;
      
      private var btn_firearms:PushButton;
      
      private var btn_sortAlpha:PushButton;
      
      private var btn_sortLevel:PushButton;
      
      private var btn_sortDPS:PushButton;
      
      public function UIInventoryWeaponFilter()
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:uint = 0;
         var _loc6_:* = null;
         super();
         var _loc1_:Language = Language.getInstance();
         this.txt_level = new BodyTextField({
            "text":_loc1_.getString("inv_filter.level").toUpperCase(),
            "color":11974326,
            "size":13,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW]
         });
         addChild(this.txt_level);
         this.input_levelMin = new UIInputField({
            "text":"1",
            "font":_loc1_.getFontName("body"),
            "bold":true,
            "size":14,
            "color":12698049,
            "align":"center"
         });
         this.input_levelMin.width = 30;
         this.input_levelMin.height = height;
         this.input_levelMin.backgroundColor = 2171169;
         this.input_levelMin.textField.restrict = "0-9";
         this.input_levelMin.textField.addEventListener(FocusEvent.FOCUS_IN,this.onInputLevelFocusIn,false,0,true);
         this.input_levelMin.textField.addEventListener(FocusEvent.FOCUS_OUT,this.onInputLevelFocusOut,false,0,true);
         this.input_levelMin.enterPressed.add(this.onInputLevelMinEnterPressed);
         this.input_levelMin.tabIndex = 0;
         addChild(this.input_levelMin);
         this.txt_levelDash = new BodyTextField({
            "text":"-",
            "color":11974326,
            "size":13,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW]
         });
         addChild(this.txt_levelDash);
         this.input_levelMax = new UIInputField({
            "text":"50",
            "font":_loc1_.getFontName("body"),
            "bold":true,
            "size":14,
            "color":12698049,
            "align":"center"
         });
         this.input_levelMax.width = this.input_levelMin.width;
         this.input_levelMax.height = this.input_levelMin.height;
         this.input_levelMax.backgroundColor = 2171169;
         this.input_levelMax.textField.restrict = "0-9";
         this.input_levelMax.textField.addEventListener(FocusEvent.FOCUS_IN,this.onInputLevelFocusIn,false,0,true);
         this.input_levelMax.textField.addEventListener(FocusEvent.FOCUS_OUT,this.onInputLevelFocusOut,false,0,true);
         this.input_levelMax.enterPressed.add(this.onInputLevelMaxEnterPressed);
         this.input_levelMax.tabIndex = 1;
         addChild(this.input_levelMax);
         this.txt_quality = new BodyTextField({
            "text":_loc1_.getString("inv_filter.quality").toUpperCase(),
            "color":11974326,
            "size":13,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW]
         });
         addChild(this.txt_quality);
         this.spin_quality = new UISpinner();
         this.spin_quality.width = 148;
         this.spin_quality.changed.add(this.onQualityChanged);
         var _loc2_:int = 0;
         while(_loc2_ < _qualityList.length)
         {
            _loc3_ = _qualityList[_loc2_];
            _loc4_ = "COLOR_" + _loc3_.toUpperCase();
            _loc5_ = _loc4_ in Effects ? uint(Effects[_loc4_]) : 16777215;
            _loc6_ = "<font color=\'" + Color.colorToHex(_loc5_) + "\'>" + _loc1_.getString("itm_quality." + _loc3_) + "</font>";
            this.spin_quality.addItem(_loc6_,_loc3_);
            _loc2_++;
         }
         addChild(this.spin_quality);
         this.btn_melee = new PushButton(null,new BmpIconMelee());
         this.btn_melee.clicked.add(this.onClickToggleOption);
         this.btn_melee.width = this.btn_melee.height = height;
         this.btn_melee.data = "melee";
         addChild(this.btn_melee);
         TooltipManager.getInstance().add(this.btn_melee,_loc1_.getString("inv_filter.melee"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         this.btn_firearms = new PushButton(null,new BmpIconFirearms());
         this.btn_firearms.clicked.add(this.onClickToggleOption);
         this.btn_firearms.width = this.btn_firearms.height = this.btn_melee.width;
         this.btn_firearms.data = "firearms";
         addChild(this.btn_firearms);
         TooltipManager.getInstance().add(this.btn_firearms,_loc1_.getString("inv_filter.firearms"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         this.btn_sortAlpha = new PushButton("",new BmpIconSortAlpha());
         this.btn_sortAlpha.clicked.add(this.onClickSortOption);
         this.btn_sortAlpha.width = this.btn_sortAlpha.height = this.btn_melee.width;
         this.btn_sortAlpha.data = "alpha";
         addChild(this.btn_sortAlpha);
         TooltipManager.getInstance().add(this.btn_sortAlpha,_loc1_.getString("crafting_sort_alpha"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         this.btn_sortLevel = new PushButton("",new BmpIconLevel());
         this.btn_sortLevel.clicked.add(this.onClickSortOption);
         this.btn_sortLevel.width = this.btn_sortLevel.height = this.btn_melee.width;
         this.btn_sortLevel.data = "level";
         addChild(this.btn_sortLevel);
         TooltipManager.getInstance().add(this.btn_sortLevel,_loc1_.getString("crafting_sort_level"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         this.btn_sortDPS = new PushButton("",new BmpIconDPS());
         this.btn_sortDPS.clicked.add(this.onClickSortOption);
         this.btn_sortDPS.width = this.btn_sortDPS.height = this.btn_melee.width;
         this.btn_sortDPS.data = "dps";
         addChild(this.btn_sortDPS);
         TooltipManager.getInstance().add(this.btn_sortDPS,_loc1_.getString("crafting_sort_dps"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.txt_level.dispose();
         this.txt_levelDash.dispose();
         this.txt_quality.dispose();
         this.btn_firearms.dispose();
         this.btn_melee.dispose();
         this.spin_quality.dispose();
         this.btn_sortAlpha.dispose();
         this.btn_sortLevel.dispose();
         this.btn_sortDPS.dispose();
      }
      
      override protected function draw() : void
      {
         this.txt_level.x = 0;
         this.txt_level.y = int((height - this.txt_level.height) * 0.5);
         this.input_levelMin.x = int(this.txt_level.x + this.txt_level.width + 4);
         this.input_levelMin.y = int((height - this.input_levelMin.height) * 0.5);
         this.txt_levelDash.x = int(this.input_levelMin.x + this.input_levelMin.width + 1);
         this.txt_levelDash.y = int((height - this.txt_levelDash.height) * 0.5);
         this.input_levelMax.x = int(this.txt_levelDash.x + this.txt_levelDash.width + 1);
         this.input_levelMax.y = int(this.input_levelMin.y);
         if(_width < 478)
         {
            this.txt_quality.x = this.txt_quality.y = 0;
            this.txt_quality.visible = false;
            this.spin_quality.x = int(this.input_levelMax.x + this.input_levelMax.width + 8);
         }
         else
         {
            this.txt_quality.x = int(this.input_levelMax.x + this.input_levelMax.width + 10);
            this.txt_quality.y = int((height - this.txt_quality.height) * 0.5);
            this.txt_quality.visible = true;
            this.spin_quality.x = int(this.txt_quality.x + this.txt_quality.width + 2);
         }
         this.spin_quality.y = int((height - this.spin_quality.height) * 0.5);
         this.btn_sortDPS.x = int(_width - this.btn_sortDPS.width - 2);
         this.btn_sortDPS.y = int((height - this.btn_melee.height) * 0.5);
         this.btn_sortAlpha.x = int(this.btn_sortDPS.x - this.btn_sortAlpha.width - 8);
         this.btn_sortAlpha.y = int(this.btn_sortDPS.y);
         this.btn_sortLevel.x = int(this.btn_sortAlpha.x - this.btn_sortLevel.width - 8);
         this.btn_sortLevel.y = int(this.btn_sortDPS.y);
         this.btn_firearms.x = int(this.btn_sortLevel.x - this.btn_firearms.width - 18);
         this.btn_firearms.y = int(this.btn_sortDPS.y);
         this.btn_melee.x = int(this.btn_firearms.x - this.btn_melee.width - 8);
         this.btn_melee.y = int(this.btn_sortDPS.y);
      }
      
      private function setToCurrentFilterValues() : void
      {
         var _loc1_:WeaponsFilterData = WeaponsFilterData(_filterData);
         this.input_levelMin.value = (_loc1_.levelMin + 1).toString();
         this.input_levelMax.value = (Math.min(Network.getInstance().playerData.getPlayerSurvivor().levelMax,_loc1_.levelMax) + 1).toString();
         this.btn_melee.selected = _loc1_.melee;
         this.btn_firearms.selected = _loc1_.firearms;
         this.spin_quality.selectItemByData(_loc1_.quality);
         this.btn_sortAlpha.selected = _loc1_.sortField == this.btn_sortAlpha.data;
         this.btn_sortLevel.selected = _loc1_.sortField == this.btn_sortLevel.data;
         this.btn_sortDPS.selected = _loc1_.sortField == this.btn_sortDPS.data;
      }
      
      private function setLevelMinFilterFromInput() : void
      {
         var _loc1_:int = int(this.input_levelMin.value);
         if(_loc1_ < 1)
         {
            _loc1_ = 1;
         }
         this.input_levelMin.value = _loc1_.toString();
         WeaponsFilterData(_filterData).levelMin = _loc1_ - 1;
         if(int(this.input_levelMax.value) < int(this.input_levelMin.value))
         {
            this.input_levelMax.value = _loc1_.toString();
            WeaponsFilterData(_filterData).levelMax = _loc1_ - 1;
         }
         changed.dispatch();
      }
      
      private function setLevelMaxFilterFromInput() : void
      {
         var _loc1_:int = int(this.input_levelMax.value);
         var _loc2_:int = Network.getInstance().playerData.getPlayerSurvivor().levelMax + 1;
         if(_loc1_ > _loc2_)
         {
            _loc1_ = _loc2_;
         }
         this.input_levelMax.value = _loc1_.toString();
         WeaponsFilterData(_filterData).levelMax = _loc1_ - 1;
         if(int(this.input_levelMax.value) < int(this.input_levelMin.value))
         {
            this.input_levelMin.value = _loc1_.toString();
            WeaponsFilterData(_filterData).levelMin = _loc1_ - 1;
         }
         changed.dispatch();
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.setToCurrentFilterValues();
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
      }
      
      private function onClickSortOption(param1:MouseEvent) : void
      {
         var _loc2_:PushButton = PushButton(param1.currentTarget);
         var _loc3_:WeaponsFilterData = WeaponsFilterData(_filterData);
         if(_loc3_.sortField == _loc2_.data)
         {
            return;
         }
         _loc3_.sortField = _loc2_.data;
         this.btn_sortAlpha.selected = _loc3_.sortField == this.btn_sortAlpha.data;
         this.btn_sortLevel.selected = _loc3_.sortField == this.btn_sortLevel.data;
         this.btn_sortDPS.selected = _loc3_.sortField == this.btn_sortDPS.data;
         changed.dispatch();
      }
      
      private function onClickToggleOption(param1:MouseEvent) : void
      {
         var _loc2_:WeaponsFilterData = WeaponsFilterData(_filterData);
         switch(param1.currentTarget)
         {
            case this.btn_firearms:
               _loc2_.firearms = !_loc2_.firearms;
               _loc2_.melee = true;
               break;
            case this.btn_melee:
               _loc2_.melee = !_loc2_.melee;
               _loc2_.firearms = true;
         }
         this.btn_melee.selected = _loc2_.melee;
         this.btn_firearms.selected = _loc2_.firearms;
         changed.dispatch();
      }
      
      private function onQualityChanged() : void
      {
         var _loc1_:WeaponsFilterData = WeaponsFilterData(_filterData);
         _loc1_.quality = this.spin_quality.selectedData;
         changed.dispatch();
      }
      
      private function onInputLevelFocusIn(param1:FocusEvent) : void
      {
         TextField(param1.currentTarget).text = "";
      }
      
      private function onInputLevelFocusOut(param1:FocusEvent) : void
      {
         var _loc2_:int = 0;
         switch(param1.currentTarget.parent)
         {
            case this.input_levelMin:
               this.setLevelMinFilterFromInput();
               break;
            case this.input_levelMax:
               this.setLevelMaxFilterFromInput();
         }
      }
      
      private function onInputLevelMinEnterPressed() : void
      {
         if(stage != null && stage.focus == this.input_levelMin.textField)
         {
            stage.focus = null;
         }
      }
      
      private function onInputLevelMaxEnterPressed() : void
      {
         if(stage != null && stage.focus == this.input_levelMax.textField)
         {
            stage.focus = null;
         }
      }
   }
}

