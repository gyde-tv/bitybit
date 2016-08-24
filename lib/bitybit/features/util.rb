module Bitybit
  module Features
    module Util

      def box(value, range)
        [[range.min, value].max, range.max].min
      end

      def normalize_percent(value)
        rounded = (value.to_f * 100).round
        box rounded, 0..100
      end

      def normalize_score(score)
        return nil if score.blank?
        return -1 if score.zero?
        (Math.log2(score) * 5).round
      end

      def normalize_film_score(score)
        (score * 10).round
      end

    end
  end
end
