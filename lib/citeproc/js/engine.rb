
module CiteProc
  module JS

    class Engine < CiteProc::Engine

      extend Forwardable

      @name = 'citeproc-js'.freeze
      @type = 'CSL'.freeze
      @version = '1.0'
      @priority = 0

      def initialize(processor=nil)
        context['system'] = self
 
        super(processor)
      end

      def path 
        @path ||= File.expand_path('../support', __FILE__)
      end

      def context
        unless @context 
          if Object.const_defined? :V8
            @context = V8::Context.new(:with => self)
            # This could probably be used from Rhino too -- would it be
            # slower though?
          elsif Object.const_defined? :Rhino
            @context = Rhino::Context.new(:with => self)
            # Not sure that this does anything, as it's slow either way
            @context.optimization_level = 0
            #@context.load(File.join(path, 'xmle4x.js'))
          else
            raise "No javascript implementation available.  You must require one of 'v8' or 'rhino'"
          end

          @context['CSL_CHROME'] = NokogiriParser

          @context['Kernel'] = Kernel
          @context.load(File.join(path,'citeproc.js'))
          @context['CSL'].debug = lambda do |this, str| 
            if str.is_a? String
              puts 'DEBUG: ' + str
            else
              print 'DEBUG: '
              p str
            end
          end
        end

        @context
      end

      def js_engine
        unless @js_engine
          @js_engine = context.eval('new CSL.Engine(this, style, lang)')
          @js_engine.opt.development_extensions.field_hack = false
        end

        @js_engine
      end

      def retrieve_item id
        item = if id.is_a? String
                 processor.items[id.to_sym]
               else
                 processor.items[id]
               end

        item.to_citeproc
      end

      # The locale put into a hash to make citeproc-js happy
      def retrieve_locale lang
        processor.locale.to_s
      end
      
      # Sets the abbreviation's namespace, both in Ruby and JS land
      def namespace=(namespace)
        set_abbreviations(namespace)
        @namespace = namespace.to_sym
      end

      def bibliography(selector = Selector.new)
        Bibliography(make_bibliography(selector.to_citeproc))
      end
            
      def append(citation)
        append_citation_cluster(citation.to_citeproc, false)
      end

      def style
        processor.style.to_s
      end

      def lang
        processor.locale.language
      end

      def flags
        @flags ||= ObjectHash.new(js_engine.opt)
      end

      def registry
        @registry ||= ObjectHash.new(js_engine.registry)
      end

      def sorted_registry_items
        items = []
        js_engine.registry.getSortedRegistryItems.each do |k,v|
          items << v
        end

        items
      end

      class << self

        def underscore(javascript_method)
          word = javascript_method.to_s.split(/\./)[-1]
          word.gsub!(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
          word.downcase!
          word
        end

      end

      @js_methods = [:setOutputFormat, :updateItems, 
        :updateUncitedItems, :makeBibliography,
        :appendCitationCluster, :processCitationCluster,
        :previewCitationCluster,
        :setAbbreviations]

      @js_methods.each do |method|
        def_instance_delegator :js_engine, method, underscore(method)
      end

      def_instance_delegator :js_engine, :processor_version

      alias retrieveLocale retrieve_locale
      alias retrieveItem retrieve_item
      alias getAbbreviations abbreviations

      alias format= set_output_format
    end

  end
end
