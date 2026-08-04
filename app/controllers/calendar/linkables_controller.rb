module Calendar
  class LinkablesController < ApplicationController
    def search
      resultado = Calendar::LinkableSearchService.new(params).call
      resultado.send_response self
    end
  end
end
