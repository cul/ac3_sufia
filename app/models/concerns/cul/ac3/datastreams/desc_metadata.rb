class Cul::Ac3::Datastreams::DescMetadata < ::ActiveFedora::Datastream
  include ::ActiveFedora::Datastreams::NokogiriDatastreams
  def self.xml_template
    Nokogiri::XML::Document.parse("<mods xmlns='http://www.loc.gov/mods/v3' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xsi:schemaLocation='http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd' version='3.5'>")
  end
  def to_solr(solr_doc={}, opts={})
    solr_doc
  end
end