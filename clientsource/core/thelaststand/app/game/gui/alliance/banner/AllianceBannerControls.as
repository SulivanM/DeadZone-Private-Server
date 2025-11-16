package thelaststand.app.game.gui.alliance.banner
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import org.osflash.signals.Signal;
   import thelaststand.common.lang.Language;
   
   public class AllianceBannerControls extends Sprite
   {
      
      private var _banner:AllianceBannerDisplay;
      
      private var baseScroller:OptionScroller;
      
      private var decal1Scroller:OptionScroller;
      
      private var decal2Scroller:OptionScroller;
      
      private var decal3Scroller:OptionScroller;
      
      private var _scrollers:Array;
      
      private var _enabled:Boolean = true;
      
      private var _lang:Language;
      
      public var changed:Signal;
      
      public function AllianceBannerControls(param1:AllianceBannerDisplay)
      {
         var _loc2_:DisplayObject = null;
         var _loc3_:OptionScroller = null;
         this.changed = new Signal();
         super();
         this._banner = param1;
         this._lang = Language.getInstance();
         this.baseScroller = new OptionScroller(this._lang.getString("alliance.editor_base"),false);
         this.decal1Scroller = new OptionScroller(this._lang.getString("alliance.editor_decal1"));
         this.decal2Scroller = new OptionScroller(this._lang.getString("alliance.editor_decal2"));
         this.decal3Scroller = new OptionScroller(this._lang.getString("alliance.editor_decal3"));
         this._scrollers = [this.decal3Scroller,this.decal2Scroller,this.decal1Scroller,this.baseScroller];
         for each(_loc3_ in this._scrollers)
         {
            if(_loc2_)
            {
               _loc3_.y = _loc2_.y + _loc2_.height;
            }
            _loc3_.onScroll.add(this.onScoller);
            _loc3_.onColorChange.add(this.onColorChange);
            addChild(_loc3_);
            _loc2_ = _loc3_;
         }
         if(this._banner.ready)
         {
            this.updateControlsFromBanner();
         }
         else
         {
            this._banner.onReady.addOnce(this.updateControlsFromBanner);
         }
      }
      
      public function dispose() : void
      {
         var _loc1_:OptionScroller = null;
         this._lang = null;
         this._banner = null;
         for each(_loc1_ in this._scrollers)
         {
            _loc1_.dispose();
         }
         this._scrollers = null;
      }
      
      private function updateLabels() : void
      {
         this.decal1Scroller.label = this._lang.getString("alliance.editor_decal1") + " - " + this._banner.decal1;
         this.decal2Scroller.label = this._lang.getString("alliance.editor_decal2") + " - " + this._banner.decal2;
         this.decal3Scroller.label = this._lang.getString("alliance.editor_decal3") + " - " + this._banner.decal3;
      }
      
      public function updateControlsFromBanner() : void
      {
         if(this._banner.ready == false)
         {
            return;
         }
         this.baseScroller.colorIndex = this._banner.baseColor;
         this.decal1Scroller.colorIndex = this._banner.decal1Color;
         this.decal2Scroller.colorIndex = this._banner.decal2Color;
         this.decal3Scroller.colorIndex = this._banner.decal3Color;
         this.updateLabels();
      }
      
      private function onScoller(param1:OptionScroller, param2:Boolean) : void
      {
         switch(param1)
         {
            case this.decal1Scroller:
               this._banner.decal1 += param2 ? 1 : -1;
               break;
            case this.decal2Scroller:
               this._banner.decal2 += param2 ? 1 : -1;
               break;
            case this.decal3Scroller:
               this._banner.decal3 += param2 ? 1 : -1;
         }
         this.updateLabels();
         this.changed.dispatch();
      }
      
      private function onColorChange(param1:OptionScroller, param2:int, param3:uint) : void
      {
         switch(param1)
         {
            case this.baseScroller:
               this._banner.baseColor = param2;
               break;
            case this.decal1Scroller:
               this._banner.decal1Color = param2;
               break;
            case this.decal2Scroller:
               this._banner.decal2Color = param2;
               break;
            case this.decal3Scroller:
               this._banner.decal3Color = param2;
         }
         this.changed.dispatch();
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         var _loc2_:OptionScroller = null;
         this._enabled = param1;
         for each(_loc2_ in this._scrollers)
         {
            _loc2_.enabled = this._enabled;
         }
      }
   }
}

