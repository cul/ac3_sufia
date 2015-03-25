class GenericWork < ActiveFedora::Base
  include Sufia::GenericWork

  has_metadata 'descMetadata', :type=> Cul::Ac3::Datastreams::DescMetadata

  delegate :label, to: :descMetadata
  delegate :title, to: :descMetadata
  delegate :date_created, to: :descMetadata
  delegate :full_text, to: :descMetadata
  delegate :resource_type, to: :descMetadata
  delegate :related_url, to: :descMetadata
  delegate :language, to: :descMetadata
  delegate :subject, to: :descMetadata
  delegate :creator, to: :descMetadata

  property :identifier, predicate: ::RDF::DC.identifier do |index|
    index.as :stored_searchable
  end

  property :date_uploaded, predicate: ::RDF::DC.dateSubmitted, multiple: false do |index|
    index.type :date
    index.as :stored_sortable
  end
end