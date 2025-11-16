package thelaststand.app.game.gui.compound
{
   import flash.display.DisplayObject;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.AntiAliasType;
   import org.osflash.signals.Signal;
   import thelaststand.app.display.TitleTextField;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorClass;
   import thelaststand.app.game.data.SurvivorLoadout;
   import thelaststand.app.game.gui.UISurvivorPortrait;
   import thelaststand.app.game.gui.dialogues.SurvivorListDialogue;
   import thelaststand.app.game.gui.loadout.UIMissionSurvivorSlot;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.common.lang.Language;
   
   public class UIRallyAssignment extends Sprite
   {
      
      private var _lang:Language;
      
      private var _width:int = 110;
      
      private var _height:int = 174;
      
      private var _panelWidth:int = 170;
      
      private var _panels:Vector.<UIMissionSurvivorSlot>;
      
      private var _building:Building;
      
      private var mc_background:Shape;
      
      private var mc_listArea:Shape;
      
      private var txt_title:TitleTextField;
      
      public var mouseOverSlot:Signal;
      
      public var mouseOutSlot:Signal;
      
      public function UIRallyAssignment()
      {
         super();
         this._lang = Language.getInstance();
         this._panels = new Vector.<UIMissionSurvivorSlot>();
         this.mc_background = new Shape();
         this.mc_background.filters = [BaseDialogue.INNER_SHADOW,BaseDialogue.STROKE,BaseDialogue.DROP_SHADOW];
         addChild(this.mc_background);
         this.mc_listArea = new Shape();
         addChild(this.mc_listArea);
         this.txt_title = new TitleTextField({
            "text":this._lang.getString("rally_assigned_title"),
            "color":11053224,
            "size":14,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         addChild(this.txt_title);
         this.mouseOverSlot = new Signal(int);
         this.mouseOutSlot = new Signal(int);
      }
      
      public function dispose() : void
      {
         var _loc1_:UIMissionSurvivorSlot = null;
         if(parent != null)
         {
            parent.removeChild(this);
         }
         this.mc_background.filters = [];
         this.txt_title.dispose();
         this.txt_title = null;
         if(this._building != null)
         {
            this._building.assignmentChanged.remove(this.onAssignmentChanged);
            this._building = null;
         }
         for each(_loc1_ in this._panels)
         {
            _loc1_.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverSlot);
            _loc1_.removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOutSlot);
            _loc1_.dispose();
         }
         this._panels = null;
         this._lang = null;
      }
      
      private function draw() : void
      {
         var _loc1_:UIMissionSurvivorSlot = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         for each(_loc1_ in this._panels)
         {
            _loc1_.removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverSlot);
            _loc1_.removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOutSlot);
            _loc1_.dispose();
         }
         this._panels.length = 0;
         this._width = this._panelWidth + 16;
         _loc2_ = this._building.numAssignableSurvivors;
         _loc3_ = this._panelWidth + 4;
         _loc4_ = _loc2_ * 46 + 4;
         this.txt_title.x = int((this._width - this.txt_title.width) * 0.5) + 1;
         this.txt_title.y = 6;
         _loc5_ = int((this._width - _loc3_) * 0.5) + 4;
         _loc6_ = int(this.txt_title.y + this.txt_title.height + 4);
         _loc7_ = 0;
         while(_loc7_ < _loc2_)
         {
            _loc1_ = new UIMissionSurvivorSlot(UIMissionSurvivorSlot.SHOW_NONE,this._panelWidth,46,UISurvivorPortrait.SIZE_32x32);
            _loc1_.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverSlot,false,0,true);
            _loc1_.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOutSlot,false,0,true);
            _loc1_.clicked.add(this.onSlotClicked);
            _loc1_.x = _loc5_;
            _loc1_.y = _loc6_;
            this._panels.push(_loc1_);
            addChild(_loc1_);
            _loc6_ += _loc1_.height - 1;
            _loc7_++;
         }
         this._height = Math.max(174,int(_loc6_ + 6));
         this.mc_background.graphics.clear();
         this.mc_background.graphics.beginFill(5460561);
         this.mc_background.graphics.drawRect(0,0,this._width,this._height);
         this.mc_background.graphics.endFill();
         this.mc_background.graphics.beginBitmapFill(BaseDialogue.BMP_GRIME);
         this.mc_background.graphics.drawRect(0,0,this._width,this._height);
         this.mc_background.graphics.endFill();
      }
      
      private function updateAssignment() : void
      {
         var _loc2_:UIMissionSurvivorSlot = null;
         var _loc3_:Survivor = null;
         var _loc1_:int = 0;
         while(_loc1_ < this._building.assignedSurvivors.length)
         {
            _loc2_ = this._panels[_loc1_];
            _loc3_ = this._building.assignedSurvivors[_loc1_];
            _loc2_.setSurvivor(_loc3_,_loc3_ != null ? _loc3_.loadoutDefence : null);
            _loc1_++;
         }
      }
      
      private function onMouseOverSlot(param1:MouseEvent) : void
      {
         var _loc2_:UIMissionSurvivorSlot = param1.currentTarget as UIMissionSurvivorSlot;
         this.mouseOverSlot.dispatch(this._panels.indexOf(_loc2_));
      }
      
      private function onMouseOutSlot(param1:MouseEvent) : void
      {
         var _loc2_:UIMissionSurvivorSlot = param1.currentTarget as UIMissionSurvivorSlot;
         if(param1.relatedObject != null && _loc2_.contains(param1.relatedObject as DisplayObject))
         {
            return;
         }
         this.mouseOutSlot.dispatch(this._panels.indexOf(param1.currentTarget));
      }
      
      private function onSlotClicked(param1:MouseEvent) : void
      {
         var slot:UIMissionSurvivorSlot = null;
         var dlg:SurvivorListDialogue = null;
         var e:MouseEvent = param1;
         slot = e.currentTarget as UIMissionSurvivorSlot;
         dlg = new SurvivorListDialogue(this._lang.getString("select_survivor_title"),Network.getInstance().playerData.compound.survivors,Vector.<Survivor>([slot.survivor]),Vector.<String>([SurvivorClass.UNASSIGNED]),true);
         dlg.selected.add(function(param1:Survivor):void
         {
            var slotIndex:int = 0;
            var msg:MessageBox = null;
            var srv:Survivor = param1;
            slotIndex = int(_panels.indexOf(slot));
            if(srv != null && srv.rallyAssignment != null && srv.rallyAssignment != _building)
            {
               msg = new MessageBox(_lang.getString("rally_assign_confirm_msg",srv.firstName));
               msg.addTitle(_lang.getString("rally_assign_confirm_title"));
               msg.addButton(_lang.getString("rally_assign_confirm_cancel")).clicked.add(function(param1:MouseEvent):void
               {
                  dlg.selectItem(-1);
               });
               msg.addButton(_lang.getString("rally_assign_confirm_ok")).clicked.add(function(param1:MouseEvent):void
               {
                  _building.assignSurvivor(srv,slotIndex);
                  dlg.close();
               });
               msg.open();
               return;
            }
            _building.assignSurvivor(srv,slotIndex);
            dlg.close();
         });
         dlg.open();
      }
      
      private function onAssignmentChanged(param1:Building, param2:Survivor, param3:int) : void
      {
         if(param3 < 0 || param3 >= this._panels.length)
         {
            return;
         }
         var _loc4_:UIMissionSurvivorSlot = this._panels[param3];
         if(_loc4_ == null)
         {
            return;
         }
         _loc4_.setSurvivor(param2,param2 != null ? param2.loadoutDefence : null);
      }
      
      public function get building() : Building
      {
         return this._building;
      }
      
      public function set building(param1:Building) : void
      {
         if(this._building == param1)
         {
            this.updateAssignment();
            return;
         }
         if(this._building != null)
         {
            this._building.assignmentChanged.remove(this.onAssignmentChanged);
         }
         this._building = param1;
         if(this._building == null)
         {
            return;
         }
         this._building.assignmentChanged.add(this.onAssignmentChanged);
         this.draw();
         this.updateAssignment();
      }
   }
}

