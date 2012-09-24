# A really basic class that allows an object to behave like a
# read-only hash.  Used for easy interop with Javascript.
module CiteProc::JS
  class ObjectHash < Hash

    def initialize obj
      @obj = obj
    end

    # Rhino can't use 'respond_to?' so instead we have to try
    # calling the method and see if it fails.
    def has_key? key
      if Object.const_defined?(:Rhino) &&
         @obj.is_a?(Java::OrgMozillaJavascript::NativeObject)
        begin 
          @obj.send(key)
          return true
        rescue NoMethodError
          return false
        end
      end

      @obj.respond_to? key
    end

    def [] key
      @obj.send(key)
    end

    def each
      @obj.each
    end

  end
end
