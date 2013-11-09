module SVGGVS
  class Session
    attr_accessor :svg_source, :svg_merged_target, :individual_files_path, :on_card_finished
    attr_accessor :png_files_path, :png_export_width, :pdf_card_size, :pdf_dpi
    attr_accessor :pdf_target

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
      @process.call
    end

    def with_new_target
      file.with_new_target do |target|
        yield target
      end

      card_finished!
    end
  end
end

