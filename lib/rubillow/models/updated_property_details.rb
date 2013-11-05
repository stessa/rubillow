require 'ostruct'

module Rubillow
  module Models
    # List of updated attributes for a property.
    class UpdatedPropertyDetails < Base
      include Zpidable
      include Addressable
      include Linkable
      include Images
      
      # @return [Hash] number of page views (:current_month, :total).
      #
      # @example
      #   puts page_views[:current_month]
      #
      attr_accessor :page_views
      
      # @return [String] price.
      attr_accessor :price
      
      # @return [String] neighborhood.
      attr_accessor :neighborhood
      
      # @return [String] elementary school's name.
      attr_accessor :elementary_school
      
      # @return [String] middle school's name.
      attr_accessor :middle_school
      
      # @return [String] school district's name.
      attr_accessor :school_district
      
      # @return [String] Realtor provided home description
      attr_accessor :home_description
      
      # @return [Hash] posting information 
      #
      # @example
      #   posting.each do |key, value|
      #   end
      # 
      attr_accessor :posting
      
      # @return [Hash] list of edited facts
      #
      # @example
      #   edited_facts.each do |key, value|
      #   end
      #
      attr_accessor :edited_facts
      
      protected
      
      # @private
        def parse
          super

          return if !success?

          extract_zpid(@parser)
          extract_links(@parser)
          extract_address(@parser)
          extract_images(@parser)

          @page_views = {
            :current_month => (@parser.xpath('//pageViewCount/currentMonth').first.text rescue nil),
            :total => (@parser.xpath('//pageViewCount/total').first.text rescue nil)
          }
          puts @parser.xpath
          @price = OpenStruct.new( @parser.xpath('//price').first ? { price: @parser.xpath('//price').first.text, code: 0, message: "Successful price from xml" }: just_use_zestimate(@parser) || { message: "No price available on this", code: -1})

          @neighborhood = @parser.xpath('//neighborhood').first.text rescue nil
          @school_district = @parser.xpath('//schoolDistrict').first.text rescue nil
          @elementary_school = @parser.xpath('//elementarySchool').first.text rescue nil
          @middle_school = @parser.xpath('//middleSchool').first.text rescue nil
          @home_description = @parser.xpath('//homeDescription').first.text rescue nil

          @posting = {}
          @parser.xpath('//posting').children.each do |elm|
              @posting[underscore(elm.name).to_sym] = elm.text
          end

          @edited_facts = {}
          @parser.xpath('//editedFacts').children.each do |elm|
              @edited_facts[underscore(elm.name).to_sym] = elm.text
          end
      end

      def just_use_zestimate(parser)
          if parser.xpath('//zestimate/amount').first
              return  {message: "No updated Value, using property zestimate", code: 1, price: parser.xpath('//zestimate/amount').first }
          else
              return nil
          end
      end
      
      # @private
      def underscore(string)
        word = string.to_s.dup
        word.gsub!(/::/, '/')
        word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
        word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
        word.gsub!(/\-/, '_')
        word.downcase!
        word
      end
    end
  end
end
