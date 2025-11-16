package thelaststand.app.game.data.notification
{
   import com.exileetiquette.utils.NumberFormatter;
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class BuildingCompleteNotification implements INotification
   {
      
      private var _active:Boolean = false;
      
      private var _data:Building;
      
      private var _closed:Signal;
      
      private var _level:int;
      
      private var _name:String;
      
      private var _imageURI:String;
      
      private var _XPAward:int;
      
      public function BuildingCompleteNotification(param1:String)
      {
         var levelNode:XML = null;
         var buildingId:String = param1;
         super();
         this._closed = new Signal(INotification);
         this._data = Network.getInstance().playerData.compound.buildings.getBuildingById(buildingId);
         if(this._data != null)
         {
            levelNode = this._data.xml.lvl.(@n == String(_data.level))[0];
            this._level = this._data.level;
            this._name = this._data.getName();
            this._imageURI = levelNode.hasOwnProperty("img") ? levelNode.img.@uri.toString() : this._data.xml.img.@uri.toString();
            this._XPAward = levelNode.hasOwnProperty("xp") ? int(levelNode.xp) : 0;
         }
      }
      
      public function open() : void
      {
         var lang:Language;
         var msg:String;
         var dlg:MessageBox;
         var thisRef:INotification = null;
         if(this._data == null)
         {
            this._closed.dispatch(this);
            return;
         }
         thisRef = this;
         lang = Language.getInstance();
         msg = lang.getString("bld_complete_msg",this._name,lang.getString("level",this._level + 1));
         if(this._XPAward > 0)
         {
            msg += "<br/><br/><font color=\'#F9AF00\' size=\'16\'><b>" + lang.getString("msg_xp_awarded",NumberFormatter.format(this._XPAward,0)) + "</b></font>";
         }
         dlg = new MessageBox(msg,"building-complete-note",true);
         dlg.addTitle(lang.getString("bld_complete_title",this._name),4671303);
         dlg.addButton(lang.getString("bld_complete_ok"));
         dlg.addImage(this._imageURI,64,64);
         dlg.closed.addOnce(function(param1:Dialogue):void
         {
            _closed.dispatch(thisRef);
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
         return NotificationType.BUILDING_COMPLETE;
      }
      
      public function get data() : *
      {
         return this._data;
      }
   }
}

