package thelaststand.app.game.gui.iteminfo
{
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.geom.Rectangle;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.CrateItem;
   import thelaststand.app.game.data.EffectItem;
   import thelaststand.app.game.data.Gear;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.SchematicItem;
   import thelaststand.app.game.data.SurvivorLoadout;
   import thelaststand.app.game.data.Weapon;
   import thelaststand.app.network.Network;
   import thelaststand.common.lang.Language;
   
   public class UISchematicInfo extends Sprite implements IUIItemInfo
   {
      
      private var _schematic:SchematicItem;
      
      private var _width:int;
      
      private var _height:int;
      
      private var ui_display:UIItemInfoDisplay;
      
      private var bmp_unlock:Bitmap;
      
      private var txt_desc:BodyTextField;
      
      public function UISchematicInfo()
      {
         super();
         this.bmp_unlock = new Bitmap(new BmpIconUnlockItem());
         this.txt_desc = new BodyTextField({
            "color":Effects.COLOR_NEUTRAL,
            "multiline":true,
            "size":14
         });
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this._schematic = null;
         this.bmp_unlock.bitmapData.dispose();
         this.bmp_unlock.bitmapData = null;
         this.txt_desc.dispose();
         if(this.ui_display != null)
         {
            this.ui_display.dispose();
            this.ui_display = null;
         }
      }
      
      public function setItem(param1:Item, param2:SurvivorLoadout = null, param3:Object = null) : void
      {
         var _loc4_:* = false;
         var _loc5_:String = null;
         var _loc6_:Rectangle = null;
         this._schematic = param1 as SchematicItem;
         param1 = this._schematic.schematicItem;
         if(param1.category == "resource")
         {
            this.ui_display = new UIResourceInfo();
         }
         else if(param1.category == "upgradekit")
         {
            this.ui_display = new UIUpgradeKitInfo();
         }
         else if(param1.category == "craftkit")
         {
            this.ui_display = new UICraftKitInfo();
         }
         else if(param1 is Weapon)
         {
            this.ui_display = new UIWeaponInfo();
         }
         else if(param1 is Gear)
         {
            this.ui_display = new UIGearInfo();
         }
         else if(param1 is CrateItem)
         {
            this.ui_display = new UICrateInfo();
         }
         else if(param1 is EffectItem)
         {
            this.ui_display = new UIEffectItemInfo();
         }
         else
         {
            this.ui_display = new UIGenericItemInfo();
         }
         this.ui_display.setItem(param1,param2);
         addChild(this.ui_display);
         if(param3 == null || param3.showAction === true)
         {
            _loc4_ = Network.getInstance().playerData.inventory.getSchematic(this._schematic.schematicId) != null;
            _loc5_ = _loc4_ ? Language.getInstance().getString("itm_desc.schematic-unlocked") : Language.getInstance().getString("itm_desc.schematic");
            this.txt_desc.htmlText = _loc5_.replace("%s","     ");
            this.txt_desc.width = int(this.ui_display.width);
            this.txt_desc.y = int(this.ui_display.y + this.ui_display.height + 10);
            addChild(this.txt_desc);
            if(!_loc4_)
            {
               _loc6_ = this.txt_desc.getCharBoundaries(_loc5_.indexOf("%s"));
               this.bmp_unlock.x = int(this.txt_desc.x + _loc6_.x + 2);
               this.bmp_unlock.y = int(this.txt_desc.y + _loc6_.y + (_loc6_.height - this.bmp_unlock.height) * 0.5 + 1);
               addChild(this.bmp_unlock);
            }
            else if(this.bmp_unlock.parent != null)
            {
               this.bmp_unlock.parent.removeChild(this.bmp_unlock);
            }
            this._height = int(this.txt_desc.y + this.txt_desc.height);
         }
         else
         {
            this._height = int(this.ui_display.y + this.ui_display.height);
         }
         this._width = this.ui_display.width;
      }
      
      public function get item() : Item
      {
         return this._schematic;
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