import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;
import org.osflash.signals.Signal;
import thelaststand.app.game.gui.UIColorPicker;
import thelaststand.app.gui.buttons.PushButton;

class OptionScroller extends Sprite
{
   
   public var onScroll:Signal;
   
   public var onColorChange:Signal;
   
   private var btn_prev:PushButton;
   
   private var btn_next:PushButton;
   
   private var label_block:PushButton;
   
   private var swatch:UIColorPicker;
   
   private var _enabled:Boolean = true;
   
   private var _allowScroll:Boolean;
   
   public function OptionScroller(param1:String, param2:Boolean = true)
   {
      super();
      this._allowScroll = param2;
      this.onScroll = new Signal(OptionScroller,Boolean);
      this.onColorChange = new Signal(OptionScroller,int,uint);
      this.btn_prev = this.generateScrollButton(true,param2);
      this.label_block = new PushButton(param1);
      this.label_block.width = 100;
      this.label_block.showBorder = false;
      this.label_block.x = this.btn_prev.width + 6;
      this.label_block.height = this.btn_prev.height;
      this.label_block.mouseEnabled = this.label_block.mouseChildren = false;
      addChild(this.label_block);
      this.btn_next = this.generateScrollButton(false,param2);
      this.btn_next.x = this.label_block.x + this.label_block.width + 6;
      this.swatch = new UIColorPicker();
      this.swatch.x = this.btn_next.x + this.btn_next.width + 6;
      this.swatch.width = this.btn_next.width;
      this.swatch.height = this.btn_next.height;
      this.swatch.showBorder = false;
      this.swatch.onChange.add(this.onSwatchChange);
      addChild(this.swatch);
   }
   
   public function dispose() : void
   {
      this.onScroll.removeAll();
      this.onColorChange.removeAll();
      this.btn_next.dispose();
      this.btn_prev.dispose();
      this.label_block.dispose();
   }
   
   private function generateScrollButton(param1:Boolean = false, param2:Boolean = true) : PushButton
   {
      var _loc3_:BitmapData = null;
      if(param2)
      {
         _loc3_ = param1 ? new BmpIconButtonPrev() : new BmpIconButtonNext();
      }
      var _loc4_:PushButton = new PushButton("",_loc3_);
      _loc4_.clicked.add(this.onButtonClicked);
      _loc4_.showBorder = false;
      _loc4_.width = 22;
      _loc4_.height = 20;
      if(!param2)
      {
         _loc4_.mouseEnabled = _loc4_.mouseChildren = false;
         _loc4_.enabled = false;
      }
      addChild(_loc4_);
      return _loc4_;
   }
   
   private function onSwatchChange(param1:int, param2:uint) : void
   {
      this.onColorChange.dispatch(this,param1,param2);
   }
   
   private function onButtonClicked(param1:MouseEvent) : void
   {
      this.onScroll.dispatch(this,param1.target == this.btn_next);
   }
   
   public function get colorIndex() : int
   {
      return this.swatch.selectedIndex;
   }
   
   public function set colorIndex(param1:int) : void
   {
      this.swatch.selectedIndex = param1;
   }
   
   public function get enabled() : Boolean
   {
      return this._enabled;
   }
   
   public function set enabled(param1:Boolean) : void
   {
      this._enabled = param1;
      if(this._allowScroll)
      {
         this.btn_next.enabled = this.btn_prev.enabled = this._enabled;
      }
      this.label_block.enabled = this._enabled;
   }
   
   public function get label() : String
   {
      return this.label_block.label;
   }
   
   public function set label(param1:String) : void
   {
      this.label_block.label = param1;
   }
}
