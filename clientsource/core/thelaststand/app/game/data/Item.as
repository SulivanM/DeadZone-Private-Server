package thelaststand.app.game.data
{
   import com.deadreckoned.threshold.display.Color;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   import playerio.PlayerIOError;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.core.Config;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.game.data.quests.MiniTask;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.game.gui.dialogues.AutoProgressBarDialogue;
   import thelaststand.app.game.logic.MiniTaskSystem;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.PaymentSystem;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.app.utils.StringUtils;
   import thelaststand.common.io.ISerializable;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.ResourceManager;
   
   public class Item implements IRecyclable, ISerializable
   {
      
      private static const MAX_MODS:int = 3;
      
      private static var _lowMods:Array = ["noise","rate","rldtime","ammo_cost","injuryChance","rng_min_eff","ready"];
      
      private static var _reverseSignMods:Array = ["rate","rldtime"];
      
      protected var _type:String;
      
      protected var _itemType:String;
      
      protected var _xml:XML;
      
      protected var _craftData:CraftingInfo;
      
      protected var _baseLevel:int;
      
      protected var _bought:Boolean;
      
      protected var _id:String;
      
      protected var _craftingTimer:TimerData;
      
      protected var _mods:Vector.<String>;
      
      protected var _new:Boolean;
      
      protected var _rarity:int;
      
      protected var _qualityType:int;
      
      protected var _quantifiable:Boolean;
      
      protected var _isVintage:Boolean;
      
      protected var _level:int;
      
      protected var _isUpgradable:Boolean;
      
      protected var _specialData:ItemBonusStats;
      
      protected var _name:String;
      
      protected var _nameBase:String;
      
      protected var _stackLimit:int = 0;
      
      protected var _minLevel:int = 0;
      
      protected var _maxLevel:int = 0;
      
      protected var _attributes:ItemAttributes;
      
      protected var _sounds:Dictionary;
      
      protected var _isTradable:Boolean = true;
      
      protected var _isDisposable:Boolean = true;
      
      protected var _bindState:uint = 0;
      
      protected var _counterType:uint;
      
      protected var _counterValue:int;
      
      public var quantity:uint = 1;
      
      public var bindStateChanged:Signal = new Signal(Item);
      
      public function Item(param1:String = null)
      {
         super();
         this._id = GUID.create().toUpperCase();
         this._mods = new Vector.<String>(MAX_MODS,true);
         this._attributes = new ItemAttributes();
         if(param1 != null)
         {
            this.setXML(ItemFactory.getItemDefinition(param1));
         }
      }
      
      public static function calcLeveledValue(param1:Number, param2:Number, param3:int, param4:int = 0) : Number
      {
         var _loc5_:Number = param1;
         var _loc6_:int = 1;
         while(_loc6_ <= param3 - param4)
         {
            _loc5_ *= param2;
            _loc6_++;
         }
         return _loc5_;
      }
      
      public static function createCraftingKitVariant(param1:Item, param2:Item) : Item
      {
         var _loc3_:Item = param1.clone();
         _loc3_._mods[2] = param2.xml.kit.mod.toString();
         _loc3_.updateAttributes();
         return _loc3_;
      }
      
      private static function applyBonusStatCap(param1:Number, param2:Number) : Number
      {
         if(param2 > -1 && param1 > param2)
         {
            return param2;
         }
         return param1;
      }
      
      public function clone() : Item
      {
         var _loc1_:Item = new Item(this._type);
         this.cloneBaseProperties(_loc1_);
         return _loc1_;
      }
      
      protected function cloneBaseProperties(param1:Item) : void
      {
         param1._type = this._type;
         param1.setXML(ItemFactory.getItemDefinition(this._type));
         param1._id = this._id;
         param1._name = this._name;
         param1._nameBase = this._nameBase;
         param1._baseLevel = this._baseLevel;
         param1._new = this._new;
         param1._qualityType = this._qualityType;
         param1.quantity = this.quantity;
         var _loc2_:int = 0;
         while(_loc2_ < this._mods.length)
         {
            param1._mods[_loc2_] = this._mods[_loc2_];
            _loc2_++;
         }
         if(this._craftData != null)
         {
            param1._craftData = this._craftData.clone() as CraftingInfo;
         }
         if(this._specialData != null)
         {
            param1._specialData = this._specialData.clone();
         }
         if(this._qualityType == ItemQualityType.INFAMOUS)
         {
            this._isUpgradable = false;
         }
         param1.updateLevel();
      }
      
      public function dispose() : void
      {
         this._mods = null;
         this._xml = null;
         this._id = null;
         if(this._craftingTimer != null)
         {
            this._craftingTimer.dispose();
            this._craftingTimer = null;
         }
      }
      
      public function getMod(param1:int) : String
      {
         if(param1 < 0 || param1 >= this._mods.length)
         {
            return null;
         }
         return this._mods[param1];
      }
      
      public function getAllModDescriptions(param1:Boolean = false) : String
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc2_:String = "";
         for each(_loc3_ in ItemAttributes.getAllGroups())
         {
            _loc4_ = this.getModDescriptions(_loc3_,param1);
            if(_loc4_)
            {
               _loc2_ += _loc4_ + "<br/>";
            }
         }
         _loc2_ = StringUtils.htmlRemoveTrailingBreaks(_loc2_);
         return StringUtils.htmlSetDoubleBreakLeading(_loc2_);
      }
      
      public function getModAttributeDescriptions(param1:String, param2:String) : Vector.<String>
      {
         var modId:String = null;
         var modNode:XML = null;
         var attNode:XML = null;
         var useAdd:Boolean = false;
         var name:String = null;
         var value:Number = NaN;
         var isGood:Boolean = false;
         var sign:String = null;
         var abs_value:Number = NaN;
         var strValue:String = null;
         var desc:String = null;
         var color:uint = 0;
         var strAttribute:String = null;
         var cap:Number = NaN;
         var group:String = param1;
         var attribute:String = param2;
         var output:Vector.<String> = new Vector.<String>();
         var xmlItemMods:XML = ResourceManager.getInstance().getResource("xml/itemmods.xml").content;
         var i:int = 0;
         while(i < this._mods.length)
         {
            modId = this._mods[i];
            if(modId != null)
            {
               modNode = xmlItemMods.mod.(@id == modId)[0];
               if(modNode != null)
               {
                  attNode = modNode[group][attribute][0];
                  if(attNode != null)
                  {
                     useAdd = ItemAttributes.isAdditive(attribute);
                     name = Language.getInstance().getString("item_mods." + modId);
                     value = Number(attNode.toString()) - (useAdd ? 0 : 1);
                     isGood = _lowMods.indexOf(attribute) == -1 ? value > 0 : value < 0;
                     sign = _reverseSignMods.indexOf(attribute) > -1 ? (value < 0 ? "+" : "-") : (value < 0 ? "-" : "+");
                     abs_value = value < 0 ? -value : value;
                     if(abs_value >= 0.01)
                     {
                        if(this._attributes.globalModCap != 0)
                        {
                           cap = this._attributes.globalModCap;
                           if(abs_value > cap)
                           {
                              value = cap * (value < 0 ? -1 : 1);
                           }
                        }
                        strValue = "";
                        if(useAdd)
                        {
                           strValue = int(Math.ceil(Math.abs(value))).toString();
                        }
                        else
                        {
                           strValue = Math.abs(Number((value * 100).toFixed(2))) + "%";
                        }
                        desc = sign + strValue;
                        switch(this._qualityType)
                        {
                           case ItemQualityType.RARE:
                              color = new Color(Effects.COLOR_RARE).multiply(2).RGB;
                              break;
                           case ItemQualityType.UNIQUE:
                           case ItemQualityType.INFAMOUS:
                              color = new Color(Effects.COLOR_UNIQUE).multiply(2).RGB;
                              break;
                           default:
                              color = isGood ? Effects.COLOR_GOOD : Effects.COLOR_WARNING;
                        }
                        strAttribute = name.indexOf("%s") > -1 ? Language.getInstance().replaceVars(name,desc) : name + " " + desc;
                        output.push("<font color=\'" + Color.colorToHex(color) + "\'>" + strAttribute + "</font>");
                     }
                  }
               }
            }
            i++;
         }
         return output;
      }
      
      public function getModDescriptions(param1:String, param2:Boolean = false) : String
      {
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:Number = Number(NaN);
         var _loc10_:Boolean = false;
         var _loc11_:String = null;
         var _loc12_:* = null;
         var _loc13_:Boolean = false;
         var _loc14_:String = null;
         var _loc15_:* = null;
         var _loc16_:uint = 0;
         var _loc17_:Boolean = false;
         var _loc18_:Boolean = false;
         var _loc19_:Boolean = false;
         var _loc20_:String = null;
         var _loc21_:String = null;
         var _loc22_:Number = Number(NaN);
         var _loc23_:String = null;
         var _loc24_:String = null;
         var _loc25_:* = false;
         var _loc3_:* = "";
         var _loc4_:Language = Language.getInstance();
         var _loc5_:Dictionary = this._craftData != null ? this._craftData.getModTable(param1) : null;
         var _loc6_:Dictionary = this._attributes.getModValues(param1);
         for(_loc7_ in _loc6_)
         {
            _loc8_ = _loc4_.getString("itm_details." + _loc7_);
            _loc9_ = this._attributes.getCappedModValue(param1,_loc7_);
            if(!(isNaN(_loc9_) || _loc9_ == 0))
            {
               _loc10_ = _lowMods.indexOf(_loc7_) > -1 ? _loc9_ < 0 : _loc9_ > 0;
               _loc11_ = _reverseSignMods.indexOf(_loc7_) > -1 ? (_loc9_ < 0 ? "+" : "-") : (_loc9_ < 0 ? "-" : "+");
               if(Math.abs(_loc9_) >= 0.001)
               {
                  _loc9_ = ItemAttributes.cap(_loc7_,_loc9_);
                  _loc12_ = "";
                  _loc13_ = ItemAttributes.isAdditive(_loc7_);
                  if(_loc13_)
                  {
                     _loc12_ = int(Math.abs(_loc9_)).toString();
                  }
                  else
                  {
                     _loc12_ = Math.abs(Number((_loc9_ * 100).toFixed(2))) + "%";
                  }
                  _loc14_ = _loc8_.indexOf("%s") > -1 ? Language.getInstance().replaceVars(_loc8_,_loc11_ + _loc12_) : _loc8_ + " " + (_loc11_ + _loc12_);
                  _loc15_ = "<b>" + _loc14_ + "</b>";
                  _loc17_ = false;
                  switch(this._qualityType)
                  {
                     case ItemQualityType.RARE:
                        _loc16_ = new Color(Effects.COLOR_RARE).multiply(2).RGB;
                        break;
                     case ItemQualityType.UNIQUE:
                     case ItemQualityType.INFAMOUS:
                        _loc16_ = new Color(Effects.COLOR_UNIQUE).multiply(2).RGB;
                        break;
                     default:
                        _loc16_ = _loc10_ ? Effects.COLOR_GOOD : Effects.COLOR_WARNING;
                        _loc17_ = true;
                  }
                  _loc3_ += "<font color=\'" + Color.colorToHex(_loc16_) + "\'>" + _loc15_ + "</font><br/>";
                  if(_loc17_)
                  {
                     _loc18_ = false;
                     _loc19_ = _loc5_ != null && _loc5_[_loc7_] != null && _loc5_[_loc7_] != 0;
                     if(_loc19_ || this.numMods > 1)
                     {
                        for each(_loc20_ in this.getModAttributeDescriptions(param1,_loc7_))
                        {
                           _loc3_ += "   - " + _loc20_ + "<br/>";
                        }
                        _loc18_ = true;
                     }
                     if(_loc19_)
                     {
                        _loc21_ = _loc4_.getString("item_mods.crafted");
                        _loc22_ = Number(_loc5_[_loc7_]);
                        _loc23_ = Math.abs(Number((_loc22_ * 100).toFixed(2))) + "%";
                        _loc23_ = int(Math.ceil(Math.abs(_loc22_))).toString();
                        _loc23_ = ItemAttributes.isAdditive(_loc7_) ? _loc23_ : _loc23_;
                        _loc24_ = (_loc22_ > 0 ? "+" : "-") + _loc23_;
                        _loc25_ = _loc22_ >= 0;
                        _loc3_ += "   - <font color=\'" + (param2 ? "#FFD800" : Color.colorToHex(_loc25_ ? Effects.COLOR_GOOD : Effects.COLOR_WARNING)) + "\'>" + _loc21_ + " " + _loc24_ + "</font><br/>";
                        _loc18_ = true;
                     }
                  }
                  if(_loc18_)
                  {
                     _loc3_ += "<br/>";
                  }
               }
            }
         }
         _loc3_ = StringUtils.htmlRemoveTrailingBreaks(_loc3_);
         return StringUtils.htmlSetDoubleBreakLeading(_loc3_);
      }
      
      public function getAttributeDescriptions(param1:String) : String
      {
         return this.getAttributeDescriptionsForDict(param1,this._attributes.getValues(param1));
      }
      
      public function getAttributeDescriptionsForDict(param1:String, param2:Dictionary) : String
      {
         var _loc5_:String = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:Number = Number(NaN);
         var _loc11_:Number = Number(NaN);
         var _loc12_:Boolean = false;
         var _loc13_:String = null;
         var _loc14_:String = null;
         var _loc15_:String = null;
         var _loc16_:* = null;
         var _loc17_:uint = 0;
         var _loc18_:Boolean = false;
         var _loc19_:Boolean = false;
         var _loc20_:Boolean = false;
         var _loc21_:Vector.<String> = null;
         var _loc22_:String = null;
         var _loc23_:String = null;
         var _loc24_:Number = Number(NaN);
         var _loc25_:String = null;
         var _loc26_:String = null;
         var _loc27_:String = null;
         var _loc28_:* = false;
         var _loc3_:Array = [];
         var _loc4_:Language = Language.getInstance();
         switch(param1)
         {
            case ItemAttributes.GROUP_GEAR:
            case ItemAttributes.GROUP_WEAPON:
               _loc5_ = "itm_details";
               break;
            case ItemAttributes.GROUP_SURVIVOR:
               _loc5_ = "att";
         }
         var _loc6_:Dictionary = this.craftData != null ? this.craftData.getModTable(param1) : null;
         for(_loc7_ in param2)
         {
            _loc9_ = Language.getInstance().getString("itm_details." + _loc7_);
            _loc10_ = Number(param2[_loc7_]);
            _loc11_ = this._attributes.getBaseValue(param1,_loc7_);
            if(_loc10_ - _loc11_ != 0)
            {
               _loc12_ = _lowMods.indexOf(_loc7_) == -1 ? _loc10_ > 0 : _loc10_ < 0;
               _loc13_ = _reverseSignMods.indexOf(_loc7_) > -1 ? (_loc10_ < 0 ? "+" : "-") : (_loc10_ < 0 ? "-" : "+");
               _loc14_ = Math.abs(Number((_loc10_ * 100).toFixed(2))) + "%";
               _loc14_ = int(Math.abs(_loc10_)).toString();
               _loc14_ = ItemAttributes.isAdditive(_loc7_) ? _loc14_ : _loc14_;
               _loc15_ = _loc9_.indexOf("%s") > -1 ? Language.getInstance().replaceVars(_loc9_,_loc13_ + _loc14_) : _loc9_ + " " + (_loc13_ + _loc14_);
               _loc16_ = "<b>" + _loc15_ + "</b>";
               _loc18_ = false;
               switch(this._qualityType)
               {
                  case ItemQualityType.RARE:
                     _loc17_ = new Color(Effects.COLOR_RARE).multiply(2).RGB;
                     break;
                  case ItemQualityType.UNIQUE:
                  case ItemQualityType.INFAMOUS:
                     _loc17_ = new Color(Effects.COLOR_UNIQUE).multiply(2).RGB;
                     break;
                  default:
                     _loc17_ = _loc12_ ? Effects.COLOR_GOOD : Effects.COLOR_WARNING;
                     _loc18_ = true;
               }
               _loc3_.push("<font color=\'" + Color.colorToHex(_loc17_) + "\'>" + _loc16_ + "</font>");
               if(_loc18_)
               {
                  _loc19_ = false;
                  _loc20_ = _loc6_ != null && _loc6_[_loc7_] != null && _loc6_[_loc7_] != 0;
                  if(_loc20_ || this.numMods > 1)
                  {
                     _loc21_ = this.getModAttributeDescriptions(param1,_loc7_);
                     if(_loc21_.length > 0)
                     {
                        _loc23_ = this.getBaseAttributeDescription(param1,_loc7_);
                        if(_loc23_.length > 0)
                        {
                           _loc3_.push("   - " + _loc23_);
                        }
                     }
                     for each(_loc22_ in _loc21_)
                     {
                        _loc3_.push("   - " + _loc22_);
                     }
                     _loc19_ = true;
                  }
                  if(_loc20_)
                  {
                     _loc24_ = Number(_loc6_[_loc7_]);
                     _loc25_ = _loc4_.getString("item_mods.crafted");
                     _loc26_ = Math.abs(Number((_loc24_ * 100).toFixed(2))) + "%";
                     _loc26_ = int(Math.abs(_loc24_)).toString();
                     _loc26_ = ItemAttributes.isAdditive(_loc7_) ? _loc26_ : _loc26_;
                     _loc27_ = (_loc24_ > 0 ? "+" : "-") + _loc26_;
                     _loc28_ = _loc24_ >= 0;
                     _loc3_.push("   - <font color=\'#FFD800\'>" + _loc25_ + " " + _loc27_ + "</font>");
                     _loc19_ = true;
                  }
               }
               if(_loc19_)
               {
                  _loc3_[_loc3_.length - 1] += "<br/>";
               }
            }
         }
         _loc8_ = _loc3_.join("<br/>");
         _loc8_ = StringUtils.htmlRemoveTrailingBreaks(_loc8_);
         return StringUtils.htmlSetDoubleBreakLeading(_loc8_);
      }
      
      public function getBaseAttributeDescription(param1:String, param2:String) : String
      {
         var _loc4_:String = null;
         var _loc6_:String = null;
         var _loc7_:Boolean = false;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc3_:String = "";
         switch(param1)
         {
            case ItemAttributes.GROUP_GEAR:
            case ItemAttributes.GROUP_WEAPON:
               _loc4_ = "itm_details";
               break;
            case ItemAttributes.GROUP_SURVIVOR:
               _loc4_ = "att";
         }
         var _loc5_:Number = this._attributes.getBaseValue(param1,param2);
         if(_loc5_ != 0)
         {
            _loc6_ = Language.getInstance().getString("itm_details.base");
            _loc7_ = _lowMods.indexOf(param2) == -1 ? _loc5_ > 0 : _loc5_ < 0;
            _loc8_ = _reverseSignMods.indexOf(param2) > -1 ? (_loc5_ < 0 ? "+" : "-") : (_loc5_ < 0 ? "-" : "+");
            if(Math.abs(_loc5_) >= 0.01)
            {
               _loc9_ = Math.abs(Number((_loc5_ * 100).toFixed(2))) + "%";
               _loc9_ = int(Math.abs(_loc5_)).toString();
               _loc9_ = ItemAttributes.isAdditive(param2) ? _loc9_ : _loc9_;
               _loc10_ = _loc6_.indexOf("%s") > -1 ? Language.getInstance().replaceVars(_loc6_,_loc8_ + _loc9_) : _loc6_ + " " + (_loc8_ + _loc9_);
               _loc3_ += "<font color=\'" + Color.colorToHex(_loc7_ ? Effects.COLOR_GOOD : Effects.COLOR_WARNING) + "\'>" + _loc10_ + "</font>";
            }
         }
         return _loc3_;
      }
      
      public function getAttributeDescription(param1:String, param2:String) : String
      {
         var _loc4_:String = null;
         var _loc3_:String = "";
         switch(param1)
         {
            case ItemAttributes.GROUP_GEAR:
            case ItemAttributes.GROUP_WEAPON:
               _loc4_ = "itm_details";
               break;
            case ItemAttributes.GROUP_SURVIVOR:
               _loc4_ = "att";
         }
         var _loc5_:Number = this._attributes.getValue(param1,param2);
         if(Math.abs(_loc5_) < 0.01)
         {
            return _loc3_;
         }
         var _loc6_:String = Language.getInstance().getString("itm_details." + param2);
         var _loc7_:Boolean = _lowMods.indexOf(param2) == -1 ? _loc5_ > 0 : _loc5_ < 0;
         var _loc8_:String = _reverseSignMods.indexOf(param2) > -1 ? (_loc5_ < 0 ? "+" : "-") : (_loc5_ < 0 ? "-" : "+");
         var _loc9_:String = Math.abs(Number((_loc5_ * 100).toFixed(2))) + "%";
         _loc9_ = int(Math.abs(_loc5_)).toString();
         _loc9_ = ItemAttributes.isAdditive(param2) ? _loc9_ : _loc9_;
         var _loc10_:String = _loc6_.indexOf("%s") > -1 ? Language.getInstance().replaceVars(_loc6_,_loc8_ + _loc9_) : _loc6_ + " " + (_loc8_ + _loc9_);
         return _loc3_ + ("<font color=\'" + Color.colorToHex(_loc7_ ? Effects.COLOR_GOOD : Effects.COLOR_WARNING) + "\'>" + _loc10_ + "</font>");
      }
      
      public function getAttributeDescriptionsForGroups(... rest) : String
      {
         var _loc4_:String = null;
         var _loc2_:String = "";
         var _loc3_:int = 0;
         while(_loc3_ < rest.length)
         {
            _loc4_ = this.getAttributeDescriptions(rest[_loc3_]);
            if(_loc4_)
            {
               _loc2_ += _loc4_ + "<br/>";
            }
            _loc3_++;
         }
         _loc2_ = StringUtils.htmlRemoveTrailingBreaks(_loc2_);
         return StringUtils.htmlSetDoubleBreakLeading(_loc2_);
      }
      
      public function getMinLevel() : int
      {
         return this._minLevel;
      }
      
      public function getMaxLevel() : int
      {
         return this._maxLevel;
      }
      
      public function getName() : String
      {
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         var _loc3_:String = null;
         var _loc4_:XML = null;
         if(this._name == null)
         {
            this._nameBase = Language.getInstance().getString("items." + this._type);
            if(this._qualityType == ItemQualityType.PREMIUM || this._qualityType == ItemQualityType.INFAMOUS)
            {
               this._name = this._nameBase;
               return this._name;
            }
            _loc1_ = [];
            _loc2_ = 0;
            while(_loc2_ < this._mods.length)
            {
               _loc3_ = this._mods[_loc2_];
               if(!(_loc3_ == null || _loc3_ == ""))
               {
                  _loc4_ = ItemFactory.getModDefinition(_loc3_);
                  if(!(Boolean(_loc4_.hasOwnProperty("@notitle")) && _loc4_.@notitle != "0"))
                  {
                     _loc1_.push(Language.getInstance().getString("item_mods." + _loc3_));
                  }
               }
               _loc2_++;
            }
            _loc1_.push(this._nameBase);
            this._name = _loc1_.join(" ");
            if(this._isVintage)
            {
               this._name = Language.getInstance().getString("quality_type.vintage",this._name);
            }
         }
         return this._name;
      }
      
      public function getBaseName() : String
      {
         if(this._nameBase == null)
         {
            this._nameBase = Language.getInstance().getString("items." + this._type);
         }
         return this._nameBase;
      }
      
      public function getImageURI() : String
      {
         var node:XML = null;
         var imageURI:String = this._xml.img.@uri.toString();
         var i:int = 0;
         while(i < this._mods.length)
         {
            if(this._mods[i] != null)
            {
               node = this._xml..mod.children().(Boolean(hasOwnProperty("@id")) && @id == _mods[i])[0];
               if(node != null && Boolean(node.hasOwnProperty("img")))
               {
                  imageURI = node.img.@uri.toString();
                  break;
               }
            }
            i++;
         }
         return imageURI;
      }
      
      public function attachCounter(param1:uint, param2:int) : void
      {
         this._counterType = param1;
         if(param2 >= 0)
         {
            this._counterValue = param2;
         }
      }
      
      public function getRecycleItems() : Vector.<Item>
      {
         var i:int = 0;
         var node:XML = null;
         var item:Item = null;
         var groupNodes:XMLList = null;
         var outputQty:int = 0;
         var xmlOutput:XML = null;
         var xmlInfamous:XMLList = null;
         var minLevel:int = 0;
         var iResource:Item = null;
         var modItemMult:Number = NaN;
         var modItems:XMLList = null;
         var isSingle:Boolean = false;
         var existingItem:Item = null;
         var outItem:Item = null;
         var out:Vector.<Item> = new Vector.<Item>();
         if(this.crafted)
         {
            if(this._xml.recycle.@nocrafted == "1")
            {
               return out;
            }
         }
         for each(node in this._xml.recycle.itm)
         {
            item = ItemFactory.createItemFromRecycleXML(node);
            out.push(item);
         }
         groupNodes = this._xml.recycle.itmgrp;
         if(groupNodes != null && groupNodes.length() >= 1)
         {
            out.push(new UnknownItem());
         }
         if(ItemQualityType.isSpecial(this._qualityType))
         {
            if(this._itemType == "weapon" || this._itemType == "gear")
            {
               if(this._qualityType == ItemQualityType.RARE || this._qualityType == ItemQualityType.UNIQUE)
               {
                  outputQty = 0;
                  xmlOutput = null;
                  xmlInfamous = Config.xml.infamous.output;
                  i = xmlInfamous.length() - 1;
                  loop5:
                  while(i >= 0)
                  {
                     node = xmlInfamous[i];
                     minLevel = int(node.@lvl);
                     if(this.level >= minLevel)
                     {
                        switch(this._qualityType)
                        {
                           case ItemQualityType.RARE:
                              outputQty = int(node.rare.toString());
                              break loop5;
                           case ItemQualityType.UNIQUE:
                              outputQty = int(node.unique.toString());
                              break loop5;
                           default:
                              outputQty = 0;
                        }
                        break;
                     }
                     i--;
                  }
                  if(outputQty > 0)
                  {
                     iResource = ItemFactory.createItemFromTypeId("infamous-resource");
                     iResource.quantity = outputQty;
                     out.push(iResource);
                  }
               }
            }
         }
         else
         {
            modItemMult = this._qualityType < ItemQualityType.GREEN ? 0 : Number(Config.constant.MOD_RECYCLE_MULTIPLIER);
            i = 0;
            while(i < this._mods.length)
            {
               if(this._mods[i] != null)
               {
                  modItems = this._xml..mod.children().(parent().localName() != "kit" && hasOwnProperty("@id") && @id == _mods[i]).recycle..itm;
                  for each(node in modItems)
                  {
                     item = ItemFactory.createItemFromRecycleXML(node);
                     isSingle = Boolean(node.hasOwnProperty("@single")) && node.@single.toString() == "1";
                     item.quantity = isSingle ? item.quantity : uint(Math.floor(item.quantity + item.quantity * this.level * modItemMult));
                     if(item.quantity > 0)
                     {
                        existingItem = null;
                        for each(outItem in out)
                        {
                           if(outItem.type == item.type && outItem.quantifiable)
                           {
                              existingItem = outItem;
                              existingItem.quantity += item.quantity;
                              break;
                           }
                        }
                        if(existingItem == null)
                        {
                           out.push(item);
                        }
                     }
                  }
               }
               i++;
            }
         }
         return out;
      }
      
      public function getUpgradeCost() : int
      {
         if(!this.isUpgradable)
         {
            return 0;
         }
         if(this.isBelowMinLevel())
         {
            return 0;
         }
         var _loc1_:Object = Network.getInstance().data.costTable.getItemByKey("CraftUpgradeItem");
         var _loc2_:int = int(_loc1_.minCost);
         var _loc3_:Number = Number(_loc1_.costPerLevel);
         var _loc4_:Number = Number(_loc1_["cost_" + ItemQualityType.getName(this._qualityType).toLowerCase()]);
         var _loc5_:Number = 1 + Network.getInstance().playerData.compound.getEffectValue(EffectType.getTypeValue("CraftingCost")) / 100;
         var _loc6_:Number = Number(Config.constant.CRAFT_COST_MIN_EFFECT);
         if(_loc5_ < _loc6_)
         {
            _loc5_ = _loc6_;
         }
         var _loc7_:int = Math.floor((this.level + 1) * _loc3_ * _loc4_ * _loc5_);
         return Math.max(_loc2_,_loc7_);
      }
      
      public function getSound(param1:String) : String
      {
         var _loc2_:Vector.<String> = this._sounds[param1];
         if(_loc2_ == null)
         {
            return null;
         }
         return _loc2_[int(Math.random() * _loc2_.length)];
      }
      
      public function getSounds(param1:String) : Vector.<String>
      {
         return this._sounds[param1];
      }
      
      public function isBelowMinLevel() : Boolean
      {
         return this._level < this.getMinLevel();
      }
      
      public function isAtMaxLevel() : Boolean
      {
         return this._level >= this.getMaxLevel();
      }
      
      public function isLowerBetter(param1:String) : Boolean
      {
         return _lowMods.indexOf(param1) > -1;
      }
      
      public function upgrade(param1:Item = null, param2:Function = null) : void
      {
         var onUpgradeComplete:Function;
         var startUpgrade:Function;
         var loadout:SurvivorLoadout;
         var upgradeCost:int = 0;
         var self:Item = null;
         var busyComplete:Boolean = false;
         var responseComplete:Boolean = false;
         var responseData:Object = null;
         var dlgBusy:AutoProgressBarDialogue = null;
         var network:Network = null;
         var minLevel:int = 0;
         var maxLevel:int = 0;
         var lang:Language = null;
         var msg:MessageBox = null;
         var upgradeKit:Item = param1;
         var onComplete:Function = param2;
         if(!this.isUpgradable)
         {
            if(onComplete != null)
            {
               onComplete(null);
            }
            return;
         }
         if(upgradeKit != null && upgradeKit.quantity > 0)
         {
            upgradeCost = 0;
            if(upgradeKit.category != "upgradekit")
            {
               if(onComplete != null)
               {
                  onComplete(null);
               }
               return;
            }
            minLevel = int(upgradeKit.xml.kit.itm_lvl_min);
            maxLevel = int(upgradeKit.xml.kit.itm_lvl_max);
            if(upgradeKit.qualityType < this.qualityType || this.level < minLevel || this.level > maxLevel)
            {
               if(onComplete != null)
               {
                  onComplete(null);
               }
               return;
            }
         }
         else
         {
            upgradeCost = this.getUpgradeCost();
         }
         if(upgradeCost > 0 && upgradeCost > Network.getInstance().playerData.compound.resources.getAmount(GameResources.CASH))
         {
            PaymentSystem.getInstance().openBuyCoinsScreen(true);
            return;
         }
         self = this;
         busyComplete = false;
         responseComplete = false;
         responseData = null;
         network = Network.getInstance();
         onUpgradeComplete = function(param1:Object):void
         {
            var _loc3_:MessageBox = null;
            dlgBusy.close();
            if(param1 == null)
            {
               return;
            }
            if(!(param1.success !== true || param1.item.toUpperCase() != self.id.toUpperCase()))
            {
               var _loc2_:int = int(param1.level);
               _baseLevel = _loc2_;
               updateLevel();
               Network.getInstance().playerData.loadoutManager.checkItemUsability(self);
               if(param1.change != null)
               {
                  network.playerData.inventory.updateQuantities(param1.change);
               }
               if(param1.winmaxlevel === true)
               {
                  MiniTaskSystem.getInstance().dispatchTaskComplete(new MiniTask("upgradeMaxLevel"));
               }
               _new = true;
               Tracking.trackEvent("Player","Upgraded",_type + "_" + level,upgradeCost);
               if(onComplete != null)
               {
                  onComplete(self);
               }
               return;
            }
            switch(param1.error)
            {
               case PlayerIOError.NotEnoughCoins.errorID:
                  PaymentSystem.getInstance().openBuyCoinsScreen(true);
                  return;
               default:
                  _loc3_ = new MessageBox(Language.getInstance().getString("crafted_failed_msg"));
                  _loc3_.addTitle(Language.getInstance().getString("crafted_failed_title"));
                  _loc3_.addButton(Language.getInstance().getString("crafted_failed_ok"));
                  _loc3_.open();
                  return;
            }
         };
         startUpgrade = function():void
         {
            dlgBusy = new AutoProgressBarDialogue(Language.getInstance().getString("crafting_upgrading",getName()),5140136);
            dlgBusy.completed.addOnce(function():void
            {
               busyComplete = true;
               if(responseComplete && busyComplete)
               {
                  onUpgradeComplete(responseData);
               }
            });
            dlgBusy.open();
            Audio.sound.play("sound/interface/int-crafting-progress.mp3");
            network.startAsyncOp();
            network.save({
               "id":_id,
               "kitId":(upgradeKit != null ? upgradeKit.id : "")
            },SaveDataMethod.CRAFT_UPGRADE,function(param1:Object):void
            {
               network.completeAsyncOp();
               responseComplete = true;
               responseData = param1;
               if(responseComplete && busyComplete)
               {
                  onUpgradeComplete(responseData);
               }
            });
         };
         loadout = Network.getInstance().playerData.loadoutManager.getItemDefensiveLoadout(this);
         if(loadout != null && loadout.survivor.level < this.level + 1)
         {
            lang = Language.getInstance();
            msg = new MessageBox(lang.getString("srv_equipped_upgrade_msg",loadout.survivor.fullName));
            msg.addTitle(lang.getString("srv_equipped_upgrade_title",loadout.survivor.fullName),BaseDialogue.TITLE_COLOR_RUST);
            msg.addButton(lang.getString("srv_equipped_upgrade_cancel"));
            msg.addButton(lang.getString("srv_equipped_upgrade_ok"),true,{
               "buttonClass":PurchasePushButton,
               "cost":upgradeCost,
               "width":120
            }).clicked.add(function(param1:MouseEvent):void
            {
               startUpgrade();
            });
            msg.open();
            return;
         }
         startUpgrade();
      }
      
      public function toChatObject() : Object
      {
         var _loc1_:Object = {};
         _loc1_.type = this._type;
         _loc1_.level = this._baseLevel;
         _loc1_.quality = this._qualityType;
         switch(this._qualityType)
         {
            case ItemQualityType.RARE:
               _loc1_.name = this._nameBase;
               break;
            case ItemQualityType.UNIQUE:
               _loc1_.name = this._nameBase;
               break;
            case ItemQualityType.INFAMOUS:
               _loc1_.name = this._nameBase;
         }
         if(this._mods[0] != null)
         {
            _loc1_.mod1 = this._mods[0];
         }
         if(this._mods[1] != null)
         {
            _loc1_.mod2 = this._mods[1];
         }
         if(this._mods[2] != null)
         {
            _loc1_.mod3 = this._mods[2];
         }
         if(this._craftData != null)
         {
            _loc1_.craft = this._craftData._rawData;
         }
         if(this._specialData != null)
         {
            _loc1_.specData = this._specialData._rawData;
         }
         if(this._counterType != ItemCounterType.None)
         {
            _loc1_.ctrType = this._counterType;
            _loc1_.ctrVal = this._counterValue;
         }
         return {
            "name":this.getName(),
            "linkClass":ItemQualityType.getName(this._qualityType).toLowerCase(),
            "data":_loc1_
         };
      }
      
      public function writeObject(param1:Object = null) : Object
      {
         if(!param1)
         {
            param1 = {};
         }
         param1._type = "itm";
         param1.id = this._id;
         param1.type = this._type;
         param1.level = this._baseLevel;
         if(this._bought)
         {
            param1.bought = this._bought;
         }
         if(this.quantity > 1)
         {
            param1.qty = this.quantity;
         }
         var _loc2_:int = 0;
         while(_loc2_ < this._mods.length)
         {
            if(this._mods[_loc2_] != null)
            {
               param1["mod" + (_loc2_ + 1)] = this._mods[_loc2_];
            }
            _loc2_++;
         }
         return param1;
      }
      
      private function getQualityRating() : int
      {
         var _loc3_:String = null;
         var _loc4_:XML = null;
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this._mods.length)
         {
            _loc3_ = this._mods[_loc2_];
            if(_loc3_ != null)
            {
               _loc4_ = ItemFactory.getModDefinition(_loc3_);
               if(_loc4_ != null)
               {
                  if(_loc4_.hasOwnProperty("qlty"))
                  {
                     _loc1_ += int(_loc4_.qlty.toString());
                  }
               }
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function readObject(param1:Object) : void
      {
         var xmlDef:XML;
         var _loc2_:XML = null;
         var _loc3_:Object = null;
         try
         {
            if(param1 is XML)
            {
               _loc2_ = XML(param1);
               this._id = ("@id" in _loc2_ ? String(_loc2_.@id.toString()) : GUID.create()).toUpperCase();
               this._type = "@type" in _loc2_ ? _loc2_.@type.toString() : null;
               if(this._type != null)
               {
                  xmlDef = ItemFactory.getItemDefinition(this._type);
                  if(xmlDef != null)
                  {
                     this.setXML(xmlDef);
                  }
               }
               if("@b" in _loc2_)
               {
                  this._bindState = uint(_loc2_.@b.toString());
               }
               if("@l" in _loc2_)
               {
                  this._level = this._baseLevel = int(_loc2_.@l.toString());
               }
               if("@q" in _loc2_)
               {
                  this.quantity = int(_loc2_.@q.toString());
               }
               if("@ctrType" in _loc2_)
               {
                  this._counterType = uint(_loc2_.@ctrType.toString());
                  this._counterValue = int(_loc2_.@ctrVal.toString());
               }
               if("@m0" in _loc2_)
               {
                  this._mods[0] = _loc2_.@m0.toString();
               }
               if("@m1" in _loc2_)
               {
                  this._mods[1] = _loc2_.@m1.toString();
               }
               if("@m2" in _loc2_)
               {
                  this._mods[2] = _loc2_.@m2.toString();
               }
               if("@qt" in _loc2_)
               {
                  this._qualityType = int(_loc2_.@qt.toString());
               }
               else if(!this.xml.hasOwnProperty("@quality"))
               {
                  this._qualityType = ItemQualityType.getQualityFromRating(this.getQualityRating());
               }
               if(_loc2_["name"][0] != null)
               {
                  this._name = _loc2_["name"][0].toString();
                  if(this._isVintage)
                  {
                     this._name = Language.getInstance().getString("quality_type.vintage",this.getName());
                  }
               }
               if(ItemQualityType.isSpecial(this._qualityType))
               {
                  _loc3_ = {};
                  if("b_srv" in _loc2_)
                  {
                     _loc3_.stat_srv = _loc2_.b_srv.toString();
                  }
                  if("b_weap" in _loc2_)
                  {
                     _loc3_.stat_weap = _loc2_.b_weap.toString();
                  }
                  this._specialData = new ItemBonusStats();
                  this._specialData.read(_loc3_);
               }
               if(this._qualityType == ItemQualityType.INFAMOUS)
               {
                  this._isUpgradable = false;
               }
               this.updateLevel();
               return;
            }
            this._id = (param1.id != null ? String(param1.id) : GUID.create()).toUpperCase();
            this._new = "new" in param1 ? Boolean(param1["new"]) : false;
            this._bought = param1.storeId != null ? true : ("bought" in param1 ? Boolean(param1.bought) : false);
            if("mod1" in param1)
            {
               this._mods[0] = param1.mod1;
            }
            if("mod2" in param1)
            {
               this._mods[1] = param1.mod2;
            }
            if("mod3" in param1)
            {
               this._mods[2] = param1.mod3;
            }
            this.setXML(ItemFactory.getItemDefinition(param1.type));
            this._level = this._baseLevel = "level" in param1 ? int(param1.level) : 0;
            this.quantity = "qty" in param1 ? uint(int(param1.qty)) : 1;
            if("quality" in param1)
            {
               this._qualityType = int(param1.quality);
            }
            else if(this._qualityType == ItemQualityType.WHITE)
            {
               this._qualityType = ItemQualityType.getQualityFromRating(this.getQualityRating());
            }
            if("bind" in param1)
            {
               this._bindState = uint(param1.bind);
            }
            if("tradable" in param1)
            {
               this._isTradable = Boolean(param1.tradable);
            }
            if("disposable" in param1)
            {
               this._isDisposable = Boolean(param1.disposable);
            }
            if("ctrType" in param1)
            {
               this._counterType = uint(param1.ctrType);
               this._counterValue = int(param1.ctrVal);
            }
            if("craft" in param1)
            {
               this._craftData = new CraftingInfo();
               this._craftData.read(param1.craft);
            }
            if("name" in param1)
            {
               this._name = param1.name;
               this._nameBase = param1.name;
               if(this._isVintage)
               {
                  this._name = Language.getInstance().getString("quality_type.vintage",this._name);
               }
            }
            if("specData" in param1)
            {
               this._specialData = new ItemBonusStats();
               this._specialData.read(param1.specData);
               if(this._qualityType == ItemQualityType.INFAMOUS)
               {
                  this._isUpgradable = false;
               }
            }
            this.updateLevel();
         }
         catch(e:Error)
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.call("console.log","[Item] ERROR in readObject: " + e.message + ", Stack: " + e.getStackTrace());
            }
         }
      }
      
      public function toString() : String
      {
         return "(Item id=" + this.id + ", type=" + this.type + ", level=" + this.level + ", mods=" + this._mods + ", quantity=" + this.quantity + ")";
      }
      
      public function getTradeTrackingName() : String
      {
         var _loc1_:* = this.getName();
         if(this.crafted)
         {
            _loc1_ += "-crafted";
         }
         if(this._qualityType == ItemQualityType.PREMIUM)
         {
            _loc1_ += "-premium";
         }
         return _loc1_ + ("-" + ItemQualityType.getName(this._qualityType).toLowerCase());
      }
      
      protected function setXML(param1:XML) : void
      {
         var _loc3_:XML = null;
         var _loc4_:Number = Number(NaN);
         this._xml = param1;
         this._type = this._xml.@id.toString();
         this._itemType = this._xml.@type.toString();
         this._quantifiable = Boolean(this._xml.hasOwnProperty("qnt_min")) || this._itemType == "resource";
         this._rarity = int(this.xml.rarity.toString());
         this._isUpgradable = this._isUpgradable && Boolean(this.xml.@upgrade != "0");
         this._isVintage = Boolean(this.xml.hasOwnProperty("@vint") && this.xml.@vint == "1");
         this._isTradable = this._xml.hasOwnProperty("@trade") ? this._xml.@trade != "0" : true;
         this._isDisposable = this._xml.hasOwnProperty("@dispose") ? this._xml.@dispose != "0" : true;
         this._bindState = this.xml.hasOwnProperty("@bind") ? uint(this.xml.@bind.toString()) : ItemBindState.NotBindable;
         this._qualityType = this.xml.hasOwnProperty("@quality") ? int(ItemQualityType.getValue(this.xml.@quality.toString())) : ItemQualityType.WHITE;
         this._attributes.globalModCap = this.xml.hasOwnProperty("modcap") ? Number(this.xml.modcap[0].toString()) : 0;
         if(this._qualityType == ItemQualityType.INFAMOUS)
         {
            this._isUpgradable = false;
         }
         if(this.xml.hasOwnProperty("counter"))
         {
            _loc3_ = this.xml.counter[0];
            this._counterType = ItemCounterType[_loc3_.@type.toString()];
            _loc4_ = Number(_loc3_.toString());
            this._counterValue = !isNaN(_loc4_) ? int(_loc4_) : this._counterValue;
         }
         var _loc2_:int = this._xml.hasOwnProperty("lvl") ? int(this._xml.lvl) : -1;
         if(_loc2_ > -1)
         {
            this._minLevel = this._maxLevel = this._baseLevel = _loc2_;
         }
         else
         {
            this._minLevel = this._xml.hasOwnProperty("lvl_min") ? int(this._xml.lvl_min) : 0;
            this._maxLevel = this._xml.hasOwnProperty("lvl_max") ? int(this._xml.lvl_max) : 0;
         }
         this._stackLimit = this._quantifiable ? 0 : 1;
         if(this._xml.hasOwnProperty("stack"))
         {
            this._stackLimit = int(this._xml.stack[0]);
         }
         if(this._qualityType == ItemQualityType.PREMIUM && Boolean(this._xml.hasOwnProperty("mod")))
         {
            if(this._xml.mod.hasOwnProperty("m0"))
            {
               this._mods[0] = this._xml.mod.m0[0].@id.toString();
            }
            if(this._xml.mod.hasOwnProperty("m1"))
            {
               this._mods[1] = this._xml.mod.m1[0].@id.toString();
            }
            if(this._xml.mod.hasOwnProperty("m2"))
            {
               this._mods[2] = this._xml.mod.m2[0].@id.toString();
            }
         }
         if(this._itemType == "craftkit")
         {
            this._mods[0] = this._xml.kit.mod.toString();
         }
      }
      
      protected function populateSoundsList(param1:XMLList) : void
      {
         var _loc2_:XML = null;
         var _loc3_:String = null;
         var _loc4_:Vector.<String> = null;
         this._sounds = new Dictionary(true);
         for each(_loc2_ in param1)
         {
            _loc3_ = _loc2_.localName();
            _loc4_ = this._sounds[_loc3_];
            if(_loc4_ == null)
            {
               _loc4_ = new Vector.<String>();
               this._sounds[_loc3_] = _loc4_;
            }
            _loc4_.push(_loc2_.toString());
         }
      }
      
      private function updateLevel() : void
      {
         this._level = this._baseLevel;
         if(this._level < 0)
         {
            this._level = 0;
         }
         this.updateAttributes();
      }
      
      protected function updateAttributes() : void
      {
         var _loc2_:String = null;
         var _loc3_:XML = null;
         var _loc4_:String = null;
         var _loc5_:XML = null;
         var _loc6_:String = null;
         this._attributes.clear();
         var _loc1_:int = 0;
         while(_loc1_ < this._mods.length)
         {
            _loc2_ = this._mods[_loc1_];
            if(_loc2_)
            {
               _loc3_ = ItemFactory.getModDefinition(_loc2_);
               if(_loc3_ != null)
               {
                  for each(_loc4_ in ItemAttributes.getAllGroups())
                  {
                     if(_loc3_.hasOwnProperty(_loc4_))
                     {
                        for each(_loc5_ in _loc3_[_loc4_].children())
                        {
                           _loc6_ = _loc5_.localName();
                           if(!(_loc6_ == "flag" || _loc6_ == "att"))
                           {
                              this._attributes.addModValue(_loc4_,_loc6_,Number(_loc5_.toString()));
                           }
                        }
                     }
                  }
               }
            }
            _loc1_++;
         }
         if(this._craftData != null)
         {
            this.applyBonusStats(this._craftData,Number(Config.constant["MAX_CRAFTING_BONUS"]));
         }
         if(this._specialData != null)
         {
            this.applyBonusStats(this._specialData);
         }
      }
      
      protected function applyBonusStats(param1:ItemBonusStats, param2:Number = -1) : void
      {
         var _loc3_:String = null;
         var _loc4_:Number = Number(NaN);
         for(_loc3_ in param1.survivorModTable)
         {
            _loc4_ = applyBonusStatCap(Number(param1.survivorModTable[_loc3_]),param2);
            this._attributes.addModValue(ItemAttributes.GROUP_SURVIVOR,_loc3_,1 + (this.isLowerBetter(_loc3_) ? -_loc4_ : _loc4_));
         }
         for(_loc3_ in param1.weaponModTable)
         {
            _loc4_ = applyBonusStatCap(Number(param1.weaponModTable[_loc3_]),param2);
            this._attributes.addModValue(ItemAttributes.GROUP_WEAPON,_loc3_,1 + (this.isLowerBetter(_loc3_) ? -_loc4_ : _loc4_));
         }
         for(_loc3_ in param1.gearModTable)
         {
            _loc4_ = applyBonusStatCap(Number(param1.gearModTable[_loc3_]),param2);
            this._attributes.addModValue(ItemAttributes.GROUP_GEAR,_loc3_,1 + (this.isLowerBetter(_loc3_) ? -_loc4_ : _loc4_));
         }
      }
      
      public function get attributes() : ItemAttributes
      {
         return this._attributes;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function set id(param1:String) : void
      {
         this._id = param1;
      }
      
      public function get type() : String
      {
         return this._type;
      }
      
      public function get category() : String
      {
         return this._itemType;
      }
      
      public function get level() : int
      {
         return this._level;
      }
      
      public function get baseLevel() : int
      {
         return this._baseLevel;
      }
      
      public function set baseLevel(param1:int) : void
      {
         this._baseLevel = param1;
         this.updateLevel();
      }
      
      public function get isVintage() : Boolean
      {
         return this._isVintage;
      }
      
      public function set isVintage(param1:Boolean) : void
      {
         this._isVintage = param1;
      }
      
      public function get isNew() : Boolean
      {
         return this._new;
      }
      
      public function set isNew(param1:Boolean) : void
      {
         this._new = param1;
      }
      
      public function get bought() : Boolean
      {
         return this._bought;
      }
      
      public function set bought(param1:Boolean) : void
      {
         this._bought = param1;
      }
      
      public function get numMods() : int
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this._mods.length)
         {
            if(this._mods[_loc2_] != null)
            {
               _loc1_++;
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function get maxMods() : int
      {
         return this._mods.length;
      }
      
      public function get quantifiable() : Boolean
      {
         return this._quantifiable;
      }
      
      public function get qualityType() : int
      {
         return this._qualityType;
      }
      
      public function get rarity() : int
      {
         return this._rarity;
      }
      
      public function get xml() : XML
      {
         return this._xml;
      }
      
      public function set xml(param1:XML) : void
      {
         if(this._xml == param1)
         {
            return;
         }
         this.setXML(param1);
      }
      
      public function get crafted() : Boolean
      {
         return this._craftData != null;
      }
      
      public function get craftData() : CraftingInfo
      {
         return this._craftData;
      }
      
      public function get isUpgradable() : Boolean
      {
         if(this._isUpgradable)
         {
            if(this.level >= this.getMaxLevel())
            {
               return false;
            }
         }
         return this._isUpgradable;
      }
      
      public function get specialData() : ItemBonusStats
      {
         return this._specialData;
      }
      
      public function get stackLimit() : int
      {
         return this._stackLimit;
      }
      
      public function get isTradable() : Boolean
      {
         return this._isTradable;
      }
      
      public function get isDisposable() : Boolean
      {
         return this._isDisposable;
      }
      
      public function get bindState() : uint
      {
         return this._bindState;
      }
      
      public function set bindState(param1:uint) : void
      {
         if(param1 == this._bindState)
         {
            return;
         }
         this._bindState = param1;
         this.bindStateChanged.dispatch(this);
      }
      
      public function get isAccountBound() : Boolean
      {
         return this._bindState == ItemBindState.Bound;
      }
      
      public function get isBindOnEquip() : Boolean
      {
         return this._bindState == ItemBindState.OnEquip;
      }
      
      public function get counterType() : uint
      {
         return this._counterType;
      }
      
      public function get counterValue() : int
      {
         return this._counterValue;
      }
      
      public function set counterValue(param1:int) : void
      {
         this._counterValue = param1;
      }
   }
}

