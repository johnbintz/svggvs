require 'pathname'

module SVGGVS
  class Context
    attr_reader :individual_files

    def initialize(cardfile = "Cardfile")
      @cardfile = cardfile

      @individual_files = []
    end

    def self.load(cardfile = "Cardfile")
      context = new(cardfile)
      context.load
      context
    end

    def session
      @session ||= SVGGVS::Session.new
    end

    def cardrc?
      ::File.file?('.cardrc')
    end

    def load
      session

      if cardrc?
        self.instance_eval(::File.read('.cardrc'))
      end

      self.instance_eval(cardfile_rb)
    end

    def cardfile_rb
      @cardfile_rb ||= ::File.read(@cardfile)
    end

    def write_merged_file
      session.on_card_finished = nil
      session.run

      session.file.save @session.svg_merged_target
    end

    def write_individual_files
      session.on_card_finished do |index|
        target = Pathname(session.individual_files_path % index)

        target.parent.mkpath

        session.file.dup_with_only_last_target.save target.to_s

        @individual_files << target
      end

      session.run
    end
  end
end

