require 'active_fedora/cleaner'

namespace :ac3 do
  namespace :migrate do
    desc "migrate objects from a list of PIDs"
    task list: :environment do
      list = ENV['list']
      unless list && File.exists?(list)
        puts "usage: rake ac3:migrate:list list=LIST_PATH"
      else
        open(list) do |blob|
          blob.each {|line| puts line.strip}
        end
      end
    end
  end
end