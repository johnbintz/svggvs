require_relative './svggvs/file'
require_relative './svggvs/target'
require_relative './svggvs/context'
require_relative './svggvs/session'
require_relative './svggvs/data_source'

module SVGGVS
end

require 'active_support/core_ext/string/inflections'

class String
  def spunderscore
    self.underscore.gsub(' ', '_')
  end
end
