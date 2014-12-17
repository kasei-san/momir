class CardsController < ApplicationController
  def pickup
    converted_mana_cost = Integer(params[:converted_mana_cost])
    render :json => ::Card.pickup(converted_mana_cost).to_json
  end
end
