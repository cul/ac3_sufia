require 'spec_helper'
require 'rubydora'
describe Cul::Ac3::Migrations do
  describe '#sparql_inbound' do
    it do
      expect(Cul::Ac3::Migrations.sparql_inbound('x','y')).to match(/\?pid \<y\> \<x\>/)
    end
  end
  describe '#sparql_outbound' do
    it do
      expect(Cul::Ac3::Migrations.sparql_outbound('x','y')).to match(/\<x\> \<y\> \?pid/)
    end
  end
  describe Cul::Ac3::Migrations::DescMetadataMigration do
    let(:rubydora) { instance_double(FedoraMigrate::RubydoraConnection,connection: repository) }
    let(:repository) { double(Rubydora::Repository) }
    before do
      FedoraMigrate.instance_variable_set(:@source,rubydora)
      allow_any_instance_of(FedoraMigrate::ContentMover).to receive(:perform_sparql_insert).and_return(instance_double("status",status:201,body:'SUCCESS'))
    end
    after do
      FedoraMigrate.instance_variable_set(:@source,nil)
    end
    it "should look the source up in the ResourceIndex" do
      source = instance_double("Source Fedora 3 Object",:datastreams => {},:uri => 'foo')
      descDS = instance_double("Datastream", content: "hullabaloo",label:"MODS Content",mimeType: "text/nil",checksum:"fakechecksum",createDate:Date.new)
      descMetadata = instance_double("Attached File",original_name:'descMetadata.xml',mime_type:'text/nil',digest:'fakechecksum')
      target = instance_double("Target", attached_files: {'descMetadata' => descMetadata})
      desc_source = instance_double("Description Fedora 3 Object",:datastreams => {'CONTENT' => descDS})
      allow(repository).to receive(:find_by_sparql).with(Cul::Ac3::Migrations.sparql_inbound('foo','http://purl.oclc.org/NET/CUL/metadataFor'))
        .and_return([desc_source])
      allow(descMetadata).to receive(:original_name=)
      expect(descMetadata).to receive(:mime_type=).with('text/nil')
      expect(descMetadata).to receive(:content=).with('hullabaloo')
      expect(descMetadata).to receive(:original_name=).with('descMetadata.xml')
      expect(descMetadata).to receive(:save).and_return(descMetadata)
      Cul::Ac3::Migrations::DescMetadataMigration.new(source,target,ds_key:'descMetadata').migrate 
    end
  end
end
