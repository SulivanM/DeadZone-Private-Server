package thelaststand.app.game.gui.map
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Back;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Config;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.data.AllianceDialogState;
   import thelaststand.app.data.NavigationLocation;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.display.Effects;
   import thelaststand.app.display.TitleTextField;
   import thelaststand.app.events.NavigationEvent;
   import thelaststand.app.game.Tutorial;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.gui.GameGUI;
   import thelaststand.app.game.gui.IGUILayer;
   import thelaststand.app.game.gui.UIHUDPanel;
   import thelaststand.app.game.gui.buttons.UIHUDAllianceButton;
   import thelaststand.app.game.gui.buttons.UIHUDBountyOfficeButton;
   import thelaststand.app.game.gui.buttons.UIHUDButton;
   import thelaststand.app.game.gui.buttons.UIHUDQuestButton;
   import thelaststand.app.game.gui.dialogues.AllianceDialogue;
   import thelaststand.app.game.gui.dialogues.BountyOfficeDialogue;
   import thelaststand.app.game.gui.dialogues.NeighborhoodListDialogue;
   import thelaststand.app.game.gui.dialogues.QuestsDialogue;
   import thelaststand.app.game.map.WorldMapView;
   import thelaststand.app.gui.MouseCursors;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.RemotePlayerData;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.ResourceManager;
   
   public class WorldMapGUILayer extends Sprite implements IGUILayer
   {
      
      private var _width:int;
      
      private var _height:int;
      
      private var _gui:GameGUI;
      
      private var _focusPlayerId:String;
      
      private var _lang:Language;
      
      private var _transitionedOut:Signal;
      
      private var _network:Network;
      
      private var _allianceSystem:AllianceSystem;
      
      private var hud_right:UIHUDPanel;
      
      private var txt_suburb:TitleTextField;
      
      private var txt_suburbLevel:TitleTextField;
      
      private var ui_filter:UIMapFilter;
      
      private var ui_neighborControl:UINeighborControl;
      
      private var map:WorldMapView;
      
      private var btn_bounty:UIHUDButton;
      
      private var btn_alliance:UIHUDButton;
      
      public function WorldMapGUILayer(param1:String = null)
      {
         var _loc2_:int = 0;
         super();
         mouseEnabled = false;
         this._network = Network.getInstance();
         this._allianceSystem = AllianceSystem.getInstance();
         this._lang = Language.getInstance();
         this._focusPlayerId = param1;
         this._transitionedOut = new Signal(WorldMapGUILayer);
         _loc2_ = int(this._network.playerData.getPlayerSurvivor().level);
         this.map = new WorldMapView();
         this.map.suburbChanged.add(this.onSuburbChanged);
         this.map.neighborClicked.add(this.onNeighborClicked);
         addChild(this.map);
         this.hud_right = new UIHUDPanel(true);
         addChild(this.hud_right);
         this.btn_alliance = this.hud_right.addButton(new UIHUDAllianceButton("alliance"));
         this.btn_alliance.clicked.add(this.onHUDButtonClicked);
         this.updateAllianceButtonState();
         this.btn_alliance.visible = this._network.playerData.getPlayerSurvivor().level >= int(Config.constant.ALLIANCE_MIN_JOIN_LEVEL);
         this.btn_bounty = this.hud_right.addButton(new UIHUDBountyOfficeButton("bounty"),-5);
         this.btn_bounty.clicked.add(this.onHUDButtonClicked);
         this.btn_bounty.visible = _loc2_ >= int(Config.constant.BOUNTY_MIN_LEVEL) || _loc2_ >= int(Config.constant.BOUNTY_ZOMBIE_MIN_LEVEL);
         var _loc3_:UIHUDButton = this.hud_right.addButton(new UIHUDButton("pvppractice",new Bitmap(new BmpIconHUDPvPPractice())));
         _loc3_.clicked.add(this.onHUDButtonClicked);
         var _loc4_:UIHUDButton = this.hud_right.addButton(new UIHUDQuestButton("quests"));
         _loc4_.clicked.add(this.onHUDButtonClicked);
         var _loc5_:UIHUDButton = this.hud_right.addButton(new UIHUDButton("list",new Bitmap(new BmpIconHUDNeighborList())));
         _loc5_.clicked.add(this.onHUDButtonClicked);
         var _loc6_:UIHUDButton = this.hud_right.addButton(new UIHUDButton("compound",new Bitmap(new BmpIconHUDReturn())));
         _loc6_.clicked.add(this.onHUDButtonClicked);
         this.ui_filter = new UIMapFilter();
         this.ui_filter.filterChanged.add(this.onFilterChanged);
         addChild(this.ui_filter);
         this.ui_neighborControl = new UINeighborControl();
         this.txt_suburb = new TitleTextField({
            "text":" ",
            "color":16777215,
            "size":24,
            "filters":[Effects.STROKE]
         });
         addChild(this.txt_suburb);
         this.txt_suburbLevel = new TitleTextField({
            "text":" ",
            "color":16777215,
            "size":20,
            "filters":[Effects.STROKE]
         });
         addChild(this.txt_suburbLevel);
         this._network.playerData.getPlayerSurvivor().levelIncreased.add(this.onPlayerLevelIncreased);
         this._allianceSystem.connectionAttempted.add(this.onAllianceSystemConnecting);
         this._allianceSystem.connectionFailed.add(this.onAllianceSystemConnectionFailed);
         this._allianceSystem.connected.add(this.onAllianceSystemConnected);
         this._allianceSystem.disconnected.add(this.onAllianceSystemDisconnected);
         TooltipManager.getInstance().add(_loc5_,this._lang.getString("tooltip.neighborhood_list"),new Point(NaN,-6),TooltipDirection.DIRECTION_DOWN);
         TooltipManager.getInstance().add(_loc6_,this._lang.getString("tooltip.return_compound"),new Point(NaN,-6),TooltipDirection.DIRECTION_DOWN);
         TooltipManager.getInstance().add(_loc3_,this._lang.getString("tooltip.pvp_practice"),new Point(NaN,-6),TooltipDirection.DIRECTION_DOWN);
         TooltipManager.getInstance().add(_loc4_,this._lang.getString("tooltip.quests"),new Point(NaN,-6),TooltipDirection.DIRECTION_DOWN);
         TooltipManager.getInstance().add(this.btn_bounty,this.getBountyTooltip,new Point(NaN,-6),TooltipDirection.DIRECTION_DOWN);
         TooltipManager.getInstance().add(this.btn_alliance,this.getAllianceTooltip,new Point(NaN,-6),TooltipDirection.DIRECTION_DOWN);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         TooltipManager.getInstance().removeAllFromParent(this,true);
         TweenMax.killChildTweensOf(this);
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         this._network.playerData.getPlayerSurvivor().levelIncreased.remove(this.onPlayerLevelIncreased);
         this._network = null;
         this._allianceSystem.connectionAttempted.remove(this.onAllianceSystemConnecting);
         this._allianceSystem.connectionFailed.remove(this.onAllianceSystemConnectionFailed);
         this._allianceSystem.connected.remove(this.onAllianceSystemConnected);
         this._allianceSystem.disconnected.remove(this.onAllianceSystemDisconnected);
         this._allianceSystem = null;
         this.map.suburbChanged.remove(this.onSuburbChanged);
         this.map.neighborClicked.remove(this.onNeighborClicked);
         this.map.dispose();
         this.map = null;
         this.hud_right.dispose();
         this.hud_right = null;
         this.ui_filter.dispose();
         this.ui_filter = null;
         this.ui_neighborControl.dispose();
         this.ui_neighborControl = null;
         this.txt_suburbLevel.dispose();
         this.txt_suburbLevel = null;
         this.txt_suburb.dispose();
         this.txt_suburb = null;
         this._transitionedOut.removeAll();
         this._lang = null;
         this._gui = null;
      }
      
      public function setSize(param1:int, param2:int) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         this._width = param1;
         this._height = param2;
         _loc3_ = 960;
         _loc4_ = int((this._width - _loc3_) * 0.5);
         this.txt_suburb.x = (param1 - this.txt_suburb.width) * 0.5;
         this.txt_suburb.y = 24;
         this.txt_suburbLevel.x = (param1 - this.txt_suburbLevel.width) * 0.5;
         this.txt_suburbLevel.y = this.txt_suburb.y + this.txt_suburb.height - 5;
         this.hud_right.x = int(Math.min(_loc4_ + _loc3_ - 4,this._width - 4) - this.hud_right.width);
         this.hud_right.y = int(this._height - this.hud_right.height - 8);
         this.ui_filter.x = Math.max(_loc4_ + 4,4);
         this.ui_filter.y = this.hud_right.y;
         this.map.setSize(this._width,this._height);
         this.map.updateViewportBounds(this._gui.header.height,this._gui.footer.y,this._width);
      }
      
      public function transitionIn(param1:Number = 0) : void
      {
         var easeFunction:Function;
         var easeParams:Array;
         var allianceDlg:AllianceDialogue = null;
         var delay:Number = param1;
         mouseChildren = true;
         MouseCursors.setCursor(MouseCursors.DEFAULT);
         easeFunction = Back.easeOut;
         easeParams = [0.75];
         if(!Tutorial.getInstance().active)
         {
            TweenMax.from(this.hud_right,0.25,{
               "delay":delay,
               "y":this._height + 100,
               "ease":easeFunction,
               "easeParams":easeParams,
               "overwrite":true
            });
            this.hud_right.visible = true;
         }
         else
         {
            this.hud_right.visible = false;
         }
         TweenMax.from(this.ui_filter,0.25,{
            "delay":delay,
            "y":"200",
            "ease":easeFunction,
            "easeParams":easeParams,
            "overwrite":true
         });
         this.txt_suburb.alpha = this.txt_suburbLevel.alpha = 1;
         TweenMax.from(this.txt_suburb,0.25,{
            "delay":delay,
            "alpha":0,
            "overwrite":true
         });
         TweenMax.from(this.txt_suburbLevel,0.25,{
            "delay":delay,
            "alpha":0,
            "overwrite":true
         });
         this.map.setSize(this._width,this._height);
         this.map.updateViewportBounds(this._gui.header.height,this._gui.footer.y,this._width);
         this.map.transitionIn(delay,this._focusPlayerId);
         if(this._focusPlayerId != null && !this.map.hasNodeForPlayer(this._focusPlayerId))
         {
            ResourceManager.getInstance().pauseQueue();
            TweenMax.delayedCall(0.25,function():void
            {
               if(stage == null || !mouseChildren)
               {
                  return;
               }
               var _loc1_:NeighborhoodListDialogue = new NeighborhoodListDialogue();
               _loc1_.open();
            });
         }
         if(AllianceDialogState.getInstance().allianceDialogReturnType != AllianceDialogState.SHOW_NONE)
         {
            allianceDlg = new AllianceDialogue();
            allianceDlg.open();
            AllianceDialogState.getInstance().allianceDialogReturnType = AllianceDialogState.SHOW_NONE;
         }
      }
      
      public function transitionOut(param1:Number = 0) : void
      {
         var easeFunction:Function;
         var easeParams:Array;
         var thisRef:WorldMapGUILayer = null;
         var delay:Number = param1;
         mouseChildren = false;
         this.ui_neighborControl.hide();
         easeFunction = Back.easeIn;
         easeParams = [0.75];
         TweenMax.to(this.hud_right,0.25,{
            "delay":delay,
            "y":this._height + 100,
            "ease":easeFunction,
            "easeParams":easeParams,
            "overwrite":true
         });
         TweenMax.to(this.ui_filter,0.25,{
            "delay":delay,
            "y":"200",
            "ease":easeFunction,
            "easeParams":easeParams,
            "overwrite":true
         });
         TweenMax.to(this.txt_suburb,0.25,{
            "delay":delay,
            "alpha":0,
            "overwrite":true
         });
         TweenMax.to(this.txt_suburbLevel,0.25,{
            "delay":delay,
            "alpha":0,
            "overwrite":true
         });
         thisRef = this;
         this.map.transitionOut(delay,function():void
         {
            ResourceManager.getInstance().loadQueue();
            _transitionedOut.dispatch(thisRef);
         });
      }
      
      private function getBountyTooltip() : String
      {
         return this._lang.getString(this.btn_bounty.enabled ? "tooltip.bountylist" : "tooltip.bountylistDisabled");
      }
      
      private function getAllianceTooltip() : String
      {
         var _loc1_:String = "tooltip.alliances";
         if(this.btn_alliance.enabled == false)
         {
            if(this._allianceSystem.buildingRequirementsMet)
            {
               _loc1_ = "tooltip.alliancesBuildingRequired";
            }
            else if(this._allianceSystem.isConnecting)
            {
               _loc1_ = "tooltip.alliancesConnecting";
            }
            else
            {
               _loc1_ = "tooltip.alliancesDisabled";
            }
         }
         return this._lang.getString(_loc1_);
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.updateAllianceButtonState();
      }
      
      private function onHUDButtonClicked(param1:MouseEvent) : void
      {
         var _loc2_:NeighborhoodListDialogue = null;
         var _loc3_:PlayerData = null;
         var _loc4_:QuestsDialogue = null;
         var _loc5_:BountyOfficeDialogue = null;
         var _loc6_:AllianceDialogue = null;
         switch(UIHUDButton(param1.currentTarget).id)
         {
            case "compound":
               dispatchEvent(new NavigationEvent(NavigationEvent.REQUEST,NavigationLocation.PLAYER_COMPOUND));
               break;
            case "list":
               _loc2_ = new NeighborhoodListDialogue();
               _loc2_.open();
               break;
            case "pvppractice":
               _loc3_ = Network.getInstance().playerData;
               dispatchEvent(new NavigationEvent(NavigationEvent.REQUEST,NavigationLocation.MISSION_PLANNING,new RemotePlayerData(_loc3_.id,{
                  "name":_loc3_.nickname,
                  "level":_loc3_.getPlayerSurvivor().level
               })));
               break;
            case "quests":
               _loc4_ = new QuestsDialogue();
               _loc4_.open();
               break;
            case "bounty":
               _loc5_ = new BountyOfficeDialogue();
               _loc5_.open();
               break;
            case "alliance":
               _loc6_ = new AllianceDialogue();
               _loc6_.open();
         }
      }
      
      private function onFilterChanged(param1:String) : void
      {
         this.map.setFilter(param1);
         Tracking.trackEvent("Map","Filter",param1);
      }
      
      private function onSuburbChanged(param1:String, param2:int, param3:Boolean) : void
      {
         var strName:String = null;
         var suburb:String = param1;
         var level:int = param2;
         var locked:Boolean = param3;
         strName = this._lang.getString("suburbs." + suburb).toUpperCase();
         TweenMax.to(this.txt_suburbLevel,0.25,{
            "alpha":0,
            "overwrite":true
         });
         TweenMax.to(this.txt_suburb,0.25,{
            "alpha":0,
            "overwrite":true,
            "onComplete":function():void
            {
               txt_suburb.text = strName;
               txt_suburbLevel.text = _lang.getString("level",level + 1).toUpperCase();
               txt_suburbLevel.textColor = locked ? Effects.COLOR_WARNING : 16777215;
               txt_suburb.x = (_width - txt_suburb.width) * 0.5;
               txt_suburbLevel.x = (_width - txt_suburbLevel.width) * 0.5;
               TweenMax.to(txt_suburb,0.25,{"alpha":1});
               TweenMax.to(txt_suburbLevel,0.25,{"alpha":1});
            }
         });
      }
      
      private function onNeighborClicked(param1:RemotePlayerData, param2:Point) : void
      {
         this.ui_neighborControl.neighbor = param1;
         this.ui_neighborControl.x = int(param2.x);
         this.ui_neighborControl.y = int(param2.y - this.ui_neighborControl.height * 0.5);
         this._gui.getLayerAsSprite(this._gui.SCENE_LAYER_NAME).addChild(this.ui_neighborControl);
      }
      
      private function updateAllianceButtonState() : void
      {
         this.btn_alliance.enabled = this._allianceSystem.canAccessAlliances() && this._allianceSystem.isConnecting == false;
      }
      
      private function onAllianceSystemConnecting() : void
      {
         this.updateAllianceButtonState();
      }
      
      private function onAllianceSystemConnectionFailed() : void
      {
         this.updateAllianceButtonState();
      }
      
      private function onAllianceSystemConnected() : void
      {
         this.updateAllianceButtonState();
      }
      
      private function onAllianceSystemDisconnected() : void
      {
         this.updateAllianceButtonState();
      }
      
      private function onPlayerLevelIncreased(param1:Survivor, param2:int) : void
      {
         var _loc3_:Boolean = false;
         var _loc4_:Boolean = param2 >= int(Config.constant.BOUNTY_MIN_LEVEL) || param2 >= int(Config.constant.BOUNTY_ZOMBIE_MIN_LEVEL);
         if((_loc4_) && this.btn_bounty.visible == false)
         {
            this.btn_bounty.visible = _loc4_;
            if(this.btn_bounty.visible)
            {
               TweenMax.from(this.btn_bounty,2,{
                  "glowFilter":{
                     "color":16777215,
                     "blurX":20,
                     "blurY":20,
                     "alpha":1,
                     "strength":2,
                     "quality":1
                  },
                  "colorTransform":{"exposure":2}
               });
               _loc3_ = true;
            }
         }
         if(param2 >= int(Config.constant.ALLIANCE_MIN_JOIN_LEVEL) && this.btn_alliance.visible == false)
         {
            this.btn_alliance.visible = this._network.playerData.getPlayerSurvivor().level >= int(Config.constant.ALLIANCE_MIN_JOIN_LEVEL);
         }
         if(_loc3_)
         {
            this.hud_right.refreshLayout();
            this.setSize(this._width,this._height);
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

