package com.adobe.protocols.dict
{
   import com.adobe.protocols.dict.events.*;
   import com.adobe.protocols.dict.util.*;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import mx.rpc.events.FaultEvent;
   import mx.rpc.events.ResultEvent;
   import mx.rpc.http.HTTPService;
   import mx.utils.StringUtil;
   
   public class Dict extends EventDispatcher
   {
      
      public static var CONNECTED:String = "connected";
      
      public static var DISCONNECTED:String = "disconnected";
      
      public static var IO_ERROR:String = IOErrorEvent.IO_ERROR;
      
      public static var ERROR:String = "error";
      
      public static var SERVERS:String = "servers";
      
      public static var DATABASES:String = "databases";
      
      public static var MATCH_STRATEGIES:String = "matchStrategies";
      
      public static var DEFINITION:String = "definition";
      
      public static var DEFINITION_HEADER:String = "definitionHeader";
      
      public static var MATCH:String = "match";
      
      public static var NO_MATCH:String = "noMatch";
      
      public static var FIRST_MATCH:uint = 0;
      
      public static var ALL_DATABASES:uint = 1;
      
      private var socket:SocketHelper;
      
      private var dbShortList:Boolean;
      
      public function Dict()
      {
         super();
         this.socket = new SocketHelper();
         this.socket.addEventListener(Event.CONNECT,this.connected);
         this.socket.addEventListener(Event.CLOSE,this.disconnected);
         this.socket.addEventListener(SocketHelper.COMPLETE_RESPONSE,this.incomingData);
         this.socket.addEventListener(IOErrorEvent.IO_ERROR,this.ioError);
         this.socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.securityError);
      }
      
      public function connect(param1:String, param2:uint = 2628) : void
      {
         if(this.socket.connected)
         {
            this.socket.close();
         }
         this.socket.connect(param1,param2);
      }
      
      public function connectThroughProxy(param1:String, param2:int, param3:String, param4:uint = 2628) : void
      {
         if(this.socket.connected)
         {
            this.socket.close();
         }
         this.socket.setProxyInfo(param1,param2);
         this.socket.connect(param3,param4);
      }
      
      public function disconnect() : void
      {
         this.socket.close();
         this.disconnected(null);
      }
      
      public function getServers() : void
      {
         var _loc1_:HTTPService = new HTTPService();
         _loc1_.url = "http://luetzschena-stahmeln.de/dictd/xmllist.php";
         _loc1_.addEventListener(ResultEvent.RESULT,this.incomingServerXML);
         _loc1_.addEventListener(FaultEvent.FAULT,this.httpError);
         _loc1_.resultFormat = HTTPService.RESULT_FORMAT_E4X;
         _loc1_.send();
      }
      
      public function getDatabases(param1:Boolean = true) : void
      {
         this.dbShortList = param1;
         this.socket.writeUTFBytes("show db\r\n");
         this.socket.flush();
      }
      
      public function getMatchStrategies() : void
      {
         this.socket.writeUTFBytes("show strat\r\n");
         this.socket.flush();
      }
      
      public function match(param1:String, param2:String, param3:String = "prefix") : void
      {
         this.socket.writeUTFBytes("match " + param1 + " " + param3 + " \"" + param2 + "\"\r\n");
         this.socket.flush();
      }
      
      public function define(param1:String, param2:String) : void
      {
         this.socket.writeUTFBytes("define " + param1 + " \"" + param2 + "\"\r\n");
         this.socket.flush();
      }
      
      public function lookup(param1:String, param2:uint) : void
      {
         var _loc3_:String = null;
         if(param2 == Dict.ALL_DATABASES)
         {
            _loc3_ = "*";
         }
         else if(param2 == Dict.FIRST_MATCH)
         {
            _loc3_ = "!";
         }
         this.socket.writeUTFBytes("define " + _loc3_ + " \"" + param1 + "\"\r\n");
         this.socket.flush();
      }
      
      private function connected(param1:Event) : void
      {
      }
      
      private function disconnected(param1:Event) : void
      {
         dispatchEvent(new DisconnectedEvent());
      }
      
      private function incomingServerXML(param1:ResultEvent) : void
      {
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc7_:XML = null;
         var _loc8_:DictionaryServerEvent = null;
         var _loc9_:DictionaryServer = null;
         var _loc2_:Namespace = new Namespace("http://www.luetzschena-stahmeln.de/dictd/");
         var _loc3_:XML = param1.result as XML;
         var _loc6_:Array = new Array();
         for each(_loc7_ in _loc3_._loc2_::server)
         {
            _loc4_ = _loc7_._loc2_::dictdurl;
            _loc5_ = _loc7_._loc2_::description;
            if(StringUtil.trim(_loc4_).length != 0 && StringUtil.trim(_loc5_).length != 0)
            {
               _loc9_ = new DictionaryServer();
               _loc9_.server = _loc4_.replace("dict://","");
               _loc9_.description = _loc5_;
               _loc6_.push(_loc9_);
            }
         }
         _loc8_ = new DictionaryServerEvent();
         _loc8_.servers = _loc6_;
         dispatchEvent(_loc8_);
      }
      
      private function incomingData(param1:CompleteResponseEvent) : void
      {
         var _loc2_:String = param1.response;
         var _loc3_:Response = this.parseRawResponse(_loc2_);
         var _loc4_:uint = _loc3_.code;
         if(_loc4_ == 552)
         {
            this.throwNoMatchEvent(_loc3_);
         }
         else if(_loc4_ >= 400 && _loc4_ <= 599)
         {
            this.throwErrorEvent(_loc3_);
         }
         else if(_loc4_ == 220)
         {
            dispatchEvent(new ConnectedEvent());
         }
         else if(_loc4_ == 110)
         {
            this.throwDatabasesEvent(_loc3_);
         }
         else if(_loc4_ == 111)
         {
            this.throwMatchStrategiesEvent(_loc3_);
         }
         else if(_loc4_ == 152)
         {
            this.throwMatchEvent(_loc3_);
         }
         else if(_loc4_ == 150)
         {
            this.throwDefinitionHeaderEvent(_loc3_);
         }
         else if(_loc4_ == 151)
         {
            this.throwDefinitionEvent(_loc3_);
         }
      }
      
      private function ioError(param1:IOErrorEvent) : void
      {
         dispatchEvent(param1);
      }
      
      private function httpError(param1:FaultEvent) : void
      {
      }
      
      private function securityError(param1:SecurityErrorEvent) : void
      {
      }
      
      private function throwDatabasesEvent(param1:Response) : void
      {
         var _loc4_:String = null;
         var _loc5_:DatabaseEvent = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc2_:Array = new Array();
         var _loc3_:Array = param1.body.split("\r\n");
         for each(_loc4_ in _loc3_)
         {
            _loc6_ = _loc4_.substring(0,_loc4_.indexOf(" "));
            if(_loc6_ == "--exit--")
            {
               if(this.dbShortList)
               {
                  break;
               }
            }
            else
            {
               _loc7_ = _loc4_.substring(_loc4_.indexOf(" ") + 1,_loc4_.length).replace(/\"/g,"");
               _loc2_.push(new Database(_loc6_,_loc7_));
            }
         }
         _loc5_ = new DatabaseEvent();
         _loc5_.databases = _loc2_;
         dispatchEvent(_loc5_);
      }
      
      private function throwMatchStrategiesEvent(param1:Response) : void
      {
         var _loc4_:String = null;
         var _loc5_:MatchStrategiesEvent = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc2_:Array = new Array();
         var _loc3_:Array = param1.body.split("\r\n");
         for each(_loc4_ in _loc3_)
         {
            _loc6_ = _loc4_.substring(0,_loc4_.indexOf(" "));
            _loc7_ = _loc4_.substring(_loc4_.indexOf(" ") + 1,_loc4_.length).replace(/\"/g,"");
            _loc2_.push(new MatchStrategy(_loc6_,_loc7_));
         }
         _loc5_ = new MatchStrategiesEvent();
         _loc5_.strategies = _loc2_;
         dispatchEvent(_loc5_);
      }
      
      private function throwMatchEvent(param1:Response) : void
      {
         var _loc4_:String = null;
         var _loc5_:MatchEvent = null;
         var _loc6_:String = null;
         var _loc2_:Array = new Array();
         var _loc3_:Array = param1.body.split("\r\n");
         for each(_loc4_ in _loc3_)
         {
            _loc6_ = _loc4_.substring(_loc4_.indexOf(" ") + 1,_loc4_.length).replace(/\"/g,"");
            _loc2_.push(_loc6_);
         }
         _loc5_ = new MatchEvent();
         _loc5_.matches = _loc2_;
         dispatchEvent(_loc5_);
      }
      
      private function throwErrorEvent(param1:Response) : void
      {
         var _loc2_:ErrorEvent = new ErrorEvent();
         _loc2_.code = param1.code;
         _loc2_.message = param1.headerText;
         dispatchEvent(_loc2_);
      }
      
      private function throwNoMatchEvent(param1:Response) : void
      {
         dispatchEvent(new NoMatchEvent());
      }
      
      private function throwDefinitionHeaderEvent(param1:Response) : void
      {
         var _loc2_:DefinitionHeaderEvent = new DefinitionHeaderEvent();
         _loc2_.definitionCount = uint(param1.headerText.substring(0,param1.headerText.indexOf(" ")));
         dispatchEvent(_loc2_);
      }
      
      private function throwDefinitionEvent(param1:Response) : void
      {
         var _loc2_:DefinitionEvent = new DefinitionEvent();
         var _loc3_:Definition = new Definition();
         var _loc4_:String = param1.headerText;
         var _loc5_:Array = _loc4_.match(/"[^"]+"/g);
         _loc3_.term = String(_loc5_[0]).replace(/"/g,"");
         _loc3_.database = String(_loc5_[1]).replace(/"/g,"");
         _loc3_.definition = param1.body;
         _loc2_.definition = _loc3_;
         dispatchEvent(_loc2_);
      }
      
      private function parseRawResponse(param1:String) : Response
      {
         var _loc3_:String = null;
         var _loc2_:Response = new Response();
         if(param1.indexOf("\r\n") != -1)
         {
            _loc3_ = param1.substring(0,param1.indexOf("\r\n"));
         }
         else
         {
            _loc3_ = param1;
         }
         var _loc4_:Array = _loc3_.match(/^\d{3}/);
         _loc2_.code = uint(_loc4_[0]);
         _loc2_.headerText = _loc3_.substring(_loc3_.indexOf(" ") + 1,_loc3_.length);
         var _loc5_:String = param1.substring(param1.indexOf("\r\n") + 2,param1.length);
         _loc5_ = _loc5_.replace(/\r\n\.\./,"\r\n.");
         _loc2_.body = _loc5_;
         return _loc2_;
      }
   }
}

