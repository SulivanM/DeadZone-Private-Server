package thelaststand.app.game.logic
{
   import flash.events.TimerEvent;
   import flash.system.Capabilities;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import org.osflash.signals.Signal;
   import playerio.Message;
   import thelaststand.aftermath;
   import thelaststand.app.core.Global;
   import thelaststand.app.game.data.BatchRecycleJob;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.TimerData;
   import thelaststand.app.game.data.effects.Cooldown;
   import thelaststand.app.game.data.effects.Effect;
   import thelaststand.app.game.data.injury.Injury;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.NetworkMessage;
   
   use namespace aftermath;
   
   public class TimerManager
   {
      
      private static var _instance:TimerManager;
      
      private var _timers:Vector.<TimerData>;
      
      private var _timersByTarget:Dictionary;
      
      private var _updateTimer:Timer;
      
      public var timerStarted:Signal;
      
      public var timerCompleted:Signal;
      
      public var timerCancelled:Signal;
      
      public function TimerManager(param1:TimerManagerSingletonEnforcer)
      {
         super();
         if(!param1)
         {
            throw new Error("TimerManager is a Singleton and cannot be directly instantiated. Use TimerManager.getInstance().");
         }
         this._timers = new Vector.<TimerData>();
         this._updateTimer = new Timer(100);
         this._updateTimer.addEventListener(TimerEvent.TIMER,this.onUpdateTimerTick,false,0,true);
         this._updateTimer.start();
         this._timersByTarget = new Dictionary(true);
         this.timerStarted = new Signal(TimerData);
         this.timerCompleted = new Signal(TimerData);
         this.timerCancelled = new Signal(TimerData);
         Network.getInstance().connection.addMessageHandler(NetworkMessage.BUILDING_COMPLETE,this.onTimerComplete);
         Network.getInstance().connection.addMessageHandler(NetworkMessage.BUILDING_REPAIR_COMPLETE,this.onTimerComplete);
         Network.getInstance().connection.addMessageHandler(NetworkMessage.MISSION_RETURN_COMPLETE,this.onTimerComplete);
         Network.getInstance().connection.addMessageHandler(NetworkMessage.MISSION_LOCK_COMPLETE,this.onTimerComplete);
         Network.getInstance().connection.addMessageHandler(NetworkMessage.SURVIVOR_REASSIGNMENT_COMPLETE,this.onTimerComplete);
         Network.getInstance().connection.addMessageHandler(NetworkMessage.SURVIVOR_INJURY_COMPLETE,this.onTimerComplete);
         Network.getInstance().connection.addMessageHandler(NetworkMessage.BATCH_RECYCLE_COMPLETE,this.onTimerComplete);
         Network.getInstance().connection.addMessageHandler(NetworkMessage.EFFECT_COMPLETE,this.onTimerComplete);
         Network.getInstance().connection.addMessageHandler(NetworkMessage.EFFECT_LOCKOUT_COMPLETE,this.onTimerComplete);
         Network.getInstance().connection.addMessageHandler(NetworkMessage.COOLDOWN_COMPLETE,this.onTimerComplete);
      }
      
      public static function getInstance() : TimerManager
      {
         if(!_instance)
         {
            _instance = new TimerManager(new TimerManagerSingletonEnforcer());
         }
         return _instance;
      }
      
      public static function createTimer(param1:int, param2:*, param3:Date = null, param4:Object = null) : TimerData
      {
         var _loc5_:TimerData = new TimerData(param3 ? param3 : new Date(Network.getInstance().serverTime),param1,param2);
         if(param4)
         {
            _loc5_.data = param4;
         }
         _instance.addTimer(_loc5_);
         return _loc5_;
      }
      
      public function addTimer(param1:TimerData) : TimerData
      {
         if(this._timers.indexOf(param1) > -1)
         {
            return null;
         }
         this._timers.push(param1);
         var _loc2_:Vector.<TimerData> = this._timersByTarget[param1.target];
         if(_loc2_ == null)
         {
            _loc2_ = this._timersByTarget[param1.target] = new Vector.<TimerData>();
         }
         _loc2_.push(param1);
         var _loc3_:Number = Network.getInstance().serverTime;
         var _loc4_:Number = param1.timeStart.time;
         var _loc5_:Number = param1.timeEnd.time;
         param1.aftermath::setProgress((_loc3_ - _loc4_) / (_loc5_ - _loc4_));
         param1.aftermath::setTimeRemaining(_loc5_ - _loc4_ - (_loc3_ - _loc4_));
         return param1;
      }
      
      public function cancelTimer(param1:TimerData) : TimerData
      {
         this.removeTimer(param1);
         param1.aftermath::setRunning(false);
         param1.cancelled.dispatch(param1);
         this.timerCancelled.dispatch(param1);
         return param1;
      }
      
      public function dispose() : void
      {
         this._timers = null;
         this._timersByTarget = null;
         this.timerStarted.removeAll();
         this.timerCompleted.removeAll();
         this.timerCancelled.removeAll();
      }
      
      public function endTimer(param1:TimerData) : TimerData
      {
         this.removeTimer(param1);
         param1.aftermath::setRunning(false);
         param1.aftermath::setProgress(1);
         param1.aftermath::setTimeRemaining(0);
         param1.completed.dispatch(param1);
         this.timerCompleted.dispatch(param1);
         return param1;
      }
      
      public function getTimer(param1:int) : TimerData
      {
         if(param1 < 0 || param1 >= this._timers.length)
         {
            return null;
         }
         return this._timers[param1];
      }
      
      public function getTimersForTarget(param1:*) : Vector.<TimerData>
      {
         if(this._timersByTarget[param1])
         {
            return this._timersByTarget[param1].concat();
         }
         return null;
      }
      
      public function removeTimer(param1:TimerData) : TimerData
      {
         var _loc3_:Vector.<TimerData> = null;
         var _loc2_:int = int(this._timers.indexOf(param1));
         if(_loc2_ == -1)
         {
            return null;
         }
         this._timers.splice(_loc2_,1);
         if(this._timersByTarget[param1.target] != null)
         {
            _loc3_ = this._timersByTarget[param1.target];
            _loc3_.splice(_loc3_.indexOf(param1),1);
         }
         return param1;
      }
      
      private function onUpdateTimerTick(param1:TimerEvent) : void
      {
         var _loc3_:TimerData = null;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc2_:Number = Network.getInstance().serverTime;
         for each(_loc3_ in this._timers)
         {
            _loc4_ = _loc3_.timeStart.time;
            _loc5_ = _loc3_.timeEnd.time;
            _loc6_ = (_loc2_ - _loc4_) / (_loc5_ - _loc4_);
            _loc7_ = _loc5_ - _loc4_ - (_loc2_ - _loc4_);
            _loc3_.aftermath::setProgress(_loc6_);
            _loc3_.aftermath::setTimeRemaining(_loc7_);
            if(_loc6_ >= 0 && !_loc3_.running)
            {
               _loc3_.aftermath::setRunning(true);
               _loc3_.started.dispatch(_loc3_);
               this.timerStarted.dispatch(_loc3_);
            }
         }
      }
      
      private function onTimerComplete(param1:Message) : void
      {
         var id:String = null;
         var timer:TimerData = null;
         var bld:Building = null;
         var mission:MissionData = null;
         var survivor:Survivor = null;
         var injury:Injury = null;
         var batchRecycleJob:BatchRecycleJob = null;
         var effect:Effect = null;
         var cooldown:Cooldown = null;
         var data:Object = null;
         var msg:Message = param1;
         if(msg.length <= 0)
         {
            return;
         }
         id = msg.getString(0).toUpperCase();
         try
         {
            var _loc3_:int = 0;
            var _loc4_:* = this._timers;
            while(true)
            {
               loop0:
               for each(timer in _loc4_)
               {
                  if(timer == null || timer.target == null)
                  {
                     continue;
                  }
                  switch(msg.type)
                  {
                     case NetworkMessage.BUILDING_COMPLETE:
                     case NetworkMessage.BUILDING_REPAIR_COMPLETE:
                        bld = timer.target as Building;
                        if(bld != null && bld.id.toUpperCase() == id)
                        {
                           if(msg.type == NetworkMessage.BUILDING_COMPLETE && (timer.data != null && timer.data.type == "upgrade") || msg.type == NetworkMessage.BUILDING_REPAIR_COMPLETE && (timer.data != null && timer.data.type == "repair"))
                           {
                              this.endTimer(timer);
                              return;
                           }
                        }
                        break;
                     case NetworkMessage.MISSION_LOCK_COMPLETE:
                     case NetworkMessage.MISSION_RETURN_COMPLETE:
                        mission = timer.target as MissionData;
                        if(mission != null && mission.id.toUpperCase() == id)
                        {
                           if(msg.type == NetworkMessage.MISSION_RETURN_COMPLETE && (timer.data != null && timer.data.type == "return"))
                           {
                              if(msg.length > 1)
                              {
                                 data = JSON.parse(msg.getString(1));
                                 timer.data.injuries = data.inj;
                                 timer.data.items = data.items;
                              }
                              this.endTimer(timer);
                              return;
                           }
                           if(msg.type == NetworkMessage.MISSION_LOCK_COMPLETE && (timer.data != null && timer.data.type == "lock"))
                           {
                              this.endTimer(timer);
                              return;
                           }
                        }
                        break;
                     case NetworkMessage.SURVIVOR_REASSIGNMENT_COMPLETE:
                        survivor = timer.target as Survivor;
                        if(survivor != null && survivor.id.toUpperCase() == id)
                        {
                           if(timer.data != null && timer.data.type == "reassign")
                           {
                              this.endTimer(timer);
                              return;
                           }
                        }
                        break;
                     case NetworkMessage.SURVIVOR_INJURY_COMPLETE:
                        injury = timer.target as Injury;
                        if(injury != null && injury.id.toUpperCase() == id)
                        {
                           this.endTimer(timer);
                           return;
                        }
                        break;
                     case NetworkMessage.BATCH_RECYCLE_COMPLETE:
                        batchRecycleJob = timer.target as BatchRecycleJob;
                        if(batchRecycleJob != null && batchRecycleJob.id.toUpperCase() == id)
                        {
                           this.endTimer(timer);
                           return;
                        }
                        break;
                     case NetworkMessage.EFFECT_COMPLETE:
                     case NetworkMessage.EFFECT_LOCKOUT_COMPLETE:
                        effect = timer.target as Effect;
                        if(effect != null && effect.id.toUpperCase() == id)
                        {
                           break loop0;
                        }
                        break;
                     case NetworkMessage.COOLDOWN_COMPLETE:
                        cooldown = timer.target as Cooldown;
                        if(cooldown != null && cooldown.id.toUpperCase() == id)
                        {
                           this.endTimer(timer);
                           return;
                        }
                  }
               }
            }
            if(msg.type == NetworkMessage.EFFECT_COMPLETE && (timer.data != null && timer.data.type == "consume") || msg.type == NetworkMessage.EFFECT_LOCKOUT_COMPLETE && (timer.data != null && timer.data.type == "lockout"))
            {
               this.endTimer(timer);
               return;
            }
            return;
         }
         catch(error:Error)
         {
            if(Network.getInstance().client != null && Capabilities.isDebugger)
            {
               Network.getInstance().client.errorLog.writeError("TimerManager.onTimerComplete exception",id,error.getStackTrace(),Global.getCapabilityData({"player":Network.getInstance().playerData.id}));
            }
         }
      }
      
      public function get numTimers() : int
      {
         return this._timers.length;
      }
   }
}

class TimerManagerSingletonEnforcer
{
   
   public function TimerManagerSingletonEnforcer()
   {
      super();
   }
}
