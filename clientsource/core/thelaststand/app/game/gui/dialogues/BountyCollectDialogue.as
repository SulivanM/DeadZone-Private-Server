package thelaststand.app.game.gui.dialogues
{
   import com.exileetiquette.utils.NumberFormatter;
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.text.AntiAliasType;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormatAlign;
   import org.osflash.signals.Signal;
   import playerio.DatabaseObject;
   import playerio.PlayerIOError;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.core.Config;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.game.gui.bounty.BountyStyleBox;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.common.lang.Language;
   
   public class BountyCollectDialogue extends BaseDialogue
   {
      
      public var onSelection:Signal;
      
      private var _lang:Language;
      
      private var _contentWidth:Number = 320;
      
      private var _glowbox:Shape;
      
      private var mc_container:Sprite;
      
      private var mc_content:Sprite;
      
      private var bd_titleIcon:BitmapData;
      
      private var bg:BountyStyleBox;
      
      private var bd_stars:BitmapData;
      
      private var bmp_starsLeft:Bitmap;
      
      private var bmp_starsRight:Bitmap;
      
      private var txt_heading:BodyTextField;
      
      private var txt_name:BodyTextField;
      
      private var txt_bountyHeading:BodyTextField;
      
      private var txt_feedback:BodyTextField;
      
      private var txt_disclaimer:BodyTextField;
      
      private var txt_description:BodyTextField;
      
      private var txt_of:BodyTextField;
      
      private var txt_ofValue:BodyTextField;
      
      private var bd_divider:BitmapData;
      
      private var d1:Bitmap;
      
      private var d2:Bitmap;
      
      private var d3:Bitmap;
      
      private var priceContainer:Sprite;
      
      private var txt_amount:BodyTextField;
      
      private var bmp_fuel:Bitmap;
      
      private var bmp_fuelSmall:Bitmap;
      
      private var btn_submit:PushButton;
      
      private var btn_cancel:PushButton;
      
      private var bountiesCollected:int = 0;
      
      private var bountyOffered:Number;
      
      private var _success:Boolean;
      
      public function BountyCollectDialogue(param1:Boolean, param2:String, param3:Number, param4:Number)
      {
         var g:Graphics;
         var displayedBounty:Number;
         var officeCut:Number;
         var perc:Number = NaN;
         var ty:Number = NaN;
         var diff:Number = NaN;
         var str:String = null;
         var net:Network = null;
         var success:Boolean = param1;
         var bountyName:String = param2;
         var bounty:Number = param3;
         var expireDate:Number = param4;
         this._success = success;
         this.bountyOffered = bounty;
         this.onSelection = new Signal(Boolean);
         this.mc_container = new Sprite();
         super("BountyCollectDialogue",this.mc_container,true);
         this._lang = Language.getInstance();
         perc = Number(Config.constant.BOUNTY_CUT);
         _autoSize = false;
         _width = 354;
         _height = 396;
         this.bd_titleIcon = new BmpBountySkull();
         addTitle(this._lang.getString("bounty.windowTitle"),BaseDialogue.TITLE_COLOR_GREY,-1,this.bd_titleIcon);
         this.bg = new BountyStyleBox(327,317);
         this.bg.y = _padding * 0.5;
         this.mc_container.addChild(this.bg);
         this.mc_content = new Sprite();
         this.bg.container.addChild(this.mc_content);
         g = this.mc_content.graphics;
         g.beginFill(success ? 3519763 : 9514788,success ? 0.5 : 0.7);
         ty = 0;
         g.drawRect(1,1,this._contentWidth - 2,51);
         this.bd_stars = new BmpBountyStars();
         this.bmp_starsLeft = new Bitmap(this.bd_stars);
         this.bmp_starsLeft.x = 14;
         this.bmp_starsLeft.y = 16;
         this.mc_content.addChild(this.bmp_starsLeft);
         this.bmp_starsRight = new Bitmap(this.bd_stars);
         this.bmp_starsRight.x = this._contentWidth - this.bmp_starsRight.width - this.bmp_starsLeft.x;
         this.bmp_starsRight.y = this.bmp_starsLeft.y;
         this.mc_content.addChild(this.bmp_starsRight);
         this.txt_heading = new BodyTextField({
            "size":40,
            "bold":true,
            "color":16777215,
            "autoSize":TextFieldAutoSize.LEFT,
            "align":TextFormatAlign.LEFT
         });
         this.txt_heading.maxWidth = this.bmp_starsRight.x - (this.bmp_starsLeft.x + this.bmp_starsLeft.width);
         this.txt_heading.text = this._lang.getString(success ? "bounty.collect_success_title" : "bounty.collect_failed_title",bountyName);
         this.txt_heading.x = this.bmp_starsLeft.x + this.bmp_starsLeft.width + (this.txt_heading.maxWidth - this.txt_heading.width) * 0.5;
         this.mc_content.addChild(this.txt_heading);
         g.beginFill(16777215,0.3);
         this.bd_divider = new BmpBountyDivider();
         this.d1 = new Bitmap(this.bd_divider);
         this.d1.x = 0;
         this.d1.y = 53;
         this.mc_content.addChild(this.d1);
         this.d2 = new Bitmap(this.bd_divider);
         this.d2.x = -2;
         this.d2.y = this.d1.y + 48;
         this.mc_content.addChild(this.d2);
         g.drawRect(1,this.d1.y,this._contentWidth - 2,this.d2.y - this.d1.y + 3);
         this.txt_name = new BodyTextField({
            "size":24,
            "bold":true,
            "color":4276025,
            "autoSize":TextFieldAutoSize.LEFT,
            "align":TextFormatAlign.LEFT
         });
         this.txt_name.maxWidth = this._contentWidth;
         this.txt_name.text = this._lang.getString(success ? "bounty.collect_success_name" : "bounty.collect_failed_name",bountyName);
         this.txt_name.x = int((this._contentWidth - this.txt_name.width) * 0.5);
         this.txt_name.y = this.d1.y + (this.d2.y - this.d1.y - this.txt_name.height) * 0.5;
         this.mc_content.addChild(this.txt_name);
         this.txt_bountyHeading = new BodyTextField({
            "size":18,
            "bold":true,
            "color":4276025,
            "autoSize":TextFieldAutoSize.LEFT,
            "align":TextFormatAlign.LEFT
         });
         this.txt_bountyHeading.maxWidth = this._contentWidth;
         this.txt_bountyHeading.text = this._lang.getString(success ? "bounty.collect_success_bountyTitle" : "bounty.collect_failed_bountyTitle");
         this.txt_bountyHeading.x = int((this._contentWidth - this.txt_bountyHeading.width) * 0.5);
         this.txt_bountyHeading.y = this.d2.y + 5;
         this.mc_content.addChild(this.txt_bountyHeading);
         ty = this.txt_bountyHeading.y + this.txt_bountyHeading.height + 3;
         displayedBounty = Math.floor(bounty);
         officeCut = Math.floor(bounty * perc);
         if(success)
         {
            displayedBounty = bounty - officeCut;
         }
         g.drawRect(1,ty,this._contentWidth - 2,60);
         this.priceContainer = new Sprite();
         this.mc_content.addChild(this.priceContainer);
         this.priceContainer.y = ty;
         this.txt_amount = new BodyTextField({
            "border":false,
            "color":4276025,
            "size":56,
            "bold":true,
            "autoSize":"left",
            "align":"left",
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_amount.text = NumberFormatter.format(displayedBounty,0);
         this.priceContainer.addChild(this.txt_amount);
         this.txt_amount.y = int((60 - this.txt_amount.height) * 0.5) - 2;
         this.bmp_fuel = new Bitmap(new BmpIconFuel());
         this.bmp_fuel.x = this.txt_amount.x + this.txt_amount.width + 8;
         this.bmp_fuel.y = int((60 - this.bmp_fuel.height) * 0.5);
         this.priceContainer.addChild(this.bmp_fuel);
         this.bmp_fuel.filters = [new GlowFilter(0,0.3,10,10)];
         this.priceContainer.x = int((this._contentWidth - this.priceContainer.width) * 0.5);
         this.txt_of = new BodyTextField({
            "text":this._lang.getString("bounty.collect_success_of"),
            "color":4276025,
            "size":13,
            "bold":true,
            "autoSize":"left",
            "align":"left",
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_ofValue = new BodyTextField({
            "text":String(Math.floor(bounty)),
            "color":4276025,
            "size":15,
            "bold":true,
            "autoSize":"left",
            "align":"left",
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_of.x = this.txt_ofValue.x = this.priceContainer.x + this.priceContainer.width + 5;
         this.txt_of.y = this.priceContainer.y + (this.priceContainer.height - (this.txt_of.height + this.txt_ofValue.height)) * 0.5 - 2;
         this.txt_ofValue.y = this.txt_of.y + this.txt_of.height - 6;
         if(success)
         {
            this.mc_content.addChild(this.txt_of);
            this.mc_content.addChild(this.txt_ofValue);
         }
         ty += 66;
         g.drawRect(1,ty,this._contentWidth - 2,30);
         this.bmp_fuelSmall = new Bitmap(new BmpIconFuel(),"auto",true);
         this.bmp_fuelSmall.width = 12;
         this.bmp_fuelSmall.scaleY = this.bmp_fuelSmall.scaleX;
         this.bmp_fuelSmall.y = ty + (30 - this.bmp_fuelSmall.height) * 0.5 - 2;
         this.bmp_fuelSmall.filters = [new GlowFilter(0,0.3,6,6)];
         this.txt_feedback = new BodyTextField({
            "size":18,
            "bold":true,
            "color":4276025,
            "autoSize":TextFieldAutoSize.LEFT,
            "align":TextFormatAlign.LEFT
         });
         this.txt_feedback.maxWidth = this._contentWidth;
         if(success)
         {
            this.txt_feedback.text = this._lang.getString("bounty.collect_success_take",String(officeCut));
            this.txt_feedback.x = int((this._contentWidth - this.txt_feedback.width) * 0.5);
            this.mc_content.addChild(this.bmp_fuelSmall);
            this.txt_feedback.x -= int((this.bmp_fuelSmall.width + 4) * 0.5);
            this.bmp_fuelSmall.x = this.txt_feedback.x + this.txt_feedback.width + 4;
         }
         else
         {
            diff = expireDate - Network.getInstance().serverTime;
            if(diff <= 0)
            {
               this.txt_feedback.text = this._lang.getString("bounty.list_expired");
               this.txt_feedback.textColor = 12910592;
            }
            else
            {
               if(diff < 3600000)
               {
                  str = this._lang.getString("bounty.list_1hour");
               }
               else
               {
                  str = DateTimeUtils.secondsToString(diff / 1000,true,false,true);
               }
               this.txt_feedback.text = this._lang.getString("bounty.collect_failed_expire",str);
            }
            this.txt_feedback.x = int((this._contentWidth - this.txt_feedback.width) * 0.5);
         }
         this.txt_feedback.y = ty + (30 - this.txt_feedback.height) * 0.5 - 2;
         this.mc_content.addChild(this.txt_feedback);
         ty += 32;
         this.txt_description = new BodyTextField({
            "size":12,
            "color":4276025,
            "autoSize":TextFieldAutoSize.CENTER,
            "multiline":true,
            "wordWrap":true,
            "align":TextFormatAlign.CENTER
         });
         this.txt_description.text = this._lang.getString("bounty.desc",bountyName);
         this.txt_description.width = this._contentWidth - 30;
         this.txt_description.x = 15;
         this.txt_description.y = ty;
         this.mc_content.addChild(this.txt_description);
         ty = 310 - 31;
         this.d3 = new Bitmap(this.bd_divider);
         this.d3.x = -2;
         this.d3.y = ty;
         this.mc_content.addChild(this.d3);
         ty += 6;
         this.txt_disclaimer = new BodyTextField({
            "size":12,
            "color":4276025,
            "autoSize":TextFieldAutoSize.NONE,
            "align":TextFormatAlign.CENTER
         });
         this.txt_disclaimer.text = this._lang.getString("bounty.disclaimer",int(perc * 100).toString());
         this.txt_disclaimer.width = this._contentWidth;
         this.txt_disclaimer.y = ty;
         this.mc_content.addChild(this.txt_disclaimer);
         ty += 45;
         this.btn_submit = new PushButton(this._lang.getString("bounty.collect_collect_btn"),null,-1,null,4226049);
         this.btn_submit.clicked.add(this.onOptionSelected);
         this.btn_submit.width = 100;
         this.btn_submit.x = this._contentWidth - this.btn_submit.width;
         this.btn_submit.y = ty;
         if(success)
         {
            this.mc_content.addChild(this.btn_submit);
         }
         this.btn_cancel = new PushButton(this._lang.getString(success ? "bounty.collect_reject_btn" : "bounty.collect_close_btn"),null,-1,null);
         this.btn_cancel.clicked.addOnce(this.onOptionSelected);
         this.btn_cancel.width = 100;
         this.btn_cancel.x = success ? this.btn_submit.x - this.btn_cancel.width - _padding : this.btn_submit.x;
         this.btn_cancel.y = ty;
         this.mc_content.addChild(this.btn_cancel);
         btn_close.clicked.removeAll();
         btn_close.clicked.add(this.onOptionSelected);
         if(success)
         {
            net = Network.getInstance();
            net.client.bigDB.load("PlayerSummary",net.playerData.id,function(param1:DatabaseObject):void
            {
               bountiesCollected = param1 != null && Boolean(param1.hasOwnProperty("bountyCollectCount")) ? int(param1.bountyCollectCount) : 0;
            },function(param1:PlayerIOError):void
            {
            });
            Tracking.trackEvent("Bounty","collection_offered",int(bounty).toString());
         }
         else
         {
            Tracking.trackEvent("Bounty","failed_attempt",int(bounty).toString());
         }
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._lang = null;
         this.btn_submit.dispose();
         this.btn_submit = null;
         this.btn_cancel.dispose();
         this.btn_cancel = null;
         this.txt_bountyHeading.dispose();
         this.txt_heading.dispose();
         this.txt_name.dispose();
         this.txt_feedback.dispose();
         this.txt_disclaimer.dispose();
         this.bd_titleIcon.dispose();
         this.bg.dispose();
         this.bd_stars.dispose();
         this.bmp_starsLeft = null;
         this.bmp_starsRight = null;
         this.bd_divider.dispose();
         this.d1 = this.d2 = this.d3 = null;
         this.bmp_fuel.bitmapData.dispose();
         this.bmp_fuelSmall.bitmapData.dispose();
         this.bmp_fuel = this.bmp_fuelSmall = null;
         if(this._glowbox)
         {
            TweenMax.killTweensOf(this._glowbox);
         }
      }
      
      override public function open() : void
      {
         super.open();
         Audio.sound.play(this._success ? "sound/interface/bounty-collect.mp3" : "sound/interface/bounty-fail.mp3");
      }
      
      public function updateCollectionStatus(param1:Boolean, param2:int) : void
      {
         var success:Boolean = param1;
         var bounty:int = param2;
         var tax:Number = Math.floor(Math.floor(bounty) * Number(Config.constant.BOUNTY_CUT));
         var postTax:Number = Math.floor(bounty - tax);
         this.txt_name.text = this._lang.getString("bounty.collect_claimed_name");
         this.txt_name.x = int((this._contentWidth - this.txt_name.width) * 0.5);
         this.txt_name.y = this.d1.y + int((this.d2.y - this.d1.y - this.txt_name.height) * 0.5);
         this.txt_bountyHeading.text = this._lang.getString("bounty.collect_claimed_bountyTitle");
         this.txt_bountyHeading.x = int((this._contentWidth - this.txt_bountyHeading.width) * 0.5);
         this.txt_amount.text = String(postTax);
         this.bmp_fuel.x = this.txt_amount.x + this.txt_amount.width + 8;
         this.priceContainer.x = int((this._contentWidth - this.priceContainer.width) * 0.5);
         this.txt_feedback.text = this._lang.getString("bounty.collect_claimed_total",String(this.bountiesCollected + 1));
         this.txt_feedback.x = int((this._contentWidth - this.txt_feedback.width) * 0.5);
         this.txt_description.text = this._lang.getString("bounty.collect_claimed_desc");
         this.btn_cancel.label = this._lang.getString("bounty.collect_close_btn");
         this.btn_cancel.x = this.btn_submit.x;
         if(this.btn_submit.parent)
         {
            this.btn_submit.parent.removeChild(this.btn_submit);
         }
         if(this.txt_of.parent)
         {
            this.txt_of.parent.removeChild(this.txt_of);
         }
         if(this.txt_ofValue.parent)
         {
            this.txt_ofValue.parent.removeChild(this.txt_ofValue);
         }
         if(this.bmp_fuelSmall.parent)
         {
            this.bmp_fuelSmall.parent.removeChild(this.bmp_fuelSmall);
         }
         this.btn_cancel.enabled = true;
         this.btn_cancel.clicked.removeAll();
         this.btn_cancel.clicked.add(function(param1:MouseEvent):void
         {
            close();
         });
         btn_close.enabled = true;
         btn_close.clicked.removeAll();
         btn_close.clicked.add(function(param1:MouseEvent):void
         {
            close();
         });
         this._glowbox = new Shape();
         this._glowbox.graphics.beginFill(16777215);
         this._glowbox.graphics.drawRect(0,0,327,317);
         this._glowbox.x = this._glowbox.y = -3;
         this.mc_content.addChild(this._glowbox);
         TweenMax.to(this._glowbox,0,{"glowFilter":{
            "blurX":40,
            "blurY":40,
            "strength":1,
            "alpha":1,
            "color":16777215
         }});
         TweenMax.to(this._glowbox,1.3,{
            "alpha":0,
            "glowFilter":{
               "blurX":5,
               "blurY":5,
               "strength":1,
               "alpha":0,
               "color":16777215
            }
         });
         Tracking.trackEvent("Bounty","collection_success",int(bounty).toString());
      }
      
      private function onOptionSelected(param1:MouseEvent) : void
      {
         var _loc2_:* = param1.target == this.btn_submit;
         this.btn_cancel.enabled = false;
         this.btn_cancel.clicked.remove(this.onOptionSelected);
         this.btn_submit.enabled = false;
         this.btn_submit.clicked.remove(this.onOptionSelected);
         btn_close.enabled = false;
         btn_close.clicked.remove(this.onOptionSelected);
         if(!_loc2_)
         {
            Tracking.trackEvent("Bounty","collection_offer_declined",int(this.bountyOffered).toString());
         }
         this.onSelection.dispatch(_loc2_);
      }
   }
}

