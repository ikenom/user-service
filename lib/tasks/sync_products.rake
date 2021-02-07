# frozen_string_literal: true

desc "Sync e-commerce data with Contentful models"
task sync_products: :environment do
  SynchronizerJob.perform_later
end
