package thelaststand.app.game.gui.bounty
{
   import com.exileetiquette.utils.NumberFormatter;
   import flash.display.Bitmap;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import flash.text.TextFieldAutoSize;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.common.lang.Language;
   
   public class BountyRaidNotice extends Sprite
   {
      
      private var _stage:Stage;
      
      private var bg:Shape;
      
      private var box:BountyStyleBox;
      
      private var mainContainer:Sprite;
      
      private var headerContainer:Sprite;
      
      private var bodyContainer:Sprite;
      
      private var _contentWidth:Number = 310;
      
      private var txt_heading:BodyTextField;
      
      private var txt_footer:BodyTextField;
      
      private var txt_fuel:BodyTextField;
      
      private var txt_headOf:BodyTextField;
      
      private var txt_name:BodyTextField;
      
      private var bmp_starsLeft:Bitmap;
      
      private var bmp_starsRight:Bitmap;
      
      private var bmp_fuel:Bitmap;
      
      private var btn_close:PushButton;
      
      private var disposed:Boolean = false;
      
      private var d0:Bitmap;
      
      private var d1:Bitmap;
      
      public function BountyRaidNotice(param1:String, param2:Number)
      {
         var _loc3_:Language = null;
         var _loc4_:Number = NaN;
         super();
         _loc3_ = Language.getInstance();
         this.bg = new Shape();
         this.bg.graphics.clear();
         this.bg.graphics.beginFill(5460819);
         this.bg.graphics.drawRect(0,0,330,112);
         this.bg.graphics.endFill();
         this.bg.graphics.beginBitmapFill(new BmpDialogueBackground());
         this.bg.graphics.drawRect(0,0,330,112);
         this.bg.graphics.endFill();
         addChild(this.bg);
         this.bg.filters = [new DropShadowFilter(1,45,16777215,0.3,2,2,1,1,true),new GlowFilter(3618358,1,1.5,1.5,10,1),new DropShadowFilter(0,45,0,0.7,10,10,1,1)];
         this.bg.cacheAsBitmap = true;
         this.box = new BountyStyleBox(316,100);
         this.box.x = 7;
         this.box.y = 5;
         addChild(this.box);
         this.mainContainer = new Sprite();
         this.mainContainer.x = this.box.x + 3;
         this.mainContainer.y = this.box.y + 3;
         addChild(this.mainContainer);
         this.mainContainer.graphics.beginFill(16777215,0.3);
         this.mainContainer.graphics.drawRect(3,30,305,40);
         this.d0 = new Bitmap(new BmpBountyDivider());
         this.d0.x = -6;
         this.d0.y = 29;
         this.mainContainer.addChild(this.d0);
         this.d1 = new Bitmap(this.d0.bitmapData);
         this.d1.x = -3;
         this.d1.y = 70;
         this.mainContainer.addChild(this.d1);
         _loc4_ = 27;
         this.headerContainer = new Sprite();
         this.mainContainer.addChild(this.headerContainer);
         this.bmp_starsLeft = new Bitmap(new BmpBountyStars());
         this.bmp_starsLeft.y = int((_loc4_ - this.bmp_starsLeft.height) * 0.5);
         this.headerContainer.addChild(this.bmp_starsLeft);
         this.headerContainer.addChild(this.bmp_starsLeft);
         this.txt_heading = new BodyTextField({
            "border":false,
            "size":23,
            "bold":true,
            "color":4276025,
            "autoSize":TextFieldAutoSize.LEFT
         });
         this.txt_heading.text = _loc3_.getString("bounty.wanted");
         this.txt_heading.x = this.bmp_starsLeft.width + 6;
         this.txt_heading.y = int((_loc4_ - this.txt_heading.height) * 0.5);
         this.headerContainer.addChild(this.txt_heading);
         this.bmp_starsRight = new Bitmap(this.bmp_starsLeft.bitmapData);
         this.bmp_starsRight.x = this.txt_heading.x + this.txt_heading.width + 6;
         this.bmp_starsRight.y = this.bmp_starsLeft.y;
         this.headerContainer.addChild(this.bmp_starsRight);
         if(this.headerContainer.width > this._contentWidth)
         {
            this.headerContainer.width = this._contentWidth - 10;
            this.headerContainer.scaleY = this.headerContainer.scaleX;
         }
         this.headerContainer.x = int((this._contentWidth - this.headerContainer.width) * 0.5);
         var _loc5_:Bitmap = new Bitmap(new BmpIconButtonClose(),"auto",true);
         _loc5_.scaleX = _loc5_.scaleY = 0.75;
         this.btn_close = new PushButton("",_loc5_,-1,null,7545099);
         this.btn_close.autoSize = false;
         this.btn_close.width = this.btn_close.height = 14;
         this.btn_close.x = this._contentWidth - this.btn_close.width - 8;
         this.btn_close.y = int((27 - this.btn_close.height) * 0.5);
         this.btn_close.clicked.add(this.onClickClose);
         this.mainContainer.addChild(this.btn_close);
         _loc4_ = 40;
         this.bodyContainer = new Sprite();
         this.bodyContainer.y = 29;
         this.mainContainer.addChild(this.bodyContainer);
         this.txt_fuel = new BodyTextField({
            "border":false,
            "size":35,
            "bold":true,
            "color":4276025,
            "autoSize":TextFieldAutoSize.LEFT
         });
         this.txt_fuel.text = NumberFormatter.format(param2,0);
         this.txt_fuel.y = int((_loc4_ - this.txt_fuel.height) * 0.5);
         this.bodyContainer.addChild(this.txt_fuel);
         this.bmp_fuel = new Bitmap(new BmpIconFuel(),"auto",true);
         this.bmp_fuel.height = 30;
         this.bmp_fuel.scaleX = this.bmp_fuel.scaleY;
         this.bmp_fuel.x = this.txt_fuel.width + 2;
         this.bmp_fuel.y = int((_loc4_ - this.bmp_fuel.height) * 0.5) + 2;
         this.bmp_fuel.filters = [new GlowFilter(0,0.3,10,10)];
         this.bodyContainer.addChild(this.bmp_fuel);
         this.txt_headOf = new BodyTextField({
            "border":false,
            "size":12,
            "bold":false,
            "color":4276025,
            "autoSize":TextFieldAutoSize.LEFT
         });
         this.txt_headOf.text = _loc3_.getString("bounty.notice_headOf");
         this.txt_headOf.x = this.bmp_fuel.x + this.bmp_fuel.width + 4;
         this.txt_headOf.y = 6;
         this.bodyContainer.addChild(this.txt_headOf);
         this.txt_name = new BodyTextField({
            "border":false,
            "size":12,
            "bold":true,
            "color":4276025,
            "autoSize":TextFieldAutoSize.LEFT
         });
         this.txt_name.text = param1;
         this.txt_name.x = this.txt_headOf.x;
         this.txt_name.y = this.txt_headOf.y + this.txt_headOf.height - 5;
         this.bodyContainer.addChild(this.txt_name);
         if(this.bodyContainer.width > this._contentWidth)
         {
            this.bodyContainer.width = this._contentWidth - 10;
            this.bodyContainer.scaleY = this.bodyContainer.scaleX;
         }
         this.bodyContainer.x = int((this._contentWidth - this.bodyContainer.width) * 0.5);
         this.txt_footer = new BodyTextField({
            "border":false,
            "size":12,
            "bold":false,
            "color":4276025,
            "autoSize":TextFieldAutoSize.LEFT
         });
         this.txt_footer.maxWidth = this._contentWidth - 10;
         this.txt_footer.text = _loc3_.getString("bounty.notice_footer");
         this.txt_footer.x = int((this._contentWidth - this.txt_footer.width) * 0.5);
         this.txt_footer.y = 67 + int((29 - this.txt_footer.height) * 0.5);
         this.mainContainer.addChild(this.txt_footer);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         if(this.disposed)
         {
            return;
         }
         this.disposed = true;
         this.box.dispose();
         this.txt_heading.dispose();
         this.txt_heading = null;
         this.txt_footer.dispose();
         this.txt_footer = null;
         this.txt_fuel.dispose();
         this.txt_fuel = null;
         this.txt_headOf.dispose();
         this.txt_headOf = null;
         this.txt_name.dispose();
         this.txt_name = null;
         this.bmp_starsLeft.bitmapData.dispose();
         this.bmp_starsLeft.bitmapData = this.bmp_starsRight.bitmapData = null;
         this.btn_close.dispose();
         this.btn_close = null;
         this.bmp_fuel.bitmapData.dispose();
         this.bmp_fuel = null;
         this.d0.bitmapData.dispose();
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         if(this._stage)
         {
            this._stage.removeEventListener(Event.RESIZE,this.updateposition);
         }
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         this._stage = stage;
         this._stage.addEventListener(Event.RESIZE,this.updateposition,false,0,true);
         this.updateposition();
         Audio.sound.play("sound/interface/bounty-general.mp3");
      }
      
      private function updateposition(param1:Event = null) : void
      {
         this.x = int((this._stage.stageWidth - this.width) * 0.5);
      }
      
      private function onClickClose(param1:MouseEvent) : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
      }
   }
}

