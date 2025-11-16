package thelaststand.app.game.gui.dialogues
{
   import com.adobe.images.JPGEncoder;
   import com.probertson.utils.GZIPBytesEncoder;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.net.FileReference;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.Endian;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemFactory;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorLoadout;
   import thelaststand.app.game.gui.attacklog.*;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.common.gui.buttons.AbstractButton;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class AttackReportLogDialogue extends BaseDialogue
   {
      
      private static const LOG:String = "log";
      
      private static const COMBATANTS:String = "combatants";
      
      private var _lang:Language;
      
      private var _attackData:Object;
      
      private var _contentHeight:int = 300;
      
      private var _contentY:int = 8;
      
      private var mc_container:Sprite;
      
      private var container_log:Sprite;
      
      private var container_combatants:Sprite;
      
      private var btn_log:PushButton;
      
      private var btn_combatants:PushButton;
      
      private var btn_closePush:PushButton;
      
      private var btn_save:PushButton;
      
      private var _jsonData:Object;
      
      private var logSummary:AttackLogSummary;
      
      private var logList:AttackLogScrollList;
      
      private var attackersList:AttackLogSurvivorList;
      
      private var defendersList:AttackLogSurvivorList;
      
      private var defendersById:Dictionary;
      
      private var defenders:Vector.<Survivor>;
      
      private var defendersLoadouts:Vector.<SurvivorLoadout>;
      
      private var attackersById:Dictionary;
      
      private var attackers:Vector.<Survivor>;
      
      private var attackersLoadouts:Vector.<SurvivorLoadout>;
      
      private var _error:Boolean = false;
      
      private var _bytes:ByteArray;
      
      public function AttackReportLogDialogue(param1:Object)
      {
         var titleStr:String;
         var compressed:ByteArray = null;
         var gzip:GZIPBytesEncoder = null;
         var jsonStr:String = null;
         var attackData:Object = param1;
         this._lang = Language.getInstance();
         this._attackData = attackData;
         this.mc_container = new Sprite();
         super("attack-log",this.mc_container,true);
         _width = 568;
         _height = 384;
         _padding = 12;
         _autoSize = false;
         titleStr = this._lang.getString("attack_log_title");
         titleStr = titleStr.replace("%attacker",String(attackData.attackerName).toUpperCase());
         titleStr = titleStr.replace("%defender",Network.getInstance().playerData.nickname.toUpperCase());
         addTitle(titleStr,this._attackData.win ? 7513127 : BaseDialogue.TITLE_COLOR_RUST);
         try
         {
            compressed = this._attackData.log;
            compressed.position = 0;
            gzip = new GZIPBytesEncoder();
            this._bytes = gzip.uncompressToByteArray(compressed);
            this._bytes.endian = Endian.LITTLE_ENDIAN;
            jsonStr = this._bytes.readUTF();
            this._jsonData = JSON.parse(jsonStr);
         }
         catch(err:Error)
         {
            _error = true;
         }
         if(this._error == false)
         {
            this.initUI();
         }
         this.mc_container.addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,-5,true);
      }
      
      private function initUI() : void
      {
         var _loc2_:String = null;
         var _loc3_:Dictionary = null;
         var _loc4_:* = null;
         var _loc5_:Object = null;
         var _loc6_:Survivor = null;
         var _loc7_:Survivor = null;
         var _loc8_:String = null;
         var _loc9_:Array = null;
         var _loc1_:PlayerData = Network.getInstance().playerData;
         this.btn_log = new PushButton(this._lang.getString("attack_log_btn_log"));
         this.btn_log.y = int(_padding * 0.5);
         this.btn_log.width = 154;
         this.btn_log.clicked.add(this.onButtonClicked);
         this.mc_container.addChild(this.btn_log);
         this.btn_combatants = new PushButton(this._lang.getString("attack_log_btn_combatant"));
         this.btn_combatants.y = this.btn_log.y;
         this.btn_combatants.width = 154;
         this.btn_combatants.x = this.btn_log.x + this.btn_log.width + 13;
         this.btn_combatants.clicked.add(this.onButtonClicked);
         this.mc_container.addChild(this.btn_combatants);
         this.defendersById = new Dictionary();
         this.defenders = new Vector.<Survivor>();
         for each(_loc2_ in this._jsonData.defenders)
         {
            _loc6_ = Network.getInstance().playerData.compound.survivors.getSurvivorById(_loc2_);
            this.defendersById[_loc2_] = _loc6_;
            this.defenders.push(_loc6_);
         }
         this.attackersById = new Dictionary();
         this.attackers = new Vector.<Survivor>();
         _loc3_ = new Dictionary();
         _loc4_ = this._lang.getString("attack_log_item_attackerPrefix") + " ";
         for each(_loc5_ in this._jsonData.attackers)
         {
            _loc7_ = new Survivor();
            _loc7_.readObject(_loc5_);
            _loc8_ = this._lang.getString("survivor_classes." + _loc7_.classId);
            if(_loc3_[_loc7_.classId] == null)
            {
               _loc7_.setFirstName(_loc4_ + _loc8_);
               _loc3_[_loc7_.classId] = [_loc7_];
            }
            else
            {
               _loc9_ = _loc3_[_loc7_.classId];
               if(_loc9_.length == 1)
               {
                  Survivor(_loc9_[0]).setFirstName(_loc4_ + _loc8_ + " 1");
               }
               _loc7_.setFirstName(_loc4_ + _loc8_ + " " + (_loc9_.length + 1));
               _loc9_.push(_loc7_);
            }
            this.attackers.push(_loc7_);
            this.attackersById[_loc7_.id] = _loc7_;
            _loc7_.loadoutOffence.weapon.item = _loc5_.weapon != null ? ItemFactory.createItemFromObject(_loc5_.weapon) : null;
            _loc7_.loadoutOffence.gearPassive.item = _loc5_.gear1 != null ? ItemFactory.createItemFromObject(_loc5_.gear1) : null;
            _loc7_.loadoutOffence.gearActive.item = _loc5_.gear2 != null ? ItemFactory.createItemFromObject(_loc5_.gear2) : null;
            _loc7_.loadoutOffence.gearActive.quantity = int(_loc5_.gear2_qty);
         }
         this.container_log = new Sprite();
         this.container_log.x = -4;
         this.container_log.y = this.btn_log.y + this.btn_log.height + _padding;
         this.mc_container.addChild(this.container_log);
         this.logSummary = new AttackLogSummary(this._attackData,this.attackers,this.defenders);
         this.container_log.addChild(this.logSummary);
         this.logList = new AttackLogScrollList(this._jsonData,this._bytes,this.attackersById,this.defendersById);
         this.logList.x = this.logSummary.x + this.logSummary.width + _padding * 0.5;
         this.container_log.addChild(this.logList);
         this.container_combatants = new Sprite();
         this.container_combatants.x = this.container_log.x;
         this.container_combatants.y = this.container_log.y;
         this.mc_container.addChild(this.container_combatants);
         this.attackersList = new AttackLogSurvivorList(AttackLogSurvivorList.ATTACKERS,this._attackData.attackerName);
         this.attackersList.populate(this.attackers);
         this.container_combatants.addChild(this.attackersList);
         this.defendersList = new AttackLogSurvivorList(AttackLogSurvivorList.DEFENDERS,Network.getInstance().playerData.nickname);
         this.defendersList.populate(this.defenders);
         this.defendersList.x = 190;
         this.container_combatants.addChild(this.defendersList);
         this.btn_closePush = new PushButton(this._lang.getString("attack_log_btn_close"));
         this.btn_closePush.x = this.container_combatants.x + this.defendersList.x + this.defendersList.width - (this.btn_closePush.width + 8);
         this.btn_closePush.y = this.container_combatants.y + this.defendersList.y + this.defendersList.height + _padding;
         this.btn_closePush.clicked.add(this.onButtonClicked);
         this.mc_container.addChild(this.btn_closePush);
         this.btn_save = new PushButton(this._lang.getString("attack_log_btn_save"));
         this.btn_save.x = this.btn_log.x;
         this.btn_save.y = this.btn_closePush.y;
         this.btn_save.clicked.add(this.onButtonClicked);
         this.mc_container.addChild(this.btn_save);
         this.setDisplay(LOG);
      }
      
      override public function dispose() : void
      {
         var _loc1_:Survivor = null;
         super.dispose();
         this._lang = null;
         this._bytes = null;
         this._jsonData = null;
         sprite.removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         if(this._error)
         {
            return;
         }
         this.btn_log.dispose();
         this.btn_combatants.dispose();
         this.btn_closePush.dispose();
         this.logSummary.dispose();
         this.logList.dispose();
         for each(_loc1_ in this.attackers)
         {
            _loc1_.dispose();
         }
         this.attackers = null;
         this.attackersList.dispose();
         this.defendersList.dispose();
      }
      
      private function setDisplay(param1:String) : void
      {
         this.btn_log.selected = param1 == LOG;
         this.btn_combatants.selected = param1 == COMBATANTS;
         this.container_log.visible = param1 == LOG;
         this.container_combatants.visible = param1 == COMBATANTS;
      }
      
      private function onButtonClicked(param1:MouseEvent) : void
      {
         switch(param1.target)
         {
            case this.btn_log:
               this.setDisplay(LOG);
               break;
            case this.btn_combatants:
               this.setDisplay(COMBATANTS);
               break;
            case this.btn_closePush:
               close();
               break;
            case this.btn_save:
               this.showConfirm();
         }
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.mc_container.removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         if(!this._error)
         {
            return;
         }
         var _loc2_:MessageBox = new MessageBox(this._lang.getString("attack_log_errorMsg"),"logCorrupted",true);
         _loc2_.open();
         _loc2_.closed.addOnce(this.closeOnError);
      }
      
      private function closeOnError(param1:Dialogue) : void
      {
         close();
      }
      
      private function showConfirm() : void
      {
         var _loc1_:MessageBox = new MessageBox(this._lang.getString("attack_log_confirm_desc"),"exportConfirm");
         _loc1_.addTitle(this._lang.getString("attack_log_confirm_title"));
         var _loc2_:AbstractButton = _loc1_.addButton(this._lang.getString("attack_log_confirm_save"),true,{
            "width":100,
            "color":Effects.BUTTON_GREEN
         });
         _loc2_.clicked.addOnce(this.exportReport);
         _loc1_.addButton(this._lang.getString("attack_log_confirm_cancel"),true,{"width":100});
         _loc1_.open();
      }
      
      private function exportReport(param1:Event = null) : void
      {
         var summaryBD:BitmapData;
         var logBD:BitmapData;
         var halfPad:Number;
         var w:Number;
         var h:Number;
         var secondRow:Number;
         var timestamp:BodyTextField;
         var d:Date;
         var m2:Matrix;
         var watermark:Sprite;
         var m:Matrix;
         var ct:ColorTransform;
         var titleStr:String;
         var saveRef:FileReference;
         var exportBD:BitmapData = null;
         var bytes:ByteArray = null;
         var encoder:JPGEncoder = null;
         var e:Event = param1;
         var combatBD:BitmapData = new BitmapData(this.container_combatants.width,this.container_combatants.height,false,4280690214);
         combatBD.draw(this.container_combatants);
         summaryBD = new BitmapData(this.logSummary.width,this.logSummary.height,false,4280690214);
         summaryBD.draw(this.logSummary);
         logBD = this.logList.generateBitmapData();
         halfPad = int(_padding * 0.5);
         w = Math.max(combatBD.width,summaryBD.width + halfPad + logBD.width) + _padding * 2;
         h = combatBD.height + Math.max(summaryBD.height + 12,logBD.height) + _padding * 3;
         secondRow = _padding + combatBD.height + 8;
         exportBD = new BitmapData(w,h,false,4280690214);
         exportBD.copyPixels(combatBD,combatBD.rect,new Point(_padding,_padding));
         exportBD.copyPixels(summaryBD,summaryBD.rect,new Point(_padding,secondRow));
         exportBD.copyPixels(logBD,logBD.rect,new Point(_padding + 190,secondRow));
         timestamp = new BodyTextField({
            "color":8421504,
            "size":12,
            "bold":false,
            "filters":[Effects.TEXT_SHADOW_DARK]
         });
         d = this._attackData.date;
         d.minutes += d.timezoneOffset;
         timestamp.text = Network.getInstance().service + " " + DateTimeUtils.dateToString(d);
         timestamp.alpha = 0.7;
         m2 = new Matrix();
         m2.translate(_padding,secondRow + summaryBD.height + 2);
         exportBD.draw(timestamp,m2);
         watermark = new AttackLogWatermark();
         m = new Matrix();
         m.scale(exportBD.width / watermark.width,exportBD.height / watermark.height);
         ct = new ColorTransform();
         ct.alphaMultiplier = 0.02;
         ct.blueMultiplier = -1;
         exportBD.draw(watermark,m,ct);
         ct.greenMultiplier = -1;
         m.translate(3,0);
         exportBD.draw(watermark,m,ct);
         combatBD.dispose();
         summaryBD.dispose();
         logBD.dispose();
         try
         {
            encoder = new JPGEncoder(100);
            bytes = encoder.encode(exportBD);
         }
         catch(e:Error)
         {
            exportBD.dispose();
            exportBD = null;
         }
         encoder = null;
         if(exportBD)
         {
            exportBD.dispose();
         }
         exportBD = null;
         if(bytes == null || bytes.length == 0)
         {
            this.saveIOErrorHandler();
            return;
         }
         titleStr = this._lang.getString("attack_log_title");
         titleStr = titleStr.replace("%attacker",String(this._attackData.attackerName));
         titleStr = titleStr.replace("%defender",Network.getInstance().playerData.nickname);
         saveRef = new FileReference();
         saveRef.addEventListener(Event.COMPLETE,this.saveCompleteHandler,false,0,true);
         saveRef.addEventListener(IOErrorEvent.IO_ERROR,this.saveIOErrorHandler,false,0,true);
         saveRef.save(bytes,titleStr + ".jpg");
      }
      
      private function saveCompleteHandler(param1:Event) : void
      {
      }
      
      private function saveIOErrorHandler(param1:IOErrorEvent = null) : void
      {
         var _loc2_:MessageBox = new MessageBox(this._lang.getString("attack_log_item_saveFail"),"logSaveFail",true);
         _loc2_.open();
      }
   }
}

