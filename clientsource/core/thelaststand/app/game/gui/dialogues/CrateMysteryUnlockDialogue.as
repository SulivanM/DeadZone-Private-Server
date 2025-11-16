package thelaststand.app.game.gui.dialogues
{
   import com.deadreckoned.threshold.display.Color;
   import com.greensock.TweenMax;
   import com.greensock.easing.Quad;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.CrateMysteryItem;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.effects.Effect;
   import thelaststand.app.game.gui.UIItemInfo;
   import thelaststand.app.game.gui.UIMysteryItem;
   import thelaststand.app.gui.UIBusySpinner;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.Resource;
   import thelaststand.common.resources.ResourceManager;
   
   public class CrateMysteryUnlockDialogue extends BaseDialogue
   {
      
      private var _uiItemList:Vector.<UIMysteryItem>;
      
      private var _rewardItems:Vector.<Item>;
      
      private var _rewardEffect:Effect;
      
      private var _crateItem:CrateMysteryItem;
      
      private var _animURI:String;
      
      private var _containerRect:Rectangle;
      
      private var _error:Boolean = false;
      
      private var _openTimeout:uint;
      
      private var mc_container:Sprite;
      
      private var mc_openAnim:MovieClip;
      
      private var ui_spinner:UIBusySpinner;
      
      private var btn_ok:PushButton;
      
      private var txt_error:BodyTextField;
      
      private var txt_effect:BodyTextField;
      
      private var ui_itemInfo:UIItemInfo;
      
      public function CrateMysteryUnlockDialogue(param1:CrateMysteryItem)
      {
         var _loc2_:int = 0;
         this._uiItemList = new Vector.<UIMysteryItem>();
         this.mc_container = new Sprite();
         super("myster-crate-unlock",this.mc_container,false,true);
         _loc2_ = 318;
         _autoSize = false;
         _width = 334;
         _height = _loc2_ + 82;
         _buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         this._crateItem = param1;
         this._animURI = this._crateItem.xml.anim.@uri.toString();
         var _loc3_:uint = new Color(this._crateItem.xml.dlg.title_bg_color[0].toString()).RGB;
         var _loc4_:uint = new Color(this._crateItem.xml.dlg.title_color[0].toString()).RGB;
         var _loc5_:String = Language.getInstance().getString(this._crateItem.xml.dlg.title[0].toString());
         var _loc6_:String = Language.getInstance().getString(this._crateItem.xml.dlg.ok[0].toString());
         addTitle(_loc5_.toUpperCase(),_loc3_);
         txt_title.textColor = _loc4_;
         this.btn_ok = PushButton(addButton(_loc6_,true,{"width":200}));
         this.btn_ok.enabled = false;
         this._containerRect = new Rectangle(0,_padding * 0.5,_width - _padding * 2,_loc2_);
         GraphicUtils.drawUIBlock(this.mc_container.graphics,this._containerRect.width,this._containerRect.height,this._containerRect.x,this._containerRect.y);
         this.ui_spinner = new UIBusySpinner();
         this.ui_spinner.x = int(this._containerRect.x + this._containerRect.width * 0.5);
         this.ui_spinner.y = int(this._containerRect.y + this._containerRect.height * 0.5);
         this.mc_container.addChild(this.ui_spinner);
         this.txt_error = new BodyTextField({
            "color":Effects.COLOR_WARNING,
            "size":16,
            "bold":true,
            "align":"center",
            "multiline":true
         });
         this.txt_error.visible = false;
         this.txt_error.width = this._containerRect.width;
         this.txt_error.x = this._containerRect.x;
         this.txt_error.y = this._containerRect.y + 16;
         this.mc_container.addChild(this.txt_error);
         this.txt_effect = new BodyTextField({
            "color":16777215,
            "size":16,
            "bold":true,
            "align":"center",
            "multiline":true
         });
         this.txt_effect.width = this._containerRect.width;
         this.txt_effect.x = this._containerRect.x;
         this.txt_effect.y = this._containerRect.y + this._containerRect.height - 24;
         this.ui_itemInfo = new UIItemInfo();
         sprite.addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         sprite.addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         sprite.removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         sprite.removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
         ResourceManager.getInstance().resourceLoadFailed.remove(this.onResourceLoadFailed);
         ResourceManager.getInstance().resourceLoadCompleted.remove(this.onResourceLoaded);
         ResourceManager.getInstance().purge(this._animURI);
         this.ui_spinner.dispose();
         this.ui_itemInfo.dispose();
      }
      
      private function loadAnimation() : void
      {
         var _loc1_:ResourceManager = ResourceManager.getInstance();
         var _loc2_:Resource = _loc1_.getResource(this._animURI);
         if(_loc2_ != null)
         {
            if(_loc1_.isInQueue(this._animURI))
            {
               _loc1_.resourceLoadCompleted.add(this.onResourceLoaded);
               _loc1_.resourceLoadFailed.add(this.onResourceLoadFailed);
            }
            else
            {
               this.mc_openAnim = MovieClip(_loc2_.content);
               this.playAnimation();
            }
         }
         else
         {
            _loc1_.resourceLoadFailed.add(this.onResourceLoadFailed);
            _loc1_.resourceLoadCompleted.add(this.onResourceLoaded);
            _loc1_.load(this._animURI);
         }
      }
      
      private function playAnimation() : void
      {
         if(this.mc_openAnim == null)
         {
            return;
         }
         if(this.ui_spinner.parent != null)
         {
            this.ui_spinner.parent.removeChild(this.ui_spinner);
         }
         this.mc_openAnim.x = int(this._containerRect.x + 3);
         this.mc_openAnim.y = int(this._containerRect.y + 3);
         this.mc_container.addChild(this.mc_openAnim);
         this.mc_openAnim.gotoAndStop("waiting");
         this._crateItem.open(this.onCrateOpenComplete);
         this._openTimeout = setTimeout(this.tryPlayOpen,3000);
      }
      
      private function tryPlayOpen() : void
      {
         if(this._error)
         {
            this.gotoError();
            return;
         }
         if(this._rewardItems != null)
         {
            this.playOpenAnimation();
         }
         else
         {
            this._openTimeout = setTimeout(this.tryPlayOpen,500);
         }
      }
      
      private function playOpenAnimation() : void
      {
         if(this.mc_openAnim == null)
         {
            return;
         }
         this.mc_openAnim.addEventListener(Event.ENTER_FRAME,this.onAnimEnterFrame,false,0,true);
         this.mc_openAnim.gotoAndPlay("unlocked");
      }
      
      private function playItemReveal() : void
      {
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc18_:String = null;
         var _loc19_:Item = null;
         var _loc20_:UIMysteryItem = null;
         this.mc_container.mouseChildren = false;
         if(this._rewardEffect != null)
         {
            _loc18_ = Language.getInstance().getString("effect_names." + this._rewardEffect.type);
            this.txt_effect.htmlText = "<font color=\'" + Color.colorToHex(Effects["COLOR_EFFECT_" + this._rewardEffect.group.toUpperCase()]) + "\'>+ " + _loc18_ + "</font>";
            this.txt_effect.y = int(this._containerRect.y + this._containerRect.height - this.txt_effect.height - 4);
            this.mc_container.addChild(this.txt_effect);
            TweenMax.from(this.txt_effect,3,{
               "colorTransform":{"exposure":2},
               "glowFilter":{
                  "color":16777215,
                  "alpha":1,
                  "blurX":20,
                  "blurY":20,
                  "strength":2,
                  "quality":2
               },
               "transformAroundCenter":{
                  "scaleX":0.75,
                  "scaleY":0.75
               }
            });
         }
         var _loc1_:int = 5;
         var _loc2_:int = Math.min(_loc1_,this._rewardItems.length);
         var _loc3_:int = Math.ceil(this._rewardItems.length / _loc2_);
         var _loc4_:int = int(this._rewardItems.length);
         while(_loc4_ > _loc2_)
         {
            _loc4_ -= _loc2_;
         }
         var _loc5_:int = int(Math.min(4 / _loc2_ * 58,58));
         var _loc6_:int = int((this._containerRect.width - _loc5_ * _loc2_) / (_loc2_ + 1));
         var _loc7_:int = this._containerRect.x + this._containerRect.width / 2;
         var _loc8_:int = this._containerRect.y + this._containerRect.height / 2;
         var _loc9_:int = this._containerRect.x + int((this._containerRect.width - _loc5_) / 2 - _loc2_ * (_loc5_ + _loc6_) / 2) + (_loc5_ + _loc6_) / 2;
         var _loc10_:int = int(this._containerRect.y + this._containerRect.height - _loc5_ - 10) - (this._rewardEffect != null ? int(this.txt_effect.height + 8) : 0);
         var _loc11_:Number = 0.5;
         var _loc12_:Number = _loc11_ * 0.2;
         var _loc13_:Number = _loc11_ - _loc12_;
         var _loc14_:Number = 0;
         var _loc17_:int = 0;
         while(_loc17_ < this._rewardItems.length)
         {
            _loc19_ = this._rewardItems[_loc17_];
            _loc20_ = new UIMysteryItem(_loc5_,_loc19_);
            _loc20_.x = _loc7_;
            _loc20_.y = _loc8_;
            _loc20_.revealed.addOnce(this.onItemRevealed);
            this.mc_container.addChildAt(_loc20_,this.mc_container.numChildren - _loc17_);
            this._uiItemList.push(_loc20_);
            TweenMax.to(_loc20_,_loc11_,{
               "delay":_loc14_,
               "x":_loc9_,
               "ease":Quad.easeInOut,
               "overwrite":false
            });
            TweenMax.to(_loc20_,_loc12_,{
               "delay":_loc14_,
               "y":_loc8_ - 40,
               "ease":Quad.easeOut,
               "overwrite":false
            });
            TweenMax.to(_loc20_,_loc13_,{
               "delay":_loc14_ + _loc12_,
               "y":_loc10_,
               "ease":Quad.easeInOut,
               "overwrite":false
            });
            TweenMax.from(_loc20_,_loc11_,{
               "delay":_loc14_,
               "scaleX":0,
               "scaleY":0,
               "colorTransform":{"exposure":2},
               "ease":Quad.easeOut,
               "overwrite":false,
               "onComplete":(_loc17_ == this._rewardItems.length - 1 ? this.onRevealComplete : null)
            });
            _loc14_ += 0.15;
            if(++_loc15_ >= _loc2_)
            {
               _loc15_ = 0;
               if(++_loc16_ >= _loc3_ - 1)
               {
                  _loc2_ = _loc4_;
               }
               _loc9_ = this._containerRect.x + int((this._containerRect.width - _loc5_) / 2 - _loc2_ * (_loc5_ + _loc6_) / 2) + (_loc5_ + _loc6_) / 2;
               _loc10_ -= int(_loc5_ + _loc6_);
            }
            else
            {
               _loc9_ += int(_loc5_ + _loc6_);
            }
            _loc17_++;
         }
      }
      
      private function onRevealComplete() : void
      {
         this.mc_container.mouseChildren = true;
      }
      
      private function gotoError() : void
      {
         this._error = true;
         ResourceManager.getInstance().resourceLoadCompleted.remove(this.onResourceLoaded);
         ResourceManager.getInstance().resourceLoadFailed.remove(this.onResourceLoadFailed);
         if(this.mc_openAnim != null)
         {
            this.mc_openAnim.removeEventListener(Event.ENTER_FRAME,this.onAnimEnterFrame);
            this.mc_openAnim.stop();
         }
         this.txt_error.htmlText = Language.getInstance().getString("crate_unlock_error");
         this.txt_error.visible = true;
         this.mc_container.addChild(this.txt_error);
         this.btn_ok.label = Language.getInstance().getString("crate_unlock_ok");
         this.btn_ok.enabled = true;
         Audio.sound.play("sound/interface/int-error.mp3");
      }
      
      private function onCrateOpenComplete(param1:Boolean, param2:Vector.<Item> = null, param3:Effect = null) : void
      {
         if(!param1 || param2.length == 0)
         {
            this.gotoError();
         }
         else
         {
            this._rewardItems = param2;
            this._rewardEffect = param3;
         }
      }
      
      private function onAnimEnterFrame(param1:Event) : void
      {
         if(this.mc_openAnim.currentFrameLabel == "showItem")
         {
            this.mc_openAnim.removeEventListener(Event.ENTER_FRAME,this.onAnimEnterFrame);
            this.playItemReveal();
         }
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.loadAnimation();
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         if(this.mc_openAnim != null)
         {
            this.mc_openAnim.removeEventListener(Event.ENTER_FRAME,this.onAnimEnterFrame);
            this.mc_openAnim.stop();
         }
         clearTimeout(this._openTimeout);
      }
      
      private function onResourceLoaded(param1:Resource) : void
      {
         if(param1.uri == this._animURI)
         {
            this.mc_openAnim = MovieClip(param1.content);
            ResourceManager.getInstance().resourceLoadCompleted.remove(this.onResourceLoaded);
            ResourceManager.getInstance().resourceLoadFailed.remove(this.onResourceLoadFailed);
            this.playAnimation();
         }
      }
      
      private function onResourceLoadFailed(param1:Resource, param2:Object = null) : void
      {
         if(param1.uri == this._animURI)
         {
            this.gotoError();
         }
      }
      
      private function onItemRevealed(param1:UIMysteryItem) : void
      {
         param1.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOverItem,false,0,true);
         this.ui_itemInfo.addRolloverTarget(param1);
         var _loc2_:Boolean = true;
         var _loc3_:int = 0;
         while(_loc3_ < this._uiItemList.length)
         {
            if(!this._uiItemList[_loc3_].isRevealed)
            {
               _loc2_ = false;
               break;
            }
            _loc3_++;
         }
         this.btn_ok.enabled = _loc2_;
      }
      
      private function onMouseOverItem(param1:MouseEvent) : void
      {
         var _loc2_:UIMysteryItem = UIMysteryItem(param1.currentTarget);
         this.ui_itemInfo.setItem(_loc2_.item);
      }
   }
}

