package thelaststand.app.game.gui.loadout
{
   import flash.display.Sprite;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import thelaststand.app.core.Config;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIImage;
   import thelaststand.common.lang.Language;
   
   public class UIMissionPossibleFinds extends Sprite
   {
      
      private const STROKE:GlowFilter = new GlowFilter(3355443,1,1.5,1.5,10,1);
      
      private var _location:String;
      
      private var _items:Vector.<UIImage>;
      
      public function UIMissionPossibleFinds()
      {
         super();
         this._items = new Vector.<UIImage>();
      }
      
      public function dispose() : void
      {
         var _loc1_:UIImage = null;
         TooltipManager.getInstance().removeAllFromParent(this,true);
         if(parent != null)
         {
            parent.removeChild(this);
         }
         for each(_loc1_ in this._items)
         {
            _loc1_.dispose();
         }
         this._items = null;
         filters = [];
      }
      
      private function updateDisplay() : void
      {
         var item:UIImage = null;
         var findTypes:XMLList = null;
         var tx:int = 0;
         var node:XML = null;
         var itemType:String = null;
         for each(item in this._items)
         {
            TooltipManager.getInstance().remove(item);
            item.dispose();
         }
         this._items.length = 0;
         findTypes = Config.xml.location_finds.param.(@type == _location).type;
         tx = 4;
         for each(node in findTypes)
         {
            itemType = node.toString();
            item = new UIImage(32,32,2236962);
            item.uri = "images/items/" + itemType + ".jpg";
            item.x = tx;
            item.filters = [this.STROKE];
            TooltipManager.getInstance().add(item,Language.getInstance().getString("itm_types." + itemType),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
            tx += item.width + 4;
            addChild(item);
            this._items.push(item);
         }
      }
      
      public function get location() : String
      {
         return this._location;
      }
      
      public function set location(param1:String) : void
      {
         this._location = param1;
         this.updateDisplay();
      }
   }
}

