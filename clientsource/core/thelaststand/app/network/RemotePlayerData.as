package thelaststand.app.network
{
   import flash.utils.ByteArray;
   import flash.utils.Endian;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Config;
   import thelaststand.app.core.Global;
   import thelaststand.app.data.IOpponent;
   import thelaststand.app.data.NavigationLocation;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.events.NavigationEvent;
   import thelaststand.app.game.data.CompoundData;
   import thelaststand.app.game.data.Gear;
   import thelaststand.app.game.data.ItemFactory;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.Weapon;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.game.gui.dialogues.BountyCapReachedMessageBox;
   import thelaststand.app.game.gui.dialogues.BountyFriendAllianceMessageBox;
   import thelaststand.app.game.logic.DialogueController;
   import thelaststand.common.lang.Language;
   
   public class RemotePlayerData implements IOpponent
   {
      
      public static const RELATIONSHIP_FRIEND:String = "friend";
      
      public static const RELATIONSHIP_NEUTRAL:String = "neutral";
      
      public static const RELATIONSHIP_ENEMY:String = "enemy";
      
      public var onUpdate:Signal;
      
      internal var _battles:int;
      
      internal var _helps:int;
      
      internal var _visits:int;
      
      internal var _retaliation:int;
      
      internal var _compound:CompoundData;
      
      internal var _id:String;
      
      internal var _level:int;
      
      internal var _nickname:String;
      
      internal var _relationship:String;
      
      internal var _reputation:int;
      
      internal var _neighbor:Boolean;
      
      internal var _friend:Boolean;
      
      internal var _portraitURI:String;
      
      internal var _getPortraitURICallback:Function;
      
      internal var _loadingData:Boolean;
      
      internal var _serviceUserId:String;
      
      internal var _online:Boolean;
      
      internal var _underAttack:Boolean;
      
      internal var _protected:Boolean;
      
      internal var _lastLogin:Date;
      
      internal var _lastInteractionTime:Number = 0;
      
      internal var _researchEffects:Object;
      
      internal var _allianceId:String = "";
      
      internal var _allianceTag:String = "";
      
      internal var _allianceName:String = "";
      
      internal var _bounty:Number = 0;
      
      internal var _bountyEarnings:Number = 0;
      
      internal var _bountyCollectCount:int = 0;
      
      internal var _bountyDate:Number = 0;
      
      internal var _bountyAllTime:Number = 0;
      
      internal var _bountyAllTimeCount:int = 0;
      
      internal var _manualTimestamp:int = 0;
      
      internal var _summaryTimestamp:int = 0;
      
      internal var _stateTimestamp:int = 0;
      
      internal var _banned:Boolean = false;
      
      private var _imageURI:String;
      
      internal var _allianceMatchRequest:Boolean = false;
      
      public function RemotePlayerData(param1:String, param2:Object = null)
      {
         super();
         this.onUpdate = new Signal();
         this._id = param1;
         if(param2)
         {
            this.readObject(param2);
         }
      }
      
      public static function getAttackToolTip(param1:RemotePlayerData, param2:Boolean = false) : String
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         if(param1 == null)
         {
            return "";
         }
         var _loc3_:Language = Language.getInstance();
         if(Network.getInstance().playerData.id == param1.id)
         {
            return _loc3_.getString("map_list_btn_attack_yourself");
         }
         if(Network.getInstance().shutdownMissionsLocked)
         {
            return _loc3_.getString("map_list_btn_attack_shutdownLock");
         }
         if(param1.isBanned)
         {
            return _loc3_.getString("map_list_btn_attack_banned");
         }
         if(param2)
         {
            if(param1.isFriend || param1.isSameAlliance)
            {
               return _loc3_.getString("map_list_btn_attack_friendAlliance");
            }
            if(Network.getInstance().playerData.bountyCap == 0)
            {
               return _loc3_.getString("map_list_btn_attack_bountyCap");
            }
            _loc5_ = param1.bountyDate + Config.constant.BOUNTY_LIFESPAN_DAYS * (24 * 60 * 60 * 1000) - Network.getInstance().serverTime;
            if(_loc5_ < 0)
            {
               return _loc3_.getString("map_list_btn_attack_bountyExpire",param1.nickname);
            }
         }
         if(Network.getInstance().playerData.compound.effects.hasEffectType(EffectType.getTypeValue("DisablePvP")))
         {
            return _loc3_.getString("map_list_btn_attack_whiteflag");
         }
         if(param1.online)
         {
            return _loc3_.getString("map_list_btn_attack_online",param1.nickname);
         }
         if(param1.isProtected)
         {
            return _loc3_.getString("map_list_btn_attack_protected",param1.nickname);
         }
         if(!param1.isFriend && !param1.isWithinAttackLevel() && param1._retaliation <= 0)
         {
            if(param1.attackLevelDifference() < 0)
            {
               return _loc3_.getString(param1.retaliationPts <= 0 ? "map_list_btn_attack_noretaliate" : "map_list_btn_attack_leveltoolow",param1.nickname);
            }
            return _loc3_.getString("map_list_btn_attack_leveltoohigh",param1.nickname);
         }
         if(Network.getInstance().playerData.missionList.hasUncompletedPvPMissionAgainstPlayer(param1.id))
         {
            return _loc3_.getString("map_list_btn_attack_lockout",param1.nickname);
         }
         if(Network.getInstance().playerData.recentPVPs.hasOwnProperty(param1.id))
         {
            _loc6_ = Network.getInstance().playerData.isAdmin ? 2 : Number(Config.constant.RECENT_ATTACK_MIN_MINUTES);
            if(Network.getInstance().serverTime < Number(Network.getInstance().playerData.recentPVPs[param1.id]) + _loc6_ * 60000)
            {
               return _loc3_.getString("map_list_btn_attack_recentPVPTooSoon",param1.nickname);
            }
         }
         var _loc4_:AllianceSystem = AllianceSystem.getInstance();
         if(_loc4_.inAlliance && _loc4_.isRoundActive && _loc4_.hasScoutingProtection(param1.id))
         {
            return _loc3_.getString("map_list_btn_attack_allianceScouted",_loc4_.getScoutingData(param1.id).user);
         }
         return _loc3_.getString("map_list_btn_attack_desc",param1.nickname);
      }
      
      public function get battles() : int
      {
         return this._battles;
      }
      
      public function get retaliationPts() : int
      {
         return this._retaliation;
      }
      
      public function get lastInteractionTime() : Number
      {
         return this._lastInteractionTime;
      }
      
      public function get compound() : CompoundData
      {
         return this._compound;
      }
      
      public function set compound(param1:CompoundData) : void
      {
         if(!this._compound)
         {
            this._compound = new CompoundData();
         }
         this._compound = param1;
      }
      
      public function get reputation() : int
      {
         return this._reputation;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get level() : int
      {
         return this._level;
      }
      
      public function get nickname() : String
      {
         return this._nickname;
      }
      
      public function get relationship() : String
      {
         return this._relationship;
      }
      
      public function get online() : Boolean
      {
         return this._online;
      }
      
      public function get underAttack() : Boolean
      {
         return this._underAttack;
      }
      
      public function get isProtected() : Boolean
      {
         return this._protected;
      }
      
      public function get isPlayer() : Boolean
      {
         return true;
      }
      
      public function get isFriend() : Boolean
      {
         return this._friend;
      }
      
      public function set isFriend(param1:Boolean) : void
      {
         this._friend = param1;
      }
      
      public function get isNeighbor() : Boolean
      {
         return this._neighbor;
      }
      
      public function get allianceId() : String
      {
         return this._allianceId;
      }
      
      public function get allianceTag() : String
      {
         return this._allianceTag;
      }
      
      public function get allianceName() : String
      {
         return this._allianceName;
      }
      
      public function get isSameAlliance() : Boolean
      {
         return this._allianceId != "" && this._allianceId != null && this._allianceId == Network.getInstance().playerData.allianceId;
      }
      
      public function get bounty() : Number
      {
         return this._bounty;
      }
      
      public function get bountyAllTime() : Number
      {
         return this._bountyAllTime;
      }
      
      public function get bountyEarnings() : Number
      {
         return this._bountyEarnings;
      }
      
      public function get bountyCollectCount() : Number
      {
         return this._bountyCollectCount;
      }
      
      public function get bountyAllTimeCount() : Number
      {
         return this._bountyAllTimeCount;
      }
      
      public function get bountyDate() : Number
      {
         return this._bountyDate;
      }
      
      public function get lastLogin() : Date
      {
         return this._lastLogin;
      }
      
      public function get isBanned() : Boolean
      {
         return this._banned;
      }
      
      public function get imageURI() : String
      {
         return this._imageURI;
      }
      
      public function get researchEffects() : Object
      {
         return this._researchEffects;
      }
      
      public function set researchEffects(param1:Object) : void
      {
         this._researchEffects = param1;
      }
      
      public function set allianceMatchRequested(param1:Boolean) : void
      {
         this._allianceMatchRequest = param1;
      }
      
      public function get allianceMatchRequested() : Boolean
      {
         return this._allianceMatchRequest;
      }
      
      public function canAttack() : Boolean
      {
         var _loc2_:PlayerData = null;
         var _loc3_:AllianceSystem = null;
         var _loc4_:Number = NaN;
         if(Network.getInstance().playerData.id == this._id)
         {
            return false;
         }
         if(Network.getInstance().shutdownMissionsLocked)
         {
            return false;
         }
         if(this.isBanned)
         {
            return false;
         }
         var _loc1_:Boolean = !this._protected && !this._online && (this.isFriend || this.isWithinAttackLevel());
         if(_loc1_)
         {
            _loc2_ = Network.getInstance().playerData;
            if(_loc2_.missionList.hasUncompletedPvPMissionAgainstPlayer(this._id))
            {
               return false;
            }
            if(_loc2_.compound.effects.hasEffectType(EffectType.getTypeValue("DisablePvP")))
            {
               return false;
            }
            if(_loc2_.recentPVPs.hasOwnProperty(this._id))
            {
               _loc4_ = _loc2_.isAdmin ? 2 : Number(Config.constant.RECENT_ATTACK_MIN_MINUTES);
               if(Network.getInstance().serverTime < Number(_loc2_.recentPVPs[this._id]) + _loc4_ * 60000)
               {
                  return false;
               }
            }
            _loc3_ = AllianceSystem.getInstance();
            if(_loc3_.inAlliance && _loc3_.isRoundActive && _loc3_.hasScoutingProtection(this.id))
            {
               return false;
            }
         }
         return _loc1_;
      }
      
      public function attackLevelDifference() : int
      {
         return this.level - Network.getInstance().playerData.getPlayerSurvivor().level;
      }
      
      public function isWithinAttackLevel() : Boolean
      {
         var _loc5_:int = 0;
         var _loc1_:PlayerData = Network.getInstance().playerData;
         var _loc2_:int = int(_loc1_.getPlayerSurvivor().level);
         var _loc3_:int = this.level - _loc2_;
         var _loc4_:int = int(Config.constant.MIN_PLAYER_ATTACK_LEVEL);
         if(this.isSameAlliance == false && _loc1_.bountyCap > 0 && this._bounty > 0 && this._bountyDate + int(Config.constant.BOUNTY_LIFESPAN_DAYS) * 24 * 60 * 60 * 1000 > Network.getInstance().serverTime)
         {
            if(Config.constant.MIN_PLAYER_ATTACK_LEVEL_BOUNTY < _loc4_)
            {
               _loc4_ = int(Config.constant.MIN_PLAYER_ATTACK_LEVEL_BOUNTY);
            }
         }
         if(AllianceSystem.getInstance().inAlliance && AllianceSystem.getInstance().isRoundActive && _loc1_.allianceId != this.allianceId)
         {
            _loc5_ = int(Config.constant.MIN_PLAYER_ATTACK_LEVEL_ALLIANCE);
            if(_loc5_ < _loc4_)
            {
               _loc4_ = _loc5_;
            }
         }
         if(this._retaliation > 0 && Config.constant.MIN_PLAYER_ATTACK_LEVEL_RETALIATION < _loc4_)
         {
            _loc4_ = int(Config.constant.MIN_PLAYER_ATTACK_LEVEL_RETALIATION);
         }
         if(_loc3_ < _loc4_ || _loc3_ > Config.constant.MAX_PLAYER_ATTACK_LEVEL)
         {
            return false;
         }
         return true;
      }
      
      public function getResearchEffectValue(param1:String) : Number
      {
         if(this._researchEffects == null)
         {
            return 0;
         }
         var _loc2_:Number = Number(this._researchEffects[param1]);
         return isNaN(_loc2_) ? 0 : _loc2_;
      }
      
      public function getPortraitURI() : String
      {
         if(this._portraitURI != null)
         {
            return this._portraitURI;
         }
         var _loc1_:String = String(this._id);
         if(_loc1_.substr(0,2) == PlayerIOConnector.SERVICE_FACEBOOK)
         {
            this._portraitURI = "https://graph.facebook.com/" + _loc1_.substr(2) + "/picture";
         }
         else if(_loc1_.substr(0,5) == PlayerIOConnector.SERVICE_ARMOR_GAMES)
         {
            this._portraitURI = "http://armatars.armorgames.com/armatar_426_50.50_c.png";
         }
         else if(_loc1_.substr(0,4) == PlayerIOConnector.SERVICE_KONGREGATE)
         {
            this._portraitURI = "images/ui/kongregate-avatar.jpg";
         }
         return this._portraitURI;
      }
      
      public function incrementBattles() : void
      {
         ++this._battles;
         this.updateRelationship();
      }
      
      public function incrementHelp() : void
      {
         ++this._helps;
         this.updateRelationship();
      }
      
      public function loadoutSurvivors(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:Object = null;
         var _loc4_:Survivor = null;
         for(_loc2_ in param1)
         {
            _loc3_ = param1[_loc2_];
            _loc4_ = this.compound.survivors.getSurvivorById(_loc2_);
            if(_loc4_ != null)
            {
               if(_loc3_.weapon != null)
               {
                  _loc4_.loadoutDefence.weapon.item = ItemFactory.createItemFromObject(_loc3_.weapon) as Weapon;
               }
               if(_loc3_.gear1 != null)
               {
                  _loc4_.loadoutDefence.gearPassive.item = ItemFactory.createItemFromObject(_loc3_.gear1) as Gear;
               }
            }
         }
      }
      
      public function writeObject(param1:Object = null) : Object
      {
         return param1 || {};
      }
      
      public function readObject(param1:Object) : void
      {
         var _loc2_:Date = null;
         var _loc3_:Date = null;
         var _loc4_:Date = null;
         var _loc5_:Date = null;
         var _loc6_:Boolean = false;
         var _loc7_:Date = null;
         var _loc8_:Date = null;
         var _loc9_:Date = null;
         if(param1 == null)
         {
            return;
         }
         if(param1.name)
         {
            this._nickname = param1.name;
         }
         if(!this._nickname && Boolean(param1.nickname))
         {
            this._nickname = param1.nickname;
         }
         if(param1.level)
         {
            this._level = int(param1.level);
         }
         if(param1.serviceUserId)
         {
            this._serviceUserId = param1.serviceUserId;
         }
         if(param1.serviceAvatar)
         {
            this._portraitURI = param1.serviceAvatar;
         }
         if(param1.serviceAvatarURL)
         {
            this._portraitURI = param1.serviceAvatarURL;
         }
         if(param1.lastLogin)
         {
            this._lastLogin = param1.lastLogin;
         }
         if(param1.allianceId)
         {
            this._allianceId = param1.allianceId;
         }
         if(param1.allianceTag)
         {
            this._allianceTag = param1.allianceTag;
         }
         if(param1.allianceName)
         {
            this._allianceName = param1.allianceName;
         }
         if(param1.bounty)
         {
            this._bounty = param1.bounty;
         }
         if(param1.bountyAllTime)
         {
            this._bountyAllTime = param1.bountyAllTime;
         }
         if(param1.bountyAllTimeCount)
         {
            this._bountyAllTimeCount = param1.bountyAllTimeCount;
         }
         if(param1.bountyEarnings)
         {
            this._bountyEarnings = param1.bountyEarnings;
         }
         if(param1.bountyCollectCount)
         {
            this._bountyCollectCount = param1.bountyCollectCount;
         }
         if(param1.bountyDate)
         {
            this._bountyDate = param1.bountyDate;
         }
         if(param1.hasOwnProperty("online"))
         {
            this._online = Boolean(param1.online);
            if(this._online)
            {
               _loc2_ = new Date(Network.getInstance().serverTime);
               --_loc2_.date;
               _loc3_ = param1.hasOwnProperty("onlineTimestamp") ? param1.onlineTimestamp : new Date(2000,1,1);
               if(_loc2_ > _loc3_)
               {
                  this._online = false;
               }
            }
         }
         if(param1.hasOwnProperty("raidLockout"))
         {
            _loc4_ = new Date(Network.getInstance().serverTime);
            _loc5_ = new Date(param1.raidLockout);
            if(_loc5_.time > _loc4_.time)
            {
               this._online = true;
            }
         }
         if(param1.hasOwnProperty("underAttack"))
         {
            this._underAttack = Boolean(param1.underAttack);
         }
         if(param1.hasOwnProperty("protected"))
         {
            _loc6_ = Boolean(param1["protected"]);
            if((_loc6_) && param1.protected_start != null)
            {
               _loc7_ = new Date(Network.getInstance().serverTime);
               _loc8_ = new Date(param1.protected_start);
               _loc9_ = new Date(_loc8_.time + int(param1.protected_length) * 1000);
               if(_loc8_.fullYear > 2000 && _loc9_.time <= _loc7_.time)
               {
                  _loc6_ = false;
               }
            }
            this._protected = _loc6_;
         }
         if(param1.hasOwnProperty("banned"))
         {
            this._banned = Boolean(param1.banned);
         }
         this.onUpdate.dispatch();
      }
      
      public function updateHistory(param1:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         param1.endian = Endian.LITTLE_ENDIAN;
         param1.position = 0;
         this._battles = int(param1.readUnsignedShort());
         this._helps = int(param1.readUnsignedShort());
         this._visits = int(param1.readUnsignedShort());
         this._retaliation = param1.length >= 10 ? int(param1.readUnsignedShort()) : 0;
         if(param1.length > 10)
         {
            _loc2_ = param1.readByte();
            _loc3_ = param1.readByte();
            _loc4_ = param1.readByte();
            this._lastInteractionTime = new Date(2000 + _loc4_,_loc3_ - 1,_loc2_).time;
         }
         this.updateRelationship();
      }
      
      public function toString() : String
      {
         return "[RemotePlayerData " + this._nickname + "(" + this._level + ") " + this._id + " - bounty:" + Math.floor(this._bounty) + " earn:" + Math.floor(this._bountyEarnings) + "]";
      }
      
      public function attemptAttack(param1:Boolean, param2:Function = null) : void
      {
         var bountyFriendMsg:BountyFriendAllianceMessageBox = null;
         var bountyCapMsg:BountyCapReachedMessageBox = null;
         var attemptAllianceMatch:Boolean = param1;
         var callback:Function = param2;
         var player:PlayerData = Network.getInstance().playerData;
         var slotProtection:Number = player.compound.effects.getValue(EffectType.getTypeValue("DisablePvP"));
         if(slotProtection > 0)
         {
            if(callback != null)
            {
               callback(false);
            }
            return;
         }
         this._allianceMatchRequest = attemptAllianceMatch;
         if(this.bounty > 0 && this.bountyDate + Config.constant.BOUNTY_LIFESPAN_DAYS * (24 * 60 * 60 * 1000) > Network.getInstance().serverTime)
         {
            if(this.isFriend || this.isSameAlliance)
            {
               bountyFriendMsg = new BountyFriendAllianceMessageBox();
               bountyFriendMsg.onAccept.add(function():void
               {
                  checkForGlobalProtection(callback);
                  bountyFriendMsg.close();
               });
               bountyFriendMsg.open();
            }
            else if(player.bountyCap == 0)
            {
               bountyCapMsg = new BountyCapReachedMessageBox();
               bountyCapMsg.onAccept.add(function():void
               {
                  checkForGlobalProtection(callback);
                  bountyCapMsg.close();
               });
               bountyCapMsg.open();
            }
            else
            {
               this.checkForGlobalProtection(callback);
            }
         }
         else
         {
            this.checkForGlobalProtection(callback);
         }
      }
      
      private function checkForGlobalProtection(param1:Function) : void
      {
         var self:RemotePlayerData = null;
         var callback:Function = param1;
         var playerData:PlayerData = Network.getInstance().playerData;
         var globalProtection:Number = Network.getInstance().playerData.compound.globalEffects.getValue(EffectType.getTypeValue("DisablePvP"));
         if(globalProtection > 0)
         {
            self = this;
            DialogueController.getInstance().openLoseProtectionWarning(function():void
            {
               Global.stage.dispatchEvent(new NavigationEvent(NavigationEvent.REQUEST,NavigationLocation.MISSION_PLANNING,self));
               if(callback != null)
               {
                  callback(true);
               }
            });
         }
         else
         {
            Global.stage.dispatchEvent(new NavigationEvent(NavigationEvent.REQUEST,NavigationLocation.MISSION_PLANNING,this));
            if(callback != null)
            {
               callback(true);
            }
         }
      }
      
      private function updateRelationship() : void
      {
         var _loc1_:String = this._relationship;
         if(this._battles > 0 && this._battles > this._helps)
         {
            this._relationship = RELATIONSHIP_ENEMY;
         }
         else if(this._helps > 0 && this._helps > this._battles)
         {
            this._relationship = RELATIONSHIP_FRIEND;
         }
         else
         {
            this._relationship = RELATIONSHIP_NEUTRAL;
         }
         if(_loc1_ != this._relationship)
         {
            this.onUpdate.dispatch();
         }
      }
   }
}

