package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.utils.setTimeout;
   import org.osflash.signals.Signal;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.data.PlayerFlags;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.gui.survivor.UISurvivorCustomize;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.PlayerIOConnector;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class CreateSurvivorDialogue extends BaseDialogue
   {
      
      private var _lang:Language;
      
      private var _survivor:Survivor;
      
      private var mc_container:Sprite = new Sprite();
      
      private var btn_save:PushButton;
      
      private var ui_customize:UISurvivorCustomize;
      
      public var completed:Signal;
      
      public function CreateSurvivorDialogue(param1:Survivor, param2:String = null, param3:String = null)
      {
         super("create-survivor",this.mc_container);
         this._survivor = param1;
         this.ui_customize = new UISurvivorCustomize(this._survivor);
         this.ui_customize.y = int(_padding * 0.5);
         this.mc_container.addChild(this.ui_customize);
         if(param3 != null && Network.getInstance().service != PlayerIOConnector.SERVICE_KONGREGATE)
         {
            this.ui_customize.showNicknameMessage(param3);
         }
         this._lang = Language.getInstance();
         _autoSize = false;
         _width = int(this.ui_customize.width + _padding * 2);
         _height = int(this.ui_customize.y + this.ui_customize.height + 70);
         _buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         this.completed = new Signal();
         addTitle(param2 || this._lang.getString("player_create_title"));
         this.btn_save = PushButton(addButton(this._lang.getString("player_create_ok"),false,{"width":118}));
         this.btn_save.clicked.add(this.onSaveClicked);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._lang = null;
         this._survivor = null;
         this.ui_customize.dispose();
         this.completed.removeAll();
         this.btn_save = null;
      }
      
      private function onSaveClicked(param1:MouseEvent) : void
      {
         var data:Object = null;
         var network:Network = null;
         var e:MouseEvent = param1;
         data = {
            "name":this.ui_customize.getName(),
            "ap":this._survivor.appearance.serialize(),
            "g":this._survivor.gender,
            "v":this._survivor.voicePack
         };
         this.btn_save.enabled = false;
         this.ui_customize.nicknameState = UISurvivorCustomize.NICKNAME_CHECKING;
         this.ui_customize.showNicknameMessage(null);
         network = Network.getInstance();
         network.playerData.saveCustomization(data,null,function(param1:Boolean, param2:String = null):void
         {
            var errMessage:String = null;
            var success:Boolean = param1;
            var errType:String = param2;
            if(success)
            {
               ui_customize.nicknameState = UISurvivorCustomize.NICKNAME_OK;
               network.playerData.flags.set(PlayerFlags.NicknameVerified,true);
               _survivor.updatePortrait();
               setTimeout(function():void
               {
                  completed.dispatch();
               },500);
            }
            else
            {
               btn_save.enabled = true;
               switch(errType)
               {
                  case "nickname_short":
                  case "nickname_long":
                  case "nickname_invalid":
                     errMessage = Language.getInstance().getString("player_create_error_nickname");
                     break;
                  case "nickname_offensive":
                     errMessage = Language.getInstance().getString("player_create_error_nickoffensive");
                     break;
                  case "nickname_taken":
                     errMessage = Language.getInstance().getString("player_create_error_nicktaken",data.name);
                     break;
                  case "nickname_error":
                     errMessage = Language.getInstance().getString("player_create_error_nick_fail");
               }
               ui_customize.nicknameState = UISurvivorCustomize.NICKNAME_ERROR;
               ui_customize.showNicknameMessage(errMessage);
               Audio.sound.play("sound/interface/int-error.mp3");
            }
         });
      }
   }
}

