require_relative '../spec_helper'
require 'svggvs/pdf'
require 'digest/md5'

describe SVGGVS::PDF do
  subject { SVGGVS::PDF.new(options) }

  let(:options) {
    { card_size: '100x100' }
  }

  describe '#page_size_with_crop_marks' do
    it "should have the right size" do
      subject.page_size_with_crop_marks.should be == "340x340"
    end
  end

  describe '#generate_crop_mark_directives' do
    let(:result) {
      [
        "20,0 20,20",
        "20,320 20,340",
        "120,0 120,20",
        "120,320 120,340",
        "220,0 220,20",
        "220,320 220,340",
        "320,0 320,20",
        "320,20 340,20",
        "320,120 340,120",
        "320,220 340,220",
        "320,320 320,340",
        "320,320 340,320",
        "0,20 20,20",
        "0,120 20,120",
        "0,220 20,220",
        "0,320 20,320",
      ]
    }

    it 'should create correct definitions' do
      subject.generate_crop_mark_directives.each { |coords|
        result.should include(coords)
      }
    end
  end
end
