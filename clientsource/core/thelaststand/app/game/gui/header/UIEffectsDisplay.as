package thelaststand.app.game.gui.header
{
   import com.dynamicflash.util.Base64;
   import com.greensock.TweenMax;
   import com.greensock.easing.Back;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.data.NavigationLocation;
   import thelaststand.app.game.Game;
   import thelaststand.app.game.Tutorial;
   import thelaststand.app.game.data.EffectCollection;
   import thelaststand.app.game.data.EffectItem;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemFactory;
   import thelaststand.app.game.data.MiscEffectItem;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.data.effects.Effect;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.game.gui.UIItemInfo;
   import thelaststand.app.game.gui.chat.events.ChatLinkEvent;
   import thelaststand.app.game.gui.dialogues.EffectItemListDialogue;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.BusyDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class UIEffectsDisplay extends Sprite
   {
      
      private var _spacing:int = 5;
      
      private var _slots:Vector.<UIEffectSlot>;
      
      private var _tacticsSlot:UIEffectSlot;
      
      private var _globalSlots:Vector.<UIEffectSlot>;
      
      private var _tooltip:TooltipManager;
      
      private var _game:Game;
      
      private var _effectList:EffectCollection;
      
      private var _globalEffectList:EffectCollection;
      
      private var _globalTooltip:GlobalEffectTooltip;
      
      private var _effectItemListDialog:EffectItemListDialogue;
      
      private var ui_itemInfo:UIItemInfo;
      
      public function UIEffectsDisplay(param1:Game)
      {
         super();
         this._game = param1;
         this._tooltip = TooltipManager.getInstance();
         this._slots = new Vector.<UIEffectSlot>(5,true);
         this._globalSlots = new Vector.<UIEffectSlot>();
         this._effectList = Network.getInstance().playerData.compound.effects;
         this._effectList.effectChanged.add(this.onEffectChanged);
         this._globalEffectList = Network.getInstance().playerData.compound.globalEffects;
         this._globalEffectList.effectChanged.add(this.onEffectChanged);
         this._globalTooltip = new GlobalEffectTooltip();
         this.ui_itemInfo = new UIItemInfo();
         Tutorial.getInstance().completed.addOnce(this.onTutorialCompleted);
         this.createSlots();
         this.updateSlots();
      }
      
      public function dispose() : void
      {
         var _loc1_:UIEffectSlot = null;
         if(parent != null)
         {
            parent.removeChild(this);
         }
         Tutorial.getInstance().completed.remove(this.onTutorialCompleted);
         this._game = null;
         this._effectList = null;
         this._tooltip.removeAllFromParent(this);
         this._tooltip = null;
         this._globalTooltip.dispose();
         for each(_loc1_ in this._slots)
         {
            if(_loc1_ != null)
            {
               _loc1_.dispose();
            }
         }
         this._slots = null;
         for each(_loc1_ in this._globalSlots)
         {
            _loc1_.dispose();
         }
         this._globalSlots = null;
         this.ui_itemInfo.dispose();
         if(this._effectItemListDialog)
         {
            this._effectItemListDialog.close();
         }
         this._effectItemListDialog = null;
      }
      
      public function transitionIn(param1:Number = 0) : void
      {
         var _loc2_:int = 0;
         var _loc3_:UIEffectSlot = null;
         visible = true;
         _loc2_ = 0;
         while(_loc2_ < this._slots.length)
         {
            _loc3_ = this._slots[_loc2_];
            if(_loc3_ != null)
            {
               param1 += _loc2_ / 60;
               TweenMax.to(_loc3_,0.25,{
                  "delay":param1,
                  "overwrite":true,
                  "y":0,
                  "ease":Back.easeOut,
                  "easeParams":[0.9]
               });
            }
            _loc2_++;
         }
         _loc2_ = 0;
         while(_loc2_ < this._globalSlots.length)
         {
            _loc3_ = this._globalSlots[_loc2_];
            param1 += _loc2_ / 60;
            TweenMax.to(_loc3_,0.25,{
               "delay":param1,
               "overwrite":true,
               "y":0,
               "ease":Back.easeOut,
               "easeParams":[0.9]
            });
            _loc2_++;
         }
      }
      
      public function transitionOut(param1:Number = 0) : void
      {
         var i:int = 0;
         var slot:UIEffectSlot = null;
         var delay:Number = param1;
         var onComplete:Function = function():void
         {
            this.visible = false;
         };
         i = 0;
         while(i < this._globalSlots.length)
         {
            slot = this._globalSlots[i];
            delay += (this._slots.length - i) / 60;
            TweenMax.to(slot,0.25,{
               "delay":delay,
               "overwrite":true,
               "y":-(slot.height * 3),
               "ease":Back.easeIn,
               "easeParams":[0.9]
            });
            i++;
         }
         i = 0;
         while(i < this._slots.length)
         {
            slot = this._slots[i];
            if(slot != null)
            {
               delay += (this._slots.length - i) / 60;
               TweenMax.to(slot,0.25,{
                  "delay":delay,
                  "overwrite":true,
                  "y":-(slot.height * 3),
                  "ease":Back.easeIn,
                  "easeParams":[0.9],
                  "onComplete":(i == this._slots.length - 1 ? onComplete : null)
               });
            }
            i++;
         }
      }
      
      private function createSlots() : void
      {
         var _loc1_:UIEffectSlot = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         for each(_loc1_ in this._slots)
         {
            if(_loc1_ != null)
            {
               this.ui_itemInfo.removeRolloverTarget(_loc1_);
               _loc1_.dispose();
            }
         }
         _loc2_ = 0;
         _loc3_ = 0;
         _loc4_ = int(this._slots.length);
         while(_loc3_ < _loc4_)
         {
            _loc5_ = null;
            if(_loc3_ == _loc4_ - 1)
            {
               _loc5_ = "tactics";
            }
            _loc1_ = new UIEffectSlot(_loc5_);
            _loc1_.clicked.add(this.onSlotClicked);
            _loc1_.mouseOver.add(this.onSlotMouseOver);
            _loc1_.x = _loc2_;
            _loc2_ += int(_loc1_.width + this._spacing);
            addChild(_loc1_);
            this.ui_itemInfo.addRolloverTarget(_loc1_);
            this._slots[_loc3_] = _loc1_;
            _loc3_++;
         }
      }
      
      private function updateSlots() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:UIEffectSlot = null;
         _loc1_ = 0;
         _loc2_ = int(this._slots.length);
         while(_loc1_ < _loc2_)
         {
            _loc3_ = this._slots[_loc1_];
            _loc3_.effect = this._effectList.getEffect(_loc1_);
            _loc3_.alpha = Tutorial.getInstance().active ? 0.5 : 1;
            _loc1_++;
         }
         var _loc4_:int = _loc3_.x + _loc3_.width + this._spacing * 3;
         var _loc5_:int = this._globalEffectList.length;
         _loc1_ = 0;
         _loc2_ = Math.max(this._globalSlots.length,_loc5_);
         while(_loc1_ < _loc2_)
         {
            if(_loc1_ >= _loc5_)
            {
               _loc3_ = this._globalSlots[_loc1_];
               _loc3_.dispose();
               this._tooltip.remove(_loc3_);
            }
            else
            {
               if(_loc1_ < this._globalSlots.length)
               {
                  _loc3_ = this._globalSlots[_loc1_];
               }
               else
               {
                  _loc3_ = new UIEffectSlot();
                  _loc3_.mouseOver.add(this.onSlotMouseOver);
                  addChild(_loc3_);
                  this._globalSlots[_loc1_] = _loc3_;
               }
               _loc3_.effect = this._globalEffectList.getEffect(_loc1_);
               _loc3_.x = _loc4_;
               _loc4_ += int(_loc3_.width + this._spacing);
               if(_loc3_.effect != null)
               {
                  if(_loc3_.effect.group == "global")
                  {
                     this.ui_itemInfo.removeRolloverTarget(_loc3_);
                  }
                  else
                  {
                     this.ui_itemInfo.addRolloverTarget(_loc3_);
                  }
               }
            }
            _loc1_++;
         }
         this._globalSlots.length = _loc5_;
      }
      
      private function isSlotLocked(param1:UIEffectSlot) : Boolean
      {
         var _loc2_:Effect = param1.effect;
         if(_loc2_ == null)
         {
            return false;
         }
         if(Tutorial.getInstance().active)
         {
            return true;
         }
         if(_loc2_.lockoutTimer != null)
         {
            return _loc2_.lockoutTimer.hasStarted();
         }
         var _loc3_:int = this._effectList.getNumEffectsOfGroup(_loc2_.group) - 1;
         var _loc4_:int = this._effectList.getMaxEffectsOfGroup(_loc2_.group) - _loc2_.getValue(EffectType.getTypeValue("EffectGroupLimit"));
         if(_loc3_ > _loc4_)
         {
            return true;
         }
         return false;
      }
      
      private function openEffectSelect(param1:UIEffectSlot) : void
      {
         var slot:UIEffectSlot = param1;
         var itemList:Vector.<Item> = Network.getInstance().playerData.inventory.getItemsOfCategory("effect").filter(function(param1:Item, param2:int, param3:Vector.<Item>):Boolean
         {
            var _loc4_:* = EffectItem(param1);
            if(slot.group == null)
            {
               if(_loc4_.effect.group == "tactics")
               {
                  return false;
               }
            }
            else if(_loc4_.effect.group != slot.group)
            {
               return false;
            }
            return true;
         });
         this._effectItemListDialog = new EffectItemListDialogue(slot,this._effectList,itemList,this._game.location);
         this._effectItemListDialog.selected.add(function(param1:Item):void
         {
            var confirmNext:Function;
            var index:int = 0;
            var effectItem:EffectItem = null;
            var confirmDialogues:Vector.<Dialogue> = null;
            var confirmIndex:int = 0;
            var dlgRemove:MessageBox = null;
            var allianceSystem:AllianceSystem = null;
            var dlgConfirm:MessageBox = null;
            var item:Item = param1;
            index = int(_slots.indexOf(slot));
            var existing:Effect = _effectList.getEffect(index);
            effectItem = item as EffectItem;
            if(effectItem != null)
            {
               if(effectItem.effect == slot.effect || index == -1)
               {
                  _effectItemListDialog.close();
                  _effectItemListDialog = null;
                  return;
               }
            }
            if(item == null && existing == null)
            {
               _effectItemListDialog.close();
               _effectItemListDialog = null;
               return;
            }
            confirmDialogues = new Vector.<Dialogue>();
            confirmIndex = 0;
            confirmNext = function(param1:Boolean):void
            {
               var _loc2_:int = 0;
               if(!param1)
               {
                  _loc2_ = confirmIndex;
                  while(_loc2_ < confirmDialogues.length)
                  {
                     confirmDialogues[_loc2_].dispose();
                     _loc2_++;
                  }
                  return;
               }
               if(confirmIndex < confirmDialogues.length)
               {
                  confirmDialogues[confirmIndex++].open();
               }
               else
               {
                  ApplyEffectToSlot(effectItem,index);
               }
            };
            if(existing != null && existing.timer != null && !existing.timer.hasEnded())
            {
               dlgRemove = new MessageBox(Language.getInstance().getString("removeEffectConfirm_msg"),"confirm-remove-effect",true);
               dlgRemove.addTitle(Language.getInstance().getString("removeEffectConfirm_title"),BaseDialogue.TITLE_COLOR_RUST);
               dlgRemove.addButton(Language.getInstance().getString("removeEffectConfirm_ok"),true,{"width":100}).clicked.addOnce(function(param1:MouseEvent):void
               {
                  confirmNext(true);
               });
               dlgRemove.addButton(Language.getInstance().getString("removeEffectConfirm_cancel"),true,{"width":100}).clicked.addOnce(function(param1:MouseEvent):void
               {
                  confirmNext(false);
               });
               confirmDialogues.push(dlgRemove);
            }
            if(effectItem != null && effectItem.effect.hasEffectType(EffectType.getTypeValue("DisablePvP")))
            {
               allianceSystem = AllianceSystem.getInstance();
               if(allianceSystem.inAlliance && allianceSystem.isRoundActive && allianceSystem.canContributeToRound)
               {
                  dlgConfirm = new MessageBox(Language.getInstance().getString("alliance.whiteflagConfirm_msg"),"dlgConfirm",true);
                  dlgConfirm.addTitle(Language.getInstance().getString("alliance.whiteflagConfirm_title"));
                  dlgConfirm.addButton(Language.getInstance().getString("alliance.whiteflagConfirm_yes"),true,{"width":100}).clicked.addOnce(function(param1:MouseEvent = null):void
                  {
                     confirmNext(true);
                  });
                  dlgConfirm.addButton(Language.getInstance().getString("alliance.whiteflagConfirm_no"),true,{"width":100}).clicked.addOnce(function(param1:MouseEvent):void
                  {
                     confirmNext(false);
                  });
                  confirmDialogues.push(dlgConfirm);
               }
            }
            confirmNext(true);
         });
         this._effectItemListDialog.open();
      }
      
      private function ApplyEffectToSlot(param1:EffectItem, param2:int) : void
      {
         var id:String;
         var busy:BusyDialogue = null;
         var effectItem:EffectItem = param1;
         var index:int = param2;
         busy = new BusyDialogue(Language.getInstance().getString("equip_book"));
         busy.open();
         id = effectItem != null ? effectItem.id : null;
         Network.getInstance().save({
            "id":id,
            "slot":index
         },SaveDataMethod.EFFECT_SET,function(param1:Object):void
         {
            busy.close();
            _effectItemListDialog.close();
            _effectItemListDialog = null;
            if(param1 == null || param1.success === false)
            {
               return;
            }
            if(effectItem != null)
            {
               effectItem.effect.readObject(Base64.decodeToByteArray(param1.effect));
               _effectList.setEffect(effectItem.effect,int(param1.slot));
            }
            else
            {
               _effectList.setEffect(null,int(param1.slot));
            }
            if(param1.cooldown != null)
            {
               _effectList.compound.player.cooldowns.parse(Base64.decodeToByteArray(param1.cooldown));
            }
            if(effectItem != null && effectItem.effect.hasEffectType(EffectType.getTypeValue("DisablePvP")) && AllianceSystem.getInstance().isConnected)
            {
               AllianceSystem.getInstance().sendRPC("clearRndPts",{"reason":"whiteflag"});
            }
         });
      }
      
      private function onSlotMouseOver(param1:MouseEvent) : void
      {
         var _loc2_:UIEffectSlot = null;
         var _loc3_:EffectItem = null;
         var _loc4_:String = null;
         _loc2_ = UIEffectSlot(param1.currentTarget);
         this._tooltip.remove(_loc2_);
         if(_loc2_.effect != null)
         {
            if(_loc2_.effect.group == "global")
            {
               this._globalTooltip.effect = _loc2_.effect;
               this._tooltip.add(_loc2_,this._globalTooltip,new Point(NaN,_loc2_.height),TooltipDirection.DIRECTION_UP,0);
               this._tooltip.show(_loc2_);
            }
            else
            {
               _loc3_ = _loc2_.effect.item;
               if(_loc3_ != null)
               {
                  this.ui_itemInfo.setItem(_loc3_);
               }
               else if(_loc2_.effect.group == "alliance" || _loc2_.effect.group == "misc" || _loc2_.effect.group == "war")
               {
                  _loc3_ = new MiscEffectItem();
                  _loc3_.effect = _loc2_.effect;
                  this.ui_itemInfo.setItem(_loc3_);
                  _loc3_.dispose();
               }
               else
               {
                  _loc3_ = ItemFactory.createItemFromTypeId("effect-book") as EffectItem;
                  _loc3_.effect = _loc2_.effect;
                  this.ui_itemInfo.setItem(_loc3_);
                  _loc3_.dispose();
               }
            }
         }
         else
         {
            this.ui_itemInfo.setItem(null);
            if(!Tutorial.getInstance().active)
            {
               switch(this._game.location)
               {
                  case NavigationLocation.PLAYER_COMPOUND:
                  case NavigationLocation.WORLD_MAP:
                  case NavigationLocation.MISSION_PLANNING:
                     _loc4_ = _loc2_.group != null ? Language.getInstance().getString("tooltip.equip_effect_" + _loc2_.group) : Language.getInstance().getString("tooltip.equip_effect");
                     this._tooltip.add(_loc2_,_loc4_,new Point(NaN,_loc2_.height),TooltipDirection.DIRECTION_UP,0);
                     this._tooltip.show(_loc2_);
               }
            }
         }
      }
      
      private function onSlotClicked(param1:MouseEvent) : void
      {
         var _loc3_:String = null;
         var _loc4_:EffectItem = null;
         var _loc5_:String = null;
         var _loc2_:UIEffectSlot = UIEffectSlot(param1.currentTarget);
         if(this.ui_itemInfo.parent != null)
         {
            this.ui_itemInfo.parent.removeChild(this.ui_itemInfo);
         }
         if(Tutorial.getInstance().active)
         {
            return;
         }
         if(param1.shiftKey && _loc2_.effect != null)
         {
            _loc4_ = _loc2_.effect.item;
            if(_loc2_.effect.item == null)
            {
               _loc4_ = ItemFactory.createItemFromTypeId("effect-book") as EffectItem;
               _loc4_.effect = _loc2_.effect;
               _loc3_ = JSON.stringify(_loc4_.toChatObject());
               _loc4_.dispose();
            }
            else
            {
               _loc3_ = JSON.stringify(_loc2_.effect.item.toChatObject());
            }
            dispatchEvent(new ChatLinkEvent(ChatLinkEvent.ADD_TO_CHAT,ChatLinkEvent.LT_ITEM,_loc3_));
            return;
         }
         switch(this._game.location)
         {
            case NavigationLocation.WORLD_MAP:
            case NavigationLocation.PLAYER_COMPOUND:
            case NavigationLocation.MISSION_PLANNING:
               if(this.isSlotLocked(_loc2_))
               {
                  _loc5_ = Language.getInstance().getString("tooltip.equip_effect_lock");
                  this._tooltip.add(_loc2_,_loc5_,new Point(NaN,_loc2_.height),TooltipDirection.DIRECTION_UP,0);
                  this._tooltip.show(_loc2_);
                  Audio.sound.play("sound/interface/int-error.mp3");
                  break;
               }
               this.openEffectSelect(_loc2_);
               break;
            default:
               Audio.sound.play("sound/interface/int-error.mp3");
         }
      }
      
      private function onEffectChanged(param1:Effect, param2:int) : void
      {
         if(param1 != null)
         {
            if(param1.item != null && this.ui_itemInfo.item == param1.item)
            {
               this.ui_itemInfo.hide();
            }
         }
         this.updateSlots();
      }
      
      private function onTutorialCompleted() : void
      {
         this.updateSlots();
      }
   }
}

