# Process Inkscape files and create sets of cards for board games

Not much in the way of docs yet. You'll need `inkscape`, `convert`, `montage`, and `gs` in your `PATH`.

Create a `Cardfile` in your working directory. It should look
something like this:

``` ruby
@session.configure do |c|
  c.svg_source = "template/template.svg"
  c.svg_merged_target = "template/output.svg"

  c.png_export_width = 825
  c.pdf_card_size = "750x1050"
  c.pdf_dpi = 300

  c.individual_files_path = "template/output/card_%02d.svg"
  c.png_files_path = "template/png/card_%02d.png"

  c.pdf_target = "merged.pdf"
end

@session.process do
  require 'google_drive'
  require 'virtus'
  require 'active_support/inflector'

  require './card_definitions.rb'

  CardDefinitions.processed.each do |card|
    @session.with_new_target do |target|
      datum = card.to_svggvs

      # #active_layers indicates what sublayers within the "Source" layer of
      # the Inkscape document should be toggled as visible. All others are hidden.
      target.active_layers = datum[:active]

      # Any text with {% liquid_like_tags %} will have those tags replaced with the
      # values within the hash passed in.
      # Additionally, you can label the following and have things replaced:
      # * svg:flowRoot will replace the text in the svg:flowPara within
      # * svg:text will replace the text in the first svg:tspan within
      # * svg:image will replace the xlink:href of the tag, changing the image to load
      target.replacements = datum[:replacements]
    end
  end
end
```

You can also have a `.cardrc` file which is run before loading the `Cardfile`.

Process your cards with `svggvs`:

* `svggvs merged_file`: Create a big SVG file with all cards as layers. Fine for simple setups, but will create monster files!
* `svggvs svgs`: Write out individual SVG files.
* `svggvs pngs`: Write out PNG files after writing out the SVG files.
* `svggvs pdf`: Write out the merged PnP PDF file.

You can also pass in `--cardfile <new file>` to load a different cardfile, say for
card backs.

