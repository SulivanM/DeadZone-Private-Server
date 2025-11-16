package thelaststand.app.game.gui
{
   import com.quasimondo.geom.ColorMatrix;
   import flash.display.Bitmap;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.geom.Point;
   import org.osflash.signals.Signal;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.CrateItem;
   import thelaststand.app.game.data.CrateMysteryItem;
   import thelaststand.app.game.data.Gear;
   import thelaststand.app.game.data.GearType;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.SchematicItem;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.network.Network;
   import thelaststand.common.lang.Language;
   
   public class UIItemControl extends Sprite
   {
      
      public static const ALIGN_LEFT:String = "left";
      
      public static const ALIGN_RIGHT:String = "right";
      
      private var _align:String = "left";
      
      private var _width:int = 34;
      
      private var _height:int = 70;
      
      private var _item:Item;
      
      private var btn_unlock:PushButton;
      
      private var btn_recycle:PushButton;
      
      private var btn_inspect:PushButton;
      
      private var btn_dispose:PushButton;
      
      private var mc_background:Shape;
      
      public var recycleClicked:Signal;
      
      public var disposeClicked:Signal;
      
      public var inspectClicked:Signal;
      
      public var unlockClicked:Signal;
      
      public function UIItemControl()
      {
         super();
         this.mc_background = new Shape();
         this.mc_background.graphics.beginFill(0,0);
         this.mc_background.graphics.drawRect(-10,0,this._width + 10,this._height);
         this.mc_background.graphics.endFill();
         this.mc_background.graphics.beginFill(5460819);
         this.mc_background.graphics.drawRoundRectComplex(0,0,this._width,this._height,0,4,0,4);
         this.mc_background.graphics.endFill();
         this.mc_background.graphics.beginBitmapFill(new BmpDialogueBackground());
         this.mc_background.graphics.drawRoundRectComplex(0,0,this._width,this._height,0,4,0,4);
         this.mc_background.graphics.endFill();
         this.mc_background.filters = [new DropShadowFilter(0,0,0,1,6,6,1,1)];
         addChild(this.mc_background);
         this.btn_recycle = new PushButton("",new BmpIconRecycle2());
         this.btn_recycle.clicked.add(this.onButtonClicked);
         this.btn_recycle.width = 22;
         this.btn_recycle.height = 24;
         this.btn_recycle.x = int((this._width - this.btn_recycle.width) * 0.5);
         this.btn_recycle.y = 6;
         this.btn_inspect = new PushButton("",new BmpIconInspect());
         this.btn_inspect.clicked.add(this.onButtonClicked);
         this.btn_inspect.width = this.btn_recycle.width;
         this.btn_inspect.height = this.btn_recycle.height;
         this.btn_inspect.x = this.btn_recycle.x;
         this.btn_inspect.y = this.btn_recycle.y;
         this.btn_unlock = new PushButton("",new BmpIconUnlockItem());
         this.btn_unlock.clicked.add(this.onButtonClicked);
         this.btn_unlock.width = this.btn_recycle.width;
         this.btn_unlock.height = this.btn_recycle.height;
         this.btn_unlock.x = this.btn_recycle.x;
         this.btn_unlock.y = this.btn_recycle.y;
         var _loc1_:ColorMatrix = new ColorMatrix();
         _loc1_.colorize(10493970);
         var _loc2_:Bitmap = new Bitmap(new BmpIconButtonClose());
         _loc2_.filters = [_loc1_.filter,Effects.STROKE];
         this.btn_dispose = new PushButton("",_loc2_);
         this.btn_dispose.clicked.add(this.onButtonClicked);
         this.btn_dispose.width = 22;
         this.btn_dispose.height = 24;
         this.btn_dispose.x = int((this._width - this.btn_recycle.width) * 0.5);
         this.btn_dispose.y = this._height - this.btn_dispose.height - 6;
         var _loc3_:Language = Language.getInstance();
         TooltipManager.getInstance().add(this.btn_recycle,_loc3_.getString("tooltip.recycle"),new Point(this.btn_recycle.x + this.btn_recycle.width,NaN),TooltipDirection.DIRECTION_LEFT);
         TooltipManager.getInstance().add(this.btn_dispose,_loc3_.getString("tooltip.dispose"),new Point(this.btn_dispose.x + this.btn_dispose.width,NaN),TooltipDirection.DIRECTION_LEFT);
         TooltipManager.getInstance().add(this.btn_inspect,_loc3_.getString("tooltip.inspect"),new Point(this.btn_inspect.x + this.btn_inspect.width,NaN),TooltipDirection.DIRECTION_LEFT);
         TooltipManager.getInstance().add(this.btn_unlock,_loc3_.getString("tooltip.unlock"),new Point(this.btn_unlock.x + this.btn_unlock.width,NaN),TooltipDirection.DIRECTION_LEFT);
         this.disposeClicked = new Signal();
         this.recycleClicked = new Signal();
         this.inspectClicked = new Signal();
         this.unlockClicked = new Signal();
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this.disposeClicked.removeAll();
         this.recycleClicked.removeAll();
         this.inspectClicked.removeAll();
         this.unlockClicked.removeAll();
         TooltipManager.getInstance().removeAllFromParent(this,true);
         this.mc_background.filters = [];
         this.mc_background = null;
         this.btn_recycle.dispose();
         this.btn_recycle = null;
         this.btn_dispose.dispose();
         this.btn_dispose = null;
         this.btn_inspect.dispose();
         this.btn_inspect = null;
         this._item = null;
      }
      
      private function update() : void
      {
         var _loc2_:* = false;
         var _loc3_:String = null;
         var _loc4_:Gear = null;
         if(this.btn_recycle.parent != null)
         {
            this.btn_recycle.parent.removeChild(this.btn_recycle);
         }
         if(this.btn_inspect.parent != null)
         {
            this.btn_inspect.parent.removeChild(this.btn_inspect);
         }
         if(this.btn_unlock.parent != null)
         {
            this.btn_unlock.parent.removeChild(this.btn_unlock);
         }
         if(this.btn_dispose.parent != null)
         {
            this.btn_dispose.parent.removeChild(this.btn_dispose);
         }
         var _loc1_:Boolean = this._item.isDisposable;
         if(this._item is CrateItem)
         {
            addChild(this.btn_inspect);
         }
         else if(this._item is CrateMysteryItem)
         {
            this.btn_unlock.enabled = true;
            addChild(this.btn_unlock);
         }
         else if(this._item is SchematicItem)
         {
            _loc2_ = Network.getInstance().playerData.inventory.getSchematic(SchematicItem(this._item).schematicId) != null;
            _loc3_ = Language.getInstance().getString("tooltip." + (_loc2_ ? "unlocked" : "unlock"));
            TooltipManager.getInstance().add(this.btn_unlock,_loc3_,new Point(this.btn_unlock.x + this.btn_unlock.width,NaN),TooltipDirection.DIRECTION_LEFT);
            this.btn_unlock.enabled = !_loc2_;
            addChild(this.btn_unlock);
         }
         else
         {
            if(this._item.category == "weapon")
            {
               if(Network.getInstance().playerData.inventory.getItemsOfCategory("weapon").length <= 1)
               {
                  _loc1_ = false;
               }
            }
            else if(this._item.category == "gear")
            {
               _loc4_ = Gear(this._item);
               if(_loc4_.gearType & GearType.ACTIVE)
               {
                  if(Network.getInstance().playerData.loadoutManager.getAvailableQuantity(_loc4_) <= 0)
                  {
                     _loc1_ = false;
                  }
               }
            }
            this.btn_recycle.enabled = _loc1_ ? this._item.xml.recycle.children().length() > 0 : false;
            addChild(this.btn_recycle);
         }
         this.btn_dispose.enabled = _loc1_;
         addChild(this.btn_dispose);
      }
      
      private function onButtonClicked(param1:MouseEvent) : void
      {
         switch(param1.currentTarget)
         {
            case this.btn_dispose:
               this.disposeClicked.dispatch();
               break;
            case this.btn_recycle:
               this.recycleClicked.dispatch();
               break;
            case this.btn_inspect:
               this.inspectClicked.dispatch();
               break;
            case this.btn_unlock:
               this.unlockClicked.dispatch();
         }
      }
      
      public function get align() : String
      {
         return this._align;
      }
      
      public function set align(param1:String) : void
      {
         this._align = param1;
         this.mc_background.scaleX = this._align == ALIGN_RIGHT ? 1 : -1;
         this.mc_background.x = this._align == ALIGN_RIGHT ? 0 : this._width;
      }
      
      public function get item() : Item
      {
         return this._item;
      }
      
      public function set item(param1:Item) : void
      {
         this._item = param1;
         this.update();
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

