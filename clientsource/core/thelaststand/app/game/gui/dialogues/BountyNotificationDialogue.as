package thelaststand.app.game.gui.dialogues
{
   import com.exileetiquette.utils.NumberFormatter;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Graphics;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.text.AntiAliasType;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormatAlign;
   import thelaststand.app.core.Config;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.game.gui.bounty.BountyStyleBox;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.common.lang.Language;
   
   public class BountyNotificationDialogue extends BaseDialogue
   {
      
      private var _lang:Language;
      
      private var _contentWidth:Number = 320;
      
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
      
      private var txt_was:BodyTextField;
      
      private var txt_lost:BodyTextField;
      
      private var bd_divider:BitmapData;
      
      private var d1:Bitmap;
      
      private var d2:Bitmap;
      
      private var d3:Bitmap;
      
      private var priceContainer:Sprite;
      
      private var txt_amount:BodyTextField;
      
      private var bmp_fuel:Bitmap;
      
      private var bmp_fuelSmall:Bitmap;
      
      private var btn_continue:PushButton;
      
      public function BountyNotificationDialogue(param1:Object)
      {
         var _loc2_:Boolean = false;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc7_:Number = NaN;
         _loc2_ = Boolean(param1.collected);
         _loc3_ = param1.targetNickname;
         _loc4_ = param1.collectorNickname;
         _loc5_ = int(param1.bounty);
         this.mc_container = new Sprite();
         super("BountyNotificationDialogue",this.mc_container,true);
         this._lang = Language.getInstance();
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
         var _loc6_:Graphics = this.mc_content.graphics;
         _loc6_.beginFill(_loc2_ ? 3519763 : 9514788,_loc2_ ? 0.5 : 0.7);
         _loc7_ = 0;
         _loc6_.drawRect(1,1,this._contentWidth - 2,51);
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
         this.txt_heading.text = this._lang.getString(_loc2_ ? "bounty.teaser_title_success" : "bounty.teaser_title_fail",_loc3_);
         this.txt_heading.x = this.bmp_starsLeft.x + this.bmp_starsLeft.width + (this.txt_heading.maxWidth - this.txt_heading.width) * 0.5;
         this.mc_content.addChild(this.txt_heading);
         _loc6_.beginFill(16777215,0.3);
         this.bd_divider = new BmpBountyDivider();
         this.d1 = new Bitmap(this.bd_divider);
         this.d1.x = 0;
         this.d1.y = 53;
         this.mc_content.addChild(this.d1);
         this.d2 = new Bitmap(this.bd_divider);
         this.d2.x = -2;
         this.d2.y = this.d1.y + 48;
         this.mc_content.addChild(this.d2);
         _loc6_.drawRect(1,this.d1.y,this._contentWidth - 2,this.d2.y - this.d1.y + 3);
         this.txt_name = new BodyTextField({
            "size":24,
            "bold":true,
            "color":4276025,
            "autoSize":TextFieldAutoSize.LEFT,
            "align":TextFormatAlign.LEFT
         });
         this.txt_name.maxWidth = this._contentWidth;
         this.txt_name.text = this._lang.getString(_loc2_ ? "bounty.teaser_name_success" : "bounty.teaser_name_fail",_loc3_);
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
         this.txt_bountyHeading.maxWidth = this._contentWidth - 10;
         this.txt_bountyHeading.text = this._lang.getString(_loc2_ ? "bounty.teaser_byline_success" : "bounty.teaser_byline_fail");
         this.txt_bountyHeading.x = int((this._contentWidth - this.txt_bountyHeading.width) * 0.5);
         this.txt_bountyHeading.y = this.d2.y + 5;
         this.mc_content.addChild(this.txt_bountyHeading);
         _loc7_ = this.txt_bountyHeading.y + this.txt_bountyHeading.height + 3;
         var _loc8_:Number = Math.floor(_loc5_);
         _loc6_.drawRect(1,_loc7_,this._contentWidth - 2,60);
         this.priceContainer = new Sprite();
         this.mc_content.addChild(this.priceContainer);
         this.priceContainer.y = _loc7_;
         this.txt_amount = new BodyTextField({
            "border":false,
            "color":4276025,
            "size":56,
            "bold":true,
            "autoSize":"left",
            "align":"left",
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_amount.maxWidth = this._contentWidth - 10;
         this.txt_amount.text = _loc2_ ? _loc4_ : NumberFormatter.format(_loc8_,0);
         this.priceContainer.addChild(this.txt_amount);
         this.txt_amount.y = int((60 - this.txt_amount.height) * 0.5) - 2;
         this.bmp_fuel = new Bitmap(new BmpIconFuel());
         this.bmp_fuel.x = this.txt_amount.x + this.txt_amount.width + 8;
         this.bmp_fuel.y = int((60 - this.bmp_fuel.height) * 0.5);
         if(!_loc2_)
         {
            this.priceContainer.addChild(this.bmp_fuel);
         }
         this.bmp_fuel.filters = [new GlowFilter(0,0.3,10,10)];
         this.priceContainer.x = int((this._contentWidth - this.priceContainer.width) * 0.5);
         this.txt_was = new BodyTextField({
            "text":this._lang.getString("bounty.teaser_was_fail"),
            "color":4276025,
            "size":13,
            "bold":true,
            "autoSize":"left",
            "align":"left",
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_lost = new BodyTextField({
            "text":this._lang.getString("bounty.teaser_lost_fail"),
            "color":4276025,
            "size":15,
            "bold":true,
            "autoSize":"left",
            "align":"left",
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_was.x = this.txt_lost.x = this.priceContainer.x + this.priceContainer.width + 5;
         this.txt_was.y = this.priceContainer.y + (this.priceContainer.height - (this.txt_was.height + this.txt_lost.height)) * 0.5 - 2;
         this.txt_lost.y = this.txt_was.y + this.txt_was.height - 6;
         if(!_loc2_)
         {
            this.mc_content.addChild(this.txt_was);
            this.mc_content.addChild(this.txt_lost);
         }
         _loc7_ += 66;
         _loc6_.drawRect(1,_loc7_,this._contentWidth - 2,30);
         this.bmp_fuelSmall = new Bitmap(new BmpIconFuel(),"auto",true);
         this.bmp_fuelSmall.width = 12;
         this.bmp_fuelSmall.scaleY = this.bmp_fuelSmall.scaleX;
         this.bmp_fuelSmall.y = _loc7_ + (30 - this.bmp_fuelSmall.height) * 0.5 - 2;
         this.bmp_fuelSmall.filters = [new GlowFilter(0,0.3,6,6)];
         this.txt_feedback = new BodyTextField({
            "size":18,
            "bold":true,
            "color":4276025,
            "autoSize":TextFieldAutoSize.LEFT,
            "align":TextFormatAlign.LEFT
         });
         this.txt_feedback.maxWidth = this._contentWidth;
         this.txt_feedback.text = this._lang.getString(_loc2_ ? "bounty.teaser_feedback_success" : "bounty.teaser_feedback_fail",NumberFormatter.format(_loc5_,0));
         this.txt_feedback.x = int((this._contentWidth - this.txt_feedback.width) * 0.5);
         if(_loc2_)
         {
            this.mc_content.addChild(this.bmp_fuelSmall);
            this.txt_feedback.x -= int((this.bmp_fuelSmall.width + 4) * 0.5);
            this.bmp_fuelSmall.x = this.txt_feedback.x + this.txt_feedback.width + 4;
         }
         this.txt_feedback.y = _loc7_ + (30 - this.txt_feedback.height) * 0.5 - 2;
         this.mc_content.addChild(this.txt_feedback);
         _loc7_ += 32;
         this.txt_description = new BodyTextField({
            "size":12,
            "color":4276025,
            "autoSize":TextFieldAutoSize.CENTER,
            "multiline":true,
            "wordWrap":true,
            "align":TextFormatAlign.CENTER
         });
         var _loc9_:String = this._lang.getString(_loc2_ ? "bounty.teaser_desc_success" : "bounty.teaser_desc_fail");
         _loc9_ = _loc9_.replace("%target",_loc3_);
         _loc9_ = _loc9_.replace("%collector",_loc4_);
         _loc9_ = _loc9_.replace("%days",String(Config.constant.BOUNTY_LIFESPAN_DAYS));
         _loc9_ = _loc9_.replace("%fuel",NumberFormatter.format(_loc5_,0));
         this.txt_description.text = _loc9_;
         this.txt_description.width = this._contentWidth - 30;
         this.txt_description.x = 15;
         this.txt_description.y = _loc7_;
         this.mc_content.addChild(this.txt_description);
         _loc7_ = 310 - 31;
         this.d3 = new Bitmap(this.bd_divider);
         this.d3.x = -2;
         this.d3.y = _loc7_;
         this.mc_content.addChild(this.d3);
         _loc7_ += 6;
         this.txt_disclaimer = new BodyTextField({
            "size":12,
            "color":4276025,
            "autoSize":TextFieldAutoSize.NONE,
            "align":TextFormatAlign.CENTER
         });
         this.txt_disclaimer.text = this._lang.getString(_loc2_ ? "bounty.teaser_disclaimer_success" : "bounty.teaser_disclaimer_fail",String(Config.constant.BOUNTY_LIFESPAN_DAYS));
         this.txt_disclaimer.width = this._contentWidth;
         this.txt_disclaimer.y = _loc7_;
         this.mc_content.addChild(this.txt_disclaimer);
         _loc7_ += 45;
         this.btn_continue = new PushButton(this._lang.getString(_loc2_ ? "bounty.teaser_close_success" : "bounty.teaser_close_fail"),null,-1,null,_loc2_ ? 4226049 : 3026478);
         this.btn_continue.clicked.addOnce(this.onButtonClicked);
         this.btn_continue.width = 100;
         this.btn_continue.x = int((this._contentWidth - this.btn_continue.width) * 0.5);
         this.btn_continue.y = _loc7_;
         this.mc_content.addChild(this.btn_continue);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._lang = null;
         this.btn_continue.dispose();
         this.btn_continue = null;
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
      }
      
      private function onButtonClicked(param1:MouseEvent) : void
      {
         close();
      }
   }
}

