class GenericWork < ActiveFedora::Base
  include Sufia::GenericWork
  has_metadata :name => "descMetadata", :type=> Cul::Ac3::Datastreams::DescMetadata
end