class GenericFile < ActiveFedora::Base
  include Sufia::GenericFile
  has_metadata :name => "descMetadata", :type=> Cul::Ac3::Datastreams::DescMetadata
end