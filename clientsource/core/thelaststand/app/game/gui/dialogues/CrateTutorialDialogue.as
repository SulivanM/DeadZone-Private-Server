package thelaststand.app.game.gui.dialogues
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Back;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.CrateItem;
   import thelaststand.app.game.gui.UILargeBgShine;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class CrateTutorialDialogue extends BaseDialogue
   {
      
      private var _crate:CrateItem;
      
      private var mc_container:Sprite = new Sprite();
      
      private var ui_image:UIImage;
      
      private var ui_shine:UILargeBgShine;
      
      private var txt_body:BodyTextField;
      
      public function CrateTutorialDialogue(param1:CrateItem)
      {
         super("cratetutorial",this.mc_container,false,true);
         _buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         _buttonYOffset = _padding;
         addTitle(Language.getInstance().getString("crate_tut_title"),BaseDialogue.TITLE_COLOR_GREY);
         addButton(Language.getInstance().getString("crate_tut_ok"),false,{
            "width":180,
            "backgroundColor":PurchasePushButton.DEFAULT_COLOR
         }).clicked.add(this.onClickUnlock);
         this._crate = param1;
         this.ui_shine = new UILargeBgShine();
         var _loc2_:int = 3;
         var _loc3_:int = 240;
         var _loc4_:int = 146;
         var _loc5_:int = _padding * 0.5;
         GraphicUtils.drawUIBlock(this.mc_container.graphics,_loc3_ + _loc2_ * 2,_loc4_ + _loc2_ * 2,0,_loc5_);
         this.ui_image = new UIImage(_loc3_,_loc4_,0,0,true,"images/ui/tutorial-crate.jpg");
         this.ui_image.x = _loc2_;
         this.ui_image.y = _loc5_ + _loc2_;
         this.mc_container.addChild(this.ui_image);
         this.txt_body = new BodyTextField({
            "color":16777215,
            "size":14,
            "multiline":true,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_body.htmlText = Language.getInstance().getString("crate_tut_msg");
         this.txt_body.width = _loc3_;
         this.txt_body.y = int(this.ui_image.y + this.ui_image.height + _loc2_ + _padding);
         this.mc_container.addChild(this.txt_body);
         this.mc_container.addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,-10,true);
         this.mc_container.addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,-10,true);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.ui_shine.dispose();
         this.ui_image.dispose();
         this.txt_body.dispose();
         this._crate = null;
      }
      
      private function onClickUnlock(param1:MouseEvent) : void
      {
         new CrateInspectionDialogue(this._crate,false).open();
         close();
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.ui_shine.x = int(_width * 0.5);
         this.ui_shine.y = int(_height * 0.5);
         this.ui_shine.scaleX = this.ui_shine.scaleY = 2;
         sprite.addChildAt(this.ui_shine,0);
         TweenMax.from(this.ui_shine,0.5,{
            "scaleX":0,
            "scaleY":0,
            "ease":Back.easeOut
         });
         Audio.sound.play("sound/interface/int-found-good.mp3");
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         TweenMax.killTweensOf(this.ui_shine);
         if(this.ui_shine.parent != null)
         {
            this.ui_shine.parent.removeChild(this.ui_shine);
         }
      }
   }
}

