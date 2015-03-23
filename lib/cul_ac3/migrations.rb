require 'fedora-migrate'
module Cul::Ac3::Migrations
  class DescMetadataMigration < FedoraMigrate::DatastreamMover
    METADATA_FOR = ::RDF::URI('http://purl.oclc.org/NET/CUL/metadataFor')
    def source
      # take @source object's uri
      subject = @source.uri
      predicate = METADATA_FOR.to_s
      ds = nil
      # use rubydora's ri query to get the object that is $description <http://purl.oclc.org/NET/CUL/metadataFor> @source
      enum = FedoraMigrate.source.connection.find_by_sparql_relationship(subject, predicate)
      ds = enum.inject(nil) {|ds,obj| ds ||= obj.datastreams['CONTENT']}
      ds
    end
    def migrate
      super
      target.original_name = "descMetadata.xml"
    end
  end
end