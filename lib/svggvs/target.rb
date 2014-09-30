require 'delegate'

module SVGGVS
  class Target < SimpleDelegator
    attr_reader :target

    def initialize(target, options)
      @target, @options = target, options
    end

    def __getobj__
      @target
    end

    def injected_sources
      @injected_sources ||= {}
    end

    def injected_defs
      @injected_defs ||= {}
    end

    def file_layers
      @file_layers ||= css("g[inkscape|groupmode='layer']")
    end

    def child_visible_layers
      @child_visible_layers ||= file_layers.find_all { |layer| layer['inkscape:label'].include?('(child visible)') }
    end

    def inject!
      file_layers.each do |layer|
        if filename = layer['inkscape:label'][/inject (.*\.svg)/, 1]
          injected_sources[filename] ||= begin
                                            data = Nokogiri::XML(::File.read(filename))

                                            injected_defs[filename] = data.css("svg > defs")

                                            data.css("svg > g[inkscape|groupmode='layer']")
                                          end

          injected_sources[filename].each do |additional_layer|
            layer << additional_layer.to_xml
          end
        end
      end
    end

    def active_layers=(layers)
      file_layers.each do |layer|
        layer['style'] = if layer['inkscape:label'].include?('(visible)')
                           ''
                         else
                           'display:none'
                         end
      end

      file_layers.each do |layer|
        if layers.include?(layer['inkscape:label'])
          layer['style'] = ''

          current_parent = layer.parent

          while current_parent && current_parent.name == "g" && current_parent['style'] != ''
            current_parent['style'] = ''

            current_parent = current_parent.parent
          end

          layers.delete(layer)
        end

        break if layers.empty?
      end

      loop do
        any_changed = false
        child_visible_layers.each do |layer|
          if layer['style'] != '' && layer.parent['style'] == ''
            layer['style'] = ''

            any_changed = true
          end
        end
        break if !any_changed
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

    def cache
      @options[:cache]
    end

    # only uncloning text
    def unclone
      file_layers.find_all { |layer| layer['style'] == '' }.each do |layer|
        layer.css('svg|use').each do |clone|
          if source = cache.is_clone_dup_type(clone['xlink:href'])
            new_group = clone.add_next_sibling("<g />").first

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

