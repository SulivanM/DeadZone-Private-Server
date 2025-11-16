package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Timer;
   import org.osflash.signals.Signal;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.data.Currency;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.effects.Cooldown;
   import thelaststand.app.game.data.effects.CooldownType;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class LeaderRetrainDialogue extends BaseDialogue
   {
      
      private var _retrainCostData:Object;
      
      private var _cooldown:Cooldown;
      
      private var _cooldownRect:Rectangle;
      
      private var _cooldownTimer:Timer;
      
      private var btnRetrain:PurchasePushButton;
      
      private var mc_container:Sprite;
      
      private var ui_image:UIImage;
      
      private var txt_message:BodyTextField;
      
      private var txt_cooldownMsg:BodyTextField;
      
      private var txt_cooldownTime:BodyTextField;
      
      private var mc_time:Sprite;
      
      private var mc_cooldownHitArea:Sprite;
      
      public var resetSuccessful:Signal;
      
      public function LeaderRetrainDialogue()
      {
         var _loc1_:Language = null;
         this.resetSuccessful = new Signal();
         this.mc_container = new Sprite();
         super("leaderRetrain",this.mc_container,true);
         _loc1_ = Language.getInstance();
         _autoSize = false;
         _width = 430;
         this._retrainCostData = Network.getInstance().data.costTable.getItemByKey("AttributeReset");
         addTitle(_loc1_.getString("retrain_leader_title"),BaseDialogue.TITLE_COLOR_GREY);
         addButton(_loc1_.getString("retrain_leader_cancel"));
         var _loc2_:int = int(this._retrainCostData.costPerLevel * Network.getInstance().playerData.getPlayerSurvivor().level);
         var _loc3_:* = Network.getInstance().loginFlags.leaderResets == 0;
         this.btnRetrain = PurchasePushButton(addButton(_loc1_.getString("retrain_leader_ok") + (_loc3_ ? " - " + _loc1_.getString("free").toUpperCase() : ""),false,{
            "buttonClass":PurchasePushButton,
            "width":160
         }));
         this.btnRetrain.currency = Currency.FUEL;
         this.btnRetrain.cost = _loc3_ ? 0 : _loc2_;
         this.btnRetrain.clicked.add(this.onClickRetrain);
         var _loc4_:int = int(_padding * 0.5);
         this.ui_image = new UIImage(108,164);
         this.ui_image.x = 1;
         this.ui_image.y = _loc4_ + 1;
         this.ui_image.uri = "images/ui/retrain.jpg";
         this.mc_container.addChild(this.ui_image);
         GraphicUtils.drawUIBlock(this.mc_container.graphics,this.ui_image.width + 2,this.ui_image.height + 2,0,_loc4_);
         this.txt_message = new BodyTextField({
            "color":16777215,
            "size":14,
            "leading":1,
            "multiline":true
         });
         this.txt_message.htmlText = _loc1_.getString("retrain_leader_msg");
         this.txt_message.filters = [Effects.TEXT_SHADOW];
         this.txt_message.x = int(this.ui_image.x + this.ui_image.width + 8);
         this.txt_message.y = _loc4_;
         this.txt_message.width = int(_width - this.txt_message.x - _padding * 2);
         this.mc_container.addChild(this.txt_message);
         var _loc5_:int = int(this.txt_message.y + this.txt_message.height + 16);
         this._cooldownRect = new Rectangle(int(this.txt_message.x),_loc5_,int(this.txt_message.width),60);
         GraphicUtils.drawUIBlock(this.mc_container.graphics,this._cooldownRect.width,this._cooldownRect.height,this._cooldownRect.x,this._cooldownRect.y);
         this.mc_cooldownHitArea = new Sprite();
         this.mc_cooldownHitArea.graphics.beginFill(0,0);
         this.mc_cooldownHitArea.graphics.drawRect(0,0,this._cooldownRect.width,this._cooldownRect.height);
         this.mc_cooldownHitArea.graphics.endFill();
         this.mc_cooldownHitArea.x = this._cooldownRect.x;
         this.mc_cooldownHitArea.y = this._cooldownRect.y;
         this.mc_container.addChild(this.mc_cooldownHitArea);
         this.mc_time = new IconTime();
         this.txt_cooldownMsg = new BodyTextField({
            "size":14,
            "bold":true
         });
         this.txt_cooldownTime = new BodyTextField({
            "size":20,
            "bold":true
         });
         this.mc_container.addChild(this.mc_time);
         this.mc_container.addChild(this.txt_cooldownMsg);
         this.mc_container.addChild(this.txt_cooldownTime);
         this.drawCooldownInfo();
         _height = int(this.ui_image.y + this.ui_image.height + _padding * 2 + 6);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         TooltipManager.getInstance().removeAllFromParent(sprite);
         this.resetSuccessful.removeAll();
         this.ui_image.dispose();
         this.txt_message.dispose();
         this.txt_cooldownMsg.dispose();
         this.txt_cooldownTime.dispose();
         if(this._cooldown != null)
         {
            this._cooldown.completed.remove(this.onCooldownCompleted);
         }
         if(this._cooldownTimer != null)
         {
            this._cooldownTimer.stop();
         }
      }
      
      private function drawCooldownInfo() : void
      {
         var _loc2_:int = 0;
         var _loc4_:String = null;
         var _loc1_:int = 6;
         this._cooldown = Network.getInstance().playerData.cooldowns.getByType(CooldownType.ResetLeaderAttributes);
         if(this._cooldown == null || this._cooldown.timer.hasEnded())
         {
            this.txt_cooldownMsg.text = Language.getInstance().getString("retrain_leader_cooldown");
            this.txt_cooldownMsg.textColor = Effects.COLOR_NEUTRAL;
            _loc4_ = DateTimeUtils.secondsToString(int(this._retrainCostData.cooldown),false);
            this.txt_cooldownTime.text = _loc4_;
            this.txt_cooldownTime.textColor = Effects.COLOR_NEUTRAL;
            this.btnRetrain.enabled = true;
            this.updateTimerPositions();
            TooltipManager.getInstance().add(this.mc_cooldownHitArea,Language.getInstance().getString("retrain_leader_cooldown_tip",_loc4_),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
         }
         else
         {
            this.txt_cooldownMsg.text = Language.getInstance().getString("retrain_leader_cooldown_active");
            this.txt_cooldownMsg.textColor = Effects.COLOR_WARNING;
            this.txt_cooldownTime.textColor = Effects.COLOR_WARNING;
            this.btnRetrain.enabled = false;
            this._cooldown.completed.addOnce(this.onCooldownCompleted);
            this._cooldownTimer = new Timer(500);
            this._cooldownTimer.addEventListener(TimerEvent.TIMER,this.onCooldownTimerTick,false,0,true);
            this._cooldownTimer.start();
            this.onCooldownTimerTick(null);
            TooltipManager.getInstance().add(this.mc_cooldownHitArea,Language.getInstance().getString("retrain_leader_cooldown_active_tip"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
         }
         _loc2_ = 0;
         var _loc3_:int = this.txt_cooldownMsg.height + _loc2_ + this.txt_cooldownTime.height;
         this.txt_cooldownMsg.x = int(this._cooldownRect.x + (this._cooldownRect.width - this.txt_cooldownMsg.width) * 0.5);
         this.txt_cooldownMsg.y = int(this._cooldownRect.y + (this._cooldownRect.height - _loc3_) * 0.5);
         this.txt_cooldownTime.y = int(this.txt_cooldownMsg.y + this.txt_cooldownMsg.height + _loc2_);
         this.mc_time.y = int(this.txt_cooldownTime.y + (this.txt_cooldownTime.height - this.mc_time.height) * 0.5 + 2);
      }
      
      private function updateTimerPositions() : void
      {
         var _loc1_:int = 8;
         var _loc2_:int = this.mc_time.width + _loc1_ + this.txt_cooldownTime.width;
         this.mc_time.x = int(this._cooldownRect.x + (this._cooldownRect.width - _loc2_) * 0.5);
         this.txt_cooldownTime.x = int(this.mc_time.x + this.mc_time.width + _loc1_);
      }
      
      private function onCooldownTimerTick(param1:TimerEvent) : void
      {
         this.txt_cooldownTime.text = DateTimeUtils.secondsToString(this._cooldown.timer.getSecondsRemaining(),true,true);
         this.updateTimerPositions();
      }
      
      private function onCooldownCompleted(param1:Cooldown) : void
      {
         this._cooldown = null;
         this._cooldownTimer.stop();
         this._cooldownTimer = null;
         this.drawCooldownInfo();
      }
      
      private function onClickRetrain(param1:MouseEvent) : void
      {
         var lang:Language = null;
         var msg:MessageBox = null;
         var e:MouseEvent = param1;
         if(Network.getInstance().playerData.levelPoints > 0)
         {
            lang = Language.getInstance();
            msg = new MessageBox(lang.getString("retrain_leader_ptsremain_msg"));
            msg.addTitle(lang.getString("retrain_leader_ptsremain_title"));
            msg.addButton(lang.getString("retrain_leader_ptsremain_ok"),true,{"width":80});
            msg.open();
            Audio.sound.play("sound/interface/int-error.mp3");
            return;
         }
         Network.getInstance().playerData.resetLeaderAttributes(function(param1:Boolean):void
         {
            if(param1)
            {
               resetSuccessful.dispatch();
               close();
            }
         });
      }
   }
}

