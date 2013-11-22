require 'roo'

module SVGGVS
  class DataSource
    def initialize(file)
      @file = file
    end

    def doc
      @doc ||= Roo::Spreadsheet.open(@file)
    end

    def settings
      settings = {}

      doc.each_with_pagename do |name, sheet|
        if name['SVGGVS Settings']
          sheet.each do |setting, value|
            settings[setting.spunderscore.to_sym] = value
          end
        end
      end

      settings
    end

    def each_card
      doc.each_with_pagename do |name, sheet|
        if name['Card Data']
          headers = sheet.row(1)

          (sheet.first_row + 1).upto(sheet.last_row) do |index|
            card_data = {
              :active_layers => [],
              :replacements => {}
            }

            headers.zip(sheet.row(index)).each do |header, cell|
              if header['Active Layer']
                card_data[:active_layers] += cell.split(';')
              else
                card_data[:replacements][header] = cell
              end
            end

            yield card_data
          end
        end
      end
    end
  end
end

