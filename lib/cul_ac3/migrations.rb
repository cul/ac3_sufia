require 'fedora-migrate'
module Cul::Ac3::Migrations
  def self.sparql_outbound(subject, predicate)
    <<-RELSEXT
        SELECT ?pid FROM <#ri> WHERE {
          <#{subject}> <#{predicate}> ?pid 
        }
      RELSEXT
  end
  def self.sparql_inbound(object, predicate)
    <<-RELSEXT
        SELECT ?pid FROM <#ri> WHERE {
          ?pid <#{predicate}> <#{object}> 
        }
      RELSEXT
  end
  class DescMetadataMigration < FedoraMigrate::DatastreamMover
    MEMBER_OF = ::RDF::URI('http://purl.oclc.org/NET/CUL/memberOf')
    METADATA_FOR = ::RDF::URI('http://purl.oclc.org/NET/CUL/metadataFor')
    def source
      # take @source object's uri
      subject = @source.uri
      predicate = METADATA_FOR.to_s
      ds = nil
      # use rubydora's ri query to get the object that is $description <http://purl.oclc.org/NET/CUL/metadataFor> @source
      enum = FedoraMigrate.source.connection.find_by_sparql Cul::Ac3::Migrations.sparql_inbound(subject, predicate)
      ds = enum.inject(nil) {|ds,obj| ds ||= obj.datastreams['CONTENT']}
      ds
    end
    def migrate
      super
      target.original_name = "descMetadata.xml"
    end
  end
  class ResourceContentMigration < FedoraMigrate::DatastreamMover
    def source
      @source.datastreams['CONTENT']
    end
  end
  class ListMigrator < FedoraMigrate::RepositoryMigrator
    def source_objects
      # read off a list of PIDs
    end
    def migrate_object source, target_class=GenericWork,conversions=nil
      conversions ||= {'descMetadata'=>DescMetadataMigration}
      object_report = SingleObjectReport.new
      begin
        migration = FedoraMigrate::ObjectMover.new(source, target_class.new(id:source.pid), options)
        migration.content_conversions.merge!(conversions)
        object_report.object = migration.migrate
        object_report.status = true
      rescue StandardError => e
        object_report.object = e.inspect
        object_report.status = false
      end
      report.results[source.pid] = object_report
      migrate_resources source
    end
    def migrate_resources source
      subject = source.uri
      predicate = MEMBER_OF.to_s
      enum = FedoraMigrate.source.connection.find_by_sparql Cul::Ac3::Migrations.sparql_inbound(subject, predicate)
      enum.each do |resource|
        migrate_object resource, GenericFile, {'content' => ResourceContentMigration}
      end
    end
  end
end