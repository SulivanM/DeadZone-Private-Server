package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.data.NavigationLocation;
   import thelaststand.app.events.NavigationEvent;
   import thelaststand.app.game.gui.lists.UINeighborhoodList;
   import thelaststand.app.gui.UIPagination;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.network.RemotePlayerData;
   import thelaststand.common.lang.Language;
   
   public class NeighborhoodListDialogue extends BaseDialogue
   {
      
      private var _lang:Language;
      
      private var mc_container:Sprite = new Sprite();
      
      private var ui_list:UINeighborhoodList;
      
      private var ui_page:UIPagination;
      
      private var ui_searchInput:SearchInput;
      
      public function NeighborhoodListDialogue()
      {
         super("neighborhoodList",this.mc_container,true);
         _autoSize = false;
         _width = 798;
         _height = 446;
         this._lang = Language.getInstance();
         addTitle(this._lang.getString("map_list_title"),13255197);
         this.ui_list = new UINeighborhoodList();
         this.ui_list.y = int(_padding * 0.5);
         this.ui_list.width = 770;
         this.ui_list.height = 370;
         this.ui_list.actioned.add(this.onNeighborActioned);
         this.ui_list.filtered.add(this.onListFiltered);
         this.mc_container.addChild(this.ui_list);
         this.ui_page = new UIPagination(this.ui_list.numPages,0);
         this.ui_page.x = int((_width - _padding * 2 - this.ui_page.width) * 0.5);
         this.ui_page.y = int(_height - this.ui_page.height - _padding * 2);
         this.ui_page.changed.add(this.onPageChanged);
         this.mc_container.addChild(this.ui_page);
         this.ui_searchInput = new SearchInput();
         this.ui_searchInput.x = _width - this.ui_searchInput.width - 56;
         this.ui_searchInput.y = 13;
         this.ui_searchInput.onSubmit.add(this.onSearchSubmit);
         sprite.addChild(this.ui_searchInput);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._lang = null;
         this.ui_list.dispose();
         this.ui_list = null;
         this.ui_page.dispose();
         this.ui_page = null;
         this.ui_searchInput.dispose();
         this.ui_searchInput = null;
      }
      
      override public function open() : void
      {
         super.open();
         Tracking.trackPageview("compoundList");
      }
      
      private function onSearchSubmit(param1:String) : void
      {
         this.ui_list.setStringFilter(param1);
      }
      
      private function onNeighborActioned(param1:RemotePlayerData, param2:String) : void
      {
         var neighbor:RemotePlayerData = param1;
         var action:String = param2;
         switch(action)
         {
            case "attack":
               neighbor.attemptAttack(false,function(param1:Boolean):void
               {
                  if(param1)
                  {
                     Tracking.trackEvent("CompoundList","Attack",neighbor.isFriend ? "friend" : "unknown");
                     close();
                  }
               });
               return;
            case "help":
               Tracking.trackEvent("CompoundList",neighbor.isFriend ? "Help" : "View");
               this.mc_container.dispatchEvent(new NavigationEvent(NavigationEvent.REQUEST,NavigationLocation.NEIGHBOR_COMPOUND,neighbor));
         }
         close();
      }
      
      private function onListFiltered(param1:String, param2:Boolean) : void
      {
         if(param2 == false)
         {
            Tracking.trackEvent("CompoundList","Filter",param1);
         }
         if(this.ui_page.numPages != this.ui_list.numPages)
         {
            this.ui_page.numPages = this.ui_list.numPages;
            this.ui_page.x = int((_width - _padding * 2 - this.ui_page.width) * 0.5);
         }
      }
      
      private function onPageChanged(param1:int) : void
      {
         this.ui_list.gotoPage(param1);
      }
   }
}

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.ui.Keyboard;
import flash.utils.Timer;
import org.osflash.signals.Signal;
import thelaststand.common.lang.Language;

class SearchInput extends Sprite
{
   
   private var _width:Number = 220;
   
   private var _height:Number = 24;
   
   private var _value:String = "";
   
   private var _regexTrim:RegExp = /(^\s+|\s+$)/ig;
   
   private var _timer:Timer;
   
   private var txt_input:TextField;
   
   private var btn_clear:Sprite;
   
   private var bmp_clear:Bitmap;
   
   private var bmp_search:Bitmap;
   
   public var onSubmit:Signal;
   
