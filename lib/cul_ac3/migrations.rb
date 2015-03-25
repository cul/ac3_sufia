require 'fedora-migrate'
module Cul::Ac3::Migrations

  MEMBER_OF = ::RDF::URI('http://purl.oclc.org/NET/CUL/memberOf')
  METADATA_FOR = ::RDF::URI('http://purl.oclc.org/NET/CUL/metadataFor')

  def self.sparql_outbound(subject, predicate)
    <<-SPARQL
        SELECT ?pid FROM <#ri> WHERE {
          <#{subject}> <#{predicate}> ?pid 
        }
      SPARQL
  end
  def self.sparql_inbound(object, predicate)
    <<-SPARQL
        SELECT ?pid FROM <#ri> WHERE {
          ?pid <#{predicate}> <#{object}> 
        }
      SPARQL
  end
  class DescMetadataMigration < FedoraMigrate::DatastreamMover
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
  class ObjectMover < FedoraMigrate::ObjectMover
    def before_object_migration
      target.ldp_source.prefixes = options[:prefixes] || {}
      puts target.ldp_source.prefixes.inspect
      target.depositor = 'fedoraAdmin'
      target.edit_users = ['fedoraAdmin']
      target.read_groups = ["public"]
      _title = source.label || source.pid
      target.title = (target.is_a? GenericFile ) ? [_title] : _title 
      target
    end
    def create_target_model
      builder = FedoraMigrate::TargetConstructor.new([])
      source.models.inject(builder) do |tc, model|
        if model.to_s == "info:fedora/ldpd:ContentAggregator"
          tc.target = GenericWork
        elsif model.to_s == "info:fedora/ldpd:Resource"
          tc.target = GenericFile
        end
        tc
      end
      raise FedoraMigrate::Errors::MigrationError, "No qualified targets found in #{source.pid}" if builder.target.nil?
      tc = builder.target
      @target = begin
        puts "loooking for #{id_component}"
        tc.find(id_component)
      rescue ActiveFedora::ObjectNotFoundError
        tc.new(id: id_component)
      end
    end
    def self.id_component(object)
      id_src = (object.kind_of?(Rubydora::DigitalObject)) ? object.pid : object.to_s
      return id_src
    end
  end
  class RelsExtDatastreamMover < FedoraMigrate::RelsExtDatastreamMover
    IGNORE = [ActiveFedora::RDF::Fcrepo::Model.hasModel,Cul::Ac3::Migrations::MEMBER_OF]
    def statements
      graph.statements.reject { |stmt| IGNORE.include?(stmt.predicate)|| has_missing_object?(stmt) }
    end
  end
  class ListMigrator < FedoraMigrate::RepositoryMigrator
    def get_source_objects
      # read off a list of PIDs
      list = options[:list]
      if list
        File.foreach(list).lazy.map(&:chomp).map {|id| FedoraMigrate.source.connection.find(id)}
      else
        []
      end
    end
    def migrate_objects
      source_objects.each { |source| migrate_object(source) }
    end
    def migrate_object(source,conversions=nil)
      conversions ||= {'descMetadata'=>DescMetadataMigration}
      object_report = SingleObjectReport.new
      migration = nil
      begin
        options = {}
        if namespace
          options[:prefixes] = {namespace.to_s => ::RDF::URI("http://fedora.info/definitions/v4/repository##{namespace}")}
        end
        puts "#{source.pid} " + options.inspect
        migration = Cul::Ac3::Migrations::ObjectMover.new(source, nil, options)
        migration.content_conversions.merge!(conversions)
        object_report.object = migration.migrate
        object_report.status = true
      rescue StandardError => e
        object_report.object = e.inspect
        object_report.status = false
        puts e.message + "\n" + e.backtrace.join("\n")
      end
      report.results[source.pid] = object_report
      if migration && object_report.status
        migrate_resources(source) {|id| migration.target.members << ActiveFedora::Base.find(id) }
        migration.target.save
      end
      object_report
    end
    def migrate_resources(source)
      subject = source.uri
      predicate = MEMBER_OF.to_s
      enum = FedoraMigrate.source.connection.find_by_sparql Cul::Ac3::Migrations.sparql_inbound(subject, predicate)
      enum.each do |resource|
        report = migrate_object resource, {'content' => ResourceContentMigration}
        yield report.object.id
      end
    end
    def migrate_relationship(source)
      relationship_report = find_or_create_single_object_report(source)
      begin
        relationship_report.relationships = Cul::Ac3::Migrations::RelsExtDatastreamMover.new(source).migrate
        relationship_report.status = true
      rescue StandardError => e
        relationship_report.relationships = e.inspect
        relationship_report.status = false
      end
      report.results[source.pid] = relationship_report
    end
  end
end