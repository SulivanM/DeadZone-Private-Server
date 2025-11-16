package thelaststand.app.game.gui.dialogues
{
   import com.deadreckoned.threshold.display.Color;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.CrateItem;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemQualityType;
   import thelaststand.app.game.data.effects.Effect;
   import thelaststand.app.game.gui.UIItemImage;
   import thelaststand.app.gui.UIBusySpinner;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.BusyDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.app.utils.ImageWriter;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.Resource;
   import thelaststand.common.resources.ResourceManager;
   
   public class CrateUnlockDialogue extends BaseDialogue
   {
      
      private var _animURI:String;
      
      private var _crate:CrateItem;
      
      private var _item:Item;
      
      private var _anim:MovieClip;
      
      private var _resources:ResourceManager;
      
      private var ui_itemImage:UIItemImage;
      
      private var mc_container:Sprite = new Sprite();
      
      private var mc_anim:Sprite;
      
      private var mc_spinner:UIBusySpinner;
      
      private var btn_share:PushButton;
      
      private var btn_ok:PushButton;
      
      private var txt_item:BodyTextField;
      
      public function CrateUnlockDialogue(param1:CrateItem)
      {
         super("crate-unlock-dialogue",this.mc_container,false);
         this._crate = param1;
         _autoSize = false;
         _width = 278;
         _height = 300;
         _buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         this._animURI = this._crate.xml.anim.@uri.toString();
         this._resources = ResourceManager.getInstance();
         addTitle(Language.getInstance().getString("crate_unlock_title"),BaseDialogue.TITLE_COLOR_GREY);
         this.btn_ok = addButton(Language.getInstance().getString("crate_unlock_ok"),true,{"width":116}) as PushButton;
         this.btn_ok.enabled = false;
         this.mc_anim = new Sprite();
         this.mc_anim.y = int(_padding * 0.5);
         GraphicUtils.drawUIBlock(this.mc_anim.graphics,252,222);
         this.mc_container.addChild(this.mc_anim);
         this.mc_spinner = new UIBusySpinner();
         this.mc_spinner.x = int(this.mc_anim.x + this.mc_anim.width * 0.5);
         this.mc_spinner.y = int(this.mc_anim.y + this.mc_anim.height * 0.5);
         this.mc_container.addChild(this.mc_spinner);
         this.txt_item = new BodyTextField({
            "color":16777215,
            "size":14,
            "bold":true,
            "align":"center",
            "filters":[Effects.ICON_SHADOW],
            "multiline":true
         });
         this.txt_item.maxWidth = this.mc_anim.width;
         this.ui_itemImage = new UIItemImage(64,64,2);
         this.ui_itemImage.x = int(this.mc_anim.x + (this.mc_anim.width - this.ui_itemImage.width) * 0.5);
         this.ui_itemImage.y = int(this.mc_anim.y + 74);
         this.mc_container.addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         this.mc_container.addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._crate = null;
         this._resources.purge(this._animURI);
         this._anim = null;
         this._resources.resourceLoadCompleted.remove(this.onResourceLoadComplete);
         this._resources.resourceLoadFailed.remove(this.onResourceLoadFailed);
         this._resources = null;
         this.btn_share = null;
         this.btn_ok = null;
         if(this.ui_itemImage != null)
         {
            this.ui_itemImage.dispose();
         }
      }
      
      override public function open() : void
      {
         super.open();
         txt_title.x = int((_width - txt_title.width) * 0.5);
      }
      
      private function playOpenAnimation() : void
      {
         this._anim.addEventListener(Event.ENTER_FRAME,this.onEnterFrame,false,0,true);
         this._anim.gotoAndPlay("unlocked");
      }
      
      private function playItemAnimation() : void
      {
         this.mc_container.addChild(this.txt_item);
         TweenMax.from(this.txt_item,3,{
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
         this.mc_container.addChild(this.ui_itemImage);
         TweenMax.from(this.ui_itemImage,3,{
            "colorTransform":{"exposure":2},
            "transformAroundCenter":{
               "scaleX":0.75,
               "scaleY":0.75
            }
         });
         this.btn_ok.enabled = true;
         if(this.btn_share != null)
         {
            this.btn_share.enabled = true;
         }
      }
      
      private function loadAnimation() : void
      {
         if(this._resources.exists(this._animURI))
         {
            if(this._resources.isInQueue(this._animURI))
            {
               this._resources.resourceLoadCompleted.add(this.onResourceLoadComplete);
               this._resources.resourceLoadFailed.add(this.onResourceLoadFailed);
            }
            else
            {
               this._anim = MovieClip(this._resources.getResource(this._animURI).content);
               this._anim.x = this._anim.y = 1;
               this.mc_anim.addChild(this._anim);
               if(this.mc_spinner.parent != null)
               {
                  this.mc_spinner.parent.removeChild(this.mc_spinner);
               }
            }
         }
         else
         {
            this._resources.resourceLoadCompleted.add(this.onResourceLoadComplete);
            this._resources.resourceLoadFailed.add(this.onResourceLoadFailed);
            this._resources.load(this._animURI);
         }
      }
      
      private function openCrate() : void
      {
         this._anim.gotoAndStop("waiting");
         this._crate.open(this.onCrateOpened);
      }
      
      private function gotoError() : void
      {
         this._resources.resourceLoadCompleted.remove(this.onResourceLoadComplete);
         this._resources.resourceLoadFailed.remove(this.onResourceLoadFailed);
         this.txt_item.multiline = this.txt_item.wordWrap = true;
         this.txt_item.autoSize = "center";
         this.txt_item.htmlText = Language.getInstance().getString("crate_unlock_error");
         this.txt_item.textColor = Effects.COLOR_WARNING;
         this.txt_item.width = this.mc_anim.width;
         this.txt_item.x = int(this.mc_anim.x + (this.mc_anim.width - this.txt_item.width) * 0.5);
         this.txt_item.y = int(this.mc_anim.y + 6);
         this.mc_container.addChild(this.txt_item);
         Audio.sound.play("sound/interface/int-error.mp3");
         this.btn_ok.enabled = true;
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         if(this._anim == null)
         {
            return;
         }
         if(this._anim.currentFrameLabel == "showItem")
         {
            this.playItemAnimation();
            this.mc_container.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         }
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.loadAnimation();
         if(this._anim != null)
         {
            this.openCrate();
         }
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
      }
      
      private function onCrateOpened(param1:Boolean, param2:Item = null, param3:Effect = null) : void
      {
         var _loc5_:String = null;
         if(!param1 || param2 == null)
         {
            this.gotoError();
            return;
         }
         this._item = param2;
         var _loc4_:* = "<font color=\'" + Color.colorToHex(Effects["COLOR_" + ItemQualityType.getName(this._item.qualityType)]) + "\'>" + this._item.getName() + "</font>";
         if(param3 != null)
         {
            _loc5_ = Language.getInstance().getString("effect_names." + param3.type);
            _loc4_ += "<br/><font color=\'" + Color.colorToHex(Effects["COLOR_EFFECT_" + param3.group.toUpperCase()]) + "\'> + " + _loc5_ + "</font>";
         }
         this.txt_item.htmlText = _loc4_;
         this.txt_item.width = this.mc_anim.width;
         this.txt_item.x = int(this.mc_anim.x + (this.mc_anim.width - this.txt_item.width) * 0.5);
         this.txt_item.y = int(this.mc_anim.y + 6);
         this.ui_itemImage.item = this._item;
         TweenMax.delayedCall(3,this.playOpenAnimation);
      }
      
      private function onResourceLoadComplete(param1:Resource) : void
      {
         if(param1.uri == this._animURI)
         {
            this._resources.resourceLoadCompleted.remove(this.onResourceLoadComplete);
            this._resources.resourceLoadFailed.remove(this.onResourceLoadFailed);
            this._anim = MovieClip(param1.content);
            this._anim.x = this._anim.y = 1;
            this.mc_anim.addChild(this._anim);
            if(this.mc_spinner.parent != null)
            {
               this.mc_spinner.parent.removeChild(this.mc_spinner);
            }
            if(this.mc_container.stage != null)
            {
               this.openCrate();
            }
         }
      }
      
      private function onResourceLoadFailed(param1:Resource, param2:Object) : void
      {
         if(param1.uri == this._animURI)
         {
            this.gotoError();
         }
      }
      
      private function onClickShare(param1:MouseEvent) : void
      {
         var lang:Language = null;
         var dlgBusy:BusyDialogue = null;
         var e:MouseEvent = param1;
         if(this._item == null)
         {
            return;
         }
         lang = Language.getInstance();
         dlgBusy = new BusyDialogue(lang.getString("crate_unlock_sharing"));
         dlgBusy.open();
         ImageWriter.saveItem(this._item,function(param1:String):void
         {
            var _loc2_:String = null;
            var _loc3_:String = null;
            dlgBusy.close();
            if(param1 != null)
            {
               _loc2_ = "shared.crate_unlocked_";
               _loc3_ = _item.getName();
               Network.getInstance().share(lang.getString(_loc2_ + "title",_loc3_),lang.getString(_loc2_ + "caption"),lang.getString(_loc2_ + "description",_loc3_),param1,"crate_unlock");
            }
         });
      }
   }
}

