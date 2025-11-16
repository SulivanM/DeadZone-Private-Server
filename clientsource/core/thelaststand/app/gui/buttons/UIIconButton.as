package thelaststand.app.gui.buttons
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   
   public class UIIconButton extends Sprite
   {
      
      private var _enabled:Boolean = true;
      
      private var _icon:DisplayObject;
      
      private var _selected:Boolean;
      
      public function UIIconButton(param1:* = null)
      {
         super();
         buttonMode = true;
         mouseChildren = false;
         this.icon = param1;
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
      }
      
      public function dispose() : void
      {
         if(this._icon != null)
         {
            TweenMax.killTweensOf(this._icon);
         }
         removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         if(parent)
         {
            parent.removeChild(this);
         }
         if(this._icon is Bitmap)
         {
            Bitmap(this._icon).bitmapData.dispose();
         }
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(this._icon == null)
         {
            return;
         }
         TweenMax.to(this._icon,0,{
            "colorTransform":{"exposure":1.15},
            "overwrite":true
         });
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         if(this._icon == null)
         {
            return;
         }
         TweenMax.to(this._icon,0.15,{
            "colorTransform":{"exposure":1},
            "overwrite":true
         });
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         if(this._icon == null)
         {
            return;
         }
         TweenMax.to(this._icon,0,{
            "colorTransform":{"exposure":1.75},
            "onComplete":function():void
            {
               TweenMax.to(_icon,0.15,{"colorTransform":{"exposure":1}});
            }
         });
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         this._enabled = param1;
         mouseEnabled = this._enabled && !this._selected;
         alpha = this._enabled ? 1 : 0.25;
      }
      
      public function get icon() : *
      {
         return this._icon;
      }
      
      public function set icon(param1:*) : void
      {
         var _loc2_:BitmapData = null;
         if(this._icon != null)
         {
            if(this._icon.parent != null)
            {
               this._icon.parent.removeChild(this._icon);
            }
            if(this._icon is Bitmap)
            {
               _loc2_ = Bitmap(this._icon).bitmapData;
               if(_loc2_ != null)
               {
                  _loc2_.dispose();
               }
            }
         }
         this._icon = null;
         if(param1 != null)
         {
            if(param1 is BitmapData)
            {
               this._icon = new Bitmap(param1,"auto",true);
            }
            else
            {
               this._icon = param1;
            }
            addChild(this._icon);
         }
      }
      
      public function get selected() : Boolean
      {
         return this._selected;
      }
      
      public function set selected(param1:Boolean) : void
      {
         this._selected = param1;
         mouseEnabled = this._enabled && !this._selected;
      }
   }
}

