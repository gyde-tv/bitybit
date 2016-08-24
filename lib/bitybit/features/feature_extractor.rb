module Bitybit
  module Features
    class FeatureExtractor
      include Bitybit::Features::Util

      attr_reader :object

      def initialize(object)
        @object = object
      end

      def generate_features(object)
        raise NotImplementedError.new("Please implement #{self.class.name}#generate_features(object)")
      end

      def to_feature_hash
        generate_features(object)
      end

      def to_object_id
        @object_id ||= object.id
      end

      def to_feature_keys
        @feature_keys ||= Bitybit::KeyConverter.convert(to_feature_hash)
      end

    end
  end
end
