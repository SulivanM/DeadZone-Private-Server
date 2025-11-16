package thelaststand.app.game.gui.compound
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Quad;
   import flash.display.Sprite;
   import flash.events.Event;
   import thelaststand.app.game.gui.notification.UINotificationWidget;
   import thelaststand.app.game.gui.notification.UIOffersWidget;
   
   public class UINotificationArea extends Sprite
   {
      
      private var _width:int = 126;
      
      private var ui_alerts:UINotificationWidget;
      
      private var ui_offers:UIOffersWidget;
      
      public function UINotificationArea()
      {
         super();
         this.ui_alerts = new UINotificationWidget();
         this.ui_alerts.changed.add(this.onChanged);
         addChild(this.ui_alerts);
         this.ui_offers = new UIOffersWidget();
         this.ui_offers.changed.add(this.onChanged);
         addChild(this.ui_offers);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         this.ui_alerts.dispose();
         this.ui_offers.dispose();
      }
      
      private function updatePositions(param1:Boolean) : void
      {
         var _loc8_:Sprite = null;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc2_:Array = [];
         if(this.ui_alerts.count > 0)
         {
            _loc2_.push(this.ui_alerts);
         }
         if(this.ui_offers.count > 0)
         {
            _loc2_.push(this.ui_offers);
         }
         var _loc3_:int = 2;
         var _loc4_:int;
         var _loc5_:int = _loc4_ = this._width / (Math.min(_loc3_,_loc2_.length) + 1);
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         while(_loc7_ < _loc2_.length)
         {
            _loc8_ = _loc2_[_loc7_];
            _loc9_ = _loc5_ - int(_loc8_.width * 0.5);
            _loc10_ = _loc6_;
            if(stage == null || !param1)
            {
               _loc8_.x = _loc9_;
               _loc8_.y = _loc10_;
            }
            else
            {
               TweenMax.to(_loc8_,0.25,{
                  "x":_loc9_,
                  "y":_loc10_,
                  "ease":Quad.easeInOut
               });
            }
            _loc5_ += _loc4_;
            _loc7_++;
         }
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.updatePositions(false);
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
      }
      
      private function onChanged() : void
      {
         this.updatePositions(stage != null);
      }
   }
}

