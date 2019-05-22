require 'rails_helper'

RSpec.describe Playbooks::Sync::CloudSpace do

  describe 'test "active" schema state' do
    let (:schema) do
      {
        id: ResourceIdSequence.nextval,
        location_id: $location.id,
        state: 'active',
      }
    end

    it "cloud_space does not exist" do
      cloud_space = nil
      synchronizer = Playbooks::Sync::CloudSpace.new(schema, cloud_space)
      resp = synchronizer.sync

      expect(resp).to be true
      expect(synchronizer.cloud_space.id).to eq(schema[:id])
      expect(synchronizer.cloud_space.state).to eq('active')
      # log(synchronizer.cloud_space.to_json)
    end

    it "cloud_space is active" do
      cloud_space = CloudSpace.create!({
        id: schema[:id],
        location_id: schema[:location_id],
        state: 'active',
      })
      synchronizer = Playbooks::Sync::CloudSpace.new(schema, cloud_space)
      resp = synchronizer.sync
      expect(resp).to be true
      expect(synchronizer.cloud_space.id).to eq(schema[:id])
      expect(synchronizer.cloud_space.state).to eq('active')
    end

  end

  describe 'test "deleted" schema state' do
    let (:cloud_space) do
      schema = {
        id: ResourceIdSequence.nextval,
        location_id: $location.id,
        state: 'active',
      }
      cloud_space = nil

      synchronizer = Playbooks::Sync::CloudSpace.new(schema, cloud_space)
      synchronizer.sync
      synchronizer.cloud_space
    end

    let (:schema) do
      {
        id: cloud_space.id,
        location_id: $location.id,
        state: 'deleted',
      }
    end

    it "delete active cloud_space" do
      expect(cloud_space.state).to eq('active')
      synchronizer = Playbooks::Sync::CloudSpace.new(schema, cloud_space)
      resp = synchronizer.sync
      expect(resp).to be true
      expect(synchronizer.cloud_space.id).to eq(schema[:id])
      expect(synchronizer.cloud_space.state).to eq('deleted')
    end

    it "delete deleted cloud space" do
      cloud_space.update_attributes(state: 'deleted')
      expect(cloud_space.state).to eq('deleted')
      synchronizer = Playbooks::Sync::CloudSpace.new(schema, cloud_space)
      resp = synchronizer.sync
      expect(resp).to be true
      expect(synchronizer.cloud_space.id).to eq(schema[:id])
      expect(synchronizer.cloud_space.state).to eq('deleted')
    end

  end

end
