package thelaststand.app.game.data
{
   import com.deadreckoned.threshold.math.Random;
   import com.exileetiquette.math.MathUtils;
   import flash.events.TimerEvent;
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.core.Config;
   import thelaststand.app.core.Settings;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.game.data.enemies.EnemyEliteType;
   import thelaststand.app.game.entities.effects.BloodSpray;
   import thelaststand.app.game.entities.effects.Explosion;
   import thelaststand.app.game.logic.ai.AIAgent;
   import thelaststand.app.game.logic.ai.AIZombieAgent;
   import thelaststand.app.network.Network;
   import thelaststand.engine.scenes.Scene;
   
   public class Zombie extends AIZombieAgent
   {
      
      private var _level:int = 0;
      
      private var _type:String;
      
      private var _enemyType:String;
      
      private var _dmgResistances:Dictionary;
      
      private var _explosive:XML;
      
      private var _explosiveTimer:Timer;
      
      private var _explosiveSoundTimer:Timer;
      
      private var _explosiveTimerStart:int;
      
      private var _explodedOnDeath:Boolean;
      
      protected var _state:String;
      
      protected var _moveAnim:String;
      
      protected var _enemyClass:String;
      
      protected var _xml:XML;
      
      public var chasesTargets:Boolean;
      
      public var inGameWorld:Boolean;
      
      public var nextThinkTime:Number = 0;
      
      public var alertRating:Number = 0;
      
      public var spawnTime:Number = 0;
      
      public var alertNoise:Number = 0;
      
      public var threatTime:Number = 0;
      
      public var isRushZombie:Boolean = false;
      
      public function Zombie()
      {
         super();
         agentData.useGuardPoint = false;
         agentData.canCauseCriticals = false;
         agentData.canCauseBackCriticals = false;
         agentData.canSeeBehind = true;
         agentData.isZombie = true;
         damageTaken.add(this.onDamageTaken);
         died.add(this.onDeath);
      }
      
      override public function dispose() : void
      {
         if(agentData == null)
         {
            return;
         }
         damageTaken.remove(this.onDamageTaken);
         died.remove(this.onDeath);
         this._xml = null;
         this._enemyType = null;
         this._enemyClass = null;
         if(weapon != null)
         {
            weapon.dispose();
         }
         super.dispose();
      }
      
      override public function reset() : void
      {
         super.reset();
         soundSource.stopAll();
         stateMachine.clear();
         agentData.reset();
         this._xml = null;
         this._state = null;
         this._explodedOnDeath = false;
         this.chasesTargets = false;
         this.inGameWorld = false;
         if(weapon != null)
         {
            weapon.dispose();
         }
      }
      
      override public function getAnimation(param1:String) : String
      {
         if(param1 == "hurt")
         {
            return Math.random() < 0.5 ? "hurt-01" : "hurt-02";
         }
         if(param1 == "getup")
         {
            return Math.random() < 0.5 ? "knockdown-rise-back" : "knockdown-rise-side";
         }
         var _loc2_:XMLList = this._xml.mdl.anim[param1];
         if(_loc2_ == null || _loc2_.length() == 0)
         {
            return null;
         }
         return _loc2_[int(Math.random() * _loc2_.length())].toString();
      }
      
      public function switchToChase() : void
      {
         this.setState(this.chasesTargets ? "chase" : "wander");
         if(this._explosiveTimer != null)
         {
            this._explosiveTimer.start();
            this._explosiveSoundTimer.start();
            this._explosiveTimerStart = getTimer();
         }
      }
      
      public function switchToWander() : void
      {
         this.setState("wander");
      }
      
      public function setDefinition(param1:XML, param2:int, param3:XML) : void
      {
         var _loc10_:XML = null;
         var _loc11_:Number = NaN;
         var _loc12_:String = null;
         var _loc13_:uint = 0;
         var _loc14_:Number = NaN;
         var _loc4_:String = this._state;
         this._xml = param1;
         this._level = param2;
         this._state = null;
         this._type = this._xml.@id.toString();
         this._enemyType = param1.@type.toString();
         _eliteType = EnemyEliteType.getValue(param1.@elite.toString());
         if(this._xml.hasOwnProperty("scale"))
         {
            actor.defaultScale = Number(this._xml.scale);
         }
         if(this._xml.hasOwnProperty("resistances"))
         {
            this._dmgResistances = new Dictionary(true);
            for each(_loc10_ in this._xml.resistances.children())
            {
               _loc11_ = Number(_loc10_.toString());
               if(!(_loc11_ == 0 || isNaN(_loc11_)))
               {
                  _loc12_ = _loc10_.localName().toLowerCase();
                  if(_loc12_ == "knockback")
                  {
                     knockbackResistance = _loc11_;
                  }
                  else
                  {
                     _loc13_ = DamageType.getValue(_loc12_);
                     if(_loc13_ != DamageType.UNKNOWN)
                     {
                        this._dmgResistances[_loc13_] = _loc11_;
                     }
                  }
               }
            }
         }
         this._explosive = this._xml.hasOwnProperty("explosive") ? this._xml.explosive[0] : null;
         if(this._explosive != null)
         {
            _loc14_ = Number(this._explosive.timer);
            if(!isNaN(_loc14_))
            {
               this._explosiveTimer = new Timer(_loc14_ * 1000,1);
               this._explosiveTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onExplosiveTimerCompleted,false,0,true);
               this._explosiveSoundTimer = new Timer(1000,0);
               this._explosiveSoundTimer.addEventListener(TimerEvent.TIMER,this.onExplosiveSoundTimerTick,false,0,true);
            }
         }
         if(Network.getInstance().playerData.compound.getEffectValue(EffectType.getTypeValue("HalloweenTrickTinyZombie")) > 0)
         {
            actor.defaultScale *= 0.8;
         }
         hp_multiplier = Number(this._xml.hp_mult.toString());
         xp_multiplier = Number(this._xml.xp_mult.toString());
         this.chasesTargets = this._xml.hasOwnProperty("spd_chase");
         this.alertNoise = this._xml.hasOwnProperty("noise") ? Number(this._xml.noise.toString()) : 0;
         navigator.mass = Number(this._xml.mass.toString());
         var _loc5_:Boolean = Network.getInstance().playerData.compound.effects.hasEffectType(EffectType.getTypeValue("ZombieCriticals"));
         agentData.canCauseCriticals = agentData.canCauseBackCriticals = _loc5_;
         var _loc6_:Weapon = new Weapon();
         _loc6_.xml = param3;
         _loc6_.baseLevel = this._level;
         _weapon = _loc6_;
         _weaponData.populate(this,_weapon);
         var _loc7_:Number = Network.getInstance().playerData.compound.getEffectValue(EffectType.getTypeValue("ZombieDamage"));
         _weaponData.damageMult += _weaponData.damageMult * (_loc7_ / 100);
         var _loc8_:Number = Network.getInstance().playerData.compound.getEffectValue(EffectType.getTypeValue("ZombieHealth"));
         var _loc9_:Number = int(Config.constant.BASE_ZOMBIE_HEALTH) * (this._level + 1) * Number(Config.constant.BASE_ZOMBIE_HEALTH_MULT) * hp_multiplier / 100;
         _maxHealth = _loc9_ + _loc9_ * (_loc8_ / 100);
         _health = _maxHealth;
         this.addAnimations();
         this.setupModel();
         this.setState(_loc4_);
      }
      
      override public function updateMaxSpeed() : void
      {
         var _loc1_:Number = Number(this._xml["spd_" + this._state].toString());
         var _loc2_:Number = _loc1_ + Math.random() * _loc1_ * 0.5;
         var _loc3_:Number = _loc2_ * _effectEngine.getMultiplierForAttribute(Attributes.MOVEMENT_SPEED);
         navigator.maxSpeed = _loc2_ + _loc3_;
         averageSpeed = _loc2_ * 1.25;
      }
      
      override protected function onDie(param1:Object) : void
      {
         var _loc2_:* = false;
         var _loc3_:AIAgent = null;
         var _loc4_:Scene = null;
         var _loc5_:Vector3D = null;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:String = null;
         var _loc11_:Explosion = null;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:BloodSpray = null;
         super.onDie(param1);
         if(this._explosiveTimer != null)
         {
            this._explosiveSoundTimer.stop();
            this._explosiveTimer.stop();
         }
         if(this._explosive != null)
         {
            _loc2_ = true;
            _loc3_ = param1 as AIAgent;
            if(_loc3_ != null)
            {
               _loc2_ = !_loc3_.weaponData.isMelee;
            }
            if(_loc2_)
            {
               this._explodedOnDeath = true;
               _loc4_ = actor.scene;
               _loc5_ = actor.transform.position;
               _loc6_ = Number(this._explosive.dmg);
               _loc7_ = Number(this._explosive.dmg_bld);
               _loc8_ = Number(this._explosive.rng) * 100;
               _loc9_ = Number(this._explosive.vrng) * 100;
               _loc10_ = this._explosive.sound.toString();
               _loc11_ = new Explosion(this,_loc5_.x,_loc5_.y,_loc5_.z,_loc6_,_loc7_,_loc8_,_loc9_,blackboard.allAgents,_loc10_);
               _loc11_.ownerItem = null;
               _loc4_.addEntity(_loc11_);
               if(actor != null && actor.asset != null)
               {
                  actor.asset.visible = false;
               }
               if(Settings.getInstance().gore)
               {
                  _loc12_ = 6;
                  _loc13_ = 0;
                  while(_loc13_ < _loc12_)
                  {
                     _loc14_ = Math.PI * 2 * (_loc13_ / _loc12_);
                     _loc15_ = Math.cos(_loc14_) * 100;
                     _loc16_ = Math.sin(_loc14_) * 100;
                     _loc17_ = 0;
                     _loc18_ = _loc5_.z + actor.getHeight() * 0.75;
                     _loc19_ = BloodSpray.pool.get() as BloodSpray;
                     if(_loc19_ != null)
                     {
                        _loc19_.init(_loc5_.x,_loc5_.y,_loc18_,new Vector3D(_loc15_,_loc16_,_loc17_),1 + Math.random(),12);
                        _loc4_.addEntity(_loc19_);
                     }
                     _loc13_++;
                  }
               }
            }
            else
            {
               this._explodedOnDeath = false;
            }
         }
      }
      
      override public function applyDamageResistance(param1:Number, param2:uint) : Number
      {
         var _loc3_:Number = NaN;
         if(this._dmgResistances != null)
         {
            _loc3_ = Number(this._dmgResistances[param2]);
            if(_loc3_ != 0 && !isNaN(_loc3_))
            {
               param1 -= param1 * _loc3_;
            }
         }
         if(param1 < 0)
         {
            param1 = 0;
         }
         return param1;
      }
      
      protected function setState(param1:String) : void
      {
         if(param1 == this._state)
         {
            return;
         }
         this._state = param1;
         this._moveAnim = this.getAnimation(this._state);
         this.updateMaxSpeed();
         if(navigator.isMoving)
         {
            actor.animatedAsset.play(this._moveAnim,true);
         }
      }
      
      protected function addAnimations() : void
      {
         throw new Error("This method should be overridden by subclasses.");
      }
      
      protected function setupModel() : void
      {
         throw new Error("This method should be overridden by subclasses.");
      }
      
      private function onDamageTaken(param1:Zombie, param2:Number, param3:Object, param4:Boolean) : void
      {
         if(soundSource != null && actor.scene != null && Math.random() < 0.5)
         {
            soundSource.play(getSound("hurt"),{"volume":Random.float(0.2,0.5)});
         }
      }
      
      private function onDeath(param1:Zombie, param2:Object) : void
      {
         if(soundSource != null && actor.scene != null)
         {
            soundSource.play(getSound("death"));
         }
      }
      
      private function onExplosiveTimerCompleted(param1:TimerEvent) : void
      {
         die(null);
      }
      
      private function onExplosiveSoundTimerTick(param1:TimerEvent) : void
      {
         Audio.sound.play("sound/interface/explosive-timer.mp3");
         var _loc2_:Number = getTimer() - this._explosiveTimerStart;
         var _loc3_:Number = (this._explosiveTimer.delay - _loc2_) / 1000;
         if(_loc3_ < 5)
         {
            this._explosiveSoundTimer.delay = MathUtils.clamp(_loc3_ / 5,0.2,1) * 1000;
         }
         else
         {
            this._explosiveSoundTimer.delay = 1000;
         }
      }
      
      public function get xml() : XML
      {
         return this._xml;
      }
      
      public function get enemyType() : String
      {
         return this._enemyType;
      }
      
      public function get type() : String
      {
         return this._type;
      }
      
      public function get explodedOnDeath() : Boolean
      {
         return this._explodedOnDeath;
      }
   }
}

