package thelaststand.app.game.gui.mission
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Back;
   import com.greensock.easing.Cubic;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.getTimer;
   import org.osflash.signals.Signal;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.RushVignette;
   import thelaststand.app.game.Tutorial;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.gui.GameGUI;
   import thelaststand.app.game.gui.IGUILayer;
   import thelaststand.app.game.gui.UIHUDPanel;
   import thelaststand.app.game.gui.buttons.UIHUDButton;
   import thelaststand.app.game.gui.buttons.UIHelpButton;
   import thelaststand.app.game.gui.dialogues.PvPHelpDialogue;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.common.lang.Language;
   
   public class MissionGUILayer extends Sprite implements IGUILayer
   {
      
      private var _gui:GameGUI;
      
      private var _width:int;
      
      private var _height:int;
      
      private var _transitionedOut:Signal;
      
      private var _lootItems:Vector.<UILootItem>;
      
      private var _leaveConfirmOpened:Boolean;
      
      private var _tutorial:Tutorial;
      
      private var _addedToStageTime:Number;
      
      private var _isPvP:Boolean;
      
      private var hud_right:UIHUDPanel;
      
      private var btn_leave:UIHUDButton;
      
      private var btn_help:UIHelpButton;
      
      private var ui_rushVignette:RushVignette;
      
      public var ui_survivorBar:UISurvivorBar;
      
      public var ui_timer:UIMissionTimer;
      
      public var ui_threatRating:UIThreatRating;
      
      public var ui_confirm:UILeaveConfirm;
      
      public var ui_progressPanel:UIScavProgressPanel;
      
      public var leaveMissionRequsted:Signal;
      
      public var leaveMissionConfirmed:Signal;
      
      public var leaveMissionOpened:Signal;
      
      public function MissionGUILayer()
      {
         super();
         mouseEnabled = false;
         this.leaveMissionRequsted = new Signal();
         this.leaveMissionConfirmed = new Signal();
         this.leaveMissionOpened = new Signal();
         this._transitionedOut = new Signal(MissionGUILayer);
         this._lootItems = new Vector.<UILootItem>();
         this._tutorial = Tutorial.getInstance();
         this._tutorial.stepChanged.add(this.onTutorialStepChanged);
         this.ui_survivorBar = new UISurvivorBar();
         this.ui_survivorBar.isPvP = this._isPvP;
         addChild(this.ui_survivorBar);
         this.ui_timer = new UIMissionTimer();
         addChild(this.ui_timer);
         this.hud_right = new UIHUDPanel(true);
         addChild(this.hud_right);
         this.btn_help = new UIHelpButton();
         this.btn_help.addEventListener(MouseEvent.CLICK,this.onHelpClicked,false,0,true);
         addChild(this.btn_help);
         this.ui_confirm = new UILeaveConfirm();
         this.ui_confirm.cancelled.add(this.closeLeaveConfirm);
         this.ui_confirm.confirmed.add(this.onLeaveConfirmed);
         this.btn_leave = this.hud_right.addButton(new UIHUDButton("compound",new Bitmap(new BmpIconHUDReturn())));
         this.btn_leave.clicked.add(this.onHUDButtonClicked);
         TooltipManager.getInstance().add(this.btn_leave,Language.getInstance().getString("tooltip.return_compound"),new Point(NaN,-6),TooltipDirection.DIRECTION_DOWN);
         TooltipManager.getInstance().add(this.btn_help,Language.getInstance().getString("tooltip.help_pvp_mission"),new Point(NaN,-6),TooltipDirection.DIRECTION_DOWN);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
      }
      
      public function addFoundLoot(param1:Item) : void
      {
         var ty:int;
         var i:int;
         var item:Item = param1;
         var mc_loot:UILootItem = new UILootItem(item);
         mc_loot.x = 0;
         mc_loot.transitionIn();
         mc_loot.timerCompleted.addOnce(function(param1:UILootItem):void
         {
            var _loc2_:int = int(_lootItems.indexOf(param1));
            if(_loc2_ > -1)
            {
               _lootItems.splice(_loc2_,1);
            }
            TweenMax.to(param1,0.25,{
               "x":40,
               "alpha":0,
               "onComplete":param1.dispose
            });
         });
         addChild(mc_loot);
         ty = int(this._height - mc_loot.height - 20);
         mc_loot.y = ty;
         i = int(this._lootItems.length - 1);
         while(i >= 0)
         {
            ty -= int(this._lootItems[i].height + 4);
            TweenMax.to(this._lootItems[i],0.25,{"y":ty});
            if(i >= 10)
            {
               this._lootItems[i].timerCompleted.dispatch(this._lootItems[i]);
            }
            i--;
         }
         this._lootItems.push(mc_loot);
         TweenMax.to(mc_loot,0.25,{"x":20});
      }
      
      public function dispose() : void
      {
         var _loc1_:UILootItem = null;
         if(parent != null)
         {
            parent.removeChild(this);
         }
         TweenMax.killChildTweensOf(this);
         TooltipManager.getInstance().removeAllFromParent(this,true);
         for each(_loc1_ in this._lootItems)
         {
            _loc1_.dispose();
         }
         this._lootItems = null;
         this._gui = null;
         this.ui_survivorBar.dispose();
         this.ui_survivorBar = null;
         this.ui_timer.dispose();
         this.ui_timer = null;
         this.hud_right.dispose();
         this.hud_right = null;
         this.btn_leave = null;
         this.btn_help.dispose();
         this.btn_help = null;
         this.ui_confirm.dispose();
         this.ui_confirm = null;
         this._tutorial.stepChanged.remove(this.onTutorialStepChanged);
         this._tutorial = null;
         if(this.ui_progressPanel != null)
         {
            this.ui_progressPanel.dispose();
         }
         this.ui_progressPanel = null;
         if(this.ui_rushVignette != null)
         {
            this.ui_rushVignette.dispose();
         }
         this._transitionedOut.removeAll();
         this.leaveMissionRequsted.removeAll();
         this.leaveMissionConfirmed.removeAll();
         this.leaveMissionOpened.removeAll();
      }
      
      public function setupProgressPanel(param1:int, param2:int) : void
      {
         this.ui_progressPanel = new UIScavProgressPanel(param1,param2);
         this.ui_progressPanel.x = 0;
         this.ui_progressPanel.y = 40;
         addChild(this.ui_progressPanel);
      }
      
      public function updateScavProgressPanel(param1:int) : void
      {
         if(this.ui_progressPanel != null)
         {
            this.ui_progressPanel.UpdateProgress(param1);
         }
      }
      
      public function setRushState(param1:int) : void
      {
         if(param1 > 0)
         {
            if(this.ui_rushVignette == null)
            {
               this.ui_rushVignette = new RushVignette();
            }
            this.ui_rushVignette.x = -x;
            this.ui_rushVignette.y = -y;
            this.ui_rushVignette.alpha = 0.5 + param1 / 3 * 0.5;
            addChildAt(this.ui_rushVignette,0);
         }
         else if(this.ui_rushVignette != null)
         {
            if(this.ui_rushVignette.parent != null)
            {
               this.ui_rushVignette.parent.removeChild(this.ui_rushVignette);
            }
         }
      }
      
      public function setSize(param1:int, param2:int) : void
      {
         this._width = param1;
         this._height = param2;
         var _loc3_:int = 960;
         var _loc4_:int = int((this._width - _loc3_) * 0.5);
         this.hud_right.x = int(Math.min(_loc4_ + _loc3_ - 4,this._width - 4) - this.hud_right.width);
         this.hud_right.y = int(this._height - this.hud_right.height - 8);
         this.btn_help.x = int(this.hud_right.x - this.btn_help.width - 12);
         this.btn_help.y = int(this.hud_right.y + (this.hud_right.height - this.btn_help.height) * 0.5);
         this.ui_timer.x = int(this._width * 0.5);
         this.ui_timer.y = 6;
         if(this.ui_confirm.parent != null)
         {
            TweenMax.killTweensOf(this.ui_confirm);
            this.ui_confirm.x = int(this.hud_right.x + this.hud_right.width - this.ui_confirm.width - 4);
            this.ui_confirm.y = int(this.hud_right.y - this.ui_confirm.height - 6);
         }
         this.ui_survivorBar.x = int(this._width * 0.5);
         this.ui_survivorBar.y = int(this._height - this.ui_survivorBar.height - 14);
         this._gui.messageArea.y = int(this.y + this.ui_survivorBar.y - 40);
         if(this.ui_rushVignette != null)
         {
            this.ui_rushVignette.x = -x;
            this.ui_rushVignette.y = -y;
         }
      }
      
      public function transitionIn(param1:Number = 0) : void
      {
         mouseChildren = true;
         var _loc2_:Function = Back.easeOut;
         var _loc3_:Array = [0.75];
         TweenMax.from(this.hud_right,0.25,{
            "delay":param1,
            "y":this._height + 100,
            "ease":_loc2_,
            "easeParams":_loc3_
         });
         TweenMax.from(this.btn_help,0.25,{
            "delay":param1,
            "transformAroundCenter":{
               "scaleX":0,
               "scaleY":0
            },
            "ease":_loc2_,
            "easeParams":_loc3_
         });
         TweenMax.from(this.ui_timer,0.25,{
            "delay":param1,
            "alpha":0
         });
         if(this.ui_progressPanel != null)
         {
            TweenMax.from(this.ui_progressPanel,0.25,{
               "delay":param1,
               "x":-this.ui_progressPanel.width - 50,
               "ease":_loc2_,
               "easeParams":_loc3_
            });
         }
         if(this._tutorial.active && this._tutorial.stepNum < this._tutorial.getStepNum(Tutorial.STEP_EXIT_ZONES))
         {
            this.btn_leave.enabled = false;
         }
      }
      
      public function transitionOut(param1:Number = 0) : void
      {
         var easeFunction:Function;
         var easeParams:Array;
         var thisRef:MissionGUILayer = null;
         var delay:Number = param1;
         thisRef = this;
         mouseChildren = false;
         if(this._leaveConfirmOpened)
         {
            this.closeLeaveConfirm();
         }
         easeFunction = Back.easeIn;
         easeParams = [0.75];
         TweenMax.to(this.ui_timer,0.25,{
            "delay":delay,
            "alpha":0
         });
         TweenMax.to(this.btn_help,0.25,{
            "delay":delay,
            "transformAroundCenter":{
               "scaleX":0,
               "scaleY":0
            },
            "ease":easeFunction,
            "easeParams":easeParams
         });
         TweenMax.to(this.hud_right,0.25,{
            "delay":delay,
            "y":this._height + 100,
            "ease":easeFunction,
            "easeParams":easeParams,
            "onComplete":function():void
            {
               _transitionedOut.dispatch(thisRef);
            }
         });
         if(this.ui_progressPanel != null)
         {
            TweenMax.to(this.ui_progressPanel,0.25,{
               "delay":delay,
               "x":-this.ui_progressPanel.width - 50,
               "ease":easeFunction,
               "easeParams":easeParams
            });
         }
         if(this.ui_timer.parent != null)
         {
            this.ui_timer.parent.removeChild(this.ui_timer);
         }
         if(this.ui_survivorBar.parent != null)
         {
            this.ui_survivorBar.parent.removeChild(this.ui_survivorBar);
         }
      }
      
      public function showLeaveConfirm(param1:Boolean) : void
      {
         var ty:int = 0;
         var allSurvivorsInZones:Boolean = param1;
         if(this._leaveConfirmOpened)
         {
            this.closeLeaveConfirm();
            return;
         }
         ty = this.hud_right.y - this.ui_confirm.height - 6;
         this.ui_confirm.x = int(this.hud_right.x + this.hud_right.width - this.ui_confirm.width - 4);
         this.ui_confirm.y = this.hud_right.y + 100;
         this.ui_confirm.allSurvivorsInZones = allSurvivorsInZones;
         this.ui_confirm.mouseChildren = true;
         addChildAt(this.ui_confirm,0);
         TweenMax.to(this.ui_confirm,0.25,{
            "y":ty,
            "overwrite":true,
            "ease":Cubic.easeOut,
            "onComplete":function():void
            {
               ui_confirm.y = ty;
            }
         });
         Audio.sound.play("sound/interface/int-open.mp3");
         if(this._tutorial.active)
         {
            this._tutorial.clearArrows();
         }
         this._leaveConfirmOpened = true;
         this.leaveMissionOpened.dispatch();
         this.ui_survivorBar.setExitZoneDisplay(true);
      }
      
      private function closeLeaveConfirm() : void
      {
         this._leaveConfirmOpened = false;
         this.ui_confirm.mouseChildren = false;
         TweenMax.to(this.ui_confirm,0.25,{
            "y":int(this.hud_right.y + 100),
            "overwrite":true,
            "ease":Back.easeIn,
            "easeParams":[0.75],
            "onComplete":function():void
            {
               if(ui_confirm.parent != null)
               {
                  ui_confirm.parent.removeChild(ui_confirm);
               }
            }
         });
         Audio.sound.play("sound/interface/int-close.mp3");
         this.ui_survivorBar.setExitZoneDisplay(false);
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this._addedToStageTime = getTimer();
      }
      
      private function onHUDButtonClicked(param1:MouseEvent) : void
      {
         var _loc2_:Language = Language.getInstance();
         switch(UIHUDButton(param1.currentTarget).id)
         {
            case "compound":
               if(getTimer() - this._addedToStageTime < 3000)
               {
                  return;
               }
               this.leaveMissionRequsted.dispatch();
         }
      }
      
      private function onHelpClicked(param1:MouseEvent) : void
      {
         var _loc2_:PvPHelpDialogue = new PvPHelpDialogue();
         _loc2_.open();
      }
      
      private function onLeaveConfirmed() : void
      {
         this.leaveMissionConfirmed.dispatch();
         this.closeLeaveConfirm();
      }
      
      private function onTutorialStepChanged() : void
      {
         switch(this._tutorial.step)
         {
            case Tutorial.STEP_EXIT_ZONES:
               this.btn_leave.enabled = true;
               this._tutorial.addArrow(this.btn_leave,90,new Point(this.btn_leave.width * 0.5,-10));
         }
      }
      
      public function get isPvP() : Boolean
      {
         return this._isPvP;
      }
      
      public function set isPvP(param1:Boolean) : void
      {
         this._isPvP = param1;
         if(this.ui_survivorBar != null)
         {
            this.ui_survivorBar.isPvP = this._isPvP;
         }
      }
      
      public function get transitionedOut() : Signal
      {
         return this._transitionedOut;
      }
      
      public function get useFullWindow() : Boolean
      {
         return false;
      }
      
      public function get gui() : GameGUI
      {
         return this._gui;
      }
      
      public function set gui(param1:GameGUI) : void
      {
         this._gui = param1;
      }
      
      public function get showHUD() : Boolean
      {
         return this.hud_right.visible;
      }
      
      public function set showHUD(param1:Boolean) : void
      {
         this.hud_right.visible = param1;
      }
      
      public function get showHelpButton() : Boolean
      {
         return this.btn_help.visible;
      }
      
      public function set showHelpButton(param1:Boolean) : void
      {
         this.btn_help.visible = param1;
      }
      
      public function get leaveConfirmOpened() : Boolean
      {
         return this._leaveConfirmOpened;
      }
   }
}

