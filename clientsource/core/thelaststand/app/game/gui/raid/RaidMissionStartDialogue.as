package thelaststand.app.game.gui.raid
{
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.geom.ColorTransform;
   import flash.geom.Rectangle;
   import thelaststand.app.game.data.raid.RaidData;
   import thelaststand.app.game.data.raid.RaidStageData;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class RaidMissionStartDialogue extends BaseDialogue
   {
      
      private var _raidData:RaidData;
      
      private var _raidStage:RaidStageData;
      
      private var _objectiveRows:Vector.<ObjectiveRow>;
      
      private var mc_container:Sprite;
      
      private var mc_objectives:Sprite;
      
      private var ui_image:UIImage;
      
      private var bmp_background:Bitmap;
      
      private var bmp_seperator:Bitmap;
      
      private var bmp_tape_tl:Bitmap;
      
      private var bmp_tape_tr:Bitmap;
      
      private var bmp_tape_bl:Bitmap;
      
      private var bmp_tape_br:Bitmap;
      
      public function RaidMissionStartDialogue(param1:RaidData)
      {
         var _loc11_:int = 0;
         var _loc12_:ObjectiveRow = null;
         this.mc_container = new Sprite();
         super("raid-mission-start",this.mc_container,true);
         _width = 365;
         _height = 370;
         _autoSize = false;
         _buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         this._raidData = param1;
         this._raidStage = this._raidData.getRaidStage(this._raidData.currentStageIndex);
         var _loc2_:String = Language.getInstance().getString("raid." + this._raidData.name + ".stage_" + this._raidStage.name);
         addTitle(Language.getInstance().getString("raid.title",_loc2_),BaseDialogue.TITLE_COLOR_GREY);
         addButton(Language.getInstance().getString("raid.launch"),true,{"width":150});
         this.bmp_background = new Bitmap(new BmpRaidMissionBg());
         this.bmp_background.scale9Grid = new Rectangle(14,14,this.bmp_background.width - 28,this.bmp_background.height - 28);
         this.mc_container.addChild(this.bmp_background);
         var _loc3_:int = 13;
         this.ui_image = new UIImage(316,190,4605510);
         this.ui_image.x = int(this.bmp_background.x + (this.bmp_background.width - this.ui_image.width) * 0.5);
         this.ui_image.y = int(this.bmp_background.y + _loc3_);
         this.ui_image.uri = ("images/raids/" + this._raidData.name + "_" + this._raidStage.name + "_large.jpg").toLowerCase();
         this.mc_container.addChild(this.ui_image);
         this.bmp_seperator = new Bitmap(new BmpDivider());
         this.bmp_seperator.width = this.ui_image.width;
         this.bmp_seperator.x = int(this.ui_image.x);
         this.bmp_seperator.y = int(this.ui_image.y + this.ui_image.height + 5);
         var _loc4_:ColorTransform = new ColorTransform(0,0,0,1);
         this.bmp_seperator.transform.colorTransform = _loc4_;
         this.mc_container.addChild(this.bmp_seperator);
         this._objectiveRows = new Vector.<ObjectiveRow>();
         this.mc_objectives = new Sprite();
         this.mc_container.addChild(this.mc_objectives);
         var _loc5_:int = this._raidData.survivorIds.length * this._raidData.pointsPerSurvivor;
         var _loc6_:ObjectiveRow = new ObjectiveRow(Language.getInstance().getString("raid.obj_survivors",this._raidData.survivorIds.length),_loc5_,new BmpIconRaidObjSurvivors());
         this._objectiveRows.push(_loc6_);
         var _loc7_:String = Language.getInstance().getString("raid." + this._raidData.name + ".obj_" + this._raidStage.objectiveXML.lang.toString());
         var _loc8_:ObjectiveRow = new ObjectiveRow(_loc7_,this._raidStage.objectivePoints,new BmpIconRaidObjSecondary());
         this._objectiveRows.push(_loc8_);
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         while(_loc10_ < this._objectiveRows.length)
         {
            _loc12_ = this._objectiveRows[_loc10_];
            this.mc_objectives.addChild(_loc12_);
            _loc12_.y = _loc9_;
            _loc12_.width = this.ui_image.width;
            _loc12_.height = 34;
            _loc12_.alternate = _loc10_ % 2 != 0;
            _loc9_ += int(_loc12_.height);
            _loc10_++;
         }
         this.mc_objectives.x = int(this.ui_image.x);
         this.mc_objectives.y = int(this.bmp_background.y + this.bmp_background.height - _loc3_ - this.mc_objectives.height - 6);
         _loc11_ = -1;
         this.bmp_tape_tl = new Bitmap(new BmpAllianceMessageTape());
         this.bmp_tape_tl.x = this.bmp_background.x - _loc11_;
         this.bmp_tape_tl.y = this.bmp_background.y - _loc11_;
         this.mc_container.addChild(this.bmp_tape_tl);
         this.bmp_tape_tr = new Bitmap(new BmpAllianceMessageTape());
         this.bmp_tape_tr.scaleX = -1;
         this.bmp_tape_tr.x = this.bmp_background.x + this.bmp_background.width + _loc11_;
         this.bmp_tape_tr.y = this.bmp_background.y - _loc11_;
         this.mc_container.addChild(this.bmp_tape_tr);
         this.bmp_tape_bl = new Bitmap(new BmpAllianceMessageTape());
         this.bmp_tape_bl.scaleY = -1;
         this.bmp_tape_bl.x = this.bmp_background.x - _loc11_;
         this.bmp_tape_bl.y = this.bmp_background.y + this.bmp_background.height + _loc11_;
         this.mc_container.addChild(this.bmp_tape_bl);
         this.bmp_tape_br = new Bitmap(new BmpAllianceMessageTape());
         this.bmp_tape_br.scaleX = -1;
         this.bmp_tape_br.scaleY = -1;
         this.bmp_tape_br.x = this.bmp_background.x + this.bmp_background.width + _loc11_;
         this.bmp_tape_br.y = this.bmp_background.y + this.bmp_background.height + _loc11_;
         this.mc_container.addChild(this.bmp_tape_br);
      }
      
      override public function dispose() : void
      {
         var _loc2_:ObjectiveRow = null;
         super.dispose();
         this._raidData = null;
         this._raidStage = null;
         this.bmp_seperator.bitmapData.dispose();
         this.bmp_seperator.bitmapData.dispose();
         this.bmp_tape_tl.bitmapData.dispose();
         this.bmp_tape_tr.bitmapData.dispose();
         this.bmp_tape_bl.bitmapData.dispose();
         this.bmp_tape_br.bitmapData.dispose();
         this.ui_image.dispose();
         var _loc1_:int = 0;
         while(_loc1_ < this._objectiveRows.length)
         {
            _loc2_ = this._objectiveRows[_loc1_];
            _loc2_.dispose();
            _loc1_++;
         }
      }
   }
}

