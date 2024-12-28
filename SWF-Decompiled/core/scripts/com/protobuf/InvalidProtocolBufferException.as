package com.protobuf
{
   import flash.errors.IOError;
   
   public class InvalidProtocolBufferException extends IOError
   {
      public function InvalidProtocolBufferException(param1:String)
      {
         super(param1);
      }
      
      public static function truncatedMessage() : InvalidProtocolBufferException
      {
         return new InvalidProtocolBufferException("While parsing a protocol message, the input ended unexpectedly in the middle of a field.  This could mean either than the input has been truncated or that an embedded message misreported its own length.");
      }
      
      public static function negativeSize() : InvalidProtocolBufferException
      {
         return new InvalidProtocolBufferException("CodedInputStream encountered an embedded string or message which claimed to have negative size.");
      }
      
      public static function malformedVarint() : InvalidProtocolBufferException
      {
         return new InvalidProtocolBufferException("CodedInputStream encountered a malformed varint.");
      }
      
      public static function invalidTag() : InvalidProtocolBufferException
      {
         return new InvalidProtocolBufferException("Protocol message contained an invalid tag (zero).");
      }
      
      public static function invalidEndTag() : InvalidProtocolBufferException
      {
         return new InvalidProtocolBufferException("Protocol message end-group tag did not match expected tag.");
      }
      
      public static function invalidWireType() : InvalidProtocolBufferException
      {
         return new InvalidProtocolBufferException("Protocol message tag had invalid wire type.");
      }
      
      public static function recursionLimitExceeded() : InvalidProtocolBufferException
      {
         return new InvalidProtocolBufferException("Protocol message had too many levels of nesting.  May be malicious.  Use CodedInputStream.setRecursionLimit() to increase the depth limit.");
      }
      
      public static function sizeLimitExceeded() : InvalidProtocolBufferException
      {
         return new InvalidProtocolBufferException("Protocol message was too large.  May be malicious.  Use CodedInputStream.setSizeLimit() to increase the size limit.");
      }
   }
}

