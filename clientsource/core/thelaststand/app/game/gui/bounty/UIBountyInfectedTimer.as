package thelaststand.app.game.gui.bounty
{
   import com.quasimondo.geom.ColorMatrix;
   import flash.display.Bitmap;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.ColorTransform;
   import flash.utils.Timer;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.bounty.InfectedBounty;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.BusyDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.gui.dialogues.DialogueManager;
   import thelaststand.common.lang.Language;
   
   public class UIBountyInfectedTimer extends UIComponent
   {
      
      public const STATE_INACTIVE:uint = 0;
      
      public const STATE_ACTIVE:uint = 1;
      
      public const STATE_COMPLETE:uint = 2;
      
      public const STATE_COUNTDOWN:uint = 3;
      
      private const color_countdown:uint = 12984609;
      
      private const color_completed:uint = 12511349;
      
      private var _width:int;
      
      private var _height:int;
      
      private var _timer:Timer;
      
      private var _bounty:InfectedBounty;
      
      private var _state:uint = 0;
      
      private var bmp_timerIcon:Bitmap;
      
      private var bmp_background:Bitmap;
      
      private var txt_timer:BodyTextField;
      
      private var btn_requestNew:PushButton;
      
      private var btn_abandon:PushButton;
      
      public function UIBountyInfectedTimer()
      {
         super();
         this.bmp_background = new Bitmap(new BmpBountyTimeRemainingBG(),"auto",true);
         addChild(this.bmp_background);
         this.bmp_timerIcon = new Bitmap(new BmpIconSearchTimer());
         var _loc1_:ColorMatrix = new ColorMatrix();
         _loc1_.colorize(this.color_countdown);
         this.bmp_timerIcon.filters = [_loc1_.filter];
         addChild(this.bmp_timerIcon);
         this.txt_timer = new BodyTextField({
            "color":this.color_countdown,
            "size":18,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         this.txt_timer.text = " ";
         addChild(this.txt_timer);
         this.btn_requestNew = new PushButton(Language.getInstance().getString("bounty.infected_request_new"));
         this.btn_requestNew.backgroundColor = 4226049;
         this.btn_requestNew.clicked.add(this.onClickRequestNew);
         this.btn_requestNew.visible = false;
         addChild(this.btn_requestNew);
         this.btn_abandon = new PushButton(Language.getInstance().getString("bounty.infected_abandon"),new BmpIconButtonClose());
         this.btn_abandon.iconBackgroundColor = Effects.COLOR_WARNING;
         this.btn_abandon.clicked.add(this.onClickAbandon);
         this.btn_abandon.visible = false;
         this.btn_abandon.width = 140;
         addChild(this.btn_abandon);
         this._timer = new Timer(500);
         this._timer.addEventListener(TimerEvent.TIMER,this.onTimerTick,false,0,true);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      public function get bounty() : InfectedBounty
      {
         return this._bounty;
      }
      
      public function set bounty(param1:InfectedBounty) : void
      {
         if(this._bounty != null)
         {
            this._bounty.completed.remove(this.onBountyCompleted);
            this._bounty = null;
         }
         this._bounty = param1;
         if(this._bounty != null)
         {
            this._bounty.completed.addOnce(this.onBountyCompleted);
         }
         this.updateStateFromBounty();
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
         this._width = param1;
         invalidate();
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
         this._height = param1;
         invalidate();
      }
      
      override public function dispose() : void
      {
         super.dispose();
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
         this.btn_requestNew.dispose();
         this.btn_abandon.dispose();
         this.bmp_background.bitmapData.dispose();
         this.bmp_timerIcon.bitmapData.dispose();
         this.txt_timer.dispose();
         if(this._bounty != null)
         {
            this._bounty.completed.remove(this.onBountyCompleted);
            this._bounty = null;
         }
      }
      
      override protected function draw() : void
      {
         graphics.clear();
         GraphicUtils.drawUIBlock(graphics,this._width,this._height);
         this.bmp_background.width = this._width - 2;
         this.bmp_background.height = this._height - 2;
         this.bmp_background.x = this.bmp_background.y = 1;
         if(this._state == this.STATE_INACTIVE)
         {
            this.bmp_background.transform.colorTransform = new ColorTransform();
            this.bmp_timerIcon.visible = false;
            this.txt_timer.visible = false;
            this.btn_requestNew.visible = false;
            this.btn_abandon.visible = false;
         }
         else if(this._state == this.STATE_COMPLETE)
         {
            this.bmp_background.transform.colorTransform = new ColorTransform(0.4,0.75,0,1,10,20,0);
            this.bmp_timerIcon.visible = false;
            this.btn_requestNew.visible = false;
            this.btn_abandon.visible = false;
            this.txt_timer.visible = true;
            this.txt_timer.text = Language.getInstance().getString("bounty.infected_time_complete");
            this.txt_timer.textColor = this.color_completed;
            this.txt_timer.x = int((this._width - this.txt_timer.width) * 0.5);
         }
         else if(this._state == this.STATE_COUNTDOWN)
         {
            this.bmp_background.transform.colorTransform = new ColorTransform(1,0,0,1,5);
            this.bmp_timerIcon.visible = true;
            this.txt_timer.visible = true;
            this.btn_abandon.visible = false;
            this.updateCountdown();
         }
         else if(this._state == this.STATE_ACTIVE)
         {
            this.bmp_background.transform.colorTransform = new ColorTransform(0.4,0.75,0,1,10,20,0);
            this.bmp_timerIcon.visible = false;
            this.btn_requestNew.visible = false;
            this.btn_abandon.visible = true;
            this.txt_timer.visible = true;
            this.txt_timer.text = Language.getInstance().getString("bounty.infected_time_active");
            this.txt_timer.textColor = this.color_completed;
            this.txt_timer.x = 14;
            this.btn_abandon.x = int(this._width - this.btn_abandon.width - 14);
            this.btn_abandon.y = int((this._height - this.btn_abandon.height) * 0.5);
         }
         this.bmp_timerIcon.y = int((this._height - this.bmp_timerIcon.height) * 0.5);
         this.txt_timer.y = int((this._height - this.txt_timer.height) * 0.5);
         this.btn_requestNew.width = int(this._width * 0.5);
         this.btn_requestNew.height = 28;
         this.btn_requestNew.x = int((this._width - this.btn_requestNew.width) * 0.5);
         this.btn_requestNew.y = int((this._height - this.btn_requestNew.height) * 0.5);
      }
      
      private function updateCountdown() : void
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc1_:Number = Network.getInstance().playerData.timeUntilNextInfectedBounty;
         if(_loc1_ <= 0)
         {
            this.txt_timer.visible = false;
            this.bmp_timerIcon.visible = false;
            this.btn_requestNew.visible = true;
            this.bmp_background.transform.colorTransform = new ColorTransform(0.4,0.75,0,1,10,20,0);
            this._timer.stop();
         }
         else
         {
            _loc2_ = DateTimeUtils.secondsToString(_loc1_,true,true);
            this.txt_timer.text = Language.getInstance().getString("bounty.infected_time_next",_loc2_);
            this.txt_timer.textColor = this.color_countdown;
            _loc3_ = 2;
            _loc4_ = int(this.bmp_timerIcon.width + _loc3_ + this.txt_timer.width);
            this.bmp_timerIcon.x = int((this._width - _loc4_) * 0.5);
            this.txt_timer.x = int(this.bmp_timerIcon.x + this.bmp_timerIcon.width + _loc3_);
            this.btn_requestNew.visible = false;
         }
      }
      
      private function requestAbandonBounty() : void
      {
         var msg:MessageBox;
         var cost:int = 0;
         var lang:Language = Language.getInstance();
         var strMsg:String = lang.getString("bounty.infected_abandon_confirm_msg");
         var player:PlayerData = Network.getInstance().playerData;
         if(player.timeUntilNextInfectedBounty > 0)
         {
            cost = int(Network.getInstance().data.costTable.getItemByKey("SpeedUpInfectedBounty").PriceCoins);
            strMsg += "<br/><br/>" + lang.getString("bounty.infected_abandon_confirm_fuel",cost);
         }
         msg = new MessageBox(strMsg);
         msg.addTitle(lang.getString("bounty.infected_abandon_confirm_title"),BaseDialogue.TITLE_COLOR_RUST);
         msg.addButton(lang.getString("bounty.infected_abandon_confirm_ok")).clicked.addOnce(function(param1:MouseEvent):void
         {
            abandonBounty();
         });
         msg.addButton(lang.getString("bounty.infected_abandon_confirm_cancel"));
         msg.open();
      }
      
      private function abandonBounty() : void
      {
         var busyMsg:BusyDialogue = null;
         busyMsg = new BusyDialogue(Language.getInstance().getString("bounty.infected_abandoning"));
         busyMsg.open();
         Network.getInstance().save(null,SaveDataMethod.BOUNTY_ABANDON,function(param1:Object):void
         {
            var _loc3_:MessageBox = null;
            var _loc4_:Date = null;
            busyMsg.close();
            if(param1 == null || param1.success !== true)
            {
               _loc3_ = new MessageBox(Language.getInstance().getString("bounty.infected_speedup_error_msg"));
               _loc3_.addTitle(Language.getInstance().getString("bounty.infected_speedup_error_title"),BaseDialogue.TITLE_COLOR_RUST);
               _loc3_.addButton(Language.getInstance().getString("bounty.infected_speedup_error_ok"));
               _loc3_.open();
               return;
            }
            var _loc2_:PlayerData = Network.getInstance().playerData;
            if(_loc2_.infectedBounty != null)
            {
               _loc2_.infectedBounty.abandon();
            }
            if(param1.nextIssue != null)
            {
               _loc4_ = new Date(param1.nextIssue);
               _loc2_.nextInfectedBountyIssueTime = _loc4_;
            }
            if(param1.bounty != null)
            {
               _loc2_.infectedBounty = new InfectedBounty(param1.bounty);
            }
            DialogueManager.getInstance().closeDialogue("bounty-office");
         });
      }
      
      private function requestNewBounty() : void
      {
         var busyMsg:BusyDialogue = null;
         busyMsg = new BusyDialogue(Language.getInstance().getString("bounty.infected_speedup_busy"));
         busyMsg.open();
         Network.getInstance().save(null,SaveDataMethod.BOUNTY_NEW,function(param1:Object):void
         {
            var _loc3_:MessageBox = null;
            var _loc4_:Date = null;
            busyMsg.close();
            if(param1 == null || param1.success !== true || param1.bounty == null)
            {
               _loc3_ = new MessageBox(Language.getInstance().getString("bounty.infected_speedup_error_msg"));
               _loc3_.addTitle(Language.getInstance().getString("bounty.infected_speedup_error_title"),BaseDialogue.TITLE_COLOR_RUST);
               _loc3_.addButton(Language.getInstance().getString("bounty.infected_speedup_error_ok"));
               _loc3_.open();
               return;
            }
            var _loc2_:PlayerData = Network.getInstance().playerData;
            if(param1.nextIssue != null)
            {
               _loc4_ = new Date(param1.nextIssue);
               _loc2_.nextInfectedBountyIssueTime = _loc4_;
            }
            if(param1.bounty != null)
            {
               _loc2_.infectedBounty = new InfectedBounty(param1.bounty);
            }
         });
      }
      
      private function updateStateFromBounty() : void
      {
         var _loc1_:Boolean = false;
         if(this._bounty == null)
         {
            this._state = this.STATE_INACTIVE;
         }
         else if(this._bounty.isAbandoned)
         {
            this._state = this.STATE_COUNTDOWN;
         }
         else if(this._bounty.isCompleted)
         {
            _loc1_ = this._bounty.rewardItemId != null ? Network.getInstance().playerData.inventory.getItemById(this._bounty.rewardItemId) == null : false;
            this._state = _loc1_ ? this.STATE_COUNTDOWN : this.STATE_COMPLETE;
         }
         else
         {
            this._state = this.STATE_ACTIVE;
         }
         if(this._state == this.STATE_COUNTDOWN)
         {
            this._timer.reset();
            this._timer.start();
         }
         else
         {
            this._timer.stop();
         }
         invalidate();
      }
      
      private function onTimerTick(param1:TimerEvent) : void
      {
         this.updateCountdown();
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         if(this._bounty != null)
         {
            this.updateStateFromBounty();
         }
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         this._timer.stop();
      }
      
      private function onBountyCompleted(param1:InfectedBounty) : void
      {
         this.updateStateFromBounty();
      }
      
      private function onClickRequestNew(param1:MouseEvent) : void
      {
         this.requestNewBounty();
      }
      
      private function onClickAbandon(param1:MouseEvent) : void
      {
         this.requestAbandonBounty();
      }
   }
}

