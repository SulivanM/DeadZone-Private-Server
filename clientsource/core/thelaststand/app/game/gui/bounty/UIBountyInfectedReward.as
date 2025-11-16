package thelaststand.app.game.gui.bounty
{
   import com.greensock.TweenMax;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.CrateMysteryItem;
   import thelaststand.app.game.data.GameResources;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemFactory;
   import thelaststand.app.game.data.bounty.InfectedBounty;
   import thelaststand.app.game.data.bounty.InfectedBountyTask;
   import thelaststand.app.game.gui.UIUnavailableBanner;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.game.gui.dialogues.CrateMysteryUnlockDialogue;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.gui.UITitleBar;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.BusyDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.PaymentSystem;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class UIBountyInfectedReward extends UIComponent
   {
      
      private var _width:int;
      
      private var _height:int;
      
      private var _taskIcons:Vector.<UIBountyInfectedRewardTaskIcon>;
      
      private var _bounty:InfectedBounty;
      
      private var _rewardItem:CrateMysteryItem;
      
      private var _previewURI:String;
      
      private var _speedUpCost:int;
      
      private var _timer:Timer;
      
      private var mc_container:Sprite;
      
      private var ui_titleBar:UITitleBar;
      
      private var txt_title:BodyTextField;
      
      private var txt_desc:BodyTextField;
      
      private var btn_open:PushButton;
      
      private var mc_tasks:Sprite;
      
      private var ui_preview:UIImage;
      
      private var ui_previewBG:Sprite;
      
      private var ui_unavailable:UIUnavailableBanner;
      
      private var btn_speedUp:PurchasePushButton;
      
      public function UIBountyInfectedReward()
      {
         var _loc2_:UIBountyInfectedRewardTaskIcon = null;
         super();
         this._previewURI = ItemFactory.getItemDefinition("crate-bounty").preview.@uri.toString();
         this.mc_container = new Sprite();
         this.mc_container.mouseEnabled = false;
         addChild(this.mc_container);
         this.ui_previewBG = new Sprite();
         this.mc_container.addChild(this.ui_previewBG);
         this.ui_preview = new UIImage(250,218,0,1,true);
         this.mc_container.addChild(this.ui_preview);
         this.ui_titleBar = new UITitleBar(null,5135921);
         this.ui_titleBar.height = 32;
         this.ui_titleBar.filters = [Effects.TEXT_SHADOW_DARK];
         this.mc_container.addChild(this.ui_titleBar);
         this.txt_title = new BodyTextField({
            "color":12511349,
            "size":21,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         this.txt_title.text = Language.getInstance().getString("bounty.infected_reward_title").toUpperCase();
         this.mc_container.addChild(this.txt_title);
         this.txt_desc = new BodyTextField({
            "color":6455588,
            "size":14,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_desc.htmlText = Language.getInstance().getString("bounty.infected_reward_desc").toUpperCase();
         this.mc_container.addChild(this.txt_desc);
         this.mc_tasks = new Sprite();
         this.mc_container.addChild(this.mc_tasks);
         this._taskIcons = new Vector.<UIBountyInfectedRewardTaskIcon>(3);
         var _loc1_:int = 0;
         while(_loc1_ < this._taskIcons.length)
         {
            _loc2_ = new UIBountyInfectedRewardTaskIcon();
            this.mc_tasks.addChild(_loc2_);
            this._taskIcons[_loc1_] = _loc2_;
            _loc1_++;
         }
         this.btn_open = new PushButton(Language.getInstance().getString("bounty.infected_reward_claim"),null,-1,{
            "size":16,
            "bold":true
         });
         this.btn_open.clicked.add(this.onClickClaimReward);
         this.btn_open.width = 184;
         this.btn_open.height = 36;
         this.mc_container.addChild(this.btn_open);
         this.ui_unavailable = new UIUnavailableBanner();
         this._speedUpCost = int(Network.getInstance().data.costTable.getItemByKey("SpeedUpInfectedBounty").PriceCoins);
         this.btn_speedUp = new PurchasePushButton(Language.getInstance().getString("bounty.infected_speedup"),this._speedUpCost,true);
         this.btn_speedUp.clicked.add(this.onClickSpeedUp);
         this.btn_speedUp.width = 200;
         this._timer = new Timer(500,0);
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
            this._bounty.taskCompleted.remove(this.onBountyTaskCompleted);
            this._rewardItem = null;
         }
         this._bounty = param1;
         if(this._bounty != null)
         {
            this._bounty.completed.addOnce(this.onBountyCompleted);
            this._bounty.taskCompleted.add(this.onBountyTaskCompleted);
            if(this._bounty.rewardItemId != null)
            {
               this._rewardItem = Network.getInstance().playerData.inventory.getItemById(this._bounty.rewardItemId) as CrateMysteryItem;
               if(this._rewardItem != null)
               {
                  Network.getInstance().playerData.inventory.itemRemoved.add(this.onItemRemoved);
               }
            }
         }
         invalidate();
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
         TweenMax.killChildTweensOf(this);
         if(this._bounty != null)
         {
            this._bounty.completed.remove(this.onBountyCompleted);
            this._bounty.taskCompleted.remove(this.onBountyTaskCompleted);
         }
         this._timer.stop();
         this._rewardItem = null;
         Network.getInstance().playerData.inventory.itemRemoved.remove(this.onItemRemoved);
         this.ui_titleBar.dispose();
         this.txt_title.dispose();
         this.txt_desc.dispose();
         this.btn_open.dispose();
         this.ui_preview.dispose();
         this.ui_unavailable.dispose();
         this.btn_speedUp.dispose();
      }
      
      override protected function draw() : void
      {
         var _loc1_:Boolean = false;
         var _loc2_:int = 0;
         var _loc9_:InfectedBountyTask = null;
         var _loc10_:UIBountyInfectedRewardTaskIcon = null;
         var _loc11_:int = 0;
         _loc1_ = this._bounty.isCompleted && this._rewardItem == null;
         graphics.clear();
         GraphicUtils.drawUIBlock(graphics,this._width,this._height);
         this.ui_previewBG.graphics.clear();
         this.ui_previewBG.graphics.beginFill(0);
         this.ui_previewBG.graphics.drawRect(0,0,this._width - 6,this._height - 6);
         this.ui_previewBG.graphics.endFill();
         this.ui_previewBG.x = 3;
         this.ui_previewBG.y = 3;
         _loc2_ = 3;
         this.ui_titleBar.width = int(this._width - _loc2_ * 2);
         this.ui_titleBar.x = _loc2_;
         this.ui_titleBar.y = _loc2_;
         this.txt_title.x = int(this.ui_titleBar.x + (this.ui_titleBar.width - this.txt_title.width) * 0.5);
         this.txt_title.y = int(this.ui_titleBar.y + (this.ui_titleBar.height - this.txt_title.height) * 0.5);
         this.ui_preview.x = int((this._width - this.ui_preview.width) * 0.5);
         this.ui_preview.y = int(this.ui_titleBar.y + this.ui_titleBar.height - 14);
         this.txt_desc.x = int((this._width - this.txt_desc.width) * 0.5);
         this.txt_desc.y = int(this.ui_titleBar.y + this.ui_titleBar.height + 18);
         this.btn_open.y = int(this._height - this.btn_open.height - 24);
         this.btn_open.x = int((this._width - this.btn_open.width) * 0.5);
         this.btn_open.enabled = this._bounty != null ? this._bounty.isCompleted : false;
         this.btn_open.backgroundColor = this.btn_open.enabled ? 4226049 : 2960942;
         var _loc3_:int = 0;
         var _loc4_:int = 16;
         var _loc5_:int = 0;
         while(_loc5_ < this._taskIcons.length)
         {
            _loc9_ = this._bounty != null ? this._bounty.getTask(_loc5_) : null;
            _loc10_ = this._taskIcons[_loc5_];
            _loc10_.completed = _loc9_ != null ? _loc9_.isCompleted : Boolean(null);
            _loc10_.redraw();
            _loc10_.x = _loc3_;
            _loc3_ += int(_loc10_.width + _loc4_);
            _loc5_++;
         }
         this.mc_tasks.y = int(this._height - 164);
         this.mc_tasks.x = int((this._width - this.mc_tasks.width) * 0.5);
         this.mc_tasks.graphics.lineStyle(1,4013116,1,true);
         var _loc6_:int = 20;
         var _loc7_:int = int(_loc10_.height);
         _loc5_ = 0;
         while(_loc5_ < this._taskIcons.length)
         {
            _loc10_ = this._taskIcons[_loc5_];
            _loc11_ = int(_loc10_.x + _loc10_.width * 0.5);
            this.mc_tasks.graphics.moveTo(_loc11_,_loc7_);
            this.mc_tasks.graphics.lineTo(_loc11_,_loc7_ + _loc6_);
            _loc5_++;
         }
         var _loc8_:int = int(this.mc_tasks.width - _loc10_.width);
         _loc11_ = int(_loc10_.width * 0.5);
         this.mc_tasks.graphics.moveTo(_loc11_,_loc7_ + _loc6_);
         this.mc_tasks.graphics.lineTo(_loc11_ + _loc8_,_loc7_ + _loc6_);
         _loc11_ = int(this.mc_tasks.width * 0.5);
         this.mc_tasks.graphics.moveTo(_loc11_,_loc7_ + _loc6_);
         this.mc_tasks.graphics.lineTo(_loc11_,_loc7_ + _loc6_ + 40);
         if(this._bounty.isAbandoned)
         {
            this.mc_container.filters = [Effects.GREYSCALE.filter];
            this.mc_container.mouseChildren = false;
            this.mc_container.alpha = 0.5;
            this.ui_unavailable.titleColor = 12735543;
            this.ui_unavailable.title = Language.getInstance().getString("bounty.infected_reward_abandoned").toUpperCase();
            this.ui_unavailable.message = Language.getInstance().getString("bounty.infected_reward_claimed_info");
            this.ui_unavailable.width = this._width;
            this.ui_unavailable.height = 116;
            this.ui_unavailable.bottomPadding = 20;
            this.ui_unavailable.x = int((this._width - this.ui_unavailable.width) * 0.5) - 1;
            this.ui_unavailable.y = int((this._height - this.ui_unavailable.height) * 0.5);
            this.ui_unavailable.redraw();
            addChild(this.ui_unavailable);
            this.btn_speedUp.x = int(this.ui_unavailable.x + (this._width - this.btn_speedUp.width) * 0.5);
            this.btn_speedUp.y = int(this.ui_unavailable.y + this.ui_unavailable.height - this.btn_speedUp.height - 20);
            addChild(this.btn_speedUp);
            this._timer.reset();
            this._timer.start();
         }
         else if(_loc1_)
         {
            this.mc_container.filters = [Effects.GREYSCALE.filter];
            this.mc_container.mouseChildren = false;
            this.mc_container.alpha = 0.5;
            this.ui_unavailable.titleColor = _loc1_ ? 11068224 : 12735543;
            this.ui_unavailable.title = Language.getInstance().getString("bounty.infected_reward_claimed").toUpperCase();
            this.ui_unavailable.message = Language.getInstance().getString("bounty.infected_reward_claimed_info");
            this.ui_unavailable.width = this._width;
            this.ui_unavailable.height = 116;
            this.ui_unavailable.bottomPadding = 20;
            this.ui_unavailable.x = int((this._width - this.ui_unavailable.width) * 0.5) - 1;
            this.ui_unavailable.y = int((this._height - this.ui_unavailable.height) * 0.5);
            this.ui_unavailable.redraw();
            addChild(this.ui_unavailable);
            this.btn_speedUp.x = int(this.ui_unavailable.x + (this._width - this.btn_speedUp.width) * 0.5);
            this.btn_speedUp.y = int(this.ui_unavailable.y + this.ui_unavailable.height - this.btn_speedUp.height - 20);
            addChild(this.btn_speedUp);
            this._timer.reset();
            this._timer.start();
         }
         else
         {
            this.mc_container.filters = [];
            this.mc_container.mouseChildren = true;
            this.mc_container.alpha = 1;
            if(this.ui_unavailable.parent != null)
            {
               this.ui_unavailable.parent.removeChild(this.ui_unavailable);
            }
            if(this.btn_speedUp.parent != null)
            {
               this.btn_speedUp.parent.removeChild(this.btn_speedUp);
            }
            this._timer.stop();
         }
      }
      
      private function onClickClaimReward(param1:MouseEvent) : void
      {
         var _loc2_:CrateMysteryUnlockDialogue = new CrateMysteryUnlockDialogue(this._rewardItem);
         _loc2_.open();
      }
      
      private function onClickSpeedUp(param1:MouseEvent) : void
      {
         var busyMsg:BusyDialogue = null;
         var e:MouseEvent = param1;
         var cash:int = Network.getInstance().playerData.compound.resources.getAmount(GameResources.CASH);
         if(cash < this._speedUpCost)
         {
            PaymentSystem.getInstance().openBuyCoinsScreen();
            return;
         }
         busyMsg = new BusyDialogue(Language.getInstance().getString("bounty.infected_speedup_busy"));
         busyMsg.open();
         Network.getInstance().save(null,SaveDataMethod.BOUNTY_SPEED_UP,function(param1:Object):void
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
      
      private function onAddedToStage(param1:Event) : void
      {
         this.ui_preview.uri = this._previewURI;
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
      }
      
      private function onBountyCompleted(param1:InfectedBounty) : void
      {
         var _loc3_:UIBountyInfectedRewardTaskIcon = null;
         var _loc2_:int = 0;
         while(_loc2_ < this._taskIcons.length)
         {
            _loc3_ = this._taskIcons[_loc2_];
            _loc3_.completed = true;
            _loc2_++;
         }
         if(this._bounty.rewardItemId != null)
         {
            this._rewardItem = Network.getInstance().playerData.inventory.getItemById(this._bounty.rewardItemId) as CrateMysteryItem;
            if(this._rewardItem != null)
            {
               Network.getInstance().playerData.inventory.itemRemoved.add(this.onItemRemoved);
            }
         }
         this.btn_open.enabled = true;
         this.btn_open.backgroundColor = 4226049;
         invalidate();
      }
      
      private function onBountyTaskCompleted(param1:InfectedBounty, param2:InfectedBountyTask) : void
      {
         if(param2.index < 0 || param2.index >= this._taskIcons.length)
         {
            return;
         }
         var _loc3_:UIBountyInfectedRewardTaskIcon = this._taskIcons[param2.index];
         _loc3_.completed = true;
      }
      
      private function onItemRemoved(param1:Item) : void
      {
         if(param1 == this._rewardItem)
         {
            this._rewardItem = null;
            Network.getInstance().playerData.inventory.itemRemoved.remove(this.onItemRemoved);
            invalidate();
         }
      }
      
      private function onTimerTick(param1:TimerEvent) : void
      {
         var _loc2_:Number = Network.getInstance().playerData.timeUntilNextInfectedBounty;
         var _loc3_:int = 60 * 5;
         if(_loc2_ <= _loc3_)
         {
            this.btn_speedUp.enabled = false;
         }
         if(_loc2_ <= 0)
         {
            this._timer.stop();
         }
      }
   }
}

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.ColorTransform;
import thelaststand.app.display.Effects;
import thelaststand.app.gui.UIComponent;

class UIBountyInfectedRewardTaskIcon extends UIComponent
{
   
   private var _width:int = 48;
   
   private var _height:int = 48;
   
   private var _backgroundColor:uint = 2171169;
   
   private var _completed:Boolean;
   
   private var bmp_stateIcon:Bitmap;
   
   private var bmp_image:Bitmap;
   
   private var mc_border:Sprite;
   
   public function UIBountyInfectedRewardTaskIcon()
   {
      super();
      this.mc_border = new Sprite();
      addChild(this.mc_border);
      this.bmp_image = new Bitmap();
      this.bmp_image.filters = [Effects.TEXT_SHADOW_DARK];
      addChild(this.bmp_image);
      this.bmp_stateIcon = new Bitmap();
      addChild(this.bmp_stateIcon);
   }
   
   public function get completed() : Boolean
   {
      return this._completed;
   }
   
   public function set completed(param1:Boolean) : void
   {
      this._completed = param1;
      invalidate();
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
   
   override public function dispose() : void
   {
      super.dispose();
      this.bmp_image.bitmapData = null;
      this.bmp_stateIcon.bitmapData = null;
   }
   
   override protected function draw() : void
   {
      graphics.clear();
      graphics.beginFill(this._backgroundColor);
      graphics.drawRect(0,0,this._width,this._height);
      graphics.endFill();
      this.mc_border.graphics.clear();
      this.mc_border.graphics.beginFill(16777215);
      this.mc_border.graphics.drawRect(0,0,this._width,this._height);
      this.mc_border.graphics.drawRect(1,1,this._width - 2,this._height - 2);
      this.mc_border.graphics.endFill();
      this.drawCompletedState();
   }
   
   private function drawCompletedState() : void
   {
      this.bmp_image.bitmapData = this._completed ? UIBountyInfectedTaskButton.BMP_BOUNTY_COMPLETE : UIBountyInfectedTaskButton.BMP_BOUNTY_INCOMPLETE;
      this.bmp_image.smoothing = true;
      this.bmp_image.width = 40;
      this.bmp_image.scaleY = this.bmp_image.scaleX;
      this.bmp_image.x = int((this._width - this.bmp_image.width) * 0.5);
      this.bmp_image.y = int((this._height - this.bmp_image.height) * 0.5);
      this.bmp_stateIcon.bitmapData = this._completed ? new BmpIconTradeTickGreen() : new BmpIconTradeCrossRed();
      this.bmp_stateIcon.x = int((this._width - this.bmp_stateIcon.width) * 0.5);
      this.bmp_stateIcon.y = int(this.height - this.bmp_stateIcon.height * 0.5);
      var _loc1_:ColorTransform = new ColorTransform();
      _loc1_.color = this._completed ? UIBountyInfectedTaskButton.COLOR_COMPLETE : UIBountyInfectedTaskButton.TEXT_COLOR_INCOMPLETE;
      this.mc_border.transform.colorTransform = _loc1_;
   }
}
