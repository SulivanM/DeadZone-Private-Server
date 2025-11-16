package thelaststand.app.game.gui.raid
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Back;
   import com.quasimondo.geom.ColorMatrix;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import org.osflash.signals.natives.NativeSignal;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.assignment.AssignmentStageState;
   import thelaststand.app.game.data.raid.RaidStageData;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.gui.UIImage;
   import thelaststand.common.lang.Language;
   
   public class UIRaidStageButton extends UIComponent
   {
      
      public static const BMP_BOUNTY_INCOMPLETE:BitmapData = new BmpIconInfectedBountyRed();
      
      public static const BMP_BOUNTY_COMPLETE:BitmapData = new BmpIconInfectedBountyGreen();
      
      public static const COLOR_COMPLETE:uint = 7902024;
      
      public static const COLOR_INCOMPLETE:uint = 8334893;
      
      public static const TEXT_COLOR_COMPLETE:uint = 12511349;
      
      public static const TEXT_COLOR_INCOMPLETE:uint = 13765901;
      
      private const _imageScaleSelected:Number = 1;
      
      private const _imageScaleDeselected:Number = 0.8;
      
      private var _width:int = 132;
      
      private var _height:int = 132;
      
      private var _border:int = 1;
      
      private var _selected:Boolean = false;
      
      private var _stage:RaidStageData;
      
      private var ui_image:UIImage;
      
      private var bmp_locked:Bitmap;
      
      private var mc_border:Sprite;
      
      private var mc_background:Sprite;
      
      private var mc_stageTextBg:Sprite;
      
      private var mc_selectedArrow:Sprite;
      
      private var txt_state:BodyTextField;
      
      private var txt_stage:BodyTextField;
      
      public var clicked:NativeSignal;
      
      public function UIRaidStageButton()
      {
         super();
         mouseChildren = false;
         this.mc_border = new Sprite();
         addChild(this.mc_border);
         this.mc_background = new Sprite();
         this.mc_background.x = this._border;
         this.mc_background.y = this._border;
         hitArea = this.mc_background;
         addChild(this.mc_background);
         this.mc_selectedArrow = new Sprite();
         this.mc_selectedArrow.scaleX = this.mc_selectedArrow.scaleY = 0;
         addChild(this.mc_selectedArrow);
         this.ui_image = new UIImage(1,1,0,0,true);
         this.ui_image.maintainAspectRatio = false;
         addChild(this.ui_image);
         this.bmp_locked = new Bitmap(new BmpIconItemLocked(),"auto",false);
         this.bmp_locked.alpha = 0.3;
         addChild(this.bmp_locked);
         this.txt_state = new BodyTextField({
            "color":16777215,
            "size":14,
            "filters":[Effects.STROKE]
         });
         this.txt_state.text = "STATE";
         addChild(this.txt_state);
         this.mc_stageTextBg = new Sprite();
         addChild(this.mc_stageTextBg);
         this.txt_stage = new BodyTextField({
            "color":16777215,
            "size":16,
            "bold":true,
            "filters":[Effects.STROKE]
         });
         this.txt_stage.text = "MISSION NAME";
         addChild(this.txt_stage);
         this.clicked = new NativeSignal(this,MouseEvent.CLICK,MouseEvent);
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
      }
      
      public function get selected() : Boolean
      {
         return this._selected;
      }
      
      public function set selected(param1:Boolean) : void
      {
         if(param1 == this._selected)
         {
            return;
         }
         this._selected = param1;
         if(this._selected)
         {
            if(stage == null)
            {
               this.mc_selectedArrow.scaleX = this.mc_selectedArrow.scaleY = 1;
            }
            else
            {
               TweenMax.to(this.mc_selectedArrow,0.25,{
                  "scale":1,
                  "ease":Back.easeOut
               });
            }
         }
         else if(stage == null)
         {
            this.mc_selectedArrow.scaleX = this.mc_selectedArrow.scaleY = 0;
         }
         else
         {
            TweenMax.to(this.mc_selectedArrow,0.25,{
               "scale":0,
               "ease":Back.easeIn
            });
         }
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
      
      public function setData(param1:RaidStageData) : void
      {
         this._stage = param1;
         data = this._stage;
         invalidate();
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.clicked.removeAll();
         this.txt_state.dispose();
         this.ui_image.dispose();
         this._stage = null;
      }
      
      override protected function draw() : void
      {
         this.mc_border.graphics.clear();
         this.mc_border.graphics.beginFill(16777215,1);
         this.mc_border.graphics.drawRect(0,0,this._width,this._height);
         this.mc_border.graphics.drawRect(this._border,this._border,this._width - this._border * 2,this._height - this._border * 2);
         this.mc_border.graphics.endFill();
         var _loc1_:int = 30;
         var _loc2_:int = 10;
         this.mc_selectedArrow.graphics.beginFill(16777215,1);
         this.mc_selectedArrow.graphics.moveTo(-_loc1_ / 2,0);
         this.mc_selectedArrow.graphics.lineTo(_loc1_ / 2,0);
         this.mc_selectedArrow.graphics.lineTo(0,_loc2_);
         this.mc_selectedArrow.graphics.endFill();
         this.mc_selectedArrow.x = int(this._width * 0.5);
         this.mc_selectedArrow.y = int(this._height);
         var _loc3_:int = this._width - this._border * 2;
         var _loc4_:int = this._height - this._border * 2;
         this.mc_background.graphics.clear();
         this.mc_background.graphics.beginFill(16777215);
         this.mc_background.graphics.drawRect(0,0,_loc3_,_loc4_);
         this.mc_background.graphics.endFill();
         this.drawState();
         this.mc_stageTextBg.graphics.clear();
         this.mc_stageTextBg.graphics.beginFill(0,0.6);
         this.mc_stageTextBg.graphics.drawRect(0,0,this._width - this._border * 2,22);
         this.mc_stageTextBg.graphics.endFill();
         this.mc_stageTextBg.x = this._border;
         this.mc_stageTextBg.y = int(this.txt_state.y - this.mc_stageTextBg.height - 2);
         this.ui_image.x = this.ui_image.y = this._border;
         this.ui_image.width = int(this._width - this.ui_image.x * 2);
         this.ui_image.height = int(this.mc_stageTextBg.y + this.mc_stageTextBg.height - this.ui_image.y);
         this.ui_image.uri = this._stage.imageURI;
         mouseEnabled = true;
         filters = [];
         alpha = 1;
         this.txt_stage.text = Language.getInstance().getString(this._stage.languageNamePath).toUpperCase();
         this.txt_stage.visible = true;
         this.txt_state.visible = true;
         this.mc_stageTextBg.visible = true;
         this.txt_stage.maxWidth = int(this._width - (this._border + 6) * 2);
         this.txt_stage.x = int((this._width - this.txt_stage.width) * 0.5);
         this.txt_stage.y = int(this.mc_stageTextBg.y + (this.mc_stageTextBg.height - this.txt_stage.height) * 0.5);
      }
      
      private function drawState() : void
      {
         var _loc1_:uint = 0;
         var _loc2_:uint = 0;
         var _loc3_:uint = 0;
         var _loc4_:String = null;
         var _loc8_:int = 0;
         var _loc5_:ColorMatrix = new ColorMatrix();
         switch(this._stage.state)
         {
            case AssignmentStageState.ACTIVE:
               _loc1_ = 4136964;
               _loc2_ = 9457170;
               _loc3_ = 15300626;
               _loc4_ = Language.getInstance().getString("raid.state_active").toUpperCase();
               this.bmp_locked.visible = false;
               break;
            case AssignmentStageState.COMPLETE:
               _loc1_ = 2898198;
               _loc2_ = 7902024;
               _loc3_ = 12511349;
               _loc4_ = Language.getInstance().getString("raid.state_complete").toUpperCase();
               _loc5_.colorize(6260253,0.5);
               this.bmp_locked.visible = false;
               break;
            case AssignmentStageState.LOCKED:
            default:
               _loc1_ = 1052688;
               _loc2_ = 7303023;
               _loc3_ = 6974058;
               _loc4_ = Language.getInstance().getString("raid.state_locked").toUpperCase();
               _loc5_.desaturate();
               _loc5_.adjustBrightness(-50);
               this.bmp_locked.visible = true;
         }
         var _loc6_:ColorTransform = new ColorTransform();
         _loc6_.color = _loc2_;
         this.mc_border.transform.colorTransform = _loc6_;
         this.mc_selectedArrow.transform.colorTransform = _loc6_;
         var _loc7_:ColorMatrix = new ColorMatrix();
         _loc7_.colorize(_loc1_);
         this.mc_background.filters = [_loc7_.filter];
         this.txt_state.text = _loc4_;
         this.txt_state.textColor = _loc3_;
         this.txt_state.y = int(this._height - this.txt_state.height - 2);
         if(this.bmp_locked.visible)
         {
            _loc8_ = this.bmp_locked.width + this.txt_state.width + 4;
            this.bmp_locked.x = int((this._width - _loc8_) * 0.5);
            this.bmp_locked.y = int(this.txt_state.y + (this.txt_state.height - this.bmp_locked.height) * 0.5);
            this.txt_state.x = int(this.bmp_locked.x + this.bmp_locked.width + 4);
         }
         else
         {
            this.txt_state.x = int((this._width - this.txt_state.width) * 0.5);
         }
         this.ui_image.filters = [_loc5_.filter];
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         var _loc2_:Number = (this._selected ? this._imageScaleSelected : this._imageScaleDeselected) * 1.1;
         Audio.sound.play("sound/interface/int-over.mp3");
         TweenMax.to(this.mc_background,0,{
            "colorTransform":{"exposure":1.1},
            "overwrite":true
         });
         TweenMax.to(this.ui_image,0,{
            "colorTransform":{"exposure":1.1},
            "overwrite":true
         });
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         var _loc2_:Number = this._selected ? this._imageScaleSelected : this._imageScaleDeselected;
         TweenMax.to(this.mc_background,0.25,{
            "colorTransform":{"exposure":1},
            "overwrite":true
         });
         TweenMax.to(this.ui_image,0.25,{
            "colorTransform":{"exposure":1},
            "overwrite":true
         });
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         Audio.sound.play("sound/interface/int-click.mp3");
         TweenMax.to(this.mc_background,0,{"colorTransform":{"exposure":1.5}});
         TweenMax.to(this.mc_background,0.25,{
            "delay":0.01,
            "colorTransform":{"exposure":1.1}
         });
         TweenMax.to(this.ui_image,0,{"colorTransform":{"exposure":1.5}});
         TweenMax.to(this.ui_image,0.25,{
            "delay":0.01,
            "colorTransform":{"exposure":1.1}
         });
      }
   }
}

