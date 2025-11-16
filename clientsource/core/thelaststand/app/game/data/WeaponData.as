package thelaststand.app.game.data
{
   import com.exileetiquette.math.MathUtils;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Config;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.game.data.research.ResearchEffect;
   import thelaststand.app.game.logic.ai.AIAgent;
   import thelaststand.app.network.Network;
   
   public class WeaponData
   {
      
      private var _minRange:Number = 0;
      
      private var _minEffectiveRange:Number = 0;
      
      private var _range:Number = 0;
      
      private var _minRangeMod:Number = 0;
      
      private var _maxRangeMod:Number = 0;
      
      private var _burstAvg:int = 0;
      
      private var _roundsInMagazine:int = 0;
      
      public var ammoCost:Number = 0;
      
      public var damageMax:Number = 0;
      
      public var damageMin:Number = 0;
      
      public var damageMult:Number = 1;
      
      public var damageMultVsBuilding:Number = 1;
      
      public var accuracy:Number = 0;
      
      public var capacity:int = 0;
      
      public var reloadTime:Number = 0;
      
      public var fireRate:Number = 0;
      
      public var noise:Number = 0;
      
      public var idleNoise:Number = 0;
      
      public var criticalChance:Number = 0;
      
      public var knockbackChance:Number = 0;
      
      public var dodgeChance:Number = 0;
      
      public var isMelee:Boolean = false;
      
      public var isExplosive:Boolean = false;
      
      public var attackArcCosine:Number = 0;
      
      public var suppressionRate:Number = 0;
      
      public var goreMultiplier:Number = 1;
      
      public var readyTime:Number = 0;
      
      public var roundsChanged:Signal;
      
      public function WeaponData()
      {
         super();
         this.roundsChanged = new Signal();
      }
      
      public function get roundsInMagazine() : int
      {
         return this._roundsInMagazine;
      }
      
      public function set roundsInMagazine(param1:int) : void
      {
         if(param1 == this._roundsInMagazine)
         {
            return;
         }
         this._roundsInMagazine = param1;
         this.roundsChanged.dispatch();
      }
      
      public function get minEffectiveRange() : Number
      {
         return this._minEffectiveRange + this._minRangeMod;
      }
      
      public function get minRange() : Number
      {
         return this._minRange + this._minRangeMod;
      }
      
      public function get range() : Number
      {
         return this._range + this._maxRangeMod;
      }
      
      public function setRangeModifiers(param1:Number, param2:Number) : void
      {
         this._minRangeMod = param1;
         this._maxRangeMod = param2;
      }
      
      public function getDPS() : Number
      {
         if(this.damageMin == 0 && this.damageMax == 0)
         {
            return 0;
         }
         var _loc1_:Number = (this.damageMin + this.damageMax) * 0.5 * 100;
         var _loc2_:Number = this.fireRate / 1000 + (this._burstAvg > 0 ? 0.25 / this._burstAvg : 0);
         var _loc3_:Number = this.reloadTime / 1000;
         var _loc4_:Number = this.isMelee ? 1 : this.capacity;
         var _loc5_:Number = this.readyTime;
         return _loc4_ * _loc1_ * this.accuracy / (_loc4_ * _loc2_ + _loc3_ + _loc5_);
      }
      
      public function reset() : void
      {
         this._minRange = 0;
         this._minEffectiveRange = 0;
         this._range = 0;
         this._minRangeMod = 0;
         this._maxRangeMod = 0;
         this._burstAvg = 0;
         this._roundsInMagazine = 0;
         this.ammoCost = 0;
         this.damageMax = 0;
         this.damageMin = 0;
         this.damageMult = 1;
         this.damageMultVsBuilding = 1;
         this.accuracy = 0;
         this.capacity = 0;
         this.reloadTime = 0;
         this.fireRate = 0;
         this.noise = 0;
         this.idleNoise = 0;
         this.criticalChance = 0;
         this.knockbackChance = 0;
         this.dodgeChance = 0;
         this.isMelee = false;
         this.isExplosive = false;
         this.attackArcCosine = 0;
         this.suppressionRate = 0;
         this.goreMultiplier = 1;
         this.readyTime = 0;
      }
      
      public function populate(param1:AIAgent, param2:Weapon, param3:String = "offence") : void
      {
         var _loc5_:SurvivorLoadout = null;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc24_:uint = 0;
         var _loc25_:Number = NaN;
         this.reset();
         if(param2 == null)
         {
            return;
         }
         var _loc4_:Survivor = param1 as Survivor;
         var _loc6_:int = param2.level;
         var _loc7_:int = param2.getMinLevel();
         var _loc8_:String = param2.weaponClass;
         var _loc9_:Boolean = Boolean(param2.weaponType & WeaponType.IMPROVISED);
         this.isMelee = Boolean(_loc8_ == WeaponClass.MELEE);
         this.isExplosive = Boolean(param2.weaponType & WeaponType.EXPLOSIVE);
         var _loc10_:Number = 1;
         var _loc11_:Number = 0;
         if(_loc4_ != null)
         {
            _loc5_ = param3 == SurvivorLoadout.TYPE_OFFENCE ? _loc4_.loadoutOffence : _loc4_.loadoutDefence;
            if(this.isMelee)
            {
               _loc10_ *= _loc4_.getAttribute(Attributes.COMBAT_MELEE,_loc5_,AttributeOptions.NO_MORALE);
            }
            else
            {
               _loc10_ *= _loc4_.getAttribute(Attributes.COMBAT_PROJECTILE,_loc5_,AttributeOptions.NO_MORALE);
            }
            if(_loc9_)
            {
               _loc10_ *= _loc4_.getAttribute(Attributes.COMBAT_IMPROVISED,_loc5_,AttributeOptions.NO_MORALE);
            }
            _loc20_ = 1 + _loc4_.getMoraleValue();
            if(_loc4_.isPlayerOwned)
            {
               if(_loc20_ < 0.9)
               {
                  _loc21_ = 1 / _loc20_;
                  _loc10_ *= _loc20_ * (1 + (_loc21_ - 1) * 0.5);
               }
               else
               {
                  _loc20_ = Math.max(_loc20_,1);
                  _loc10_ *= _loc20_;
               }
            }
            else
            {
               _loc10_ *= _loc20_;
            }
            _loc11_ = _loc4_.getWeaponPref(param2);
            this.dodgeChance = Math.min(_loc4_.getAttribute(Attributes.COMBAT_MELEE,_loc5_) * 30,80) / 100;
         }
         else
         {
            this.dodgeChance = 0;
         }
         this._burstAvg = param2.getBurstAvg();
         var _loc12_:Number = _loc5_ != null ? _loc5_.getGearLoadoutAttributeMod(ItemAttributes.GROUP_WEAPON,"dmg",param2,param2) : 0;
         var _loc13_:Number = _loc5_ != null ? _loc5_.survivor.injuries.getTotalAttributeModifier("dmg") : 0;
         var _loc14_:Number = this.getEffectAttributeMod(_loc4_,"dmg");
         var _loc15_:Number = 1 + _loc11_ + _loc12_ + _loc13_ + _loc14_;
         this.damageMax = param2.getDamageMax() * _loc15_;
         this.damageMin = param2.getDamageMin() * _loc15_;
         if(_loc4_ != null && _loc10_ > 1)
         {
            _loc22_ = _loc10_ / 25;
            this.damageMin += this.damageMin * _loc22_;
            this.damageMax += this.damageMax * _loc22_;
         }
         if(_loc4_ != null && _loc4_.researchEffects != null)
         {
            _loc23_ = this.isMelee ? Number(_loc4_.researchEffects[ResearchEffect.MeleeDamage]) : Number(_loc4_.researchEffects[ResearchEffect.FirearmDamage]);
            if(!isNaN(_loc23_))
            {
               this.damageMin += this.damageMin * _loc23_;
               this.damageMax += this.damageMax * _loc23_;
            }
         }
         if(this.damageMin < 0)
         {
            this.damageMin = 0;
         }
         if(this.damageMax < this.damageMin)
         {
            this.damageMax = this.damageMin;
         }
         this.accuracy = param2.getAccuracy();
         if(_loc5_ != null)
         {
            this.accuracy *= 1 + _loc5_.getGearLoadoutAttributeMod(ItemAttributes.GROUP_WEAPON,"acc",param2,param2) + _loc5_.survivor.injuries.getTotalAttributeModifier("acc") + this.getEffectAttributeMod(_loc4_,"acc") + _loc11_;
            if(_loc10_ <= 1)
            {
               this.accuracy *= _loc10_;
            }
            else
            {
               this.accuracy = this.accuracy * (_loc10_ / 15) + this.accuracy;
            }
         }
         this.accuracy = MathUtils.clamp(this.accuracy,0.01,0.99);
         this.criticalChance = param2.getCriticalChance();
         if(_loc5_ != null)
         {
            this.criticalChance *= 1 + _loc5_.getGearLoadoutAttributeMod(ItemAttributes.GROUP_WEAPON,"crit",param2,param2) + _loc5_.survivor.injuries.getTotalAttributeModifier("crit") + this.getEffectAttributeMod(_loc4_,"crit");
            if(_loc10_ > 1)
            {
               this.criticalChance = this.criticalChance * (_loc10_ / 5) + this.criticalChance;
            }
         }
         var _loc16_:Number = Number(Config.constant.MAX_CRIT_CHANCE);
         if(this.criticalChance > _loc16_)
         {
            this.criticalChance = _loc16_;
         }
         var _loc17_:Number = 1 + Network.getInstance().playerData.compound.getEffectValue(EffectType.getTypeValue("GoreMultiplier")) / 100;
         this.goreMultiplier = param2.getGoreMultiplier() * _loc17_;
         this.damageMultVsBuilding = param2.getDamageMultiplierVsBuilding();
         if(_loc5_ != null)
         {
            this.damageMultVsBuilding *= 1 + _loc5_.getGearLoadoutAttributeMod(ItemAttributes.GROUP_WEAPON,"dmg_bld",param2,param2) + _loc5_.survivor.injuries.getTotalAttributeModifier("dmg_bld") + this.getEffectAttributeMod(_loc4_,"dmg_bld");
         }
         this._range = param2.getRange();
         if(_loc5_ != null)
         {
            this._range *= 1 + _loc5_.getGearLoadoutAttributeMod(ItemAttributes.GROUP_WEAPON,"rng",param2,param2) + _loc5_.survivor.injuries.getTotalAttributeModifier("rng") + this.getEffectAttributeMod(_loc4_,"rng");
         }
         this._range = Math.max(this._range,150);
         if(this.isMelee)
         {
            this._range = Math.min(this._range,400);
         }
         if(_loc4_ != null && this._range < 175)
         {
            this._range = 175;
         }
         this._minRange = param2.getMinRange();
         if(_loc5_ != null)
         {
            this._minRange *= 1 + _loc5_.getGearLoadoutAttributeMod(ItemAttributes.GROUP_WEAPON,"rng_min",param2,param2) + _loc5_.survivor.injuries.getTotalAttributeModifier("rng_min") + this.getEffectAttributeMod(_loc4_,"rng_min");
         }
         this._minEffectiveRange = param2.getMinEffectiveRange();
         if(_loc5_ != null)
         {
            this._minEffectiveRange *= 1 + _loc5_.getGearLoadoutAttributeMod(ItemAttributes.GROUP_WEAPON,"rng_min_eff",param2,param2) + _loc5_.survivor.injuries.getTotalAttributeModifier("rng_min_eff") + this.getEffectAttributeMod(_loc4_,"rng_min_eff");
         }
         this.reloadTime = param2.getReloadTime();
         if(_loc5_ != null)
         {
            this.reloadTime *= 1 + _loc5_.getGearLoadoutAttributeMod(ItemAttributes.GROUP_WEAPON,"rldtime",param2,param2) + _loc5_.survivor.injuries.getTotalAttributeModifier("rldtime") + this.getEffectAttributeMod(_loc4_,"rldtime");
         }
         this.fireRate = param2.getFireRate();
         if(_loc5_ != null)
         {
            this.fireRate *= 1 + _loc5_.getGearLoadoutAttributeMod(ItemAttributes.GROUP_WEAPON,"rate",param2,param2) + _loc5_.survivor.injuries.getTotalAttributeModifier("rate") + this.getEffectAttributeMod(_loc4_,"rate");
         }
         this.capacity = param2.getCapacity();
         if(_loc5_ != null)
         {
            this.capacity *= 1 + _loc5_.getGearLoadoutAttributeMod(ItemAttributes.GROUP_WEAPON,"cap",param2,param2) + this.getEffectAttributeMod(_loc4_,"cap");
         }
         this.noise = param2.getNoise();
         if(_loc5_ != null)
         {
            this.noise *= 1 + _loc5_.getGearLoadoutAttributeMod(ItemAttributes.GROUP_WEAPON,"noise",param2,param2) + this.getEffectAttributeMod(_loc4_,"noise");
         }
         this.noise = Math.max(this.noise,0);
         this.idleNoise = param2.getIdleNoise();
         if(_loc5_ != null)
         {
            this.idleNoise *= 1 + _loc5_.getGearLoadoutAttributeMod(ItemAttributes.GROUP_WEAPON,"idle_noise",param2,param2) + this.getEffectAttributeMod(_loc4_,"idle_noise");
         }
         this.idleNoise = Math.max(this.idleNoise,0);
         this.knockbackChance = param2.getKnockbackChance();
         if(_loc5_ != null)
         {
            this.knockbackChance *= 1 + _loc5_.getGearLoadoutAttributeMod(ItemAttributes.GROUP_WEAPON,"knock",param2,param2) + _loc5_.survivor.injuries.getTotalAttributeModifier("knock") + this.getEffectAttributeMod(_loc4_,"knock");
         }
         this.knockbackChance = MathUtils.clamp(this.knockbackChance,0,0.99);
         this.attackArcCosine = Math.cos(param2.getAttackArc());
         if(_loc5_ != null)
         {
            this.attackArcCosine *= 1 + _loc5_.getGearLoadoutAttributeMod(ItemAttributes.GROUP_WEAPON,"arc",param2,param2) + _loc5_.survivor.injuries.getTotalAttributeModifier("arc") + this.getEffectAttributeMod(_loc4_,"arc");
         }
         var _loc18_:Number = param2.getSuppressionRate();
         if(_loc5_ != null)
         {
            _loc18_ *= 1 + _loc5_.getGearLoadoutAttributeMod(ItemAttributes.GROUP_WEAPON,"sup",param2,param2) + this.getEffectAttributeMod(_loc4_,"sub");
         }
         this.suppressionRate = _loc18_ / (Config.constant.SUPPRESSION_BASE_TIME / (this.fireRate / 1000));
         var _loc19_:Number = param2.getBaseAmmoCost();
         this.ammoCost = _loc19_ > 0 ? Math.max(1,Math.floor(1 / (this.fireRate / 1000) * _loc19_ + this.capacity)) : 0;
         if(_loc5_ != null)
         {
            this.ammoCost = int(this.ammoCost * (1 + _loc5_.getGearLoadoutAttributeMod(ItemAttributes.GROUP_WEAPON,"ammo_cost",param2,param2) + this.getEffectAttributeMod(_loc4_,"ammo_cost")));
         }
         this.readyTime = param2.getReadyTime();
         if(_loc4_ != null && _loc4_.team == AIAgent.TEAM_PLAYER)
         {
            _loc24_ = uint(EffectType.getTypeValue(this.isMelee ? "MeleeDamage" : "FirearmDamage"));
            _loc25_ = Network.getInstance().playerData.compound.getEffectValue(_loc24_);
            this.damageMult += this.damageMult * (_loc25_ / 100);
         }
      }
      
      private function getEffectAttributeMod(param1:Survivor, param2:String) : Number
      {
         if(param1 == null || !param1.isPlayerOwned)
         {
            return 0;
         }
         var _loc3_:ItemAttributes = Network.getInstance().playerData.compound.effects.attributes;
         return _loc3_.getModValue(ItemAttributes.GROUP_WEAPON,param2);
      }
   }
}

