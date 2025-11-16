package thelaststand.app.game.data.notification
{
   import com.deadreckoned.threshold.display.Color;
   import flash.events.MouseEvent;
   import org.osflash.signals.Signal;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.ItemQualityType;
   import thelaststand.app.game.data.Schematic;
   import thelaststand.app.game.gui.dialogues.CraftingDialogue;
   import thelaststand.app.game.gui.dialogues.EventAlertDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class SchematicUnlockedNotification implements INotification
   {
      
      private var _active:Boolean = false;
      
      private var _data:Schematic;
      
      private var _closed:Signal;
      
      public function SchematicUnlockedNotification(param1:String)
      {
         super();
         this._closed = new Signal(INotification);
         this._data = Network.getInstance().playerData.inventory.getSchematic(param1);
      }
      
      public function open() : void
      {
         var lang:Language;
         var itemColour:String;
         var itemName:String;
         var thisRef:INotification = null;
         var dlg:EventAlertDialogue = null;
         if(this._data == null)
         {
            this._closed.dispatch(this);
            return;
         }
         thisRef = this;
         lang = Language.getInstance();
         itemColour = Color.colorToHex(Effects["COLOR_" + ItemQualityType.getName(this._data.outputItem.qualityType)]);
         itemName = "<font color=\'" + itemColour + "\'>" + this._data.getName() + "</font>";
         dlg = new EventAlertDialogue("images/ui/schematic-unlocked.jpg",110,110,"left","schematic-unlocked");
         dlg.addTitle(lang.getString("schematic_unlocked_title"),5864895);
         dlg.addBody(lang.getString("schematic_unlocked_msg",itemName));
         dlg.addButton(lang.getString("schematic_unlocked_craft"),false,{"width":106}).clicked.addOnce(function(param1:MouseEvent):void
         {
            dlg.close();
            var _loc2_:CraftingDialogue = new CraftingDialogue(_data.outputItem.category);
            _loc2_.selectSchematic(_data);
            _loc2_.open();
         });
         dlg.addButton(lang.getString("schematic_unlocked_ok"),true,{"width":90});
         dlg.closed.addOnce(function(param1:Dialogue):void
         {
            _closed.dispatch(thisRef);
         });
         dlg.open();
         Audio.sound.play("schematic-unlocked");
      }
      
      public function get active() : Boolean
      {
         return this._active;
      }
      
      public function set active(param1:Boolean) : void
      {
         this._active = param1;
      }
      
      public function get closed() : Signal
      {
         return this._closed;
      }
      
      public function get type() : String
      {
         return NotificationType.TASK_COMPLETE;
      }
      
      public function get data() : *
      {
         return this._data;
      }
   }
}

