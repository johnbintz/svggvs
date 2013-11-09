require 'delegate'

module SVGGVS
  class Target < SimpleDelegator
    attr_reader :target

    def initialize(target)
      @target = target
    end

    def __getobj__
      @target
    end

    def active_layers=(layers)
      css("g[inkscape|groupmode='layer']").each do |layer|
        if layers.include?(layer['inkscape:label'])
          layer['style'] = ''
        else
          layer['style'] = 'display:none'
        end
      end
    end

    def replacements=(replacements)
      @replacements = replacements
    end

    def replaced(node = @target)
      if !!@replacements
        node.children.each do |child|
          if child.text?
            if match = child.content[%r{\{% ([^ ]+) %\}}, 1]
              child.content = @replacements[match] || ''
            end
          else
            replaced(child)
          end
        end
      end
    end
  end
end
