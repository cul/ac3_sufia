class GenericWorksController < ApplicationController
  include Sufia::Controller
  include Sufia::WorksControllerBehavior
  #include ApplicationController::Override
  #self.solr_search_params_logic += [:scrub_pid]

  def search_builder_class
    Cul::Ac3::SearchBuilder
  end

  def collection_member_search_builder_class
    Cul::Ac3::SearchBuilder
  end

  def scrub_pid(solr_parameters,user_parameters)
    #raise solr_parameters.inspect
    scrubbed = params[:id]
    scrubbed = scrubbed.gsub(':','\:')
    if scrubbed
      solr_parameters.each do |k,v|
        Array(v).each {|x| x.gsub!(params[:id],scrubbed) if x.respond_to? :gsub }
      end
    end
  end
end