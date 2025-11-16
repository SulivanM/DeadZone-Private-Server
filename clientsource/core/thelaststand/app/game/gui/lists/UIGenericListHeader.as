package thelaststand.app.game.gui.lists
{
   import com.greensock.TweenMax;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.text.AntiAliasType;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   
   public class UIGenericListHeader extends Sprite
   {
      
      private var _width:int = 100;
      
      private var _height:int = 24;
      
      private var mc_background:Sprite;
      
      private var txt_label:BodyTextField;
      
      public function UIGenericListHeader(param1:String, param2:int = 24)
      {
         super();
         mouseChildren = false;
         this._height = param2;
         this.mc_background = new Sprite();
         addChild(this.mc_background);
         this.txt_label = new BodyTextField({
            "text":param1,
            "color":5987163,
            "size":12,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_label.y = int((this._height - this.txt_label.height) * 0.5);
         addChild(this.txt_label);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      public function dispose() : void
      {
         TweenMax.killChildTweensOf(this);
         if(parent != null)
         {
            parent.removeChild(this);
         }
         this.txt_label.dispose();
      }
      
      private function draw() : void
      {
         if(!stage)
         {
            return;
         }
         this.mc_background.graphics.clear();
         this.mc_background.graphics.beginFill(2434341);
         this.mc_background.graphics.drawRect(0,0,this._width,this._height);
         this.mc_background.graphics.endFill();
         this.txt_label.x = int((this._width - this.txt_label.width) * 0.5);
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.draw();
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
         this._width = param1;
         this.draw();
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
         this._height = param1;
         this.draw();
      }
   }
}

