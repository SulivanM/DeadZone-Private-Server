package thelaststand.app.game.gui.dialogues
{
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.GameResources;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorClass;
   import thelaststand.app.game.data.SurvivorLoadout;
   import thelaststand.app.game.data.SurvivorState;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.game.gui.loadout.UIMissionInfo;
   import thelaststand.app.game.gui.loadout.UIMissionSurvivorSlot;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class MissionLoadoutDialogue extends BaseDialogue
   {
      
      private const MAX_SLOTS:int = 5;
      
      private var _lang:Language;
      
      private var _tooltip:TooltipManager;
      
      private var _missionData:MissionData;
      
      private var _survivorSlots:Vector.<UIMissionSurvivorSlot>;
      
      private var _survivorsUsed:Vector.<Survivor>;
      
      private var _userModified:Boolean;
      
      private var _totalAmmo:int;
      
      private var _maxSurvivors:int;
      
      private var mc_container:Sprite;
      
      private var bmp_launchBg:Bitmap;
      
      private var btn_launch:PushButton;
      
      private var ui_missionInfo:UIMissionInfo;
      
      private var isHighActivityArea:Boolean = false;
      
      public var launched:Signal;
      
      public function MissionLoadoutDialogue(param1:MissionData)
      {
         var _loc2_:String = null;
         var _loc6_:UIMissionSurvivorSlot = null;
         this.mc_container = new Sprite();
         super("mission-loadout",this.mc_container,true);
         this._lang = Language.getInstance();
         this._tooltip = TooltipManager.getInstance();
         _autoSize = false;
         _padding = 12;
         _width = 432;
         _height = 466;
         this._survivorsUsed = new Vector.<Survivor>();
         this._missionData = param1;
         this.isHighActivityArea = param1.highActivityIndex > -1;
         this.launched = new Signal(MissionData);
         if(this._missionData.isPvPPractice)
         {
            _loc2_ = this._lang.getString("mission_title_pvppractice");
         }
         else if(this._missionData.isPvP)
         {
            _loc2_ = this._lang.getString("mission_title_attackplayer",this._missionData.opponent.nickname);
         }
         else
         {
            _loc2_ = this._lang.getString("mission_title",this._lang.getString("locations." + param1.type,this._lang.getString("suburbs." + param1.suburb)));
         }
         addTitle(_loc2_,this.isHighActivityArea ? Effects.COLOR_WARNING : 4934477);
         if(this._missionData.opponent.isPlayer)
         {
            this._maxSurvivors = this.MAX_SLOTS;
         }
         else
         {
            this._maxSurvivors = Network.getInstance().playerData.compound.getEffectValue(EffectType.getTypeValue("MissionSurvivorLimit"));
            if(this._maxSurvivors == 0)
            {
               this._maxSurvivors = this.MAX_SLOTS;
            }
         }
         this._survivorSlots = new Vector.<UIMissionSurvivorSlot>();
         var _loc3_:int = 0;
         var _loc4_:int = _padding - 6;
         var _loc5_:int = 0;
         while(_loc5_ < this.MAX_SLOTS)
         {
            _loc6_ = new UIMissionSurvivorSlot();
            _loc6_.clicked.add(this.onSurvivorSlotClicked);
            _loc6_.x = _loc3_;
            _loc6_.y = _loc4_;
            _loc4_ += _loc6_.height + 4;
            this._survivorSlots.push(_loc6_);
            this.mc_container.addChild(_loc6_);
            _loc5_++;
         }
         this.ui_missionInfo = new UIMissionInfo(this._missionData);
         this.ui_missionInfo.x = int(_width - this.ui_missionInfo.width - _padding * 2);
         this.ui_missionInfo.y = _padding - 6;
         this.mc_container.addChild(this.ui_missionInfo);
         this.btn_launch = new PushButton(this._lang.getString("mission_launch"),new BmpIconButtonArrow(),41732);
         this.btn_launch.x = int(this.ui_missionInfo.x + (this.ui_missionInfo.width - this.btn_launch.width) * 0.5);
         this.btn_launch.y = int(_height - _padding * 2 - this.btn_launch.height - 20);
         this.btn_launch.enabled = false;
         this.btn_launch.clicked.add(this.onLaunchClicked);
         this.mc_container.addChild(this.btn_launch);
         this.bmp_launchBg = new Bitmap(new BmpMissionLaunchBG());
         this.bmp_launchBg.cacheAsBitmap = true;
         this.bmp_launchBg.x = int(this.btn_launch.x + (this.btn_launch.width - this.bmp_launchBg.width) * 0.5);
         this.bmp_launchBg.y = int(this.btn_launch.y + (this.btn_launch.height - this.bmp_launchBg.height) * 0.5);
         this.mc_container.addChildAt(this.bmp_launchBg,0);
         this.updateSlotStates();
         Network.getInstance().playerData.compound.resources.resourceChanged.add(this.onResourceChanged);
      }
      
      override public function dispose() : void
      {
         var _loc1_:UIMissionSurvivorSlot = null;
         this._tooltip.removeAllFromParent(this.mc_container);
         Network.getInstance().playerData.compound.resources.resourceChanged.remove(this.onResourceChanged);
         super.dispose();
         this._lang = null;
         this._tooltip = null;
         this._missionData = null;
         this._survivorsUsed = null;
         for each(_loc1_ in this._survivorSlots)
         {
            if(_loc1_.survivor != null)
            {
               _loc1_.survivor.loadoutOffence.changed.remove(this.onSurvivorLoadoutChanged);
               _loc1_.survivor.injuries.changed.remove(this.onSurvivorInjuriesChanged);
            }
            _loc1_.dispose();
         }
         this._survivorSlots = null;
         this.launched.removeAll();
         this.ui_missionInfo.dispose();
         this.btn_launch.dispose();
         this.bmp_launchBg.bitmapData.dispose();
         this.bmp_launchBg.bitmapData = null;
      }
      
      override public function open() : void
      {
         super.open();
         Tracking.trackPageview("missionSetup/" + (this._missionData.opponent.isPlayer ? "pvp" : "pve"));
      }
      
      private function updateSlotStates() : void
      {
         var _loc4_:UIMissionSurvivorSlot = null;
         var _loc5_:String = null;
         this._survivorsUsed.length = 0;
         this._missionData.survivors.length = 0;
         var _loc1_:Boolean = true;
         var _loc2_:int = 0;
         while(_loc2_ < this._survivorSlots.length)
         {
            _loc4_ = this._survivorSlots[_loc2_];
            if(_loc4_.survivor != null)
            {
               if(this._survivorsUsed.indexOf(_loc4_.survivor) > -1)
               {
                  _loc4_.setSurvivor(null,null);
               }
               else
               {
                  this._survivorsUsed.push(_loc4_.survivor);
                  if(_loc4_.survivor.loadoutOffence.weapon.item == null)
                  {
                     _loc1_ = false;
                  }
                  this._missionData.survivors.push(_loc4_.survivor);
               }
            }
            _loc4_.enabled = _loc2_ < this._maxSurvivors && (_loc4_.survivor != null || _loc2_ == 0 || this._survivorSlots[_loc2_ - 1].survivor != null);
            _loc4_.alpha = _loc2_ >= this._maxSurvivors ? 0.8 : 1;
            _loc2_++;
         }
         this._totalAmmo = Network.getInstance().playerData.compound.resources.getAmount(GameResources.AMMUNITION);
         var _loc3_:* = this._missionData.getTotalAmmoCost() <= this._totalAmmo;
         this.btn_launch.enabled = this._survivorsUsed.length > 0 && _loc1_ && _loc3_;
         if(this.btn_launch.enabled)
         {
            this._tooltip.remove(this.btn_launch);
         }
         else
         {
            _loc5_ = "";
            if(this._survivorsUsed.length == 0)
            {
               _loc5_ = Language.getInstance().getString("mission_launch_nosurvivors");
            }
            else if(!_loc3_)
            {
               _loc5_ = Language.getInstance().getString("mission_launch_noammo");
            }
            else
            {
               _loc5_ = Language.getInstance().getString("mission_launch_noweapons");
            }
            this._tooltip.add(this.btn_launch,_loc5_,new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
         }
         this.ui_missionInfo.update();
      }
      
      private function onSurvivorSlotClicked(param1:MouseEvent) : void
      {
         var slot:UIMissionSurvivorSlot = null;
         var dlg:SurvivorListDialogue = null;
         var e:MouseEvent = param1;
         var assignSurvivor:Function = function(param1:SurvivorListDialogue, param2:Survivor):void
         {
            if(slot.survivor != null)
            {
               slot.survivor.loadoutOffence.changed.remove(onSurvivorLoadoutChanged);
               slot.survivor.injuries.changed.remove(onSurvivorInjuriesChanged);
            }
            slot.setSurvivor(param2,param2 != null ? param2.loadoutOffence : null);
            if(param2 != null)
            {
               param2.loadoutOffence.changed.add(onSurvivorLoadoutChanged);
               param2.injuries.changed.add(onSurvivorInjuriesChanged);
            }
            updateSlotStates();
            param1.close();
            _userModified = true;
         };
         slot = e.currentTarget as UIMissionSurvivorSlot;
         dlg = new SurvivorListDialogue(this._lang.getString("select_survivor_title"),Network.getInstance().playerData.compound.survivors,this._survivorsUsed,Vector.<String>([SurvivorClass.UNASSIGNED]),true);
         dlg.selected.add(function(param1:Survivor):void
         {
            var langId:String = null;
            var dlgAway:MessageBox = null;
            var dlgTask:MessageBox = null;
            var srv:Survivor = param1;
            if(srv != null)
            {
               if(Boolean(srv.state & SurvivorState.ON_MISSION) || Boolean(srv.state & SurvivorState.REASSIGNING) || Boolean(srv.state & SurvivorState.ON_ASSIGNMENT))
               {
                  langId = "srv_mission_cantassign_";
                  if(Boolean(srv.state & SurvivorState.ON_MISSION) || Boolean(srv.state & SurvivorState.ON_ASSIGNMENT))
                  {
                     langId += "away";
                  }
                  else
                  {
                     langId += "reassign";
                  }
                  dlgAway = new MessageBox(_lang.getString(langId + "_msg",srv.firstName));
                  dlgAway.addTitle(_lang.getString(langId + "_title",srv.firstName));
                  dlgAway.addImage(srv.portraitURI);
                  dlgAway.addButton(_lang.getString(langId + "_ok"));
                  if(!(srv.state & SurvivorState.ON_ASSIGNMENT))
                  {
                     dlgAway.addButton(_lang.getString(langId + "_speedup"),true,{"backgroundColor":4226049}).clicked.add(function(param1:MouseEvent):void
                     {
                        var _loc3_:SpeedUpDialogue = null;
                        var _loc2_:* = srv.missionId != null ? Network.getInstance().playerData.missionList.getMissionById(srv.missionId) : srv;
                        if(_loc2_ != null)
                        {
                           _loc3_ = new SpeedUpDialogue(_loc2_);
                           _loc3_.open();
                        }
                     });
                  }
                  dlgAway.closed.addOnce(function(param1:Dialogue):void
                  {
                     dlg.selectItem(-1);
                  });
                  dlgAway.open();
                  return;
               }
               if(Boolean(srv.state & SurvivorState.ON_TASK) && srv.task != null)
               {
                  dlgTask = new MessageBox(_lang.getString("srv_assigned_task_msg",srv.fullName));
                  dlgTask.addTitle(_lang.getString("srv_assigned_task_title"));
                  dlgTask.addImage(srv.portraitURI);
                  dlgTask.addButton(_lang.getString("srv_assigned_task_cancel")).clicked.addOnce(function(param1:MouseEvent):void
                  {
                     dlg.selectItem(-1);
                  });
                  dlgTask.addButton(_lang.getString("srv_assigned_task_ok")).clicked.addOnce(function(param1:MouseEvent):void
                  {
                     assignSurvivor(dlg,srv);
                  });
                  dlgTask.open();
                  return;
               }
            }
            assignSurvivor(dlg,srv);
         });
         dlg.open();
      }
      
      private function onSurvivorLoadoutChanged() : void
      {
         this._userModified = true;
         this.updateSlotStates();
      }
      
      private function onSurvivorInjuriesChanged(param1:Survivor) : void
      {
         this.updateSlotStates();
      }
      
      private function onLaunchClicked(param1:MouseEvent) : void
      {
         Tracking.trackEvent("MissionSetup","Launch",this._missionData.automated ? "automated" : "played",this._missionData.survivors.length);
         this.launched.dispatch(this._missionData);
         close();
      }
      
      private function onResourceChanged(param1:String, param2:int) : void
      {
         if(param1 == GameResources.AMMUNITION)
         {
            if(this._totalAmmo != Network.getInstance().playerData.compound.resources.getAmount(GameResources.AMMUNITION))
            {
               this.updateSlotStates();
            }
         }
      }
   }
}

