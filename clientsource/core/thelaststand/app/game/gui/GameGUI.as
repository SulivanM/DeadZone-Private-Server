package thelaststand.app.game.gui
{
   import com.exileetiquette.utils.NumberFormatter;
   import com.greensock.TweenMax;
   import com.greensock.easing.Cubic;
   import com.greensock.easing.Quad;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.geom.Point;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Global;
   import thelaststand.app.data.NavigationLocation;
   import thelaststand.app.events.NavigationEvent;
   import thelaststand.app.game.Game;
   import thelaststand.app.game.Tutorial;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.data.alliance.AllianceTask;
   import thelaststand.app.game.data.bounty.InfectedBounty;
   import thelaststand.app.game.data.bounty.InfectedBountyTask;
   import thelaststand.app.game.data.quests.MiniTask;
   import thelaststand.app.game.data.quests.Quest;
   import thelaststand.app.game.data.research.ResearchTask;
   import thelaststand.app.game.gui.chat.events.ChatGUIEvent;
   import thelaststand.app.game.gui.footer.UIFooter;
   import thelaststand.app.game.gui.header.UIEffectsDisplay;
   import thelaststand.app.game.gui.header.UIHeader;
   import thelaststand.app.game.gui.quest.UIQuestCompletedNotification;
   import thelaststand.app.game.gui.quest.UIQuestMilestoneNotification;
   import thelaststand.app.game.gui.quest.UIQuestTracker;
   import thelaststand.app.game.logic.GlobalQuestSystem;
   import thelaststand.app.game.logic.MiniTaskSystem;
   import thelaststand.app.game.logic.QuestSystem;
   import thelaststand.app.network.Network;
   import thelaststand.common.lang.Language;
   
   public class GameGUI extends Sprite
   {
      
      public const CHAT_LAYER_NAME:String = "chat";
      
      public const SCENE_LAYER_NAME:String = "scene";
      
      public const SECONDARY_UI_LAYER_NAME:String = "secondary";
      
      private var _questNoteQueue:Vector.<UIQuestCompletedNotification>;
      
      private var _questMilestoneQueue:Vector.<UIQuestMilestoneNotification>;
      
      private var _layerContainer:Sprite;
      
      private var _layers:Vector.<IGUILayer>;
      
      private var _width:int;
      
      private var _height:int;
      
      private var _game:Game;
      
      private var ui_header:UIHeader;
      
      private var ui_footer:UIFooter;
      
      private var ui_questTracker:UIQuestTracker;
      
      private var ui_resources:UIResourceListPanel;
      
      private var ui_effects:UIEffectsDisplay;
      
      private var _tutorial:Tutorial;
      
      private var _stage:Stage;
      
      public var messageArea:UIMessageArea;
      
      public var sceneLayer:Sprite;
      
      public var keyPressed:Signal;
      
      public var keyReleased:Signal;
      
      public function GameGUI(param1:Game)
      {
         var _loc2_:EmptyGUILayer = null;
         super();
         mouseEnabled = false;
         tabChildren = false;
         tabEnabled = false;
         this._game = param1;
         this._questNoteQueue = new Vector.<UIQuestCompletedNotification>();
         this._questMilestoneQueue = new Vector.<UIQuestMilestoneNotification>();
         this.keyPressed = new Signal(KeyboardEvent);
         this.keyReleased = new Signal(KeyboardEvent);
         this._layers = new Vector.<IGUILayer>();
         this._layerContainer = new Sprite();
         this._layerContainer.mouseEnabled = false;
         addChild(this._layerContainer);
         this.ui_header = new UIHeader();
         addChild(this.ui_header);
         this.ui_footer = new UIFooter();
         this.ui_footer.minimizedChanged.add(this.onFooterMinimizedChanged);
         addChild(this.ui_footer);
         this.messageArea = new UIMessageArea();
         addChild(this.messageArea);
         this.addLayer(this.SCENE_LAYER_NAME,new EmptyGUILayer());
         this.addLayer(this.CHAT_LAYER_NAME,new EmptyGUILayer());
         _loc2_ = new EmptyGUILayer();
         this.addLayer(this.SECONDARY_UI_LAYER_NAME,_loc2_);
         this.ui_questTracker = new UIQuestTracker();
         this.ui_questTracker.expanded.add(this.onQuestTrackerStateChanged);
         this.ui_questTracker.collapsed.add(this.onQuestTrackerStateChanged);
         this.ui_resources = new UIResourceListPanel();
         this.ui_resources.visible = false;
         this.ui_resources.transitionOut();
         _loc2_.addChild(this.ui_resources);
         this.ui_effects = new UIEffectsDisplay(this._game);
         _loc2_.addChild(this.ui_effects);
         this._tutorial = Tutorial.getInstance();
         if(!this._tutorial.active)
         {
            _loc2_.addChild(this.ui_questTracker);
         }
         else
         {
            this._tutorial.completed.addOnce(this.onTutorialCompleted);
            this._tutorial.stepChanged.add(this.onTutorialStepChanged);
         }
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
         QuestSystem.getInstance().questCompleted.add(this.onQuestCompletedOrFailed);
         QuestSystem.getInstance().questFailed.add(this.onQuestCompletedOrFailed);
         QuestSystem.getInstance().achievementReceived.add(this.onQuestCompletedOrFailed);
         QuestSystem.getInstance().milestoneReached.add(this.onQuestMilestoneReached);
         GlobalQuestSystem.getInstance().questCompleted.add(this.onQuestCompletedOrFailed);
         MiniTaskSystem.getInstance().achievementCompleted.add(this.onRepeatAchievementCompleted);
         AllianceSystem.getInstance().connected.add(this.onAllianceSystemConnected);
         AllianceSystem.getInstance().disconnected.add(this.onAllianceSystemDisconnected);
         Network.getInstance().playerData.researchState.researchCompleted.add(this.onResearchCompleted);
         Network.getInstance().playerData.infectedBountyReceived.add(this.onInfectedBountyReceived);
         var _loc3_:InfectedBounty = Network.getInstance().playerData.infectedBounty;
         if(_loc3_ != null)
         {
            this.onInfectedBountyReceived(_loc3_);
         }
         if(AllianceSystem.getInstance().isConnected)
         {
            this.onAllianceSystemConnected();
         }
      }
      
      public function dispose() : void
      {
         var _loc1_:IGUILayer = null;
         var _loc2_:InfectedBounty = null;
         if(parent)
         {
            parent.removeChild(this);
         }
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
         for each(_loc1_ in this._layers)
         {
            if(Sprite(_loc1_).parent != null)
            {
               Sprite(_loc1_).parent.removeChild(_loc1_ as Sprite);
            }
         }
         this.keyPressed.removeAll();
         this.keyReleased.removeAll();
         _loc2_ = Network.getInstance().playerData.infectedBounty;
         if(_loc2_ != null)
         {
            _loc2_.completed.remove(this.onInfectedBountyCompleted);
            _loc2_.taskCompleted.remove(this.onInfectedBountyTaskReceived);
         }
         Network.getInstance().playerData.infectedBountyReceived.remove(this.onInfectedBountyReceived);
         Network.getInstance().playerData.researchState.researchCompleted.remove(this.onResearchCompleted);
         QuestSystem.getInstance().questCompleted.remove(this.onQuestCompletedOrFailed);
         QuestSystem.getInstance().questFailed.remove(this.onQuestCompletedOrFailed);
         QuestSystem.getInstance().achievementReceived.remove(this.onQuestCompletedOrFailed);
         QuestSystem.getInstance().milestoneReached.remove(this.onQuestMilestoneReached);
         GlobalQuestSystem.getInstance().questCompleted.remove(this.onQuestCompletedOrFailed);
         MiniTaskSystem.getInstance().achievementCompleted.remove(this.onRepeatAchievementCompleted);
         AllianceSystem.getInstance().connected.remove(this.onAllianceSystemConnected);
         AllianceSystem.getInstance().disconnected.remove(this.onAllianceSystemDisconnected);
         this.ui_resources.dispose();
         this.ui_effects.dispose();
         this.ui_footer.dispose();
         this.ui_header.dispose();
         this._tutorial.completed.remove(this.onTutorialCompleted);
         this._tutorial.stepChanged.remove(this.onTutorialStepChanged);
         this._tutorial = null;
         this._game = null;
      }
      
      public function addLayer(param1:String, param2:IGUILayer, param3:int = -1) : IGUILayer
      {
         var _loc4_:int = int(this._layers.indexOf(param2));
         if(_loc4_ > -1)
         {
            this._layers.splice(_loc4_,1);
         }
         param2.name = param1;
         if(param3 == -1)
         {
            this._layers.push(param2);
            if(param2 is Sprite)
            {
               this._layerContainer.addChild(param2 as Sprite);
            }
         }
         else
         {
            this._layers.splice(param3,0,param2);
            if(param2 is Sprite)
            {
               this._layerContainer.addChildAt(param2 as Sprite,param3);
            }
         }
         param2.gui = this;
         if(stage != null)
         {
            this.onStageResize(null);
         }
         return param2;
      }
      
      public function getLayer(param1:String) : IGUILayer
      {
         var _loc2_:IGUILayer = null;
         for each(_loc2_ in this._layers)
         {
            if(_loc2_.name == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function getLayerAsSprite(param1:String) : Sprite
      {
         return this.getLayer(param1) as Sprite;
      }
      
      public function getLayerIndex(param1:IGUILayer) : int
      {
         return this._layers.indexOf(param1);
      }
      
      public function getLayerIndexByName(param1:String) : int
      {
         return this._layers.indexOf(this.getLayer(param1));
      }
      
      public function clearLayer(param1:IGUILayer, param2:Boolean = false) : void
      {
         var _loc4_:DisplayObject = null;
         var _loc3_:int = Sprite(param1).numChildren - 1;
         while(_loc3_ >= 0)
         {
            _loc4_ = Sprite(param1).getChildAt(_loc3_);
            if(param2)
            {
               try
               {
                  _loc4_["dispose"]();
               }
               catch(e:Error)
               {
               }
            }
            if(_loc4_.parent != null)
            {
               _loc4_.parent.removeChild(_loc4_);
            }
            _loc3_--;
         }
      }
      
      public function removeLayer(param1:IGUILayer, param2:Boolean = false, param3:Function = null) : IGUILayer
      {
         var layer:IGUILayer = param1;
         var transitionOut:Boolean = param2;
         var callback:Function = param3;
         if(this._layers.indexOf(layer) <= -1)
         {
            return layer;
         }
         if(!transitionOut || layer.transitionedOut == null)
         {
            this.doRemoveLayer(layer);
         }
         else
         {
            layer.transitionedOut.addOnce(function(param1:IGUILayer):void
            {
               if(callback != null)
               {
                  callback.apply();
               }
               doRemoveLayer(param1);
            });
            layer.transitionOut();
         }
         return layer;
      }
      
      public function removeLayerByName(param1:String, param2:Boolean = false, param3:Function = null) : IGUILayer
      {
         var _loc5_:IGUILayer = null;
         var _loc4_:int = 0;
         while(_loc4_ < this._layers.length)
         {
            _loc5_ = this._layers[_loc4_];
            if(_loc5_.name == param1)
            {
               this.removeLayer(_loc5_,param2,param3);
               break;
            }
            _loc4_++;
         }
         return _loc5_;
      }
      
      public function transitionIn(param1:Number = 0, param2:Function = null) : void
      {
         this.onStageResize(null);
         TweenMax.from(this.ui_header,0.25,{
            "delay":param1,
            "y":-this.ui_header.height - 10,
            "ease":Cubic.easeOut
         });
         TweenMax.from(this.ui_footer,0.25,{
            "delay":param1,
            "y":stage.stageHeight + this.ui_footer.height + 10,
            "ease":Cubic.easeOut,
            "onComplete":param2
         });
      }
      
      private function doRemoveLayer(param1:IGUILayer) : void
      {
         var _loc2_:int = int(this._layers.indexOf(param1));
         if(_loc2_ == -1)
         {
            return;
         }
         this._layers.splice(_loc2_,1);
         if(param1.gui == this)
         {
            param1.gui = null;
         }
         if(param1 is Sprite && Sprite(param1).parent != null)
         {
            this._layerContainer.removeChild(param1 as Sprite);
         }
      }
      
      private function addQuestCompletedNote(param1:UIQuestCompletedNotification) : void
      {
         var note:UIQuestCompletedNotification = param1;
         note.x = int((this._width - note.width) * 0.5);
         note.y = int(this.ui_header.height + 50);
         note.completed.addOnce(function():void
         {
            _questNoteQueue.shift();
            if(_questNoteQueue.length > 0)
            {
               _questNoteQueue[0].transitionIn();
               addChild(_questNoteQueue[0]);
            }
         });
         this._questNoteQueue.push(note);
         if(this._questNoteQueue.length == 1)
         {
            note.transitionIn();
            addChild(note);
         }
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this._stage = stage;
         stage.addEventListener(Event.RESIZE,this.onStageResize,false,0,true);
         stage.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown,false,0,true);
         stage.addEventListener(KeyboardEvent.KEY_UP,this.onKeyUp,false,0,true);
         stage.addEventListener(ChatGUIEvent.UNDOCKED,this.onChatUndocked,false,0,true);
         stage.addEventListener(NavigationEvent.START,this.onNavigationEventStart,false,0,true);
         this.onStageResize(null);
         if(Global.softwareRendering)
         {
         }
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         this._stage.removeEventListener(Event.RESIZE,this.onStageResize);
         this._stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown);
         this._stage.removeEventListener(KeyboardEvent.KEY_UP,this.onKeyUp);
         this._stage.removeEventListener(ChatGUIEvent.UNDOCKED,this.onChatUndocked);
         this._stage.removeEventListener(NavigationEvent.START,this.onNavigationEventStart);
      }
      
      private function onStageResize(param1:Event) : void
      {
         var _loc2_:IGUILayer = null;
         var _loc3_:UIQuestCompletedNotification = null;
         var _loc4_:UIQuestMilestoneNotification = null;
         var _loc5_:Sprite = null;
         this._width = Math.max(stage.stageWidth,760);
         this._height = stage.stageHeight;
         this.ui_header.width = this._width;
         this.ui_header.x = int((this._width - this.ui_header.width) * 0.5);
         this.ui_header.y = 0;
         this.ui_footer.width = this._width;
         this.ui_footer.x = int((this._width - this.ui_footer.width) * 0.5);
         this.ui_footer.y = int(this._height - (this.ui_footer.minimized ? this.ui_footer.minimizedHeight : this.ui_footer.height));
         this.ui_questTracker.x = this.ui_questTracker.isExpanded ? int(this._width - this.ui_questTracker.width - 18) : int(this._width - 25);
         this.ui_questTracker.y = int(this.ui_header.y + this.ui_header.height + 18);
         this.messageArea.x = int(this._width * 0.5);
         this.messageArea.y = int(this.ui_footer.y - 134);
         this.ui_resources.x = 30;
         this.ui_resources.y = 36 + this.ui_header.height;
         this.ui_effects.x = int(this.ui_header.x + this.ui_header.playerXPDisplay.x + 48);
         this.ui_effects.y = int(this.ui_header.y + this.ui_header.playerXPDisplay.y + 38);
         for each(_loc2_ in this._layers)
         {
            _loc5_ = _loc2_ as Sprite;
            if(_loc2_.useFullWindow)
            {
               _loc5_.y = 0;
               _loc2_.setSize(this._width,this._height);
            }
            else
            {
               _loc5_.y = this.ui_header.y + this.ui_header.height;
               _loc2_.setSize(this._width,this.ui_footer.y - _loc5_.y);
            }
         }
         for each(_loc3_ in this._questNoteQueue)
         {
            _loc3_.x = int((this._width - _loc3_.width) * 0.5);
            _loc3_.y = int(this.ui_header.height + 50);
         }
         for each(_loc4_ in this._questMilestoneQueue)
         {
            _loc4_.x = int(this._width - _loc4_.width);
            _loc4_.y = int(this.ui_footer.y - _loc4_.height - 110);
         }
      }
      
      private function onFooterMinimizedChanged(param1:Boolean) : void
      {
         var state:Boolean = param1;
         var ty:int = int(this._height - (this.ui_footer.minimized ? this.ui_footer.minimizedHeight : this.ui_footer.height));
         TweenMax.to(this.ui_footer,0.25,{
            "y":ty,
            "ease":Quad.easeInOut,
            "onUpdate":function():void
            {
               var _loc1_:* = undefined;
               var _loc2_:* = undefined;
               messageArea.y = int(ui_footer.y - 120);
               for each(_loc1_ in _layers)
               {
                  _loc2_ = _loc1_ as Sprite;
                  if(!_loc1_.useFullWindow)
                  {
                     _loc2_.y = ui_header.y + ui_header.height;
                     _loc1_.setSize(_width,ui_footer.y - _loc2_.y);
                  }
               }
            },
            "onComplete":function():void
            {
               if(ui_footer.minimized)
               {
                  ui_footer.hidePanels();
               }
               else
               {
                  ui_footer.showPanels();
               }
               onStageResize(null);
            }
         });
      }
      
      private function onKeyDown(param1:KeyboardEvent) : void
      {
         this.keyPressed.dispatch(param1);
      }
      
      private function onKeyUp(param1:KeyboardEvent) : void
      {
         this.keyReleased.dispatch(param1);
      }
      
      private function onQuestTrackerStateChanged() : void
      {
         var _loc1_:int = 0;
         if(this.ui_questTracker.isExpanded)
         {
            _loc1_ = int(this._width - this.ui_questTracker.width - 18);
         }
         else
         {
            _loc1_ = int(this._width - 25);
         }
         if(stage != null)
         {
            TweenMax.to(this.ui_questTracker,0.25,{
               "x":_loc1_,
               "overwrite":true,
               "ease":Cubic.easeInOut
            });
         }
         else
         {
            TweenMax.killTweensOf(this.ui_questTracker);
            this.ui_questTracker.x = _loc1_;
         }
      }
      
      private function onQuestCompletedOrFailed(param1:Quest) : void
      {
         if(param1 == null)
         {
            return;
         }
         if(param1.important && this._game.location == NavigationLocation.PLAYER_COMPOUND && !param1.failed && !param1.isAchievement)
         {
            return;
         }
         this.addQuestCompletedNote(UIQuestCompletedNotification.fromQuest(param1));
      }
      
      private function onRepeatAchievementCompleted(param1:MiniTask, param2:Number, param3:int) : void
      {
         if(param1.isPercentage)
         {
            param2 = int(param2 * 100);
         }
         this.addQuestCompletedNote(new UIQuestCompletedNotification(UIQuestCompletedNotification.COLOR_REPEAT_ACHIEVEMENT,new BmpIconMiniTask(),Language.getInstance().getString("ach_" + param1.id + "_desc",NumberFormatter.format(param2,0)),Language.getInstance().getString("ach_" + param1.id),param3,"sound/interface/int-complete-minitask.mp3"));
      }
      
      private function onQuestMilestoneReached(param1:Quest, param2:int) : void
      {
         var milestone:UIQuestMilestoneNotification;
         var quest:Quest = param1;
         var conditionIndex:int = param2;
         if(quest == null || !quest.isAchievement)
         {
            return;
         }
         milestone = new UIQuestMilestoneNotification(quest,conditionIndex);
         milestone.x = int(this._width - milestone.width);
         milestone.y = int(this.ui_footer.y - milestone.height - 110);
         milestone.completed.addOnce(function():void
         {
            _questMilestoneQueue.shift();
            if(_questMilestoneQueue.length > 0)
            {
               _questMilestoneQueue[0].transitionIn();
               addChild(_questMilestoneQueue[0]);
            }
         });
         this._questMilestoneQueue.push(milestone);
         if(this._questMilestoneQueue.length == 1)
         {
            milestone.transitionIn();
            addChild(milestone);
         }
      }
      
      private function onAllianceSystemConnected() : void
      {
         AllianceSystem.getInstance().alliance.taskCompleted.add(this.onAllianceTaskCompleted);
      }
      
      private function onAllianceSystemDisconnected() : void
      {
         AllianceSystem.getInstance().alliance.taskCompleted.remove(this.onAllianceTaskCompleted);
      }
      
      private function onAllianceTaskCompleted(param1:AllianceTask) : void
      {
         this.addQuestCompletedNote(new UIQuestCompletedNotification(UIQuestCompletedNotification.COLOR_ALLIANCE_TASK,Quest.getIcon(param1.iconType),param1.getGoalDescription(),"ALLIANCE TASK: " + param1.getName(),0,"sound/interface/int-complete-minitask.mp3"));
      }
      
      private function onTutorialCompleted() : void
      {
         this.getLayerAsSprite(this.SECONDARY_UI_LAYER_NAME).addChild(this.ui_questTracker);
         this.ui_questTracker.x = int(this._width - this.ui_questTracker.width - 18);
         TweenMax.from(this.ui_questTracker,0.25,{
            "delay":0.1,
            "x":int(this._width - 25),
            "ease":Cubic.easeOut
         });
      }
      
      private function onChatUndocked(param1:ChatGUIEvent) : void
      {
         addChild(Sprite(param1.data));
      }
      
      private function onTutorialStepChanged() : void
      {
         switch(this._tutorial.step)
         {
            case Tutorial.STEP_RESOURCES:
               this._tutorial.addArrow(this.ui_resources.tutorialArrowTargetObject,180,new Point(this.ui_resources.tutorialArrowTargetObject.width + 10));
               this.ui_resources.visible = true;
               this.ui_resources.transitionIn(0.05);
               break;
            case Tutorial.STEP_END_TUTORIAL:
               this.ui_resources.visible = true;
         }
         if(this._tutorial.stepNum >= this._tutorial.getStepNum(Tutorial.STEP_RESOURCES) && !this.ui_resources.visible)
         {
            this.ui_resources.transitionIn(0.05);
         }
      }
      
      private function onNavigationEventStart(param1:NavigationEvent) : void
      {
         switch(param1.location)
         {
            case NavigationLocation.WORLD_MAP:
            case NavigationLocation.PLAYER_COMPOUND:
               if(!this._tutorial.active || this._tutorial.stepNum >= this._tutorial.getStepNum(Tutorial.STEP_RESOURCES))
               {
                  this.ui_resources.transitionIn(0.05);
               }
               this.ui_effects.transitionIn(0.05);
               break;
            case NavigationLocation.MISSION:
            case NavigationLocation.MISSION_PLANNING:
               this.ui_resources.transitionOut();
               this.ui_effects.transitionIn(0.05);
               break;
            default:
               this.ui_resources.transitionOut();
               this.ui_effects.transitionOut();
         }
      }
      
      private function onResearchCompleted(param1:ResearchTask) : void
      {
         if(param1 == null)
         {
            return;
         }
         this.addQuestCompletedNote(UIQuestCompletedNotification.fromResearchTask(param1));
      }
      
      private function onInfectedBountyReceived(param1:InfectedBounty) : void
      {
         if(param1 != null)
         {
            param1.completed.addOnce(this.onInfectedBountyCompleted);
            param1.taskCompleted.add(this.onInfectedBountyTaskReceived);
         }
      }
      
      private function onInfectedBountyCompleted(param1:InfectedBounty) : void
      {
         this.addQuestCompletedNote(UIQuestCompletedNotification.fromInfectedBounty(param1));
      }
      
      private function onInfectedBountyTaskReceived(param1:InfectedBounty, param2:InfectedBountyTask) : void
      {
         this.addQuestCompletedNote(UIQuestCompletedNotification.fromInfectedBountyTask(param2));
      }
      
      public function get footer() : UIFooter
      {
         return this.ui_footer;
      }
      
      public function get header() : UIHeader
      {
         return this.ui_header;
      }
      
      public function get resouces() : UIResourceListPanel
      {
         return this.ui_resources;
      }
   }
}

