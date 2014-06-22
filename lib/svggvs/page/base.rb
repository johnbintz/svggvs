module SVGGVS
  module Page
    class Base
      def initialize(options)
        @options = options
      end

      def cards_per_page
        self.class::CARDS_X * self.class::CARDS_Y
      end

      def montage_tiling
        [ self.class::CARDS_X, self.class::CARDS_Y ].join('x')
      end

      private
      def card_width
        card_size.first
      end

      def card_height
        card_size.last
      end

      def page_height
        card_height * cards_per_width
      end

      def page_width
        card_width * cards_per_height
      end

      def card_size
        @card_size ||= @options[:card_size].split('x').collect(&:to_i)
      end
    end
  end
end

require_relative './letter/poker'
require_relative './letter/small_shard'
require_relative './letter/small_square_tile'

