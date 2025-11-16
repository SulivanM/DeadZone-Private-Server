package thelaststand.app.game.gui.survivor
{
   import com.deadreckoned.threshold.display.Color;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.AttributeClass;
   import thelaststand.app.game.data.AttributeOptions;
   import thelaststand.app.game.data.Attributes;
   import thelaststand.app.game.data.ItemAttributes;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorLoadout;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.utils.DictionaryUtils;
   import thelaststand.common.lang.Language;
   
   public class UIPlayerSkillsTable extends Sprite implements IUISkillsTable
   {
      
      private const DEFAULT_ATTRIBUTES:Attributes = new Attributes();
      
      private var _modifiedAttributeValues:Dictionary;
      
      private var _points:int;
      
      private var _showModifyButtons:Boolean;
      
      private var _survivor:Survivor;
      
      private var _loadout:SurvivorLoadout;
      
      private var _rows:Vector.<Sprite>;
      
      private var _rowsById:Dictionary;
      
      private var _rowColor:uint = 1447446;
      
      private var _rowHeight:int = 20;
      
      private var _width:int;
      
      private var _height:int;
      
      public var attributeModified:Signal;
      
      public function UIPlayerSkillsTable(param1:int)
      {
         super();
         this._width = param1;
         this._rows = new Vector.<Sprite>();
         this._rowsById = new Dictionary(true);
         mouseEnabled = false;
         this._modifiedAttributeValues = new Dictionary(true);
         this.attributeModified = new Signal(String);
         this.createTable();
      }
      
      public function dispose() : void
      {
         var _loc1_:TableRow = null;
         TooltipManager.getInstance().removeAllFromParent(this,true);
         if(parent != null)
         {
            parent.removeChild(this);
         }
         this.attributeModified.removeAll();
         for each(_loc1_ in this._rows)
         {
            _loc1_.dispose();
         }
         this._rows = null;
         this._rowsById = null;
         this._survivor = null;
         this._loadout = null;
      }
      
      public function getModifiedAttriutes() : Object
      {
         var _loc2_:String = null;
         var _loc1_:Object = {};
         for(_loc2_ in this._modifiedAttributeValues)
         {
            if(this._modifiedAttributeValues[_loc2_] > 0)
            {
               _loc1_[_loc2_] = int(this._modifiedAttributeValues[_loc2_]);
            }
         }
         return _loc1_;
      }
      
      public function setSurvivor(param1:Survivor, param2:SurvivorLoadout) : void
      {
         var _loc3_:String = null;
         DictionaryUtils.clear(this._modifiedAttributeValues);
         for each(_loc3_ in AttributeClass.getAttributeClasses())
         {
            this._modifiedAttributeValues[_loc3_] = 0;
         }
         this._survivor = param1;
         this._loadout = param2;
         this.refresh();
      }
      
      public function refresh() : void
      {
         this.updateAttributes();
         this.updateTooltips();
         this.updateModifyButtonStates();
      }
      
      private function createTable() : void
      {
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:TableRow = null;
         var _loc1_:Language = Language.getInstance();
         var _loc2_:int = 0;
         var _loc3_:Array = AttributeClass.getAttributeClasses();
         var _loc4_:int = 0;
         var _loc5_:int = int(_loc3_.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc3_[_loc4_];
            _loc7_ = _loc1_.getString("att_classes." + _loc6_.toLowerCase()).toUpperCase();
            _loc8_ = new TableRow(this._width,this._rowHeight,_loc7_,this._rowColor,_loc4_ % 2 == 0 ? 1 : 0,this._showModifyButtons);
            _loc8_.btn_decrease.data = "decrease_" + _loc6_;
            _loc8_.btn_decrease.clicked.add(this.onModifyButtonClicked);
            _loc8_.btn_increase.data = "increase_" + _loc6_;
            _loc8_.btn_increase.clicked.add(this.onModifyButtonClicked);
            _loc8_.attribute = _loc6_;
            _loc8_.y = _loc2_;
            addChild(_loc8_);
            this._rows.push(_loc8_);
            this._rowsById[_loc6_] = _loc8_;
            _loc2_ += this._rowHeight + 1;
            _loc4_++;
         }
         this._height = _loc2_;
      }
      
      private function updateTooltips() : void
      {
         var _loc2_:TableRow = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:Array = null;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:String = null;
         var _loc1_:Language = Language.getInstance();
         for each(_loc2_ in this._rows)
         {
            _loc3_ = "";
            _loc4_ = "";
            _loc5_ = AttributeClass[_loc2_.attribute];
            _loc6_ = 0;
            _loc7_ = 0;
            _loc8_ = 0;
            _loc9_ = int(_loc5_.length);
            _loc10_ = 0;
            while(_loc10_ < _loc9_)
            {
               _loc13_ = _loc5_[_loc10_];
               _loc3_ += "<b>" + _loc1_.getString("att." + _loc13_) + "</b><br/>" + _loc1_.getString("att_desc." + _loc13_) + (_loc10_ < _loc5_.length - 1 ? "<br/><br/>" : "");
               _loc6_ += this._survivor.getAttribute(_loc13_,false,AttributeOptions.INCLUDE_NONE);
               _loc7_ += this._survivor.getAttribute(_loc13_,false,AttributeOptions.INCLUDE_MORALE);
               _loc8_ += this._survivor.getAttribute(_loc13_,false,AttributeOptions.INCLUDE_INJURIES);
               if(this._loadout.isAttributeAffectedByGear(ItemAttributes.GROUP_SURVIVOR,_loc13_))
               {
                  _loc4_ += this._loadout.getAffectedAttributeDescription(ItemAttributes.GROUP_SURVIVOR,_loc13_);
               }
               _loc10_++;
            }
            _loc6_ /= _loc9_;
            _loc7_ /= _loc9_;
            _loc8_ /= _loc9_;
            _loc11_ = Math.floor((_loc7_ - _loc6_) / _loc6_ * 100);
            if(_loc11_ != 0)
            {
               _loc3_ += "<br/><br/><font color=\'" + Color.colorToHex(_loc11_ < 0 ? Effects.COLOR_WARNING : Effects.COLOR_GOOD) + "\'>" + _loc1_.getString("tooltip.morale_mod",(_loc11_ < 0 ? "" : "+") + _loc11_) + "</font>";
            }
            _loc12_ = Math.floor((_loc8_ - _loc6_) / _loc6_ * 100);
            if(_loc12_ != 0)
            {
               _loc3_ += "<br/><font color=\'" + Color.colorToHex(_loc12_ < 0 ? Effects.COLOR_WARNING : Effects.COLOR_GOOD) + "\'>" + _loc1_.getString("tooltip.injury_mod",(_loc12_ < 0 ? "" : "+") + _loc12_) + "</font>";
            }
            if(_loc4_.length > 0)
            {
               _loc3_ += "<br/><br/>" + _loc4_;
            }
            TooltipManager.getInstance().add(_loc2_,_loc3_,new Point(_loc2_.width,NaN),TooltipDirection.DIRECTION_LEFT);
         }
      }
      
      private function updateAttributes() : void
      {
         var _loc1_:String = null;
         var _loc2_:Array = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:TableRow = null;
         var _loc11_:String = null;
         var _loc12_:Number = NaN;
         for each(_loc1_ in AttributeClass.getAttributeClasses())
         {
            _loc2_ = AttributeClass[_loc1_];
            _loc3_ = 0;
            _loc4_ = 0;
            _loc5_ = 0;
            _loc6_ = 0;
            _loc7_ = 0;
            _loc8_ = int(_loc2_.length);
            _loc9_ = 0;
            while(_loc9_ < _loc8_)
            {
               _loc11_ = _loc2_[_loc9_];
               _loc12_ = this._modifiedAttributeValues[_loc1_] / 10;
               _loc7_ += this._survivor.getAttribute(_loc11_,this._loadout,AttributeOptions.INCLUDE_NONE) + _loc12_;
               _loc3_ += this._survivor.getAttributeWithBase(_loc11_,_loc7_,this._loadout,AttributeOptions.INCLUDE_ALL);
               _loc4_ += this._survivor.getAttribute(_loc11_,this._loadout,AttributeOptions.INCLUDE_NONE);
               _loc5_ += this._survivor.getAttribute(_loc11_,false,AttributeOptions.INCLUDE_NONE);
               _loc6_ += this._survivor.getAttribute(_loc11_,false,AttributeOptions.INCLUDE_MORALE | AttributeOptions.INCLUDE_INJURIES);
               _loc9_++;
            }
            _loc7_ /= _loc8_;
            _loc3_ /= _loc8_;
            _loc4_ /= _loc8_;
            _loc5_ /= _loc8_;
            _loc6_ /= _loc8_;
            _loc10_ = this._rowsById[_loc1_];
            _loc10_.baseValue = Math.floor(_loc7_ * 10);
            _loc10_.moddedValue = Math.floor(_loc3_ * 10);
            _loc10_.alpha = _loc10_.moddedValue == 0 ? 0.4 : 1;
            _loc10_.baseValueColor = this._modifiedAttributeValues[_loc1_] > 0 ? 4443629 : 14803425;
            _loc10_.moddedValueColor = this._modifiedAttributeValues[_loc1_] > 0 ? 4443629 : (_loc5_ == _loc6_ ? 11908533 : (_loc6_ < _loc5_ ? Effects.COLOR_WARNING : Effects.COLOR_GOOD));
            _loc10_.labelColor = _loc5_ == _loc4_ ? 11908533 : (_loc4_ < _loc5_ ? Effects.COLOR_WARNING : Effects.COLOR_GOOD);
         }
      }
      
      private function updateModifyButtonStates() : void
      {
         var _loc1_:TableRow = null;
         for each(_loc1_ in this._rows)
         {
            _loc1_.btn_increase.enabled = this._points > 0;
            _loc1_.btn_decrease.enabled = this._modifiedAttributeValues[_loc1_.attribute] > 0;
         }
      }
      
      private function onModifyButtonClicked(param1:MouseEvent) : void
      {
         var _loc2_:PushButton = PushButton(param1.currentTarget);
         var _loc3_:Array = String(_loc2_.data).split("_");
         var _loc4_:String = _loc3_[1];
         var _loc5_:int = 0;
         switch(_loc3_[0])
         {
            case "increase":
               if(this._points <= 0)
               {
                  return;
               }
               ++this._modifiedAttributeValues[_loc4_];
               --this._points;
               this.attributeModified.dispatch(_loc4_);
               break;
            case "decrease":
               _loc5_ = int(this._modifiedAttributeValues[_loc4_]);
               if(_loc5_ <= 0)
               {
                  this._modifiedAttributeValues[_loc4_] = 0;
                  return;
               }
               --this._modifiedAttributeValues[_loc4_];
               ++this._points;
               this.attributeModified.dispatch(_loc4_);
         }
         this.updateAttributes();
         this.updateModifyButtonStates();
      }
      
      public function get points() : int
      {
         return this._points;
      }
      
      public function set points(param1:int) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         this._points = param1;
         this.refresh();
      }
      
      public function get showModifyButtons() : Boolean
      {
         return this._showModifyButtons;
      }
      
      public function set showModifyButtons(param1:Boolean) : void
      {
         var _loc2_:TableRow = null;
         this._showModifyButtons = param1;
         for each(_loc2_ in this._rows)
         {
            _loc2_.showModifyButtons = this._showModifyButtons;
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
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
   }
}

import flash.display.Sprite;
import flash.text.AntiAliasType;
import thelaststand.app.display.BodyTextField;
import thelaststand.app.display.Effects;
import thelaststand.app.display.TitleTextField;
import thelaststand.app.gui.buttons.PushButton;

class TableRow extends Sprite
{
   
   private var _showModButtons:Boolean;
   
   private var _baseValue:Number = 0;
   
   private var _moddedValue:Number = 0;
   
   private var _width:int;
   
   private var _height:int;
   
   private var txt_label:TitleTextField;
   
   private var txt_moddedValue:BodyTextField;
   
   private var txt_baseValue:BodyTextField;
   
   public var attribute:String;
   
   public var btn_increase:PushButton;
   
   public var btn_decrease:PushButton;
   
   public function TableRow(param1:int, param2:int, param3:String, param4:int, param5:Number, param6:Boolean = false)
   {
      super();
      this._width = param1;
      this._height = param2;
      graphics.beginFill(param4,param5);
      graphics.drawRect(0,0,this._width,this._height);
      graphics.endFill();
      this.txt_label = new TitleTextField({
         "color":11908533,
         "size":16,
         "antiAliasType":AntiAliasType.ADVANCED
      });
      this.txt_label.text = param3;
      this.txt_label.x = 2;
      this.txt_label.y = -1;
      this.txt_label.filters = [Effects.TEXT_SHADOW];
      addChild(this.txt_label);
      this.btn_decrease = new PushButton("-");
      this.btn_increase = new PushButton("+");
      this.btn_decrease.enabled = this.btn_increase.enabled = false;
      this.btn_decrease.showBorder = this.btn_increase.showBorder = false;
      this.btn_decrease.width = this.btn_increase.width = this.btn_decrease.height = this.btn_increase.height = int(param2 - 6);
      this.btn_increase.x = int(this._width - this.btn_increase.width - 2);
      this.btn_decrease.x = int(this.btn_increase.x - this.btn_increase.width - 30);
      this.btn_increase.y = this.btn_decrease.y = int(param2 - this.btn_increase.height) * 0.5;
      this.txt_baseValue = new BodyTextField({
         "color":11908533,
         "size":14,
         "antiAliasType":AntiAliasType.ADVANCED
      });
      this.txt_baseValue.text = "0";
      this.txt_baseValue.y = this.txt_label.y;
      this.txt_baseValue.filters = [Effects.TEXT_SHADOW];
      this.txt_baseValue.visible = this._showModButtons;
      addChild(this.txt_baseValue);
      this.txt_moddedValue = new BodyTextField({
         "color":11908533,
         "size":14,
         "antiAliasType":AntiAliasType.ADVANCED
      });
      this.txt_moddedValue.text = "0";
      this.txt_moddedValue.y = this.txt_label.y;
      this.txt_moddedValue.filters = [Effects.TEXT_SHADOW];
      addChild(this.txt_moddedValue);
      this.showModifyButtons = this._showModButtons;
   }
   
   public function dispose() : void
   {
      this.txt_moddedValue.dispose();
      this.txt_moddedValue = null;
      this.txt_label.dispose();
      this.txt_label = null;
      this.btn_increase.dispose();
      this.btn_increase = null;
      this.btn_decrease.dispose();
      this.btn_decrease = null;
   }
   
   public function get showModifyButtons() : Boolean
   {
      return this._showModButtons;
   }
   
   public function set showModifyButtons(param1:Boolean) : void
   {
      this._showModButtons = param1;
      if(this._showModButtons)
      {
         addChild(this.btn_increase);
         addChild(this.btn_decrease);
      }
      else
      {
         if(this.btn_increase.parent != null)
         {
            this.btn_increase.parent.removeChild(this.btn_increase);
         }
         if(this.btn_decrease.parent != null)
         {
            this.btn_decrease.parent.removeChild(this.btn_decrease);
         }
      }
      this.updateValuePositioning();
   }
   
   private function updateValuePositioning() : void
   {
      var _loc1_:int = 0;
      if(this._showModButtons)
      {
         this.txt_baseValue.visible = true;
         _loc1_ = this.btn_decrease.x + this.btn_decrease.width;
         this.txt_baseValue.x = int(_loc1_ + (this.btn_increase.x - _loc1_ - this.txt_baseValue.width) * 0.5);
         this.txt_moddedValue.x = int(this.btn_decrease.x - 20 - this.txt_moddedValue.width * 0.5);
      }
      else
      {
         this.txt_baseValue.visible = false;
         this.txt_baseValue.x = 0;
         this.txt_moddedValue.x = int(this._width - this.txt_moddedValue.width - 2);
         if(this.btn_increase.parent != null)
         {
            this.btn_increase.parent.removeChild(this.btn_increase);
         }
         if(this.btn_decrease.parent != null)
         {
            this.btn_decrease.parent.removeChild(this.btn_decrease);
         }
      }
   }
   
   public function get labelColor() : uint
   {
      return this.txt_label.textColor;
   }
   
   public function set labelColor(param1:uint) : void
   {
      this.txt_label.textColor = param1;
   }
   
   public function get baseValue() : int
   {
      return this._baseValue;
   }
   
   public function set baseValue(param1:int) : void
   {
      this._baseValue = param1;
      this.txt_baseValue.text = this._baseValue.toString();
      this.updateValuePositioning();
   }
   
   public function get baseValueColor() : uint
   {
      return this.txt_baseValue.textColor;
   }
   
   public function set baseValueColor(param1:uint) : void
   {
      this.txt_baseValue.textColor = param1;
   }
   
   public function get moddedValue() : int
   {
      return this._moddedValue;
   }
   
   public function set moddedValue(param1:int) : void
   {
      this._moddedValue = param1;
      this.txt_moddedValue.text = this._moddedValue.toString();
      this.updateValuePositioning();
   }
   
   public function get moddedValueColor() : uint
   {
      return this.txt_moddedValue.textColor;
   }
   
   public function set moddedValueColor(param1:uint) : void
   {
      this.txt_moddedValue.textColor = param1;
   }
}
