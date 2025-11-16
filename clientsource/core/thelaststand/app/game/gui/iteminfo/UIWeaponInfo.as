package thelaststand.app.game.gui.iteminfo
{
   import flash.display.Bitmap;
   import flash.filters.GlowFilter;
   import flash.geom.ColorTransform;
   import flash.utils.Dictionary;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemAttributes;
   import thelaststand.app.game.data.SurvivorClass;
   import thelaststand.app.game.data.SurvivorLoadout;
   import thelaststand.app.game.data.Weapon;
   import thelaststand.app.game.data.WeaponClass;
   import thelaststand.app.game.data.WeaponData;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.network.Network;
   
   public class UIWeaponInfo extends UIItemInfoDisplay
   {
      
      private var _weapon:Weapon;
      
      private var bmp_equipOffence:Bitmap;
      
      private var bmp_equipDefence:Bitmap;
      
      private var bmp_specialized:Bitmap;
      
      private var bmp_dpsCompare:Bitmap;
      
      private var mc_stats:UIItemStatTable;
      
      private var txt_dpsValue:BodyTextField;
      
      private var txt_dpsTitle:BodyTextField;
      
      private var txt_damage:BodyTextField;
      
      private var txt_equipOffence:BodyTextField;
      
      private var txt_equipDefence:BodyTextField;
      
      private var txt_specialized:BodyTextField;
      
      private var txt_levelRequired:BodyTextField;
      
      private var txt_modInfo:BodyTextField;
      
      private var txt_classRequired:BodyTextField;
      
      public function UIWeaponInfo()
      {
         super();
         this.txt_dpsValue = new BodyTextField({
            "text":"0",
            "color":16777215,
            "size":30,
            "bold":true
         });
         this.txt_dpsValue.x = mc_image.x + mc_image.width + 6;
         this.txt_dpsValue.y = mc_image.y;
         this.txt_dpsValue.filters = [new GlowFilter(16777215,1,20,20,1,2)];
         addChild(this.txt_dpsValue);
         this.txt_dpsTitle = new BodyTextField({
            "color":11908533,
            "size":12,
            "bold":true
         });
         this.txt_dpsTitle.text = _lang.getString("itm_details.dps").toUpperCase();
         this.txt_dpsTitle.x = this.txt_dpsValue.x;
         this.txt_dpsTitle.y = Math.round(this.txt_dpsValue.y + (this.txt_dpsValue.height - this.txt_dpsTitle.height) * 0.5);
         addChild(this.txt_dpsTitle);
         this.txt_damage = new BodyTextField({
            "color":11908533,
            "size":14,
            "bold":true
         });
         this.txt_damage.x = this.txt_dpsValue.x;
         this.txt_damage.y = int(this.txt_dpsValue.y + this.txt_dpsValue.height - 5);
         addChild(this.txt_damage);
         this.mc_stats = new UIItemStatTable(_width);
         addChild(this.mc_stats);
         this.txt_modInfo = new BodyTextField({
            "color":Effects.COLOR_NEUTRAL,
            "multiline":true,
            "size":14,
            "leading":1
         });
         this.txt_modInfo.width = _width;
         this.bmp_equipOffence = new Bitmap(new BmpIconEquipped());
         this.bmp_equipOffence.x = -2;
         this.txt_equipOffence = new BodyTextField({
            "color":Effects.COLOR_NEUTRAL,
            "size":13,
            "bold":true
         });
         this.txt_equipOffence.x = int(this.bmp_equipOffence.x + this.bmp_equipOffence.width);
         this.txt_equipOffence.maxWidth = _width;
         this.bmp_equipDefence = new Bitmap(new BmpIconEquippedDefence());
         this.bmp_equipDefence.x = -2;
         this.txt_equipDefence = new BodyTextField({
            "color":Effects.COLOR_NEUTRAL,
            "size":13,
            "bold":true
         });
         this.txt_equipDefence.x = int(this.bmp_equipDefence.x + this.bmp_equipDefence.width);
         this.txt_equipDefence.maxWidth = _width;
         this.bmp_specialized = new Bitmap(new BmpIconSpecialized());
         this.txt_specialized = new BodyTextField({
            "color":Effects.COLOR_NEUTRAL,
            "size":13,
            "bold":true
         });
         this.txt_specialized.x = int(this.txt_equipOffence.x);
         this.txt_specialized.maxWidth = _width;
         this.txt_levelRequired = new BodyTextField({
            "color":Effects.COLOR_WARNING,
            "size":13,
            "bold":true
         });
         this.txt_levelRequired.maxWidth = _width;
         this.txt_classRequired = new BodyTextField({
            "color":Effects.COLOR_NEUTRAL,
            "size":13,
            "bold":true,
            "multiline":true,
            "leading":-1
         });
         this.txt_classRequired.width = _width;
      }
      
      override public function dispose() : void
      {
         this._weapon = null;
         if(parent)
         {
            parent.removeChild(this);
         }
         this.bmp_specialized.bitmapData.dispose();
         this.bmp_specialized.bitmapData = null;
         this.bmp_equipOffence.bitmapData.dispose();
         this.bmp_equipOffence.bitmapData = null;
         this.bmp_equipDefence.bitmapData.dispose();
         this.bmp_equipDefence.bitmapData = null;
         if(this.bmp_dpsCompare != null)
         {
            if(this.bmp_dpsCompare.bitmapData != null)
            {
               this.bmp_dpsCompare.bitmapData.dispose();
            }
            this.bmp_dpsCompare.bitmapData = null;
         }
         this.txt_classRequired.dispose();
         this.txt_damage.dispose();
         this.txt_dpsTitle.dispose();
         this.txt_dpsValue.dispose();
         this.txt_equipOffence.dispose();
         this.txt_equipDefence.dispose();
         this.txt_levelRequired.dispose();
         this.txt_modInfo.dispose();
         this.txt_specialized.dispose();
      }
      
      override public function setItem(param1:Item, param2:SurvivorLoadout = null, param3:Object = null) : void
      {
         var _loc4_:WeaponData = null;
         var _loc5_:WeaponData = null;
         var _loc18_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc26_:Number = NaN;
         var _loc28_:Number = NaN;
         var _loc30_:Number = NaN;
         var _loc32_:Number = NaN;
         var _loc34_:String = null;
         var _loc39_:Number = NaN;
         var _loc40_:Number = NaN;
         var _loc41_:Number = NaN;
         var _loc42_:ColorTransform = null;
         var _loc43_:String = null;
         var _loc44_:String = null;
         var _loc45_:Number = NaN;
         var _loc46_:uint = 0;
         var _loc47_:Number = NaN;
         var _loc48_:uint = 0;
         var _loc49_:* = null;
         var _loc50_:String = null;
         if(!(param1 is Weapon))
         {
            throw new Error("Item is not Weapon");
         }
         this._weapon = param1 as Weapon;
         super.setItem(param1,param2);
         _loc4_ = new WeaponData();
         _loc4_.populate(_survivor,this._weapon,param2 != null ? param2.type : SurvivorLoadout.TYPE_OFFENCE);
         if(param2 != null && param2.weapon != null && param2.weapon.item != this._weapon)
         {
            _loc5_ = new WeaponData();
            _loc5_.populate(param2.survivor,param2.weapon.item as Weapon,param2.type);
         }
         var _loc6_:Dictionary = this._weapon.attributes.getModValues(ItemAttributes.GROUP_WEAPON);
         this.txt_dpsValue.text = Number(_loc4_.getDPS().toFixed(1)).toString();
         this.txt_damage.text = int(_loc4_.damageMin * 100) + " - " + int(_loc4_.damageMax * 100) + " " + _lang.getString("itm_details.dmg");
         this.txt_damage.textColor = _loc6_.dmg != undefined ? (_loc6_.dmg < 0 ? Effects.COLOR_WARNING : Effects.COLOR_GOOD) : Effects.COLOR_NEUTRAL;
         this.txt_dpsTitle.x = int(this.txt_dpsValue.x + this.txt_dpsValue.width + 2);
         if(_loc5_ != null)
         {
            _loc39_ = Number(_loc5_.getDPS().toFixed(1));
            _loc40_ = Number(_loc4_.getDPS().toFixed(1));
            _loc41_ = _loc40_ - _loc39_;
            if(_loc41_ != 0)
            {
               _loc42_ = new ColorTransform();
               _loc42_.color = _loc41_ < 0 ? Effects.COLOR_WARNING : Effects.COLOR_GOOD;
               this.bmp_dpsCompare = new Bitmap(new BmpIconCompareArrow());
               this.bmp_dpsCompare.x = int(this.txt_dpsTitle.x + this.txt_dpsTitle.width + 4);
               this.bmp_dpsCompare.y = int(this.txt_dpsTitle.y + (this.txt_dpsTitle.height - this.bmp_dpsCompare.height) * 0.5);
               this.bmp_dpsCompare.transform.colorTransform = _loc42_;
               addChild(this.bmp_dpsCompare);
               if(_loc41_ < 0)
               {
                  this.bmp_dpsCompare.scaleY = -1;
                  this.bmp_dpsCompare.y += this.bmp_dpsCompare.height;
               }
            }
         }
         this.mc_stats.y = int(mc_image.y + mc_image.height + 10);
         var _loc7_:int = this._weapon.getBurstAvg();
         var _loc8_:Number = _loc4_.fireRate / 1000 + (_loc7_ > 0 ? 0.25 / _loc7_ : 0);
         var _loc9_:Number = 1 / _loc8_;
         var _loc10_:String = _loc4_.ammoCost.toString();
         var _loc11_:* = Number((Math.min(_loc4_.accuracy,0.99) * 100).toFixed(2)) + "%";
         var _loc12_:String = Number(Number(_loc4_.minEffectiveRange / 100).toFixed(2)).toString();
         var _loc13_:String = Number(Number(_loc4_.range / 100).toFixed(2)).toString();
         var _loc14_:String = Number(_loc9_.toFixed(2)).toString();
         var _loc15_:String = Number(_loc4_.noise.toFixed(2)).toString();
         var _loc16_:* = Number((_loc4_.knockbackChance * 100).toFixed(2)) + "%";
         var _loc17_:String = Number(_loc4_.readyTime.toFixed(2)) + " " + _lang.getString("sec");
         var _loc19_:uint = 0;
         var _loc21_:uint = 0;
         var _loc23_:uint = 0;
         var _loc25_:uint = 0;
         var _loc27_:uint = 0;
         var _loc29_:uint = 0;
         var _loc31_:uint = 0;
         var _loc33_:uint = 0;
         if(_loc5_ != null)
         {
            _loc20_ = _loc4_.accuracy < _loc5_.accuracy ? -1 : (_loc4_.accuracy > _loc5_.accuracy ? 1 : 0);
            _loc22_ = _loc4_.range < _loc5_.range ? -1 : (_loc4_.range > _loc5_.range ? 1 : 0);
            _loc24_ = _loc4_.minEffectiveRange < _loc5_.minEffectiveRange ? -1 : (_loc4_.minEffectiveRange > _loc5_.minEffectiveRange ? 1 : 0);
            _loc26_ = _loc4_.fireRate < _loc5_.fireRate ? 1 : (_loc4_.fireRate > _loc5_.fireRate ? -1 : 0);
            _loc28_ = _loc4_.noise < _loc5_.noise ? -1 : (_loc4_.noise > _loc5_.noise ? 1 : 0);
            _loc30_ = _loc4_.knockbackChance < _loc5_.knockbackChance ? -1 : (_loc4_.knockbackChance > _loc5_.knockbackChance ? 1 : 0);
            _loc32_ = _loc4_.readyTime < _loc5_.readyTime ? -1 : (_loc4_.readyTime > _loc5_.readyTime ? 1 : 0);
            _loc21_ = _loc20_ < 0 ? Effects.COLOR_WARNING : Effects.COLOR_GOOD;
            _loc23_ = _loc22_ < 0 ? Effects.COLOR_WARNING : Effects.COLOR_GOOD;
            _loc25_ = _loc24_ < 0 ? Effects.COLOR_GOOD : Effects.COLOR_WARNING;
            _loc27_ = _loc26_ < 0 ? Effects.COLOR_WARNING : Effects.COLOR_GOOD;
            _loc29_ = _loc28_ < 0 ? Effects.COLOR_GOOD : Effects.COLOR_WARNING;
            _loc31_ = _loc30_ < 0 ? Effects.COLOR_WARNING : Effects.COLOR_GOOD;
            _loc33_ = _loc32_ < 0 ? Effects.COLOR_GOOD : Effects.COLOR_WARNING;
            _loc18_ = 0;
            if(_loc5_.ammoCost != 0)
            {
               _loc18_ = _loc4_.ammoCost < _loc5_.ammoCost ? -1 : (_loc4_.ammoCost > _loc5_.ammoCost ? 1 : 0);
               _loc19_ = _loc18_ < 0 ? Effects.COLOR_GOOD : Effects.COLOR_WARNING;
            }
         }
         if(_loc4_.ammoCost > 0)
         {
            this.mc_stats.addRow(_lang.getString("itm_details.ammo_cost"),_loc10_,this.getRowColor(_loc6_,"ammo_cost"),_loc18_,_loc19_);
         }
         this.mc_stats.addRow(_lang.getString("itm_details.rng"),_loc13_,this.getRowColor(_loc6_,"rng"),_loc22_,_loc23_);
         if(_loc4_.minEffectiveRange > 0)
         {
            this.mc_stats.addRow(_lang.getString("itm_details.rng_min_eff"),_loc12_,this.getRowColor(_loc6_,"rng_min_eff"),_loc24_,_loc25_);
         }
         if(_loc4_.readyTime > 0)
         {
            this.mc_stats.addRow(_lang.getString("itm_details.ready"),_loc17_,this.getRowColor(_loc6_,"ready"),_loc32_,_loc33_);
         }
         this.mc_stats.addRow(_lang.getString("itm_details.rate"),_loc14_,this.getRowColor(_loc6_,"rate"),_loc26_,_loc27_);
         this.mc_stats.addRow(_lang.getString("itm_details.acc"),_loc11_,this.getRowColor(_loc6_,"acc"),_loc20_,_loc21_);
         this.mc_stats.addRow(_lang.getString("itm_details.noise"),_loc15_,this.getRowColor(_loc6_,"noise"),_loc28_,_loc29_);
         this.mc_stats.addRow(_lang.getString("itm_details.knock"),_loc16_,this.getRowColor(_loc6_,"knock"),_loc30_,_loc31_);
         if(this._weapon.weaponClass != WeaponClass.MELEE)
         {
            _loc43_ = Number((_loc4_.reloadTime / 1000).toFixed(2)) + " " + _lang.getString("sec");
            _loc44_ = int(_loc4_.capacity).toString();
            _loc46_ = 0;
            _loc48_ = 0;
            if(_loc5_ != null)
            {
               _loc47_ = _loc45_ = 0;
               if(!_loc5_.isMelee)
               {
                  _loc45_ = _loc4_.reloadTime < _loc5_.reloadTime ? -1 : (_loc4_.reloadTime > _loc5_.reloadTime ? 1 : 0);
                  _loc47_ = _loc4_.capacity < _loc5_.capacity ? -1 : (_loc4_.capacity > _loc5_.capacity ? 1 : 0);
                  _loc46_ = _loc45_ < 0 ? Effects.COLOR_GOOD : Effects.COLOR_WARNING;
                  _loc48_ = _loc47_ < 0 ? Effects.COLOR_WARNING : Effects.COLOR_GOOD;
               }
            }
            this.mc_stats.addRow(_lang.getString("itm_details.rldtime"),_loc43_,this.getRowColor(_loc6_,"rldtime"),_loc45_,_loc46_);
            this.mc_stats.addRow(_lang.getString("itm_details.cap"),_loc44_,this.getRowColor(_loc6_,"cap"),_loc47_,_loc48_);
         }
         _height = int(this.mc_stats.y + this.mc_stats.height);
         if(this._weapon.numMods > 0)
         {
            _loc34_ = this._weapon.getAllModDescriptions();
         }
         else
         {
            _loc34_ = this._weapon.getAttributeDescriptionsForGroups(ItemAttributes.GROUP_WEAPON,ItemAttributes.GROUP_SURVIVOR,ItemAttributes.GROUP_GEAR);
         }
         if(_loc34_)
         {
            this.txt_modInfo.htmlText = _loc34_;
            this.txt_modInfo.y = _height + 10;
            addChild(this.txt_modInfo);
            _height = int(this.txt_modInfo.y + this.txt_modInfo.height);
         }
         if(this._weapon.survivorClasses.length > 0)
         {
            _loc49_ = _lang.getString("itm_details.requires") + " ";
            for each(_loc50_ in this._weapon.survivorClasses)
            {
               _loc49_ += _lang.getString("survivor_classes." + _loc50_) + " / ";
            }
            if(this._weapon.survivorClasses.indexOf(SurvivorClass.PLAYER) == -1)
            {
               _loc49_ += _lang.getString("survivor_classes." + SurvivorClass.PLAYER);
            }
            else
            {
               _loc49_ = _loc49_.substr(0,_loc49_.length - 3);
            }
            this.txt_classRequired.text = _loc49_;
            this.txt_classRequired.y = _height + 10;
            addChild(this.txt_classRequired);
            _height = int(this.txt_classRequired.y + this.txt_classRequired.height);
         }
         else if(this.txt_classRequired.parent != null)
         {
            this.txt_classRequired.parent.removeChild(this.txt_classRequired);
         }
         var _loc35_:SurvivorLoadout = Network.getInstance().playerData.loadoutManager.getItemOffensiveLoadout(_item);
         if(_loc35_ != null && _loc35_.survivor != _survivor)
         {
            this.bmp_equipOffence.y = _height + 10;
            addChild(this.bmp_equipOffence);
            this.txt_equipOffence.maxWidth = _width;
            this.txt_equipOffence.text = _lang.getString("itm_details.equipped",_loc35_.survivor.fullName);
            this.txt_equipOffence.y = int(this.bmp_equipOffence.y + (this.bmp_equipOffence.height - this.txt_equipOffence.height) * 0.5);
            addChild(this.txt_equipOffence);
            _height = int(this.txt_equipOffence.y + this.txt_equipOffence.height);
         }
         else
         {
            if(this.txt_equipOffence.parent != null)
            {
               this.txt_equipOffence.parent.removeChild(this.txt_equipOffence);
            }
            if(this.bmp_equipOffence.parent != null)
            {
               this.bmp_equipOffence.parent.removeChild(this.bmp_equipOffence);
            }
         }
         var _loc36_:SurvivorLoadout = Network.getInstance().playerData.loadoutManager.getItemDefensiveLoadout(_item);
         if(_loc36_ != null && _loc36_.survivor != _survivor)
         {
            this.bmp_equipDefence.y = _height + 10;
            addChild(this.bmp_equipDefence);
            this.txt_equipDefence.maxWidth = _width;
            this.txt_equipDefence.text = _lang.getString("itm_details.equipped_defence",_loc36_.survivor.fullName);
            this.txt_equipDefence.y = int(this.bmp_equipDefence.y + (this.bmp_equipDefence.height - this.txt_equipDefence.height) * 0.5);
            addChild(this.txt_equipDefence);
            _height = int(this.txt_equipDefence.y + this.txt_equipDefence.height);
         }
         else
         {
            if(this.txt_equipDefence.parent != null)
            {
               this.txt_equipDefence.parent.removeChild(this.txt_equipDefence);
            }
            if(this.bmp_equipDefence.parent != null)
            {
               this.bmp_equipDefence.parent.removeChild(this.bmp_equipDefence);
            }
         }
         if(_survivor != null && _survivor.sClass.isSpecialisedWithWeapon(this._weapon))
         {
            this.bmp_specialized.y = _height + 10;
            addChild(this.bmp_specialized);
            this.txt_specialized.maxWidth = _width;
            this.txt_specialized.text = _lang.getString("itm_details.specialized",_survivor.firstName);
            this.txt_specialized.y = int(this.bmp_specialized.y + (this.bmp_specialized.height - this.txt_specialized.height) * 0.5);
            addChild(this.txt_specialized);
            _height = int(this.txt_specialized.y + this.txt_specialized.height);
         }
         else
         {
            if(this.txt_specialized.parent != null)
            {
               this.txt_specialized.parent.removeChild(this.txt_specialized);
            }
            if(this.bmp_specialized.parent != null)
            {
               this.bmp_specialized.parent.removeChild(this.bmp_specialized);
            }
         }
         var _loc37_:int = Network.getInstance().playerData.compound.getEffectValue(EffectType.getTypeValue("WeaponGearLevelLimit"));
         var _loc38_:int = _survivor != null ? _survivor.level - _loc37_ : 0;
         if(_survivor != null && this._weapon.level > _loc38_)
         {
            this.txt_levelRequired.maxWidth = _width;
            this.txt_levelRequired.text = _lang.getString("itm_details.level_required",this._weapon.level + 1);
            if(_loc37_ != 0)
            {
               this.txt_levelRequired.text += " " + _lang.getString("itm_details.level_required_mod");
            }
            this.txt_levelRequired.y = _height + 10;
            addChild(this.txt_levelRequired);
            _height = int(this.txt_levelRequired.y + this.txt_levelRequired.height);
         }
         else if(this.txt_levelRequired.parent != null)
         {
            this.txt_levelRequired.parent.removeChild(this.txt_levelRequired);
         }
      }
      
      private function getRowColor(param1:Dictionary, param2:String) : uint
      {
         if(param1[param2] == undefined)
         {
            return Effects.COLOR_NEUTRAL;
         }
         var _loc3_:Number = Number(param1[param2]);
         if(this._weapon.isLowerBetter(param2))
         {
            return _loc3_ > 0 ? Effects.COLOR_WARNING : Effects.COLOR_GOOD;
         }
         return _loc3_ < 0 ? Effects.COLOR_WARNING : Effects.COLOR_GOOD;
      }
   }
}

