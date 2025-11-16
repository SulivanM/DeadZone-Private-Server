package thelaststand.app.game.gui.arena
{
   import flash.display.Bitmap;
   import flash.events.MouseEvent;
   import org.osflash.signals.Signal;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorClass;
   import thelaststand.app.game.data.SurvivorLoadout;
   import thelaststand.app.game.data.SurvivorState;
   import thelaststand.app.game.data.arena.ArenaSession;
   import thelaststand.app.game.gui.UISurvivorPortrait;
   import thelaststand.app.game.gui.dialogues.SpeedUpDialogue;
   import thelaststand.app.game.gui.dialogues.SurvivorListDialogue;
   import thelaststand.app.game.gui.loadout.UIMissionSurvivorSlot;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.gui.UITitleBar;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class ArenaSurvivorsView extends UIComponent
   {
      
      private var _session:ArenaSession;
      
      private var _slots:Vector.<UIMissionSurvivorSlot> = new Vector.<UIMissionSurvivorSlot>();
      
      private var _survivorsUsed:Vector.<Survivor> = new Vector.<Survivor>();
      
      private var _width:int;
      
      private var _height:int;
      
      private var ui_titleBar:UITitleBar;
      
      private var txt_title:BodyTextField;
      
      private var bmp_lock:Bitmap;
      
      public var loadoutsChanged:Signal = new Signal();
      
      public function ArenaSurvivorsView()
      {
         super();
         this.ui_titleBar = new UITitleBar(null,3223857);
         addChild(this.ui_titleBar);
         this.txt_title = new BodyTextField({
            "color":11053224,
            "size":16,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         addChild(this.txt_title);
         this.bmp_lock = new Bitmap(new BmpIconItemLocked());
         this.bmp_lock.alpha = 0.3;
         addChild(this.bmp_lock);
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
      
      public function setData(param1:ArenaSession) : void
      {
         var _loc2_:UIMissionSurvivorSlot = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:UIMissionSurvivorSlot = null;
         this._session = param1;
         for each(_loc2_ in this._slots)
         {
            _loc2_.dispose();
         }
         this._slots.length = 0;
         _loc3_ = this._width - 4;
         _loc4_ = 0;
         while(_loc4_ < this._session.maxSurvivorCount)
         {
            _loc5_ = new UIMissionSurvivorSlot(UIMissionSurvivorSlot.SHOW_HEAL,_loc3_,46,UISurvivorPortrait.SIZE_32x32);
            _loc5_.mouseEnabled = _loc5_.mouseChildren = !this._session.hasStarted;
            _loc5_.clicked.add(this.onSlotClicked);
            addChild(_loc5_);
            this._slots.push(_loc5_);
            _loc4_++;
         }
         if(this._session.hasStarted)
         {
            mouseChildren = false;
         }
         invalidate();
      }
      
      override public function dispose() : void
      {
         var _loc1_:UIMissionSurvivorSlot = null;
         super.dispose();
         this.bmp_lock.bitmapData.dispose();
         this.txt_title.dispose();
         this.ui_titleBar.dispose();
         this.loadoutsChanged.removeAll();
         for each(_loc1_ in this._slots)
         {
            if(_loc1_.survivor != null)
            {
               _loc1_.survivor.loadoutOffence.changed.remove(this.onSurvivorLoadoutChanged);
               _loc1_.survivor.injuries.changed.remove(this.onSurvivorInjuriesChanged);
            }
            _loc1_.dispose();
         }
      }
      
      override protected function draw() : void
      {
         var _loc2_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:UIMissionSurvivorSlot = null;
         graphics.clear();
         GraphicUtils.drawUIBlock(graphics,this._width,this._height);
         var _loc1_:int = 3;
         this.ui_titleBar.x = _loc1_;
         this.ui_titleBar.y = _loc1_;
         this.ui_titleBar.width = int(this._width - _loc1_ * 2);
         this.ui_titleBar.height = 32;
         this.txt_title.text = Language.getInstance().getString("arena.survivors").toUpperCase();
         this.txt_title.y = int(this.ui_titleBar.y + (this.ui_titleBar.height - this.txt_title.height) * 0.5);
         if(this._session.hasStarted)
         {
            this.bmp_lock.visible = true;
            _loc4_ = this.bmp_lock.width + 6 + this.txt_title.width;
            this.bmp_lock.x = int(this.ui_titleBar.x + (this.ui_titleBar.width - _loc4_) * 0.5);
            this.bmp_lock.y = int(this.ui_titleBar.y + (this.ui_titleBar.height - this.bmp_lock.height) * 0.5);
            this.txt_title.x = int(this.bmp_lock.x + this.bmp_lock.width + 6);
         }
         else
         {
            this.bmp_lock.visible = false;
            this.txt_title.x = int(this.ui_titleBar.x + (this.ui_titleBar.width - this.txt_title.width) * 0.5);
         }
         _loc2_ = int(this.ui_titleBar.y + this.ui_titleBar.height + 4);
         var _loc3_:int = 0;
         while(_loc3_ < this._slots.length)
         {
            _loc5_ = this._slots[_loc3_];
            _loc5_.x = int((this._width - _loc5_.width) * 0.5);
            _loc5_.y = _loc2_;
            _loc2_ += int(_loc5_.height);
            _loc3_++;
         }
         this.updateSurvivors();
      }
      
      private function updateSurvivors() : void
      {
         var _loc2_:UIMissionSurvivorSlot = null;
         var _loc3_:String = null;
         var _loc4_:Survivor = null;
         this._survivorsUsed.length = 0;
         var _loc1_:int = 0;
         while(_loc1_ < this._slots.length)
         {
            _loc2_ = this._slots[_loc1_];
            _loc3_ = _loc1_ < this._session.survivorIds.length ? this._session.survivorIds[_loc1_] : null;
            _loc4_ = _loc3_ != null ? Network.getInstance().playerData.compound.survivors.getSurvivorById(_loc3_) : null;
            _loc2_.setSurvivor(_loc4_,_loc4_ != null ? _loc4_.loadoutOffence : null);
            if(_loc4_ != null)
            {
               this._survivorsUsed.push(_loc4_);
            }
            _loc1_++;
         }
      }
      
      private function onSlotClicked(param1:MouseEvent) : void
      {
         var assignSurvivor:Function;
         var slot:UIMissionSurvivorSlot = null;
         var dlg:SurvivorListDialogue = null;
         var e:MouseEvent = param1;
         if(this._session.hasStarted)
         {
            return;
         }
         slot = e.currentTarget as UIMissionSurvivorSlot;
         assignSurvivor = function(param1:SurvivorListDialogue, param2:Survivor):void
         {
            var _loc3_:int = 0;
            if(slot.survivor != null)
            {
               slot.survivor.loadoutOffence.changed.remove(onSurvivorLoadoutChanged);
               slot.survivor.injuries.changed.remove(onSurvivorInjuriesChanged);
               _session.removeSurvivor(slot.survivor);
            }
            if(param2 != null)
            {
               param2.loadoutOffence.changed.add(onSurvivorLoadoutChanged);
               param2.injuries.changed.add(onSurvivorInjuriesChanged);
               _session.addSurvivor(param2);
            }
            updateSurvivors();
            param1.close();
         };
         dlg = new SurvivorListDialogue(Language.getInstance().getString("select_survivor_title"),Network.getInstance().playerData.compound.survivors,this._survivorsUsed,Vector.<String>([SurvivorClass.UNASSIGNED]),true);
         dlg.selected.add(function(param1:Survivor):void
         {
            var langId:String = null;
            var dlgAway:MessageBox = null;
            var dlgTask:MessageBox = null;
            var srv:Survivor = param1;
            if(srv != null)
            {
               if(Boolean(srv.state & SurvivorState.ON_MISSION) || Boolean(srv.state & SurvivorState.REASSIGNING) || Boolean(srv.state & SurvivorState.ON_ASSIGNMENT))
               {
                  langId = "srv_mission_cantassign_";
                  if(Boolean(srv.state & SurvivorState.ON_MISSION) || Boolean(srv.state & SurvivorState.ON_ASSIGNMENT))
                  {
                     langId += "away";
                  }
                  else
                  {
                     langId += "reassign";
                  }
                  dlgAway = new MessageBox(Language.getInstance().getString(langId + "_msg",srv.firstName));
                  dlgAway.addTitle(Language.getInstance().getString(langId + "_title",srv.firstName));
                  dlgAway.addImage(srv.portraitURI);
                  dlgAway.addButton(Language.getInstance().getString(langId + "_ok"));
                  if((srv.state & SurvivorState.ON_ASSIGNMENT) == 0)
                  {
                     dlgAway.addButton(Language.getInstance().getString(langId + "_speedup"),true,{"backgroundColor":4226049}).clicked.add(function(param1:MouseEvent):void
                     {
                        var _loc3_:SpeedUpDialogue = null;
                        var _loc2_:* = srv.missionId != null ? Network.getInstance().playerData.missionList.getMissionById(srv.missionId) : srv;
                        if(_loc2_ != null)
                        {
                           _loc3_ = new SpeedUpDialogue(_loc2_);
                           _loc3_.open();
                        }
                     });
                  }
                  dlgAway.closed.addOnce(function(param1:Dialogue):void
                  {
                     dlg.selectItem(-1);
                  });
                  dlgAway.open();
                  return;
               }
               if(Boolean(srv.state & SurvivorState.ON_TASK) && srv.task != null)
               {
                  dlgTask = new MessageBox(Language.getInstance().getString("srv_assigned_task_msg",srv.fullName));
                  dlgTask.addTitle(Language.getInstance().getString("srv_assigned_task_title"));
                  dlgTask.addImage(srv.portraitURI);
                  dlgTask.addButton(Language.getInstance().getString("srv_assigned_task_cancel")).clicked.addOnce(function(param1:MouseEvent):void
                  {
                     dlg.selectItem(-1);
                  });
                  dlgTask.addButton(Language.getInstance().getString("srv_assigned_task_ok")).clicked.addOnce(function(param1:MouseEvent):void
                  {
                     assignSurvivor(dlg,srv);
                  });
                  dlgTask.open();
                  return;
               }
            }
            assignSurvivor(dlg,srv);
         });
         dlg.open();
      }
      
      private function onSurvivorLoadoutChanged() : void
      {
         this.updateSurvivors();
         this.loadoutsChanged.dispatch();
      }
      
      private function onSurvivorInjuriesChanged(param1:Survivor) : void
      {
         this.updateSurvivors();
      }
   }
}

