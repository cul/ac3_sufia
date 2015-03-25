require 'active_fedora/cleaner'
require 'fedora-migrate'
class Ldp::Resource::RdfSource
  attr_accessor :prefixes
  def content options=nil
    options ||= {prefixes: self.prefixes || {}}
    graph.dump(:ttl,options) if graph
  end
end
namespace :ac3 do
  namespace :migrate do
    desc "migrate objects from a list of PIDs"
    task list: :environment do
      list = ENV['list']
      unless list && File.exists?(list)
        puts "usage: rake ac3:migrate:list list=LIST_PATH"
      else
        ac = ::RDF::URI("info:fedora/ac#")
        migrator = Cul::Ac3::Migrations::ListMigrator.new('ac', list:list,prefixes:{ac:ac})
        migrator.migrate_objects
        migrator.migrate_relationships # this is where we need to add DC and RELS-INT migration
        migrator
      end
    end
  end
end