import com.exileetiquette.utils.NumberFormatter;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.text.AntiAliasType;
import thelaststand.app.display.BodyTextField;
import thelaststand.app.gui.UIComponent;

class ObjectiveRow extends UIComponent
{
   
   private var _width:int;
   
   private var _height:int;
   
   private var _altRow:Boolean;
   
   private var mc_background:Shape;
   
   private var txt_objective:BodyTextField;
   
   private var txt_points:BodyTextField;
   
   private var bmp_image:Bitmap;
   
   public function ObjectiveRow(param1:String, param2:int, param3:BitmapData)
   {
      super();
      this.mc_background = new Shape();
      addChild(this.mc_background);
      this.txt_objective = new BodyTextField({
         "color":12632256,
         "size":16,
         "bold":true,
         "antiAliasType":AntiAliasType.ADVANCED
      });
      this.txt_objective.text = param1;
      addChild(this.txt_objective);
      this.txt_points = new BodyTextField({
         "color":12632256,
         "size":16,
         "bold":true,
         "antiAliasType":AntiAliasType.ADVANCED
      });
      this.txt_points.text = "+" + NumberFormatter.format(param2,0);
      addChild(this.txt_points);
      this.bmp_image = new Bitmap(param3);
      addChild(this.bmp_image);
   }
   
   public function get alternate() : Boolean
   {
      return this._altRow;
   }
   
   public function set alternate(param1:Boolean) : void
   {
      this._altRow = param1;
   }
   
   override public function get width() : Number
   {
      return this._width;
   }
   
   override public function set width(param1:Number) : void
   {
      this._width = param1;
      invalidate();
   }
   
   override public function get height() : Number
   {
      return this._height;
   }
   
   override public function set height(param1:Number) : void
   {
      this._height = param1;
      invalidate();
   }
   
   override public function dispose() : void
   {
      super.dispose();
      if(this.bmp_image.bitmapData != null)
      {
         this.bmp_image.bitmapData.dispose();
      }
      this.txt_objective.dispose();
      this.txt_points.dispose();
   }
   
   override protected function draw() : void
   {
      this.mc_background.graphics.clear();
      this.mc_background.graphics.beginFill(0,this._altRow ? 0.7 : 0.8);
      this.mc_background.graphics.drawRect(0,0,this._width,this._height);
      this.mc_background.graphics.endFill();
      this.bmp_image.x = int(this.bmp_image.width * 0.5);
      this.bmp_image.y = int((this._height - this.bmp_image.height) * 0.5);
      this.txt_objective.x = 44;
      this.txt_objective.y = int((this._height - this.txt_objective.height) * 0.5);
      this.txt_points.x = int(this._width - this.txt_points.width - 8);
      this.txt_points.y = this.txt_objective.y;
   }
}
