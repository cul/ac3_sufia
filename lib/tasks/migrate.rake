require 'active_fedora/cleaner'

namespace :ac3 do
  namespace :migrate do
    desc "migrate objects from a list of PIDs"
    task list: :environment do
      list = ENV['list']
      unless list && File.exists?(list)
        puts "usage: rake ac3:migrate:list list=LIST_PATH"
      else
        migrator = Cul::Ac3::ListMigrator.new('ac', list:list)
        migrator.migrate_objects
        migrator.migrate_relationships # this is where we need to add DC and RELS-INT migration
        migrator
      end
    end
  end
end