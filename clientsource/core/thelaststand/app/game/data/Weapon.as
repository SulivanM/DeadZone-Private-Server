package thelaststand.app.game.data
{
   import thelaststand.app.core.Config;
   import thelaststand.app.game.data.injury.InjuryCause;
   
   public class Weapon extends Item
   {
      
      protected var _attachments:Vector.<String>;
      
      private var _burstFire:Boolean;
      
      private var _injuryCause:String = null;
      
      private var _weaponClass:String;
      
      private var _animType:String;
      
      private var _reloadAnim:String;
      
      private var _swingAnims:Vector.<String>;
      
      private var _playSwingExertionSound:Boolean = true;
      
      public var flags:uint = 0;
      
      public var weaponType:uint = 0;
      
      public var ammoType:uint = 0;
      
      public var survivorClasses:Vector.<String>;
      
      public function Weapon(param1:String = null)
      {
         super();
         this._attachments = new Vector.<String>();
         _isUpgradable = true;
         this.survivorClasses = new Vector.<String>();
         if(param1 != null)
         {
            this.setXML(ItemFactory.getItemDefinition(param1));
         }
      }
      
      override public function clone() : Item
      {
         var _loc1_:Weapon = new Weapon(_type);
         cloneBaseProperties(_loc1_);
         _loc1_.survivorClasses = this.survivorClasses.concat();
         _loc1_._attachments = this._attachments.concat();
         _loc1_.flags = this.flags;
         _loc1_.weaponType = this.weaponType;
         _loc1_.ammoType = this.ammoType;
         return _loc1_;
      }
      
      public function getCapacity() : int
      {
         return Math.round(_attributes.getValue(ItemAttributes.GROUP_WEAPON,"cap"));
      }
      
      public function getBurstRate() : int
      {
         if(!this._burstFire)
         {
            return 0;
         }
         var _loc1_:int = int(_attributes.getValue(ItemAttributes.GROUP_WEAPON,"brst_min"));
         var _loc2_:int = int(_attributes.getValue(ItemAttributes.GROUP_WEAPON,"brst_max"));
         return int(_loc1_ + (_loc2_ - _loc1_) * Math.random());
      }
      
      public function supportsSurvivorClass(param1:String) : Boolean
      {
         if(param1 == SurvivorClass.PLAYER)
         {
            return true;
         }
         if(this.survivorClasses.length > 0)
         {
            return this.survivorClasses.indexOf(param1) > -1;
         }
         return true;
      }
      
      public function getGoreMultiplier() : Number
      {
         return _attributes.getValue(ItemAttributes.GROUP_WEAPON,"gore") || 1;
      }
      
      public function getBurstAvg() : int
      {
         var _loc1_:int = int(_attributes.getValue(ItemAttributes.GROUP_WEAPON,"brst_min"));
         var _loc2_:int = int(_attributes.getValue(ItemAttributes.GROUP_WEAPON,"brst_max"));
         return int((_loc1_ + _loc2_) * 0.5);
      }
      
      public function getMeleeSwing() : String
      {
         return this._swingAnims.length > 0 ? this._swingAnims[int(Math.random() * this._swingAnims.length)] : null;
      }
      
      public function getNoise() : Number
      {
         return _attributes.getValue(ItemAttributes.GROUP_WEAPON,"noise");
      }
      
      public function getIdleNoise() : Number
      {
         return _attributes.getValue(ItemAttributes.GROUP_WEAPON,"idle_noise");
      }
      
      public function getFireRate() : Number
      {
         return _attributes.getValue(ItemAttributes.GROUP_WEAPON,"rate") * 1000;
      }
      
      public function getReadyTime() : Number
      {
         var _loc1_:Number = _attributes.getValue(ItemAttributes.GROUP_WEAPON,"ready");
         if(!_loc1_)
         {
            _loc1_ = this._weaponClass == WeaponClass.MELEE ? 0 : 0.1;
         }
         return _loc1_;
      }
      
      public function getAccuracy() : Number
      {
         var _loc1_:Number = _attributes.getValue(ItemAttributes.GROUP_WEAPON,"acc");
         return _loc1_ > 1 ? 1 : _loc1_;
      }
      
      public function getCriticalChance() : Number
      {
         return _attributes.getValue(ItemAttributes.GROUP_WEAPON,"crit");
      }
      
      public function getDamageMin() : Number
      {
         return _attributes.getValue(ItemAttributes.GROUP_WEAPON,"dmg_min") / 100;
      }
      
      public function getDamageMax() : Number
      {
         return _attributes.getValue(ItemAttributes.GROUP_WEAPON,"dmg_max") / 100;
      }
      
      public function getDamageMultiplierVsBuilding() : Number
      {
         return _attributes.getValue(ItemAttributes.GROUP_WEAPON,"dmg_bld") || 1;
      }
      
      public function getKnockbackChance() : Number
      {
         return _attributes.getValue(ItemAttributes.GROUP_WEAPON,"knock");
      }
      
      public function getAttackArc() : Number
      {
         var _loc1_:Number = _attributes.getBaseValue(ItemAttributes.GROUP_WEAPON,"arc");
         if(!_loc1_)
         {
            _loc1_ = (this._weaponClass == WeaponClass.MELEE ? 45 : 10) * Math.PI / 180;
         }
         return _loc1_ + _loc1_ * _attributes.getModValue(ItemAttributes.GROUP_WEAPON,"arc");
      }
      
      public function getSuppressionRate() : Number
      {
         return _attributes.getValue(ItemAttributes.GROUP_WEAPON,"sup");
      }
      
      public function getBaseAmmoCost() : Number
      {
         return _attributes.getValue(ItemAttributes.GROUP_WEAPON,"ammo_cost");
      }
      
      public function getRange() : Number
      {
         return _attributes.getValue(ItemAttributes.GROUP_WEAPON,"rng") * 100;
      }
      
      public function getMinRange() : Number
      {
         return _attributes.getValue(ItemAttributes.GROUP_WEAPON,"rng_min") * 100;
      }
      
      public function getMinEffectiveRange() : Number
      {
         return _attributes.getValue(ItemAttributes.GROUP_WEAPON,"rng_min_eff") * 100;
      }
      
      public function getReloadTime() : Number
      {
         return _attributes.getValue(ItemAttributes.GROUP_WEAPON,"rldtime") * 1000;
      }
      
      override public function getSound(param1:String) : String
      {
         switch(param1)
         {
            case "ricochet":
               return "sound/impacts/ricochet-" + (1 + int(Math.random() * 4)) + ".mp3";
            case "buildingHit":
               return "sound/impacts/building-hit" + (1 + int(Math.random() * 2)) + ".mp3";
            default:
               return super.getSound(param1);
         }
      }
      
      public function getInjuryCause() : String
      {
         var _loc1_:Boolean = false;
         var _loc2_:Boolean = false;
         if(this._injuryCause == null)
         {
            _loc1_ = Boolean(this.weaponType & (WeaponType.BLADE | WeaponType.AXE));
            _loc2_ = Boolean(this.weaponType & WeaponType.BLUNT);
            if(_loc1_ && _loc2_)
            {
               this._injuryCause = Math.random() < 0.5 ? InjuryCause.BLUNT : InjuryCause.SHARP;
            }
            else if(_loc1_)
            {
               this._injuryCause = InjuryCause.SHARP;
            }
            else if(_loc2_)
            {
               this._injuryCause = InjuryCause.BLUNT;
            }
            else if(this.weaponType & WeaponType.EXPLOSIVE)
            {
               this._injuryCause = InjuryCause.HEAT;
            }
            else if(this._weaponClass == WeaponClass.MELEE)
            {
               this._injuryCause = InjuryCause.BLUNT;
            }
            else
            {
               this._injuryCause = InjuryCause.BULLET;
            }
         }
         return this._injuryCause;
      }
      
      public function hasAttachment(param1:String) : Boolean
      {
         return this._attachments.indexOf(param1) > -1;
      }
      
      override public function toString() : String
      {
         return "(Weapon id=" + id + ", type=" + type + ", level=" + level + ", mods=" + getMod(0) + "," + getMod(1) + ")";
      }
      
      private function updateFlagsAndAttachments() : void
      {
         var _loc2_:String = null;
         var _loc3_:XML = null;
         var _loc4_:XML = null;
         var _loc5_:XML = null;
         this.flags = WeaponFlags.NONE;
         this._attachments.length = 0;
         var _loc1_:int = 0;
         while(_loc1_ < maxMods)
         {
            _loc2_ = getMod(_loc1_);
            if(_loc2_ != null)
            {
               _loc3_ = ItemFactory.getModDefinition(_loc2_);
               if(_loc3_ != null)
               {
                  for each(_loc4_ in _loc3_.weap.flag)
                  {
                     this.flags |= WeaponFlags.getFlagByName(_loc4_.toString());
                  }
                  for each(_loc5_ in _loc3_.weap.att)
                  {
                     this._attachments.push(_loc5_.toString());
                  }
               }
            }
            _loc1_++;
         }
      }
      
      override protected function setXML(param1:XML) : void
      {
         var _loc2_:XML = null;
         super.setXML(param1);
         this._burstFire = _xml.weap.hasOwnProperty("brst_min");
         this._animType = String(_xml.weap.anim[0]);
         this._reloadAnim = String(_xml.weap.rldanim[0]);
         this._weaponClass = String(_xml.weap.cls[0]);
         populateSoundsList(_xml.weap.snd.children());
         this.survivorClasses.length = 0;
         for each(_loc2_ in _xml.weap.srv.cls)
         {
            this.survivorClasses.push(_loc2_.toString());
         }
         this.weaponType = WeaponType.NONE;
         for each(_loc2_ in _xml.weap.type)
         {
            this.weaponType |= WeaponType[_loc2_.toString().toUpperCase()];
         }
         this.ammoType = AmmoType.NONE;
         for each(_loc2_ in _xml.weap.ammo)
         {
            this.ammoType |= AmmoType[_loc2_.toString().toUpperCase()];
         }
         this._swingAnims = new Vector.<String>();
         for each(_loc2_ in _xml.weap.swing.anim)
         {
            this._swingAnims.push(_loc2_.toString());
         }
         this._playSwingExertionSound = true;
         if(_xml.weap.swing.noexert.length() > 0)
         {
            this._playSwingExertionSound = false;
         }
      }
      
      override protected function updateAttributes() : void
      {
         super.updateAttributes();
         _attributes.addBaseValuesFromXML(ItemAttributes.GROUP_WEAPON,_xml.weap.children(),_level,_minLevel);
         _attributes.addModValuesFromXML(ItemAttributes.GROUP_SURVIVOR,_xml.weap.srv.children(),_level,_minLevel);
         _attributes.addModValuesFromXML(ItemAttributes.GROUP_GEAR,_xml.weap.gear.children(),_level,_minLevel);
         _attributes.addBaseValue(ItemAttributes.GROUP_WEAPON,"crit",Number(Config.constant.BASE_CRIT_CHANCE));
         this.updateFlagsAndAttachments();
      }
      
      public function get attachments() : Vector.<String>
      {
         return this._attachments;
      }
      
      public function get isBurstFire() : Boolean
      {
         return this._burstFire;
      }
      
      public function get weaponClass() : String
      {
         return this._weaponClass;
      }
      
      public function get animType() : String
      {
         return this._animType;
      }
      
      public function get reloadAnim() : String
      {
         return this._reloadAnim;
      }
      
      public function get playSwingExertionSound() : Boolean
      {
         return this._playSwingExertionSound;
      }
   }
}

