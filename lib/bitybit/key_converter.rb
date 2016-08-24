require 'digest/sha2'

module Bitybit
  class KeyConverter

    attr_reader :params

    def self.convert(params)
      new(params).to_features
    end

    def self.convert_hashed(params)
      new(params).to_hashed_features
    end

    def initialize(params)
      @params = params
    end

    def to_features
      normalize(params).map { |k| k.join(":") }
    end

    def to_hashed_features
      to_features.map { |f| Digest::SHA256.hexdigest(f)[0, 12] }
    end

    def normalize(value)
      case value
      when Hash
        out = []
        value.map do |key, subvalue|
          # We don't index blank values...
          next if subvalue.blank?
          k = key.to_s
          normalize(subvalue).each do |item|
            out << ([key] + item)
          end
        end
        out
      when Array
        value.map do |item|
          normalize(item)
        end
      when Range
        normalize value.to_a
      else
        [[value.to_s]]
      end
    end

  end
end
