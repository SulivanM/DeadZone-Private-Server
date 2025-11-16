package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextFormatAlign;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIInputField;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.buttons.UIIconButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.Resource;
   import thelaststand.common.resources.ResourceManager;
   
   public class RenameCarDialogue extends BaseDialogue
   {
      
      private const NAMES_URI:String = "xml/vehiclenames.xml";
      
      private var _building:Building;
      
      private var _lang:Language;
      
      private var _names:XML;
      
      private var mc_container:Sprite = new Sprite();
      
      private var btn_random:UIIconButton;
      
      private var btn_ok:PushButton;
      
      private var ui_input:UIInputField;
      
      public function RenameCarDialogue(param1:Building)
      {
         super("rename-car",this.mc_container,true);
         this._building = param1;
         this._lang = Language.getInstance();
         _buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         _buttonYOffset = 10;
         var _loc2_:Resource = ResourceManager.getInstance().getResource(this.NAMES_URI);
         if(_loc2_ == null)
         {
            this._names = null;
            ResourceManager.getInstance().load(this.NAMES_URI,{"onComplete":this.onNamesLoaded});
         }
         else
         {
            this._names = _loc2_.content as XML;
         }
         addTitle(this._lang.getString("rename_car_title"),BaseDialogue.TITLE_COLOR_GREY);
         this.btn_ok = addButton(this._lang.getString("rename_car_ok"),false,{"width":120}) as PushButton;
         this.btn_ok.clicked.add(this.onClickSave);
         this.ui_input = new UIInputField({
            "color":16777215,
            "size":20,
            "align":TextFormatAlign.CENTER
         });
         this.ui_input.textField.addEventListener(Event.CHANGE,this.onNameChanged,false,0,true);
         this.ui_input.textField.restrict = "a-zA-Z0-9 ";
         this.ui_input.textField.maxChars = 22;
         this.ui_input.value = param1.getName();
         this.ui_input.width = 240;
         this.ui_input.height = 34;
         this.ui_input.y = int(_padding * 0.5);
         this.mc_container.addChild(this.ui_input);
         this.btn_random = new UIIconButton(new BmpIconRecycle());
         this.btn_random.addEventListener(MouseEvent.CLICK,this.onClickRandom,false,0,true);
         this.btn_random.enabled = this._names != null;
         this.btn_random.x = int(this.ui_input.x + this.ui_input.width - this.btn_random.width - 8);
         this.btn_random.y = int(this.ui_input.y + (this.ui_input.height - this.btn_random.height) * 0.5);
         this.mc_container.addChild(this.btn_random);
         TooltipManager.getInstance().add(this.btn_random,this._lang.getString("tooltip.randomize"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
      }
      
      override public function dispose() : void
      {
         TooltipManager.getInstance().removeAllFromParent(this.mc_container);
         super.dispose();
         this.ui_input.dispose();
         this.btn_random.dispose();
         this._lang = null;
      }
      
      private function generateRandomName() : String
      {
         if(this._names == null)
         {
            return "";
         }
         var _loc1_:XMLList = this._names.first.n;
         var _loc2_:XMLList = this._names.last.n;
         var _loc3_:String = _loc1_[int(Math.random() * _loc1_.length())].toString();
         var _loc4_:String = null;
         var _loc5_:Boolean = false;
         if(_loc3_.substr(_loc3_.length - 1) == "%")
         {
            _loc3_ = _loc3_.substr(0,_loc3_.length - 1);
            _loc5_ = false;
            while(!_loc4_)
            {
               _loc4_ = _loc2_[int(Math.random() * _loc2_.length())].toString();
               if(_loc4_.substr(0,1) == "%")
               {
                  _loc4_ = null;
               }
            }
         }
         else
         {
            _loc4_ = _loc2_[int(Math.random() * _loc2_.length())].toString();
            if(_loc4_.substr(0,1) == "%")
            {
               _loc4_ = _loc4_.substr(1,_loc4_.length);
               _loc5_ = true;
            }
         }
         return _loc3_ + (_loc5_ ? "" : " ") + _loc4_;
      }
      
      private function onNamesLoaded() : void
      {
         this._names = ResourceManager.getInstance().getResource(this.NAMES_URI).content;
         this.btn_random.enabled = true;
      }
      
      private function onClickRandom(param1:MouseEvent) : void
      {
         this.ui_input.value = this.generateRandomName();
         this.btn_ok.enabled = this.ui_input.value.length > 0;
      }
      
      private function onNameChanged(param1:Event) : void
      {
         this.btn_ok.enabled = this.ui_input.value.length > 0;
      }
      
      private function onClickSave(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         this.btn_ok.enabled = false;
         Network.getInstance().save({"name":this.ui_input.value},SaveDataMethod.DEATH_MOBILE_RENAME,function():void
         {
            _building.setName(ui_input.value);
            close();
         });
      }
   }
}

