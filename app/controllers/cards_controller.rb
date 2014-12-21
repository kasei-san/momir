class CardsController < ApplicationController
   def pickup
    if params.has_key?(:converted_mana_cost)
      converted_mana_cost = Integer(params[:converted_mana_cost].first)
      @card = ::Card.pickup(converted_mana_cost)
    end

    respond_to do |format|
      format.js
      format.html
    end
  end
end
