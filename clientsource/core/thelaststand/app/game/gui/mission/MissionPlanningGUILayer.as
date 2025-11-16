package thelaststand.app.game.gui.mission
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Back;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.gui.GameGUI;
   import thelaststand.app.game.gui.IGUILayer;
   import thelaststand.app.game.gui.UIHUDPanel;
   import thelaststand.app.game.gui.alliance.UIAllianceRaidPanel;
   import thelaststand.app.game.gui.bounty.BountyRaidNotice;
   import thelaststand.app.game.gui.buttons.UIHUDButton;
   import thelaststand.app.game.gui.buttons.UIHUDMapButton;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.common.lang.Language;
   
   public class MissionPlanningGUILayer extends Sprite implements IGUILayer
   {
      
      private var _gui:GameGUI;
      
      private var _width:int;
      
      private var _height:int;
      
      private var _transitionedOut:Signal;
      
      private var hud_right:UIHUDPanel;
      
      private var ui_bountyNotice:BountyRaidNotice;
      
      private var ui_alliancePanel:UIAllianceRaidPanel;
      
      private var ui_sameIPMsg:MessageBox;
      
      public var missionCancelled:Signal;
      
      public var ui_timer:UIMissionTimer;
      
      public function MissionPlanningGUILayer()
      {
         super();
         mouseEnabled = false;
         this.missionCancelled = new Signal();
         this.ui_timer = new UIMissionTimer();
         this.ui_timer.showWarning = false;
         addChild(this.ui_timer);
         this.hud_right = new UIHUDPanel(true);
         addChild(this.hud_right);
         var _loc1_:UIHUDButton = this.hud_right.addButton(new UIHUDMapButton("worldmap"));
         _loc1_.clicked.add(this.onHUDButtonClicked);
         this._transitionedOut = new Signal(MissionPlanningGUILayer);
         TooltipManager.getInstance().add(_loc1_,Language.getInstance().getString("tooltip.worldmap_return"),new Point(NaN,-6),TooltipDirection.DIRECTION_DOWN);
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         TweenMax.killChildTweensOf(this);
         TooltipManager.getInstance().removeAllFromParent(this,true);
         this.hud_right.dispose();
         this.hud_right = null;
         this.ui_timer.dispose();
         this.ui_timer = null;
         this._gui = null;
         this.missionCancelled.removeAll();
         this._transitionedOut.removeAll();
         if(this.ui_bountyNotice)
         {
            this.ui_bountyNotice.dispose();
         }
         if(this.ui_alliancePanel != null)
         {
            this.ui_alliancePanel.dispose();
         }
         if(this.ui_sameIPMsg)
         {
            this.ui_sameIPMsg.dispose();
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
         this.ui_timer.x = int(this._width * 0.5);
         this.ui_timer.y = 6;
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
         TweenMax.from(this.ui_timer,0.25,{
            "delay":param1,
            "alpha":0
         });
         if(this.ui_bountyNotice != null)
         {
            TweenMax.from(this.ui_bountyNotice,0.25,{
               "delay":param1,
               "y":-this.ui_bountyNotice.height - 50,
               "ease":_loc2_,
               "easeParams":_loc3_
            });
         }
         if(this.ui_alliancePanel != null)
         {
            TweenMax.from(this.ui_alliancePanel,0.25,{
               "delay":param1,
               "x":-this.ui_alliancePanel.width - 50,
               "ease":_loc2_,
               "easeParams":_loc3_
            });
         }
      }
      
      public function transitionOut(param1:Number = 0) : void
      {
         var easeFunction:Function;
         var easeParams:Array;
         var self:MissionPlanningGUILayer = null;
         var delay:Number = param1;
         self = this;
         mouseChildren = false;
         easeFunction = Back.easeIn;
         easeParams = [0.75];
         TweenMax.to(this.hud_right,0.25,{
            "delay":delay,
            "y":this._height + 100,
            "ease":easeFunction,
            "easeParams":easeParams,
            "onComplete":function():void
            {
               _transitionedOut.dispatch(self);
            }
         });
         if(this.ui_bountyNotice != null)
         {
            TweenMax.to(this.ui_bountyNotice,0.25,{
               "delay":delay,
               "y":-this.ui_bountyNotice.height - 50,
               "ease":easeFunction,
               "easeParams":easeParams
            });
         }
         if(this.ui_alliancePanel != null)
         {
            TweenMax.to(this.ui_alliancePanel,0.25,{
               "delay":delay,
               "x":-this.ui_alliancePanel.width - 50,
               "ease":easeFunction,
               "easeParams":easeParams
            });
         }
         if(this.ui_timer.parent != null)
         {
            this.ui_timer.parent.removeChild(this.ui_timer);
         }
      }
      
      public function showIPWarning() : void
      {
         this.ui_sameIPMsg = new MessageBox(Language.getInstance().getString("mission_sameip"),"sameIP",true);
         this.ui_sameIPMsg.addTitle(Language.getInstance().getString("mission_sameip_title"),BaseDialogue.TITLE_COLOR_RUST);
         this.ui_sameIPMsg.open();
      }
      
      public function setBountyInfo(param1:String, param2:Number) : void
      {
         this.ui_bountyNotice = new BountyRaidNotice(param1,param2);
         this.ui_bountyNotice.y = 50;
         addChild(this.ui_bountyNotice);
      }
      
      public function setAllianceInfo(param1:MissionData) : void
      {
         this.ui_alliancePanel = new UIAllianceRaidPanel(param1);
         this.ui_alliancePanel.x = 0;
         this.ui_alliancePanel.y = 40;
         addChild(this.ui_alliancePanel);
      }
      
      private function onHUDButtonClicked(param1:MouseEvent) : void
      {
         var _loc2_:Language = Language.getInstance();
         switch(UIHUDButton(param1.currentTarget).id)
         {
            case "compound":
            case "worldmap":
               this.missionCancelled.dispatch();
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
   }
}

