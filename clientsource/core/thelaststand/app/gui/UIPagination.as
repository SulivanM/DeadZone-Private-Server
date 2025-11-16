package thelaststand.app.gui
{
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.AntiAliasType;
   import org.osflash.signals.Signal;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.gui.buttons.PushButton;
   
   public class UIPagination extends Sprite
   {
      
      private const MAX_SPACING:int = 15;
      
      private var _dots:Vector.<UIPaginationDot>;
      
      private var _currentPage:int;
      
      private var _numPages:int;
      
      private var _maxWidth:int = 370;
      
      private var _maxDots:int = 50;
      
      private var _width:int;
      
      private var btn_prev:PushButton;
      
      private var btn_next:PushButton;
      
      private var txt_pages:BodyTextField;
      
      public var changed:Signal;
      
      public function UIPagination(param1:int = 0, param2:int = 0)
      {
         super();
         this.btn_prev = new PushButton("",new BmpIconButtonPrev());
         this.btn_prev.addEventListener(MouseEvent.CLICK,this.onClickNav,false,0,true);
         this.btn_prev.width = this.btn_prev.height;
         addChild(this.btn_prev);
         this.btn_next = new PushButton("",new BmpIconButtonNext());
         this.btn_next.addEventListener(MouseEvent.CLICK,this.onClickNav,false,0,true);
         this.btn_next.width = this.btn_next.height;
         addChild(this.btn_next);
         this.txt_pages = new BodyTextField({
            "color":16777215,
            "size":14,
            "bold":true,
            "antiAliasType":AntiAliasType.ADVANCED,
            "filters":[Effects.TEXT_SHADOW]
         });
         this._dots = new Vector.<UIPaginationDot>();
         this.numPages = param1;
         this.gotoPage(param2);
         this.changed = new Signal(int);
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this.changed.removeAll();
         this.btn_prev.dispose();
         this.btn_prev = null;
         this.btn_next.dispose();
         this.btn_next = null;
         this.txt_pages.dispose();
         this.txt_pages = null;
         this._dots = null;
      }
      
      private function gotoPage(param1:int, param2:Boolean = false) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         else if(param1 >= this._numPages)
         {
            param1 = this._numPages;
         }
         var _loc3_:* = param1 != this._currentPage;
         if(_loc3_ && this._currentPage < this._dots.length)
         {
            this._dots[this._currentPage].selected = false;
         }
         this._currentPage = param1;
         if(this._numPages > 0)
         {
            this._dots[this._currentPage].selected = true;
         }
         this.txt_pages.text = this._currentPage + 1 + " / " + this._numPages;
         this.txt_pages.x = int((this.btn_next.x + this.btn_next.width - this.txt_pages.width) * 0.5);
         if(param2 && _loc3_)
         {
            this.changed.dispatch(this._currentPage);
         }
         this.btn_prev.enabled = this._currentPage > 0 && this._numPages > 1;
         this.btn_next.enabled = this._currentPage < this._numPages - 1 && this._numPages > 1;
      }
      
      private function positionElements() : void
      {
         var _loc1_:UIPaginationDot = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc4_:int = Math.min(this._maxWidth,this.btn_next.width + this.btn_prev.width + ((10 + this.MAX_SPACING) * this._numPages + this.MAX_SPACING));
         this.btn_prev.x = 4;
         this.btn_prev.y = 0;
         if(this._numPages < this._maxDots)
         {
            _loc5_ = _loc4_ - this.btn_next.width - this.btn_prev.width;
            _loc6_ = Math.min(this.MAX_SPACING,_loc5_ / this._numPages * 0.5);
            _loc3_ = this.btn_prev.x + this.btn_prev.width + _loc6_;
            _loc2_ = 0;
            while(_loc2_ < this._numPages)
            {
               _loc1_ = this._dots[_loc2_];
               _loc1_.x = _loc3_;
               _loc1_.y = int((this.btn_prev.height - _loc1_.height) * 0.5);
               _loc1_.selected = _loc2_ == this._currentPage;
               _loc3_ += int(_loc1_.width + _loc6_);
               addChild(_loc1_);
               _loc2_++;
            }
            _loc4_ = _loc3_ + this.btn_next.width;
            if(this.txt_pages.parent != null)
            {
               this.txt_pages.parent.removeChild(this.txt_pages);
            }
         }
         else
         {
            _loc2_ = 0;
            while(_loc2_ < this._numPages)
            {
               _loc1_ = this._dots[_loc2_];
               if(_loc1_.parent != null)
               {
                  _loc1_.parent.removeChild(_loc1_);
               }
               _loc2_++;
            }
            _loc3_ = _loc4_ - this.btn_next.width - 4;
            this.txt_pages.text = this._currentPage + 1 + " / " + this._numPages;
            this.txt_pages.x = int((_loc3_ + this.btn_next.width - this.txt_pages.width) * 0.5);
            this.txt_pages.y = int(this.btn_next.y + (this.btn_next.height - this.txt_pages.height) * 0.5);
            addChild(this.txt_pages);
         }
         this.btn_next.x = _loc3_;
         this.btn_next.y = this.btn_prev.y;
      }
      
      private function onClickNav(param1:MouseEvent) : void
      {
         switch(param1.currentTarget)
         {
            case this.btn_prev:
               this.gotoPage(this._currentPage - 1,true);
               break;
            case this.btn_next:
               this.gotoPage(this._currentPage + 1,true);
         }
      }
      
      private function onClickPage(param1:MouseEvent) : void
      {
         var _loc2_:int = int(this._dots.indexOf(UIPaginationDot(param1.currentTarget)));
         this.gotoPage(_loc2_,true);
      }
      
      public function get currentPage() : int
      {
         return this._currentPage;
      }
      
      public function set currentPage(param1:int) : void
      {
         this.gotoPage(param1);
      }
      
      public function get maxWidth() : int
      {
         return this._maxWidth;
      }
      
      public function set maxWidth(param1:int) : void
      {
         this._maxWidth = param1;
         this.positionElements();
      }
      
      public function get maxDots() : int
      {
         return this._maxDots;
      }
      
      public function set maxDots(param1:int) : void
      {
         this._maxDots = param1;
         this.positionElements();
      }
      
      public function get numPages() : int
      {
         return this._numPages;
      }
      
      public function set numPages(param1:int) : void
      {
         var _loc2_:UIPaginationDot = null;
         var _loc3_:int = 0;
         if(param1 < 0)
         {
            param1 = 0;
         }
         this._numPages = param1;
         if(this._currentPage >= this._numPages)
         {
            this._currentPage = Math.max(0,this._numPages - 1);
         }
         for each(_loc2_ in this._dots)
         {
            if(_loc2_.parent != null)
            {
               _loc2_.parent.removeChild(_loc2_);
            }
         }
         this._dots.length = 0;
         _loc3_ = 0;
         while(_loc3_ < this._numPages)
         {
            _loc2_ = new UIPaginationDot();
            _loc2_.addEventListener(MouseEvent.CLICK,this.onClickPage,false,0,true);
            this._dots.push(_loc2_);
            addChild(_loc2_);
            _loc3_++;
         }
         this.btn_prev.enabled = this._currentPage > 0 && this._numPages > 1;
         this.btn_next.enabled = this._currentPage < this._numPages - 1 && this._numPages > 1;
         this.positionElements();
      }
   }
}

