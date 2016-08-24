require 'digest/sha2'
require 'fast_bitset'
require 'bitwise'

module Bitybit
  class Client

    class Result < Struct.new(:value)

      delegate :[], :each, :to_a, to: :ids

      def inspect
        "<#{self.class.name} count=#{count} checksum=#{checksum[0, 8]}>"
      end

      def checksum
        @_checksum ||= Digest::SHA256.hexdigest(value)
      end

      def count
        @_count ||= Bitwise.population_count(value)
      end

      def ids
        @_ids ||= FastBitset.bitstring_to_ids(value)
      end

    end

    class << self

      attr_writer :redis

      def redis
        @redis ||= Redis.current
      end

    end

    attr_reader :prefix, :redis

    def initialize(prefix, redis = self.class.redis)
      @prefix = prefix.to_s
      @redis = redis
    end

    def query_operation(operation)

      STDOUT.puts "Executing indexing query: #{operation.inspect}"

      return [] unless operation.present?

      if !operation.respond_to?(:resolve) && !operation.respond_to?(:clear)
        raise ArgumentError.new("#{operation.inspect} doesn't implement the operation protocol.")
      end

      resolved = operation.resolve(redis) { |key| k key }
      value = redis.get k(resolved.key)
      operation.clear(redis) { |key| k key }

      return Result.new(value.to_s)
    end

    def index(id, features)
      features.each do |key|
        redis.setbit k(key), id, 1
      end
    end

    def clear(id)
      keys.each do |key|
        redis.setbit k(key), id, 0
      end
    end

    def rename(new_prefix)
      existing_keys = redis.keys k("*", new_prefix)
      renaming = keys.map { |key| [k(key), k(key, new_prefix)] }
      redis.multi do
        existing_keys.in_groups_of(50, false) do |batch|
          redis.del *batch
        end
        renaming.each do |keys|
          redis.rename *keys
        end
      end
    end

    private

    def k(key, before = prefix)
       "#{before}:#{key.to_s}"
    end

    def keys
      redis.keys(prefix + ":*").sort.map { |k| k.gsub("#{prefix}:", "") }
    end

  end
