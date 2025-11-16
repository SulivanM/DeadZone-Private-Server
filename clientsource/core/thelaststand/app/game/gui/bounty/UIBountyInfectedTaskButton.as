package thelaststand.app.game.gui.bounty
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Back;
   import com.quasimondo.geom.ColorMatrix;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import org.osflash.signals.natives.NativeSignal;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.bounty.InfectedBountyTask;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.common.lang.Language;
   
   public class UIBountyInfectedTaskButton extends UIComponent
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
      
      private var _bgMatrix:Matrix = new Matrix();
      
      private var _bountyTask:InfectedBountyTask;
      
      private var bmp_image:Bitmap;
      
      private var mc_border:Sprite;
      
      private var mc_background:Sprite;
      
      private var mc_suburbBg:Sprite;
      
      private var mc_selectedArrow:Sprite;
      
      private var txt_completeState:BodyTextField;
      
      private var txt_suburb:BodyTextField;
      
      public var clicked:NativeSignal;
      
      public function UIBountyInfectedTaskButton()
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
         this.bmp_image = new Bitmap(BMP_BOUNTY_INCOMPLETE,"auto",true);
         this.bmp_image.filters = [Effects.TEXT_SHADOW_DARK];
         addChild(this.bmp_image);
         this.txt_completeState = new BodyTextField({
            "color":16777215,
            "size":14,
            "filters":[Effects.STROKE]
         });
         this.txt_completeState.text = "STATE";
         addChild(this.txt_completeState);
         this.mc_suburbBg = new Sprite();
         addChild(this.mc_suburbBg);
         this.txt_suburb = new BodyTextField({
            "color":16777215,
            "size":16,
            "bold":true,
            "filters":[Effects.STROKE]
         });
         this.txt_suburb.text = "SUBURB NAME";
         addChild(this.txt_suburb);
         this.clicked = new NativeSignal(this,MouseEvent.CLICK,MouseEvent);
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
      }
      
      public function get task() : InfectedBountyTask
      {
         return this._bountyTask;
      }
      
      public function set task(param1:InfectedBountyTask) : void
      {
         if(this._bountyTask != null)
         {
            this._bountyTask.completed.remove(this.onBountyTaskCompleted);
            this._bountyTask = null;
         }
         this._bountyTask = param1;
         if(this._bountyTask != null)
         {
            if(!this._bountyTask.isCompleted)
            {
               this._bountyTask.completed.add(this.onBountyTaskCompleted);
            }
         }
         invalidate();
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
         this.mc_border.alpha = this._selected ? 1 : 0.3;
         var _loc2_:Number = this._selected ? this._imageScaleSelected : this._imageScaleDeselected;
         TweenMax.to(this.bmp_image,0.25,{
            "transformAroundCenter":{
               "scaleX":_loc2_,
               "scaleY":_loc2_
            },
            "overwrite":true
         });
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
         this.clicked.removeAll();
         this.txt_completeState.dispose();
         if(this._bountyTask != null)
         {
            this._bountyTask.completed.remove(this.onBountyTaskCompleted);
            this._bountyTask = null;
         }
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
         this._bgMatrix.createGradientBox(_loc3_,_loc4_,Math.PI * 0.5);
         this.mc_background.graphics.beginGradientFill("linear",[2171169,4802889],[1,1],[0,255],this._bgMatrix);
         this.mc_background.graphics.drawRect(0,0,_loc3_,_loc4_);
         this.mc_background.graphics.endFill();
         this.drawCompletedState();
         var _loc5_:int = this._border + 2;
         this.mc_suburbBg.graphics.clear();
         this.mc_suburbBg.graphics.beginFill(0,0.36);
         this.mc_suburbBg.graphics.drawRect(0,0,this._width - _loc5_ * 2,22);
         this.mc_suburbBg.graphics.endFill();
         this.mc_suburbBg.x = _loc5_;
         this.mc_suburbBg.y = int(this.txt_completeState.y - this.mc_suburbBg.height - 2);
         if(this._bountyTask == null)
         {
            mouseEnabled = false;
            filters = [Effects.GREYSCALE.filter];
            alpha = 0.5;
            this.txt_suburb.visible = false;
            this.mc_suburbBg.visible = false;
            this.txt_completeState.visible = false;
         }
         else
         {
            mouseEnabled = true;
            filters = [];
            alpha = 1;
            this.txt_suburb.text = Language.getInstance().getString("suburbs." + this._bountyTask.suburb).toUpperCase();
            this.txt_suburb.visible = true;
            this.mc_suburbBg.visible = true;
            this.txt_completeState.visible = true;
         }
         this.txt_suburb.maxWidth = int(this._width - (this._border + 6) * 2);
         this.txt_suburb.x = int((this._width - this.txt_suburb.width) * 0.5);
         this.txt_suburb.y = int(this.mc_suburbBg.y + (this.mc_suburbBg.height - this.txt_suburb.height) * 0.5);
      }
      
      private function drawCompletedState() : void
      {
         var _loc1_:Boolean = this._bountyTask != null && this._bountyTask.isCompleted;
         var _loc2_:ColorTransform = new ColorTransform();
         _loc2_.color = _loc1_ ? COLOR_COMPLETE : COLOR_INCOMPLETE;
         var _loc3_:ColorMatrix = new ColorMatrix();
         _loc3_.colorize(_loc1_ ? int(TEXT_COLOR_COMPLETE) : int(TEXT_COLOR_INCOMPLETE));
         this.mc_border.transform.colorTransform = _loc2_;
         this.mc_border.alpha = this._selected ? 1 : 0.3;
         this.mc_selectedArrow.transform.colorTransform = _loc2_;
         this.mc_background.filters = [_loc3_.filter];
         this.bmp_image.bitmapData = _loc1_ ? BMP_BOUNTY_COMPLETE : BMP_BOUNTY_INCOMPLETE;
         this.bmp_image.smoothing = true;
         this.bmp_image.scaleX = this.bmp_image.scaleY = this._selected ? this._imageScaleSelected : this._imageScaleDeselected;
         this.bmp_image.x = int((this._width - this.bmp_image.width) * 0.5);
         this.bmp_image.y = int((this._height - this.bmp_image.height) * 0.3);
         this.txt_completeState.textColor = _loc1_ ? TEXT_COLOR_COMPLETE : TEXT_COLOR_INCOMPLETE;
         this.txt_completeState.text = _loc1_ ? Language.getInstance().getString("bounty.infected_complete").toUpperCase() : Language.getInstance().getString("bounty.infected_incomplete").toUpperCase();
         this.txt_completeState.x = int((this._width - this.txt_completeState.width) * 0.5);
         this.txt_completeState.y = int(this._height - this.txt_completeState.height - 2);
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         var _loc2_:Number = (this._selected ? this._imageScaleSelected : this._imageScaleDeselected) * 1.1;
         Audio.sound.play("sound/interface/int-over.mp3");
         TweenMax.to(this.mc_background,0,{
            "colorTransform":{"exposure":1.1},
            "overwrite":true
         });
         TweenMax.to(this.bmp_image,0.25,{
            "transformAroundCenter":{
               "scaleX":_loc2_,
               "scaleY":_loc2_
            },
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
         TweenMax.to(this.bmp_image,0.25,{
            "transformAroundCenter":{
               "scaleX":_loc2_,
               "scaleY":_loc2_
            },
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
      }
      
      private function onBountyTaskCompleted(param1:InfectedBountyTask) : void
      {
         this._bountyTask.completed.remove(this.onBountyTaskCompleted);
         this.drawCompletedState();
      }
   }
}

