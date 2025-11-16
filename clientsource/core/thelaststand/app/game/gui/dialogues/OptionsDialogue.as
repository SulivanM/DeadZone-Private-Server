package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.system.Security;
   import flash.system.SecurityPanel;
   import flash.utils.Dictionary;
   import thelaststand.app.game.gui.options.UIOptionsAudio;
   import thelaststand.app.game.gui.options.UIOptionsGeneral;
   import thelaststand.app.game.gui.options.UIOptionsVideo;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.common.lang.Language;
   
   public class OptionsDialogue extends BaseDialogue
   {
      
      private static var _categories:Vector.<Object> = new <Object>[{
         "category":"general",
         "width":0.25,
         "page":UIOptionsGeneral
      },{
         "category":"video",
         "width":0.175,
         "page":UIOptionsVideo
      },{
         "category":"audio",
         "width":0.175,
         "page":UIOptionsAudio
      },{
         "category":"flash",
         "width":0.4,
         "page":null
      }];
      
      private var _categoryButtons:Vector.<PushButton>;
      
      private var _selectedButton:PushButton;
      
      private var _selectedCategory:String;
      
      private var _activePage:Sprite;
      
      private var _pagesByData:Dictionary;
      
      private var btn_ok:PushButton;
      
      private var mc_container:Sprite;
      
      public function OptionsDialogue(param1:String = null)
      {
         var _loc7_:Object = null;
         var _loc8_:PushButton = null;
         this.mc_container = new Sprite();
         super("options",this.mc_container,true);
         _width = 414;
         _height = 336;
         _autoSize = false;
         addTitle(Language.getInstance().getString("options_title"),BaseDialogue.TITLE_COLOR_GREY);
         this._pagesByData = new Dictionary(true);
         this._categoryButtons = new Vector.<PushButton>(_categories.length,true);
         var _loc2_:int = 16;
         var _loc3_:int = _width - _padding * 2 - _loc2_ * (_categories.length - 1);
         var _loc4_:int = 0;
         var _loc5_:int = int(_padding * 0.5);
         var _loc6_:int = 0;
         while(_loc6_ < _categories.length)
         {
            _loc7_ = _categories[_loc6_];
            _loc8_ = new PushButton(Language.getInstance().getString("options_" + _loc7_.category));
            _loc8_.data = _categories[_loc6_];
            _loc8_.clicked.add(this.onCategoryButtonClicked);
            _loc8_.width = int(_loc3_ * _loc7_.width);
            _loc8_.y = _loc5_;
            _loc8_.x = _loc4_;
            _loc4_ += int(_loc8_.width + _loc2_);
            this.mc_container.addChild(_loc8_);
            this._categoryButtons[_loc6_] = _loc8_;
            _loc6_++;
         }
         this.btn_ok = new PushButton(Language.getInstance().getString("options_ok"));
         this.btn_ok.clicked.addOnce(this.onClickOK);
         this.btn_ok.x = int(_width - this.btn_ok.width - _padding * 2);
         this.btn_ok.y = int(_height - this.btn_ok.height - _padding * 2 - 8);
         this.mc_container.addChild(this.btn_ok);
         this.gotoCategory(param1 || _categories[0].category);
      }
      
      override public function dispose() : void
      {
         var _loc2_:String = null;
         super.dispose();
         var _loc1_:int = 0;
         while(_loc1_ < this._categoryButtons.length)
         {
            this._categoryButtons[_loc1_].dispose();
            _loc1_++;
         }
         for(_loc2_ in this._pagesByData)
         {
            this._pagesByData[_loc2_].dispose();
         }
      }
      
      public function gotoCategory(param1:String) : void
      {
         var _loc3_:Sprite = null;
         var _loc4_:Class = null;
         if(this._selectedCategory == param1)
         {
            return;
         }
         if(param1 == "flash")
         {
            Security.showSettings(SecurityPanel.DISPLAY);
            return;
         }
         if(this._selectedButton != null)
         {
            this._selectedButton.selected = false;
            this._selectedButton = null;
         }
         if(this._activePage != null)
         {
            if(this._activePage.parent != null)
            {
               this._activePage.parent.removeChild(this._activePage);
            }
            this._activePage = null;
         }
         this._selectedCategory = param1;
         if(this._selectedCategory == null)
         {
            return;
         }
         var _loc2_:PushButton = this.getCategoryButton(param1);
         if(_loc2_ != null)
         {
            this._selectedButton = _loc2_;
            this._selectedButton.selected = true;
         }
         _loc3_ = this._pagesByData[_loc2_.data.category];
         if(_loc3_ == null)
         {
            _loc4_ = Class(_loc2_.data.page);
            _loc3_ = new _loc4_();
            this._pagesByData[_loc2_.data.category] = _loc3_;
         }
         _loc3_.x = 0;
         _loc3_.y = int(this._categoryButtons[0].y + this._categoryButtons[0].height + _padding);
         _loc3_.width = int(_width - _padding * 2 - _loc3_.x * 2);
         this.mc_container.addChild(_loc3_);
         this._activePage = _loc3_;
      }
      
      private function getCategoryButton(param1:String) : PushButton
      {
         var _loc3_:PushButton = null;
         var _loc2_:int = 0;
         while(_loc2_ < this._categoryButtons.length)
         {
            _loc3_ = this._categoryButtons[_loc2_];
            if(_loc3_.data.category == param1)
            {
               return _loc3_;
            }
            _loc2_++;
         }
         return null;
      }
      
      private function onCategoryButtonClicked(param1:MouseEvent) : void
      {
         var _loc2_:PushButton = PushButton(param1.currentTarget);
         this.gotoCategory(_loc2_.data.category);
      }
      
      private function onClickOK(param1:MouseEvent) : void
      {
         close();
      }
   }
}

