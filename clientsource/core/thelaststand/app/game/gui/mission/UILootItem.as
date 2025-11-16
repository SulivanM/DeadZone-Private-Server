package thelaststand.app.game.gui.mission
{
   import com.greensock.TweenMax;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import org.osflash.signals.Signal;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.display.TextFieldTyper;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.gui.UIItemImage;
   import thelaststand.common.lang.Language;
   
   public class UILootItem extends Sprite
   {
      
      private var _item:Item;
      
      private var _typer:TextFieldTyper;
      
      private var _timer:Timer;
      
      private var mc_background:Shape;
      
      private var ui_image:UIItemImage;
      
      private var txt_label:BodyTextField;
      
      public var timerCompleted:Signal;
      
      public function UILootItem(param1:Item)
      {
         super();
         mouseEnabled = mouseChildren = false;
         this._item = param1;
         this.ui_image = new UIItemImage(32,32,1);
         this.ui_image.showQuantity = false;
         if(param1 != null)
         {
            this.ui_image.item = param1;
         }
         else
         {
            this.ui_image.uri = "images/items/none.jpg";
         }
         addChild(this.ui_image);
         this.mc_background = new Shape();
         this.mc_background.graphics.beginGradientFill("linear",[0,0],[0.8,0],[0,255]);
         this.mc_background.graphics.drawRect(0,0,190,this.ui_image.height);
         this.mc_background.graphics.endFill();
         addChildAt(this.mc_background,0);
         this.txt_label = new BodyTextField({
            "color":16777215,
            "size":12,
            "bold":true
         });
         this.txt_label.filters = [Effects.TEXT_SHADOW];
         this.txt_label.text = " ";
         this.txt_label.textColor = this._item == null ? 16777215 : Effects.getQualityTitleColor(param1.qualityType);
         this.txt_label.x = int(this.ui_image.x + this.ui_image.width + 2);
         this.txt_label.y = Math.round(this.mc_background.y + (this.mc_background.height - this.txt_label.height) * 0.5);
         addChild(this.txt_label);
         this._typer = new TextFieldTyper(this.txt_label);
         this._timer = new Timer(10000,1);
         this._timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerComplete,false,0,true);
         this.timerCompleted = new Signal(UILootItem);
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this.ui_image.dispose();
         this._item = null;
         this._typer.dispose();
         this._typer = null;
         this._timer.stop();
         this._timer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerComplete);
         this.timerCompleted.removeAll();
      }
      
      public function transitionIn(param1:Number = 0) : void
      {
         var _loc2_:String = null;
         if(this._item == null)
         {
            _loc2_ = Language.getInstance().getString("nothing_found").toUpperCase();
         }
         else
         {
            _loc2_ = (this._item.quantity > 1 ? this._item.quantity + " x " : "") + this._item.getName().toUpperCase();
         }
         TweenMax.from(this.ui_image,0.25,{
            "delay":param1,
            "alpha":0
         });
         TweenMax.from(this.mc_background,0.25,{
            "delay":param1,
            "alpha":0
         });
         this._typer.type(_loc2_);
         this._timer.start();
      }
      
      private function onTimerComplete(param1:TimerEvent) : void
      {
         this._timer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerComplete);
         this.timerCompleted.dispatch(this);
      }
   }
}

