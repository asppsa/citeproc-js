# -*- coding: utf-8 -*-

require 'spec_helper'

# We can't do testing without one of v8 or rhino.  In the case
# of the former, we also need nokogiri.
begin
  require 'v8'
rescue LoadError
  require 'rhino'
end
require 'nokogiri'

module CiteProc
  module JS
    describe 'Engine' do

      let(:items) { load_items('items') }
      
      let(:processor) do
        p = Processor.new(:style => 'apa')
        p.update(items)
        p
      end

      before(:all) do
        Style.root = File.expand_path('../../../fixtures/styles', __FILE__)
        Locale.root = File.expand_path('../../../fixtures/locales', __FILE__)
      end

      let(:engine) do
        processor.engine = Engine.new(processor)
      end

      it { should_not be nil }


      describe '#version' do
        it 'returns a 1.x version string' do
          engine.version.should =~ /^1\.[\d\.]+/
        end
      end

      describe '#name' do
        it 'returns "citeproc-js"' do
          engine.name.should == 'citeproc-js'
        end
      end

      describe '#type' do
        it 'returns "CSL"' do
          engine.type.should == 'CSL'
        end
      end


      describe '#processor_version' do  
        it 'returns the citeproc-js version' do
          engine.processor_version.should =~ /^[\d\.]+$/
        end
      end

      describe '#flags' do
        it 'returns a hash of flags' do
          engine.flags.should have_key('sort_citations')
        end
      end

      describe '#namespace=' do
        it 'sets the abbreviation namespace' do
          lambda { engine.namespace = :default }.should_not raise_error
        end
      end

      describe '#registry' do
        it 'is a hash' do
          engine.registry.should be_a(Hash)
        end
      end

      describe '#update_items' do
        it 'given a list of ids, loads the corresponding items into the engine' do
          expect { engine.update_items(['ITEM-1']) }.to
          change { engine.registry[:inserts].length }.by(1)
        end
      end

      describe '#bibliography' do
        it 'returns an empty bibliography by default' do
          engine.bibliography.should be_empty
        end

        describe 'when items were updated' do
          before(:each) { engine.update_items(['ITEM-1']) }

          it 'returns the bibliography when at least one item was processed' do
            engine.bibliography.should_not be_empty
          end
          
          it 'the bibliography contains the processed items' do
            engine.bibliography[0].should match(/Boundaries of Dissent/)
          end
        end
      end

      describe '#append' do
                  
        it 'returns the citation id and string for the item' do
          engine.append(CitationData.new([{:id => 'ITEM-1'}]))[0][1].should == '(D’Arcus, 2006)'
        end
        
        it 'increases the citation index on subsequent calls' do
          x = engine.append(CitationData.new([{:id => 'ITEM-1'}]))[0][0]
          engine.append(CitationData.new([{:id => 'ITEM-1'}]))[0][0].should > x
        end
        
        it 'includes the locator' do
          engine.append(CitationData.new([{:id => 'ITEM-1', :locator => 'PAGE'}]))[0][1].should match(/PAGE/)
        end
        
      end
      
      describe '#sorted_registry_items' do
        it 'returns an empty bibliography by default' do
          engine.sorted_registry_items.should be_empty
        end

        describe 'when items were processed' do
          before(:each) { engine.update_items(['ITEM-1']) }

          it 'returns the bibliography when at least one item was processed' do
            engine.sorted_registry_items.should_not be_empty
          end
        end        
      end

    end

  end  
end
