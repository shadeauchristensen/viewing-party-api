class Api::V1::InviteesController < ApplicationController
    def create
        begin
            party = ViewingParty.find(params[:viewing_party_id])
            user = User.find(params[:invitees_user_id])

            ViewingPartyUser.create!(viewing_party: party, user: user)

            render json: ViewingPartySerializer.new(party), status: :created

        rescue  ActiveRecord::RecordNotFound => error 
            render json: { message: error.message }, status: :bad_request
        rescue ActiveRecord::RecordInvalid => error
            render json: { message: error.message }, status: :bad_request
        end        
    end
end