   public function SearchInput()
   {
      super();
      graphics.beginFill(11615516,1);
      graphics.drawRect(0,0,this._width,this._height);
      graphics.beginFill(3149574,1);
      graphics.drawRect(1,1,this._width - 2,this._height - 2);
      graphics.beginFill(7078400,1);
      graphics.drawRect(2,2,this._height - 4,this._height - 4);
      this.bmp_search = new Bitmap(new BmpIconSearch(),"auto",true);
      this.bmp_search.width = this.bmp_search.height = 16;
      this.bmp_search.x = this.bmp_search.y = 4;
      this.bmp_search.alpha = 0.5;
      addChild(this.bmp_search);
      mouseEnabled = true;
      addEventListener(MouseEvent.CLICK,this.onBoxClick,false,0,true);
      var _loc1_:TextFormat = new TextFormat("_sans",12,12145207);
      _loc1_.bold = true;
      this.txt_input = new TextField();
      this.txt_input.defaultTextFormat = _loc1_;
      this.txt_input.text = Language.getInstance().getString("map_list_filter_empty");
      this.txt_input.x = 28;
      this.txt_input.y = 3;
      this.txt_input.width = 170;
      this.txt_input.height = 16;
      this.txt_input.type = TextFieldType.INPUT;
      this.txt_input.mouseEnabled = true;
      this.txt_input.mouseWheelEnabled = false;
      this.txt_input.autoSize = TextFieldAutoSize.NONE;
      this.txt_input.wordWrap = this.txt_input.multiline = false;
      this.txt_input.maxChars = 30;
      this.txt_input.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown,false,0,true);
      this.txt_input.addEventListener(Event.CHANGE,this.onTextChange,false,0,true);
      this.txt_input.addEventListener(FocusEvent.FOCUS_IN,this.onTextFocusIn,false,0,true);
      this.txt_input.addEventListener(FocusEvent.FOCUS_OUT,this.onTextFocusOut,false,0,true);
      addChild(this.txt_input);
      this.btn_clear = new Sprite();
      this.bmp_clear = new Bitmap(new BmpIconInputClear(),"auto",true);
      this.bmp_clear.width = this.bmp_clear.height = 18;
      this.btn_clear.addChild(this.bmp_clear);
      this.btn_clear.alpha = 0.5;
      this.btn_clear.addChild(this.bmp_clear);
      this.btn_clear.mouseChildren = false;
      this.btn_clear.x = this._width - 21;
      this.btn_clear.y = int((this._height - this.btn_clear.height) * 0.5);
      this.btn_clear.visible = false;
      addChild(this.btn_clear);
      this.btn_clear.addEventListener(MouseEvent.CLICK,this.onClearClick,false,0,true);
      this._timer = new Timer(200,1);
      this._timer.addEventListener(TimerEvent.TIMER,this.onTimerComplete,false,0,true);
      this.onSubmit = new Signal(String);
   }
   
   public function dispose() : void
   {
      this.bmp_search.bitmapData.dispose();
      this.bmp_search = null;
      removeEventListener(MouseEvent.CLICK,this.onBoxClick);
      this.txt_input.removeEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown);
      this.txt_input.removeEventListener(Event.CHANGE,this.onTextChange);
      this.txt_input.removeEventListener(FocusEvent.FOCUS_IN,this.onTextFocusIn);
      this.txt_input.removeEventListener(FocusEvent.FOCUS_OUT,this.onTextFocusOut);
      this.btn_clear.removeEventListener(MouseEvent.CLICK,this.onClearClick);
      this.bmp_clear.bitmapData.dispose();
      this._timer.stop();
      this._timer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onTimerComplete);
      this.onSubmit.removeAll();
   }
   
   private function updateClearBtn() : void
   {
      this.btn_clear.visible = this._value.replace(this._regexTrim,"") != "";
   }
   
   private function onBoxClick(param1:MouseEvent) : void
   {
      stage.focus = this.txt_input;
   }
   
   private function onKeyDown(param1:KeyboardEvent) : void
   {
      if(param1.keyCode == Keyboard.ENTER)
      {
         this._timer.stop();
         this._value = this.txt_input.text;
         this.onSubmit.dispatch(this._value);
         this.txt_input.setSelection(0,this.txt_input.text.length);
      }
      if(param1.keyCode == Keyboard.ESCAPE)
      {
         this._value = this.txt_input.text = "";
         this.onSubmit.dispatch(this._value);
         this.updateClearBtn();
      }
   }
   
   private function onTextChange(param1:Event) : void
   {
      this._value = this.txt_input.text;
      this._timer.reset();
      this._timer.start();
      this.updateClearBtn();
   }
   
   private function onTextFocusIn(param1:FocusEvent) : void
   {
      if(this._value == "")
      {
         this.txt_input.text = "";
      }
      this.txt_input.textColor = 16777215;
      this.txt_input.setSelection(0,this.txt_input.text.length);
   }
   
   private function onTextFocusOut(param1:FocusEvent) : void
   {
      if(this.txt_input.text.replace(this._regexTrim,"") == "")
      {
         this._value = "";
      }
      if(this._value == "")
      {
         this.txt_input.textColor = 12145207;
         this.txt_input.text = Language.getInstance().getString("map_list_filter_empty");
      }
      this.updateClearBtn();
   }
   
   private function onClearClick(param1:MouseEvent) : void
   {
      this._value = "";
      this.txt_input.text = "";
      stage.focus = this.txt_input;
      this._timer.stop();
      this.onSubmit.dispatch(this._value);
   }
   
   private function onTimerComplete(param1:TimerEvent) : void
   {
      this.onSubmit.dispatch(this._value);
   }
}
