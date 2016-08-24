module Bitybit
  class Indexer

    attr_reader :name, :scope, :feature_extractor, :client

    def initialize(name, scope, feature_extractor)
      @name = name
      @scope = scope
      @feature_extractor = feature_extractor
      @client = Bitybit::Client.new "i:#{name}"
    end

    def index(id)
      record = scope.where(id: id).first
      if record
        index_doc record
      else
        clear_doc id
      end
    end

    def index_all!
      count = scope.count
      done = 0
      started = Time.now.to_f
      scope.find_in_batches(batch_size: 500) do |batch|
        process_batch batch
        done += batch.size
        taken = Time.now.to_f - started
        yield done, count, taken if block_given?
      end
    end

    def with_temporary(&new_indexer)
      prefix = SecureRandom.hex 6
      indexer = self.class.new prefix, scope, feature_extractor
      yield indexer
      # We rename the old indexer back to here...
      indexer.client.rename client.prefix
      true
    end

    private

    def process_batch(batch)
      converted = convert_records batch
      index_batch converted
    end

    def convert_records(records)
      records.map do |record|
        s = feature_extractor.new(record)
        [s.to_object_id, s.to_feature_keys]
      end
    end

    def index_doc(record)
      converted = feature_extractor.new(record)
      client.index converted.to_object_id, converted.to_feature_keys
    end


    def clear_doc(id)
      client.clear id
    end

    def index_batch(batch)
      batch.each do |(id, features)|
        client.index id, features
      end
    end

  end
end
