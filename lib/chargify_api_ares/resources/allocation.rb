module Chargify
  class Allocation < Base
    self.prefix = "/subscriptions/:subscription_id/components/:component_id/"

    def self.bulk_create_prefix(opts = {})
      subscription_id = opts[:subscription_id]
      raise ArgumentError, 'subscription_id required' if subscription_id.nil?

      "/subscriptions/#{subscription_id}/allocations.#{connection.format.extension}"
    end

    def self.bulk_create(opts = {})
      return [] if opts[:allocations].blank?

      subscription_id = opts.delete(:subscription_id)
      raise ArgumentError, 'subscription_id required' if subscription_id.nil?

      json_format = ActiveResource::Formats[:json]
      orig_format = connection.format
      begin
        connection.format = json_format
        format = json_format
        response = connection.post(
          bulk_create_prefix(subscription_id: subscription_id),
          format.encode(opts),
          headers
        )
        instantiate_collection(format.decode(response.body))
      ensure
        connection.format = orig_format
        format = orig_format
      end
    end

    def self.preview_prefix(opts = {})
      subscription_id = opts[:subscription_id]
      raise ArgumentError, 'subscription_id required' if subscription_id.nil?
      "/subscriptions/#{subscription_id}/allocations/preview.#{connection.format.extension}"
    end

    def self.preview(opts = {})
      return [] if opts[:allocations].blank?

      subscription_id = opts.delete(:subscription_id)
      raise ArgumentError, 'subscription_id required' if subscription_id.nil?

      json_format = ActiveResource::Formats[:json]
      orig_format = connection.format
      begin
        connection.format = json_format
        format = json_format
        response = connection.post(
          preview_prefix(subscription_id: subscription_id),
          connection.format.encode(opts),
          headers
        )
        instantiate_record(connection.format.decode(response.body))
      ensure
        connection.format = orig_format
        format = orig_format
      end
    end

    # Needed to avoid ActiveResource using Chargify::Payment
    # when there is a Payment inside an Allocation.
    # This Payment is an output-only attribute of an Allocation.
    class Payment < Base
    end
  end
end
