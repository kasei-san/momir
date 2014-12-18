class CardsController < ApplicationController
   def pickup
    if params.has_key?(:converted_mana_cost)
      converted_mana_cost = Integer(params[:converted_mana_cost])
      render :json => ::Card.pickup(converted_mana_cost).to_json
    else
      render
    end
  end
end
