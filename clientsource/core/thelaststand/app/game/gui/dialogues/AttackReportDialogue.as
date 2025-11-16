package thelaststand.app.game.gui.dialogues
{
   import flash.display.Bitmap;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.AntiAliasType;
   import flash.utils.Dictionary;
   import thelaststand.app.core.Config;
   import thelaststand.app.data.NavigationLocation;
   import thelaststand.app.display.BasicTextField;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.events.NavigationEvent;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemFactory;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.Weapon;
   import thelaststand.app.game.gui.UIXPCounterBar;
   import thelaststand.app.game.gui.bounty.BountyMissionReportTeaser;
   import thelaststand.app.game.gui.mission.UIResourceLootReport;
   import thelaststand.app.game.gui.survivor.UISurvivorModelView;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.NetworkMessage;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class AttackReportDialogue extends BaseDialogue
   {
      
      private var _lang:Language;
      
      private var _attackData:Object;
      
      private var _survivorDisplayWidth:int = 204;
      
      private var _contentHeight:int = 300;
      
      private var _contentY:int = 8;
      
      private var _lootCount:Dictionary;
      
      private var _detailLines:Vector.<DetailLine>;
      
      private var _enemySurvivor:Survivor;
      
      private var mc_container:Sprite;
      
      private var mc_levelUp:Sprite;
      
      private var mc_injuries:Sprite;
      
      private var mc_modelView:UISurvivorModelView;
      
      private var mc_lootResources:UIResourceLootReport;
      
      private var btn_share:PushButton;
      
      private var btn_detail:PushButton;
      
      private var btn_ok:PushButton;
      
      private var btn_retaliate:PushButton;
      
      private var ui_xpCounter:UIXPCounterBar;
      
      private var mc_attackInfoContainer:Sprite;
      
      private var mc_detailsContainer:Sprite;
      
      private var bountyTeaser:BountyMissionReportTeaser;
      
      public function AttackReportDialogue(param1:Object)
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc7_:Item = null;
         var _loc8_:XML = null;
         var _loc9_:String = null;
         this._lang = Language.getInstance();
         this._attackData = param1;
         this.mc_container = new Sprite();
         super("attack-report",this.mc_container,true);
         _width = 568;
         _height = 336;
         _padding = 12;
         _autoSize = false;
         addTitle(this._lang.getString("attack_report_title_" + (this._attackData.win ? "success" : "failure")),this._attackData.win ? 7513127 : BaseDialogue.TITLE_COLOR_RUST);
         this._lootCount = new Dictionary(true);
         for each(_loc2_ in this._attackData.loot)
         {
            _loc7_ = ItemFactory.createItemFromObject(_loc2_);
            if(_loc7_.category == "resource")
            {
               for each(_loc8_ in _loc7_.xml.res.res)
               {
                  _loc9_ = _loc8_.@id.toString();
                  if(this._lootCount[_loc9_] == null)
                  {
                     this._lootCount[_loc9_] = 0;
                  }
                  this._lootCount[_loc9_] += int(_loc8_.toString()) * _loc7_.quantity;
               }
            }
         }
         this.drawSurvivorDisplay();
         this.drawAttackInfo();
         this.drawDetailsInfo();
         _loc3_ = this._survivorDisplayWidth + 14;
         _loc4_ = int(this._contentY + this._contentHeight - 26);
         _loc5_ = 18;
         this.btn_detail = new PushButton(this._lang.getString("attack_report_details"));
         this.btn_detail.clicked.add(this.onClickButton);
         this.btn_detail.width = 94;
         this.btn_detail.x = _loc3_;
         this.btn_detail.y = _loc4_;
         this.mc_container.addChild(this.btn_detail);
         _loc3_ = int(this.btn_detail.x + this.btn_detail.width + _loc5_);
         this.btn_ok = new PushButton(this._lang.getString("attack_report_ok"));
         this.btn_ok.clicked.add(this.onClickButton);
         this.btn_ok.width = 76;
         this.btn_ok.x = _loc3_;
         this.btn_ok.y = _loc4_;
         this.mc_container.addChild(this.btn_ok);
         this.btn_retaliate = new PushButton(this._lang.getString("attack_report_retaliate"),null,-1,null,7545099);
         this.btn_retaliate.clicked.add(this.onClickButton);
         this.btn_retaliate.width = 116;
         this.btn_retaliate.x = int(this.btn_ok.x + this.btn_ok.width + _loc5_);
         this.btn_retaliate.y = _loc4_;
         this.mc_container.addChild(this.btn_retaliate);
         var _loc6_:int = int(Config.constant.BOUNTY_MIN_LEVEL);
         if(Network.getInstance().playerData.getPlayerSurvivor().level >= _loc6_ && this._attackData.attackerLevel >= _loc6_)
         {
            this.bountyTeaser = new BountyMissionReportTeaser(this._attackData.attackerId);
            this.bountyTeaser.x = int((_width - this.bountyTeaser.width) * 0.5) + 4;
            this.bountyTeaser.y = -this.bountyTeaser.height - 30;
            this.mc_container.addChild(this.bountyTeaser);
            offset.y = int(this.bountyTeaser.height * 0.5) - 10;
         }
         this.mc_container.addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         this.mc_container.addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      override public function dispose() : void
      {
         var _loc2_:DetailLine = null;
         var _loc3_:BasicTextField = null;
         super.dispose();
         this._lang = null;
         if(this._enemySurvivor != null)
         {
            this._enemySurvivor.dispose();
         }
         this.mc_lootResources.dispose();
         this.mc_lootResources = null;
         this.mc_modelView.dispose();
         this.mc_modelView = null;
         this.ui_xpCounter.dispose();
         this.ui_xpCounter = null;
         if(this.btn_share != null)
         {
            this.btn_share.dispose();
            this.btn_share = null;
         }
         this.btn_detail.dispose();
         this.btn_detail = null;
         this.btn_ok.dispose();
         this.btn_ok = null;
         this.btn_retaliate.dispose();
         this.btn_retaliate = null;
         var _loc1_:int = this.mc_container.numChildren - 1;
         while(_loc1_ >= 0)
         {
            _loc3_ = this.mc_container.getChildAt(_loc1_) as BasicTextField;
            if(_loc3_ != null)
            {
               _loc3_.dispose();
            }
            _loc1_--;
         }
         for each(_loc2_ in this._detailLines)
         {
            _loc2_.dispose();
         }
         if(this.bountyTeaser)
         {
            this.bountyTeaser.dispose();
         }
      }
      
      private function drawSurvivorDisplay() : void
      {
         var _loc5_:BodyTextField = null;
         GraphicUtils.drawUIBlock(this.mc_container.graphics,this._survivorDisplayWidth,this._contentHeight,0,this._contentY);
         this.mc_modelView = new UISurvivorModelView(this._survivorDisplayWidth - 2,220);
         this.mc_modelView.x = 1;
         this.mc_modelView.y = int(this._contentY + (this._contentHeight - this.mc_modelView.height) * 0.5 - 10);
         this.mc_modelView.actorMesh.scaleX = this.mc_modelView.actorMesh.scaleY = this.mc_modelView.actorMesh.scaleZ = 1.2;
         this.mc_modelView.cameraPosition.y = -40;
         this.mc_modelView.showWeapon = true;
         this.mc_container.addChild(this.mc_modelView);
         var _loc1_:Shape = new Shape();
         _loc1_.graphics.beginFill(0,0.7);
         _loc1_.graphics.drawRect(0,0,this.mc_modelView.width,this.mc_modelView.height);
         _loc1_.graphics.endFill();
         _loc1_.x = this.mc_modelView.x;
         _loc1_.y = this.mc_modelView.y;
         this.mc_modelView.mask = _loc1_;
         this.mc_container.addChild(_loc1_);
         var _loc2_:int = 4;
         var _loc3_:int = 25;
         var _loc4_:int = this._contentY + this._contentHeight - _loc3_ - _loc2_;
         this.mc_container.graphics.beginFill(0,0.7);
         this.mc_container.graphics.drawRect(_loc2_,_loc4_,this._survivorDisplayWidth - _loc2_ * 2,_loc3_);
         this.mc_container.graphics.endFill();
         _loc5_ = new BodyTextField({
            "color":16166400,
            "bold":true,
            "size":13
         });
         _loc5_.text = this._lang.getString("level",this._attackData.attackerLevel + 1).toUpperCase();
         _loc5_.x = int(this._survivorDisplayWidth - _loc2_ - _loc5_.width - 4);
         _loc5_.y = int(_loc4_ + (_loc3_ - _loc5_.height) * 0.5);
         this.mc_container.addChild(_loc5_);
      }
      
      private function drawAttackInfo() : void
      {
         var _loc3_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:Sprite = null;
         var _loc23_:Bitmap = null;
         var _loc1_:int = 10;
         var _loc2_:int = this._survivorDisplayWidth + _loc1_;
         _loc3_ = this._contentY;
         var _loc4_:int = _width - this._survivorDisplayWidth - _loc1_ - _padding * 2;
         this.mc_attackInfoContainer = new Sprite();
         this.mc_container.addChild(this.mc_attackInfoContainer);
         GraphicUtils.drawUIBlock(this.mc_attackInfoContainer.graphics,_loc4_,40,_loc2_,_loc3_);
         var _loc5_:int = int(new Date(new Date().time - this._attackData.date.time).time) / 1000;
         var _loc6_:String = this._lang.getString("attack_report_attackedby_time",DateTimeUtils.secondsToString(_loc5_,true));
         var _loc7_:BodyTextField = new BodyTextField({
            "color":9078920,
            "size":14,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         _loc7_.htmlText = this._lang.getString("attack_report_attackedby",this._attackData.attackerName,_loc6_);
         _loc7_.x = _loc2_ + 6;
         _loc7_.maxWidth = int(_loc4_ - _loc7_.x * 2);
         _loc7_.y = int(_loc3_ + (40 - _loc7_.height) * 0.5);
         this.mc_attackInfoContainer.addChild(_loc7_);
         _loc3_ += 70;
         this.ui_xpCounter = new UIXPCounterBar(_loc4_,26);
         this.ui_xpCounter.x = _loc2_;
         this.ui_xpCounter.y = _loc3_;
         this.ui_xpCounter.levelMax = Network.getInstance().playerData.getPlayerSurvivor().levelMax;
         this.ui_xpCounter.startXP = int(this._attackData.startXP);
         this.ui_xpCounter.startLevel = int(this._attackData.startLevel);
         this.ui_xpCounter.endXP = int(this._attackData.endXP);
         this.ui_xpCounter.endLevel = int(this._attackData.endLevel);
         this.ui_xpCounter.xpTotal = int(this._attackData.xpEarned);
         this.mc_attackInfoContainer.addChild(this.ui_xpCounter);
         _loc3_ += 36;
         GraphicUtils.drawUIBlock(this.mc_attackInfoContainer.graphics,_loc4_,64,_loc2_,_loc3_);
         var _loc8_:int = 4;
         var _loc9_:int = _loc4_ - _loc8_ * 2;
         this.mc_attackInfoContainer.graphics.beginFill(5708828);
         this.mc_attackInfoContainer.graphics.drawRect(_loc2_ + _loc8_,_loc3_ + _loc8_,_loc9_,21);
         this.mc_attackInfoContainer.graphics.endFill();
         var _loc10_:BodyTextField = new BodyTextField({
            "color":13381383,
            "size":14,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         _loc10_.text = this._lang.getString("attack_report_stolen",this._attackData.attackerName);
         _loc10_.maxWidth = _loc9_;
         _loc10_.x = int(_loc2_ + _loc8_ + (_loc4_ - _loc10_.width) * 0.5);
         _loc10_.y = int(_loc3_ + _loc8_ + (21 - _loc10_.height) * 0.5);
         this.mc_attackInfoContainer.addChild(_loc10_);
         var _loc11_:int = _loc3_ + 21 + _loc8_ * 2;
         this.mc_attackInfoContainer.graphics.beginFill(3750201);
         this.mc_attackInfoContainer.graphics.drawRect(_loc2_ + _loc8_,_loc11_,_loc9_,30);
         this.mc_attackInfoContainer.graphics.endFill();
         this.mc_lootResources = new UIResourceLootReport(this._lootCount,true);
         this.mc_lootResources.x = int(_loc2_ + _loc8_ + 10);
         this.mc_lootResources.width = int(_width - _padding * 2 - this.mc_lootResources.x - _loc8_ - 10);
         this.mc_lootResources.scaleY = this.mc_lootResources.scaleX;
         this.mc_lootResources.y = int(_loc11_ + 15);
         this.mc_attackInfoContainer.addChild(this.mc_lootResources);
         _loc3_ += 72;
         _loc12_ = 34;
         GraphicUtils.drawUIBlock(this.mc_attackInfoContainer.graphics,_loc4_,_loc12_,_loc2_,_loc3_);
         _loc13_ = new Sprite();
         this.mc_attackInfoContainer.addChild(_loc13_);
         var _loc14_:Bitmap = new Bitmap(new BmpIconLevelUps());
         _loc13_.addChild(_loc14_);
         var _loc15_:BodyTextField = new BodyTextField({
            "color":16777215,
            "size":14,
            "bold":true
         });
         _loc15_.text = this._lang.getString("mission_report_leveled_up",int(this._attackData.levelUps));
         _loc15_.x = int(_loc14_.x + _loc14_.width + 4);
         _loc15_.y = int(_loc14_.y + (_loc14_.height - _loc15_.height) * 0.5);
         _loc13_.addChild(_loc15_);
         var _loc16_:Sprite = new Sprite();
         this.mc_attackInfoContainer.addChild(_loc16_);
         var _loc17_:Bitmap = new Bitmap(new BmpIconInjuries());
         _loc16_.addChild(_loc17_);
         var _loc18_:int = this._attackData.hasOwnProperty("numSrvDown") ? int(this._attackData.numSrvDown) : (this._attackData.srvDown is Array ? int(this._attackData.srvDown.length) : 0);
         var _loc19_:BodyTextField = new BodyTextField({
            "color":(_loc18_ > 0 ? Effects.COLOR_WARNING : 16777215),
            "size":14,
            "bold":true
         });
         _loc19_.text = this._lang.getString("mission_report_injuries",_loc18_);
         _loc19_.x = int(_loc17_.x + _loc17_.width + 4);
         _loc19_.y = int(_loc17_.y + (_loc17_.height - _loc19_.height) * 0.5);
         _loc16_.addChild(_loc19_);
         _loc13_.x = _loc2_ + 8;
         _loc13_.y = Math.round(_loc3_ + (_loc12_ - _loc13_.height) * 0.5);
         _loc16_.x = int(_loc2_ + _loc4_ - 6 - _loc16_.width);
         _loc16_.y = Math.round(_loc3_ + (_loc12_ - _loc16_.height) * 0.5);
         _loc3_ += 42;
         GraphicUtils.drawUIBlock(this.mc_attackInfoContainer.graphics,_loc4_,_loc12_,_loc2_,_loc3_);
         var _loc20_:int = int(this._attackData.protection);
         var _loc21_:Sprite = new Sprite();
         this.mc_attackInfoContainer.addChild(_loc21_);
         var _loc22_:BodyTextField = new BodyTextField({
            "color":Effects.COLOR_GOOD,
            "size":13,
            "bold":true
         });
         if(_loc20_ > 0)
         {
            _loc23_ = new Bitmap(new BmpIconDamageProtection());
            _loc21_.addChild(_loc23_);
            _loc22_.text = this._lang.getString("mission_report_protection",DateTimeUtils.secondsToString(_loc20_,true));
            _loc22_.x = int(_loc23_.x + _loc23_.width + 4);
            _loc22_.y = int(_loc23_.y + (_loc23_.height - _loc22_.height) * 0.5);
         }
         else
         {
            _loc22_.text = this._lang.getString("mission_report_protection_no");
         }
         _loc21_.addChild(_loc22_);
         _loc21_.x = int(_loc2_ + (_loc4_ - _loc21_.width) * 0.5);
         _loc21_.y = Math.round(_loc3_ + (_loc12_ - _loc21_.height) * 0.5);
      }
      
      private function drawDetailsInfo() : void
      {
         var _loc11_:DetailLine = null;
         var _loc1_:int = 10;
         var _loc2_:int = this._survivorDisplayWidth + _loc1_;
         var _loc3_:int = this._contentY;
         var _loc4_:int = _width - this._survivorDisplayWidth - _loc1_ - _padding * 2;
         this.mc_detailsContainer = new Sprite();
         GraphicUtils.drawUIBlock(this.mc_detailsContainer.graphics,_loc4_,this._contentHeight - 39,_loc2_,_loc3_);
         var _loc5_:Number = _loc2_ + 4;
         var _loc6_:Number = _loc3_ + 4;
         this._detailLines = new Vector.<DetailLine>();
         var _loc7_:int = this._attackData.srvDown != null ? int(this._attackData.srvDown.length) : 0;
         var _loc8_:Array = [this._lang.getString("attack_report_attackersKilled"),String(this._attackData.attackerInjured),this._lang.getString("attack_report_survivorsDowned"),this._attackData.numSrvDown != null ? String(this._attackData.numSrvDown) : _loc7_.toString(),this._lang.getString("attack_report_buildingsLooted"),String(this._attackData.bldLooted),this._lang.getString("attack_report_buildingsDestroyed"),this._attackData.destBlds != null ? String(this._attackData.destBlds.length) : "0",this._lang.getString("attack_report_trapsDisarmed"),String(this._attackData.trpDism),this._lang.getString("attack_report_trapsTriggered"),String(this._attackData.trpTrig)];
         var _loc9_:* = false;
         var _loc10_:int = 0;
         while(_loc10_ < _loc8_.length)
         {
            _loc11_ = new DetailLine(_loc4_ - 8,_loc8_[_loc10_],_loc8_[_loc10_ + 1],_loc9_);
            _loc11_.x = _loc5_;
            _loc11_.y = _loc6_;
            this.mc_detailsContainer.addChild(_loc11_);
            _loc6_ += _loc11_.height;
            _loc9_ = !_loc9_;
            _loc10_ += 2;
         }
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         var e:Event = param1;
         this.ui_xpCounter.animate();
         this.mc_modelView.showLoader();
         Network.getInstance().send(NetworkMessage.GET_PLAYER_SURVIVOR,{
            "id":this._attackData.attackerId,
            "weapon":true
         },function(param1:Object):void
         {
            if(param1 == null || mc_container.stage == null)
            {
               return;
            }
            if(!param1.survivor)
            {
               return;
            }
            _enemySurvivor = new Survivor();
            _enemySurvivor.readObject(param1.survivor);
            if(param1.weapon != null)
            {
               _enemySurvivor.loadoutOffence.weapon.item = ItemFactory.createItemFromObject(param1.weapon) as Weapon;
            }
            mc_modelView.survivor = _enemySurvivor;
         });
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
      }
      
      private function onClickButton(param1:MouseEvent) : void
      {
         var _loc2_:AttackReportLogDialogue = null;
         switch(param1.currentTarget)
         {
            case this.btn_ok:
               close();
               break;
            case this.btn_retaliate:
               this.mc_container.dispatchEvent(new NavigationEvent(NavigationEvent.REQUEST,NavigationLocation.WORLD_MAP,this._attackData.attackerId));
               close();
               break;
            case this.btn_detail:
               if(this._attackData.hasOwnProperty("log"))
               {
                  _loc2_ = new AttackReportLogDialogue(this._attackData);
                  _loc2_.open();
                  return;
               }
               if(this.mc_attackInfoContainer.parent)
               {
                  this.mc_container.removeChild(this.mc_attackInfoContainer);
                  this.mc_container.addChild(this.mc_detailsContainer);
                  this.btn_detail.label = this._lang.getString("attack_report_overview");
                  break;
               }
               this.mc_container.removeChild(this.mc_detailsContainer);
               this.mc_container.addChild(this.mc_attackInfoContainer);
               this.btn_detail.label = this._lang.getString("attack_report_details");
         }
      }
   }
}

import flash.display.Sprite;
import flash.text.AntiAliasType;
import thelaststand.app.display.BodyTextField;
import thelaststand.app.display.Effects;

class DetailLine extends Sprite
{
   
   private var txt_label:BodyTextField;
   
   private var txt_value:BodyTextField;
   
   public function DetailLine(param1:Number, param2:String, param3:String, param4:Boolean)
   {
      super();
      graphics.beginFill(1447446,param4 ? 0 : 1);
      graphics.drawRect(0,0,param1,25);
      this.txt_label = new BodyTextField({
         "color":13381383,
         "size":14,
         "bold":true,
         "filters":[Effects.TEXT_SHADOW_DARK],
         "antiAliasType":AntiAliasType.ADVANCED
      });
      this.txt_label.x = 10;
      this.txt_label.y = 2;
      this.txt_label.text = param2;
      addChild(this.txt_label);
      this.txt_value = new BodyTextField({
         "color":13381383,
         "size":14,
         "bold":true,
         "filters":[Effects.TEXT_SHADOW_DARK],
         "antiAliasType":AntiAliasType.ADVANCED
      });
      this.txt_value.text = param3;
      this.txt_value.y = 2;
      this.txt_value.x = param1 - this.txt_value.width - 10;
      addChild(this.txt_value);
   }
   
   public function dispose() : void
   {
      this.txt_label.dispose();
      this.txt_value.dispose();
   }
}
