package thelaststand.app.game.data.alliance
{
   import com.dynamicflash.util.Base64;
   import flash.utils.ByteArray;
   
   public class AllianceDataSummary
   {
      
      protected var _points:int = 0;
      
      protected var _efficiency:Number = 0;
      
      private var _id:String;
      
      private var _tag:String;
      
      private var _name:String;
      
      private var _banner:AllianceBannerData;
      
      private var _thumbURI:String;
      
      private var _memberCount:int;
      
      public function AllianceDataSummary(param1:String)
      {
         super();
         this._id = param1;
         this._banner = new AllianceBannerData();
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function get tag() : String
      {
         return this._tag;
      }
      
      public function get tagBracketed() : String
      {
         return !this._tag ? "" : "[" + this._tag + "]";
      }
      
      public function get memberCount() : int
      {
         return this._memberCount;
      }
      
      public function get banner() : AllianceBannerData
      {
         return this._banner;
      }
      
      public function get thumbURI() : String
      {
         return this._thumbURI;
      }
      
      public function get points() : int
      {
         return this._points;
      }
      
      public function get efficiency() : Number
      {
         return this._efficiency;
      }
      
      public function deserialize(param1:Object) : void
      {
         if("allianceId" in param1)
         {
            this._id = String(param1.allianceId);
         }
         else if("id" in param1)
         {
            this._id = String(param1.id);
         }
         if("name" in param1)
         {
            this._name = String(param1.name);
         }
         if("tag" in param1)
         {
            this._tag = String(param1.tag);
         }
         if("banner" in param1)
         {
            if(param1.banner is String)
            {
               try
               {
                  this._banner.byteArray = Base64.decodeToByteArray(String(param1.banner));
               }
               catch(error:Error)
               {
               }
            }
            else if(param1.banner is ByteArray)
            {
               this._banner.byteArray = param1.banner;
            }
         }
         if("thumbURI" in param1)
         {
            this._thumbURI = param1.thumbURI;
         }
         if("memberCount" in param1)
         {
            this._memberCount = int(param1.memberCount);
         }
         if("efficiency" in param1)
         {
            this._efficiency = Number(param1.efficiency);
         }
         if("points" in param1)
         {
            this._points = int(param1.points);
         }
      }
   }
}

