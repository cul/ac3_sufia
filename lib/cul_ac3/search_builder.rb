class Cul::Ac3::SearchBuilder < Sufia::SearchBuilder
  def include_collection_ids(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "{!join from=hasCollectionMember_ssim to=id}id:#{collection.id.gsub(':','\:')}"
  end

  def include_work_ids(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "{!join from=hasCollectionMember_ssim to=id}id:#{scope.id.gsub(':','\:')}"
  end
end