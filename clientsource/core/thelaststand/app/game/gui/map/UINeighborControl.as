package thelaststand.app.game.gui.map
{
   import flash.display.DisplayObject;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.AntiAliasType;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.data.NavigationLocation;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.display.TitleTextField;
   import thelaststand.app.events.NavigationEvent;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.game.logic.DialogueController;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.RemotePlayerData;
   import thelaststand.common.lang.Language;
   
   public class UINeighborControl extends Sprite
   {
      
      private var _lang:Language;
      
      private var _neighbor:RemotePlayerData;
      
      private var _padding:int = 10;
      
      private var _width:int = 130;
      
      private var _height:int = 168;
      
      private var mc_background:Shape;
      
      private var txt_name:TitleTextField;
      
      private var txt_level:TitleTextField;
      
      private var btn_help:PushButton;
      
      private var btn_attack:PushButton;
      
      private var btn_view:PushButton;
      
      public function UINeighborControl()
      {
         super();
         this._lang = Language.getInstance();
         this.mc_background = new Shape();
         this.mc_background.filters = [BaseDialogue.INNER_SHADOW,BaseDialogue.STROKE,BaseDialogue.DROP_SHADOW];
         addChild(this.mc_background);
         this.txt_name = new TitleTextField({
            "text":" ",
            "color":14408667,
            "size":18
         });
         this.txt_name.maxWidth = this._width;
         this.txt_name.y = this._padding - 6;
         addChild(this.txt_name);
         this.txt_level = new TitleTextField({
            "text":" ",
            "color":11053224,
            "size":14,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         addChild(this.txt_level);
         this.btn_help = new PushButton(this._lang.getString("map_list_btn_help"));
         this.btn_help.clicked.add(this.onClickButton);
         this.btn_help.backgroundColor = 4226049;
         this.btn_help.width = int(this._width - this._padding * 2);
         this.btn_help.x = int((this._width - this.btn_help.width) * 0.5);
         this.btn_attack = new PushButton(this._lang.getString("map_list_btn_attack"));
         this.btn_attack.clicked.add(this.onClickButton);
         this.btn_attack.backgroundColor = 7545099;
         this.btn_attack.width = this.btn_help.width;
         this.btn_attack.x = this.btn_help.x;
         this.btn_view = new PushButton(this._lang.getString("map_list_btn_view"));
         this.btn_view.clicked.add(this.onClickButton);
         this.btn_view.width = this.btn_help.width;
         this.btn_view.x = this.btn_help.x;
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         this.mc_background.filters = [];
         this.txt_name.dispose();
         this.txt_level.dispose();
         this._lang = null;
         this._neighbor = null;
         this.mc_background.filters = [];
         this.txt_level.dispose();
         this.txt_level = null;
         this.txt_name.dispose();
         this.txt_name = null;
         this.btn_attack.dispose();
         this.btn_attack = null;
         this.btn_help.dispose();
         this.btn_help = null;
         this.btn_view.dispose();
         this.btn_view = null;
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
      }
      
      public function hide() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
            Audio.sound.play("sound/interface/int-close.mp3");
         }
      }
      
      private function update() : void
      {
         var _loc1_:int = 0;
         if(this._neighbor == null)
         {
            return;
         }
         this.txt_name.text = this._neighbor.nickname + (this._neighbor.allianceTag ? " [" + this._neighbor.allianceTag + "]" : "");
         this.txt_name.x = int((this._width - this.txt_name.width) * 0.5);
         this.txt_level.text = this._lang.getString("level",this._neighbor.level + 1).toUpperCase();
         this.txt_level.x = int((this._width - this.txt_level.width) * 0.5);
         this.txt_level.y = int(this.txt_name.y + this.txt_name.height - 4);
         var _loc2_:int = int(this.txt_level.y + this.txt_level.height + this._padding);
         if(this._neighbor.isFriend)
         {
            this.btn_help.y = _loc2_;
            addChild(this.btn_help);
            _loc2_ += this.btn_help.height + this._padding;
            if(this.btn_view.parent != null)
            {
               this.btn_view.parent.removeChild(this.btn_view);
            }
         }
         else
         {
            this.btn_view.y = _loc2_;
            addChild(this.btn_view);
            _loc2_ += this.btn_view.height + this._padding;
            if(this.btn_help.parent != null)
            {
               this.btn_help.parent.removeChild(this.btn_help);
            }
         }
         this.btn_attack.y = _loc2_;
         this.btn_attack.enabled = this._neighbor.canAttack();
         addChild(this.btn_attack);
         _loc2_ += this.btn_attack.height + this._padding;
         _loc1_ = _loc2_;
         this.mc_background.graphics.clear();
         this.mc_background.graphics.beginFill(5460561);
         this.mc_background.graphics.drawRect(0,0,this._width,_loc1_);
         this.mc_background.graphics.endFill();
         this.mc_background.graphics.beginBitmapFill(BaseDialogue.BMP_GRIME);
         this.mc_background.graphics.drawRect(0,0,this._width,_loc1_);
         this.mc_background.graphics.endFill();
         this._height = _loc1_;
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         stage.addEventListener(MouseEvent.MOUSE_DOWN,this.onStageMouseDown,false,0,true);
         stage.addEventListener(MouseEvent.MOUSE_WHEEL,this.onStageMouseDown,false,0,true);
         Audio.sound.play("sound/interface/int-open.mp3");
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         stage.removeEventListener(MouseEvent.MOUSE_DOWN,this.onStageMouseDown);
         stage.removeEventListener(MouseEvent.MOUSE_WHEEL,this.onStageMouseDown);
      }
      
      private function onStageMouseDown(param1:MouseEvent) : void
      {
         if(param1.target == this || contains(DisplayObject(param1.target)))
         {
            return;
         }
         this.hide();
      }
      
      private function onClickButton(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         var player:PlayerData = Network.getInstance().playerData;
         var slotProtection:Boolean = player.compound.effects.hasEffectType(EffectType.getTypeValue("DisablePvP"));
         var globalProtection:Boolean = player.compound.globalEffects.hasEffectType(EffectType.getTypeValue("DisablePvP"));
         switch(e.currentTarget)
         {
            case this.btn_attack:
               if(slotProtection)
               {
                  return;
               }
               if(globalProtection)
               {
                  DialogueController.getInstance().openLoseProtectionWarning(function():void
                  {
                     dispatchEvent(new NavigationEvent(NavigationEvent.REQUEST,NavigationLocation.MISSION_PLANNING,neighbor));
                     hide();
                  });
                  return;
               }
               dispatchEvent(new NavigationEvent(NavigationEvent.REQUEST,NavigationLocation.MISSION_PLANNING,this._neighbor));
               break;
            case this.btn_help:
            case this.btn_view:
               dispatchEvent(new NavigationEvent(NavigationEvent.REQUEST,NavigationLocation.NEIGHBOR_COMPOUND,this._neighbor));
         }
         this.hide();
      }
      
      public function get neighbor() : RemotePlayerData
      {
         return this._neighbor;
      }
      
      public function set neighbor(param1:RemotePlayerData) : void
      {
         this._neighbor = param1;
         this.update();
      }
   }
}

