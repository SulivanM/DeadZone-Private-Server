package thelaststand.app.game.logic.ai.states
{
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.entities.EntityFlags;
   import thelaststand.app.game.entities.buildings.ITrapEntity;
   import thelaststand.app.game.logic.ai.AIActorAgent;
   import thelaststand.app.game.logic.ai.effects.IAIEffect;
   import thelaststand.app.game.logic.ai.effects.SlowMovementEffect;
   import thelaststand.engine.map.Cell;
   
   public class TrapSlowMovementState implements IAITrapState
   {
      
      private var _onTriggered:Signal = new Signal(Building);
      
      private var _agent:Building;
      
      private var _tiles:Dictionary;
      
      private var _slowDown:Number;
      
      private var _damageAmount:Number;
      
      private var _damageTime:Number;
      
      private var _enemiesAffected:Dictionary;
      
      private var _triggered:Boolean;
      
      private var _disarmed:Boolean;
      
      public function TrapSlowMovementState(param1:Building)
      {
         super();
         this._agent = param1;
         this._slowDown = -0.75;
         this._enemiesAffected = new Dictionary(true);
         this._damageAmount = Number(param1.getLevelXML().dmg.toString()) / 100;
         this._damageTime = Number(param1.getLevelXML().dmg_time.toString());
      }
      
      public function get triggered() : Signal
      {
         return this._onTriggered;
      }
      
      public function dispose() : void
      {
         this._agent = null;
         this._tiles = null;
         this._enemiesAffected = null;
         this._onTriggered.removeAll();
      }
      
      public function enter(param1:Number) : void
      {
         var _loc3_:Cell = null;
         var _loc4_:uint = 0;
         this._tiles = new Dictionary(true);
         var _loc2_:int = this._agent.blackboard.scene.map.size.x;
         for each(_loc3_ in this._agent.blackboard.scene.map.getCellsEntityIsOccupying(this._agent.buildingEntity))
         {
            _loc4_ = uint(_loc3_.x + _loc3_.y * _loc2_);
            this._tiles[_loc4_] = _loc3_;
         }
      }
      
      public function exit(param1:Number) : void
      {
         this.cancelEffects();
      }
      
      private function cancelEffects() : void
      {
         var _loc1_:Object = null;
         var _loc2_:AIActorAgent = null;
         var _loc3_:IAIEffect = null;
         for(_loc1_ in this._enemiesAffected)
         {
            _loc2_ = AIActorAgent(_loc1_);
            _loc3_ = this._enemiesAffected[_loc2_];
            _loc2_.effectEngine.removeEffect(_loc3_);
            _loc3_.dispose();
            delete this._enemiesAffected[_loc2_];
         }
      }
      
      public function update(param1:Number, param2:Number) : void
      {
         var _loc6_:AIActorAgent = null;
         var _loc7_:Cell = null;
         var _loc8_:SlowMovementEffect = null;
         var _loc9_:uint = 0;
         var _loc10_:String = null;
         if(this._disarmed)
         {
            return;
         }
         if(this._agent.flags & EntityFlags.TRAP_DISARMED)
         {
            this._disarmed = true;
            this.cancelEffects();
            return;
         }
         var _loc3_:Vector.<AIActorAgent> = this._agent.blackboard.enemies;
         var _loc4_:int = 0;
         var _loc5_:int = int(_loc3_.length);
         for(; _loc4_ < _loc5_; _loc4_++)
         {
            _loc6_ = _loc3_[_loc4_];
            if(_loc6_.health > 0)
            {
               if(this._agent.flags & EntityFlags.TRAP_DETECTED)
               {
                  if(_loc6_ is Survivor && Survivor(_loc6_).canDisarmTraps && Boolean(_loc6_.flags & EntityFlags.DISARMING_TRAP))
                  {
                     _loc8_ = this._enemiesAffected[_loc6_];
                     if(_loc8_ != null)
                     {
                        _loc6_.effectEngine.removeEffect(_loc8_);
                        _loc8_.dispose();
                        delete this._enemiesAffected[_loc6_];
                     }
                     continue;
                  }
               }
               _loc7_ = this._agent.blackboard.scene.map.getCellAtCoords(_loc6_.navigator.position.x,_loc6_.navigator.position.y);
               if(_loc7_ != null)
               {
                  _loc8_ = this._enemiesAffected[_loc6_];
                  _loc9_ = _loc7_.x + _loc7_.y * this._agent.blackboard.scene.map.size.x;
                  if(this._tiles[_loc9_] != null)
                  {
                     if(!this._triggered)
                     {
                        this.trigger();
                     }
                     if(_loc8_ == null)
                     {
                        _loc8_ = new SlowMovementEffect(_loc6_,this._slowDown,this._damageAmount,this._damageTime);
                        _loc8_.owner = this._agent;
                        _loc6_.effectEngine.addEffect(_loc8_);
                        this._enemiesAffected[_loc6_] = _loc8_;
                        this._agent.soundSource.play(this._agent.getSound("fire"));
                     }
                     else if(Math.random() < 0.1)
                     {
                        _loc10_ = this._agent.getSound("fire");
                        if(!Audio.sound.isPlaying(_loc10_))
                        {
                           this._agent.soundSource.play(_loc10_);
                        }
                     }
                  }
                  else if(_loc8_ != null)
                  {
                     _loc6_.effectEngine.removeEffect(_loc8_);
                     _loc8_.dispose();
                     delete this._enemiesAffected[_loc6_];
                  }
               }
            }
         }
      }
      
      public function trigger() : void
      {
         this._triggered = true;
         this._agent.flags |= EntityFlags.TRAP_DETECTED | EntityFlags.TRAP_TRIGGERED;
         this._agent.buildingEntity.asset.visible = true;
         ITrapEntity(this._agent.buildingEntity).activate();
         this._onTriggered.dispatch(this._agent);
      }
   }
}

