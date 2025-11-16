package thelaststand.app.game.gui.bounty
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextFieldAutoSize;
   import playerio.DatabaseObject;
   import playerio.PlayerIOError;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.core.Config;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.game.gui.dialogues.BountyAddDialogue;
   import thelaststand.app.gui.UIBusySpinner;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.network.Network;
   import thelaststand.common.lang.Language;
   
   public class BountyMissionReportTeaser extends Sprite
   {
      
      private var container:Sprite;
      
      private var bg:BountyStyleBox;
      
      private var box:Shape;
      
      private var starLeft:Bitmap;
      
      private var starRight:Bitmap;
      
      private var txt_heading:BodyTextField;
      
      private var txt_body:BodyTextField;
      
      private var btn_report:PushButton;
      
      private var _lang:Language;
      
      private var _disposed:Boolean;
      
      private var _id:String;
      
      private var _nickname:String;
      
      private var _spinner:UIBusySpinner;
      
      public function BountyMissionReportTeaser(param1:String)
      {
         var id:String = param1;
         super();
         this._lang = Language.getInstance();
         this._id = id;
         this.bg = new BountyStyleBox(554,60);
         addChild(this.bg);
         this.container = new Sprite();
         this.box = new Shape();
         this.box.graphics.beginFill(11303478,1);
         this.box.graphics.drawRect(0,0,175,48);
         this.box.x = this.box.y = 2;
         this.box.alpha = 0.7;
         this.container.addChild(this.box);
         this.starLeft = new Bitmap(new BmpBountySignleStar());
         this.starLeft.x = 7;
         this.starLeft.y = this.box.y + int((this.box.height - this.starLeft.height) * 0.5);
         this.container.addChild(this.starLeft);
         this.starRight = new Bitmap(new BmpBountySignleStar());
         this.starRight.x = this.box.x + this.box.width - this.starRight.width - 7;
         this.starRight.y = this.starLeft.y;
         this.container.addChild(this.starRight);
         this.txt_heading = new BodyTextField({
            "border":false,
            "size":30,
            "bold":true,
            "color":16777215,
            "autoSize":TextFieldAutoSize.LEFT
         });
         this.txt_heading.maxWidth = this.starRight.x - (this.starLeft + this.starLeft.width);
         this.container.addChild(this.txt_heading);
         this.btn_report = new PushButton();
         this.btn_report.backgroundColor = 8748389;
         this.btn_report.strokeColor = 6840911;
         this.btn_report.outlineColor = 12959661;
         this.btn_report.width = 100;
         this.btn_report.height = 25;
         this.btn_report.x = this.bg.width - this.btn_report.width - 16;
         this.btn_report.y = this.box.y + int((this.box.height - this.btn_report.height) * 0.5) + 2;
         this.container.addChild(this.btn_report);
         this.btn_report.clicked.add(this.onButtonClicked);
         this.txt_body = new BodyTextField({
            "border":false,
            "size":13,
            "bold":false,
            "color":4276025,
            "align":"center",
            "autoSize":TextFieldAutoSize.CENTER,
            "multiline":true,
            "wordWrap":true
         });
         this.txt_body.x = this.box.x + this.box.width + 8;
         this.txt_body.width = this.btn_report.x - 8 - (this.box.x + this.box.width + 8);
         this.container.addChild(this.txt_body);
         this._spinner = new UIBusySpinner();
         this._spinner.x = this.bg.width * 0.5;
         this._spinner.y = this.bg.height * 0.5;
         this._spinner.scaleX = this._spinner.scaleY = 1.1;
         this.bg.container.addChild(this._spinner);
         TweenMax.to(this._spinner,0,{"tint":4276025});
         Network.getInstance().client.bigDB.load("PlayerSummary",id,this.onDBComplete,function(param1:PlayerIOError):void
         {
         });
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
      }
      
      public function dispose() : void
      {
         if(this._disposed)
         {
            return;
         }
         this._disposed = true;
         this._lang = null;
         if(parent)
         {
            parent.removeChild(this);
         }
         this.bg.dispose();
         this.starLeft.bitmapData.dispose();
         this.txt_heading.dispose();
         this.txt_body.dispose();
         this.btn_report.dispose();
         this._spinner.dispose();
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
      }
      
      private function onDBComplete(param1:DatabaseObject) : void
      {
         var _loc4_:Number = NaN;
         if(this._disposed)
         {
            return;
         }
         if(param1 == null)
         {
            this.dispose();
            return;
         }
         var _loc2_:Boolean = false;
         if(this._spinner.parent)
         {
            this._spinner.parent.removeChild(this._spinner);
         }
         this._nickname = param1.nickname;
         var _loc3_:Number = param1.hasOwnProperty("bounty") ? Number(param1.bounty) : 0;
         if(_loc3_ > 0)
         {
            _loc4_ = param1.bountyDate ? Number(param1.bountyDate) : 0;
            _loc4_ = _loc4_ + Config.constant.BOUNTY_LIFESPAN_DAYS * (24 * 60 * 60 * 1000);
            if(_loc4_ > Network.getInstance().serverTime)
            {
               _loc2_ = true;
               Audio.sound.play("sound/interface/bounty-general.mp3");
            }
         }
         this.bg.container.addChild(this.container);
         TweenMax.to(this.box,0,{"tint":(_loc2_ ? 9514788 : 10574851)});
         this.txt_heading.text = this._lang.getString(_loc2_ ? "bounty.teaser_headingWanted" : "bounty.teaser_headingNotice");
         this.txt_heading.x = this.box.x + int((this.box.width - this.txt_heading.width) * 0.5);
         this.txt_heading.y = this.box.y + int((this.box.height - this.txt_heading.height) * 0.5);
         this.starLeft.x = this.txt_heading.x - this.starLeft.width - 8;
         this.starRight.x = this.txt_heading.x + this.txt_heading.width + 8;
         this.txt_body.text = this._lang.getString(_loc2_ ? "bounty.teaser_bodyWanted" : "bounty.teaser_bodyNotice",this._nickname);
         this.txt_body.y = this.box.y + int((this.box.height - this.txt_body.height) * 0.5);
         this.btn_report.label = this._lang.getString(_loc2_ ? "bounty.teaser_btnWanted" : "bounty.teaser_btnNotice");
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
      }
      
      private function onButtonClicked(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         var dlg:BountyAddDialogue = new BountyAddDialogue(this._nickname,this._id);
         dlg.onSuccess.add(function():void
         {
            btn_report.enabled = false;
         });
         dlg.open();
      }
   }
}

