package thelaststand.app.game.gui.bounty
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Quad;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import org.osflash.signals.Signal;
   import thelaststand.app.game.logic.bounty.BountyListLogic;
   import thelaststand.app.gui.UIBusySpinner;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.network.RemotePlayerData;
   
   public class BountyList extends Sprite
   {
      
      public static const LAYOUT_BOUNTIES:String = "bounties";
      
      public static const LAYOUT_HUNTERS:String = "hunters";
      
      public static const LAYOUT_ALLTIME:String = "alltime";
      
      public var actioned:Signal;
      
      private var _width:Number = 768;
      
      private var _listHeight:Number = 312;
      
      private var _logic:BountyListLogic;
      
      private var background:Shape;
      
      private var containerMask:Shape;
      
      private var container:Sprite;
      
      private var headers:HeaderBar;
      
      private var page:Sprite;
      
      private var pageBMP:Bitmap;
      
      private var btn_next:PushButton;
      
      private var btn_prev:PushButton;
      
      private var _items:Vector.<BountyListItem>;
      
      private var _currentCategory:String;
      
      private var _currentPage:int;
      
      private var _currentFinalPage:int;
      
      private var _transitioning:Boolean = false;
      
      private var _spinner:UIBusySpinner;
      
      public function BountyList()
      {
         var _loc3_:BountyListItem = null;
         super();
         this.actioned = new Signal(RemotePlayerData,String);
         this._logic = new BountyListLogic();
         this._logic.onPageReady.add(this.onPageReady);
         this.background = new Shape();
         addChild(this.background);
         this.container = new Sprite();
         addChild(this.container);
         this.containerMask = new Shape();
         addChild(this.containerMask);
         this.headers = new HeaderBar();
         this.container.addChild(this.headers);
         var _loc1_:BitmapData = new BitmapData(this._width,this._listHeight,false,0);
         this.pageBMP = new Bitmap(_loc1_,"auto",true);
         this.pageBMP.y = 25;
         this.container.addChildAt(this.pageBMP,0);
         this.page = new Sprite();
         this.page.y = this.pageBMP.y;
         this.container.addChildAt(this.page,1);
         this._items = new Vector.<BountyListItem>();
         var _loc2_:int = 0;
         while(_loc2_ < 5)
         {
            _loc3_ = new BountyListItem();
            _loc3_.y = _loc2_ * _loc3_.height;
            _loc3_.alternating = _loc2_ % 2 == 0;
            this.page.addChild(_loc3_);
            this._items.push(_loc3_);
            _loc3_.actioned.add(this.onItemActioned);
            _loc2_++;
         }
         this._spinner = new UIBusySpinner();
         this._spinner.scaleX = this._spinner.scaleY = 2;
         this._spinner.x = int(this._width * 0.5);
         this._spinner.y = int(this._listHeight * 0.5);
         this.page.addChild(this._spinner);
         this.btn_next = new PushButton("",new BmpIconButtonNext());
         this.btn_next.width = this.btn_next.height;
         this.btn_next.clicked.add(this.onButtonClicked);
         addChild(this.btn_next);
         this.btn_next.enabled = false;
         this.btn_prev = new PushButton("",new BmpIconButtonPrev());
         this.btn_prev.width = this.btn_prev.height;
         this.btn_prev.clicked.add(this.onButtonClicked);
         addChild(this.btn_prev);
         this.btn_prev.enabled = false;
         this.draw();
      }
      
      public function dispose() : void
      {
         var _loc1_:BountyListItem = null;
         this._logic.dispose();
         this.btn_next.dispose();
         this.btn_next = null;
         this.btn_prev.dispose();
         this.btn_prev = null;
         for each(_loc1_ in this._items)
         {
            _loc1_.dispose();
         }
         this._items = null;
         this.actioned.removeAll();
         this.pageBMP.bitmapData.dispose();
         this.pageBMP = null;
         TweenMax.killChildTweensOf(this);
      }
      
      public function changeCategory(param1:String) : void
      {
         var _loc2_:String = null;
         var _loc3_:BountyListItem = null;
         switch(param1)
         {
            case BountyListLogic.BEST_BOUNTY_HUNTERS:
               _loc2_ = LAYOUT_HUNTERS;
               break;
            case BountyListLogic.ALL_TIME_BOUNTIES:
               _loc2_ = LAYOUT_ALLTIME;
               break;
            default:
               _loc2_ = LAYOUT_BOUNTIES;
         }
         this.headers.setLayout(_loc2_);
         for each(_loc3_ in this._items)
         {
            _loc3_.setLayout(_loc2_);
         }
         this.btn_next.enabled = this.btn_prev.enabled = false;
         this._currentCategory = param1;
         this._currentPage = 0;
         this._currentFinalPage = int.MAX_VALUE;
         this.clearCurrentList();
         TweenMax.killTweensOf(this.page);
         this.page.x = 0;
         this._transitioning = false;
         this._logic.getPage(this._currentCategory,0);
      }
      
      private function onPageReady(param1:Vector.<RemotePlayerData>, param2:int) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:int = 0;
         this._currentFinalPage = param2;
         this._spinner.visible = false;
         if(param1.length > 0)
         {
            _loc3_ = Math.min(param1.length,this._items.length);
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               this._items[_loc4_].remotePlayerData = param1[_loc4_];
               _loc4_++;
            }
         }
         this.updateButtons();
      }
      
      private function updateButtons() : void
      {
         if(this._transitioning)
         {
            return;
         }
         this.btn_prev.enabled = this._currentPage > 0;
         this.btn_next.enabled = this._currentPage < this._currentFinalPage;
      }
      
      private function clearCurrentList() : void
      {
         var _loc1_:BountyListItem = null;
         this._spinner.visible = true;
         for each(_loc1_ in this._items)
         {
            _loc1_.remotePlayerData = null;
         }
      }
      
      private function changePage(param1:int) : void
      {
         var slideLeft:Boolean = false;
         var pgNum:int = param1;
         if(pgNum > this._currentFinalPage)
         {
            pgNum = this._currentFinalPage;
         }
         if(pgNum < 0)
         {
            pgNum = 0;
         }
         this.btn_next.enabled = this.btn_prev.enabled = false;
         if(pgNum != this._currentPage)
         {
            slideLeft = pgNum > this._currentPage;
            this.pageBMP.bitmapData.draw(this.page);
            this._transitioning = true;
            this.page.x = slideLeft ? this._width : -this._width;
            TweenMax.to(this.page,0.25,{
               "x":0,
               "ease":Quad.easeInOut,
               "onComplete":function():void
               {
                  _transitioning = false;
                  updateButtons();
               }
            });
            this.pageBMP.x = 0;
            TweenMax.to(this.pageBMP,0.25,{
               "x":(slideLeft ? -this._width : this._width),
               "ease":Quad.easeInOut,
               "onComplete":function():void
               {
                  _transitioning = false;
                  updateButtons();
               }
            });
         }
         this.clearCurrentList();
         this._currentPage = pgNum;
         this._logic.getPage(this._currentCategory,this._currentPage);
      }
      
      private function draw() : void
      {
         this.background.graphics.clear();
         this.background.graphics.beginFill(7763574);
         this.background.graphics.drawRect(0,0,this._width,this._listHeight);
         this.background.graphics.endFill();
         this.background.graphics.beginFill(2434341);
         this.background.graphics.drawRect(1,1,this._width - 2,this._listHeight - 2);
         this.background.graphics.endFill();
         this.containerMask.graphics.clear();
         this.containerMask.graphics.beginFill(16711680,0.25);
         this.containerMask.graphics.drawRect(1,1,this._width - 2,this._listHeight - 2);
         this.containerMask.graphics.endFill();
         this.container.mask = this.containerMask;
         var _loc1_:int = (this._width - (this.btn_prev.width + this.btn_next.width + 18)) * 0.5;
         this.btn_prev.x = _loc1_;
         this.btn_next.x = _loc1_ + this.btn_prev.width + 18;
         this.btn_prev.y = this.btn_next.y = this._listHeight + 15;
      }
      
      private function onButtonClicked(param1:MouseEvent) : void
      {
         switch(param1.target)
         {
            case this.btn_next:
               this.changePage(this._currentPage + 1);
               break;
            case this.btn_prev:
               this.changePage(this._currentPage - 1);
         }
      }
      
      private function onItemActioned(param1:RemotePlayerData, param2:String) : void
      {
         this.actioned.dispatch(param1,param2);
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
         return this.btn_next.y + this.btn_next.height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
      
      public function get listHeight() : Number
      {
         return this._listHeight;
      }
   }
}

