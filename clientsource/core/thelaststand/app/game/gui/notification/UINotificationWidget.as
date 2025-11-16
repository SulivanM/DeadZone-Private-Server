package thelaststand.app.game.gui.notification
{
   import com.exileetiquette.utils.NumberFormatter;
   import com.greensock.TweenMax;
   import com.greensock.easing.Back;
   import com.greensock.easing.Quad;
   import com.greensock.easing.RoughEase;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.notification.INotification;
   import thelaststand.app.game.logic.NotificationSystem;
   
   public class UINotificationWidget extends Sprite
   {
      
      private var _count:int;
      
      private var _noteSystem:NotificationSystem;
      
      private var _width:int;
      
      private var _height:int;
      
      private var bmp_icon:Bitmap;
      
      private var ui_count:UINotificationCount;
      
      public var changed:Signal = new Signal();
      
      public function UINotificationWidget()
      {
         super();
         mouseChildren = false;
         mouseEnabled = false;
         this.bmp_icon = new Bitmap(new BmpIconAlert(),"auto",true);
         this.bmp_icon.filters = [new GlowFilter(14135830,1,18,18,1,1)];
         addChild(this.bmp_icon);
         this.ui_count = new UINotificationCount();
         this.ui_count.label = "0";
         this.ui_count.x = -4;
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
         this._noteSystem = NotificationSystem.getInstance();
         this._noteSystem.notificationAdded.add(this.onNotificationReceived);
         this._noteSystem.notificationRemoved.add(this.onNotificationRemoved);
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
      
      public function dispose() : void
      {
         TweenMax.killChildTweensOf(this);
         if(parent)
         {
            parent.removeChild(this);
         }
         this.bmp_icon.bitmapData.dispose();
         this.bmp_icon.bitmapData = null;
         this.bmp_icon = null;
         this.ui_count.dispose();
         this.ui_count = null;
         this._noteSystem.notificationAdded.remove(this.onNotificationReceived);
         this._noteSystem.notificationRemoved.remove(this.onNotificationRemoved);
         this._noteSystem = null;
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
         removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         removeEventListener(MouseEvent.CLICK,this.onClicked);
      }
      
      private function updateCount(param1:Boolean = true) : void
      {
         var _loc2_:int = this._noteSystem.numPassiveNotifications;
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
      
      private function pulse() : void
      {
         TweenMax.to(this.ui_count,0.1,{
            "scaleX":1.4,
            "scaleY":1.4,
            "overwrite":true,
            "onComplete":function():void
            {
               TweenMax.to(ui_count,1,{
                  "scaleX":1,
                  "scaleY":1,
                  "ease":Quad.easeInOut
               });
            }
         });
         TweenMax.to(this.bmp_icon,0.25,{
            "transformAroundCenter":{
               "scaleX":1.2,
               "scaleY":1.2,
               "rotation":10
            },
            "ease":RoughEase.create(2),
            "onComplete":function():void
            {
               TweenMax.to(bmp_icon,0.25,{"transformAroundCenter":{
                  "scaleX":1,
                  "scaleY":1,
                  "rotation":0
               }});
            }
         });
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.updateCount(false);
         if(this._count > 0)
         {
            this.animateIn();
         }
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
         this._noteSystem.openPassiveNotifications();
      }
      
      private function onNotificationReceived(param1:INotification) : void
      {
         var _loc2_:int = this._count;
         this.updateCount();
         if(_loc2_ < this._count)
         {
            if(_loc2_ <= 0)
            {
               this.animateIn();
            }
            else
            {
               this.pulse();
            }
         }
      }
      
      private function onNotificationRemoved(param1:INotification) : void
      {
         this.updateCount();
         if(this._count <= 0)
         {
            this.animateOut();
         }
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

