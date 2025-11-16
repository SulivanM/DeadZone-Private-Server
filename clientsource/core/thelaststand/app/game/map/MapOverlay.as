package thelaststand.app.game.map
{
   import com.greensock.TweenMax;
   import com.junkbyte.console.Cc;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import org.osflash.signals.Signal;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.core.Config;
   import thelaststand.app.data.IOpponent;
   import thelaststand.app.data.NavigationLocation;
   import thelaststand.app.events.NavigationEvent;
   import thelaststand.app.game.Tutorial;
   import thelaststand.app.game.data.MissionCollection;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.data.RaiderOpponentData;
   import thelaststand.app.game.data.ZombieOpponentData;
   import thelaststand.app.game.data.arena.ArenaSession;
   import thelaststand.app.game.data.bounty.InfectedBounty;
   import thelaststand.app.game.data.bounty.InfectedBountyTask;
   import thelaststand.app.game.data.raid.RaidData;
   import thelaststand.app.game.gui.arena.ArenaDialogue;
   import thelaststand.app.game.gui.arena.ArenaLaunchDialogue;
   import thelaststand.app.game.gui.dialogues.MissionLoadoutDialogue;
   import thelaststand.app.game.gui.map.UIAreaNodeInfo;
   import thelaststand.app.game.gui.map.UIHighActivityZoneMarker;
   import thelaststand.app.game.gui.map.UIMapArenaPin;
   import thelaststand.app.game.gui.map.UIMapAssignmentPin;
   import thelaststand.app.game.gui.map.UIMapInfectedBountyPin;
   import thelaststand.app.game.gui.map.UIMapPin;
   import thelaststand.app.game.gui.map.UIMapRaidPin;
   import thelaststand.app.game.gui.map.UIMissionAreaNode;
   import thelaststand.app.game.gui.raid.RaidDialogue;
   import thelaststand.app.game.gui.raid.RaidLaunchDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.RemotePlayerData;
   import thelaststand.app.network.RemotePlayerManager;
   import thelaststand.common.resources.ResourceManager;
   
   public class MapOverlay extends Sprite
   {
      
      public var suburbChanged:Signal = new Signal(String,int,Boolean);
      
      public var neighborClicked:Signal = new Signal(RemotePlayerData,Point);
      
      private const CT_SUBURB_UNLOCKED:ColorTransform = new ColorTransform(0,0,0,1,255,255,255);
      
      private const SUBURB_ALPHA_OUT:Number = 0.3;
      
      private const SUBURB_ALPHA_OVER:Number = 1;
      
      private var _xml:XML;
      
      private var mc_suburbs:Sprite;
      
      private var _pinLayer:Sprite;
      
      private var _suburbFillShapes:Vector.<Object>;
      
      private var _hitAreaGridSize:uint = 512;
      
      private var _hitAreas:Vector.<Vector.<UIMissionAreaNode>>;
      
      private var _hitAreaCols:int;
      
      private var _hitAreaRows:int;
      
      private var _highlightedData:UIMissionAreaNode;
      
      private var _highlightShapes:Vector.<Shape>;
      
      private var _highlightShapeIndex:int = 0;
      
      private var _missionList:MissionCollection;
      
      private var _areaNodes:Vector.<UIMissionAreaNode>;
      
      private var _areaNodeByLootType:Dictionary;
      
      private var _suburbAreaById:Dictionary;
      
      private var _suburbShapeById:Dictionary;
      
      private var _suburbByShape:Dictionary;
      
      private var _suburbById:Dictionary;
      
      private var _suburbs:Vector.<SuburbData>;
      
      private var _pinsByNode:Dictionary;
      
      private var _pins:Vector.<UIMapPin>;
      
      private var _compoundNodesById:Dictionary;
      
      private var _tutorial:Tutorial;
      
      private var _tutorialNode:UIMissionAreaNode;
      
      private var _infectedBounty:InfectedBounty;
      
      private var _infectedBountyPins:Vector.<UIMapInfectedBountyPin>;
      
      private var _assignmentPins:Vector.<UIMapAssignmentPin>;
      
      private var _highActivityMarkers:Vector.<UIHighActivityZoneMarker>;
      
      private var _playerNode:UIMissionAreaNode;
      
      private var _stage:Stage;
      
      private var _mouseDownPoint:Point;
      
      private var _mouseDownData:UIMissionAreaNode;
      
      private var _isDragging:Boolean = false;
      
      private var ui_nodeInfo:UIAreaNodeInfo;
      
      private var _rolloverTimer:Timer;
      
      private var _currentFilter:String;
      
      private var _selectedNode:UIMissionAreaNode;
      
      private var _navigationTargetNode:UIMissionAreaNode;
      
      private var _nodesByHazLevel:Array = [];
      
      public function MapOverlay(param1:XML)
      {
         super();
         this._xml = param1;
         this._missionList = Network.getInstance().playerData.missionList;
         this._areaNodes = new Vector.<UIMissionAreaNode>();
         this._areaNodeByLootType = new Dictionary(true);
         this._suburbAreaById = new Dictionary(true);
         this._suburbShapeById = new Dictionary(true);
         this._suburbByShape = new Dictionary(true);
         this._suburbById = new Dictionary(true);
         this._suburbs = new Vector.<SuburbData>();
         this._pins = new Vector.<UIMapPin>();
         this._pinsByNode = new Dictionary(true);
         this._compoundNodesById = new Dictionary(true);
         this._infectedBountyPins = new Vector.<UIMapInfectedBountyPin>();
         this._assignmentPins = new Vector.<UIMapAssignmentPin>();
         this._highActivityMarkers = new Vector.<UIHighActivityZoneMarker>();
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         if(Network.getInstance().playerData.isAdmin)
         {
            Cc.addSlashCommand("testmap",this.testMap,"/testmap mapType [level] - loads the map");
         }
      }
      
      private function testMap(param1:String) : void
      {
         var dlgMission:MissionLoadoutDialogue;
         var info:String = param1;
         var a:Array = info.split(" ");
         var opponent:ZombieOpponentData = new ZombieOpponentData(Number(a.length > 1 ? a[1] : "15"));
         var data:MissionData = new MissionData();
         data.opponent = opponent;
         data.type = a[0];
         data.suburb = "Testington";
         data.type = "testLocation";
         data.areaId = "TestAreaId";
         dlgMission = new MissionLoadoutDialogue(data);
         dlgMission.launched.add(function(param1:MissionData):void
         {
            var data:MissionData = param1;
            data.startMission(function():void
            {
               Network.getInstance().playerData.missionList.addMission(data);
               dispatchEvent(new NavigationEvent(NavigationEvent.REQUEST,NavigationLocation.MISSION,data));
            });
         });
         dlgMission.open();
      }
      
      public function dispose() : void
      {
         var _loc1_:RemotePlayerData = null;
         var _loc2_:Sprite = null;
         var _loc3_:UIMissionAreaNode = null;
         var _loc4_:UIMapPin = null;
         var _loc5_:UIMapInfectedBountyPin = null;
         var _loc6_:UIMapAssignmentPin = null;
         var _loc7_:UIHighActivityZoneMarker = null;
         if(this.mc_suburbs.parent)
         {
            this.mc_suburbs.parent.removeChild(this.mc_suburbs);
         }
         if(this._stage)
         {
            this._stage.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
            this._stage.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
            this._stage.removeEventListener(Event.DEACTIVATE,this.onMouseUp);
            this._stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
         }
         for each(_loc1_ in RemotePlayerManager.getInstance().neighbors)
         {
            if(this._navigationTargetNode == null || this._navigationTargetNode.mission == null || this._navigationTargetNode.mission.opponent != _loc1_)
            {
               ResourceManager.getInstance().purge(_loc1_.getPortraitURI());
            }
         }
         for each(_loc2_ in this._suburbShapeById)
         {
            _loc2_.removeEventListener(MouseEvent.ROLL_OVER,this.onSuburbRollOver);
            _loc2_.removeEventListener(MouseEvent.ROLL_OUT,this.onSuburbRollOut);
         }
         for each(_loc3_ in this._areaNodes)
         {
            _loc3_.dispose();
         }
         for each(_loc4_ in this._pins)
         {
            _loc4_.dispose();
         }
         for each(_loc5_ in this._infectedBountyPins)
         {
            _loc5_.dispose();
         }
         for each(_loc6_ in this._assignmentPins)
         {
            _loc6_.dispose();
         }
         for each(_loc7_ in this._highActivityMarkers)
         {
            _loc7_.dispose();
         }
         this._suburbs = null;
         this._navigationTargetNode = null;
         this._selectedNode = null;
         this._tutorial.stepChanged.remove(this.onTutorialStepChanged);
         this._tutorial = null;
         if(this._infectedBounty != null)
         {
            this._infectedBounty.completed.remove(this.onInfectedBountyComplete);
            this._infectedBounty = null;
         }
         this.suburbChanged.removeAll();
         this.neighborClicked.removeAll();
         this.ui_nodeInfo.dispose();
         this.ui_nodeInfo = null;
         this._rolloverTimer.stop();
         this._rolloverTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onRolloverTimerComplete);
         this._stage = null;
         this._missionList = null;
         this._areaNodes = null;
         this._areaNodeByLootType = null;
         this._suburbAreaById = null;
         this._suburbShapeById = null;
         this._suburbByShape = null;
         this._suburbById = null;
         this._suburbs = null;
         this._pins = null;
         this._pinsByNode = null;
         this._infectedBountyPins = null;
         this._assignmentPins = null;
         this._compoundNodesById = null;
         this._playerNode = null;
         this._hitAreas = null;
         this._highlightedData = null;
         this._suburbFillShapes = null;
         this._xml = null;
         this.mc_suburbs = null;
      }
      
      public function passSuburbsToStarlingMap(param1:MapStarlingLayer) : void
      {
         var _loc3_:Object = null;
         var _loc4_:DisplayObject = null;
         var _loc5_:Rectangle = null;
         var _loc6_:BitmapData = null;
         var _loc7_:Matrix = null;
         var _loc2_:Sprite = new Sprite();
         for each(_loc3_ in this._suburbFillShapes)
         {
            _loc4_ = _loc3_.fill;
            _loc4_.alpha = 0.3;
            _loc2_.addChild(_loc4_);
            _loc5_ = _loc2_.getRect(_loc2_);
            _loc6_ = new BitmapData(_loc5_.width,_loc5_.height,true,0);
            _loc7_ = new Matrix(1,0,0,1,-_loc5_.x,-_loc5_.y);
            _loc6_.draw(_loc2_,_loc7_);
            param1.addSuburbTexture(_loc6_,this.mc_suburbs.x + _loc3_.parent.x + _loc5_.x,this.mc_suburbs.y + _loc3_.parent.y + _loc5_.y);
            _loc2_.removeChild(_loc4_);
            _loc6_.dispose();
         }
      }
      
      public function hasNodeForPlayer(param1:String) : Boolean
      {
         return this._compoundNodesById[param1] != null;
      }
      
      public function getPlayerNode() : UIMissionAreaNode
      {
         return this._playerNode;
      }
      
      public function getOtherPlayerNode(param1:String) : UIMissionAreaNode
      {
         return this._compoundNodesById[param1];
      }
      
      public function updateElementScales(param1:Number) : void
      {
         var _loc3_:Sprite = null;
         var _loc4_:UIMapInfectedBountyPin = null;
         var _loc5_:UIMapAssignmentPin = null;
         var _loc2_:Number = 1 / param1;
         for each(_loc3_ in this._pins)
         {
            _loc3_.scaleX = _loc3_.scaleY = _loc2_;
         }
         for each(_loc4_ in this._infectedBountyPins)
         {
            _loc4_.scaleX = _loc4_.scaleY = _loc2_;
         }
         for each(_loc5_ in this._assignmentPins)
         {
            _loc5_.scaleX = _loc5_.scaleY = _loc2_;
         }
         if(Boolean(this.ui_nodeInfo) && this.ui_nodeInfo.scaleX != _loc2_)
         {
            this.ui_nodeInfo.scaleX = this.ui_nodeInfo.scaleY = _loc2_;
            if(this.ui_nodeInfo.parent)
            {
               this.ui_nodeInfo.parent.removeChild(this.ui_nodeInfo);
               this.updateNodeInfoPosition();
               this._highlightedData = null;
            }
         }
      }
      
      public function setFilter(param1:String) : void
      {
         var _loc2_:UIMissionAreaNode = null;
         var _loc3_:Vector.<UIMissionAreaNode> = null;
         if(this._currentFilter != null)
         {
            _loc3_ = this._areaNodeByLootType[this._currentFilter];
            if(_loc3_ != null)
            {
               for each(_loc2_ in _loc3_)
               {
                  _loc2_.showFilter(null);
               }
            }
         }
         if(param1 == null)
         {
            return;
         }
         this._currentFilter = param1;
         _loc3_ = this._areaNodeByLootType[this._currentFilter];
         if(_loc3_ != null)
         {
            for each(_loc2_ in _loc3_)
            {
               _loc2_.showFilter(this._currentFilter);
            }
         }
      }
      
      private function setupSuburbs() : void
      {
         var nodes:XMLList;
         var suburbData:SuburbData = null;
         var n:XML = null;
         var i:int = 0;
         var len:int = 0;
         var dobj:DisplayObject = null;
         var fill:DisplayObject = null;
         var maxLevel:int = int(Network.getInstance().playerData.getPlayerSurvivor().level);
         var t:* = ResourceManager.getInstance();
         var suburbSWF:Sprite = ResourceManager.getInstance().getResource("map/worldmap-suburbs.swf").content;
         var suburbShapeClass:Class = suburbSWF.loaderInfo.applicationDomain.getDefinition("MapSuburbShapes") as Class;
         this.mc_suburbs = new suburbShapeClass();
         this.mc_suburbs.x = int(this._xml.suburbs.@x);
         this.mc_suburbs.y = int(this._xml.suburbs.@y);
         addChild(this.mc_suburbs);
         nodes = this._xml.suburbs.children();
         for each(n in nodes)
         {
            suburbData = new SuburbData();
            suburbData.name = n.localName();
            suburbData.level = int(Config.xml.suburb_levels.param.(@id == suburbData.name)[0]);
            suburbData.locked = suburbData.level > maxLevel;
            this._suburbs.push(suburbData);
            this._suburbById[suburbData.name] = suburbData;
         }
         this._suburbFillShapes = new Vector.<Object>();
         i = 0;
         len = this.mc_suburbs.numChildren;
         while(i < len)
         {
            dobj = this.mc_suburbs.getChildAt(i);
            if(dobj is Sprite)
            {
               fill = Sprite(dobj).getChildByName("fill");
               if(fill)
               {
                  suburbData = this._suburbById[dobj.name];
                  if(suburbData)
                  {
                     this._suburbShapeById[dobj.name] = dobj;
                     this._suburbByShape[dobj] = suburbData;
                     if(suburbData.locked == false)
                     {
                        dobj.transform.colorTransform = this.CT_SUBURB_UNLOCKED;
                     }
                     dobj.alpha = this.SUBURB_ALPHA_OUT;
                     dobj.addEventListener(MouseEvent.ROLL_OVER,this.onSuburbRollOver,false,0,true);
                     dobj.addEventListener(MouseEvent.ROLL_OUT,this.onSuburbRollOut,false,0,true);
                  }
                  if(!suburbData || suburbData && suburbData.locked)
                  {
                     this._suburbFillShapes.push({
                        "parent":fill.parent,
                        "fill":fill,
                        "name":dobj.name
                     });
                  }
                  fill.parent.removeChild(fill);
               }
            }
            i++;
         }
      }
      
      private function onSuburbRollOver(param1:MouseEvent) : void
      {
         var _loc2_:DisplayObject = DisplayObject(param1.target);
         var _loc3_:SuburbData = this._suburbByShape[_loc2_];
         if(!_loc3_)
         {
            return;
         }
         this.suburbChanged.dispatch(_loc3_.name,_loc3_.level,_loc3_.locked);
         if(!_loc3_.locked)
         {
            _loc2_.alpha = this.SUBURB_ALPHA_OVER;
         }
      }
      
      private function onSuburbRollOut(param1:MouseEvent) : void
      {
         var _loc2_:DisplayObject = DisplayObject(param1.target);
         var _loc3_:SuburbData = this._suburbByShape[_loc2_];
         if(!_loc3_)
         {
            return;
         }
         if(!_loc3_.locked)
         {
            _loc2_.alpha = this.SUBURB_ALPHA_OUT;
         }
      }
      
      private function setupHitAreaGrid() : void
      {
         var _loc1_:XML = this._xml.size[0];
         var _loc2_:Number = int(_loc1_.@cols) * int(_loc1_.@width);
         var _loc3_:Number = int(_loc1_.@rows) * int(_loc1_.@height);
         this._hitAreaCols = Math.ceil(_loc2_ / this._hitAreaGridSize);
         this._hitAreaRows = Math.ceil(_loc3_ / this._hitAreaGridSize);
         var _loc4_:int = this._hitAreaRows * this._hitAreaCols;
         this._hitAreas = new Vector.<Vector.<UIMissionAreaNode>>();
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            this._hitAreas.push(new Vector.<UIMissionAreaNode>());
            _loc5_++;
         }
         this._hitAreas.fixed = true;
      }
      
      private function setupBounties() : void
      {
         var _loc2_:InfectedBountyTask = null;
         if(this._infectedBounty == null || !this._infectedBounty.isActive)
         {
            return;
         }
         var _loc1_:int = 0;
         while(_loc1_ < this._infectedBounty.numTasks)
         {
            _loc2_ = this._infectedBounty.getTask(_loc1_);
            if(!_loc2_.isCompleted)
            {
               this.addInfectedBountyPin(_loc2_);
            }
            _loc1_++;
         }
      }
      
      private function setupAreasNodes() : void
      {
         var node:XML = null;
         var raidId:String = null;
         var arenaId:String = null;
         var tl:Array = null;
         var br:Array = null;
         var tx:int = 0;
         var ty:int = 0;
         var tx2:int = 0;
         var ty2:int = 0;
         var areaNode:UIMissionAreaNode = null;
         var mission:MissionData = null;
         var nodeCenter:Point = null;
         var suburbData:SuburbData = null;
         var added:Boolean = false;
         var h:int = 0;
         var tlc:int = 0;
         var tlr:int = 0;
         var brc:int = 0;
         var brr:int = 0;
         var c:int = 0;
         var shape:DisplayObject = null;
         var _neighbors:Vector.<RemotePlayerData> = null;
         var neighbor:RemotePlayerData = null;
         var findNode:XML = null;
         var lootType:String = null;
         var areas:Vector.<UIMissionAreaNode> = null;
         var r:int = 0;
         var pos:int = 0;
         var zones:Array = null;
         var highActivityLevel:int = 0;
         var j:int = 0;
         var zoneIndex:int = 0;
         var hazNode:UIMissionAreaNode = null;
         var marker:UIHighActivityZoneMarker = null;
         var mod:int = 0;
         var list:XMLList = this._xml.areas.children();
         var neighborIndex:int = 0;
         var split:Array = String(Config.constant.HAZ_LEVEL_RANGES).split(",");
         var hazLevels:Array = [];
         var i:int = 0;
         while(i < split.length)
         {
            hazLevels[i] = int(split[i]);
            if(this._nodesByHazLevel.length < split.length)
            {
               this._nodesByHazLevel.push([]);
            }
            i++;
         }
         for each(node in this._xml.areas.children())
         {
            if(node.localName() == "raid")
            {
               raidId = String(node.@name.toString()).substr("raid".length + 1);
               this.addRaidPin(raidId,int(node.@x),int(node.@y));
            }
            else if(node.localName() == "arena")
            {
               arenaId = String(node.@name.toString()).substr("arena".length + 1);
               this.addArenaPin(arenaId,int(node.@x),int(node.@y));
            }
            else
            {
               tl = String(node.@tl).split(",");
               br = String(node.@br).split(",");
               tx = int(tl[0]);
               ty = int(tl[1]);
               tx2 = int(br[0]);
               ty2 = int(br[1]);
               areaNode = new UIMissionAreaNode(tx,ty,tx2 - tx,ty2 - ty);
               areaNode.type = node.localName();
               areaNode.name = node.@name.toString();
               mission = this._missionList.getLatestLockedMissionByAreaId(areaNode.name);
               if(mission != null)
               {
                  areaNode.mission = mission;
               }
               nodeCenter = new Point(tx + (tx2 - tx) * 0.5,ty + (ty2 - ty) * 0.5);
               for each(suburbData in this._suburbs)
               {
                  shape = this._suburbShapeById[suburbData.name];
                  if(shape)
                  {
                     if(shape.hitTestPoint(nodeCenter.x,nodeCenter.y,true))
                     {
                        areaNode.suburb = suburbData.name;
                        break;
                     }
                  }
               }
               if(!areaNode.suburb)
               {
                  TweenMax.to(areaNode,0,{"tint":16711680});
                  addChild(areaNode);
               }
               else
               {
                  switch(node.localName())
                  {
                     case "playerCompound":
                        this._playerNode = areaNode;
                        break;
                     case "compound":
                        _neighbors = RemotePlayerManager.getInstance().neighbors;
                        if(neighborIndex < _neighbors.length)
                        {
                           neighbor = _neighbors[neighborIndex++];
                           areaNode.neighbor = neighbor;
                           this.addPin(areaNode,neighbor);
                           break;
                        }
                        areaNode.mouseEnabled = false;
                        break;
                     default:
                        areaNode.level = this.calculateNodeLevel(areaNode);
                        for each(findNode in Config.xml.location_finds.param.(@type == areaNode.type).type)
                        {
                           lootType = findNode.toString();
                           areaNode.possibleFinds.push(lootType);
                           areas = this._areaNodeByLootType[lootType];
                           if(areas == null)
                           {
                              areas = this._areaNodeByLootType[lootType] = new Vector.<UIMissionAreaNode>();
                           }
                           areas.push(areaNode);
                        }
                  }
                  added = false;
                  h = 0;
                  while(h < hazLevels.length)
                  {
                     if(areaNode.level < hazLevels[h])
                     {
                        break;
                     }
                     if(h == hazLevels.length - 1 || areaNode.level < hazLevels[h + 1])
                     {
                        added = true;
                        this._nodesByHazLevel[h].push(areaNode);
                        break;
                     }
                     h++;
                  }
                  if(this._tutorial.active && areaNode.type.indexOf("tutorial") == 0)
                  {
                     this._tutorialNode = areaNode;
                  }
                  addChild(areaNode);
                  this._areaNodes.push(areaNode);
                  tlc = Math.floor(areaNode.rect.left / this._hitAreaGridSize);
                  tlr = Math.floor(areaNode.rect.top / this._hitAreaGridSize);
                  brc = Math.floor(areaNode.rect.right / this._hitAreaGridSize);
                  brr = Math.floor(areaNode.rect.bottom / this._hitAreaGridSize);
                  c = tlc;
                  while(c <= brc)
                  {
                     r = tlr;
                     while(r <= brr)
                     {
                        pos = r * this._hitAreaCols + c;
                        this._hitAreas[pos].push(areaNode);
                        r++;
                     }
                     c++;
                  }
               }
            }
         }
         if(Network.getInstance().playerData.getPlayerSurvivor().level >= int(Config.constant.HAZ_MIN_PLAYER_LEVEL))
         {
            zones = Network.getInstance().playerData.highActivityZones;
            highActivityLevel = Network.getInstance().playerData.getHighActivityAreaLevel();
            while(j < hazLevels.length)
            {
               if(!(zones[j] < 0 || this._nodesByHazLevel[j].length == 0))
               {
                  zoneIndex = int(zones[j]);
                  do
                  {
                     mod = zoneIndex % this._nodesByHazLevel[j].length;
                     hazNode = this._nodesByHazLevel[j][mod];
                     if(hazNode.type.indexOf("aicomp") == 0)
                     {
                        hazNode = null;
                        zoneIndex++;
                     }
                  }
                  while(hazNode == null);
                  
                  hazNode.highActivityIndex = j;
                  hazNode.level = highActivityLevel;
                  marker = new UIHighActivityZoneMarker(hazNode.width,hazNode.height);
                  marker.x = hazNode.x;
                  marker.y = hazNode.y;
                  addChild(marker);
                  this._highActivityMarkers.push(marker);
               }
               j++;
            }
         }
         if(this._playerNode != null)
         {
            this.addPlayerPin(this._playerNode);
         }
      }
      
      private function addPin(param1:UIMissionAreaNode, param2:RemotePlayerData) : void
      {
         var _loc3_:UIMapPin = new UIMapPin(param1,param2);
         _loc3_.x = int(param1.x + param1.width * 0.5);
         _loc3_.y = int(param1.y + param1.width * 0.5);
         this._pinLayer.addChild(_loc3_);
         this._pins.push(_loc3_);
         this._pinsByNode[param1] = _loc3_;
         this._compoundNodesById[param2.id] = param1;
      }
      
      private function addRaidPin(param1:String, param2:int, param3:int) : void
      {
         var _loc4_:UIMapRaidPin = new UIMapRaidPin(param1);
         _loc4_.clicked.add(this.onClickRaidPin);
         _loc4_.x = param2;
         _loc4_.y = param3;
         this._pinLayer.addChild(_loc4_);
         this._assignmentPins.push(_loc4_);
      }
      
      private function addArenaPin(param1:String, param2:int, param3:int) : void
      {
         var _loc4_:UIMapArenaPin = new UIMapArenaPin(param1);
         _loc4_.clicked.add(this.onClickArenaPin);
         _loc4_.x = param2;
         _loc4_.y = param3;
         this._pinLayer.addChild(_loc4_);
         this._assignmentPins.push(_loc4_);
      }
      
      private function onClickRaidPin(param1:MouseEvent) : void
      {
         var _loc4_:RaidDialogue = null;
         var _loc5_:RaidLaunchDialogue = null;
         var _loc2_:UIMapRaidPin = UIMapRaidPin(param1.currentTarget);
         var _loc3_:RaidData = Network.getInstance().playerData.assignments.getByName(_loc2_.id) as RaidData;
         if(_loc3_ != null)
         {
            _loc4_ = new RaidDialogue(_loc3_);
            _loc4_.open();
         }
         else
         {
            _loc5_ = new RaidLaunchDialogue(_loc2_.id);
            _loc5_.open();
         }
      }
      
      private function onClickArenaPin(param1:MouseEvent) : void
      {
         var _loc4_:ArenaDialogue = null;
         var _loc5_:ArenaLaunchDialogue = null;
         var _loc2_:UIMapArenaPin = UIMapArenaPin(param1.currentTarget);
         var _loc3_:ArenaSession = Network.getInstance().playerData.assignments.getByName(_loc2_.id) as ArenaSession;
         if(_loc3_ != null)
         {
            _loc4_ = new ArenaDialogue(_loc3_);
            _loc4_.open();
         }
         else
         {
            _loc5_ = new ArenaLaunchDialogue(_loc2_.id);
            _loc5_.open();
         }
      }
      
      private function addInfectedBountyPin(param1:InfectedBountyTask) : void
      {
         var _loc2_:DisplayObject = this._suburbShapeById[param1.suburb];
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:UIMapInfectedBountyPin = new UIMapInfectedBountyPin();
         _loc3_.task = param1;
         var _loc4_:Rectangle = _loc2_.getBounds(this._pinLayer);
         _loc3_.x = int(_loc4_.x + _loc4_.width * 0.5);
         _loc3_.y = int(_loc4_.y + _loc4_.height * 0.5);
         this._pinLayer.addChild(_loc3_);
         this._infectedBountyPins.push(_loc3_);
      }
      
      private function addPlayerPin(param1:UIMissionAreaNode) : void
      {
         var _loc2_:CompoundFlag = new CompoundFlag();
         _loc2_.x = int(param1.x + param1.width * 0.5);
         _loc2_.y = int(param1.y + param1.height * 0.5);
         _loc2_.mouseEnabled = _loc2_.mouseChildren = false;
         addChild(_loc2_);
      }
      
      private function calculateNodeLevel(param1:UIMissionAreaNode) : int
      {
         var suburbLevel:int = 0;
         var levelMod:Number = NaN;
         var levelModNode:XML = null;
         var node:UIMissionAreaNode = param1;
         suburbLevel = int(this._suburbById[node.suburb].level);
         levelMod = 0;
         levelModNode = Config.xml.location_levels.param.(@type == node.type)[0];
         if(levelModNode != null)
         {
            levelMod = Number(levelModNode.toString());
         }
         return Math.max(0,Math.round(suburbLevel + levelMod));
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         var _loc3_:Shape = null;
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         this._tutorial = Tutorial.getInstance();
         this._tutorial.stepChanged.add(this.onTutorialStepChanged);
         this._infectedBounty = Network.getInstance().playerData.infectedBounty;
         if(this._infectedBounty != null)
         {
            this._infectedBounty.completed.addOnce(this.onInfectedBountyComplete);
         }
         this.setupSuburbs();
         this._pinLayer = new Sprite();
         addChild(this._pinLayer);
         this.setupHitAreaGrid();
         this.setupAreasNodes();
         this.setupBounties();
         RemotePlayerManager.getInstance().updateNeighborStates();
         this._highlightShapes = new Vector.<Shape>();
         var _loc2_:int = 0;
         while(_loc2_ < 2)
         {
            _loc3_ = new Shape();
            addChildAt(_loc3_,getChildIndex(this._pinLayer));
            this._highlightShapes.push(_loc3_);
            _loc2_++;
         }
         this.ui_nodeInfo = new UIAreaNodeInfo();
         this._rolloverTimer = new Timer(150,1);
         this._rolloverTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onRolloverTimerComplete,false,0,true);
         this._stage = stage;
         this._stage.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,int.MAX_VALUE,true);
         this._stage.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp,false,int.MAX_VALUE,true);
         this._stage.addEventListener(Event.DEACTIVATE,this.onMouseUp,false,int.MAX_VALUE,true);
         this._stage.addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove,false,0,true);
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         if(!mouseEnabled)
         {
            return;
         }
         if(contains(DisplayObject(param1.target)) == false)
         {
            return;
         }
         this._mouseDownPoint = new Point(this._stage.mouseX,this._stage.mouseY);
         this._mouseDownData = this.getAreaDataAtPos(mouseX,mouseY);
      }
      
      private function onMouseUp(param1:Event) : void
      {
         var _loc2_:UIMissionAreaNode = null;
         if(mouseEnabled && Boolean(this._mouseDownData))
         {
            _loc2_ = this.getAreaDataAtPos(mouseX,mouseY);
            if(this._mouseDownData == _loc2_)
            {
               this.onMissionClicked(this._mouseDownData);
            }
         }
         this._mouseDownPoint = null;
         this._mouseDownData = null;
         this._isDragging = false;
      }
      
      private function onMouseMove(param1:MouseEvent) : void
      {
         var _loc2_:UIMissionAreaNode = null;
         var _loc3_:Shape = null;
         if(!this._isDragging && Boolean(this._mouseDownPoint))
         {
            if(Math.abs(this._mouseDownPoint.x - this._stage.mouseX) > 5 || Math.abs(this._mouseDownPoint.y - this._stage.mouseY) > 5)
            {
               this._isDragging = true;
               this._mouseDownData = null;
            }
         }
         if(!this._isDragging && mouseEnabled && param1.target && contains(DisplayObject(param1.target)))
         {
            _loc2_ = this.getAreaDataAtPos(mouseX,mouseY);
         }
         if(_loc2_ == this._highlightedData)
         {
            return;
         }
         if(this._highlightedData)
         {
            TweenMax.to(this._highlightShapes[this._highlightShapeIndex],0.5,{"autoAlpha":0});
            this._highlightedData = null;
            if(Boolean(this.ui_nodeInfo) && this.ui_nodeInfo.parent != null)
            {
               this.ui_nodeInfo.parent.removeChild(this.ui_nodeInfo);
            }
            this._rolloverTimer.stop();
         }
         if(_loc2_)
         {
            if(!_loc2_.mouseEnabled)
            {
               return;
            }
            this._highlightedData = _loc2_;
            if(_loc2_.highActivityIndex < 0)
            {
               ++this._highlightShapeIndex;
               if(this._highlightShapeIndex >= this._highlightShapes.length)
               {
                  this._highlightShapeIndex = 0;
               }
               _loc3_ = this._highlightShapes[this._highlightShapeIndex];
               TweenMax.killTweensOf(_loc3_);
               _loc3_.alpha = 1;
               _loc3_.visible = true;
               _loc3_.graphics.clear();
               _loc3_.graphics.beginFill(16777215,1);
               _loc3_.graphics.drawRect(0,0,this._highlightedData.rect.width + 4,this._highlightedData.rect.height + 4);
               _loc3_.graphics.drawRect(2,2,this._highlightedData.rect.width,this._highlightedData.rect.height);
               _loc3_.x = this._highlightedData.rect.x - 2;
               _loc3_.y = this._highlightedData.rect.y - 2;
            }
            this.ui_nodeInfo.areaNode = this._highlightedData;
            if(this._highlightedData.type != "playerCompound")
            {
               this._rolloverTimer.reset();
               this._rolloverTimer.start();
            }
         }
      }
      
      private function onRolloverTimerComplete(param1:TimerEvent) : void
      {
         this.updateNodeInfoPosition();
         addChild(this.ui_nodeInfo);
         Audio.sound.play("sound/interface/int-over.mp3");
      }
      
      private function onInfectedBountyComplete(param1:InfectedBounty) : void
      {
      }
      
      private function updateNodeInfoPosition() : void
      {
         if(stage == null || this._highlightedData == null)
         {
            return;
         }
         var _loc1_:int = this._highlightedData.x + this._highlightedData.width + 2;
         var _loc2_:int = this._highlightedData.y;
         var _loc3_:Point = new Point(_loc1_,_loc2_);
         _loc3_ = localToGlobal(_loc3_);
         var _loc4_:Boolean = true;
         var _loc5_:int = WorldMapView(parent)._viewportBounds.bottom - this.ui_nodeInfo.height - 10;
         var _loc6_:int = WorldMapView(parent)._viewportBounds.top + 10;
         if(_loc3_.y < _loc6_)
         {
            _loc2_ += this.ui_nodeInfo.areaNode.height + 2;
            _loc4_ = false;
         }
         else if(_loc3_.y > _loc5_)
         {
            _loc2_ -= this.ui_nodeInfo.height * this.ui_nodeInfo.scaleY + 2;
            _loc4_ = false;
         }
         var _loc7_:int = stage.stageWidth - this.ui_nodeInfo.width - 10;
         if(_loc3_.x > _loc7_)
         {
            if(!_loc4_)
            {
               _loc1_ = this._highlightedData.x + this._highlightedData.width - (this.ui_nodeInfo.width * this.ui_nodeInfo.scaleX + 2);
            }
            else
            {
               _loc1_ = this._highlightedData.x - this.ui_nodeInfo.width * this.ui_nodeInfo.scaleX - 2;
            }
         }
         else if(!_loc4_)
         {
            _loc1_ = this._highlightedData.x;
         }
         this.ui_nodeInfo.x = _loc1_;
         this.ui_nodeInfo.y = _loc2_;
      }
      
      private function onMissionClicked(param1:UIMissionAreaNode) : void
      {
         var _loc2_:* = false;
         var _loc3_:Point = null;
         var _loc4_:SuburbData = null;
         if(param1 == null || param1.locked || !param1.mouseEnabled)
         {
            return;
         }
         if(this._tutorial.active)
         {
            _loc2_ = param1.type.indexOf("tutorial") == 0;
            if(!_loc2_ || this._tutorial.stepNum < this._tutorial.getStepNum(Tutorial.STEP_GOTO_TUTORIAL_SCENE))
            {
               return;
            }
         }
         if(param1.neighbor != null)
         {
            _loc3_ = new Point(param1.x + param1.width,param1.y + param1.height * 0.5);
            _loc3_ = param1.parent.localToGlobal(_loc3_);
            this.neighborClicked.dispatch(param1.neighbor,_loc3_);
         }
         else
         {
            _loc4_ = this._suburbById[param1.suburb];
            if(_loc4_.locked)
            {
               return;
            }
            if(param1.type == "playerCompound")
            {
               this._selectedNode = this._playerNode;
               this.gotoNode(param1);
            }
            else
            {
               this.openMissionLoadout(param1);
            }
         }
      }
      
      private function openMissionLoadout(param1:UIMissionAreaNode) : void
      {
         var dlgMission:MissionLoadoutDialogue;
         var node:UIMissionAreaNode = param1;
         this._selectedNode = node;
         if(node.locked)
         {
            return;
         }
         dlgMission = new MissionLoadoutDialogue(this.getMissionData(node));
         dlgMission.launched.add(function(param1:MissionData):void
         {
            var data:MissionData = param1;
            data.startMission(function():void
            {
               Network.getInstance().playerData.missionList.addMission(data);
               if(data.automated)
               {
                  node.mission = data;
               }
               else
               {
                  gotoNode(node,data);
               }
            });
         });
         dlgMission.open();
      }
      
      private function gotoNode(param1:UIMissionAreaNode, param2:MissionData = null) : void
      {
         var _loc3_:String = null;
         switch(param1.type)
         {
            case "playerCompound":
               _loc3_ = NavigationLocation.PLAYER_COMPOUND;
               break;
            default:
               _loc3_ = NavigationLocation.MISSION;
         }
         if(_loc3_ == null)
         {
            return;
         }
         this._navigationTargetNode = param1;
         dispatchEvent(new NavigationEvent(NavigationEvent.REQUEST,_loc3_,param2));
      }
      
      private function getMissionData(param1:UIMissionAreaNode) : MissionData
      {
         var _loc2_:IOpponent = null;
         if(param1.type.indexOf("aicomp") == 0)
         {
            _loc2_ = new RaiderOpponentData(param1.level);
         }
         else
         {
            _loc2_ = new ZombieOpponentData(param1.level);
         }
         var _loc3_:MissionData = new MissionData();
         _loc3_.opponent = _loc2_;
         _loc3_.type = param1.type;
         _loc3_.suburb = param1.suburb;
         _loc3_.areaId = param1.name;
         _loc3_.highActivityIndex = param1.highActivityIndex;
         return _loc3_;
      }
      
      private function getAreaDataAtPos(param1:Number, param2:Number) : UIMissionAreaNode
      {
         var _loc4_:UIMissionAreaNode = null;
         var _loc3_:int = Math.floor(param2 / this._hitAreaGridSize) * this._hitAreaCols + Math.floor(param1 / this._hitAreaGridSize);
         if(_loc3_ < 0 || _loc3_ >= this._hitAreas.length)
         {
            return null;
         }
         for each(_loc4_ in this._hitAreas[_loc3_])
         {
            if(_loc4_.rect.contains(param1,param2))
            {
               return _loc4_;
            }
         }
         return null;
      }
      
      public function get selectedNode() : UIMissionAreaNode
      {
         return this._selectedNode;
      }
      
      private function onTutorialStepChanged() : void
      {
         if(this._tutorial.step == Tutorial.STEP_GOTO_TUTORIAL_SCENE)
         {
            this._tutorial.addArrow(this._tutorialNode,0,new Point(10,this._tutorialNode.height * 0.5));
         }
      }
   }
}

class SuburbData
{
   
   public var name:String;
   
   public var level:int;
   
   public var locked:Boolean;
   
   public function SuburbData()
   {
      super();
   }
}
