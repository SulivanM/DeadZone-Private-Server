package thelaststand.app.game.gui.mission
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.text.TextFieldAutoSize;
   import org.osflash.signals.Signal;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.gui.UITitleBar;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.common.lang.Language;
   
   public class UILeaveConfirm extends Sprite
   {
      
      private var _lang:Language;
      
      private var _allSurvivorsInZones:Boolean;
      
      private var _width:int = 136;
      
      private var _height:int = 264;
      
      private var _padding:int = 14;
      
      private var bmp_image:Bitmap;
      
      private var bmp_icon:Bitmap;
      
      private var mc_background:Shape;
      
      private var btn_leave:PushButton;
      
      private var btn_stay:PushButton;
      
      private var txt_desc:BodyTextField;
      
      private var mc_title:UITitleBar;
      
      public var cancelled:Signal;
      
      public var confirmed:Signal;
      
      public function UILeaveConfirm()
      {
         super();
         this._lang = Language.getInstance();
         this.cancelled = new Signal();
         this.confirmed = new Signal();
         this.mc_background = new Shape();
         this.mc_background.filters = [BaseDialogue.INNER_SHADOW,BaseDialogue.STROKE,BaseDialogue.DROP_SHADOW];
         this.mc_background.graphics.clear();
         this.mc_background.graphics.beginFill(5460819);
         this.mc_background.graphics.drawRect(0,0,this._width,this._height);
         this.mc_background.graphics.endFill();
         this.mc_background.graphics.beginBitmapFill(BaseDialogue.BMP_GRIME);
         this.mc_background.graphics.drawRect(0,0,this._width,this._height);
         this.mc_background.graphics.endFill();
         addChild(this.mc_background);
         this.mc_title = new UITitleBar({
            "color":16777215,
            "padding":46,
            "size":24
         });
         this.mc_title.title = this._lang.getString("mission_leave_title");
         this.mc_title.width = int(this._width + 8);
         this.mc_title.x = -4;
         this.mc_title.y = 6;
         this.mc_title.filters = [BaseDialogue.TITLE_BAR_SHADOW];
         addChild(this.mc_title);
         this.bmp_icon = new Bitmap(new BmpIconNotification());
         this.bmp_icon.filters = [new DropShadowFilter(0,45,0,1,8,8,1,1)];
         this.bmp_icon.x = int(this.mc_title.x + (46 - this.bmp_icon.width) * 0.5);
         this.bmp_icon.y = int(this.mc_title.y + (this.mc_title.height - this.bmp_icon.height) * 0.5);
         addChild(this.bmp_icon);
         this.bmp_image = new Bitmap(new BmpExitZones());
         this.bmp_image.x = int((this._width - this.bmp_image.width) * 0.5);
         this.bmp_image.y = int(this.mc_title.y + this.mc_title.height + 8);
         addChild(this.bmp_image);
         this.txt_desc = new BodyTextField({
            "color":13882323,
            "size":13,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW],
            "multiline":true,
            "autoSize":TextFieldAutoSize.CENTER,
            "align":"center"
         });
         this.txt_desc.text = this._lang.getString("mission_leave_msg");
         this.txt_desc.width = int(this._width - this._padding);
         this.txt_desc.x = int((this._width - this.txt_desc.width) * 0.5);
         this.txt_desc.y = int(this.bmp_image.y + this.bmp_image.height + 2);
         addChild(this.txt_desc);
         this.btn_leave = new PushButton(this._lang.getString("mission_leave_ok"),null,-1,null,4226049);
         this.btn_leave.clicked.add(this.onButtonClicked);
         this.btn_leave.width = int(this._width - this._padding * 2);
         this.btn_leave.x = int((this._width - this.btn_leave.width) * 0.5);
         this.btn_leave.y = int(this.txt_desc.y + this.txt_desc.height + this._padding - 4);
         addChild(this.btn_leave);
         this.btn_stay = new PushButton(this._lang.getString("mission_leave_cancel"),null,-1,null,7545099);
         this.btn_stay.clicked.add(this.onButtonClicked);
         this.btn_stay.width = this.btn_leave.width;
         this.btn_stay.x = this.btn_leave.x;
         this.btn_stay.y = int(this.btn_leave.y + this.btn_leave.height + this._padding - 2);
         addChild(this.btn_stay);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      public function dispose() : void
      {
         TweenMax.killTweensOf(this);
         if(parent != null)
         {
            parent.removeChild(this);
         }
         this._lang = null;
         this.btn_leave.dispose();
         this.btn_leave = null;
         this.btn_stay.dispose();
         this.btn_stay = null;
         this.txt_desc.dispose();
         this.txt_desc = null;
         this.mc_background.filters = [];
         this.mc_background = null;
         this.mc_title.dispose();
         this.mc_title = null;
         this.bmp_icon.bitmapData.dispose();
         this.bmp_icon.bitmapData = null;
         this.bmp_icon = null;
         this.bmp_image.bitmapData.dispose();
         this.bmp_image.bitmapData = null;
         this.bmp_image = null;
         this.cancelled.removeAll();
         this.confirmed.removeAll();
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         stage.addEventListener(MouseEvent.MOUSE_DOWN,this.onStageMouseDown,false,0,true);
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         stage.removeEventListener(MouseEvent.MOUSE_DOWN,this.onStageMouseDown);
      }
      
      private function onStageMouseDown(param1:MouseEvent) : void
      {
         if(param1.target == this || contains(DisplayObject(param1.target)))
         {
            return;
         }
         this.cancelled.dispatch();
      }
      
      private function onButtonClicked(param1:MouseEvent) : void
      {
         switch(param1.currentTarget)
         {
            case this.btn_leave:
               this.confirmed.dispatch();
               break;
            case this.btn_stay:
               this.cancelled.dispatch();
         }
      }
      
      public function get allSurvivorsInZones() : Boolean
      {
         return this._allSurvivorsInZones;
      }
      
      public function set allSurvivorsInZones(param1:Boolean) : void
      {
         this._allSurvivorsInZones = param1;
         this.btn_leave.backgroundColor = this._allSurvivorsInZones ? 4226049 : 7545099;
         this.btn_stay.backgroundColor = this._allSurvivorsInZones ? 7545099 : 2960942;
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
   }
}

