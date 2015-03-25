class Cul::Ac3::Datastreams::DescMetadata < ::ActiveFedora::File
  include ::ActiveFedora::Datastreams::NokogiriDatastreams
  MODSNS = {mods:'http://www.loc.gov/mods/v3'}
  def self.xml_template
    Nokogiri::XML::Document.parse("<mods xmlns='http://www.loc.gov/mods/v3' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xsi:schemaLocation='http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd' version='3.5'>")
  end
  def to_solr(solr_doc={}, opts={})
    texts = [:resource_type, :title, :creator, :contributor, :description, :tag, :rights,
       :publisher, :date_created, :subject, :language, :identifier, :based_near, :related_url]
    facets = [:resource_type, :title, :creator, :contributor, :tag, :publisher, :subject,
       :language, :based_near]
    texts.each do |key|
      fname = "#{key}_tesim" # + solr_name(key.to_s, :stored_searchable)
      solr_doc[fname] ||= []
      if (vals = self.send(key))
        if Array === vals
          solr_doc[fname] += vals
        else
          solr_doc[fname] = vals
        end
      end
    end
    facets.each do |key|
      fname = "#{key}_sim" # + solr_name(key.to_s, :stored_searchable)
      solr_doc[fname] ||= []
      if (vals = self.send(key))
        if Array === vals
          solr_doc[fname] += vals
        else
          solr_doc[fname] = vals
        end
      end
    end
    solr_doc[Solrizer.solr_name('title')] = title
    solr_doc
  end

  def resource_type
    ng_xml.xpath('mods:mods/mods:genre', MODSNS).map {|n| n.text}
  end
  def title
    ng_xml.xpath('mods:mods/mods:titleInfo', MODSNS).map {|n| n.text.strip}.first || "untitled"
  end
  def label
    title
  end
  def creator
    ng_xml.xpath("mods:mods/mods:name/mods:role/mods:roleTerm[normalize-space(.)='author']", MODSNS).collect do|r|
      name_parts = []
      r.parent.parent.xpath('mods:namePart',MODSNS).each {|p| name_parts << p.text }
      name_parts.join(' ')
    end
  end
  def contributor
    []
  end
  def description
    ng_xml.xpath('mods:mods/mods:abstract', MODSNS).map {|n| n.text}
  end
  def tag
    []
  end
  def rights
    []
  end
  def publisher
    []
  end
  def date_created
    ng_xml.xpath('mods:mods/mods:originInfo/mods:dateIssued', MODSNS).map {|n| n.text}
  end
  def subject
    ng_xml.xpath('mods:mods/mods:subject', MODSNS).map {|n| n.text}
  end
  def language
    ng_xml.xpath('mods:mods/mods:language', MODSNS).map {|n| n.text}
  end
  def identifier
    ng_xml.xpath('mods:mods/mods:identifier', MODSNS).map {|n| n.text}
  end
  def based_near
    []
  end
  def related_url
    ng_xml.xpath("mods:mods/mods:identifier[@type='CDRS doi']", MODSNS).map {|n| n.text}
  end
  def full_text
    FullText.new(ng_xml.text)
  end
  class FullText
    attr_reader :content
    def initialize(content)
      @content = content
    end
  end
end