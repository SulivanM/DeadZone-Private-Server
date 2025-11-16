package thelaststand.app.game.gui.survivor
{
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.gui.UISurvivorPortrait;
   import thelaststand.app.gui.UIComponent;
   
   public class UISurvivorItemListHeader extends UIComponent
   {
      
      private var _survivor:Survivor;
      
      private var _width:int = 310;
      
      private var _height:int = 54;
      
      private var ui_info:UISurvivorInfoOverview;
      
      private var ui_portrait:UISurvivorPortrait;
      
      public function UISurvivorItemListHeader(param1:Survivor)
      {
         super();
         this._survivor = param1;
         this.ui_portrait = new UISurvivorPortrait(UISurvivorPortrait.SIZE_40x40,3552822);
         this.ui_portrait.survivor = this._survivor;
         this.ui_portrait.filters = [Effects.STROKE];
         addChild(this.ui_portrait);
         this.ui_info = new UISurvivorInfoOverview();
         this.ui_info.survivor = this._survivor;
         addChild(this.ui_info);
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
         this._survivor = null;
         this.ui_portrait.dispose();
         this.ui_info.dispose();
      }
      
      override protected function draw() : void
      {
         this.ui_portrait.x = 1;
         this.ui_portrait.y = int((this._height - this.ui_portrait.height) * 0.5);
         this.ui_info.x = int(this.ui_portrait.x + this.ui_portrait.width + 10);
         this.ui_info.y = int((this._height - this.ui_info.height) * 0.5);
      }
   }
}

