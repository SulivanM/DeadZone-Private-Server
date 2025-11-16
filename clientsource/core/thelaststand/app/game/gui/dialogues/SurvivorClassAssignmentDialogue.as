package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Config;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorClass;
   import thelaststand.app.game.gui.survivor.UISurvivorClassDetails;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class SurvivorClassAssignmentDialogue extends BaseDialogue
   {
      
      private var _lang:Language;
      
      private var _survivor:Survivor;
      
      private var _thumbs:Vector.<ClassThumbPanel>;
      
      private var _selectedThumb:ClassThumbPanel;
      
      private var _selectedClass:SurvivorClass;
      
      private var _showingMoreDetails:Boolean;
      
      private var mc_container:Sprite;
      
      private var ui_details:UISurvivorClassDetails;
      
      private var btn_select:PushButton;
      
      private var btn_details:PushButton;
      
      public var selected:Signal;
      
      public function SurvivorClassAssignmentDialogue(param1:Survivor, param2:String, param3:Boolean = true)
      {
         var _loc8_:String = null;
         var _loc11_:String = null;
         var _loc12_:ClassThumbPanel = null;
         this._survivor = param1;
         this._lang = Language.getInstance();
         this.selected = new Signal(String,Boolean);
         this.mc_container = new Sprite();
         super("class-assignment",this.mc_container,true);
         _autoSize = false;
         _padding = 12;
         _width = 535;
         _height = 432;
         addTitle(param2,4671303,396);
         var _loc4_:int = 8;
         var _loc5_:Array = SurvivorClass.getClasses();
         var _loc6_:int = _loc4_;
         var _loc7_:int = _loc4_ + _padding * 0.5;
         this._thumbs = new Vector.<ClassThumbPanel>();
         var _loc9_:int = 0;
         var _loc10_:int = int(_loc5_.length);
         while(_loc9_ < _loc10_)
         {
            _loc11_ = _loc5_[_loc9_];
            _loc12_ = new ClassThumbPanel(_loc11_,this._survivor.gender);
            _loc12_.addEventListener(MouseEvent.CLICK,this.onSelectClass,false,0,true);
            _loc12_.x = _loc6_;
            _loc12_.y = _loc7_;
            if(_loc8_ == null)
            {
               _loc8_ = _loc11_;
            }
            TooltipManager.getInstance().add(_loc12_,this._lang.getString("survivor_classes." + _loc11_),new Point(0,NaN),TooltipDirection.DIRECTION_RIGHT,0);
            this._thumbs.push(_loc12_);
            this.mc_container.addChild(_loc12_);
            _loc7_ += int(_loc12_.height + _loc4_);
            _loc9_++;
         }
         GraphicUtils.drawUIBlock(this.mc_container.graphics,int(this._thumbs[0].width + _loc4_ * 2),int(_loc7_ - _padding * 0.5),0,int(_padding * 0.5));
         this.ui_details = new UISurvivorClassDetails();
         this.ui_details.x = int(_width - this.ui_details.width - _padding * 2);
         this.ui_details.y = int(_padding * 0.5);
         this.mc_container.addChild(this.ui_details);
         this.btn_select = new PushButton();
         this.btn_select.clicked.add(this.onClickSelect);
         this.btn_select.width = 120;
         this.btn_select.x = int(_width - _padding * 2 - this.btn_select.width - 12);
         this.btn_select.y = int(_height - _padding * 2 - _padding * 0.5 - this.btn_select.height);
         this.mc_container.addChild(this.btn_select);
         this.btn_details = new PushButton(this._lang.getString("srv_assign_moredetails"));
         this.btn_details.clicked.add(this.onClickDetails);
         this.btn_details.width = 120;
         this.btn_details.x = int(this.ui_details.x + (282 - this.btn_details.width) * 0.5);
         this.btn_details.y = this.btn_select.y;
         this.mc_container.addChild(this.btn_details);
         this.selectClass(_loc8_);
      }
      
      override public function dispose() : void
      {
         var _loc1_:ClassThumbPanel = null;
         super.dispose();
         this._survivor = null;
         this._selectedClass = null;
         this._lang = null;
         this.selected.removeAll();
         this.ui_details.dispose();
         for each(_loc1_ in this._thumbs)
         {
            _loc1_.dispose();
         }
         this._thumbs = null;
         this._selectedThumb = null;
         TooltipManager.getInstance().removeAllFromParent(this.mc_container);
      }
      
      private function selectClass(param1:String) : void
      {
         var _loc3_:ClassThumbPanel = null;
         if(this._selectedThumb != null)
         {
            this._selectedThumb.selected = false;
            this._selectedThumb = null;
         }
         var _loc2_:ClassThumbPanel = null;
         for each(_loc3_ in this._thumbs)
         {
            if(_loc3_.classId == param1)
            {
               _loc2_ = _loc3_;
               break;
            }
         }
         if(_loc2_ == null)
         {
            return;
         }
         _loc2_.selected = true;
         this._selectedThumb = _loc2_;
         this._selectedClass = Network.getInstance().data.getSurvivorClass(param1);
         var _loc4_:int = this._survivor.classId == SurvivorClass.UNASSIGNED ? int(this._survivor.level) : int(this._survivor.level + Config.constant.SURVIVOR_REASSIGN_LEVEL_PENALTY);
         this.ui_details.setSurvivorClass(this._selectedClass,_loc4_,this._survivor.gender);
         this.btn_select.label = this._lang.getString("srv_assign_select",this._lang.getString("survivor_classes." + this._selectedClass.id));
         this.btn_select.enabled = this._selectedClass.id != this._survivor.classId;
         this._showingMoreDetails = false;
         this.btn_details.label = this._lang.getString("srv_assign_moredetails");
      }
      
      private function onSelectClass(param1:MouseEvent) : void
      {
         var _loc2_:ClassThumbPanel = param1.currentTarget as ClassThumbPanel;
         this.selectClass(_loc2_.classId);
      }
      
      private function onClickSelect(param1:MouseEvent) : void
      {
         var className:String;
         var dlgConfirmUnassigned:MessageBox = null;
         var dlgConfirmReassign:ConfirmReassignDialogue = null;
         var e:MouseEvent = param1;
         if(this._selectedClass.id == this._survivor.classId || this._survivor.classId == SurvivorClass.PLAYER)
         {
            return;
         }
         className = this._lang.getString("survivor_classes." + this._selectedClass.id);
         if(this._survivor.classId == SurvivorClass.UNASSIGNED)
         {
            dlgConfirmUnassigned = new MessageBox(this._lang.getString("srv_assign_confirm_msg",this._survivor.firstName,className),null,true,true);
            dlgConfirmUnassigned.addTitle(this._lang.getString("srv_assign_confirm_title",this._survivor.firstName,className),BaseDialogue.TITLE_COLOR_GREY);
            dlgConfirmUnassigned.addButton(this._lang.getString("srv_assign_confirm_ok")).clicked.addOnce(function(param1:MouseEvent):void
            {
               selected.dispatch(_selectedClass.id,false);
               close();
            });
            dlgConfirmUnassigned.addButton(this._lang.getString("srv_assign_confirm_cancel"));
            dlgConfirmUnassigned.open();
         }
         else
         {
            dlgConfirmReassign = new ConfirmReassignDialogue(this._survivor,this._selectedClass);
            dlgConfirmReassign.confirmed.addOnce(function(param1:Boolean):void
            {
               selected.dispatch(_selectedClass.id,param1);
               close();
            });
            dlgConfirmReassign.open();
         }
      }
      
      private function onClickDetails(param1:MouseEvent) : void
      {
         this._showingMoreDetails = !this._showingMoreDetails;
         this.ui_details.showMoreDetails(this._showingMoreDetails);
         this.btn_details.label = this._lang.getString(this._showingMoreDetails ? "srv_assign_lessdetails" : "srv_assign_moredetails");
      }
   }
}

