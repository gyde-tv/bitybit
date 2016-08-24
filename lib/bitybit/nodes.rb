require 'securerandom'
module Bitybit
  module Nodes

    class Null

      def inspect
        "NULL"
      end

      def resolved?
        true
      end

      def clear(on)
      end

      def resolve(on)
        nil
      end

      def hashable_key
        "NULL"
      end

      def present?
        false
      end

    end

    class Key < Struct.new(:key)

      def hashable_key
        key
      end

      def inspect
        key
      end

      def resolved?
        true
      end

      def resolve(on)
        self
      end

      def clear(on)
      end

      def present?
        true
      end

    end

    class BitwiseOperation < Struct.new(:operation, :children)

      def present?
        case operation
        when 'AND'
          children.present? && children.all?(&:present?)
        else
          children.present? && children.any?(&:present?)
        end
      end

      def hashable_key
        Digest::SHA256.hexdigest "#{operation}:#{children.map(&:hashable_key).sort.uniq.join(",")}"
      end

      def initialize(operation, children)
        super operation.to_s.upcase, Array.wrap(children)
      end

      def inspect

        operator = {'AND' => " & ", 'OR' => ' | '}.fetch(operation) { raise "Unknown operation '#{operation}'" }
        "(#{children.map { |child| child.inspect }.join(operator)})"
      end

      # Returns a key with the results
      def resolve(redis, &key_converter)
        key_converter ||= :to_s.to_proc
        resolved_children = children.map { |child| child.resolve(redis, &key_converter) }
        redis.bitop operation, key_converter.call(temporary_key), *resolved_children.map { |key| key_converter.call(key.key) }.compact.uniq
        Key.new temporary_key
      end

      def clear(redis, &key_converter)
        key_converter ||= :to_s.to_proc
        children.each { |c| c.clear redis, &key_converter }
        redis.del key_converter.call(temporary_key)
      end

      def temporary_key
        @temporary_key ||= "op:#{SecureRandom.uuid}"
      end

      def resolved?
        false
      end

    end

    def self.make(item)
      items = Array.wrap item

      if items.empty?
        Null.new
      elsif items.size == 2
        operation = items.first
        choices = Array.wrap(items.last)
        if choices.one?
          make choices.first
        else
          BitwiseOperation.new operation, choices.map { |c| make c }
        end
      else
        Key.new items.first.to_s
      end
    end

  end
end
