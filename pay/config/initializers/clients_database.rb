# frozen_string_literal: true

CLIENTS_DB = YAML::load(ERB.new(File.read(Rails.root.join('config', 'clients_database.yml'))).result)[Rails.env]
