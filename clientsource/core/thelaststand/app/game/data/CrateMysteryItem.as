package thelaststand.app.game.data
{
   import com.dynamicflash.util.Base64;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.game.data.effects.Effect;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.SaveDataMethod;
   
   public class CrateMysteryItem extends Item
   {
      
      public var unlocked:Signal = new Signal(CrateMysteryItem,Vector.<Item>,Effect);
      
      public function CrateMysteryItem(param1:String = null)
      {
         super(param1);
         _quantifiable = false;
         quantity = 1;
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.unlocked.removeAll();
      }
      
      override public function getImageURI() : String
      {
         return _xml.img.@uri.toString();
      }
      
      public function open(param1:Function = null) : void
      {
         var self:CrateMysteryItem = null;
         var network:Network = null;
         var onComplete:Function = param1;
         self = this;
         network = Network.getInstance();
         network.save({"id":_id},SaveDataMethod.CRATE_MYSTERY_UNLOCK,function(param1:Object):void
         {
            var _loc4_:Effect = null;
            var _loc6_:int = 0;
            var _loc7_:Item = null;
            if(param1 == null || param1.success !== true)
            {
               onComplete(false);
               return;
            }
            var _loc2_:Vector.<Item> = new Vector.<Item>();
            var _loc3_:Array = param1.items as Array;
            if(_loc3_ != null)
            {
               _loc6_ = 0;
               while(_loc6_ < _loc3_.length)
               {
                  _loc7_ = ItemFactory.createItemFromObject(_loc3_[_loc6_]);
                  if(_loc7_ != null)
                  {
                     network.playerData.giveItem(_loc7_,true);
                     _loc2_.push(_loc7_);
                  }
                  _loc6_++;
               }
            }
            if(param1.effect != null)
            {
               _loc4_ = new Effect();
               _loc4_.readObject(Base64.decodeToByteArray(param1.effect));
               network.playerData.compound.globalEffects.addEffect(_loc4_);
            }
            if(param1.cooldown != null)
            {
               network.playerData.cooldowns.parse(Base64.decodeToByteArray(param1.cooldown));
            }
            var _loc5_:CrateMysteryItem = self;
            if(param1.crateId != null)
            {
               _loc5_ = network.playerData.inventory.removeItemById(param1.crateId) as CrateMysteryItem || self;
            }
            if(onComplete != null)
            {
               onComplete(true,_loc2_,_loc4_);
            }
            Tracking.trackEvent("Player","CrateMysteryOpen",self.type);
            unlocked.dispatch(self,_loc2_,_loc4_);
         });
      }
   }
}