import com.greensock.TweenMax;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import thelaststand.app.audio.Audio;
import thelaststand.app.gui.UIImage;

class ConfirmReassign extends Sprite
{
   
   public function ConfirmReassign(param1:int)
   {
      super();
   }
}

class ClassThumbPanel extends Sprite
{
   
   private var _width:int = 70;
   
   private var _height:int = 70;
   
   private var _classId:String;
   
   private var _selected:Boolean = false;
   
   private var _enabled:Boolean = true;
   
   private var mc_border:Shape;
   
   private var ui_image:UIImage;
   
   public function ClassThumbPanel(param1:String, param2:String)
   {
      super();
      this._classId = param1;
      mouseChildren = false;
      this.ui_image = new UIImage(this._width - 2,this._height - 2);
      this.ui_image.uri = "images/ui/class-icon-" + param1 + "-" + param2 + ".jpg";
      this.ui_image.x = this.ui_image.y = 1;
      addChild(this.ui_image);
      this.mc_border = new Shape();
      addChild(this.mc_border);
      this.drawBorder();
      addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
      addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
      addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
   }
   
   public function dispose() : void
   {
      if(parent != null)
      {
         parent.removeChild(this);
      }
      this.ui_image.dispose();
   }
   
   private function drawBorder() : void
   {
      var _loc1_:int = this._selected ? 2 : 1;
      var _loc2_:int = this._selected ? 8992288 : 5395026;
      this.mc_border.graphics.clear();
      this.mc_border.graphics.beginFill(_loc2_);
      this.mc_border.graphics.drawRect(0,0,this._width,this._height);
      this.mc_border.graphics.drawRect(_loc1_,_loc1_,this._width - _loc1_ * 2,this._height - _loc1_ * 2);
      this.mc_border.graphics.endFill();
   }
   
   private function onMouseOver(param1:MouseEvent) : void
   {
      TweenMax.to(this.ui_image,0,{
         "colorTransform":{"exposure":1.05},
         "overwrite":true
      });
      Audio.sound.play("sound/interface/int-over.mp3");
   }
   
   private function onMouseOut(param1:MouseEvent) : void
   {
      TweenMax.to(this.ui_image,0.15,{
         "colorTransform":{"exposure":1},
         "overwrite":true
      });
   }
   
   private function onMouseDown(param1:MouseEvent) : void
   {
      var e:MouseEvent = param1;
      TweenMax.to(this.ui_image,0,{
         "colorTransform":{"exposure":1.75},
         "onComplete":function():void
         {
            TweenMax.to(ui_image,0.15,{"colorTransform":{"exposure":1}});
         }
      });
      Audio.sound.play("sound/interface/int-click.mp3");
   }
   
   public function get selected() : Boolean
   {
      return this._selected;
   }
   
   public function set selected(param1:Boolean) : void
   {
      this._selected = param1;
      mouseEnabled = Boolean(this._enabled) && !this._selected;
      this.drawBorder();
   }
   
   public function get enabled() : Boolean
   {
      return this._enabled;
   }
   
   public function set enabled(param1:Boolean) : void
   {
      this._enabled = param1;
      mouseEnabled = Boolean(this._enabled) && !this._selected;
      this.ui_image.alpha = this._enabled ? 1 : 0.25;
   }
   
   public function get classId() : String
   {
      return this._classId;
   }
}
