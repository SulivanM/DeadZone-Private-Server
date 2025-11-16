package thelaststand.app.game.gui
{
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.network.Network;
   import thelaststand.common.lang.Language;
   
   public class UIRequirementsChecklist extends UIComponent
   {
      
      private var _items:Vector.<UIRequirementsItem>;
      
      private var _spacing:int = 1;
      
      private var _list:XMLList;
      
      private var _width:int;
      
      private var _height:int;
      
      public function UIRequirementsChecklist()
      {
         super();
         this._items = new Vector.<UIRequirementsItem>();
      }
      
      public function get list() : XMLList
      {
         return this._list;
      }
      
      public function set list(param1:XMLList) : void
      {
         this._list = param1;
         invalidate();
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
         this._width = param1;
         invalidate();
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
         var _loc1_:UIRequirementsItem = null;
         super.dispose();
         for each(_loc1_ in this._items)
         {
            _loc1_.dispose();
         }
         this._list = null;
      }
      
      override protected function draw() : void
      {
         var _loc1_:UIRequirementsItem = null;
         var _loc3_:XML = null;
         var _loc4_:String = null;
         var _loc5_:* = false;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         for each(_loc1_ in this._items)
         {
            _loc1_.dispose();
         }
         this._items.length = 0;
         if(this._list == null)
         {
            return;
         }
         var _loc2_:int = 0;
         for each(_loc3_ in this._list)
         {
            _loc5_ = false;
            _loc6_ = int(_loc3_.@lvl.toString());
            _loc7_ = Math.max(int(_loc3_.toString()),1);
            switch(_loc3_.localName())
            {
               case "bld":
                  _loc4_ = Language.getInstance().getString("blds." + _loc3_.@id.toString());
                  _loc5_ = Network.getInstance().playerData.compound.buildings.hasBuilding(_loc3_.@id.toString(),_loc6_,_loc7_);
                  break;
               case "srv":
                  _loc4_ = Language.getInstance().getString("survivor_classes." + _loc3_.@id.toString());
                  _loc5_ = Network.getInstance().playerData.compound.survivors.hasSurvivor(_loc3_.@id.toString(),_loc6_,_loc7_);
                  break;
               case "lvl":
                  _loc4_ = Language.getInstance().getString("survivor_classes.player");
                  _loc5_ = Network.getInstance().playerData.getPlayerSurvivor().level >= _loc6_;
                  continue;
               case "skill":
                  _loc4_ = Language.getInstance().getString("skills." + _loc3_.@id.toString());
                  _loc5_ = Network.getInstance().playerData.skills.getSkill(_loc3_.@id.toString()).level >= _loc6_;
                  break;
               default:
                  continue;
            }
            if(_loc7_ > 1)
            {
               _loc4_ = _loc7_ + " x " + Language.getInstance().getString("construct_requires",_loc6_ + 1,_loc4_);
            }
            else
            {
               _loc4_ = Language.getInstance().getString("construct_requires",_loc6_ + 1,_loc4_);
            }
            _loc1_ = new UIRequirementsItem();
            _loc1_.label = _loc4_;
            _loc1_.completed = _loc5_;
            _loc1_.width = this._width;
            _loc1_.y = _loc2_;
            _loc2_ += _loc1_.height + this._spacing;
            addChild(_loc1_);
            this._items.push(_loc1_);
         }
         this._height = Math.max(_loc2_ - this._spacing,0);
      }
   }
}

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.text.AntiAliasType;
import thelaststand.app.display.BodyTextField;
import thelaststand.app.display.Effects;
import thelaststand.app.gui.UIComponent;

class UIRequirementsItem extends UIComponent
{
   
   private static const BMP_ICON_INCOMPLETE:BitmapData = new BmpIconTradeCrossRed();
   
   private static const BMP_ICON_COMPLETE:BitmapData = new BmpIconTradeTickGreen();
   
   private var _completed:Boolean = false;
   
   private var _width:int = 266;
   
   private var _height:int = 18;
   
   private var _label:String;
   
   private var bmp_icon:Bitmap;
   
   private var txt_label:BodyTextField;
   
   public function UIRequirementsItem()
   {
      super();
      this.bmp_icon = new Bitmap();
      addChild(this.bmp_icon);
      this.txt_label = new BodyTextField({
         "text":" ",
         "size":13,
         "bold":true,
         "antiAliasType":AntiAliasType.ADVANCED,
         "filters":[Effects.TEXT_SHADOW]
      });
      addChild(this.txt_label);
   }
   
   public function get completed() : Boolean
   {
      return this._completed;
   }
   
   public function set completed(param1:Boolean) : void
   {
      this._completed = param1;
      invalidate();
   }
   
   public function get label() : String
   {
      return this._label;
   }
   
   public function set label(param1:String) : void
   {
      this._label = param1;
      invalidate();
   }
   
   override public function get width() : Number
   {
      return this._width;
   }
   
   override public function set width(param1:Number) : void
   {
      this._width = param1;
      invalidate();
   }
   
   override public function get height() : Number
   {
      return this._height;
   }
   
   override public function set height(param1:Number) : void
   {
      this._height = param1;
      invalidate();
   }
   
   override public function dispose() : void
   {
      super.dispose();
      this.bmp_icon.bitmapData = null;
      this.txt_label.dispose();
   }
   
   override protected function draw() : void
   {
      graphics.clear();
      if(this._completed)
      {
         graphics.beginFill(2585125,0.3);
         graphics.drawRect(0,0,this._height,this._height);
         graphics.beginFill(2585125,0.5);
         graphics.drawRect(this._height,0,this._width - this._height,this._height);
         graphics.endFill();
         this.txt_label.textColor = 3988260;
         this.bmp_icon.bitmapData = BMP_ICON_COMPLETE;
      }
      else
      {
         graphics.beginFill(7798784,0.3);
         graphics.drawRect(0,0,this._height,this._height);
         graphics.beginFill(7798784,0.5);
         graphics.drawRect(this._height,0,this._width - this._height,this._height);
         graphics.endFill();
         this.txt_label.textColor = 16711680;
         this.bmp_icon.bitmapData = BMP_ICON_INCOMPLETE;
      }
      this.bmp_icon.x = int((this._height - this.bmp_icon.width) * 0.5);
      this.bmp_icon.y = int((this._height - this.bmp_icon.height) * 0.5);
      this.txt_label.htmlText = this._label.toString();
      this.txt_label.x = int(this._height + 2);
      this.txt_label.y = int((this._height - this.txt_label.height) * 0.5);
      this.txt_label.maxWidth = int(this._width - this.txt_label.x - 2);
   }
}