import flash.display.Sprite;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.text.AntiAliasType;
import flash.utils.Timer;
import thelaststand.app.display.BodyTextField;
import thelaststand.app.display.Effects;
import thelaststand.app.game.data.effects.Effect;
import thelaststand.app.utils.DateTimeUtils;
import thelaststand.common.lang.Language;

class GlobalEffectTooltip extends Sprite
{
   
   private var _effect:Effect;
   
   private var _timer:Timer;
   
   private var txt_name:BodyTextField;
   
   private var txt_time:BodyTextField;
   
   private var txt_desc:BodyTextField;
   
   public function GlobalEffectTooltip()
   {
      super();
      this._timer = new Timer(500);
      this._timer.addEventListener(TimerEvent.TIMER,this.updateTime,false,0,true);
      var _loc1_:int = 260;
      this.txt_name = new BodyTextField({
         "text":" ",
         "color":16777215,
         "size":13,
         "multiline":true,
         "width":_loc1_,
         "antiAliasType":AntiAliasType.ADVANCED,
         "bold":true
      });
      this.txt_time = new BodyTextField({
         "text":" ",
         "color":16777215,
         "size":13,
         "antiAliasType":AntiAliasType.ADVANCED,
         "bold":true
      });
      this.txt_desc = new BodyTextField({
         "text":" ",
         "color":16777215,
         "size":13,
         "leading":1,
         "multiline":true,
         "width":_loc1_,
         "antiAliasType":AntiAliasType.ADVANCED
      });
      addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
      addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
   }
   