import flash.display.Sprite;
import flash.text.AntiAliasType;
import thelaststand.app.display.BodyTextField;
import thelaststand.app.display.Effects;
import thelaststand.app.game.gui.lists.UIListSeparator;
import thelaststand.common.lang.Language;

class HeaderBar extends Sprite
{
   
   private var _width:Number = 768;
   
   private var _headings:Vector.<ColumnHeader>;
   
   private var _separators:Vector.<UIListSeparator>;
   
   private var _layout:String = "";
   
   private var bountiesInfo:Array = [{"width":74},{"width":220},{
      "width":150,
      "label":Language.getInstance().getString("bounty.col_expiry")
   },{
      "width":166,
      "label":Language.getInstance().getString("bounty.col_total")
   },{"width":0}];
   
   private var huntersInfo:Array = [{"width":74},{"width":220},{
      "width":316,
      "label":Language.getInstance().getString("bounty.col_collected")
   },{
      "width":0,
      "label":Language.getInstance().getString("bounty.col_count")
   }];
   
   private var alltimeInfo:Array = [{"width":74},{"width":220},{
      "width":316,
      "label":Language.getInstance().getString("bounty.col_allTime")
   },{
      "width":0,
      "label":Language.getInstance().getString("bounty.col_allTimeCount")
   }];
   
