# Process Inkscape files and create sets of cards for board games

You'll need `inkscape`, `convert`, `montage`, and `gs` in your `PATH`. After installing the
gem, run `svggvs prereqs` to see what you need installed and, potentially, how to install it.

### Using Inkscape in /Applications on Mac OS X

If you've installed Inkscape on Mac OS X and want to use that version instead of one from Homebrew,
you'll need to follow these directions for setting up a shell alias: http://wiki.inkscape.org/wiki/index.php/MacOS_X#Inkscape_command_line

## Initialize a starter project

Install the gem globally with `gem install svggvs` and then run `svggvs install <project>` where `project`
is the name of the directory to place the skeleton project files. You'll get a few files in there:

* `template.svg`, an Inkscape template that shoows how to do the basic SVGGVS template setup
* `data.ods`, a LibreOffice spreadsheet that defines the card data and project settings
* `Cardfile`, the file SVGGVS uses to find the data file and optionally process the spreadsheet data after-the-fact
* `Gemfile`, in case you need additional gems. It has SVGGVS added already, but you may also want remote
  data gems like `google_drive`, for instance.

## How it works

Create an Inkscape SVG file in your project directory. Make sure it has a Source and a Target layer.
Your card template is made up of sublayers in the Source layer. These layers are copied to the Target layer
upon processing.
By default, layers are hidden, and hidden layers are deleted after copying to the Target layer,
unless they have the following names:

* (visible): The layer is always visible, regardless if it's specified in `#active_layers`
* (protect): The layer will not be deleted if it is hidden. Good for clone sources.
* (child visible): The layer will be visible if its parent layer is also made visible. Good if you
                   break artwork up into multiple layers (inks, colors, shading, etc.)
* (inject filename.svg): Include all the layers of another SVG file as child layers of this layer.
                         Copies some elements from `<defs>` from the injected file!

Hiding/showing layers is the way that you make certain card elements appear/disappear on
different types of cards with with different properties. You can also replace the text in
text boxes (both standard and flowroot boxes) by giving those boxes a distinct label (under Object Properties).

Create a spreadsheet in the same directory, or on Google Drive. This project uses the Roo gem
to read spreadsheets, so as long as Roo can read it, you're good to do.

Give the sheets names so that SVGGVS knows what to do with them:

* Put "Card Data" somewhere in the name for SVGGVS to use it as a data source
* Name it "SVGGVS Settings" to define your project's settings.

Under SVGGVS settings, you can currently set the following, as a series of two-column rows:

* Card Size: Right now, only one option: Poker
* Target: Right now, only one option: The Game Crafter
* SVG Source: The SVG template file
* Individual Files Path: Where final SVG files go
* PNG Files Path: Where rendered PNG files go
* PDF Target: Where the print-n-play PDF goes

The following can be manually specified if you don't provide Card Size and Target:

* PNG Export Width: The width of the exported card from Inkscape
* PDF Card Size: The size a card is cropped down to before being placed on the PnP PDF
* PDF DPI: The DPI of the PDF file

The following Card Size and Target settings set these to the following:

* The Game Crafter
  * Poker
    * PNG Export Width: 825
    * PDF Card Size: 750x1050
    * PDF DPI: 300
  * Small Square Tile
    * PNG Export Width: 600
    * PDF Card Size: 675x675
    * PDF DPI: 300
  * Square Shard
    * PNG Export Width: 225
    * PDF Card Size: 300x300
    * PDF DPI: 300

Create a `Cardfile` in your working directory. It should look something like this:

``` ruby
@session.configure do |c|
  # manipulate the data after reading from the spreadsheet
  # c.post_read_data = proc { |data|
  #  data[:replacements]['Superpower Text'] << '!!'
  # }

  # only sheets with this in the title will be read for card data
  # c.card_sheet_identifier = "Card Data"

  # prepend this PDF to the outputted PDF (useful for game rules)
  # c.prepend_pdf = "rules.pdf"

  c.data_source = "data.ods"
end
```

All of the settings that could be set in your spreadsheet can also be set here. See
`SVGGVS::Session` for more details.

You can also have a `.cardrc` file which is run before loading the `Cardfile`.

Process your cards with `svggvs`:

* `svggvs merged_file`: Create a big SVG file with all cards as layers. Fine for simple setups, but will create monster files!
* `svggvs svgs`: Write out individual SVG files.
* `svggvs pngs`: Write out PNG files after writing out the SVG files.
* `svggvs pdf`: Write out the merged PnP PDF file.

You can also pass in `--cardfile <new file>` to load a different cardfile, say for
card backs.

