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

          current_parent = layer.parent

          while current_parent && current_parent.name == "g"
            current_parent['style'] = ''

            current_parent = current_parent.parent
          end
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
            if label = child['inkscape:label']
              if !!@replacements[label]
                if flow_para = child.css('svg|flowPara').first
                  flow_para.content = @replacements[label] || ''
                end

                if span = child.css('svg|tspan').first
                  span.content = @replacements[label] || ''
                end

                if child.name == "image" && !!@replacements[label]
                  child['xlink:href'] = ::File.expand_path(@replacements[label])
                end
              end
            end

            replaced(child)
          end
        end
      end
    end

    # only uncloning text
    def unclone
      css('svg|use').each do |clone|
        if source = css(clone['xlink:href']).first
          if source.name == 'flowRoot' || source.name == 'text'
            new_group = clone.add_next_sibling("<svg:g />").first

            clone.attributes.each do |key, attribute|
              new_group[attribute.name] = attribute.value
            end

            new_group << source.dup

            clone.remove
          end
        end
      end
    end
  end
end

