module Rubillow
  module Models
    # List of comps for a given property with deep data.
    class DeepSearchResults < Base
      # @return [Models::DeepSearchResult] principal property.
      attr_accessor :principal
      
      # @return [Hash] comparables list (key => comparable's score, value => {Models::DeepSearchResult}).
      #
      # @example
      #  comparables.each do |score, comp|
      #    puts score
      #    puts comp.price
      #  end
      attr_accessor :results
      
      protected
      
      # @private
      def parse
        super
        
        return if !success?
        
        # @principal = DeepSearchResult.new(@parser.xpath('//principal').to_xml)
        
        @results = Array.new
        @parser.xpath('//result').each do |elm|
          puts elm.to_s
          # key = elm.attribute('zpid').value
          @results.push DeepSearchResult.new(elm.to_xml)
        end
      end
    end
  end
end