module Bitybit
  class Queryer

    attr_reader :name, :scope, :client

    def initialize(name, scope)
      @name = name
      @scope = scope
      @client = Bitybit::Client.new "i:#{name}"
    end

    def query_ids(query)
      normalized = query_to_bitwise_operation query
      client.query_operation(normalized).to_a
    end

    def query(query, limit)
      ids = query_ids(query)
      scope.where(id: ids).limit(limit).all
    end

    def query_to_bitwise_operation(query)
      if !query.is_a?(Hash)
        raise ArgumentError.new("Your query must start as a hash, mmmkay?")
      end
      conditions = []
      query.to_a.map do |key, value|
        conditions << [:or, Bitybit::KeyConverter.convert(key => value)]
      end
      Bitybit::Nodes.make [:and, conditions]
    end
  end
end
