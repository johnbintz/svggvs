require 'nokogiri'

module SVGGVS
  class File
    def initialize(path_or_doc)
      @instance = 0

      case path_or_doc
      when String
        @path = path_or_doc
      else
        @doc = path_or_doc
      end
    end

    def source
      return @source if @source

      @source = doc.at_css('g[inkscape|label="Source"]')
      @source['style'] = 'display:none'
      @source
    end

    def root
      source.parent
    end

    def target
      @target ||= doc.at_css('g[inkscape|label="Target"]')
    end

    def defs
      @defs ||= doc.at_css('defs')
    end

    def original_defs
      @original_defs ||= defs.children.collect(&:to_xml).join
    end

    def reset_defs!
      defs.children.each(&:remove)

      defs << original_defs
    end

    def doc
      return @doc if @doc

      @doc = Nokogiri::XML(::File.read(@path))
      clear_targets!

      original_defs

      @doc
    end

    def clear_targets!
      target.children.each(&:remove)
    end

    def with_new_target
      new_target = source.dup
      new_target[:id] = new_target[:id] + "_#{@instance}"
      new_target['inkscape:label'] = new_target['inkscape:label'] + "_#{@instance}"

      target_obj = Target.new(new_target)

      reset_defs!

      yield target_obj

      target_obj.replaced
      target_obj.unclone

      target << target_obj.target

      target_obj.injected_defs.values.each do |v|
        defs << v
      end

      @instance += 1
    end

    def dup_with_only_last_target
      dupe = self.class.new(doc.dup)

      target = dupe.target.children.last.dup
      target[:style] = ''

      dupe.target.remove

      dupe.root.children.each do |child|
        child[:style] = 'display:none'
      end

      dupe.root << target

      dupe
    end

    def save(file)
      for_save_doc = doc.dup
      for_save_doc.css('g[inkscape|label]').each do |group|
        if (group[:style] || '').include?('display:none')
          if !(group['inkscape:label'] || '').include?('(protect)')
            group.remove
          end
        end
      end

      ::File.open(file, 'w') { |fh| fh.print for_save_doc.to_xml }
    end
  end
end

