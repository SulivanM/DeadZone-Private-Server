package mx.messaging.config
{
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   import mx.collections.ArrayCollection;
   import mx.core.mx_internal;
   import mx.messaging.Channel;
   import mx.messaging.ChannelSet;
   import mx.messaging.MessageAgent;
   import mx.messaging.errors.InvalidChannelError;
   import mx.messaging.errors.InvalidDestinationError;
   import mx.resources.IResourceManager;
   import mx.resources.ResourceManager;
   import mx.utils.ObjectUtil;
   
   use namespace mx_internal;
   
   public class ServerConfig
   {
      
      private static var _resourceManager:IResourceManager;
      
      public static var serverConfigData:XML;
      
      private static var _configFetchedChannels:Object;
      
      public static const CLASS_ATTR:String = "type";
      
      public static const URI_ATTR:String = "uri";
      
      private static var _channelSets:Object = {};
      
      private static var _clusteredChannels:Object = {};
      
      private static var _unclusteredChannels:Object = {};
      
      public static var channelSetFactory:Class = ChannelSet;
      
      public function ServerConfig()
      {
         super();
      }
      
      private static function get resourceManager() : IResourceManager
      {
         if(!_resourceManager)
         {
            _resourceManager = ResourceManager.getInstance();
         }
         return _resourceManager;
      }
      
      public static function get xml() : XML
      {
         if(serverConfigData == null)
         {
            serverConfigData = <services/>;
         }
         return serverConfigData;
      }
      
      public static function set xml(param1:XML) : void
      {
         serverConfigData = param1;
         _channelSets = {};
         _clusteredChannels = {};
         _unclusteredChannels = {};
      }
      
      public static function checkChannelConsistency(param1:String, param2:String) : void
      {
         var _loc3_:Array = mx_internal::getChannelIdList(param1);
         var _loc4_:Array = mx_internal::getChannelIdList(param2);
         if(ObjectUtil.compare(_loc3_,_loc4_) != 0)
         {
            throw new ArgumentError("Specified destinations are not channel consistent");
         }
      }
      
      public static function getChannel(param1:String, param2:Boolean = false) : Channel
      {
         var _loc3_:Channel = null;
         if(!param2)
         {
            if(param1 in _unclusteredChannels)
            {
               return _unclusteredChannels[param1];
            }
            _loc3_ = createChannel(param1);
            _unclusteredChannels[param1] = _loc3_;
            return _loc3_;
         }
         if(param1 in _clusteredChannels)
         {
            return _clusteredChannels[param1];
         }
         _loc3_ = createChannel(param1);
         _clusteredChannels[param1] = _loc3_;
         return _loc3_;
      }
      
      public static function getChannelSet(param1:String) : ChannelSet
      {
         var _loc2_:XML = getDestinationConfig(param1);
         return internalGetChannelSet(_loc2_,param1);
      }
      
      public static function getProperties(param1:String) : XMLList
      {
         var destination:XMLList = null;
         var message:String = null;
         var destinationId:String = param1;
         destination = xml..destination.(@id == destinationId);
         if(destination.length() > 0)
         {
            return destination.properties;
         }
         message = resourceManager.getString("messaging","unknownDestination",[destinationId]);
         throw new InvalidDestinationError(message);
      }
      
      mx_internal static function channelSetMatchesDestinationConfig(param1:ChannelSet, param2:String) : Boolean
      {
         var csUris:Array = null;
         var csChannels:Array = null;
         var i:uint = 0;
         var ids:Array = null;
         var dsUris:Array = null;
         var dsChannels:XMLList = null;
         var channelConfig:XML = null;
         var endpoint:XML = null;
         var dsUri:String = null;
         var j:uint = 0;
         var channelSet:ChannelSet = param1;
         var destination:String = param2;
         if(channelSet != null)
         {
            if(ObjectUtil.compare(channelSet.channelIds,mx_internal::getChannelIdList(destination)) == 0)
            {
               return true;
            }
            csUris = [];
            csChannels = channelSet.channels;
            i = 0;
            while(i < csChannels.length)
            {
               csUris.push(csChannels[i].uri);
               i++;
            }
            ids = mx_internal::getChannelIdList(destination);
            dsUris = [];
            j = 0;
            while(j < ids.length)
            {
               dsChannels = xml.channels.channel.(@id == ids[j]);
               channelConfig = dsChannels[0];
               endpoint = channelConfig.endpoint;
               dsUri = endpoint.length() > 0 ? endpoint[0].attribute(URI_ATTR).toString() : null;
               if(dsUri != null)
               {
                  dsUris.push(dsUri);
               }
               j++;
            }
            return ObjectUtil.compare(csUris,dsUris) == 0;
         }
         return false;
      }
      
      mx_internal static function fetchedConfig(param1:String) : Boolean
      {
         return _configFetchedChannels != null && _configFetchedChannels[param1] != null;
      }
      
      mx_internal static function getChannelIdList(param1:String) : Array
      {
         var _loc2_:XML = getDestinationConfig(param1);
         return _loc2_ ? getChannelIds(_loc2_) : getDefaultChannelIds();
      }
      
      mx_internal static function needsConfig(param1:Channel) : Boolean
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         if(_configFetchedChannels == null || _configFetchedChannels[param1.endpoint] == null)
         {
            _loc2_ = param1.channelSets;
            _loc3_ = int(_loc2_.length);
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               if(getQualifiedClassName(_loc2_[_loc4_]).indexOf("Advanced") != -1)
               {
                  return true;
               }
               _loc5_ = ChannelSet(_loc2_[_loc4_]).messageAgents;
               _loc6_ = int(_loc5_.length);
               _loc7_ = 0;
               while(_loc7_ < _loc6_)
               {
                  if(MessageAgent(_loc5_[_loc7_]).mx_internal::needsConfig)
                  {
                     return true;
                  }
                  _loc7_++;
               }
               _loc4_++;
            }
         }
         return false;
      }
      
      mx_internal static function updateServerConfigData(param1:ConfigMap, param2:String = null) : void
      {
         var newServices:XML = null;
         var newService:XML = null;
         var newChannels:XMLList = null;
         var oldServices:XMLList = null;
         var oldDestinations:XMLList = null;
         var newDestination:XML = null;
         var oldService:XML = null;
         var oldChannels:XML = null;
         var serverConfig:ConfigMap = param1;
         var endpoint:String = param2;
         if(serverConfig != null)
         {
            if(endpoint != null)
            {
               if(_configFetchedChannels == null)
               {
                  _configFetchedChannels = {};
               }
               _configFetchedChannels[endpoint] = true;
            }
            newServices = <services></services>;
            convertToXML(serverConfig,newServices);
            xml["default-channels"] = newServices["default-channels"];
            for each(newService in newServices..service)
            {
               oldServices = xml.service.(@id == newService.@id);
               if(oldServices.length() != 0)
               {
                  oldService = oldServices[0];
                  for each(newDestination in newService..destination)
                  {
                     oldDestinations = oldService.destination.(@id == newDestination.@id);
                     if(oldDestinations.length() != 0)
                     {
                        delete oldDestinations[0];
                     }
                     oldService.appendChild(newDestination.copy());
                  }
               }
               else
               {
                  for each(newDestination in newService..destination)
                  {
                     oldDestinations = xml..destination.(@id == newDestination.@id);
                     if(oldDestinations.length() != 0)
                     {
                        oldDestinations[0] = newDestination[0].copy();
                        delete newService..destination.(@id == newDestination.@id)[0];
                     }
                  }
                  if(newService.children().length() > 0)
                  {
                     xml.appendChild(newService);
                  }
               }
            }
            newChannels = newServices.channels;
            if(newChannels.length() > 0)
            {
               oldChannels = xml.channels[0];
               if(oldChannels == null || oldChannels.length() == 0)
               {
                  xml.appendChild(newChannels);
               }
            }
         }
      }
      
      private static function createChannel(param1:String) : Channel
      {
         var message:String = null;
         var channels:XMLList = null;
         var channelConfig:XML = null;
         var className:String = null;
         var endpoint:XMLList = null;
         var uri:String = null;
         var channel:Channel = null;
         var channelClass:Class = null;
         var channelId:String = param1;
         channels = xml.channels.channel.(@id == channelId);
         if(channels.length() == 0)
         {
            message = resourceManager.getString("messaging","unknownChannelWithId",[channelId]);
            throw new InvalidChannelError(message);
         }
         channelConfig = channels[0];
         className = channelConfig.attribute(CLASS_ATTR).toString();
         endpoint = channelConfig.endpoint;
         uri = endpoint.length() > 0 ? endpoint[0].attribute(URI_ATTR).toString() : null;
         channel = null;
         try
         {
            channelClass = getDefinitionByName(className) as Class;
            channel = new channelClass(channelId,uri);
            channel.applySettings(channelConfig);
            if(LoaderConfig.parameters != null && LoaderConfig.parameters.WSRP_ENCODED_CHANNEL != null)
            {
               channel.url = LoaderConfig.parameters.WSRP_ENCODED_CHANNEL;
            }
         }
         catch(e:ReferenceError)
         {
            message = resourceManager.getString("messaging","unknownChannelClass",[className]);
            throw new InvalidChannelError(message);
         }
         return channel;
      }
      
      private static function convertToXML(param1:ConfigMap, param2:XML) : void
      {
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         var _loc7_:XML = null;
         var _loc8_:XML = null;
         for(_loc3_ in param1)
         {
            _loc4_ = param1[_loc3_];
            if(_loc4_ is String)
            {
               if(_loc3_ == "")
               {
                  param2.appendChild(_loc4_);
               }
               else
               {
                  param2[_loc3_] = _loc4_;
               }
            }
            else if(_loc4_ is ArrayCollection || _loc4_ is Array)
            {
               if(_loc4_ is ArrayCollection)
               {
                  _loc5_ = ArrayCollection(_loc4_).toArray();
               }
               else
               {
                  _loc5_ = _loc4_ as Array;
               }
               _loc6_ = 0;
               while(_loc6_ < _loc5_.length)
               {
                  _loc7_ = new XML("<" + _loc3_ + "></" + _loc3_ + ">");
                  param2.appendChild(_loc7_);
                  convertToXML(_loc5_[_loc6_] as ConfigMap,_loc7_);
                  _loc6_++;
               }
            }
            else
            {
               _loc8_ = new XML("<" + _loc3_ + "></" + _loc3_ + ">");
               param2.appendChild(_loc8_);
               convertToXML(_loc4_ as ConfigMap,_loc8_);
            }
         }
      }
      
      private static function getChannelIds(param1:XML) : Array
      {
         var _loc2_:Array = [];
         var _loc3_:XMLList = param1.channels.channel;
         var _loc4_:int = int(_loc3_.length());
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            _loc2_.push(_loc3_[_loc5_].@ref.toString());
            _loc5_++;
         }
         return _loc2_;
      }
      
      private static function getDefaultChannelIds() : Array
      {
         var _loc1_:Array = [];
         var _loc2_:XMLList = xml["default-channels"].channel;
         var _loc3_:int = int(_loc2_.length());
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc1_.push(_loc2_[_loc4_].@ref.toString());
            _loc4_++;
         }
         return _loc1_;
      }
      
      private static function getDestinationConfig(param1:String) : XML
      {
         var destinations:XMLList = null;
         var destinationCount:int = 0;
         var destinationId:String = param1;
         destinations = xml..destination.(@id == destinationId);
         destinationCount = int(destinations.length());
         if(destinationCount == 0)
         {
            return null;
         }
         return destinations[0];
      }
      
      private static function internalGetChannelSet(param1:XML, param2:String) : ChannelSet
      {
         var _loc3_:Array = null;
         var _loc4_:Boolean = false;
         var _loc6_:String = null;
         var _loc7_:ChannelSet = null;
         var _loc8_:int = 0;
         if(param1 == null)
         {
            _loc3_ = getDefaultChannelIds();
            if(_loc3_.length == 0)
            {
               _loc6_ = resourceManager.getString("messaging","noChannelForDestination",[param2]);
               throw new InvalidDestinationError(_loc6_);
            }
            _loc4_ = false;
         }
         else
         {
            _loc3_ = getChannelIds(param1);
            _loc4_ = param1.properties.network.cluster.length() > 0 ? true : false;
         }
         var _loc5_:String = _loc3_.join(",") + ":" + _loc4_;
         if(_loc5_ in _channelSets)
         {
            return _channelSets[_loc5_];
         }
         _loc7_ = new channelSetFactory(_loc3_,_loc4_);
         _loc8_ = int(serverConfigData["flex-client"]["heartbeat-interval-millis"]);
         if(_loc8_ > 0)
         {
            _loc7_.heartbeatInterval = _loc8_;
         }
         if(_loc4_)
         {
            _loc7_.initialDestinationId = param2;
         }
         _channelSets[_loc5_] = _loc7_;
         return _loc7_;
      }
   }
}

