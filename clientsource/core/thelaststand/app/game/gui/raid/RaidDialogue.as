package thelaststand.app.game.gui.raid
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.GameResources;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.effects.Cooldown;
   import thelaststand.app.game.data.effects.CooldownType;
   import thelaststand.app.game.data.raid.RaidData;
   import thelaststand.app.game.data.raid.RaidSystem;
   import thelaststand.app.game.gui.UIUnavailableBanner;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.ResourceManager;
   
   public class RaidDialogue extends BaseDialogue
   {
      
      public static const COLOR:uint = 11098127;
      
      private var _raidData:RaidData;
      
      private var _bmdIcon:BitmapData;
      
      private var _cooldown:Cooldown;
      
      private var mc_container:Sprite;
      
      private var bmp_launchBG:Bitmap;
      
      private var ui_stageView:RaidStagesView;
      
      private var ui_rewardsView:RaidRewardsView;
      
      private var ui_survivorsView:RaidSurvivorsView;
      
      private var ui_ammoView:AssignmentAmmoView;
      
      private var btn_launch:PushButton;
      
      private var btn_abandon:PushButton;
      
      private var ui_unavailable:UIUnavailableBanner;
      
      public function RaidDialogue(param1:*)
      {
         var spacing:int;
         var h:int;
         var raidId:String = null;
         var raidData:RaidData = null;
         var raidNameOrRaidData:* = param1;
         if(raidNameOrRaidData is String)
         {
            raidId = String(raidNameOrRaidData);
            raidData = new RaidData();
            raidData.setXML(ResourceManager.getInstance().getResource("xml/raids.xml").content.raid.(@id == raidId)[0]);
         }
         else if(raidNameOrRaidData is RaidData)
         {
            raidData = RaidData(raidNameOrRaidData);
            raidId = raidData.name;
         }
         this.mc_container = new Sprite();
         super("raid-" + raidId,this.mc_container,true,true);
         _autoSize = false;
         _width = 758;
         _height = 470;
         this._raidData = raidData;
         this._raidData.survivorsChanged.add(this.onSurvivorsChanged);
         this._raidData.survivorLoadoutChanged.add(this.onSurvivorsChanged);
         this._bmdIcon = new BmpBountySkull();
         addTitle(Language.getInstance().getString("raid.title",Language.getInstance().getString("raid." + this._raidData.name + ".name")),BaseDialogue.TITLE_COLOR_GREY,-1,this._bmdIcon);
         this.ui_stageView = new RaidStagesView();
         this.ui_stageView.width = _width - 228 - _padding;
         this.ui_stageView.height = 290;
         this.mc_container.addChild(this.ui_stageView);
         this.ui_rewardsView = new RaidRewardsView();
         this.ui_rewardsView.x = int(this.ui_stageView.x);
         this.ui_rewardsView.y = int(this.ui_stageView.y + this.ui_stageView.height + 6);
         this.ui_rewardsView.width = this.ui_stageView.width;
         this.ui_rewardsView.height = int(_height - this.ui_rewardsView.y - _padding * 2 - 6);
         this.mc_container.addChild(this.ui_rewardsView);
         this.ui_survivorsView = new RaidSurvivorsView();
         this.ui_survivorsView.x = int(this.ui_stageView.x + this.ui_stageView.width + 6);
         this.ui_survivorsView.y = int(this.ui_stageView.y);
         this.ui_survivorsView.height = int(this.ui_stageView.height - 20);
         this.ui_survivorsView.width = int(_width - this.ui_survivorsView.x - _padding * 2);
         this.ui_survivorsView.loadoutsChanged.add(this.onSurvivorLoadoutChanged);
         this.mc_container.addChild(this.ui_survivorsView);
         this.ui_ammoView = new AssignmentAmmoView();
         this.ui_ammoView.x = int(this.ui_survivorsView.x);
         this.ui_ammoView.y = int(this.ui_survivorsView.y + this.ui_survivorsView.height + 6);
         this.ui_ammoView.width = int(this.ui_survivorsView.width);
         this.ui_ammoView.height = 40;
         this.mc_container.addChild(this.ui_ammoView);
         this.btn_abandon = new PushButton(Language.getInstance().getString(this._raidData.hasStarted ? "raid.abandon" : "raid.cancel"),new BmpIconTradeCrossRed(),10884373,{"bold":true});
         this.btn_abandon.width = int(this.ui_survivorsView.width - 8);
         this.btn_abandon.height = 40;
         this.btn_abandon.x = int(this.ui_survivorsView.x + 4);
         this.btn_abandon.clicked.add(this.onClickAbandon);
         this.mc_container.addChild(this.btn_abandon);
         this.btn_launch = new PushButton(Language.getInstance().getString("raid.launch"),new BmpIconButtonArrow(),5083399,{"bold":true});
         this.btn_launch.width = this.btn_abandon.width;
         this.btn_launch.height = this.btn_abandon.height;
         this.btn_launch.clicked.add(this.onClickLaunch);
         this.btn_launch.x = this.btn_abandon.x;
         this.mc_container.addChild(this.btn_launch);
         spacing = 22;
         h = this.btn_abandon.height + spacing + this.btn_launch.height;
         this.btn_abandon.y = int(this.ui_rewardsView.y + this.ui_rewardsView.height - this.btn_launch.height - 4);
         this.btn_launch.y = int(this.btn_abandon.y - this.btn_abandon.height - spacing);
         this.bmp_launchBG = new Bitmap(new BmpMissionLaunchBG(),"auto",true);
         this.bmp_launchBG.width = int(this.btn_launch.width + 30);
         this.bmp_launchBG.height = int(this.btn_launch.height + 30);
         this.bmp_launchBG.x = int(this.btn_launch.x + (this.btn_launch.width - this.bmp_launchBG.width) * 0.5);
         this.bmp_launchBG.y = int(this.btn_launch.y + (this.btn_launch.height - this.bmp_launchBG.height) * 0.5);
         this.mc_container.addChildAt(this.bmp_launchBG,0);
         Network.getInstance().playerData.compound.resources.resourceChanged.add(this.onResourceChanged);
         this.refresh();
      }
      
      override public function dispose() : void
      {
         super.dispose();
         Network.getInstance().playerData.compound.resources.resourceChanged.remove(this.onResourceChanged);
         this.bmp_launchBG.bitmapData.dispose();
         this.ui_stageView.dispose();
         this.ui_rewardsView.dispose();
         this.ui_survivorsView.dispose();
         this.ui_ammoView.dispose();
         if(this.ui_unavailable != null)
         {
            this.ui_unavailable.dispose();
         }
         this._bmdIcon.dispose();
         this._raidData.survivorsChanged.remove(this.onSurvivorsChanged);
         this._raidData.survivorLoadoutChanged.remove(this.onSurvivorsChanged);
         this._raidData = null;
      }
      
      private function refresh() : void
      {
         this.ui_stageView.setData(this._raidData);
         this.ui_stageView.redraw();
         this.ui_rewardsView.setData(this._raidData);
         this.ui_rewardsView.redraw();
         this.ui_survivorsView.setData(this._raidData);
         this.ui_survivorsView.redraw();
         this.ui_ammoView.setData(this._raidData);
         this.ui_ammoView.redraw();
         this.ui_stageView.selectStage(this._raidData.currentStageIndex);
         this.updateLaunchButtonState();
         this._cooldown = Network.getInstance().playerData.cooldowns.getByType(CooldownType.Raid);
         if(this._cooldown != null)
         {
            this._cooldown.completed.remove(this.onCooldownCompleted);
            this._cooldown.completed.addOnce(this.onCooldownCompleted);
            this.mc_container.mouseChildren = false;
            this.mc_container.filters = [Effects.GREYSCALE.filter];
            if(this.ui_unavailable == null)
            {
               this.ui_unavailable = new UIUnavailableBanner();
            }
            this.ui_unavailable.timer = this._cooldown.timer;
            this.ui_unavailable.title = Language.getInstance().getString("raid.cooldown_title");
            this.ui_unavailable.message = Language.getInstance().getString("raid.cooldown_message");
            this.ui_unavailable.width = int(_width - _padding * 2);
            this.ui_unavailable.height = 110;
            this.ui_unavailable.x = int(this.mc_container.x + (_width - this.ui_unavailable.width) * 0.5) - 1;
            this.ui_unavailable.y = int(this.mc_container.y + this.ui_stageView.y + 30 + (this.ui_stageView.height - this.ui_unavailable.height) * 0.5);
            sprite.addChild(this.ui_unavailable);
         }
         else if(this.ui_unavailable != null)
         {
            this.ui_unavailable.dispose();
            this.ui_unavailable = null;
         }
      }
      
      private function updateLaunchButtonState() : void
      {
         var _loc3_:Survivor = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(this._raidData.survivorIds.length < this._raidData.minSurvivorCount)
         {
            this.btn_launch.enabled = false;
            TooltipManager.getInstance().add(this.btn_launch,Language.getInstance().getString("raid.launch_tooltip_error_minsrv",this._raidData.minSurvivorCount),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
            return;
         }
         var _loc1_:Vector.<Survivor> = this._raidData.getSurvivorList();
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_.length)
         {
            _loc3_ = _loc1_[_loc2_];
            if(_loc3_.loadoutOffence.weapon.item == null)
            {
               this.btn_launch.enabled = false;
               TooltipManager.getInstance().add(this.btn_launch,Language.getInstance().getString("raid.launch_tooltip_error_minsrv",this._raidData.minSurvivorCount),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
               return;
            }
            _loc2_++;
         }
         if(!this._raidData.hasStarted || this._raidData.currentStageIndex == 0)
         {
            _loc4_ = Network.getInstance().playerData.compound.resources.getAmount(GameResources.AMMUNITION);
            _loc5_ = MissionData.calculateAmmoCost(this._raidData.getSurvivorList());
            if(_loc4_ < _loc5_)
            {
               this.btn_launch.enabled = false;
               TooltipManager.getInstance().add(this.btn_launch,Language.getInstance().getString("raid.launch_tooltip_error_ammo"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
               return;
            }
         }
         this.btn_launch.enabled = true;
         TooltipManager.getInstance().add(this.btn_launch,Language.getInstance().getString("raid.launch_tooltip"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
      }
      
      private function launchRaid() : void
      {
         RaidSystem.launchRaid(this._raidData,function(param1:Boolean):void
         {
            if(param1)
            {
               close();
            }
         });
      }
      
      private function abandonRaid() : void
      {
         RaidSystem.abortRaid(this._raidData,function(param1:Boolean):void
         {
            if(param1)
            {
               close();
            }
         });
      }
      
      private function onSurvivorsChanged() : void
      {
         this.updateLaunchButtonState();
      }
      
      private function onClickLaunch(param1:MouseEvent) : void
      {
         var msg:RaidConfirmLaunchDialogue = null;
         var e:MouseEvent = param1;
         if(this._raidData.hasStarted)
         {
            this.launchRaid();
         }
         else
         {
            msg = new RaidConfirmLaunchDialogue();
            msg.onConfirm = function():void
            {
               launchRaid();
            };
            msg.open();
         }
      }
      
      private function onClickAbandon(param1:MouseEvent) : void
      {
         var msg:MessageBox = null;
         var e:MouseEvent = param1;
         if(this._raidData.hasStarted)
         {
            msg = new MessageBox(Language.getInstance().getString("raid.abandon_confirm_message"));
            msg.addTitle(Language.getInstance().getString("raid.abandon_confirm_title"),BaseDialogue.TITLE_COLOR_RUST);
            msg.addButton(Language.getInstance().getString("raid.abandon_confirm_cancel"));
            msg.addButton(Language.getInstance().getString("raid.abandon_confirm_ok")).clicked.addOnce(function(param1:MouseEvent):void
            {
               abandonRaid();
            });
            msg.open();
         }
         else
         {
            close();
         }
      }
      
      private function onCooldownCompleted(param1:Cooldown) : void
      {
         this._cooldown.completed.remove(this.onCooldownCompleted);
         this._cooldown = null;
         this.refresh();
      }
      
      private function onSurvivorLoadoutChanged() : void
      {
         this.ui_ammoView.invalidate();
      }
      
      private function onResourceChanged(param1:String, param2:int) : void
      {
         if(param1 == GameResources.AMMUNITION)
         {
            this.updateLaunchButtonState();
         }
      }
   }
}

