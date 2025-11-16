package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.getDefinitionByName;
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorClass;
   import thelaststand.app.game.data.SurvivorCollection;
   import thelaststand.app.game.gui.lists.UISurvivorList;
   import thelaststand.app.game.gui.lists.UISurvivorListItem;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIPagination;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.common.lang.Language;
   
   public class SurvivorListDialogue extends BaseDialogue
   {
      
      private static var _selectedClass:String = "all";
      
      private var _classButtons:Vector.<PushButton>;
      
      private var _excludeSurvivors:Vector.<Survivor>;
      
      private var _excludeClassFilter:Vector.<String>;
      
      private var _lang:Language;
      
      private var _selectedClassButton:PushButton;
      
      private var _survivorList:SurvivorCollection;
      
      private var _showNoneItem:Boolean;
      
      private var mc_container:Sprite;
      
      private var ui_list:UISurvivorList;
      
      private var ui_page:UIPagination;
      
      public var selected:Signal;
      
      public function SurvivorListDialogue(param1:String, param2:SurvivorCollection, param3:Vector.<Survivor> = null, param4:Vector.<String> = null, param5:Boolean = false)
      {
         var _loc6_:TooltipManager = null;
         var _loc12_:String = null;
         var _loc13_:Class = null;
         var _loc14_:PushButton = null;
         param3 ||= new Vector.<Survivor>();
         param4 ||= new Vector.<String>();
         _loc6_ = TooltipManager.getInstance();
         this._lang = Language.getInstance();
         this.mc_container = new Sprite();
         super("survivor-list-dialogue",this.mc_container,true);
         _autoSize = false;
         _width = 352;
         _height = 486;
         _padding = 20;
         this._survivorList = param2;
         this._excludeSurvivors = param3;
         this._excludeClassFilter = param4;
         this._showNoneItem = param5;
         this.selected = new Signal(Survivor);
         addTitle(param1,4934477);
         this._classButtons = new Vector.<PushButton>();
         var _loc7_:int = 4;
         var _loc8_:Array = Network.getInstance().data.getSurvivorClassIds();
         var _loc9_:int = int(_loc8_.indexOf(SurvivorClass.PLAYER));
         if(_loc9_ > -1)
         {
            _loc8_.splice(_loc9_,1);
         }
         _loc8_.sort(Array.CASEINSENSITIVE);
         _loc8_.unshift(SurvivorClass.PLAYER);
         var _loc10_:int = 0;
         var _loc11_:int = int(_loc8_.length);
         while(_loc10_ < _loc11_)
         {
            _loc12_ = _loc8_[_loc10_];
            if(_loc12_ != SurvivorClass.UNASSIGNED)
            {
               _loc13_ = getDefinitionByName("BmpIconClass_" + _loc12_) as Class;
               _loc14_ = new PushButton("",new _loc13_());
               _loc14_.clicked.add(this.onCategoryButtonClicked);
               _loc14_.data = _loc12_;
               _loc14_.width = 33;
               _loc14_.x = _loc7_;
               _loc14_.y = -2;
               _loc14_.selected = _loc12_ == _selectedClass;
               if(_loc14_.selected)
               {
                  this._selectedClassButton = _loc14_;
               }
               _loc7_ += _loc14_.width + 12;
               this._classButtons.push(_loc14_);
               this.mc_container.addChild(_loc14_);
               _loc6_.add(_loc14_,this._lang.getString("survivor_classes." + _loc14_.data),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
            }
            _loc10_++;
         }
         _loc14_ = new PushButton("",new BmpIconClass_all());
         _loc14_.clicked.add(this.onCategoryButtonClicked);
         _loc14_.data = "all";
         _loc14_.width = 33;
         _loc14_.x = _loc7_;
         _loc14_.y = -2;
         _loc14_.selected = _selectedClass == _loc14_.data;
         if(_loc14_.selected)
         {
            this._selectedClassButton = _loc14_;
         }
         this._classButtons.push(_loc14_);
         this.mc_container.addChild(_loc14_);
         _loc6_.add(_loc14_,this._lang.getString("survivor_classes.all"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
         this.ui_list = new UISurvivorList(false);
         this.ui_list.y = int(_loc14_.y + _loc14_.height + 8);
         this.ui_list.width = 311;
         this.ui_list.height = 383;
         this.ui_list.survivorList = this.getSurvivorsByClass(_selectedClass);
         this.ui_list.changed.add(this.onItemSelected);
         this.mc_container.addChild(this.ui_list);
         this.ui_page = new UIPagination();
         this.ui_page.numPages = this.ui_list.numPages;
         this.ui_page.x = int(this.ui_list.x + (this.ui_list.width - this.ui_page.width) * 0.5);
         this.ui_page.y = int(this.ui_list.y + this.ui_list.height + 10);
         this.ui_page.changed.add(this.onPageChanged);
         this.mc_container.addChild(this.ui_page);
      }
      
      override public function dispose() : void
      {
         this._lang = null;
         this._excludeSurvivors = null;
         this.ui_list.dispose();
         this.ui_page.dispose();
         super.dispose();
      }
      
      public function selectItem(param1:int) : void
      {
         this.ui_list.selectItem(param1);
      }
      
      private function getSurvivorsByClass(param1:String) : Vector.<Survivor>
      {
         var _loc2_:Vector.<Survivor> = Network.getInstance().playerData.compound.survivors.getSurvivorsByClass(_selectedClass);
         var _loc3_:int = int(_loc2_.length - 1);
         while(_loc3_ >= 0)
         {
            if(this._excludeSurvivors.indexOf(_loc2_[_loc3_]) > -1 || this._excludeClassFilter.indexOf(_loc2_[_loc3_].classId) > -1)
            {
               _loc2_.splice(_loc3_,1);
            }
            _loc3_--;
         }
         if(this._showNoneItem)
         {
            _loc2_.unshift(null);
         }
         return _loc2_;
      }
      
      private function onCategoryButtonClicked(param1:MouseEvent) : void
      {
         var _loc2_:PushButton = param1.currentTarget as PushButton;
         if(_loc2_ == this._selectedClassButton)
         {
            return;
         }
         if(this._selectedClassButton != null)
         {
            this._selectedClassButton.selected = false;
         }
         this._selectedClassButton = _loc2_;
         this._selectedClassButton.selected = true;
         _selectedClass = _loc2_.data;
         this.ui_list.survivorList = this.getSurvivorsByClass(_selectedClass);
         this.ui_page.numPages = this.ui_list.numPages;
         this.ui_page.x = int(this.ui_list.x + (this.ui_list.width - this.ui_page.width) * 0.5);
      }
      
      private function onItemSelected() : void
      {
         this.selected.dispatch(this.ui_list.selectedItem is UISurvivorListItem ? UISurvivorListItem(this.ui_list.selectedItem).survivor : null);
      }
      
      private function onPageChanged(param1:int) : void
      {
         this.ui_list.gotoPage(param1);
      }
   }
}