   public function get effect() : Effect
   {
      return this._effect;
   }
   
   public function set effect(param1:Effect) : void
   {
      this._effect = param1;
      this.update();
   }
   
   public function dispose() : void
   {
      if(parent != null)
      {
         parent.removeChild(this);
      }
      this._timer.stop();
      this._effect = null;
      this.txt_name.dispose();
      this.txt_time.dispose();
      this.txt_desc.dispose();
   }
   
   private function update() : void
   {
      var _loc2_:int = 0;
      if(this._effect == null)
      {
         return;
      }
      var _loc1_:Language = Language.getInstance();
      this.txt_name.htmlText = _loc1_.getString("effect_names." + this._effect.type);
      this.txt_name.y = _loc2_;
      _loc2_ = int(this.txt_name.y + this.txt_name.height);
      addChild(this.txt_name);
      if(this._effect.timer != null && Boolean(this._effect.timer.hasStarted()))
      {
         this.updateTime();
         this.txt_time.y = _loc2_;
         _loc2_ = int(this.txt_time.y + this.txt_time.height);
         addChild(this.txt_time);
      }
      else if(this.txt_time.parent != null)
      {
         this.txt_time.parent.removeChild(this.txt_time);
      }
      this.txt_desc.htmlText = _loc1_.getString("effect_desc." + this._effect.type);
      this.txt_desc.y = _loc2_ + 10;
      addChild(this.txt_desc);
   }
   
   private function updateTime(param1:TimerEvent = null) : void
   {
      var _loc2_:int = int(this._effect.timer.getSecondsRemaining());
      var _loc3_:String = DateTimeUtils.secondsToString(_loc2_,true,true);
      this.txt_time.htmlText = Language.getInstance().getString("effect_desc.time_active",_loc3_);
      this.txt_time.textColor = _loc2_ <= this._effect.timer.length * 0.1 ? Effects.COLOR_WARNING : Effects.COLOR_GOOD;
   }
   
   private function onAddedToStage(param1:Event) : void
   {
      this._timer.reset();
      this._timer.start();
   }
   
   private function onRemovedFromStage(param1:Event) : void
   {
      this._timer.stop();
   }
}
