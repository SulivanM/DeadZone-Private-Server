package thelaststand.app.game.gui
{
   import com.deadreckoned.threshold.data.ObjectPool;
   import com.greensock.TweenMax;
   import com.greensock.easing.Linear;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.PixelSnapping;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.scenes.BaseScene;
   
   public class UIFloatingMessage extends Sprite
   {
      
      private static var _textField:BodyTextField;
      
      private static var _matrix:Matrix;
      
      private static var _padding:int = 4;
      
      public static var pool:ObjectPool = new ObjectPool(UIFloatingMessage,0,40,false);
      
      private var _scene:BaseScene;
      
      private var _x:Number;
      
      private var _y:Number;
      
      private var _z:Number;
      
      private var _floatHeight:int = 20;
      
      private var _time:Number = 0;
      
      private var _disposed:Boolean = false;
      
      private var bmd_message:BitmapData;
      
      private var bmp_message:Bitmap;
      
      public function UIFloatingMessage()
      {
         super();
         if(_textField == null)
         {
            _textField = new BodyTextField({
               "text":" ",
               "size":13,
               "bold":true,
               "multiline":true,
               "leading":-4,
               "align":"center",
               "filters":[Effects.STROKE]
            });
         }
         if(_matrix == null)
         {
            _matrix = new Matrix();
            _matrix.tx = _matrix.ty = _padding;
         }
         mouseChildren = mouseEnabled = tabEnabled = false;
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      public function init(param1:String, param2:uint, param3:BaseScene, param4:Number = 0, param5:Number = 0, param6:Number = 0, param7:int = 20, param8:Number = 0.75) : void
      {
         this._scene = param3;
         this._x = param4;
         this._y = param5;
         this._z = param6;
         this._floatHeight = param7;
         this._time = param8;
         _textField.text = param1;
         _textField.textColor = param2;
         _textField.autoSizeToContent();
         this.bmd_message = new BitmapData(_textField.width + _padding * 2,_textField.height + _padding * 2,true,0);
         this.bmd_message.draw(_textField,_matrix);
         this.bmp_message = new Bitmap(this.bmd_message,PixelSnapping.NEVER,true);
         this.bmp_message.x = -int(this.bmp_message.width * 0.5);
         this.bmp_message.y = -int(this.bmp_message.height);
         addChild(this.bmp_message);
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         var self:UIFloatingMessage = null;
         var e:Event = param1;
         self = this;
         var floatTime:Number = this._time * 5;
         var fadeDelay:Number = this._time * 0.66;
         TweenMax.to(this.bmp_message,floatTime,{
            "y":"-" + this._floatHeight,
            "ease":Linear.easeOut
         });
         TweenMax.to(this.bmp_message,this._time,{
            "delay":fadeDelay,
            "alpha":0,
            "ease":Linear.easeOut,
            "onComplete":function():void
            {
               if(self.parent != null)
               {
                  self.parent.removeChild(self);
               }
            }
         });
         addEventListener(Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
         this.onEnterFrame(null);
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         TweenMax.killTweensOf(this.bmp_message);
         this.bmd_message.dispose();
         this.bmp_message.bitmapData = null;
         this._scene = null;
         pool.put(this);
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         var _loc2_:Point = this._scene.getScreenPosition(this._x,this._y,this._z);
         x = _loc2_.x;
         y = _loc2_.y;
      }
   }
}

