package thelaststand.app.game.gui.quest
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Cubic;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import flash.text.AntiAliasType;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.BodyTextField;
   
   public class UIQuestTrackerItem extends Sprite
   {
      
      private static const STROKE:GlowFilter = new GlowFilter(3223336,1,2,2,10,1,true);
      
      private static const ICON_HIGHLIGHT:DropShadowFilter = new DropShadowFilter(1,45,16777215,0.25,2,2,10,1,true);
      
      private static const BMP_HEADER_COLLAPSE:BitmapData = new BmpIconNext();
      
      private static const BMP_COLLAPSE:BitmapData = new BmpIconCollapse();
      
      private static const BMP_EXPAND:BitmapData = new BmpIconExpand();
      
      private var _label:String;
      
      private var _width:int = 200;
      
      private var _iconAreaWidth:int = 25;
      
      private var _headerHeight:int = 24;
      
      private var _headerWidth:int;
      
      private var _contentHeight:int;
      
      private var _expanded:Boolean;
      
      private var _color:uint = 1075865;
      
      private var _isHeader:Boolean;
      
      private var _reqItems:Vector.<UIQuestTrackerItemRow>;
      
      private var bmp_icon:Bitmap;
      
      private var bmp_controlIcon:Bitmap;
      
      private var mc_hitArea:Sprite;
      
      private var mc_iconArea:Shape;
      
      private var mc_header:Sprite;
      
      private var mc_progress:Shape;
      
      private var mc_contentBG:Shape;
      
      private var mc_content:Sprite;
      
      private var mc_contentMask:Shape;
      
      private var txt_label:BodyTextField;
      
      public function UIQuestTrackerItem(param1:Boolean = false)
      {
         super();
         this._isHeader = param1;
         this._headerWidth = this._width - this._iconAreaWidth;
         this._reqItems = new Vector.<UIQuestTrackerItemRow>();
         this.mc_hitArea = new Sprite();
         addChildAt(this.mc_hitArea,0);
         hitArea = this.mc_hitArea;
         this.mc_iconArea = new Shape();
         this.mc_iconArea.alpha = 0.8;
         addChild(this.mc_iconArea);
         this.bmp_icon = new Bitmap();
         addChild(this.bmp_icon);
         if(!this._isHeader)
         {
            this.mc_progress = new Shape();
            this.mc_progress.alpha = 0.35;
            this.mc_progress.x = this._iconAreaWidth + 1;
            this.mc_progress.y = 2;
            this.mc_contentBG = new Shape();
            this.mc_contentMask = new Shape();
            this.mc_content = new Sprite();
            this.mc_content.mouseEnabled = this.mc_content.mouseChildren = false;
         }
         this.mc_header = new Sprite();
         this.mc_header.mouseEnabled = this.mc_header.mouseChildren = false;
         this.mc_header.x = this._iconAreaWidth;
         addChild(this.mc_header);
         this.txt_label = new BodyTextField({
            "text":" ",
            "color":16777215,
            "size":13,
            "bold":true,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_label.mouseEnabled = false;
         addChild(this.txt_label);
         this.bmp_controlIcon = new Bitmap(this._isHeader ? BMP_HEADER_COLLAPSE : BMP_EXPAND);
         addChild(this.bmp_controlIcon);
         this.drawIcon();
         this.drawHeader();
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.drawIcon();
         this.drawHeader();
         this.drawContent();
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         TweenMax.killChildTweensOf(this);
         this.clearRequirementsList();
         this.txt_label.dispose();
         this.bmp_controlIcon.bitmapData = null;
         this.bmp_icon.bitmapData.dispose();
         this.bmp_icon.bitmapData = null;
         this.mc_iconArea.filters = [];
         removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
      }
      
      public function toggleState() : void
      {
         if(this._isHeader)
         {
            return;
         }
         this._expanded = !this._expanded;
         if(this._expanded)
         {
            this.bmp_controlIcon.bitmapData = BMP_COLLAPSE;
            addChild(this.mc_contentBG);
            addChild(this.mc_contentMask);
            addChild(this.mc_content);
         }
         else
         {
            this.bmp_controlIcon.bitmapData = BMP_EXPAND;
         }
         this.bmp_controlIcon.x = int(this.mc_header.x + this._headerWidth - 12 - this.bmp_controlIcon.width * 0.5);
         this.bmp_controlIcon.y = int(this.mc_header.y + (this._headerHeight - this.bmp_controlIcon.height) * 0.5);
         TweenMax.to(this.mc_contentBG,0.25,{
            "scaleY":(this._expanded ? 1 : 0),
            "ease":Cubic.easeInOut,
            "onUpdate":function():void
            {
               mc_contentMask.height = mc_contentBG.height;
            },
            "onComplete":function():void
            {
               if(!_expanded)
               {
                  if(mc_content.parent != null)
                  {
                     mc_content.parent.removeChild(mc_content);
                  }
                  if(mc_contentBG.parent != null)
                  {
                     mc_contentBG.parent.removeChild(mc_contentBG);
                  }
                  if(mc_contentMask.parent != null)
                  {
                     mc_contentMask.parent.removeChild(mc_contentMask);
                  }
               }
            }
         });
      }
      
      private function drawIcon() : void
      {
         this.mc_iconArea.graphics.clear();
         this.mc_iconArea.graphics.beginFill(this._color);
         this.mc_iconArea.graphics.drawRoundRectComplex(0,0,this._iconAreaWidth,this._headerHeight,4,0,4,0);
         this.mc_iconArea.graphics.endFill();
         this.mc_iconArea.filters = [ICON_HIGHLIGHT,STROKE];
         this.bmp_icon.x = int((this._iconAreaWidth - this.bmp_icon.width) * 0.5 + 1);
         this.bmp_icon.y = int((this._headerHeight - this.bmp_icon.height) * 0.5);
      }
      
      private function drawHeader() : void
      {
         this.mc_hitArea.graphics.clear();
         this.mc_hitArea.graphics.beginFill(16711680,0);
         this.mc_hitArea.graphics.drawRect(0,0,this._width,this._headerHeight);
         this.mc_hitArea.graphics.endFill();
         this.mc_header.graphics.clear();
         this.mc_header.graphics.beginFill(3223336,0.8);
         this.mc_header.graphics.drawRect(0,0,this._headerWidth,this._headerHeight);
         this.mc_header.graphics.drawRect(0,1,this._headerWidth - 1,this._headerHeight - 2);
         this.mc_header.graphics.endFill();
         this.mc_header.graphics.beginFill(0,0.8);
         this.mc_header.graphics.drawRect(0,1,this._headerWidth - 1,this._headerHeight - 2);
         this.mc_header.graphics.endFill();
         if(!this._isHeader)
         {
            this.mc_progress.graphics.clear();
            this.mc_progress.graphics.beginFill(8882055);
            this.mc_progress.graphics.drawRect(0,0,this._headerWidth - 4,this._headerHeight - 4);
            this.mc_progress.graphics.endFill();
            this.mc_progress.scaleX = 0;
         }
         this.bmp_controlIcon.x = int(this.mc_header.x + this._headerWidth - 12 - this.bmp_controlIcon.width * 0.5);
         this.bmp_controlIcon.y = int(this.mc_header.y + (this._headerHeight - this.bmp_controlIcon.height) * 0.5);
         this.txt_label.x = int(this.mc_header.x + 4);
         this.txt_label.y = int(this.mc_header.y + (this._headerHeight - this.txt_label.height) * 0.5);
      }
      
      private function drawContent() : void
      {
         if(this._isHeader)
         {
            return;
         }
         this.updateRequirementsDisplay();
         this.mc_content.y = int(this.mc_header.x + 4);
         this.mc_content.x = int(this.mc_header.y + this._headerHeight + 4);
         this._contentHeight = int(this.mc_content.height + 8);
         this.mc_contentBG.graphics.clear();
         this.mc_contentBG.graphics.beginFill(3223336,0.8);
         this.mc_contentBG.graphics.drawRect(0,0,this._headerWidth,this._contentHeight);
         this.mc_contentBG.graphics.drawRect(1,1,this._headerWidth - 2,this._contentHeight - 2);
         this.mc_contentBG.graphics.endFill();
         this.mc_contentBG.graphics.beginFill(0,0.4);
         this.mc_contentBG.graphics.drawRect(1,1,this._headerWidth - 2,this._contentHeight - 2);
         this.mc_contentBG.graphics.endFill();
         this.mc_contentBG.x = int(this.mc_header.x);
         this.mc_contentBG.y = int(this.mc_header.y + this._headerHeight);
         this.mc_contentBG.scaleY = this._expanded ? 1 : 0;
         this.mc_contentMask.graphics.clear();
         this.mc_contentMask.graphics.beginFill(16711680);
         this.mc_contentMask.graphics.drawRect(0,0,this._headerWidth,this._contentHeight);
         this.mc_contentMask.graphics.endFill();
         this.mc_contentMask.x = this.mc_contentBG.x;
         this.mc_contentMask.y = this.mc_contentBG.y;
         this.mc_contentMask.height = this.mc_contentBG.height;
         this.mc_content.mask = this.mc_contentMask;
      }
      
      protected function setProgress(param1:Number) : void
      {
         if(this._isHeader)
         {
            return;
         }
         if(param1 < 0)
         {
            param1 = 0;
         }
         else if(param1 > 1)
         {
            param1 = 1;
         }
         this.mc_progress.scaleX = param1;
         addChildAt(this.mc_progress,getChildIndex(this.mc_header) + 1);
      }
      
      protected function clearRequirementsList() : void
      {
         var _loc1_:UIQuestTrackerItemRow = null;
         for each(_loc1_ in this._reqItems)
         {
            _loc1_.dispose();
         }
         this._reqItems.length = 0;
      }
      
      protected function addRequirementRow() : UIQuestTrackerItemRow
      {
         var _loc1_:UIQuestTrackerItemRow = new UIQuestTrackerItemRow();
         this.mc_content.addChild(_loc1_);
         this._reqItems.push(_loc1_);
         return _loc1_;
      }
      
      protected function updateRequirementsDisplay() : void
      {
         var _loc3_:UIQuestTrackerItemRow = null;
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this._reqItems.length)
         {
            _loc3_ = this._reqItems[_loc2_];
            _loc3_.y = _loc1_;
            _loc1_ += int(_loc3_.height + _loc3_.spacing);
            _loc2_++;
         }
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         TweenMax.to(this.bmp_controlIcon,0.15,{
            "glowFilter":{
               "color":16777215,
               "alpha":1,
               "blurX":12,
               "blurY":12,
               "strength":0.75,
               "quality":1
            },
            "colorTransform":{"exposure":1.25}
         });
         TweenMax.to(this.bmp_icon,0.15,{
            "glowFilter":{
               "color":16777215,
               "alpha":1,
               "blurX":12,
               "blurY":12,
               "strength":0.75,
               "quality":1
            },
            "colorTransform":{"exposure":1.15}
         });
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         TweenMax.to(this.bmp_controlIcon,0.25,{
            "glowFilter":{
               "alpha":0,
               "remove":true
            },
            "colorTransform":{"exposure":1}
         });
         TweenMax.to(this.bmp_icon,0.25,{
            "glowFilter":{
               "alpha":0,
               "remove":true
            },
            "colorTransform":{"exposure":1}
         });
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         Audio.sound.play("sound/interface/int-click.mp3");
      }
      
      public function get expanded() : Boolean
      {
         return this._expanded;
      }
      
      public function get color() : uint
      {
         return this._color;
      }
      
      public function set color(param1:uint) : void
      {
         this._color = param1;
         this.drawIcon();
      }
      
      public function get label() : String
      {
         return this._label;
      }
      
      public function set label(param1:String) : void
      {
         this._label = param1;
         if(this._label.length > 22)
         {
            this.txt_label.text = this._label.substr(0,19) + "...";
         }
         else
         {
            this.txt_label.text = this._label;
         }
      }
      
      public function get icon() : BitmapData
      {
         return this.bmp_icon.bitmapData;
      }
      
      public function set icon(param1:BitmapData) : void
      {
         this.bmp_icon.bitmapData = param1;
         this.bmp_icon.x = int((this._iconAreaWidth - this.bmp_icon.width) * 0.5 + 1);
         this.bmp_icon.y = int((this._headerHeight - this.bmp_icon.height) * 0.5);
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
         return this._expanded ? int(this._headerHeight + this._contentHeight) : this._headerHeight;
      }
      
      override public function set height(param1:Number) : void
      {
      }
      
      public function get headerWidth() : int
      {
         return this._headerWidth;
      }
   }
}

