module SVGGVS
  CROP_MARK_SIZE = 20.freeze

  class PDF
    def initialize(options)
      @options = options
    end

    def self.border_size
      ([ CROP_MARK_SIZE ] * 2).join('x')
    end

    def page_size_with_crop_marks
      [ card_width * 3, card_height * 3 ].collect { |size| size + CROP_MARK_SIZE * 2 }.join('x')
    end

    def generate_crop_mark_directives
      (0..3).collect { |index|
        pos_x = CROP_MARK_SIZE + index * card_width
        pos_y = CROP_MARK_SIZE + index * card_height

        [ [ 0 ], [ CROP_MARK_SIZE + page_height ] ].collect { |size|
          [ pos_x ] + size + [ pos_x, size.first + CROP_MARK_SIZE ]
        } +
        [ [ 0 ], [ CROP_MARK_SIZE + page_width ] ].collect { |size|
          size + [ pos_y ] + [ size.first + CROP_MARK_SIZE, pos_y ]
        }
      }.flatten(1).collect { |sx, sy, ex, ey| "#{sx},#{sy} #{ex},#{ey}" }
    end

    def generate_crop_mark_draws
      generate_crop_mark_directives.collect { |coords| %{-stroke black -strokewidth 3 -draw "line #{coords}"} }
    end

    private
    def card_width
      card_size.first
    end

    def card_height
      card_size.last
    end

    def page_height
      card_height * 3
    end

    def page_width
      card_width * 3
    end

    def card_size
      @card_size ||= @options[:card_size].split('x').collect(&:to_i)
    end
  end
end

