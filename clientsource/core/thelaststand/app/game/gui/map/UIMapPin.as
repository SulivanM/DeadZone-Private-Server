package thelaststand.app.game.gui.map
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Back;
   import com.greensock.easing.Quad;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.filters.DropShadowFilter;
   import flash.system.LoaderContext;
   import thelaststand.app.display.BasicTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.network.RemotePlayerData;
   
   public class UIMapPin extends Sprite
   {
      
      private static const SHADOW:DropShadowFilter = new DropShadowFilter(0,0,0,1,4,4,0.75,1);
      
      private var _neighbor:RemotePlayerData;
      
      private var ui_image:UIImage;
      
      private var txt_level:BasicTextField;
      
      public var node:UIMissionAreaNode;
      
      public function UIMapPin(param1:UIMissionAreaNode, param2:RemotePlayerData)
      {
         super();
         mouseEnabled = mouseChildren = false;
         this.node = param1;
         this._neighbor = param2;
         this.ui_image = new UIImage(50,50);
         this.ui_image.graphics.beginFill(16777215,1);
         this.ui_image.graphics.drawRect(-2,-2,54,54);
         this.ui_image.graphics.endFill();
         this.ui_image.x = this.ui_image.y = -25;
         this.ui_image.context = new LoaderContext(true);
         addChild(this.ui_image);
         this.txt_level = new BasicTextField({
            "text":String(param2.level + 1),
            "color":16777215,
            "size":14,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_level.x = int(this.ui_image.x + this.ui_image.width - this.txt_level.width - 4);
         this.txt_level.y = int(this.ui_image.y + this.ui_image.height - this.txt_level.height - 4);
         addChild(this.txt_level);
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
         this.ui_image.dispose();
         this.ui_image = null;
         this.txt_level.dispose();
         this.txt_level = null;
         this._neighbor = null;
         this.node = null;
      }
      
      public function transitionIn(param1:Number = 0) : void
      {
         this.ui_image.scaleX = this.ui_image.scaleY = 1;
         this.ui_image.x = this.ui_image.y = -25;
         TweenMax.from(this.ui_image,0.15,{
            "transformAroundCenter":{
               "scaleX":0,
               "scaleY":0
            },
            "ease":Back.easeOut,
            "overwrite":true
         });
      }
      
      public function transitionOut(param1:Number = 0) : void
      {
         TweenMax.to(this.ui_image,0.15,{
            "transformAroundCenter":{
               "scaleX":0,
               "scaleY":0
            },
            "ease":Quad.easeOut,
            "overwrite":true
         });
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.ui_image.uri = this._neighbor.getPortraitURI();
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         TweenMax.killTweensOf(this.ui_image);
      }
      
      public function get remotePlayer() : RemotePlayerData
      {
         return this._neighbor;
      }
   }
}