   public function HeaderBar()
   {
      super();
      this._headings = new Vector.<ColumnHeader>();
      this._separators = new Vector.<UIListSeparator>();
   }
   
   public function dispose() : void
   {
      var _loc1_:ColumnHeader = null;
      var _loc2_:UIListSeparator = null;
      for each(_loc1_ in this._headings)
      {
         _loc1_.dispose();
      }
      this._headings = null;
      for each(_loc2_ in this._separators)
      {
         _loc2_.dispose();
      }
      this._separators = null;
   }
   
   public function setLayout(param1:String) : void
   {
      var _loc2_:Array = null;
      var _loc4_:ColumnHeader = null;
      var _loc6_:UIListSeparator = null;
      var _loc9_:Object = null;
      var _loc10_:Number = NaN;
      switch(param1)
      {
         case BountyList.LAYOUT_ALLTIME:
            _loc2_ = this.alltimeInfo;
            break;
         case BountyList.LAYOUT_HUNTERS:
            _loc2_ = this.huntersInfo;
            break;
         default:
            param1 = BountyList.LAYOUT_BOUNTIES;
            _loc2_ = this.bountiesInfo;
      }
      if(this._layout == param1)
      {
         return;
      }
      var _loc3_:int = 0;
      var _loc5_:int = 0;
      var _loc7_:int = 0;
      var _loc8_:int = 0;
      _loc8_ = 0;
      while(_loc8_ < _loc2_.length)
      {
         _loc9_ = _loc2_[_loc8_];
         _loc10_ = _loc8_ == _loc2_.length - 1 ? this._width - _loc3_ : Number(_loc9_.width);
         if(_loc9_.label)
         {
            if(this._headings.length > _loc5_)
            {
               _loc4_ = this._headings[_loc5_];
            }
            else
            {
               _loc4_ = new ColumnHeader();
               this._headings.push(_loc4_);
            }
            _loc4_.label = _loc9_.label;
            _loc4_.x = _loc3_;
            _loc4_.y = 1;
            _loc4_.width = _loc10_;
            addChildAt(_loc4_,0);
            _loc5_++;
         }
         if(_loc8_ < _loc2_.length - 1)
         {
            if(this._separators.length > _loc7_)
            {
               _loc6_ = this._separators[_loc7_];
            }
            else
            {
               _loc6_ = new UIListSeparator(1);
               this._separators.push(_loc6_);
            }
            addChild(_loc6_);
            _loc6_.x = _loc3_ + _loc10_;
            _loc6_.y = 1;
            _loc6_.height = 24;
            _loc7_++;
         }
         _loc3_ += _loc10_;
         _loc8_++;
      }
      _loc8_ = _loc5_;
      while(_loc8_ < this._headings.length)
      {
         if(this._headings[_loc8_].parent)
         {
            this._headings[_loc8_].parent.removeChild(this._headings[_loc8_]);
         }
         _loc8_++;
      }
      _loc8_ = _loc7_;
      while(_loc8_ < this._separators.length)
      {
         if(this._separators[_loc8_].parent)
         {
            this._separators[_loc8_].parent.removeChild(this._separators[_loc8_]);
         }
         _loc8_++;
      }
   }
}

class ColumnHeader extends Sprite
{
   
   private var _width:Number = 100;
   
   private var _height:Number = 24;
   
   private var txt_label:BodyTextField;
   
   public function ColumnHeader()
   {
      super();
      this.txt_label = new BodyTextField({
         "text":"",
         "color":5987163,
         "size":12,
         "bold":true,
         "filters":[Effects.TEXT_SHADOW],
         "antiAliasType":AntiAliasType.ADVANCED
      });
      this.txt_label.y = 4;
      addChild(this.txt_label);
      this.redraw();
   }
   
   public function dispose() : void
   {
      this.txt_label.dispose();
   }
   
   private function redraw() : void
   {
      graphics.clear();
      graphics.beginFill(2434341,1);
      graphics.drawRect(0,0,this._width,this._height);
      this.txt_label.x = int((this._width - this.txt_label.width) * 0.5);
   }
   
   override public function get width() : Number
   {
      return this._width;
   }
   
   override public function set width(param1:Number) : void
   {
      this._width = param1;
      this.redraw();
   }
   
   public function get label() : String
   {
      return this.txt_label.text;
   }
   
   public function set label(param1:String) : void
   {
      this.txt_label.text = param1;
      this.redraw();
   }
}
