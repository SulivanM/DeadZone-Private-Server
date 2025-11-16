package thelaststand.app.game.data
{
   public class JunkBuilding extends Building
   {
      
      private var _items:Vector.<Item>;
      
      private var _xp:int;
      
      private var _removalTime:int;
      
      public function JunkBuilding()
      {
         super();
         this._items = new Vector.<Item>();
      }
      
      override public function readObject(param1:Object) : void
      {
         var _loc4_:int = 0;
         var _loc5_:Item = null;
         super.readObject(param1);
         this._removalTime = int(xml.time);
         if(param1.items is Array && param1.items.length > 0)
         {
            this._items.length = 0;
            _loc4_ = 0;
            while(_loc4_ < param1.items.length)
            {
               if(param1.items[_loc4_] != null)
               {
                  _loc5_ = ItemFactory.createItemFromObject(param1.items[_loc4_]);
                  if(_loc5_ != null)
                  {
                     this._items.push(_loc5_);
                  }
               }
               _loc4_++;
            }
         }
         var _loc2_:Array = String(param1.pos).split(",");
         entity.transform.position.x = Number(_loc2_[0]);
         entity.transform.position.y = Number(_loc2_[1]);
         entity.transform.position.z = Number(_loc2_[2]);
         var _loc3_:Array = String(param1.rot).split(",");
         entity.transform.setRotationEuler(Number(_loc3_[0]) * Math.PI / 180,Number(_loc3_[1]) * Math.PI / 180,Number(_loc3_[2]) * Math.PI / 180);
         entity.updateTransform();
      }
      
      override public function setLevel(param1:int) : void
      {
         super.setLevel(param1);
         buildingEntity.coverRating = int(xml.cover);
      }
      
      override protected function setXML(param1:XML) : void
      {
         var _loc2_:XML = null;
         var _loc3_:Item = null;
         super.setXML(param1);
         this._items.length = 0;
         for each(_loc2_ in xml.items.itm)
         {
            _loc3_ = ItemFactory.createItemFromXML(_loc2_);
            if(_loc3_ != null)
            {
               this._items.push(_loc3_);
            }
         }
         this._xp = int(xml.xp);
         buildingEntity.coverRating = int(xml.cover);
      }
      
      public function get items() : Vector.<Item>
      {
         return this._items;
      }
      
      public function get removalTime() : int
      {
         return this._removalTime;
      }
      
      public function get xp() : int
      {
         return this._xp;
      }
   }
}

