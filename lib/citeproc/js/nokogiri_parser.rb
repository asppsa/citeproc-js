# Copyright (c) 2009, 2010, 2011 and 2012 Frank G. Bennett, Jr. All Rights
# Reserved.
#
# The contents of this file are subject to the Common Public
# Attribution License Version 1.0 (the “License”); you may not use
# this file except in compliance with the License. You may obtain a
# copy of the License at:
#
# http://bitbucket.org/fbennett/citeproc-js/src/tip/LICENSE.
#
# The License is based on the Mozilla Public License Version 1.1 but
# Sections 1.13, 14 and 15 have been added to cover use of software over a
# computer network and provide for limited attribution for the
# Original Developer. In addition, Exhibit A has been modified to be
# consistent with Exhibit B.
#
# Software distributed under the License is distributed on an “AS IS”
# basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
# the License for the specific language governing rights and limitations
# under the License.
#
# The Original Code is the citation formatting software known as
# "citeproc-js" (an implementation of the Citation Style Language
# [CSL]), including the original test fixtures and software located
# under the ./tests subdirectory of the distribution archive.
#
# The Original Developer is not the Initial Developer and is
# __________. If left blank, the Original Developer is the Initial
# Developer.
#
# The Initial Developer of the Original Code is Frank G. Bennett,
# Jr. All portions of the code written by Frank G. Bennett, Jr. are
# Copyright (c) 2009, 2010, 2011, and 2012 Frank G. Bennett, Jr. All Rights Reserved.
#
# Alternatively, the contents of this file may be used under the
# terms of the GNU Affero General Public License (the [AGPLv3]
# License), in which case the provisions of [AGPLv3] License are
# applicable instead of those above. If you wish to allow use of your
# version of this file only under the terms of the [AGPLv3] License
# and not to allow others to use your version of this file under the
# CPAL, indicate your decision by deleting the provisions above and
# replace them with the notice and other provisions required by the
# [AGPLv3] License. If you do not delete the provisions above, a
# recipient may use your version of this file under either the CPAL
# or the [AGPLv3] License.”
module CiteProc::JS
  class NokogiriParser

    INSTITUTION_KEYS = [
        "font-style",
        "font-variant",
        "font-weight",
        "text-decoration",
        "text-case"
    ]

    def cslns
      { 'csl' => "http://purl.org/net/xbiblio/csl" }
    end

    def clean xml
      xml = xml.gsub(/<\?[^?]+\?>/, "")
      xml.gsub!(/<![^>]+>/, "")
      xml.gsub!(/^\s+/, "")
      xml.gsub!(/\s+$/, "")
      xml
    end

    def getStyleId myxml
      if node = myxml.xpath('descendant-or-self::csl:id', cslns).first
        node.inner_text
      end
    end

    def children myxml
      if myxml.respond_to? :children
        myxml.children.to_a
      else
        []
      end
    end

    def nodename myxml
      if myxml.respond_to? :name
        myxml.name
      end
    end

    def attributes myxml
      if myxml.respond_to? :attribute_nodes
        Hash[myxml.attribute_nodes.map{ |a| ['@' + a.name, a.text] }]
      else
        {}
      end
    end

    def content myxml
      if myxml.respond_to? :inner_text
        myxml.inner_text
      end
    end

    def namespace 
      @namespace ||= { "xml" => "http://www.w3.org/XML/1998/namespace" } 
    end

    def numberofnodes myxml
      if myxml.respond_to? :length
        myxml.length
      else
        0 
      end
    end

    def getAttributeName attr
      if attr.respond_to? :name
        attr.name
      end
    end

    def getAttributeValue myxml,name=nil,ns=nil
      attr = if ns && !ns.empty?
               myxml.attribute_with_ns name, namespace[ns]
             elsif name && !name.empty?
               myxml.attribute name
             else
               myxml
             end

      if attr.respond_to? :text
        attr.text
      end
    end

    def getNodeValue myxml,name=nil
      return nil unless myxml

      node = if name && !name.empty?
               myxml.at_xpath('csl:' + name, cslns)
             else
               myxml.first
             end

      if node.respond_to? :inner_text
        node.inner_text 
      end
    end

    def setAttributeOnNodeIdentifiedByNameAttribute(
        myxml,nodename,attrname,attr,val)

      attr = attr[1..attr.length]   if attr[0] == ?@
      if node = myxml.at_xpath("csl:#{nodename}[@name=$attrname]", cslns,
                               {:attrname => attrname})
        node[attr] = val
      end
    end

    def deleteNodeByNameAttribute myxml,val
      myxml.at_xpath('csl:*[@name=$val]', cslns, {:val=>val}).each do |node|
        node.remove
      end
    end
      
    def deleteAttribute myxml,attr
      if myxml.respond_to? :remove_attribute
        myxml.remove_attribute attr
      end
    end

    def setAttribute myxml,attr,val 
      if myxml.respond_to? :[]
        myxml[attr] = val
      end
    end

    def nodeCopy myxml
      if myxml.respond_to? :clone
        myxml.clone
      end
    end

    def getNodesByName myxml,name,nameattrval=nil
      return [] unless myxml

      nodes = if nameattrval && !nameattrval.empty?
                myxml.xpath("descendant-or-self::csl:#{name}[@name=$nameattrval]",
                            cslns, {:nameattrval => nameattrval})
              else
                myxml.xpath('descendant-or-self::csl:' + name, cslns)
              end

      nodes.to_a
    end

    def nodeNameIs myxml,name
      if myxml.respond_to? :name=
        myxml.name == name
      end
    end

    def makeXml myxml=nil
      doc = if myxml && !myxml.empty?
              myxml = myxml.to_s if myxml.is_a? Nokogiri::XML::Node
              myxml = myxml.gsub(/\s*<\?[^>]*\?>\s*\n*/, "")
              Nokogiri::XML::Document.parse(myxml)
            else
              Nokogiri::XML::Document.new
            end

      cslns.each{ |k,v| doc.root.add_namespace k,v } if doc.root
      doc.root
    end

    def insertChildNodeAfter parent,node,pos,datexml
      if node.respond_to? :replace
        node.replace datexml
      end
    end

    def insertPublisherAndPlace myxml
      return unless myxml.respond_to? :xpath

      myxml.xpath('descendant-or-self::csl:group', cslns).each do |node|
        if node.children.length == 2
          twovars = []
          node.children.
            filter{ |child| child.children.length == 0 }.
            each do |child|
  
              twovars << child['variable']  if 
                child.has_attribute?('variable') &&
                !child['variable'].empty?

              if child.has_attribute?('suffix') ||
                child.has_attribute?('prefix')
                
                twovars = []
                break
              end
          end

          if twovars.include?("publisher") && twovars.include?("publisher-place")
            node['has-publisher-and-publisher-place'] = true
          end
        end
      end
    end

    def addMissingNameNodes myxml
      return unless myxml.respond_to? :xpath

      myxml.xpath('descendant-or-self::csl:names', cslns).each do |node|
        if node.parent.name != 'substitute' && !node.at_xpath('csl:name', cslns)
          name = Nokogiri::XML::Element.new('name', node.document)
          name.default_namespace = cslns['csl']
          node.append name 
        end
      end
    end

    def addInstitutionNodes myxml
      return unless myxml.respond_to? :xpath

      myxml.xpath('descendant-or-self::csl:names', cslns).each do |node|
        if name = node.at_xpath('csl:name', cslns)
          
          unless node.at_xpath('csl:institution', cslns)
            institution_long = Nokogiri::XML::Element.new('institution', node.document)
            institution_long.default_namespace = cslns['csl']
            institution_long['institution-parts'] = 'long'
            institution_long['substitute-first-use'] = '1'
            institution_long['use-last'] = '1'
            institution_long['delimiter'] = name['delimiter']
            institution_long['and'] = 'text' if (node['and'])

            institution_part = Nokogiri::XML::Element.new('institution-part', node.document)
            institution_part.default_namespace = cslns['csl']
            institution_part['name'] = 'long'

            name.add_next_sibling(institution_long)
            institution_long.add_child institution_part

            INSTITUTION_KEYS.each do |attr|
              institution_part[attr] = name[attr] if name[attr]
            end

            name.xpath('csl:name-part[@name="family"]', cslns).each do |namepartnode|
              INSTITUTION_KEYS.each do |attr|
                institution_part[attr] = namepartnode[attr] if namepartnode[attr]
              end
            end
          end
        end
      end
    end

    def flagDateMacros myxml
      return unless myxml.respond_to? :xpath

      myxml.xpath('descendant-or-self::csl:macro[descendant-or-self::csl:date]', cslns).each do |node|
        node['macro-has-date'] = 'true'
      end
    end
  end
end
