package thelaststand.app.game.gui.lists
{
   import com.greensock.TweenMax;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.gui.UIImage;
   import thelaststand.common.lang.Language;
   
   public class UISurvivorListNoneItem extends UIPagedListItem
   {
      
      private var _alternating:Boolean;
      
      private var mc_background:Sprite;
      
      private var mc_image:UIImage;
      
      private var txt_label:BodyTextField;
      
      public function UISurvivorListNoneItem()
      {
         super();
         _width = 305;
         _height = 53;
         this.mc_background = new Sprite();
         this.mc_background.graphics.beginFill(1447446);
         this.mc_background.graphics.drawRect(0,0,_width,_height);
         this.mc_background.graphics.endFill();
         addChild(this.mc_background);
         this.mc_image = new UIImage(40,40,0,1,false,"images/items/none.jpg");
         this.mc_image.x = 10;
         this.mc_image.y = Math.round((_height - this.mc_image.height) * 0.5);
         addChild(this.mc_image);
         this.txt_label = new BodyTextField({
            "color":16777215,
            "size":13,
            "bold":true
         });
         this.txt_label.text = Language.getInstance().getString("none").toUpperCase();
         this.txt_label.x = int(this.mc_image.x + this.mc_image.width + 5);
         this.txt_label.y = Math.round((_height - this.txt_label.height) * 0.5);
         this.txt_label.filters = [Effects.TEXT_SHADOW_DARK];
         addChild(this.txt_label);
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.mc_image.dispose();
         this.mc_image = null;
         this.txt_label.dispose();
         this.txt_label = null;
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         TweenMax.to(this.mc_background,0,{"tint":UISurvivorListItem.COLOR_OVER});
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         TweenMax.to(this.mc_background,0,{"tint":(this._alternating ? UISurvivorListItem.COLOR_ALT : UISurvivorListItem.COLOR_NORMAL)});
      }
      
      public function get alternating() : Boolean
      {
         return this._alternating;
      }
      
      public function set alternating(param1:Boolean) : void
      {
         var _loc2_:ColorTransform = null;
         this._alternating = param1;
         if(!selected)
         {
            _loc2_ = this.mc_background.transform.colorTransform;
            _loc2_.color = this._alternating ? uint(UISurvivorListItem.COLOR_ALT) : uint(UISurvivorListItem.COLOR_NORMAL);
            this.mc_background.transform.colorTransform = _loc2_;
         }
      }
      
      override public function set selected(param1:Boolean) : void
      {
         super.selected = param1;
         var _loc2_:ColorTransform = this.mc_background.transform.colorTransform;
         _loc2_.color = super.selected ? uint(UISurvivorListItem.COLOR_SELECTED) : (this._alternating ? uint(UISurvivorListItem.COLOR_ALT) : uint(UISurvivorListItem.COLOR_NORMAL));
         this.mc_background.transform.colorTransform = _loc2_;
      }
   }
}

