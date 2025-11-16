package thelaststand.app.game.gui.survivor
{
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.AntiAliasType;
   import flash.ui.MouseCursor;
   import thelaststand.app.core.Config;
   import thelaststand.app.display.Effects;
   import thelaststand.app.display.TitleTextField;
   import thelaststand.app.game.data.Gender;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.gui.MouseCursors;
   import thelaststand.app.gui.Tooltip;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIBusySpinner;
   import thelaststand.app.gui.UIInputField;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.PlayerIOConnector;
   import thelaststand.app.network.users.KongregateUser;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.ResourceManager;
   
   public class UISurvivorCustomize extends Sprite
   {
      
      public static const NICKNAME_UNCHECKED:uint = 0;
      
      public static const NICKNAME_CHECKING:uint = 1;
      
      public static const NICKNAME_OK:uint = 2;
      
      public static const NICKNAME_ERROR:uint = 3;
      
      private var _attireXML:XML;
      
      private var _defaultName:String;
      
      private var _survivor:Survivor;
      
      private var _tooltip:TooltipManager;
      
      private var _lang:Language;
      
      private var _width:int = 270;
      
      private var _height:int = 360;
      
      private var _padding:int = 6;
      
      private var _attireTypes:Array;
      
      private var _nicknameState:uint = 0;
      
      private var _nicknameTip:Tooltip;
      
      private var _upperOptions:XMLList;
      
      private var _lowerOptions:XMLList;
      
      private var _hairOptions:XMLList;
      
      private var _facialHairOptions:XMLList;
      
      private var _index_upper:int;
      
      private var _index_lower:int;
      
      private var _index_hair:int;
      
      private var _index_fhair:int;
      
      private var bmp_nicknameState:Bitmap;
      
      private var ui_name:UIInputField;
      
      private var txt_nameKong:TitleTextField;
      
      private var ui_editAppearance:UISurvivorEditAppearance;
      
      private var mc_modelView:UISurvivorModelView;
      
      private var btn_upperNext:PushButton;
      
      private var btn_upperPrev:PushButton;
      
      private var btn_lowerNext:PushButton;
      
      private var btn_lowerPrev:PushButton;
      
      private var btn_hairNext:PushButton;
      
      private var btn_hairPrev:PushButton;
      
      private var btn_fhairNext:PushButton;
      
      private var btn_fhairPrev:PushButton;
      
      private var mc_saving:UIBusySpinner;
      
      public function UISurvivorCustomize(param1:Survivor)
      {
         var _loc4_:int = 0;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:PushButton = null;
         var _loc10_:PushButton = null;
         this._attireTypes = ["hair","fhair","upper","lower"];
         super();
         this._attireXML = ResourceManager.getInstance().getResource("xml/attire.xml").content;
         this._tooltip = TooltipManager.getInstance();
         this._lang = Language.getInstance();
         this._defaultName = this._lang.getString("player_create_name");
         GraphicUtils.drawUIBlock(graphics,this._width,this._height);
         var _loc2_:int = int(this._width - this._padding - 40);
         var _loc3_:int = 28;
         this.bmp_nicknameState = new Bitmap();
         this.mc_saving = new UIBusySpinner();
         if(Network.getInstance().service == PlayerIOConnector.SERVICE_KONGREGATE)
         {
            this.txt_nameKong = new TitleTextField({
               "color":16777215,
               "size":22,
               "align":"center",
               "autoSize":"none",
               "antiAliasType":AntiAliasType.ADVANCED
            });
            this.txt_nameKong.text = KongregateUser(PlayerIOConnector.getInstance().user).userName;
            this.txt_nameKong.filters = [Effects.TEXT_SHADOW_DARK];
            this.txt_nameKong.width = int(this._width - this._padding * 2);
            this.txt_nameKong.x = int((this._width - this.txt_nameKong.width) * 0.5);
            this.txt_nameKong.y = 6;
            addChild(this.txt_nameKong);
            addChild(this.bmp_nicknameState);
            this.mc_saving.x = int(this._width - this.mc_saving.width * 0.5 - 6);
            this.mc_saving.y = int(this.txt_nameKong.y + this.txt_nameKong.height * 0.5);
         }
         else
         {
            this.ui_name = new UIInputField();
            this.ui_name.textField.restrict = Config.constant.RESTRICT_NAME_CHARS;
            this.ui_name.textField.maxChars = Config.constant.RESTRICT_NAME_MAX_LENGTH;
            this.ui_name.defaultValue = this._defaultName;
            this.ui_name.value = param1.firstName;
            this.ui_name.width = _loc2_;
            this.ui_name.height = _loc3_;
            this.ui_name.x = this.ui_name.y = this._padding;
            addChild(this.ui_name);
            this.bmp_nicknameState.x = int(this.ui_name.x + this.ui_name.width + 5);
            this.bmp_nicknameState.y = int(this.ui_name.y + (this.ui_name.height - this.bmp_nicknameState.height) * 0.5);
            addChild(this.bmp_nicknameState);
            this.mc_saving.x = int(this.ui_name.x + this.ui_name.width + 18);
            this.mc_saving.y = int(this.ui_name.y + this.ui_name.height * 0.5);
         }
         this.mc_modelView = new UISurvivorModelView(this._width,260);
         this.mc_modelView.x = int((this._width - this.mc_modelView.width) * 0.5);
         this.mc_modelView.y = int(this._padding + _loc3_ + 4);
         this.mc_modelView.cameraPosition.y = -20;
         this.mc_modelView.actorMesh.scaleX = this.mc_modelView.actorMesh.scaleY = this.mc_modelView.actorMesh.scaleZ = 1.15;
         addChildAt(this.mc_modelView,0);
         this.ui_editAppearance = new UISurvivorEditAppearance(this._width - this._padding * 2,UISurvivorEditAppearance.PLAYER_CREATION);
         this.ui_editAppearance.x = this._padding;
         this.ui_editAppearance.y = int(this._height - this._padding - this.ui_editAppearance.height + 2);
         this.ui_editAppearance.genderButtonAlign = UISurvivorEditAppearance.GENDER_ALIGN_CENTER;
         this.ui_editAppearance.appearanceChanged.add(this.onAppearanceChanged);
         this.ui_editAppearance.genderChanged.add(this.onGenderChanged);
         addChild(this.ui_editAppearance);
         _loc4_ = this._padding + _loc3_;
         _loc4_ = _loc4_ + 15;
         var _loc5_:Array = [_loc4_,_loc4_ = _loc4_ + 26,_loc4_ = _loc4_ + 36,_loc4_ = _loc4_ + 60];
         var _loc6_:int = 0;
         while(_loc6_ < this._attireTypes.length)
         {
            _loc7_ = this._attireTypes[_loc6_];
            _loc8_ = 20;
            _loc4_ = int(_loc5_[_loc6_]);
            _loc9_ = new PushButton(null,new BmpIconButtonPrev());
            _loc9_.clicked.add(this.onClothingNavClicked);
            _loc9_.showBorder = false;
            _loc9_.height = 20;
            _loc9_.width = _loc9_.height;
            _loc9_.y = _loc4_;
            _loc9_.x = _loc8_;
            addChild(_loc9_);
            _loc10_ = new PushButton(null,new BmpIconButtonNext());
            _loc10_.clicked.add(this.onClothingNavClicked);
            _loc10_.showBorder = false;
            _loc10_.height = 20;
            _loc10_.width = _loc10_.height;
            _loc10_.y = _loc4_;
            _loc10_.x = int(this._width - _loc10_.width - _loc8_);
            addChild(_loc10_);
            this["btn_" + _loc7_ + "Prev"] = _loc9_;
            this["btn_" + _loc7_ + "Next"] = _loc10_;
            _loc6_++;
         }
         this.setToSurvivor(param1);
         this.nicknameState = UISurvivorCustomize.NICKNAME_UNCHECKED;
      }
      
      public function dispose() : void
      {
         var _loc2_:String = null;
         if(parent)
         {
            parent.removeChild(this);
         }
         this._tooltip.removeAllFromParent(this);
         this._tooltip = null;
         this._lang = null;
         this._survivor = null;
         this._attireXML = null;
         this._hairOptions = null;
         this._facialHairOptions = null;
         this._lowerOptions = null;
         this._upperOptions = null;
         var _loc1_:int = 0;
         while(_loc1_ < this._attireTypes.length)
         {
            _loc2_ = this._attireTypes[_loc1_];
            PushButton(this["btn_" + _loc2_ + "Prev"]).dispose();
            PushButton(this["btn_" + _loc2_ + "Next"]).dispose();
            _loc1_++;
         }
         this.ui_editAppearance.dispose();
         this.ui_editAppearance = null;
         if(this.txt_nameKong != null)
         {
            this.txt_nameKong.dispose();
            this.txt_nameKong = null;
         }
         if(this.ui_name != null)
         {
            this.ui_name.dispose();
            this.ui_name = null;
         }
         this.mc_modelView.dispose();
         this.mc_modelView = null;
         if(this.bmp_nicknameState.bitmapData != null)
         {
            this.bmp_nicknameState.bitmapData.dispose();
            this.bmp_nicknameState.bitmapData = null;
         }
      }
      
      public function getName() : String
      {
         return this.ui_name != null ? this.ui_name.value : KongregateUser(PlayerIOConnector.getInstance().user).userName;
      }
      
      public function showNicknameMessage(param1:String) : void
      {
         if(this._nicknameTip != null)
         {
            this._nicknameTip.dispose();
            this._nicknameTip = null;
         }
         if(param1 != null)
         {
            this._nicknameTip = new Tooltip();
            this._nicknameTip.setTooltip(param1,TooltipDirection.DIRECTION_LEFT,new Point(this._width + this._padding,this.bmp_nicknameState.y + this.bmp_nicknameState.height * 0.5),new Rectangle(0,0,760,this._height),180);
            addChild(this._nicknameTip);
         }
      }
      
      private function setToSurvivor(param1:Survivor) : void
      {
         if(param1 == this._survivor)
         {
            return;
         }
         this._survivor = param1;
         var _loc2_:String = this._survivor.gender;
         this.updateClothingHairOptions();
         this._index_hair = this.getNodeIndex(this._hairOptions,this._survivor.appearance.hair.id);
         this._index_fhair = this.getNodeIndex(this._facialHairOptions,this._survivor.appearance.facialHair.id);
         this._index_upper = this.getNodeIndex(this._upperOptions,this._survivor.appearance.upperBody.id);
         this._index_lower = this.getNodeIndex(this._lowerOptions,this._survivor.appearance.lowerBody.id);
         this.btn_fhairPrev.visible = this.btn_fhairNext.visible = _loc2_ == Gender.MALE;
         this.ui_editAppearance.appearance = this._survivor.appearance;
         this.mc_modelView.survivor = this._survivor;
      }
      
      private function getNodeIndex(param1:XMLList, param2:String) : int
      {
         var _loc5_:XML = null;
         var _loc3_:int = 0;
         var _loc4_:int = int(param1.length());
         while(_loc3_ < _loc4_)
         {
            _loc5_ = param1[_loc3_];
            if(_loc5_.@id == param2)
            {
               return _loc3_;
            }
            _loc3_++;
         }
         return 0;
      }
      
      private function updateClothingHairOptions() : void
      {
         var gender:String = this._survivor.gender;
         this._hairOptions = this._attireXML.item.(@type == "hair" && (!hasOwnProperty("@classOnly") || @classOnly != "1") && Boolean(hasOwnProperty(gender)));
         this._facialHairOptions = this._attireXML.item.(@type == "fhair" && (!hasOwnProperty("@classOnly") || @classOnly != "1") && Boolean(hasOwnProperty(gender)));
         this._upperOptions = this._attireXML.item.(@type == "upper" && (!hasOwnProperty("@classOnly") || @classOnly != "1") && Boolean(hasOwnProperty(gender)));
         this._lowerOptions = this._attireXML.item.(@type == "lower" && (!hasOwnProperty("@classOnly") || @classOnly != "1") && Boolean(hasOwnProperty(gender)));
      }
      
      private function setClothing(param1:String, param2:int) : void
      {
         var _loc3_:XMLList = null;
         switch(param1)
         {
            case "hair":
               _loc3_ = this._hairOptions;
               break;
            case "fhair":
               _loc3_ = this._facialHairOptions;
               break;
            case "lower":
               _loc3_ = this._lowerOptions;
               break;
            case "upper":
               _loc3_ = this._upperOptions;
         }
         if(param2 < 0)
         {
            param2 = _loc3_.length() - 1;
         }
         else if(param2 >= _loc3_.length())
         {
            param2 = 0;
         }
         var _loc4_:XML = _loc3_[param2][this._survivor.gender][0];
         if(_loc4_ == null)
         {
            param2 = 0;
         }
         this["_index_" + param1] = param2;
         var _loc5_:XML = _loc3_[param2];
         switch(param1)
         {
            case "hair":
               this._survivor.appearance.hair.parseXML(_loc5_,this._survivor.gender);
               break;
            case "fhair":
               this._survivor.appearance.facialHair.parseXML(_loc5_,this._survivor.gender);
               break;
            case "lower":
               this._survivor.appearance.lowerBody.parseXML(_loc5_,this._survivor.gender);
               break;
            case "upper":
               this._survivor.appearance.upperBody.parseXML(_loc5_,this._survivor.gender);
         }
         this._survivor.appearance.invalidate();
         this.mc_modelView.update();
      }
      
      private function onNameMouseOver(param1:MouseEvent) : void
      {
         MouseCursors.setCursor(MouseCursor.IBEAM);
      }
      
      private function onNameMouseOut(param1:MouseEvent) : void
      {
         MouseCursors.setCursor(MouseCursors.DEFAULT);
      }
      
      private function onAppearanceChanged() : void
      {
         this.mc_modelView.update();
      }
      
      private function onGenderChanged(param1:String) : void
      {
         this.btn_fhairPrev.visible = this.btn_fhairNext.visible = param1 == Gender.MALE;
         this.updateClothingHairOptions();
         this.setClothing("lower",this._index_lower);
         this.setClothing("upper",this._index_upper);
         this.setClothing("hair",this._index_hair);
         this.setClothing("fhair",this._index_fhair);
         this.mc_modelView.update();
      }
      
      private function onVoiceChanged() : void
      {
      }
      
      private function onClothingNavClicked(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         switch(param1.currentTarget)
         {
            case this.btn_hairNext:
               _loc2_ = "hair";
               _loc3_ = 1;
               break;
            case this.btn_hairPrev:
               _loc2_ = "hair";
               _loc3_ = -1;
               break;
            case this.btn_fhairNext:
               _loc2_ = "fhair";
               _loc3_ = 1;
               break;
            case this.btn_fhairPrev:
               _loc2_ = "fhair";
               _loc3_ = -1;
               break;
            case this.btn_lowerNext:
               _loc2_ = "lower";
               _loc3_ = 1;
               break;
            case this.btn_lowerPrev:
               _loc2_ = "lower";
               _loc3_ = -1;
               break;
            case this.btn_upperNext:
               _loc2_ = "upper";
               _loc3_ = 1;
               break;
            case this.btn_upperPrev:
               _loc2_ = "upper";
               _loc3_ = -1;
               break;
            default:
               return;
         }
         var _loc4_:int = this["_index_" + _loc2_] + _loc3_;
         this.setClothing(_loc2_,_loc4_);
      }
      
      public function get nicknameState() : uint
      {
         return this._nicknameState;
      }
      
      public function set nicknameState(param1:uint) : void
      {
         this._nicknameState = param1;
         if(this.bmp_nicknameState.bitmapData != null)
         {
            this.bmp_nicknameState.bitmapData.dispose();
         }
         if(this.mc_saving.parent != null)
         {
            this.mc_saving.parent.removeChild(this.mc_saving);
         }
         switch(this._nicknameState)
         {
            case NICKNAME_OK:
               this.bmp_nicknameState.bitmapData = new BmpExitZoneOK();
               break;
            case NICKNAME_ERROR:
               this.bmp_nicknameState.bitmapData = new BmpExitZoneBad();
               break;
            case NICKNAME_CHECKING:
               addChild(this.mc_saving);
               break;
            case NICKNAME_UNCHECKED:
            default:
               this.showNicknameMessage(null);
         }
         if(Network.getInstance().service == PlayerIOConnector.SERVICE_KONGREGATE)
         {
            this.bmp_nicknameState.x = int(this._width - this.bmp_nicknameState.width - 10);
            this.bmp_nicknameState.y = int(this.txt_nameKong.y + (this.txt_nameKong.height - this.bmp_nicknameState.height) * 0.5);
         }
         else
         {
            if(this._nicknameState == NICKNAME_UNCHECKED)
            {
               this.ui_name.width = int(this._width - this._padding * 2);
            }
            else
            {
               this.ui_name.width = int(this._width - this._padding - 40);
            }
            this.bmp_nicknameState.x = int(this.ui_name.x + this.ui_name.width + 5);
            this.bmp_nicknameState.y = int(this.ui_name.y + (this.ui_name.height - this.bmp_nicknameState.height) * 0.5);
         }
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
   }
}

