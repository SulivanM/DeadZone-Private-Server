package thelaststand.common.io
{
   public interface ISerializable
   {
      
      function writeObject(param1:Object = null) : Object;
      
      function readObject(param1:Object) : void;
   }
}

