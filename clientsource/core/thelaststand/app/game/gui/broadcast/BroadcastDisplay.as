package thelaststand.app.game.gui.broadcast
{
   import com.exileetiquette.math.MathUtils;
   import com.exileetiquette.utils.NumberFormatter;
   import com.greensock.TimelineMax;
   import com.greensock.TweenAlign;
   import com.greensock.TweenMax;
   import com.greensock.easing.Linear;
   import flash.display.BitmapData;
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.text.Font;
   import flash.text.StyleSheet;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import thelaststand.app.core.Config;
   import thelaststand.app.core.Global;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemFactory;
   import thelaststand.app.game.gui.UIItemInfo;
   import thelaststand.app.game.gui.dialogues.StoreDialogue;
   import thelaststand.app.network.BroadcastSystem;
   import thelaststand.app.network.Network;
   import thelaststand.common.lang.Language;
   
   public class BroadcastDisplay extends Sprite
   {
      
      public var broadcastSystem:BroadcastSystem;
      
      private var gridContainer:Sprite;
      
      private var bg:Shape;
      
      private var bgShadow:Shape;
      
      private var grid:Shape;
      
      private var gridOverlay:Shape;
      
      private var gridBD:BitmapData;
      
      private var msgContainer:Sprite;
      
      private var msgMask:Shape;
      
      private var textfields:Vector.<TextField>;
      
      private var txtContainer:Sprite;
      
      private var currentIndex:int = 0;
      
      private var textPosition:Point;
      
      private var _langXML:XML;
      
      private var _linkData:Array;
      
      private var _itemInfo:UIItemInfo;
      
      private var _item:Item;
      
      private var btn_toggle:BroadcastToggleButton;
      
      private var _width:Number = 657;
      
      private var _height:Number = 30;
      
      private var _enabled:Boolean = true;
      
      private var _shutdownCounter:int = 0;
      
      private var _shuttingDown:Boolean = false;
      
      private var _months:Array;
      
      private var _font:Font;
      
      public function BroadcastDisplay()
      {
         var _loc3_:Font = null;
         var _loc4_:TextField = null;
         this.textfields = new Vector.<TextField>();
         this.textPosition = new Point(1,4);
         this._itemInfo = new UIItemInfo();
         this._font = new Fixedsys_15();
         super();
         this.broadcastSystem = Network.getInstance().broadcastSystem;
         this.broadcastSystem.messageReceived.add(this.onMessageReceived);
         this.broadcastSystem.disconnected.add(this.onDisconnected);
         this.broadcastSystem.connect();
         this._langXML = Language.getInstance().xml.data.broadcast_system[0];
         this.btn_toggle = new BroadcastToggleButton();
         this.btn_toggle.y = int((this._height - this.btn_toggle.height) * 0.5);
         this.btn_toggle.addEventListener(MouseEvent.CLICK,this.onButtonClick,false,0,true);
         addChild(this.btn_toggle);
         this.gridContainer = new Sprite();
         this.gridContainer.x = this.btn_toggle.x + this.btn_toggle.width + 10;
         addChild(this.gridContainer);
         this.bg = new Shape();
         this.bg.graphics.beginFill(4079166,1);
         this.bg.graphics.drawRect(0,0,this._width,this._height);
         this.bg.graphics.endFill();
         this.gridContainer.addChild(this.bg);
         this.bgShadow = new Shape();
         this.bgShadow.graphics.beginFill(4079166,1);
         this.bgShadow.graphics.drawRect(0,0,this._width,this._height);
         this.bgShadow.graphics.endFill();
         this.gridContainer.addChild(this.bgShadow);
         this.bgShadow.filters = [new GlowFilter(0,0.5,15,15,2,1,true,true)];
         this.msgContainer = new Sprite();
         this.gridContainer.addChild(this.msgContainer);
         this.msgMask = new Shape();
         this.msgMask.x = this.msgMask.y = 1;
         this.msgMask.graphics.beginFill(16711680,1);
         this.msgMask.graphics.drawRect(0,0,this._width - 2,this._height - 2);
         this.msgMask.graphics.endFill();
         this.gridContainer.addChild(this.msgMask);
         this.msgContainer.mask = this.msgMask;
         this.gridBD = new Bmp_BroadcastPanelGrid();
         this.grid = new Shape();
         this.grid.x = this.grid.y = 1;
         this.grid.alpha = 0.5;
         this.msgContainer.addChild(this.grid);
         this.txtContainer = new Sprite();
         this.msgContainer.addChild(this.txtContainer);
         var _loc1_:int = 0;
         while(_loc1_ < 6)
         {
            _loc4_ = this.generateTextField();
            this.textfields.push(_loc4_);
            if(_loc1_ % 3 != 0)
            {
               TweenMax.to(_loc4_,0,{"colorTransform":{"brightness":0.5}});
            }
            else
            {
               _loc4_.mouseEnabled = true;
               _loc4_.addEventListener(TextEvent.LINK,this.onTextLink,false,0,true);
            }
            _loc1_++;
         }
         this.textfields.fixed = true;
         this.gridOverlay = new Shape();
         this.gridOverlay.x = this.gridOverlay.y = 1;
         this.gridOverlay.alpha = 0.3;
         this.msgContainer.addChild(this.gridOverlay);
         this._months = String(Language.getInstance().xml.data.months[0]).split(",");
         this.width = 700;
         var _loc2_:Array = Font.enumerateFonts();
         for each(_loc3_ in _loc2_)
         {
         }
      }
      
      public function dispose() : void
      {
         this.broadcastSystem.messageReceived.remove(this.onMessageReceived);
      }
      
      public function onMessageReceived(param1:String, param2:Array) : void
      {
         var _loc6_:XML = null;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc11_:XMLList = null;
         var _loc13_:Object = null;
         var _loc16_:String = null;
         var _loc17_:String = null;
         var _loc18_:String = null;
         var _loc19_:int = 0;
         var _loc20_:XMLList = null;
         var _loc21_:Array = null;
         var _loc22_:Object = null;
         var _loc23_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc25_:String = null;
         var _loc26_:XMLList = null;
         var _loc27_:String = null;
         var _loc28_:Array = null;
         var _loc29_:String = null;
         var _loc30_:String = null;
         var _loc31_:String = null;
         var _loc32_:String = null;
         var _loc33_:String = null;
         var _loc34_:Array = null;
         var _loc35_:Date = null;
         var _loc36_:XML = null;
         var _loc37_:XML = null;
         var _loc3_:Boolean = param1 == BroadcastSystemProtocols.ADMIN || param1 == BroadcastSystemProtocols.SHUT_DOWN;
         if(!(this._enabled || _loc3_))
         {
            return;
         }
         var _loc4_:String = "";
         var _loc5_:Boolean = false;
         var _loc7_:Array = [];
         var _loc8_:String = "defaultMsg";
         var _loc12_:int = -1;
         if(param1 != BroadcastSystemProtocols.SHUT_DOWN)
         {
            if(this._shuttingDown)
            {
               Network.getInstance().setShutdownStatus(false,int.MAX_VALUE);
            }
            this._shuttingDown = false;
            this._shutdownCounter = 0;
         }
         switch(param1)
         {
            case BroadcastSystemProtocols.ADMIN:
               _loc8_ = "adminMsg";
               _loc5_ = true;
               _loc4_ = param2[0];
               _loc12_ = 1907783;
               break;
            case BroadcastSystemProtocols.WARNING:
               _loc8_ = "warnMsg";
               _loc5_ = true;
               _loc12_ = 6636288;
               _loc4_ = param2[0];
               break;
            case BroadcastSystemProtocols.SHUT_DOWN:
               _loc8_ = "shutdownMsg";
               _loc5_ = true;
               if(this._langXML.shutdown.length() == 0)
               {
                  return;
               }
               this._shutdownCounter %= this._langXML.shutdown.length();
               _loc16_ = param2[0];
               _loc17_ = param2.length < 3 || param2[2] == "" ? "N/A" : param2[2];
               _loc18_ = "N/A";
               if(param2.length > 1 && param2[1] != null && param2[1] != "")
               {
                  _loc34_ = String(param2[1]).split(":");
                  _loc35_ = new Date();
                  _loc35_.setUTCHours(Number(_loc34_[0]));
                  _loc35_.setUTCMinutes(Number(_loc34_[1]));
                  _loc18_ = NumberFormatter.addLeadingZero(_loc35_.hours) + ":" + NumberFormatter.addLeadingZero(_loc35_.minutes);
               }
               _loc4_ = this._langXML.shutdown[this._shutdownCounter].toString();
               _loc4_ = _loc4_.replace("%min",_loc16_);
               _loc4_ = _loc4_.replace("%eta",_loc18_);
               _loc4_ = _loc4_.replace("%reason",_loc17_);
               _loc12_ = 7274496;
               ++this._shutdownCounter;
               _loc19_ = parseInt(_loc16_);
               if(isNaN(_loc19_))
               {
                  _loc19_ = 0;
               }
               Network.getInstance().setShutdownStatus(true,_loc19_);
               break;
            case BroadcastSystemProtocols.STATIC:
               if(this._langXML.random.children().length() <= 0)
               {
                  return;
               }
               _loc20_ = this._langXML.random.attributes();
               _loc21_ = [];
               for each(_loc36_ in _loc20_)
               {
                  _loc21_.push({
                     "id":_loc36_.name().toString(),
                     "val":Number(_loc36_.toString())
                  });
               }
               _loc21_.sortOn("val",Array.NUMERIC);
               _loc23_ = 0;
               for each(_loc22_ in _loc21_)
               {
                  _loc22_.val += _loc23_;
                  _loc23_ = Number(_loc22_.val);
               }
               _loc24_ = Math.random() * _loc23_;
               _loc25_ = _loc21_[0].id;
               for each(_loc22_ in _loc21_)
               {
                  if(_loc24_ <= _loc22_.val)
                  {
                     _loc25_ = _loc22_.id;
                     break;
                  }
               }
               _loc26_ = this._langXML.random[_loc25_];
               if(_loc26_.length() <= 0)
               {
                  return;
               }
               _loc27_ = Network.getInstance().service;
               _loc28_ = [];
               for each(_loc37_ in _loc26_)
               {
                  if(!_loc37_.hasOwnProperty("@service") || _loc37_.@service.toString == _loc27_)
                  {
                     _loc28_.push(_loc37_);
                  }
               }
               _loc4_ = _loc28_[Math.floor(Math.random() * _loc28_.length)];
               break;
            case BroadcastSystemProtocols.ITEM_UNBOXED:
               _loc11_ = this._langXML.item_unboxed;
               if(_loc11_.length() == 0)
               {
                  return;
               }
               _loc4_ = this.parseGenericItemString(String(_loc11_[MathUtils.randomBetween(0,_loc11_.length())]),_loc7_,param2[0],param2[1]);
               break;
            case BroadcastSystemProtocols.ITEM_FOUND:
               _loc11_ = this._langXML.item_found;
               if(_loc11_.length() == 0)
               {
                  return;
               }
               _loc4_ = this.parseGenericItemString(String(_loc11_[MathUtils.randomBetween(0,_loc11_.length())]),_loc7_,param2[0],param2[1]);
               break;
            case BroadcastSystemProtocols.ITEM_CRAFTED:
               _loc11_ = this._langXML.item_crafted;
               if(_loc11_.length() == 0)
               {
                  return;
               }
               _loc4_ = this.parseGenericItemString(String(_loc11_[MathUtils.randomBetween(0,_loc11_.length())]),_loc7_,param2[0],param2[1]);
               break;
            case BroadcastSystemProtocols.RAID_ATTACK:
               _loc11_ = this._langXML.raid_attack;
               if(_loc11_.length() == 0)
               {
                  return;
               }
               _loc4_ = _loc11_[MathUtils.randomBetween(0,_loc11_.length())].toString();
               _loc4_ = _loc4_.replace("%user","<span class=\'user\'>" + param2[0] + "</span>");
               break;
            case BroadcastSystemProtocols.RAID_DEFEND:
               _loc11_ = this._langXML.raid_defend;
               if(_loc11_.length() == 0)
               {
                  return;
               }
               _loc4_ = _loc11_[MathUtils.randomBetween(0,_loc11_.length())].toString();
               _loc4_ = _loc4_.replace("%user","<span class=\'user\'>" + param2[0] + "</span>");
               break;
            case BroadcastSystemProtocols.ACHIEVEMENT:
               _loc11_ = this._langXML.achievement;
               if(_loc11_.length() == 0)
               {
                  return;
               }
               _loc29_ = param2[2] == "1" ? "achievements." : "quests.";
               _loc30_ = Language.getInstance().getString(_loc29_ + param2[1] + "_name");
               _loc4_ = _loc11_[MathUtils.randomBetween(0,_loc11_.length())].toString();
               _loc4_ = _loc4_.replace("%user","<span class=\'user\'>" + param2[0] + "</span>");
               _loc4_ = _loc4_.replace("%achievement","<span class=\'highlight\'>" + _loc30_ + "</span>");
               break;
            case BroadcastSystemProtocols.USER_LEVEL:
               _loc11_ = this._langXML.level_up;
               if(_loc11_.length() == 0)
               {
                  return;
               }
               _loc4_ = _loc11_[MathUtils.randomBetween(0,_loc11_.length())].toString();
               _loc4_ = _loc4_.replace("%user","<span class=\'user\'>" + param2[0] + "</span>");
               _loc4_ = _loc4_.replace("%level","<span class=\'highlight\'>" + param2[1] + "</span>");
               break;
            case BroadcastSystemProtocols.SURVIVOR_COUNT:
               _loc11_ = this._langXML.survivor_count;
               if(_loc11_.length() == 0)
               {
                  return;
               }
               _loc4_ = _loc11_[MathUtils.randomBetween(0,_loc11_.length())].toString();
               _loc4_ = _loc4_.replace("%user","<span class=\'user\'>" + param2[0] + "</span>");
               _loc4_ = _loc4_.replace("%survivor","<span class=\'highlight\'>" + param2[1] + "</span>");
               break;
            case BroadcastSystemProtocols.ZOMBIE_ATTACK_FAIL:
               _loc11_ = this._langXML.zombie_attack_fail;
               if(_loc11_.length() == 0)
               {
                  return;
               }
               _loc4_ = _loc11_[MathUtils.randomBetween(0,_loc11_.length())].toString();
               _loc4_ = _loc4_.replace("%user","<span class=\'user\'>" + param2[0] + "</span>");
               break;
            case BroadcastSystemProtocols.ALL_INJURED:
               _loc11_ = this._langXML.injured_all_survivors;
               if(_loc11_.length() == 0)
               {
                  return;
               }
               _loc31_ = Language.getInstance().getString("suburbs." + param2[1]);
               _loc4_ = _loc11_[MathUtils.randomBetween(0,_loc11_.length())].toString();
               _loc4_ = _loc4_.replace("%user","<span class=\'user\'>" + param2[0] + "</span>");
               _loc4_ = _loc4_.replace("%suburb","<span class=\'highlight\'>" + _loc31_ + "</span>");
               break;
            case BroadcastSystemProtocols.BOUNTY_ADD:
               _loc11_ = this._langXML.bounty_add;
               if(_loc11_.length() == 0)
               {
                  return;
               }
               _loc4_ = _loc11_[MathUtils.randomBetween(0,_loc11_.length())].toString();
               _loc4_ = _loc4_.replace("%user","<span class=\'user\'>" + param2[0] + "</span>");
               _loc4_ = _loc4_.replace("%target","<span class=\'user\'>" + param2[1] + "</span>");
               _loc4_ = _loc4_.replace("%bounty","<span class=\'highlight\'>" + param2[2] + "</span>");
               break;
            case BroadcastSystemProtocols.BOUNTY_COLLECTED:
               _loc11_ = this._langXML.bounty_collected;
               if(_loc11_.length() == 0)
               {
                  return;
               }
               _loc4_ = _loc11_[MathUtils.randomBetween(0,_loc11_.length())].toString();
               _loc4_ = _loc4_.replace("%user","<span class=\'user\'>" + param2[0] + "</span>");
               _loc4_ = _loc4_.replace("%target","<span class=\'highlight\'>" + param2[1] + "</span>");
               _loc4_ = _loc4_.replace("%bounty","<span class=\'highlight\'>" + param2[2] + "</span>");
               break;
            case BroadcastSystemProtocols.ALLIANCE_RAID_SUCCESS:
               _loc11_ = this._langXML.alliance_raidSuccess;
               if(_loc11_.length() == 0)
               {
                  return;
               }
               _loc10_ = param2[1];
               _loc32_ = param2[4];
               _loc4_ = _loc11_[MathUtils.randomBetween(0,_loc11_.length())].toString();
               _loc4_ = _loc4_.replace("%user","<span class=\'user\'>" + param2[0] + "</span>");
               _loc4_ = _loc4_.replace("%allianceName","<span class=\'alliance\'>" + param2[2] + "</span>");
               _loc4_ = _loc4_.replace("%allianceTag","<span class=\'alliance\'>" + param2[3] + "</span>");
               _loc4_ = _loc4_.replace("%targetAllianceName","<span class=\'alliance\'>" + param2[5] + "</span>");
               _loc4_ = _loc4_.replace("%targetAllianceTag","<span class=\'alliance\'>[" + param2[6] + "]></span>");
               _loc4_ = _loc4_.replace("%points","<span class=\'highlight\'>" + param2[7] + "</span>");
               break;
            case BroadcastSystemProtocols.ALLIANCE_RANK:
               _loc33_ = param2[0];
               _loc11_ = this._langXML["alliance_rank_" + _loc33_];
               _loc4_ = _loc11_[MathUtils.randomBetween(0,_loc11_.length())].toString();
               _loc10_ = param2[1];
               _loc4_ = _loc4_.replace("%allianceName","<span class=\'alliance\'>" + param2[2] + "</span>");
               _loc4_ = _loc4_.replace("%allianceTag","<span class=\'alliance\'>[" + param2[3] + "]</span>");
               break;
            case BroadcastSystemProtocols.RAIDMISSION_STARTED:
               _loc11_ = this._langXML.raidmission_started;
               if(_loc11_.length() == 0)
               {
                  return;
               }
               _loc4_ = _loc11_[MathUtils.randomBetween(0,_loc11_.length())].toString();
               _loc4_ = _loc4_.replace("%user","<span class=\'user\'>" + param2[0] + "</span>");
               _loc4_ = _loc4_.replace("%raidname","<span class=\'highlight\'>" + Language.getInstance().getString("raid." + param2[1] + ".name") + "</span>");
               break;
            case BroadcastSystemProtocols.RAIDMISSION_COMPELTE:
               _loc11_ = this._langXML.raidmission_completed;
               if(_loc11_.length() == 0)
               {
                  return;
               }
               _loc4_ = _loc11_[MathUtils.randomBetween(0,_loc11_.length())].toString();
               _loc4_ = _loc4_.replace("%user","<span class=\'user\'>" + param2[0] + "</span>");
               _loc4_ = _loc4_.replace("%raidname","<span class=\'highlight\'>" + Language.getInstance().getString("raid." + param2[1] + ".name") + "</span>");
               break;
            case BroadcastSystemProtocols.RAIDMISSION_FAILED:
               _loc11_ = this._langXML.raidmission_failed;
               if(_loc11_.length() == 0)
               {
                  return;
               }
               _loc4_ = _loc11_[MathUtils.randomBetween(0,_loc11_.length())].toString();
               _loc4_ = _loc4_.replace("%user","<span class=\'user\'>" + param2[0] + "</span>");
               _loc4_ = _loc4_.replace("%raidname","<span class=\'highlight\'>" + Language.getInstance().getString("raid." + param2[1] + ".name") + "</span>");
               break;
            case BroadcastSystemProtocols.ARENA_LEADERBOARD:
               _loc11_ = this._langXML.arena_leaderboard;
               if(_loc11_.length() == 0)
               {
                  return;
               }
               _loc4_ = _loc11_[MathUtils.randomBetween(0,_loc11_.length())].toString();
               _loc4_ = _loc4_.replace("%user","<span class=\'user\'>" + param2[0] + "</span>");
               _loc4_ = _loc4_.replace("%arenaname","<span class=\'highlight\'>" + Language.getInstance().getString("arena." + param2[1] + ".name") + "</span>");
               _loc4_ = _loc4_.replace("%level","<span class=\'highlight\'>" + NumberFormatter.format(Number(param2[2]) + 1,0) + "</span>");
               _loc4_ = _loc4_.replace("%points","<span class=\'highlight\'>" + NumberFormatter.format(Number(param2[3]),0) + "</span>");
               break;
            case BroadcastSystemProtocols.HAZ_SUCCESS:
               _loc11_ = this._langXML.haz_win;
               if(_loc11_.length() == 0)
               {
                  return;
               }
               _loc4_ = _loc11_[MathUtils.randomBetween(0,_loc11_.length())].toString();
               _loc4_ = _loc4_.replace("%user","<span class=\'user\'>" + param2[0] + "</span>");
               break;
            case BroadcastSystemProtocols.HAZ_FAIL:
               _loc11_ = this._langXML.haz_lose;
               if(_loc11_.length() == 0)
               {
                  return;
               }
               _loc4_ = _loc11_[MathUtils.randomBetween(0,_loc11_.length())].toString();
               _loc4_ = _loc4_.replace("%user","<span class=\'user\'>" + param2[0] + "</span>");
               break;
            case BroadcastSystemProtocols.PLAIN_TEXT:
               _loc4_ = param2.length > 0 ? param2[0] : "";
               break;
            default:
               return;
         }
         if(!_loc4_ && param1 != BroadcastSystemProtocols.PLAIN_TEXT)
         {
            return;
         }
         _loc4_ = _loc4_.replace("%nickname",Network.getInstance().playerData.nickname);
         var _loc14_:RegExp = /\[\%UTC (\d{4})\-(\d{2})\-(\d{2}) (\d{2})\-(\d{2})\]/ig;
         while(true)
         {
            _loc13_ = _loc14_.exec(_loc4_);
            if(!_loc13_)
            {
               break;
            }
            _loc4_ = _loc4_.replace(_loc13_[0],this.convertUTCtoLocal(Number(_loc13_[1]),Number(_loc13_[2]),Number(_loc13_[3]),Number(_loc13_[4]),Number(_loc13_[5])));
         }
         _loc14_ = /\[\%UTC (\d{2})\-(\d{2})\]/ig;
         while(true)
         {
            _loc13_ = _loc14_.exec(_loc4_);
            if(!_loc13_)
            {
               break;
            }
            _loc4_ = _loc4_.replace(_loc13_[0],this.convertUTCtoLocal(0,0,0,Number(_loc13_[1]),Number(_loc13_[2])));
         }
         var _loc15_:* = "<span class=\'" + _loc8_ + "\'>" + _loc4_ + "</span>";
         this.displayMessage(_loc15_,_loc7_,_loc5_,_loc12_);
      }
      
      private function convertUTCtoLocal(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number) : String
      {
         var _loc6_:Date = new Date();
         if(param1 > 0)
         {
            _loc6_.setUTCFullYear(param1,param2 - 1,param3);
         }
         _loc6_.setUTCHours(param4);
         _loc6_.setUTCMinutes(param5);
         var _loc7_:* = "";
         if(param1 > 0)
         {
            _loc7_ = this._months[_loc6_.month] + " " + _loc6_.date + ", " + _loc6_.fullYear + " ";
         }
         return _loc7_ + ((_loc6_.hours <= 12 ? _loc6_.hours : _loc6_.hours - 12) + ":" + (_loc6_.minutes < 10 ? "0" + _loc6_.minutes : _loc6_.minutes) + (_loc6_.hours < 12 ? "am" : "pm"));
      }
      
      private function parseGenericItemString(param1:String, param2:Array, param3:String, param4:String) : String
      {
         var _loc5_:Object = null;
         var _loc6_:Item = null;
         var _loc7_:Object = null;
         var _loc8_:String = null;
         try
         {
            param1 = param1.replace("%user","<span class=\'user\'>" + param3 + "</span>");
            _loc5_ = JSON.parse(param4);
            _loc6_ = ItemFactory.createItemFromObject(_loc5_);
            if(_loc6_ == null)
            {
               return "";
            }
            _loc7_ = _loc6_.toChatObject();
            if(!_loc7_ || !_loc7_.name || !_loc7_.data)
            {
               return "";
            }
            _loc8_ = "defaultLink";
            if(_loc7_.hasOwnProperty("linkClass"))
            {
               _loc8_ = _loc7_.linkClass;
            }
            param1 = param1.replace("%item","<a href=\'event:item:0\' class=\'" + _loc8_ + "\'>[" + _loc7_.name + "]</a>");
            param2.push(_loc7_);
            return param1;
         }
         catch(e:Error)
         {
         }
         return "";
      }
      
      private function onDisconnected() : void
      {
         this.displayMessage("");
      }
      
      private function displayMessage(param1:String, param2:Array = null, param3:Boolean = false, param4:int = -1) : void
      {
         this._linkData = param2;
         var _loc5_:int = this.currentIndex;
         ++this.currentIndex;
         if(this.currentIndex > 1)
         {
            this.currentIndex = 0;
         }
         var _loc6_:int = this.currentIndex * 3;
         _loc5_ *= 3;
         var _loc7_:RegExp = /<([A-Z][A-Z0-9]*)\b[^>]*>(.*?)<\/\1>/ig;
         var _loc8_:Object = _loc7_.exec(param1);
         var _loc9_:TextField = this.textfields[_loc6_];
         _loc9_.htmlText = param1;
         _loc9_.x = int(this.grid.x + (this.grid.width - _loc9_.width) * 0.5);
         if(_loc9_.x < this.grid.x)
         {
            _loc9_.x = this.grid.x;
         }
         _loc9_.y = this.textPosition.y + this.grid.height;
         this.textfields[_loc6_ + 1].x = this.textfields[_loc6_ + 2].x = _loc9_.x;
         this.textfields[_loc6_ + 1].y = this.textfields[_loc6_ + 2].y = _loc9_.y;
         this.textfields[_loc6_ + 1].htmlText = this.textfields[_loc6_ + 2].htmlText = param1;
         this.textfields[_loc6_ + 1].alpha = 0.8;
         this.textfields[_loc6_ + 2].alpha = 0.8;
         this.txtContainer.addChild(this.textfields[_loc6_ + 2]);
         this.txtContainer.addChild(this.textfields[_loc6_ + 1]);
         this.txtContainer.addChild(_loc9_);
         var _loc10_:Number = 0.075;
         this.textfields[_loc6_].mouseEnabled = true;
         TweenMax.killTweensOf(this.textfields[_loc6_]);
         TweenMax.killTweensOf(this.textfields[_loc6_ + 1]);
         TweenMax.killTweensOf(this.textfields[_loc6_ + 2]);
         TweenMax.to(this.textfields[_loc6_ + 1],1,{
            "y":this.textPosition.y,
            "ease":Linear.easeNone
         });
         TweenMax.to(this.textfields[_loc6_],1,{
            "delay":_loc10_,
            "y":this.textPosition.y,
            "ease":Linear.easeNone
         });
         TweenMax.to(this.textfields[_loc6_ + 2],1,{
            "delay":_loc10_ * 2,
            "y":this.textPosition.y,
            "ease":Linear.easeNone,
            "onComplete":this.onMessageTweenInComplete,
            "onCompleteParams":[param3]
         });
         this.textfields[_loc5_].mouseEnabled = false;
         TweenMax.killTweensOf(this.textfields[_loc5_]);
         TweenMax.killTweensOf(this.textfields[_loc5_ + 1]);
         TweenMax.killTweensOf(this.textfields[_loc5_ + 2]);
         this.textfields[_loc5_].visible = true;
         this.textfields[_loc5_].alpha = 1;
         this.textfields[_loc5_ + 1].visible = true;
         this.textfields[_loc5_ + 2].visible = true;
         TweenMax.to(this.textfields[_loc5_ + 1],1,{
            "y":this.textPosition.y - this.grid.height,
            "ease":Linear.easeNone
         });
         TweenMax.to(this.textfields[_loc5_],1,{
            "delay":_loc10_,
            "y":this.textPosition.y - this.grid.height,
            "ease":Linear.easeNone
         });
         TweenMax.to(this.textfields[_loc5_ + 2],1,{
            "delay":_loc10_ * 2,
            "y":this.textPosition.y - this.grid.height,
            "ease":Linear.easeNone
         });
         TweenMax.to(this.bg,1,{"tint":(param4 >= 0 ? param4 : null)});
      }
      
      private function onMessageTweenInComplete(param1:Boolean) : void
      {
         if(param1)
         {
            this.triggerBlink();
         }
         var _loc2_:int = this.currentIndex * 3;
         if(this.textfields[_loc2_].width > this.msgMask.width)
         {
            this.marqueeText(param1 ? 2 : 0.5);
         }
      }
      
      private function marqueeText(param1:Number) : void
      {
         var _loc2_:int = this.currentIndex * 3;
         var _loc3_:Number = 0.075;
         var _loc4_:Number = this.msgMask.width - this.textfields[_loc2_].width;
         var _loc5_:Number = Math.abs(_loc4_) / 30;
         this.textfields[_loc2_ + 1].visible = true;
         this.textfields[_loc2_ + 2].visible = true;
         TweenMax.to(this.textfields[_loc2_ + 1],_loc5_,{
            "delay":param1,
            "x":_loc4_,
            "ease":Linear.easeNone
         });
         TweenMax.to(this.textfields[_loc2_],_loc5_,{
            "delay":param1 + _loc3_,
            "x":_loc4_,
            "ease":Linear.easeNone
         });
         TweenMax.to(this.textfields[_loc2_ + 2],_loc5_,{
            "delay":param1 + _loc3_ * 2,
            "x":_loc4_,
            "ease":Linear.easeNone
         });
      }
      
      private function triggerBlink() : void
      {
         var _loc1_:int = this.currentIndex * 3;
         this.textfields[_loc1_ + 1].visible = false;
         this.textfields[_loc1_ + 2].visible = false;
         var _loc2_:TimelineMax = new TimelineMax({
            "repeat":2,
            "repeatDelay":0.5,
            "align":TweenAlign.SEQUENCE
         });
         _loc2_.insert(new TweenMax(this.textfields[_loc1_],0,{
            "delay":0.25,
            "autoAlpha":0
         }));
         _loc2_.insert(new TweenMax(this.textfields[_loc1_],0,{
            "delay":0.75,
            "autoAlpha":1
         }));
      }
      
      private function generateTextField() : TextField
      {
         var _loc1_:String = Config.constant.CHAT_MESSAGE_DISPLAY_CSS;
         var _loc2_:StyleSheet = new StyleSheet();
         _loc2_.parseCSS(_loc1_);
         var _loc3_:TextField = new TextField();
         _loc3_.embedFonts = true;
         var _loc4_:TextFormat = new TextFormat(this._font.fontName,15,16757760);
         _loc4_.letterSpacing = -0.5;
         _loc3_.defaultTextFormat = _loc4_;
         _loc3_.styleSheet = _loc2_;
         _loc3_.autoSize = TextFieldAutoSize.LEFT;
         _loc3_.wordWrap = false;
         _loc3_.multiline = false;
         _loc3_.text = "";
         _loc3_.width = this.grid.width;
         _loc3_.height = 22;
         _loc3_.selectable = false;
         _loc3_.mouseWheelEnabled = false;
         _loc3_.mouseEnabled = false;
         _loc3_.sharpness = 200;
         _loc3_.thickness = -100;
         _loc3_.antiAliasType = "advanced";
         _loc3_.x = this.textPosition.x;
         _loc3_.y = this.textPosition.y;
         return _loc3_;
      }
      
      private function displayItemDataPopup(param1:*) : void
      {
         if(this._item)
         {
            this._item.dispose();
            this._item = null;
         }
         this._item = ItemFactory.createItemFromObject(param1);
         if(this._item == null)
         {
            return;
         }
         this._itemInfo.setItem(this._item,null,{"showAction":false});
         this._itemInfo.x = 2;
         this._itemInfo.y = -this._itemInfo.height - 10;
         addChild(this._itemInfo);
         Global.stage.addEventListener(MouseEvent.MOUSE_DOWN,this.removeDisplayItem,true,int.MAX_VALUE,true);
      }
      
      private function removeDisplayItem(param1:MouseEvent) : void
      {
         if(this._itemInfo.parent)
         {
            this._itemInfo.parent.removeChild(this._itemInfo);
         }
      }
      
      private function onButtonClick(param1:MouseEvent) : void
      {
         this._enabled = !this._enabled;
         if(!this._enabled)
         {
            this.displayMessage("");
            this.btn_toggle.active = false;
         }
         else
         {
            this.btn_toggle.active = true;
         }
      }
      
      private function onTextLink(param1:TextEvent) : void
      {
         var cat:String = null;
         var subCat:String = null;
         var store:StoreDialogue = null;
         var e:TextEvent = param1;
         var parts:Array = e.text.split(":");
         switch(parts[0])
         {
            case "item":
               try
               {
                  this.displayItemDataPopup(this._linkData[int(parts[1])].data);
                  break;
               }
               catch(error:Error)
               {
                  break;
               }
               break;
            case "store":
               try
               {
                  cat = parts.length > 1 ? String(parts[1]) : null;
                  subCat = parts.length > 2 ? String(parts[2]) : null;
                  store = new StoreDialogue(cat,subCat);
                  store.open();
               }
               catch(error:Error)
               {
               }
         }
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
         this._width = param1;
         this.bg.width = this._width - this.gridContainer.x;
         this.bgShadow.width = this.bg.width;
         var _loc2_:Graphics = this.grid.graphics;
         _loc2_.clear();
         _loc2_.beginBitmapFill(this.gridBD,null,true,false);
         _loc2_.drawRect(0,0,this.bg.width - 2,this.bg.height - 2);
         _loc2_.endFill();
         _loc2_ = this.gridOverlay.graphics;
         _loc2_.clear();
         _loc2_.beginBitmapFill(this.gridBD,null,true,false);
         _loc2_.drawRect(0,0,this.bg.width - 2,this.bg.height - 2);
         _loc2_.endFill();
         this.msgMask.width = this.grid.width;
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
   }
}

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;

class BroadcastToggleButton extends Sprite
{
   
   private var bd_on:BitmapData = new Bmp_ActivityTickerOn();
   
   private var bd_off:BitmapData = new Bmp_ActivityTickerOff();
   
   private var bmp:Bitmap;
   
   private var _active:Boolean;
   
   public function BroadcastToggleButton()
   {
      super();
      buttonMode = true;
      mouseChildren = false;
      this.bmp = new Bitmap(this.bd_on);
      addChild(this.bmp);
      addEventListener(MouseEvent.ROLL_OVER,this.onRollOver,false,0,true);
      addEventListener(MouseEvent.ROLL_OUT,this.onRollOut,false,0,true);
   }
   
   private function onRollOver(param1:MouseEvent) : void
   {
   }
   
   private function onRollOut(param1:MouseEvent) : void
   {
   }
   
   public function get active() : Boolean
   {
      return this._active;
   }
   
   public function set active(param1:Boolean) : void
   {
      this._active = param1;
      this.bmp.bitmapData = this._active ? this.bd_on : this.bd_off;
      this.bmp.x = int((this.bd_on.width - this.bmp.width) * 0.5);
      this.bmp.y = int((this.bd_on.height - this.bmp.height) * 0.5);
   }
}
