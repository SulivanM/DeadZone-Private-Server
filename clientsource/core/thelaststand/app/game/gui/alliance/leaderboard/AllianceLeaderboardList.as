package thelaststand.app.game.gui.alliance.leaderboard
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Quad;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   import flash.text.AntiAliasType;
   import thelaststand.app.core.Config;
   import thelaststand.app.data.AllianceDialogState;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.gui.lists.UIGenericListHeader;
   import thelaststand.app.game.gui.lists.UIListSeparator;
   import thelaststand.app.gui.UIBusySpinner;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.network.Network;
   import thelaststand.common.lang.Language;
   
   public class AllianceLeaderboardList extends Sprite
   {
      
      private var _width:Number = 495;
      
      private var _listHeight:Number = 350;
      
      private var background:Shape;
      
      private var containerMask:Shape;
      
      private var container:Sprite;
      
      private var page:Sprite;
      
      private var pageBMP:Bitmap;
      
      private var btn_next:PushButton;
      
      private var btn_prev:PushButton;
      
      private var _items:Vector.<AllianceLeaderboardListItem>;
      
      private var _currentPage:int;
      
      private var _currentFinalPage:int = -1;
      
      private var _transitioning:Boolean = false;
      
      private var _spinner:UIBusySpinner;
      
      private var _loader:URLLoader;
      
      private var headers:Vector.<UIGenericListHeader>;
      
      private var separators:Vector.<UIListSeparator>;
      
      private var _round:int = -1;
      
      private var _recordsPerPage:int = 8;
      
      private var _maxRecords:int = 100;
      
      private var txt_empty:BodyTextField;
      
      public function AllianceLeaderboardList(param1:int, param2:int = 0)
      {
         var _loc6_:int = 0;
         var _loc8_:UIGenericListHeader = null;
         var _loc9_:UIListSeparator = null;
         var _loc10_:AllianceLeaderboardListItem = null;
         super();
         this._round = param1;
         this.background = new Shape();
         addChild(this.background);
         this.container = new Sprite();
         addChild(this.container);
         this.containerMask = new Shape();
         addChild(this.containerMask);
         var _loc3_:Language = Language.getInstance();
         this.headers = new Vector.<UIGenericListHeader>();
         this.separators = new Vector.<UIListSeparator>();
         var _loc4_:Array = [{
            "width":40,
            "label":_loc3_.getString("alliance.top100_header_num")
         },{
            "width":265,
            "label":_loc3_.getString("alliance.top100_header_name")
         },{
            "width":102,
            "label":_loc3_.getString("alliance.top100_header_pts")
         },{
            "width":80,
            "label":_loc3_.getString("alliance.top100_header_efficiency")
         }];
         var _loc5_:int = 0;
         _loc6_ = 0;
         while(_loc6_ < _loc4_.length)
         {
            _loc8_ = new UIGenericListHeader(_loc4_[_loc6_].label,22);
            _loc8_.width = _loc4_[_loc6_].width;
            _loc8_.x = _loc5_;
            this.container.addChildAt(_loc8_,0);
            this.headers.push(_loc8_);
            _loc5_ += _loc4_[_loc6_].width;
            if(_loc6_ < _loc4_.length - 1)
            {
               _loc9_ = new UIListSeparator(22);
               _loc9_.x = _loc5_ - int(_loc9_.width * 0.5);
               this.container.addChild(_loc9_);
               this.separators.push(_loc9_);
            }
            _loc6_++;
         }
         var _loc7_:BitmapData = new BitmapData(this._width,this._listHeight,false,1973790);
         this.pageBMP = new Bitmap(_loc7_,"auto",true);
         this.pageBMP.y = 23;
         this.container.addChildAt(this.pageBMP,0);
         this.page = new Sprite();
         this.page.y = this.pageBMP.y;
         this.container.addChildAt(this.page,1);
         this.page.visible = false;
         this._items = new Vector.<AllianceLeaderboardListItem>();
         _loc6_ = 0;
         while(_loc6_ < this._recordsPerPage)
         {
            _loc10_ = new AllianceLeaderboardListItem();
            _loc10_.y = _loc6_ * _loc10_.height;
            _loc10_.alternating = _loc6_ % 2 == 0;
            this.page.addChild(_loc10_);
            this._items.push(_loc10_);
            _loc6_++;
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
         this.txt_empty = new BodyTextField({
            "text":Language.getInstance().getString("alliance.top100_noRecords"),
            "color":16777215,
            "size":14,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_empty.x = int((this._width - this.txt_empty.width) * 0.5);
         this.txt_empty.y = int((this._listHeight - this.txt_empty.height) * 0.5);
         this._loader = new URLLoader();
         this._loader.addEventListener(Event.COMPLETE,this.onLoaderComplete,false,0,true);
         this._loader.addEventListener(IOErrorEvent.IO_ERROR,this.onLoaderError,false,0,true);
         this.changePage(param2);
      }
      
      public function dispose() : void
      {
         var _loc1_:AllianceLeaderboardListItem = null;
         try
         {
            this._loader.close();
         }
         catch(error:Error)
         {
         }
         while(this.headers.length > 0)
         {
            this.headers.pop().dispose();
         }
         this.headers = null;
         while(this.separators.length > 0)
         {
            this.separators.pop().dispose();
         }
         this.separators = null;
         this.btn_next.dispose();
         this.btn_next = null;
         this.btn_prev.dispose();
         this.btn_prev = null;
         this.txt_empty.dispose();
         this.txt_empty = null;
         for each(_loc1_ in this._items)
         {
            _loc1_.dispose();
         }
         this._items = null;
         this.pageBMP.bitmapData.dispose();
         this.pageBMP = null;
         TweenMax.killChildTweensOf(this);
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
         var _loc1_:AllianceLeaderboardListItem = null;
         this._spinner.visible = true;
         for each(_loc1_ in this._items)
         {
            _loc1_.data = null;
         }
      }
      
      public function changePage(param1:int) : void
      {
         var vars:URLVariables;
         var request:URLRequest;
         var slideLeft:Boolean = false;
         var pgNum:int = param1;
         if(this._currentFinalPage > -1 && pgNum > this._currentFinalPage)
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
         AllianceDialogState.getInstance().alliancePage = pgNum;
         try
         {
            this._loader.close();
         }
         catch(e:Error)
         {
         }
         vars = new URLVariables();
         vars.action = "list";
         vars.round = this._round;
         vars.offset = this._recordsPerPage * pgNum;
         vars.limit = this._recordsPerPage;
         vars.service = Network.getInstance().service;
         request = new URLRequest(Config.getPath("alliance_url"));
         request.method = URLRequestMethod.POST;
         request.data = vars;
         this._loader.load(request);
      }
      
      private function draw() : void
      {
         this.background.graphics.clear();
         this.background.graphics.beginFill(7763574);
         this.background.graphics.drawRect(0,0,this._width,this._listHeight);
         this.background.graphics.endFill();
         this.background.graphics.beginFill(1973790);
         this.background.graphics.drawRect(1,1,this._width - 2,this._listHeight - 2);
         this.background.graphics.endFill();
         this.container.x = this.container.y = 4;
         this.containerMask.x = this.container.x;
         this.containerMask.y = this.container.y;
         this.containerMask.graphics.clear();
         this.containerMask.graphics.beginFill(16711680,0.25);
         this.containerMask.graphics.drawRect(0,0,this._width - 8,this._listHeight - 6);
         this.containerMask.graphics.endFill();
         this.container.mask = this.containerMask;
         var _loc1_:int = (this._width - (this.btn_prev.width + this.btn_next.width + 18)) * 0.5;
         this.btn_prev.x = _loc1_;
         this.btn_next.x = _loc1_ + this.btn_prev.width + 18;
         this.btn_prev.y = this.btn_next.y = this._listHeight + 7;
      }
      
      private function onLoaderComplete(param1:Event) : void
      {
         var i:int;
         var max:Number;
         var obj:Object = null;
         var e:Event = param1;
         try
         {
            obj = JSON.parse(URLLoader(e.target).data);
         }
         catch(e:Error)
         {
            return;
         }
         if(obj.success != true)
         {
            return;
         }
         if(obj.offset != this._currentPage * this._recordsPerPage)
         {
            return;
         }
         if(obj.round != this._round)
         {
            return;
         }
         i = 0;
         while(i < obj.table.length)
         {
            obj.table[i].rank = obj.offset + i + 1;
            if(this._currentPage * this._recordsPerPage + i < this._maxRecords)
            {
               this._items[i].data = obj.table[i];
            }
            else
            {
               this._items[i].data = null;
            }
            i++;
         }
         this._spinner.visible = false;
         max = Math.min(this._maxRecords,obj.totalRecords - 1);
         this._currentFinalPage = Math.floor(max / this._recordsPerPage);
         if(obj.totalRecords <= 0)
         {
            addChild(this.txt_empty);
            this.page.visible = false;
         }
         else
         {
            if(this.txt_empty.parent)
            {
               this.txt_empty.parent.removeChild(this.txt_empty);
            }
            this.page.visible = true;
         }
         this.updateButtons();
      }
      
      private function onLoaderError(param1:IOErrorEvent) : void
      {
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
      
      public function get round() : int
      {
         return this._round;
      }
      
      public function set round(param1:int) : void
      {
         if(param1 < -1)
         {
            param1 = -1;
         }
         if(param1 == this._round)
         {
            return;
         }
         this._round = param1;
         this.changePage(0);
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

