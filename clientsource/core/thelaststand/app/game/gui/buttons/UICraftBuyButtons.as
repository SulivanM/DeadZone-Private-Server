package thelaststand.app.game.gui.buttons
{
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.ItemFactory;
   import thelaststand.app.game.gui.dialogues.CraftingDialogue;
   import thelaststand.app.game.gui.dialogues.MiniStoreDialogue;
   import thelaststand.app.game.gui.dialogues.StoreDialogue;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.network.Network;
   import thelaststand.common.gui.dialogues.DialogueManager;
   
   public class UICraftBuyButtons extends UIComponent
   {
      
      private static const BMP_BUY_ICON:BitmapData = new BmpIconAddResource();
      
      private static const BMP_CRAFT_ICON:BitmapData = new BmpIconCraftItem();
      
      private static const SHADOW:DropShadowFilter = new DropShadowFilter(0,0,0,0.5,6,6,0.75,1);
      
      private var _width:int = 13;
      
      private var _height:int = 33;
      
      private var _buyType:String;
      
      private var _buyCategory:String;
      
      private var _craftType:String;
      
      private var _craftCategory:String;
      
      private var _showCraft:Boolean = true;
      
      private var _showBuy:Boolean = true;
      
      private var btn_craft:AddButton;
      
      private var btn_buy:AddButton;
      
      private var mc_container:Sprite;
      
      public var buyClicked:Signal = new Signal();
      
      public var craftClicked:Signal = new Signal();
      
      public function UICraftBuyButtons()
      {
         super();
         this.mc_container = new Sprite();
         this.mc_container.filters = [SHADOW];
         addChild(this.mc_container);
      }
      
      public function get craftAvailable() : Boolean
      {
         return this.btn_craft != null && this.btn_craft.parent == this;
      }
      
      public function get showCraft() : Boolean
      {
         return this._showCraft;
      }
      
      public function set showCraft(param1:Boolean) : void
      {
         if(param1 == this._showCraft)
         {
            return;
         }
         this._showCraft = param1;
         invalidate();
      }
      
      public function get showBuy() : Boolean
      {
         return this._showBuy;
      }
      
      public function set showBuy(param1:Boolean) : void
      {
         if(param1 == this._showBuy)
         {
            return;
         }
         this._showBuy = param1;
         invalidate();
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
         TooltipManager.getInstance().removeAllFromParent(this);
         this.buyClicked.removeAll();
         this.craftClicked.removeAll();
         this.mc_container.filters = [];
         if(this.btn_buy != null)
         {
            this.btn_buy.dispose();
         }
         if(this.btn_craft != null)
         {
            this.btn_craft.dispose();
         }
      }
      
      public function setBuyItem(param1:String, param2:String = null) : void
      {
         var _loc3_:XML = null;
         if(param2 == null)
         {
            _loc3_ = ItemFactory.getItemDefinition(param1);
            param2 = _loc3_.@type.toString();
         }
         this._buyType = param1;
         this._buyCategory = param2;
         invalidate();
      }
      
      public function setCraftItem(param1:String, param2:String = null) : void
      {
         var _loc3_:XML = null;
         if(param2 == null)
         {
            _loc3_ = ItemFactory.getItemDefinition(param1);
            param2 = _loc3_.@type.toString();
         }
         this._craftType = param1;
         this._craftCategory = param2;
         invalidate();
      }
      
      public function setItem(param1:String, param2:String = null) : void
      {
         var _loc3_:XML = null;
         if(param2 == null)
         {
            _loc3_ = ItemFactory.getItemDefinition(param1);
            param2 = _loc3_.@type.toString();
         }
         this._buyType = this._craftType = param1;
         this._buyCategory = this._craftCategory = param2;
         invalidate();
      }
      
      override protected function draw() : void
      {
         var _loc1_:int = 0;
         if(this._showCraft)
         {
            if(Network.getInstance().playerData.inventory.hasSchematicForItem(this._craftType))
            {
               if(this.btn_craft == null)
               {
                  this.btn_craft = new AddButton(BMP_CRAFT_ICON,3106217);
                  this.btn_craft.clicked.add(this.onClickCraft);
               }
               this.btn_craft.y = _loc1_;
               this.mc_container.addChild(this.btn_craft);
               _loc1_ += int(this.btn_craft.height - 1);
            }
         }
         else if(this.btn_craft != null)
         {
            if(this.btn_craft.parent != null)
            {
               this.btn_craft.parent.removeChild(this.btn_craft);
            }
         }
         if(this._showBuy)
         {
            if(this.btn_buy == null)
            {
               this.btn_buy = new AddButton(BMP_BUY_ICON,4160257);
               this.btn_buy.clicked.add(this.onClickBuy);
            }
            this.btn_buy.y = _loc1_;
            this.mc_container.addChild(this.btn_buy);
            _loc1_ += int(this.btn_buy.height - 1);
         }
         else if(this.btn_buy != null)
         {
            if(this.btn_buy.parent != null)
            {
               this.btn_buy.parent.removeChild(this.btn_buy);
            }
         }
         this.mc_container.y = int((this._height - this.mc_container.height) * 0.5);
      }
      
      private function onClickCraft(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:CraftingDialogue = DialogueManager.getInstance().getDialogueById("crafting-dialogue") as CraftingDialogue;
         if(_loc2_ == null)
         {
            _loc2_ = new CraftingDialogue(this._craftCategory,this._craftType);
         }
         else
         {
            _loc2_.setCategoryAndSelectSchematicByType(this._craftCategory,this._craftType);
         }
         _loc2_.open();
      }
      
      private function onClickBuy(param1:MouseEvent) : void
      {
         var _loc2_:StoreDialogue = null;
         var _loc3_:MiniStoreDialogue = null;
         param1.stopPropagation();
         if(this._buyCategory == "resource")
         {
            _loc2_ = new StoreDialogue("resource",this._buyType);
            _loc2_.open();
         }
         else
         {
            _loc3_ = new MiniStoreDialogue(this._buyType);
            _loc3_.open();
         }
      }
   }
}

