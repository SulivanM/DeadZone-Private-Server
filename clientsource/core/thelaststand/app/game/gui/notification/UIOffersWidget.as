package thelaststand.app.game.gui.notification
{
   import com.exileetiquette.utils.NumberFormatter;
   import com.greensock.TweenMax;
   import com.greensock.easing.Back;
   import com.greensock.easing.Linear;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import org.osflash.signals.Signal;
   import thelaststand.app.game.gui.dialogues.OffersDialogue;
   import thelaststand.app.network.OfferSystem;
   import thelaststand.common.gui.dialogues.Dialogue;
   
   public class UIOffersWidget extends Sprite
   {
      
      private var _count:int;
      
      private var _width:int;
      
      private var _height:int;
      
      private var _offers:OfferSystem;
      
      private var bmp_icon:Bitmap;
      
      private var bmp_newBg:Bitmap;
      
      private var mc_hitArea:Sprite;
      
      private var mc_newBg:Sprite;
      
      private var ui_count:UINotificationCount;
      
      public var changed:Signal = new Signal();
      
      public function UIOffersWidget()
      {
         super();
         mouseChildren = false;
         mouseEnabled = false;
         this._offers = OfferSystem.getInstance();
         this._offers.changed.add(this.onOffersChanged);
         this.bmp_icon = new Bitmap(new BmpIconOffers(),"auto",true);
         this.bmp_icon.filters = [new GlowFilter(9884595,1,18,18,1,1)];
         this.bmp_icon.y = -3;
         addChild(this.bmp_icon);
         this.mc_hitArea = new Sprite();
         this.mc_hitArea.graphics.beginFill(16711680,0);
         this.mc_hitArea.graphics.drawRect(0,0,this.bmp_icon.width,this.bmp_icon.height);
         this.mc_hitArea.graphics.endFill();
         this.mc_hitArea.x = this.bmp_icon.x;
         this.mc_hitArea.y = this.bmp_icon.y;
         addChild(this.mc_hitArea);
         hitArea = this.mc_hitArea;
         this.bmp_newBg = new Bitmap(new BmpIconOffersBg(),"auto",true);
         this.bmp_newBg.alpha = 0.75;
         this.bmp_newBg.x = -int(this.bmp_newBg.width * 0.5);
         this.bmp_newBg.y = -int(this.bmp_newBg.height * 0.5);
         this.mc_newBg = new Sprite();
         this.mc_newBg.addChild(this.bmp_newBg);
         this.mc_newBg.x = int(this.bmp_icon.x + this.bmp_icon.width * 0.5);
         this.mc_newBg.y = int(this.bmp_icon.y + this.bmp_icon.height * 0.5);
         this.ui_count = new UINotificationCount();
         this.ui_count.x = 2;
         this.ui_count.y = 0;
         addChild(this.ui_count);
         this._width = this.bmp_icon.width;
         this._height = this.bmp_icon.height;
         this.ui_count.scaleX = this.ui_count.scaleY = 0;
         this.ui_count.visible = false;
         TweenMax.to(this.bmp_icon,0,{"transformAroundCenter":{
            "scaleX":0,
            "scaleY":0,
            "rotation":10
         }});
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         addEventListener(MouseEvent.CLICK,this.onClicked,false,0,true);
         this.updateCount();
      }
      
      public function get count() : int
      {
         return this._count;
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
      
      public function dispose() : void
      {
         TweenMax.killChildTweensOf(this);
         if(parent)
         {
            parent.removeChild(this);
         }
         this._offers.changed.remove(this.onOffersChanged);
         this._offers = null;
         this.bmp_icon.bitmapData.dispose();
         this.bmp_icon.bitmapData = null;
         this.bmp_icon = null;
         this.bmp_newBg.bitmapData.dispose();
         this.bmp_newBg.bitmapData = null;
         this.ui_count.dispose();
         this.ui_count = null;
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
         removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         removeEventListener(MouseEvent.CLICK,this.onClicked);
      }
      
      private function updateCount(param1:Boolean = true) : void
      {
         var _loc2_:int = this._offers.numOffers;
         if(_loc2_ == this._count)
         {
            return;
         }
         this._count = _loc2_;
         this.ui_count.scaleX = this.ui_count.scaleY = 1;
         this.ui_count.label = NumberFormatter.format(this._count,0);
         if(param1)
         {
            this.changed.dispatch();
         }
      }
      
      private function animateIn() : void
      {
         mouseEnabled = true;
         TweenMax.to(this.bmp_icon,0.3,{
            "transformAroundCenter":{
               "scaleX":1,
               "scaleY":1,
               "rotation":0
            },
            "ease":Back.easeOut,
            "easeParams":[0.75],
            "overwrite":true
         });
         TweenMax.to(this.ui_count,0.15,{
            "delay":0.2,
            "scaleX":1,
            "scaleY":1,
            "ease":Back.easeOut,
            "easeParams":[0.75],
            "overwrite":true
         });
         this.ui_count.visible = true;
      }
      
      private function animateOut() : void
      {
         mouseEnabled = false;
         TweenMax.to(this.bmp_icon,0.3,{
            "delay":0.1,
            "transformAroundCenter":{
               "scaleX":0,
               "scaleY":0,
               "rotation":10
            },
            "ease":Back.easeIn,
            "easeParams":[0.75],
            "overwrite":true
         });
         TweenMax.to(this.ui_count,0.15,{
            "scaleX":0,
            "scaleY":0,
            "ease":Back.easeIn,
            "easeParams":[0.75],
            "overwrite":true
         });
      }
      
      private function updateUnviewedState() : void
      {
         if(this._offers.hasUnviewedOffers())
         {
            TweenMax.to(this.mc_newBg,6,{
               "rotation":360,
               "repeat":-1,
               "ease":Linear.easeNone,
               "overwrite":true
            });
            addChildAt(this.mc_newBg,0);
         }
         else if(this.mc_newBg.parent != null)
         {
            this.mc_newBg.parent.removeChild(this.mc_newBg);
         }
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.updateCount(false);
         if(this._count > 0)
         {
            this.animateIn();
         }
         this.updateUnviewedState();
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(!mouseEnabled)
         {
            return;
         }
         TweenMax.to(this.bmp_icon,0.15,{
            "transformAroundCenter":{
               "scaleX":1.05,
               "scaleY":1.05,
               "rotation":10
            },
            "ease":Back.easeOut,
            "easeParams":[0.75],
            "overwrite":true
         });
         TweenMax.to(this.ui_count,0.15,{
            "scaleX":1.15,
            "scaleY":1.15,
            "ease":Back.easeOut,
            "easeParams":[0.75],
            "overwrite":true
         });
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         if(!mouseEnabled)
         {
            return;
         }
         TweenMax.to(this.bmp_icon,0.5,{
            "transformAroundCenter":{
               "scaleX":1,
               "scaleY":1,
               "rotation":0
            },
            "ease":Back.easeOut,
            "easeParams":[0.75],
            "overwrite":true
         });
         TweenMax.to(this.ui_count,0.5,{
            "scaleX":1,
            "scaleY":1,
            "ease":Back.easeOut,
            "easeParams":[0.75],
            "overwrite":true
         });
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         if(!mouseEnabled)
         {
            return;
         }
         TweenMax.to(this,0,{"colorTransform":{"exposure":1.75}});
         TweenMax.to(this,0.5,{
            "delay":0.01,
            "colorTransform":{"exposure":1}
         });
      }
      
      private function onClicked(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         var dlg:OffersDialogue = new OffersDialogue();
         dlg.closed.addOnce(function(param1:Dialogue):void
         {
            updateUnviewedState();
         });
         dlg.open();
      }
      
      private function onOffersChanged() : void
      {
         this.updateCount();
         if(this._count <= 0)
         {
            this.animateOut();
         }
      }
   }
}

