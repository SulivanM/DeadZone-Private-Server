package thelaststand.app.game.data.notification
{
   import flash.events.MouseEvent;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Global;
   import thelaststand.app.data.NavigationLocation;
   import thelaststand.app.events.NavigationEvent;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.Task;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.RemotePlayerData;
   import thelaststand.app.network.RemotePlayerManager;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class HelpedNotification implements INotification
   {
      
      private var _active:Boolean = false;
      
      private var _data:Object;
      
      private var _closed:Signal;
      
      public function HelpedNotification(param1:Object)
      {
         super();
         this._closed = new Signal(INotification);
         this._data = param1;
      }
      
      public function open() : void
      {
         var lang:Language;
         var fromName:String;
         var strTime:String;
         var strType:String;
         var helpType:String;
         var dlgTitle:String;
         var dlg:MessageBox;
         var thisRef:INotification = null;
         var neighbor:RemotePlayerData = null;
         var dlgMessage:String = null;
         var building:Building = null;
         var task:Task = null;
         thisRef = this;
         var close:Function = function():void
         {
            _closed.dispatch(thisRef);
         };
         if(this._data == null)
         {
            close();
            return;
         }
         lang = Language.getInstance();
         fromName = String(this.data.fromName);
         strTime = DateTimeUtils.secondsToString(int(this.data.secRemoved));
         strType = String(this.data.type);
         helpType = strType.substr(strType.indexOf(":") + 1);
         neighbor = RemotePlayerManager.getInstance().getPlayer(this.data.fromId);
         dlgTitle = lang.getString("help_note_title",fromName);
         switch(helpType)
         {
            case "building":
               building = Network.getInstance().playerData.compound.buildings.getBuildingById(String(this.data.buildingId));
               if(building == null)
               {
                  close();
                  return;
               }
               dlgMessage = lang.getString("help_note_bld_msg",fromName,building.getUpgradeName(),strTime,fromName);
               break;
            case "task":
               task = Network.getInstance().playerData.compound.tasks.getTaskById(String(this.data.taskId));
               if(task == null)
               {
                  close();
                  return;
               }
               dlgMessage = lang.getString("help_note_task_msg",fromName,lang.getString("tasks." + task.type),strTime,fromName);
               break;
            default:
               close();
               return;
         }
         dlg = new MessageBox(dlgMessage,"notification-helped",true);
         dlg.addTitle(dlgTitle,4671303);
         dlg.addButton(lang.getString("help_note_btn_ok"));
         if(neighbor != null)
         {
            dlg.addImage(neighbor.getPortraitURI(),64,64);
            dlg.addButton(lang.getString("help_note_btn_help",fromName),true,{"backgroundColor":4226049}).clicked.addOnce(function(param1:MouseEvent):void
            {
               Global.stage.dispatchEvent(new NavigationEvent(NavigationEvent.REQUEST,NavigationLocation.WORLD_MAP,neighbor.id));
               close();
            });
         }
         dlg.closed.addOnce(function(param1:Dialogue):void
         {
            close();
         });
         dlg.open();
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
         return NotificationType.SURVIVOR_HEALED;
      }
      
      public function get data() : *
      {
         return this._data;
      }
   }
}