import com.greensock.TweenMax;
import com.quasimondo.geom.ColorMatrix;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;
import org.osflash.signals.natives.NativeSignal;
import thelaststand.app.audio.Audio;

class AddButton extends Sprite
{
   
   private static const BMP_ADD_BUTTON:BitmapData = new BmpItemAddBG();
   
   private var _color:uint;
   
   private var bmp_background:Bitmap;
   
   private var bmp_icon:Bitmap;
   
   public var clicked:NativeSignal;
   
   public function AddButton(param1:BitmapData, param2:uint)
   {
      super();
      this._color = param2;
      this.clicked = new NativeSignal(this,MouseEvent.CLICK,MouseEvent);
      var _loc3_:ColorMatrix = new ColorMatrix();
      _loc3_.colorize(param2);
      this.bmp_background = new Bitmap(BMP_ADD_BUTTON);
      this.bmp_background.filters = [_loc3_.filter];
      addChild(this.bmp_background);
      this.bmp_icon = new Bitmap(param1);
      this.bmp_icon.x = int(this.bmp_background.x + (this.bmp_background.width - this.bmp_icon.width) * 0.5) - 1;
      this.bmp_icon.y = int(this.bmp_background.y + (this.bmp_background.height - this.bmp_icon.height) * 0.5);
      addChild(this.bmp_icon);
      addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
      addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
      addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
   }
   
   public function dispose() : void
   {
      TweenMax.killChildTweensOf(this);
      if(parent != null)
      {
         parent.removeChild(this);
      }
      this.bmp_background.bitmapData = null;
      this.bmp_icon.bitmapData = null;
      this.clicked.removeAll();
      removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
      removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
      removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
   }
   
   private function onMouseOver(param1:MouseEvent) : void
   {
      TweenMax.to(this.bmp_icon,0,{
         "colorTransform":{"exposure":1.1},
         "glowFilter":{
            "color":16777215,
            "alpha":1,
            "blurX":8,
            "blurY":8,
            "strength":1,
            "quality":1
         },
         "overwrite":true
      });
      TweenMax.to(this.bmp_background,0,{
         "colorTransform":{"exposure":1.08},
         "overwrite":true
      });
      Audio.sound.play("sound/interface/int-over.mp3");
   }
   
   private function onMouseOut(param1:MouseEvent) : void
   {
      TweenMax.to(this.bmp_icon,0.25,{
         "colorTransform":{"exposure":1},
         "glowFilter":{
            "alpha":0,
            "remove":true
         }
      });
      TweenMax.to(this.bmp_background,0.25,{"colorTransform":{"exposure":1}});
   }
   
   private function onMouseDown(param1:MouseEvent) : void
   {
      TweenMax.to(this.bmp_background,0,{
         "colorTransform":{"exposure":1.25},
         "overwrite":true
      });
      TweenMax.to(this.bmp_background,0.5,{
         "delay":0.05,
         "colorTransform":{"exposure":1}
      });
      Audio.sound.play("sound/interface/int-click.mp3");
   }
}
