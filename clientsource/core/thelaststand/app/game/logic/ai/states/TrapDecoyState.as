package thelaststand.app.game.logic.ai.states
{
   import alternativa.engine3d.core.Object3D;
   import com.greensock.easing.Back;
   import flash.geom.Vector3D;
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.entities.EntityFlags;
   import thelaststand.app.game.entities.effects.Confetti;
   import thelaststand.app.game.logic.ai.AIActorAgent;
   import thelaststand.engine.utils.TweenMaxDelta;
   
   public class TrapDecoyState implements IAITrapState
   {
      
      private var _onTriggered:Signal = new Signal(Building);
      
      private var _agent:Building;
      
      private var _worldCenter:Vector3D;
      
      private var _detectionRadius:Number;
      
      private var _triggered:Boolean;
      
      private var _triggerTimer:Number;
      
      private var _triggerTime:Number;
      
      public function TrapDecoyState(param1:Building)
      {
         super();
         this._agent = param1;
         this._worldCenter = new Vector3D();
         this._triggerTimer = 0;
         this._triggerTime = Number(this._agent.getLevelXML().trig_time.toString());
      }
      
      public function get triggered() : Signal
      {
         return this._onTriggered;
      }
      
      public function dispose() : void
      {
         this._agent = null;
         this._onTriggered.removeAll();
      }
      
      public function enter(param1:Number) : void
      {
         this._worldCenter.x = this._agent.buildingEntity.transform.position.x + this._agent.buildingEntity.centerPoint.x;
         this._worldCenter.y = this._agent.buildingEntity.transform.position.y + this._agent.buildingEntity.centerPoint.y;
         this._detectionRadius = this._agent.buildingEntity.scene.map.cellSize * Number(this._agent.getLevelXML().detect_rng.toString());
      }
      
      public function exit(param1:Number) : void
      {
      }
      
      public function update(param1:Number, param2:Number) : void
      {
         var _loc6_:AIActorAgent = null;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         if(this._triggered)
         {
            this._triggerTimer += param1;
            if(this._triggerTimer >= this._triggerTime)
            {
               this.explode();
            }
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
                     continue;
                  }
               }
               _loc7_ = _loc6_.actor.transform.position.x - this._worldCenter.x;
               _loc8_ = _loc6_.actor.transform.position.y - this._worldCenter.y;
               _loc9_ = _loc7_ * _loc7_ + _loc8_ * _loc8_;
               if(_loc9_ < this._detectionRadius * this._detectionRadius)
               {
                  this.trigger();
                  break;
               }
            }
         }
      }
      
      public function trigger() : void
      {
         this._triggered = true;
         this._triggerTimer = 0;
         this._agent.soundSource.play(this._agent.getSound("trigger"),{
            "minDistance":5000,
            "maxDistance":10000
         });
         this._agent.buildingEntity.asset.visible = true;
         this._agent.flags |= EntityFlags.TRAP_DETECTED | EntityFlags.TRAP_TRIGGERED;
         this._onTriggered.dispatch(this._agent);
      }
      
      private function explode() : void
      {
         var _loc2_:Object3D = null;
         this._agent.soundSource.play(this._agent.getSound("fire"),{
            "minDistance":5000,
            "maxDistance":10000
         });
         var _loc1_:Confetti = new Confetti(this._worldCenter.x,this._worldCenter.y);
         this._agent.entity.scene.addEntity(_loc1_);
         if(this._agent.buildingEntity.buildingMesh != null)
         {
            this._agent.buildingEntity.showDecoyMarker(true);
            _loc2_ = this._agent.buildingEntity.buildingMesh.getChildByName("decoy");
            if(_loc2_ != null)
            {
               _loc2_.visible = true;
               _loc2_.scaleX = _loc2_.scaleY = _loc2_.scaleZ = 0;
               TweenMaxDelta.to(_loc2_,0.25,{
                  "scaleX":1,
                  "scaleY":1,
                  "scaleZ":1,
                  "ease":Back.easeOut
               });
            }
         }
         this._agent.die(null);
      }
   }
}

