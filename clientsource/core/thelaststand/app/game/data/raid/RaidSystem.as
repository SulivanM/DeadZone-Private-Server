package thelaststand.app.game.data.raid
{
   import com.dynamicflash.util.Base64;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Global;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.data.NavigationLocation;
   import thelaststand.app.events.NavigationEvent;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemFactory;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.UnknownOpponentData;
   import thelaststand.app.game.data.assignment.AssignmentStageState;
   import thelaststand.app.game.data.assignment.AssignmentType;
   import thelaststand.app.game.logic.DialogueController;
   import thelaststand.app.gui.dialogues.BusyDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.common.lang.Language;
   
   public class RaidSystem
   {
      
      public static var raidStarted:Signal = new Signal(RaidData);
      
      public static var raidEnded:Signal = new Signal(RaidData);
      
      public function RaidSystem()
      {
         super();
      }
      
      public static function handleRaidMissionResult(param1:Object, param2:MissionData) : void
      {
         var _loc3_:int = 0;
         var _loc8_:RaidStageData = null;
         var _loc9_:String = null;
         var _loc10_:Survivor = null;
         var _loc11_:Array = null;
         var _loc12_:Item = null;
         var _loc4_:RaidData = Network.getInstance().playerData.assignments.getById(param1.id) as RaidData;
         if(_loc4_ == null)
         {
            return;
         }
         var _loc5_:RaidStageData = _loc4_.getRaidStage(_loc4_.currentStageIndex);
         _loc5_.survivorCount = int(param1.srvcount);
         _loc5_.objectiveState = uint(param1.objstate);
         _loc4_.completedStageIndex = _loc5_.index;
         var _loc6_:Boolean = Boolean(param1.completed);
         _loc4_.isCompleted = _loc6_;
         _loc4_.points = int(param1.points);
         _loc4_.currentStageIndex = int(param1.stage);
         _loc3_ = 0;
         while(_loc3_ < _loc4_.stageCount)
         {
            _loc8_ = _loc4_.getRaidStage(_loc3_);
            if(_loc3_ < _loc4_.currentStageIndex)
            {
               _loc8_.state = AssignmentStageState.COMPLETE;
            }
            else if(_loc3_ == _loc4_.currentStageIndex)
            {
               _loc8_.state = AssignmentStageState.ACTIVE;
            }
            else
            {
               _loc8_.state = AssignmentStageState.LOCKED;
            }
            _loc3_++;
         }
         var _loc7_:Array = param1.returnsurvivors as Array;
         _loc3_ = 0;
         while(_loc3_ < _loc7_.length)
         {
            _loc9_ = _loc7_[_loc3_];
            _loc10_ = Network.getInstance().playerData.compound.survivors.getSurvivorById(_loc9_);
            _loc10_.assignmentId = null;
            _loc10_.missionId = null;
            _loc4_.removeSurvivor(_loc10_);
            _loc3_++;
         }
         if(param1.cooldown != null)
         {
            Network.getInstance().playerData.cooldowns.parse(Base64.decodeToByteArray(param1.cooldown));
         }
         if(_loc6_)
         {
            _loc4_.successful = Boolean(param1.assignsuccess);
            _loc4_.rewardItems = new Vector.<Item>();
            if(param1.items is Array)
            {
               _loc11_ = param1.items;
               _loc3_ = 0;
               while(_loc3_ < _loc11_.length)
               {
                  _loc12_ = ItemFactory.createItemFromObject(_loc11_[_loc3_]);
                  if(_loc12_ != null)
                  {
                     _loc4_.rewardItems.push(_loc12_);
                     Network.getInstance().playerData.giveItem(_loc12_,true);
                     if(param2 != null)
                     {
                        param2.addLootItem(_loc12_);
                     }
                  }
                  _loc3_++;
               }
            }
            Global.completedAssignment = _loc4_;
            Network.getInstance().playerData.assignments.remove(_loc4_);
            Network.getInstance().playerData.checkAndUpdateLoadouts();
            RaidSystem.raidEnded.dispatch(_loc4_);
            try
            {
               if(_loc4_.successful)
               {
                  Tracking.trackEvent("Raid","Completed",_loc4_.name);
               }
               else
               {
                  Tracking.trackEvent("Raid","Failed",_loc4_.name,_loc5_.index);
               }
            }
            catch(error:Error)
            {
            }
         }
      }
      
      public static function launchRaid(param1:RaidData, param2:Function = null) : void
      {
         var data:Object;
         var missionData:MissionData = null;
         var busy:BusyDialogue = null;
         var onMissionStarted:Function = null;
         var i:int = 0;
         var srv:Survivor = null;
         var raidData:RaidData = param1;
         var onComplete:Function = param2;
         busy = new BusyDialogue(Language.getInstance().getString("raid.launching_raid"));
         busy.open();
         onMissionStarted = function():void
         {
            if(onComplete != null)
            {
               onComplete(true);
            }
            Network.getInstance().playerData.missionList.addMission(missionData);
            Global.stage.dispatchEvent(new NavigationEvent(NavigationEvent.REQUEST,NavigationLocation.MISSION,missionData));
         };
         data = {};
         if(raidData.hasStarted)
         {
            data.id = raidData.id;
            Network.getInstance().save(data,SaveDataMethod.RAID_CONTINUE,function(param1:Object):void
            {
               busy.close();
               if(param1 == null || param1.success !== true)
               {
                  DialogueController.getInstance().showGenericRequestError();
                  if(onComplete != null)
                  {
                     onComplete(false);
                  }
                  return;
               }
               missionData = createMissionData(raidData,param1.mission);
               missionData.startMission(onMissionStarted);
            });
         }
         else
         {
            data.name = raidData.name;
            data.survivors = [];
            data.loadout = [];
            i = 0;
            while(i < raidData.survivorIds.length)
            {
               srv = Network.getInstance().playerData.compound.survivors.getSurvivorById(raidData.survivorIds[i]);
               data.survivors.push(srv.id);
               data.loadout.push(srv.loadoutOffence.toHashtable());
               i++;
            }
            Network.getInstance().save(data,SaveDataMethod.RAID_START,function(param1:Object):void
            {
               var _loc2_:int = 0;
               var _loc4_:String = null;
               var _loc5_:Survivor = null;
               busy.close();
               if(param1 == null || param1.success !== true)
               {
                  DialogueController.getInstance().showGenericRequestError();
                  if(onComplete != null)
                  {
                     onComplete(false);
                  }
                  return;
               }
               raidData.id = String(param1.id);
               raidData.hasStarted = true;
               raidData.survivorIds.length = 0;
               var _loc3_:Array = param1.survivors as Array;
               _loc2_ = 0;
               while(_loc2_ < _loc3_.length)
               {
                  raidData.survivorIds.push(String(_loc3_[_loc2_]));
                  _loc2_++;
               }
               _loc2_ = 0;
               while(_loc2_ < raidData.survivorIds.length)
               {
                  _loc4_ = raidData.survivorIds[_loc2_];
                  if(_loc4_ != null)
                  {
                     _loc5_ = Network.getInstance().playerData.compound.survivors.getSurvivorById(_loc4_);
                     _loc5_.assignmentId = raidData.id;
                  }
                  _loc2_++;
               }
               Network.getInstance().playerData.assignments.add(raidData);
               missionData = createMissionData(raidData,param1.mission);
               missionData.startMission(onMissionStarted);
               RaidSystem.raidStarted.dispatch(raidData);
               try
               {
                  Tracking.trackEvent("Raid","Started",raidData.name);
               }
               catch(error:Error)
               {
               }
            });
         }
      }
      
      public static function abortRaid(param1:RaidData, param2:Function = null) : void
      {
         var data:Object;
         var busy:BusyDialogue = null;
         var network:Network = null;
         var raidData:RaidData = param1;
         var onComplete:Function = param2;
         busy = new BusyDialogue(Language.getInstance().getString("raid.abandON_ASSIGNMENT"));
         busy.open();
         data = {"id":raidData.id};
         network = Network.getInstance();
         network.save(data,SaveDataMethod.RAID_ABORT,function(param1:Object):void
         {
            var _loc3_:String = null;
            var _loc4_:Survivor = null;
            busy.close();
            if(param1 == null || param1.success !== true)
            {
               DialogueController.getInstance().showGenericRequestError();
               if(onComplete != null)
               {
                  onComplete(false);
               }
               return;
            }
            var _loc2_:int = 0;
            while(_loc2_ < raidData.survivorIds.length)
            {
               _loc3_ = raidData.survivorIds[_loc2_];
               _loc4_ = network.playerData.compound.survivors.getSurvivorById(_loc3_);
               if(_loc4_ != null)
               {
                  _loc4_.assignmentId = null;
                  _loc4_.missionId = null;
               }
               _loc2_++;
            }
            if(param1.cooldown != null)
            {
               network.playerData.cooldowns.parse(Base64.decodeToByteArray(param1.cooldown));
            }
            network.playerData.assignments.remove(raidData);
            network.playerData.checkAndUpdateLoadouts();
            if(onComplete != null)
            {
               onComplete(true);
            }
            RaidSystem.raidEnded.dispatch(raidData);
            try
            {
               Tracking.trackEvent("Raid","Aborted",raidData.name + "_" + raidData.currentStageIndex,raidData.currentStageIndex);
            }
            catch(error:Error)
            {
            }
         });
      }
      
      private static function createMissionData(param1:RaidData, param2:Object) : MissionData
      {
         var _loc6_:Survivor = null;
         var _loc3_:MissionData = new MissionData();
         _loc3_.assignmentId = param1.id;
         _loc3_.assignmentType = AssignmentType.Raid;
         _loc3_.opponent = new UnknownOpponentData(int(param2.level));
         var _loc4_:int = 0;
         while(_loc4_ < param1.survivorIds.length)
         {
            _loc6_ = Network.getInstance().playerData.compound.survivors.getSurvivorById(param1.survivorIds[_loc4_]);
            _loc3_.survivors.push(_loc6_);
            _loc4_++;
         }
         var _loc5_:int = int(param2.stage);
         param1.getRaidStage(_loc5_).setMapAndObjective(int(param2.map),int(param2.obj));
         return _loc3_;
      }
   }
}

