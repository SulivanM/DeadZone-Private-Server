package thelaststand.app.game.gui.quest
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Cubic;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Settings;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.data.bounty.InfectedBounty;
   import thelaststand.app.game.data.bounty.InfectedBountyTask;
   import thelaststand.app.game.data.quests.Quest;
   import thelaststand.app.game.data.raid.RaidData;
   import thelaststand.app.game.logic.QuestSystem;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.network.Network;
   import thelaststand.common.lang.Language;
   
   public class UIQuestTracker extends Sprite
   {
      
      private var _items:Vector.<UIQuestTrackerItem>;
      
      private var _bountyTaskItem:UIQuestTrackerBountyItem;
      
      private var _raidObjTaskItem:UIQuestTrackerRaidObjectiveItem;
      
      private var _width:int;
      
      private var _spacing:int = 6;
      
      private var _expanded:Boolean = true;
      
      private var ui_header:UIQuestTrackerItem;
      
      public var expanded:Signal;
      
      public var collapsed:Signal;
      
      public function UIQuestTracker()
      {
         var _loc1_:int = 0;
         super();
         this._items = new Vector.<UIQuestTrackerItem>();
         this._expanded = Settings.getInstance().getData("trackerExpanded",true);
         mouseChildren = this._expanded;
         mouseEnabled = !this._expanded;
         this.expanded = new Signal();
         this.collapsed = new Signal();
         this.ui_header = new UIQuestTrackerItem(true);
         this.ui_header.addEventListener(MouseEvent.CLICK,this.onClickHeader,false,0,true);
         this.ui_header.icon = new BmpIconQuest();
         this.ui_header.label = "TASKS";
         addChild(this.ui_header);
         this._items.push(this.ui_header);
         this._width = this.ui_header.width;
         for each(_loc1_ in Network.getInstance().playerData.questsTracked)
         {
            this.addItem(QuestSystem.getInstance().getQuestByIndex(_loc1_));
         }
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onClick,false,0,true);
         QuestSystem.getInstance().questStarted.add(this.onQuestStarted);
         QuestSystem.getInstance().questTracked.add(this.onQuestTracked);
         QuestSystem.getInstance().questUntracked.add(this.onQuestUntracked);
         Network.getInstance().playerData.missionStarted.add(this.onMissionStarted);
         Network.getInstance().playerData.missionEnded.add(this.onMissionEnded);
         TooltipManager.getInstance().add(this.ui_header,Language.getInstance().getString("tooltip.task_tracker"),new Point(0,NaN),TooltipDirection.DIRECTION_RIGHT,0.1);
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
         TooltipManager.getInstance().removeAllFromParent(this);
         QuestSystem.getInstance().questStarted.remove(this.onQuestStarted);
         QuestSystem.getInstance().questTracked.remove(this.onQuestTracked);
         QuestSystem.getInstance().questUntracked.remove(this.onQuestUntracked);
         Network.getInstance().playerData.missionStarted.add(this.onMissionStarted);
         Network.getInstance().playerData.missionEnded.add(this.onMissionEnded);
         var _loc1_:int = 0;
         while(_loc1_ < this._items.length)
         {
            this._items[_loc1_].dispose();
            _loc1_++;
         }
      }
      
      private function addItem(param1:Quest) : UIQuestItem
      {
         var _loc2_:UIQuestItem = new UIQuestItem(param1);
         _loc2_.addEventListener(MouseEvent.CLICK,this.onClickQuestItem,false,0,true);
         this._items.push(_loc2_);
         addChild(_loc2_);
         if(stage)
         {
            this.updateItemPositions();
         }
         return _loc2_;
      }
      
      private function removeItem(param1:Quest) : void
      {
         var _loc3_:UIQuestItem = null;
         var _loc2_:int = int(this._items.length - 1);
         while(_loc2_ >= 0)
         {
            _loc3_ = this._items[_loc2_] as UIQuestItem;
            if(_loc3_ != null && _loc3_.quest == param1)
            {
               this._items.splice(_loc2_,1);
               _loc3_.dispose();
               if(stage)
               {
                  this.updateItemPositions();
               }
               break;
            }
            _loc2_--;
         }
      }
      
      private function updateItemPositions(param1:Boolean = false) : void
      {
         var _loc4_:UIQuestTrackerItem = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         while(_loc3_ < this._items.length)
         {
            _loc4_ = this._items[_loc3_];
            if(param1)
            {
               TweenMax.to(_loc4_,0.25,{
                  "y":_loc2_,
                  "ease":Cubic.easeInOut,
                  "overwrite":true
               });
            }
            else
            {
               TweenMax.killTweensOf(_loc4_);
               _loc4_.y = _loc2_;
            }
            _loc2_ += int(_loc4_.height + (_loc4_.expanded ? 0 : this._spacing));
            _loc3_++;
         }
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.updateItemPositions();
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
      }
      
      private function onClickQuestItem(param1:MouseEvent) : void
      {
         var _loc2_:UIQuestTrackerItem = UIQuestTrackerItem(param1.currentTarget);
         _loc2_.toggleState();
         this.updateItemPositions(true);
      }
      
      private function onClickHeader(param1:MouseEvent) : void
      {
         if(this._expanded)
         {
            this._expanded = false;
            mouseChildren = false;
            mouseEnabled = true;
            this.collapsed.dispatch();
            Settings.getInstance().setData("trackerExpanded",this._expanded);
         }
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         if(!this._expanded)
         {
            this._expanded = true;
            mouseChildren = true;
            mouseEnabled = false;
            this.expanded.dispatch();
            Settings.getInstance().setData("trackerExpanded",this._expanded);
         }
      }
      
      private function onQuestTracked(param1:Quest) : void
      {
         this.addItem(param1).toggleState();
      }
      
      private function onQuestUntracked(param1:Quest) : void
      {
         this.removeItem(param1);
      }
      
      private function onQuestStarted(param1:Quest) : void
      {
         if(param1.important && !param1.complete)
         {
            if(!QuestSystem.getInstance().isTracked(param1))
            {
               QuestSystem.getInstance().toggleTracking(param1);
            }
         }
      }
      
      private function onMissionStarted(param1:MissionData) : void
      {
         this.addBountyItem(param1);
         this.addRaidObjectiveItem(param1);
         if(stage)
         {
            this.updateItemPositions();
         }
      }
      
      private function onMissionEnded(param1:MissionData) : void
      {
         this.removeBountyItem(param1);
         this.removeRaidObjectiveItem(param1);
         if(stage)
         {
            this.updateItemPositions();
         }
      }
      
      private function addRaidObjectiveItem(param1:MissionData) : void
      {
         if(!param1.assignmentId)
         {
            return;
         }
         var _loc2_:RaidData = Network.getInstance().playerData.assignments.getById(param1.assignmentId) as RaidData;
         if(_loc2_ == null)
         {
            return;
         }
         this._raidObjTaskItem = new UIQuestTrackerRaidObjectiveItem(_loc2_,param1);
         this._raidObjTaskItem.addEventListener(MouseEvent.CLICK,this.onClickQuestItem,false,0,true);
         this._items.push(this._raidObjTaskItem);
         addChild(this._raidObjTaskItem);
         this._raidObjTaskItem.toggleState();
      }
      
      private function removeRaidObjectiveItem(param1:MissionData) : void
      {
         if(this._raidObjTaskItem == null)
         {
            return;
         }
         var _loc2_:int = int(this._items.indexOf(this._raidObjTaskItem));
         if(_loc2_ > -1)
         {
            this._items.splice(_loc2_,1);
         }
         this._raidObjTaskItem.dispose();
         this._raidObjTaskItem = null;
      }
      
      private function addBountyItem(param1:MissionData) : void
      {
         if(param1.isCompoundAttack() || param1.opponent.isPlayer || param1.automated)
         {
            return;
         }
         var _loc2_:InfectedBounty = Network.getInstance().playerData.infectedBounty;
         if(_loc2_ == null || !_loc2_.isActive)
         {
            return;
         }
         var _loc3_:InfectedBountyTask = _loc2_.getTaskForSuburb(param1.suburb);
         if(_loc3_ == null || _loc3_.isCompleted)
         {
            return;
         }
         this._bountyTaskItem = new UIQuestTrackerBountyItem(_loc3_);
         this._bountyTaskItem.addEventListener(MouseEvent.CLICK,this.onClickQuestItem,false,0,true);
         this._items.push(this._bountyTaskItem);
         addChild(this._bountyTaskItem);
         if(!param1.assignmentId)
         {
            this._bountyTaskItem.toggleState();
         }
      }
      
      private function removeBountyItem(param1:MissionData) : void
      {
         if(this._bountyTaskItem == null)
         {
            return;
         }
         var _loc2_:int = int(this._items.indexOf(this._bountyTaskItem));
         if(_loc2_ > -1)
         {
            this._items.splice(_loc2_,1);
         }
         this._bountyTaskItem.dispose();
         this._bountyTaskItem = null;
      }
      
      public function get isExpanded() : Boolean
      {
         return this._expanded;
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
      }
   }
}

