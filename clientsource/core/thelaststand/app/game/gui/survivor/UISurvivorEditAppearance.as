package thelaststand.app.game.gui.survivor
{
   import com.deadreckoned.threshold.display.Color;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundLoaderContext;
   import flash.net.URLRequest;
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Global;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.AttireFlags;
   import thelaststand.app.game.data.Gender;
   import thelaststand.app.game.data.HumanAppearance;
   import thelaststand.app.game.data.SurvivorAppearance;
   import thelaststand.app.gui.CheckBox;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIBusySpinner;
   import thelaststand.app.gui.UIColorPalette;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.network.Network;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.ResourceManager;
   
   public class UISurvivorEditAppearance extends Sprite
   {
      
      public static const GENDER_ALIGN_CENTER:String = "center";
      
      public static const GENDER_ALIGN_RIGHT:String = "right";
      
      public static const HAIR:uint = 1 << 0;
      
      public static const FACIAL_HAIR:uint = 1 << 1;
      
      public static const HAIR_COLOR:uint = 1 << 2;
      
      public static const SKIN_COLOR:uint = 1 << 3;
      
      public static const FORCE_HAIR:uint = 1 << 4;
      
      public static const HIDE_GEAR:uint = 1 << 5;
      
      public static const GENDER:uint = 1 << 6;
      
      public static const VOICE:uint = 1 << 7;
      
      public static const PLAYER_CREATION:uint = HAIR_COLOR | SKIN_COLOR | VOICE | GENDER;
      
      public static const PLAYER_EDIT:uint = HAIR | FACIAL_HAIR | HAIR_COLOR | FORCE_HAIR | HIDE_GEAR | SKIN_COLOR | VOICE | GENDER;
      
      public static const SURVIVOR_EDIT:uint = HAIR | FACIAL_HAIR | HAIR_COLOR | FORCE_HAIR | HIDE_GEAR | SKIN_COLOR | VOICE | GENDER;
      
      private var _lang:Language;
      
      private var _attireXML:XML;
      
      private var _rowCount:int;
      
      private var _rowHeight:int = 24;
      
      private var _rowSpacing:int = 2;
      
      private var _rowLabelWidth:Number = 0.3;
      
      private var _padding:int = 4;
      
      private var _width:int;
      
      private var _height:int;
      
      private var _appearance:SurvivorAppearance;
      
      private var _hairOptions:XMLList;
      
      private var _hairColorOptions:XMLList;
      
      private var _skinColorOptions:XMLList;
      
      private var _facialHairOptions:XMLList;
      
      private var _voiceOptions:XMLList;
      
      private var _rowLabels:Vector.<BodyTextField>;
      
      private var _rowIndexById:Dictionary;
      
      private var _genderButtonAlign:String = "right";
      
      private var _gender:String;
      
      private var _voiceSound:Sound;
      
      private var _voiceChannel:SoundChannel;
      
      private var _voiceSampleId:String;
      
      private var _voiceSampleIndex:int = 1;
      
      private var _voiceSampleCount:int = 3;
      
      private var _voiceSampleLoaded:Boolean = false;
      
      private var _voicePlayOnLoad:Boolean = false;
      
      private var btn_male:PushButton;
      
      private var btn_female:PushButton;
      
      private var btn_playVoice:UIPlayVoiceSampleButton;
      
      private var ui_hairPalette:UIColorPalette;
      
      private var ui_skinPalette:UIColorPalette;
      
      private var ui_hairStyle:AppearanceSpinner;
      
      private var ui_facialHairStyle:AppearanceSpinner;
      
      private var ui_voicePack:AppearanceSpinner;
      
      private var ui_hairOn:CheckBox;
      
      private var ui_gearHide:CheckBox;
      
      private var mc_rowContainer:Sprite;
      
      private var mc_voiceSpinner:UIBusySpinner;
      
      public var appearanceChanged:Signal;
      
      public var genderChanged:Signal;
      
      public var voiceChanged:Signal;
      
      private var _editFlags:uint;
      
      public function UISurvivorEditAppearance(param1:int, param2:uint)
      {
         var contentAreaWidth:int;
         var showForceHair:Boolean;
         var showHideGear:Boolean;
         var row:int = 0;
         var btnWidth:int = 0;
         var btnSpacing:int = 0;
         var tx:int = 0;
         var ty:int = 0;
         var width:int = param1;
         var editorFlags:uint = param2;
         this._rowLabels = new Vector.<BodyTextField>();
         this._rowIndexById = new Dictionary(true);
         this.appearanceChanged = new Signal();
         this.genderChanged = new Signal(String);
         this.voiceChanged = new Signal();
         super();
         this._width = width;
         this._editFlags = editorFlags;
         this._lang = Language.getInstance();
         this._attireXML = ResourceManager.getInstance().getResource("xml/attire.xml").content;
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
         contentAreaWidth = this._width - this.getContentOffset(0);
         this.mc_rowContainer = new Sprite();
         addChild(this.mc_rowContainer);
         if(this._editFlags & GENDER)
         {
            btnWidth = 20;
            btnSpacing = 12;
            this.btn_male = new PushButton("",new BmpIconMale());
            this.btn_male.clicked.add(this.onGenderButtonClicked);
            this.btn_male.width = btnWidth;
            this.btn_male.height = btnWidth;
            addChild(this.btn_male);
            this.btn_female = new PushButton("",new BmpIconFemale());
            this.btn_female.clicked.add(this.onGenderButtonClicked);
            this.btn_female.width = btnWidth;
            this.btn_female.height = btnWidth;
            addChild(this.btn_female);
            TooltipManager.getInstance().add(this.btn_male,this._lang.getString("gender.male"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
            TooltipManager.getInstance().add(this.btn_female,this._lang.getString("gender.female"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN);
            this.mc_rowContainer.y = int(this.btn_male.height + 10);
         }
         if(this._editFlags & HAIR)
         {
            row = this.addRow("hair",this._lang.getString("survivor_edit_hair"));
            this.ui_hairStyle = new AppearanceSpinner(contentAreaWidth);
            this.ui_hairStyle.x = int(this.getContentOffset(row) + 2);
            this.ui_hairStyle.y = int(this.getRowOffset(row) + (this._rowHeight - this.ui_hairStyle.height) * 0.5);
            this.ui_hairStyle.changed.add(this.onHairChanged);
            this.mc_rowContainer.addChild(this.ui_hairStyle);
         }
         if(this._editFlags & FACIAL_HAIR)
         {
            row = this.addRow("fhair",this._lang.getString("survivor_edit_fhair"));
            this.ui_facialHairStyle = new AppearanceSpinner(contentAreaWidth);
            this.ui_facialHairStyle.x = int(this.getContentOffset(row) + 2);
            this.ui_facialHairStyle.y = int(this.getRowOffset(row) + (this._rowHeight - this.ui_facialHairStyle.height) * 0.5);
            this.ui_facialHairStyle.changed.add(this.onFacialHairChanged);
            this.mc_rowContainer.addChild(this.ui_facialHairStyle);
         }
         if(this._editFlags & HAIR_COLOR)
         {
            this._hairColorOptions = this._attireXML.hair_textures.tex;
            row = this.addRow("hairColor",this._lang.getString("survivor_edit_haircolor"));
            this.ui_hairPalette = new UIColorPalette(HumanAppearance.getHairColors());
            this.ui_hairPalette.x = int(this.getContentOffset(row));
            this.ui_hairPalette.y = int(this.getRowOffset(row) + (this._rowHeight - this.ui_hairPalette.height) * 0.5);
            this.ui_hairPalette.changed.add(this.onHairColorChanged);
            this.mc_rowContainer.addChild(this.ui_hairPalette);
         }
         if(this._editFlags & SKIN_COLOR)
         {
            this._skinColorOptions = this._attireXML.item.(@type == "skin");
            row = this.addRow("skin",this._lang.getString("survivor_edit_skin"));
            this.ui_skinPalette = new UIColorPalette(HumanAppearance.getSkinColors());
            this.ui_skinPalette.x = int(this.getContentOffset(row));
            this.ui_skinPalette.y = int(this.getRowOffset(row) + (this._rowHeight - this.ui_skinPalette.height) * 0.5);
            this.ui_skinPalette.changed.add(this.onSkinColorChanged);
            this.mc_rowContainer.addChild(this.ui_skinPalette);
         }
         if(this._editFlags & VOICE)
         {
            row = this.addRow("voice",this._lang.getString("survivor_edit_voice"));
            this.ui_voicePack = new AppearanceSpinner(contentAreaWidth);
            this.ui_voicePack.x = int(this.getContentOffset(row) + 2);
            this.ui_voicePack.y = int(this.getRowOffset(row) + (this._rowHeight - this.ui_voicePack.height) * 0.5);
            this.ui_voicePack.changed.add(this.onVoicePackChanged);
            this.mc_rowContainer.addChild(this.ui_voicePack);
            this.mc_voiceSpinner = new UIBusySpinner();
            this.mc_voiceSpinner.height = this._rowHeight * 0.5;
            this.mc_voiceSpinner.scaleX = this.mc_voiceSpinner.scaleY;
            this.mc_voiceSpinner.x = int(this._width - this._padding - this.mc_voiceSpinner.width * 0.5 - 6);
            this.mc_voiceSpinner.y = int(this.ui_voicePack.y + this.ui_voicePack.height * 0.5);
            this.mc_voiceSpinner.visible = false;
            this.mc_rowContainer.addChild(this.mc_voiceSpinner);
            this.btn_playVoice = new UIPlayVoiceSampleButton();
            this.btn_playVoice.x = int(this._width - this._padding - this.btn_playVoice.width * 0.5 - 6);
            this.btn_playVoice.y = int(this.ui_voicePack.y + (this.ui_voicePack.height - this.btn_playVoice.height) * 0.5);
            this.btn_playVoice.visible = false;
            this.btn_playVoice.addEventListener(MouseEvent.CLICK,this.onClickPlayVoice,false,0,true);
            this.mc_rowContainer.addChild(this.btn_playVoice);
         }
         showForceHair = (this._editFlags & FORCE_HAIR) != 0;
         showHideGear = (this._editFlags & HIDE_GEAR) != 0;
         if(showForceHair || showHideGear)
         {
            row = this.addRow("hide",this._lang.getString("survivor_edit_hide"));
            tx = this.getContentOffset(row);
            ty = this.getRowOffset(row);
            if(showForceHair)
            {
               this.ui_hairOn = new CheckBox(null,"right");
               this.ui_hairOn.label = this._lang.getString("survivor_edit_hide_hair");
               this.ui_hairOn.width = this.ui_hairOn.height = int(this._rowHeight - 4);
               this.ui_hairOn.x = tx;
               this.ui_hairOn.y = int(ty + (this._rowHeight - this.ui_hairOn.height) * 0.5);
               this.ui_hairOn.changed.add(this.onHairShowChanged);
               this.mc_rowContainer.addChild(this.ui_hairOn);
               tx += int(this.ui_hairOn.width + 10);
            }
            if(showHideGear)
            {
               this.ui_gearHide = new CheckBox(null,"right");
               this.ui_gearHide.label = this._lang.getString("survivor_edit_hide_gear");
               this.ui_gearHide.width = this.ui_gearHide.height = int(this._rowHeight - 4);
               this.ui_gearHide.x = tx;
               this.ui_gearHide.y = int(ty + (this._rowHeight - this.ui_gearHide.height) * 0.5);
               this.ui_gearHide.changed.add(this.onGearHideChanged);
               this.mc_rowContainer.addChild(this.ui_gearHide);
               tx += int(this.ui_hairOn.width + 10);
            }
         }
      }
      
      public function get genderButtonAlign() : String
      {
         return this._genderButtonAlign;
      }
      
      public function set genderButtonAlign(param1:String) : void
      {
         this._genderButtonAlign = param1;
      }
      
      public function get appearance() : SurvivorAppearance
      {
         return this._appearance;
      }
      
      public function set appearance(param1:SurvivorAppearance) : void
      {
         if(param1 == this._appearance)
         {
            return;
         }
         this._appearance = param1;
         this.setToAppearance();
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
      
      public function dispose() : void
      {
         var _loc1_:BodyTextField = null;
         if(parent != null)
         {
            parent.removeChild(this);
         }
         this.stopVoiceSample();
         this._voiceSound.removeEventListener(Event.COMPLETE,this.onVoiceLoadCompleted);
         this._voiceSound.removeEventListener(IOErrorEvent.IO_ERROR,this.onVoiceLoadError);
         try
         {
            this._voiceSound.close();
         }
         catch(e:Error)
         {
         }
         TooltipManager.getInstance().removeAllFromParent(this);
         for each(_loc1_ in this._rowLabels)
         {
            _loc1_.dispose();
         }
         this._rowLabels = null;
         this._lang = null;
         this._appearance = null;
         this._skinColorOptions = null;
         this._hairColorOptions = null;
         this._hairOptions = null;
         this._facialHairOptions = null;
         this._voiceOptions = null;
         if(this.ui_skinPalette != null)
         {
            this.ui_skinPalette.dispose();
         }
         if(this.ui_hairPalette != null)
         {
            this.ui_hairPalette.dispose();
         }
         if(this.ui_hairStyle != null)
         {
            this.ui_hairStyle.dispose();
         }
         if(this.ui_facialHairStyle != null)
         {
            this.ui_facialHairStyle.dispose();
         }
         if(this.ui_hairOn != null)
         {
            this.ui_hairOn.dispose();
         }
         if(this.ui_gearHide != null)
         {
            this.ui_gearHide.dispose();
         }
         if(this.btn_male != null)
         {
            this.btn_male.dispose();
         }
         if(this.btn_female != null)
         {
            this.btn_female.dispose();
         }
         this.appearanceChanged.removeAll();
         this.genderChanged.removeAll();
         this.voiceChanged.removeAll();
      }
      
      public function updateForceHairOption() : void
      {
         var _loc1_:* = false;
         if(this._appearance == null)
         {
            return;
         }
         if(this._editFlags & FORCE_HAIR)
         {
            _loc1_ = (this._appearance.flags & AttireFlags.NO_HAIR) != 0;
            this.ui_hairOn.enabled = _loc1_;
            this.ui_hairOn.selected = _loc1_ && !this._appearance.forceHair;
         }
      }
      
      private function addRow(param1:String, param2:String) : int
      {
         var _loc3_:int = 0;
         var _loc4_:int = this.getRowOffset(this._rowCount);
         var _loc5_:int = int(this._width * this._rowLabelWidth);
         this._rowIndexById[param1] = this._rowCount;
         if(this._rowCount % 2 == 0)
         {
            this.mc_rowContainer.graphics.beginFill(2894892);
            this.mc_rowContainer.graphics.drawRect(_loc3_,_loc4_,_loc5_,this._rowHeight);
            this.mc_rowContainer.graphics.endFill();
            this.mc_rowContainer.graphics.beginFill(1447446);
            this.mc_rowContainer.graphics.drawRect(_loc3_ + _loc5_,_loc4_,this._width - _loc5_,this._rowHeight);
            this.mc_rowContainer.graphics.endFill();
         }
         var _loc6_:BodyTextField = new BodyTextField({
            "color":12895428,
            "size":13,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         _loc6_.maxWidth = _loc5_;
         _loc6_.htmlText = param2.toUpperCase();
         _loc6_.x = int(_loc3_ + _loc5_ - _loc6_.width - this._padding);
         _loc6_.y = int(_loc4_ + (this._rowHeight - _loc6_.height) * 0.5);
         this.mc_rowContainer.addChild(_loc6_);
         this._rowLabels.push(_loc6_);
         ++this._rowCount;
         this._height = this.mc_rowContainer.y + this.getRowOffset(this._rowCount);
         return this._rowCount - 1;
      }
      
      private function getRowOffset(param1:int) : int
      {
         return param1 * (this._rowHeight + this._rowSpacing);
      }
      
      private function getContentOffset(param1:int) : int
      {
         var _loc2_:int = 0;
         var _loc3_:int = int(this._width * this._rowLabelWidth);
         return _loc2_ + _loc3_ + this._padding;
      }
      
      private function setRowLabelEnabled(param1:String, param2:Boolean) : void
      {
         this._rowLabels[this._rowIndexById[param1]].alpha = param2 ? 1 : 0.3;
      }
      
      private function setToAppearance() : void
      {
         if(this._editFlags & GENDER)
         {
            this._gender = this._appearance.survivor.gender;
            this.btn_male.selected = this._appearance.survivor.gender == Gender.MALE;
            this.btn_female.selected = this._appearance.survivor.gender == Gender.FEMALE;
         }
         if(this._editFlags & SKIN_COLOR)
         {
            this.ui_skinPalette.selectColor(Color.hexToColor(this._skinColorOptions.(@id == _appearance.skin.id)[0].@color.toString()));
         }
         if(this._editFlags & HAIR)
         {
            this._hairOptions = this._attireXML.item.(@type == "hair" && (!hasOwnProperty("@classOnly") || @classOnly != "1") && Boolean(hasOwnProperty(_appearance.survivor.gender)));
            this.ui_hairStyle.min = 0;
            this.ui_hairStyle.max = this._hairOptions.length() - 1;
            this.ui_hairStyle.value = this.getNodeIndex(this._hairOptions,this._appearance.hair.id);
            this.setRowLabelEnabled("hair",this.ui_hairStyle.min != this.ui_hairStyle.max);
         }
         if(this._editFlags & FACIAL_HAIR)
         {
            this._facialHairOptions = this._attireXML.item.(@type == "fhair" && (!hasOwnProperty("@classOnly") || @classOnly != "1") && Boolean(hasOwnProperty(_appearance.survivor.gender)));
            this.ui_facialHairStyle.min = 0;
            this.ui_facialHairStyle.max = this._facialHairOptions.length() - 1;
            this.ui_facialHairStyle.value = this.getNodeIndex(this._facialHairOptions,this._appearance.facialHair.id);
            this.setRowLabelEnabled("fhair",this.ui_facialHairStyle.min != this.ui_facialHairStyle.max);
         }
         if(this._editFlags & VOICE)
         {
            this._voiceOptions = this._attireXML.voices.voice.(@gender == _appearance.survivor.gender);
            this.ui_voicePack.min = 0;
            this.ui_voicePack.max = this._voiceOptions.length() - 1;
            this.ui_voicePack.value = this.getNodeIndex(this._voiceOptions,this._appearance.survivor.voicePack);
            this.setupVoiceSamples();
            this.loadVoiceSample(false);
         }
         if(this._editFlags & HAIR_COLOR)
         {
            this.ui_hairPalette.selectColor(Color.hexToColor(this._hairColorOptions.(@id == _appearance.hairColor)[0].@color.toString()));
         }
         this.updateForceHairOption();
         this.updateSpinnerLabels();
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
      
      private function updateSpinnerLabels() : void
      {
         var _loc1_:XML = null;
         if(this.ui_hairStyle != null)
         {
            _loc1_ = this._hairOptions[this.ui_hairStyle.value];
            this.ui_hairStyle.label = this._lang.getString("attire.hair." + _loc1_.@id.toString() + "." + this._appearance.survivor.gender);
         }
         if(this.ui_facialHairStyle != null)
         {
            _loc1_ = this._facialHairOptions[this.ui_facialHairStyle.value];
            this.ui_facialHairStyle.label = this._lang.getString("attire.fhair." + _loc1_.@id.toString() + "." + this._appearance.survivor.gender);
         }
         if(this.ui_voicePack != null)
         {
            _loc1_ = this._voiceOptions[this.ui_voicePack.value];
            this.ui_voicePack.label = this._lang.getString("gender." + this._appearance.survivor.gender) + " " + (this.ui_voicePack.value + 1);
         }
      }
      
      private function stopVoiceSample() : void
      {
         if(this._voiceChannel != null)
         {
            this._voiceChannel.stop();
            this._voiceChannel = null;
         }
      }
      
      private function setupVoiceSamples() : void
      {
         var _loc1_:XML = this._voiceOptions[this.ui_voicePack.value];
         this._voiceSampleId = _loc1_.@id.toString();
         this._voiceSampleCount = int(_loc1_.@samples.toString());
         this._voiceSampleIndex = 1 + int(Math.random() * this._voiceSampleCount);
      }
      
      private function playVoiceSample() : void
      {
         this.stopVoiceSample();
         if(this._voiceSound != null)
         {
            this._voiceChannel = this._voiceSound.play();
         }
         this.incrementVoiceSampleIndex();
         this.loadVoiceSample(false);
      }
      
      private function incrementVoiceSampleIndex() : void
      {
         if(++this._voiceSampleIndex > this._voiceSampleCount)
         {
            this._voiceSampleIndex = 1;
         }
      }
      
      private function loadVoiceSample(param1:Boolean = false) : void
      {
         this.mc_voiceSpinner.visible = true;
         this.btn_playVoice.visible = false;
         this._voicePlayOnLoad = param1;
         var _loc2_:* = ResourceManager.getInstance().baseURL + "sound/voices/" + this._voiceSampleId + "-sample" + this._voiceSampleIndex + ".mp3";
         if(_loc2_.substr(0,1) != "/")
         {
            _loc2_ = "/" + _loc2_;
         }
         _loc2_ = Network.getInstance().client.gameFS.getUrl(_loc2_,Global.useSSL);
         this._voiceSound = new Sound();
         this._voiceSound.load(new URLRequest(_loc2_),new SoundLoaderContext(1000,true));
         this._voiceSound.addEventListener(Event.COMPLETE,this.onVoiceLoadCompleted,false,0,true);
         this._voiceSound.addEventListener(IOErrorEvent.IO_ERROR,this.onVoiceLoadError,false,0,true);
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(this._editFlags & GENDER)
         {
            _loc2_ = 14;
            if(this._genderButtonAlign == GENDER_ALIGN_CENTER)
            {
               _loc3_ = this.btn_male.width + this.btn_female.width + _loc2_;
               this.btn_male.x = int((this._width - _loc3_) * 0.5);
               this.btn_female.x = int(this.btn_male.x + this.btn_male.width + _loc2_);
            }
            else
            {
               this.btn_female.x = int(this._width - this.btn_female.width - 4);
               this.btn_male.x = int(this.btn_female.x - this.btn_male.width - _loc2_);
            }
         }
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
      }
      
      private function onSkinColorChanged(param1:UIColorPalette) : void
      {
         var colorId:String = null;
         var node:XML = null;
         var palette:UIColorPalette = param1;
         colorId = Color.colorToHex(this.ui_skinPalette.selectedColor).toLowerCase();
         node = this._skinColorOptions.(@color.toString().toLowerCase() == colorId)[0];
         this._appearance.skin.parseXML(node,this._appearance.survivor.gender);
         this._appearance.invalidate();
         this.appearanceChanged.dispatch();
      }
      
      private function onHairColorChanged(param1:UIColorPalette) : void
      {
         var colorId:String = null;
         var node:XML = null;
         var palette:UIColorPalette = param1;
         colorId = Color.colorToHex(this.ui_hairPalette.selectedColor).toLowerCase();
         node = this._hairColorOptions.(@color.toString().toLowerCase() == colorId)[0];
         this._appearance.hairColor = node.@id.toString();
         this.appearanceChanged.dispatch();
      }
      
      private function onHairChanged(param1:int) : void
      {
         var _loc2_:XML = this._hairOptions[param1];
         if(_loc2_ == null)
         {
            return;
         }
         this._appearance.hair.parseXML(_loc2_,this._appearance.survivor.gender);
         this._appearance.invalidate();
         this.updateSpinnerLabels();
         this.appearanceChanged.dispatch();
      }
      
      private function onFacialHairChanged(param1:int) : void
      {
         var _loc2_:XML = this._facialHairOptions[param1];
         if(_loc2_ == null)
         {
            return;
         }
         this._appearance.facialHair.parseXML(_loc2_,this._appearance.survivor.gender);
         this._appearance.invalidate();
         this.updateSpinnerLabels();
         this.appearanceChanged.dispatch();
      }
      
      private function onHairShowChanged(param1:CheckBox) : void
      {
         this._appearance.forceHair = !this._appearance.forceHair;
         this.ui_hairOn.selected = !this._appearance.forceHair;
         this.appearanceChanged.dispatch();
      }
      
      private function onGearHideChanged(param1:CheckBox) : void
      {
         this._appearance.hideGear = !this._appearance.hideGear;
         this.ui_gearHide.selected = this._appearance.hideGear;
         this.appearanceChanged.dispatch();
      }
      
      private function onVoicePackChanged(param1:int) : void
      {
         var _loc2_:XML = this._voiceOptions[param1];
         if(_loc2_ == null)
         {
            return;
         }
         this._appearance.survivor.voicePack = _loc2_.@id.toString();
         this.setupVoiceSamples();
         this.loadVoiceSample(true);
         this.updateSpinnerLabels();
         this.voiceChanged.dispatch();
      }
      
      private function onVoiceLoadCompleted(param1:Event) : void
      {
         this.mc_voiceSpinner.visible = false;
         this.btn_playVoice.visible = true;
         this._voiceSampleLoaded = true;
         if(this._voicePlayOnLoad)
         {
            this.playVoiceSample();
         }
      }
      
      private function onVoiceLoadError(param1:IOErrorEvent) : void
      {
         this.mc_voiceSpinner.visible = false;
         this.btn_playVoice.visible = true;
         this._voiceSampleLoaded = true;
      }
      
      private function onGenderButtonClicked(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         switch(param1.currentTarget)
         {
            case this.btn_male:
               _loc2_ = Gender.MALE;
               break;
            case this.btn_female:
               _loc2_ = Gender.FEMALE;
         }
         if(_loc2_ == this._gender)
         {
            return;
         }
         this._appearance.survivor.gender = _loc2_;
         this._appearance.setToCurrentClass(_loc2_);
         this.setToAppearance();
         if(this.ui_hairStyle != null)
         {
            this.onHairChanged(this.ui_hairStyle.value);
         }
         if(this.ui_facialHairStyle != null)
         {
            this.onFacialHairChanged(this.ui_facialHairStyle.value);
         }
         if(this.ui_voicePack != null)
         {
            this.onVoicePackChanged(this.ui_voicePack.value);
         }
         this._gender = _loc2_;
         this.btn_male.selected = this._gender == Gender.MALE;
         this.btn_female.selected = this._gender == Gender.FEMALE;
         this.genderChanged.dispatch(this._gender);
      }
      
      private function onClickPlayVoice(param1:MouseEvent) : void
      {
         this.playVoiceSample();
      }
   }
}

import com.exileetiquette.utils.NumberFormatter;
import com.greensock.TweenMax;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormatAlign;
import org.osflash.signals.Signal;
import thelaststand.app.display.BodyTextField;
import thelaststand.app.gui.UIComponent;
import thelaststand.app.gui.buttons.PushButton;

class AppearanceSpinner extends Sprite
{
   
   private var _min:int = 0;
   
   private var _max:int = 0;
   
   private var _value:int = 0;
   
   private var _width:int;
   
   private var _height:int = 16;
   
   private var _label:String = "";
   
   private var btn_prev:PushButton;
   
   private var btn_next:PushButton;
   
   private var txt_index:BodyTextField;
   
   private var txt_label:BodyTextField;
   
   public var changed:Signal = new Signal(int);
   
   public function AppearanceSpinner(param1:int)
   {
      super();
      this._width = param1;
      this.btn_prev = new PushButton(null,new BmpIconButtonPrev());
      this.btn_prev.clicked.add(this.onSpinnerClicked);
      this.btn_prev.width = this.btn_prev.height = this._height;
      this.btn_prev.showBorder = false;
      addChild(this.btn_prev);
      this.btn_next = new PushButton(null,new BmpIconButtonNext());
      this.btn_next.clicked.add(this.onSpinnerClicked);
      this.btn_next.width = this.btn_next.height = this._height;
      this.btn_next.x = int(this.btn_prev.x + this.btn_prev.width + 6);
      this.btn_next.showBorder = false;
      addChild(this.btn_next);
      this.txt_index = new BodyTextField({
         "color":12895428,
         "size":12,
         "autoSize":TextFieldAutoSize.NONE,
         "align":TextFormatAlign.CENTER,
         "bold":true
      });
      this.txt_index.x = int(this.btn_next.x + this.btn_next.width + 4);
      this.txt_index.y = int((this._height - this.txt_index.height) * 0.5 - 1);
      this.txt_index.width = this.txt_index.maxWidth = 32;
      this.txt_index.text = "0/0";
      addChild(this.txt_index);
      this.txt_label = new BodyTextField({
         "text":" ",
         "color":12895428,
         "size":12
      });
      this.txt_label.x = int(this.txt_index.x + 36);
      this.txt_label.y = int((this._height - this.txt_label.height) * 0.5 - 1);
      this.txt_label.maxWidth = int(this._width - this.txt_label.x);
      addChild(this.txt_label);
      this.updateEnabledState();
   }
   
   public function get min() : int
   {
      return this._min;
   }
   
   public function set min(param1:int) : void
   {
      this._min = param1;
      this.setIndex(this._value);
      this.updateEnabledState();
   }
   
   public function get max() : int
   {
      return this._max;
   }
   
   public function set max(param1:int) : void
   {
      this._max = param1;
      this.setIndex(this._value);
      this.updateEnabledState();
   }
   
   public function get value() : int
   {
      return this._value;
   }
   
   public function set value(param1:int) : void
   {
      this.setIndex(param1);
   }
   
   public function get label() : String
   {
      return this._label;
   }
   
   public function set label(param1:String) : void
   {
      this._label = param1;
      this.txt_label.text = this._label.toUpperCase();
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
   
   public function dispose() : void
   {
      if(parent != null)
      {
         parent.removeChild(this);
      }
      this.btn_next.dispose();
      this.btn_prev.dispose();
      this.txt_index.dispose();
      this.txt_label.dispose();
      this.changed.removeAll();
   }
   
   private function updateEnabledState() : void
   {
      this.btn_prev.enabled = this.btn_next.enabled = this.txt_index.visible = this.txt_label.visible = this._min != this._max;
   }
   
   private function setIndex(param1:int) : void
   {
      if(param1 < this._min)
      {
         param1 = int(this._max);
      }
      if(param1 > this._max)
      {
         param1 = int(this._min);
      }
      this._value = param1;
      this.txt_index.text = NumberFormatter.format(this._value + 1,0) + "/" + NumberFormatter.format(this._max + 1,0);
   }
   
   private function onSpinnerClicked(param1:MouseEvent) : void
   {
      switch(param1.currentTarget)
      {
         case this.btn_prev:
            this.setIndex(this._value - 1);
            this.changed.dispatch(this._value);
            break;
         case this.btn_next:
            this.setIndex(this._value + 1);
            this.changed.dispatch(this._value);
      }
   }
}

class UIPlayVoiceSampleButton extends UIComponent
{
   
   private var _defaultAlpha:Number = 0.75;
   
   private var bmp_icon:Bitmap;
   
   public function UIPlayVoiceSampleButton()
   {
      super();
      this.bmp_icon = new Bitmap(new BmpIconButtonNext());
      this.bmp_icon.alpha = this._defaultAlpha;
      addChild(this.bmp_icon);
      addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
      addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
   }
   
   override public function dispose() : void
   {
      super.dispose();
      this.bmp_icon.bitmapData.dispose();
   }
   
   private function onMouseOver(param1:MouseEvent) : void
   {
      TweenMax.to(this.bmp_icon,0,{"alpha":1});
   }
   
   private function onMouseOut(param1:MouseEvent) : void
   {
      TweenMax.to(this.bmp_icon,0.1,{"alpha":this._defaultAlpha});
   }
}
