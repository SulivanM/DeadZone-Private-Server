package thelaststand.app.game.logic.bounty
{
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   import playerio.Client;
   import playerio.DatabaseObject;
   import playerio.PlayerIOError;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.RemotePlayerData;
   import thelaststand.app.network.RemotePlayerManager;
   
   public class BountyListLogic
   {
      
      public static const BY_BOUNTY:String = "BountiesByBounty";
      
      public static const BY_EXPIRE:String = "BountiesByExpiration";
      
      public static const BY_LEVEL:String = "BountiesByLevel";
      
      public static const BEST_BOUNTY_HUNTERS:String = "BestBountyHunters";
      
      public static const ALL_TIME_BOUNTIES:String = "BountiesByAllTime";
      
      private var recordsPerPage:int;
      
      private var _client:Client;
      
      private var _network:Network;
      
      private var playerDict:Dictionary;
      
      private var listsById:Dictionary;
      
      private var _currentLookupId:uint = 0;
      
      public var onPageReady:Signal;
      
      public function BountyListLogic(param1:int = 5)
      {
         super();
         this.recordsPerPage = param1;
         this._network = Network.getInstance();
         this._client = this._network.client;
         this.onPageReady = new Signal(Vector.<RemotePlayerData>,int);
         this.playerDict = new Dictionary(true);
         this.listsById = new Dictionary(true);
         this.listsById[BY_BOUNTY] = new BountyList(BY_BOUNTY);
         this.listsById[BY_BOUNTY].sortKey = "bounty";
         this.listsById[BY_EXPIRE] = new BountyList(BY_EXPIRE);
         this.listsById[BY_EXPIRE].sortKey = "bountyDate";
         this.listsById[BY_EXPIRE].sortDecending = false;
         this.listsById[BY_LEVEL] = new BountyList(BY_LEVEL);
         this.listsById[BY_LEVEL].sortKey = "level";
         this.listsById[BEST_BOUNTY_HUNTERS] = new BountyList(BEST_BOUNTY_HUNTERS);
         this.listsById[BEST_BOUNTY_HUNTERS].sortKey = "bountyEarnings";
         this.listsById[ALL_TIME_BOUNTIES] = new BountyList(ALL_TIME_BOUNTIES);
         this.listsById[ALL_TIME_BOUNTIES].sortKey = "bountyAllTime";
      }
      
      public function dispose() : void
      {
         this.playerDict = null;
         this.listsById = null;
         this._client = null;
         this._network = null;
      }
      
      public function getPage(param1:String, param2:int) : void
      {
         if(this._currentLookupId == uint.MAX_VALUE)
         {
            this._currentLookupId = 0;
         }
         ++this._currentLookupId;
         var _loc3_:BountyList = this.listsById[param1];
         if(!_loc3_)
         {
            this.onPageReady.dispatch(new Vector.<RemotePlayerData>(),-1);
            return;
         }
         this.attemptReturnFromCurrentList(_loc3_,param2,this._currentLookupId);
      }
      
      private function attemptReturnFromCurrentList(param1:BountyList, param2:int, param3:uint) : void
      {
         var returnList:Vector.<RemotePlayerData> = null;
         var len:int = 0;
         var i:int = 0;
         var list:BountyList = param1;
         var pageNum:int = param2;
         var lookupId:uint = param3;
         if(list.dirty)
         {
            list.sort();
         }
         if(pageNum > list.finalPageNum)
         {
            pageNum = list.finalPageNum;
         }
         if(pageNum < 0)
         {
            pageNum = 0;
         }
         if(list.highestPageCollected >= pageNum)
         {
            returnList = new Vector.<RemotePlayerData>();
            len = Math.min((pageNum + 1) * this.recordsPerPage,list.list.length);
            if(pageNum * this.recordsPerPage < 0 || len < 0)
            {
            }
            i = pageNum * this.recordsPerPage;
            while(i < len)
            {
               returnList.push(list.list[i]);
               i++;
            }
            this.onPageReady.dispatch(returnList,list.finalPageNum);
            return;
         }
         this._client.bigDB.loadRange("PlayerSummary",list.category,null,list.highestPageKeyValue,null,this.recordsPerPage + 3,function(param1:Array):void
         {
            processGatheredItems(list,pageNum,lookupId,param1);
         },function(param1:PlayerIOError):void
         {
            processGatheredItems(list,pageNum,lookupId,[]);
         });
      }
      
      private function processGatheredItems(param1:BountyList, param2:int, param3:uint, param4:Array) : void
      {
         var record:RemotePlayerData = null;
         var dobj:DatabaseObject = null;
         var otherList:BountyList = null;
         var list:BountyList = param1;
         var pageNum:int = param2;
         var lookupId:uint = param3;
         var items:Array = param4;
         var itemAdded:Boolean = false;
         var collectionList:Array = [];
         for each(dobj in items)
         {
            record = this.playerDict[dobj.key];
            collectionList.push(dobj.key);
            if(!record)
            {
               record = RemotePlayerManager.getInstance().getPlayer(dobj.key);
            }
            if(record)
            {
               record.readObject(dobj);
               if(list.list.indexOf(record) == -1)
               {
                  itemAdded = true;
                  list.list.push(record);
               }
               list.dirty = true;
               for each(otherList in this.listsById)
               {
                  if(!otherList.dirty)
                  {
                     if(otherList.list.indexOf(record) > -1)
                     {
                        otherList.dirty = true;
                     }
                  }
               }
            }
            else
            {
               record = RemotePlayerManager.getInstance().updatePlayer(dobj.key,dobj);
               list.list.push(record);
               this.playerDict[record.id] = record;
               itemAdded = true;
            }
         }
         RemotePlayerManager.getInstance().getLoadPlayers(collectionList,function(param1:Vector.<RemotePlayerData>):void
         {
         },RemotePlayerManager.STATE);
         list.highestPageCollected = pageNum;
         if(record)
         {
            list.highestPageKeyValue = record[list.sortKey];
         }
         if(items.length < this.recordsPerPage && pageNum < list.finalPageNum)
         {
            list.finalPageNum = Math.floor(list.list.length / this.recordsPerPage);
         }
         if(lookupId == this._currentLookupId)
         {
            this.attemptReturnFromCurrentList(list,pageNum,lookupId);
         }
      }
   }
}

import thelaststand.app.network.RemotePlayerData;

class BountyList
{
   
   public var category:String;
   
   public var sortKey:String;
   
   public var highestPageCollected:int = -1;
   
   public var highestPageKeyValue:Object = null;
   
   public var finalPageNum:int = 2147483647;
   
   public var list:Vector.<RemotePlayerData> = new Vector.<RemotePlayerData>();
   
   public var dirty:Boolean;
   
   public var sortDecending:Boolean = true;
   
   private var sortResult:Number;
   
   public function BountyList(param1:String)
   {
      super();
      this.category = param1;
   }
   
   public function sort() : void
   {
      if(this.sortMethod != null)
      {
         this.list.sort(this.sortMethod);
      }
      this.dirty = false;
   }
   
   private function sortMethod(param1:RemotePlayerData, param2:RemotePlayerData) : Number
   {
      this.sortResult = 0;
      if(param1[this.sortKey] > param2[this.sortKey])
      {
         this.sortResult = -1;
      }
      else if(param1[this.sortKey] < param2[this.sortKey])
      {
         this.sortResult = 1;
      }
      return this.sortDecending ? Number(this.sortResult) : -this.sortResult;
   }
}
