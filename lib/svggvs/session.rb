module SVGGVS
  class Session
    attr_accessor :svg_source, :svg_merged_target, :individual_files_path, :on_card_finished
    attr_accessor :png_files_path, :png_export_width, :pdf_card_size, :pdf_dpi
    attr_accessor :pdf_target, :card_back, :card_size, :target, :post_read_data

    def initialize
      @index = 0
    end

    def configure
      yield self
    end

    def process(&block)
      @process = block
    end

    def card_finished!
      @on_card_finished.call(@index) if @on_card_finished

      @index += 1
    end

    def on_card_finished(&block)
      @on_card_finished = block
    end

    def file
      @file ||= SVGGVS::File.new(@svg_source)
    end

    def run
      if !!@card_size && !!@target
        settings_from_hash(EXPORT_DEFAULTS[@card_size.spunderscore.to_sym][@target.spunderscore.to_sym])
      end

      @process.call
    end

    def settings_from_hash(hash)
      hash.each do |setting, value|
        self.send("#{setting}=", value)
      end
    end

    def with_new_target
      file.with_new_target do |target|
        yield target
      end

      card_finished!
    end

    def data_source=(source)
      data_source = DataSource.new(source)

      settings_from_hash(data_source.settings)

      @process = proc do
        data_source.each_card do |card|
          if !!@post_read_data
            @post_read_data.call(card)
          end

          with_new_target do |target|
            target.active_layers = card[:active_layers]
            target.replacements = card[:replacements]
          end
        end
      end
    end

    EXPORT_DEFAULTS = {
      :poker => {
        :the_game_crafter => {
          :pdf_card_size => '750x1050',
          :pdf_dpi => 300,
          :png_export_width => 825
        }
      }
    }.freeze
  end
end

