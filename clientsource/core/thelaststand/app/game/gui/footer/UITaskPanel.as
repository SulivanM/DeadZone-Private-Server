package thelaststand.app.game.gui.footer
{
   import com.greensock.TweenMax;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.AntiAliasType;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.Tutorial;
   import thelaststand.app.game.data.BatchRecycleJob;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.data.Task;
   import thelaststand.app.game.data.TaskCollection;
   import thelaststand.app.game.data.TimerData;
   import thelaststand.app.game.data.arena.ArenaSession;
   import thelaststand.app.game.data.arena.ArenaSystem;
   import thelaststand.app.game.data.assignment.AssignmentCollection;
   import thelaststand.app.game.data.raid.RaidData;
   import thelaststand.app.game.data.raid.RaidSystem;
   import thelaststand.app.game.data.research.ResearchTask;
   import thelaststand.app.game.gui.UIScrollBar;
   import thelaststand.app.game.gui.task.UIAssignmentTaskItem;
   import thelaststand.app.game.gui.task.UIBuildingTaskItem;
   import thelaststand.app.game.gui.task.UIMissionTaskItem;
   import thelaststand.app.game.gui.task.UIRecycleJobTaskItem;
   import thelaststand.app.game.gui.task.UIRepairTaskItem;
   import thelaststand.app.game.gui.task.UIResearchTaskItem;
   import thelaststand.app.game.gui.task.UITaskItem;
   import thelaststand.app.game.gui.task.UITaskTaskItem;
   import thelaststand.app.game.logic.TimerManager;
   import thelaststand.app.network.Network;
   import thelaststand.common.lang.Language;
   
   public class UITaskPanel extends Sprite
   {
      
      private var _items:Vector.<UITaskItem>;
      
      private var _enabled:Boolean = true;
      
      private var _padding:int = 10;
      
      private var _spacing:int = 2;
      
      private var _width:int = 448;
      
      private var _height:int = 200;
      
      private var _scrollOffset:Number = 0;
      
      private var _tutorial:Tutorial;
      
      private var mc_items:Sprite;
      
      private var mc_mask:Sprite;
      
      private var ui_scroll:UIScrollBar;
      
      private var txt_status:BodyTextField;
      
      public function UITaskPanel()
      {
         super();
         graphics.beginFill(5130824);
         graphics.drawRect(0,0,this._width,this._height);
         graphics.endFill();
         graphics.beginFill(3552051);
         graphics.drawRect(1,1,this._width - 2,this._height - 2);
         graphics.endFill();
         graphics.beginFill(0);
         graphics.drawRect(this._padding,this._padding,this._width - this._padding * 2,this._height - this._padding * 2);
         graphics.endFill();
         this.mc_items = new Sprite();
         this.mc_items.x = this._padding + 6;
         this.mc_items.y = this._padding + 6;
         addChild(this.mc_items);
         this.mc_mask = new Sprite();
         this.mc_mask.graphics.beginFill(16711680);
         this.mc_mask.graphics.drawRect(0,0,this._width - this._padding * 2 - 12,this._height - this._padding * 2 - 12);
         this.mc_mask.graphics.endFill();
         this.mc_mask.x = this.mc_items.x;
         this.mc_mask.y = this.mc_items.y;
         this.mc_items.mask = this.mc_mask;
         addChild(this.mc_mask);
         this.ui_scroll = new UIScrollBar();
         this.ui_scroll.x = this._width - this._padding - this.ui_scroll.width - 8;
         this.ui_scroll.y = this._padding + 4;
         this.ui_scroll.height = int(this._height - this._padding * 2 - 12);
         this.ui_scroll.contentHeight = this.mc_items.height;
         this.ui_scroll.changed.add(this.onScrollbarChanged);
         addChild(this.ui_scroll);
         this.txt_status = new BodyTextField({
            "text":" ",
            "color":Effects.COLOR_GREY,
            "size":14,
            "bold":true,
            "antiAliasType":AntiAliasType.ADVANCED,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_status.x = this.txt_status.y = this._padding + 4;
         addChild(this.txt_status);
         this._items = new Vector.<UITaskItem>();
         this._tutorial = Tutorial.getInstance();
         this._tutorial.stepChanged.add(this.onTutorialStepChanged);
         TimerManager.getInstance().timerStarted.add(this.onTimerStarted);
         TimerManager.getInstance().timerCancelled.add(this.onTimerEnded);
         TimerManager.getInstance().timerCompleted.add(this.onTimerEnded);
         var _loc1_:PlayerData = Network.getInstance().playerData;
         _loc1_.compound.tasks.taskAdded.add(this.onTaskStarted);
         _loc1_.compound.tasks.taskRemoved.add(this.onTaskEnded);
         _loc1_.researchState.researchStarted.add(this.onResearchStarted);
         _loc1_.researchState.researchCompleted.add(this.onResearchCompleted);
         RaidSystem.raidStarted.add(this.onRaidStarted);
         RaidSystem.raidEnded.add(this.onRaidCompleted);
         ArenaSystem.sessionStarted.add(this.onArenaStarted);
         ArenaSystem.sessionEnded.add(this.onArenaCompleted);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
         addEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheel,false,0,true);
      }
      
      public function dispose() : void
      {
         var _loc2_:UITaskItem = null;
         if(parent != null)
         {
            parent.removeChild(this);
         }
         TimerManager.getInstance().timerStarted.remove(this.onTimerStarted);
         TimerManager.getInstance().timerCancelled.remove(this.onTimerEnded);
         TimerManager.getInstance().timerCompleted.remove(this.onTimerEnded);
         RaidSystem.raidStarted.remove(this.onRaidStarted);
         RaidSystem.raidEnded.remove(this.onRaidCompleted);
         ArenaSystem.sessionStarted.remove(this.onArenaStarted);
         ArenaSystem.sessionEnded.remove(this.onArenaCompleted);
         var _loc1_:PlayerData = Network.getInstance().playerData;
         _loc1_.compound.tasks.taskAdded.remove(this.onTaskStarted);
         _loc1_.compound.tasks.taskRemoved.remove(this.onTaskEnded);
         _loc1_.researchState.researchStarted.remove(this.onResearchStarted);
         _loc1_.researchState.researchCompleted.remove(this.onResearchCompleted);
         this._tutorial.stepChanged.remove(this.onTutorialStepChanged);
         this._tutorial = null;
         this.txt_status.dispose();
         this.txt_status = null;
         for each(_loc2_ in this._items)
         {
            _loc2_.dispose();
         }
         this._items = null;
      }
      
      private function getItemByTarget(param1:*) : UITaskItem
      {
         var _loc2_:UITaskItem = null;
         for each(_loc2_ in this._items)
         {
            if(_loc2_.target == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      private function addItem(param1:UITaskItem) : void
      {
         if(this._items.indexOf(param1) > -1 || this.getItemByTarget(param1.target) != null)
         {
            return;
         }
         this._items.push(param1);
         this.mc_items.addChild(param1);
         param1.update();
         param1.enabled = this._enabled;
      }
      
      private function removeItem(param1:UITaskItem) : void
      {
         var _loc2_:int = int(this._items.indexOf(param1));
         if(_loc2_ == -1)
         {
            return;
         }
         this._items.splice(_loc2_,1);
         param1.dispose();
      }
      
      private function updateStatus() : void
      {
         if(this._items.length == 0)
         {
            this.txt_status.text = Language.getInstance().getString("tasks_none");
            addChild(this.txt_status);
         }
         else if(this.txt_status.parent != null)
         {
            this.txt_status.parent.removeChild(this.txt_status);
         }
      }
      
      private function sortItems() : void
      {
         var ty:int;
         var i:int;
         var item:UITaskItem = null;
         this._items.sort(function(param1:UITaskItem, param2:UITaskItem):int
         {
            var _loc3_:int = param2.priority - param1.priority;
            if(_loc3_ != 0)
            {
               return _loc3_;
            }
            return param1.label.localeCompare(param2.label);
         });
         ty = 0;
         i = 0;
         while(i < this._items.length)
         {
            item = this._items[i];
            item.y = ty;
            ty += item.height + this._spacing;
            i++;
         }
         this.ui_scroll.contentHeight = this.mc_items.height;
         if(this.mc_items.height <= this.mc_mask.height)
         {
            TweenMax.to(this.mc_items,0.25,{
               "y":this.mc_mask.y,
               "overwrite":true
            });
         }
      }
      
      private function scroll(param1:int) : void
      {
         var _loc2_:int = param1 * (32 + this._spacing);
         this._scrollOffset += _loc2_;
         this._scrollOffset -= this._scrollOffset % _loc2_;
         var _loc3_:int = this.mc_mask.y + this._scrollOffset;
         var _loc4_:int = this.mc_mask.y - (this.mc_items.height - this.mc_mask.height);
         if(_loc3_ < _loc4_)
         {
            _loc3_ = _loc4_;
            this._scrollOffset = -(this.mc_items.height - this.mc_mask.height);
         }
         if(_loc3_ > this.mc_mask.y)
         {
            _loc3_ = this.mc_mask.y;
            this._scrollOffset = 0;
         }
         this.ui_scroll.value = (this.mc_mask.y - _loc3_) / (this.mc_items.height - this.mc_mask.height);
         TweenMax.to(this.mc_items,0.25,{
            "y":_loc3_,
            "overwrite":true
         });
      }
      
      private function addTutorialArrowToMissionTask() : void
      {
         if(!Tutorial.getInstance().active || Tutorial.getInstance().step != Tutorial.STEP_RETURN_SPEED_UP)
         {
            return;
         }
         var _loc1_:MissionData = Tutorial.getInstance().getState(Tutorial.STATE_MISSION_COMPLETE) as MissionData;
         if(_loc1_ == null)
         {
            return;
         }
         var _loc2_:UIMissionTaskItem = this.getItemByTarget(_loc1_) as UIMissionTaskItem;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:Sprite = _loc2_.getChildByName("btn_speedUp") as Sprite;
         Tutorial.getInstance().addArrow(_loc3_,90,new Point(_loc3_.width * 0.5));
      }
      
      private function onScrollbarChanged(param1:Number) : void
      {
         TweenMax.killTweensOf(this.mc_items);
         this._scrollOffset = -(this.mc_items.height - this.mc_mask.height) * param1;
         this._scrollOffset -= this._scrollOffset % (32 + this._spacing);
         var _loc2_:int = this.mc_mask.y + this._scrollOffset;
         var _loc3_:int = this.mc_mask.y - (this.mc_items.height - this.mc_mask.height);
         if(_loc2_ < _loc3_)
         {
            _loc2_ = _loc3_;
            this._scrollOffset = -(this.mc_items.height - this.mc_mask.height);
         }
         if(_loc2_ > this.mc_mask.y)
         {
            _loc2_ = this.mc_mask.y;
            this._scrollOffset = 0;
         }
         TweenMax.to(this.mc_items,0.25,{
            "y":_loc2_,
            "overwrite":true
         });
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         addEventListener(Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
         var _loc4_:AssignmentCollection = Network.getInstance().playerData.assignments;
         _loc2_ = 0;
         while(_loc2_ < _loc4_.length)
         {
            this.addItem(new UIAssignmentTaskItem(_loc4_.getAt(_loc2_)));
            _loc2_++;
         }
         var _loc5_:TimerManager = TimerManager.getInstance();
         _loc2_ = 0;
         _loc3_ = _loc5_.numTimers;
         while(_loc2_ < _loc3_)
         {
            this.onTimerStarted(_loc5_.getTimer(_loc2_));
            _loc2_++;
         }
         var _loc6_:TaskCollection = Network.getInstance().playerData.compound.tasks;
         _loc2_ = 0;
         _loc3_ = _loc6_.length;
         while(_loc2_ < _loc3_)
         {
            this.onTaskStarted(_loc6_.getTask(_loc2_));
            _loc2_++;
         }
         var _loc7_:Vector.<ResearchTask> = Network.getInstance().playerData.researchState.tasks;
         _loc2_ = 0;
         while(_loc2_ < _loc7_.length)
         {
            this.addItem(new UIResearchTaskItem(_loc7_[_loc2_]));
            _loc2_++;
         }
         this.sortItems();
         this.updateStatus();
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         var _loc2_:UITaskItem = null;
         for each(_loc2_ in this._items)
         {
            _loc2_.update();
         }
      }
      
      private function onMouseWheel(param1:MouseEvent) : void
      {
         this.scroll(param1.delta < 0 ? -1 : 1);
         param1.stopPropagation();
      }
      
      private function onRaidStarted(param1:RaidData) : void
      {
         this.addItem(new UIAssignmentTaskItem(param1));
         this.sortItems();
         this.updateStatus();
      }
      
      private function onRaidCompleted(param1:RaidData) : void
      {
         var _loc2_:UITaskItem = this.getItemByTarget(param1);
         if(_loc2_ == null)
         {
            return;
         }
         this.removeItem(_loc2_);
         this.sortItems();
         this.updateStatus();
      }
      
      private function onArenaStarted(param1:ArenaSession) : void
      {
         this.addItem(new UIAssignmentTaskItem(param1));
         this.sortItems();
         this.updateStatus();
      }
      
      private function onArenaCompleted(param1:ArenaSession) : void
      {
         var _loc2_:UITaskItem = this.getItemByTarget(param1);
         if(_loc2_ == null)
         {
            return;
         }
         this.removeItem(_loc2_);
         this.sortItems();
         this.updateStatus();
      }
      
      private function onResearchStarted(param1:ResearchTask) : void
      {
         this.addItem(new UIResearchTaskItem(param1));
         this.sortItems();
         this.updateStatus();
      }
      
      private function onResearchCompleted(param1:ResearchTask) : void
      {
         var _loc2_:UITaskItem = this.getItemByTarget(param1);
         if(_loc2_ == null)
         {
            return;
         }
         this.removeItem(_loc2_);
         this.sortItems();
         this.updateStatus();
      }
      
      private function onTimerStarted(param1:TimerData) : void
      {
         var _loc5_:UIMissionTaskItem = null;
         var _loc6_:UIRecycleJobTaskItem = null;
         var _loc2_:Building = param1.target as Building;
         if(_loc2_ != null)
         {
            if(Network.getInstance().playerData.compound.buildings.containsBuilding(_loc2_))
            {
               if(param1.data.type == "repair")
               {
                  this.addItem(new UIRepairTaskItem(_loc2_));
               }
               else
               {
                  this.addItem(new UIBuildingTaskItem(_loc2_));
               }
               this.sortItems();
               this.updateStatus();
            }
            return;
         }
         var _loc3_:MissionData = param1.target as MissionData;
         if(_loc3_ != null && _loc3_.returnTimer != null && param1.data.type == "return")
         {
            _loc5_ = new UIMissionTaskItem(_loc3_);
            this.addItem(_loc5_);
            this.sortItems();
            this.updateStatus();
            return;
         }
         var _loc4_:BatchRecycleJob = param1.target as BatchRecycleJob;
         if(_loc4_ != null && _loc4_.timer != null)
         {
            _loc6_ = new UIRecycleJobTaskItem(_loc4_);
            this.addItem(_loc6_);
            this.sortItems();
            this.updateStatus();
            return;
         }
      }
      
      private function onTimerEnded(param1:TimerData) : void
      {
         var _loc2_:UITaskItem = this.getItemByTarget(param1.target);
         if(_loc2_ == null)
         {
            return;
         }
         if(param1.target as MissionData)
         {
            if(param1.data.type != "return")
            {
               return;
            }
         }
         this.removeItem(_loc2_);
         this.sortItems();
         this.updateStatus();
      }
      
      private function onTaskStarted(param1:Task) : void
      {
         if(param1 == null || param1.complete)
         {
            return;
         }
         if(Network.getInstance().playerData.compound.tasks.containsTask(param1))
         {
            this.addItem(new UITaskTaskItem(param1));
            this.sortItems();
            this.updateStatus();
         }
      }
      
      private function onTaskEnded(param1:Task) : void
      {
         var _loc2_:UITaskItem = this.getItemByTarget(param1);
         if(_loc2_ != null)
         {
            this.removeItem(_loc2_);
            this.sortItems();
            this.updateStatus();
         }
      }
      
      private function onTutorialStepChanged() : void
      {
         if(this._tutorial.step == Tutorial.STEP_RETURN_SPEED_UP)
         {
            this.addTutorialArrowToMissionTask();
         }
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         var _loc2_:UITaskItem = null;
         this._enabled = param1;
         mouseChildren = this._enabled;
         for each(_loc2_ in this._items)
         {
            _loc2_.enabled = this._enabled;
         }
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
   }
}

