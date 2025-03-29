class Api::V1::ViewingPartiesController < ApplicationController
    def create
        begin
            party = ViewingParty.create!(
                name: params[:name],
                start_time: params[:start_time],
                end_time: params[:end_time],
                movie_id: params[:movie_id],
                movie_title: params[:movie_title]
            )
            # if viewing party is valid/ has correct user id, use serializer to create viewing party
            ViewingPartyUser.create!(
                user_id: params[:host_id],
                viewing_party_id: party.id,
                host: true
            )

            params[:invitees].each do |invitee_id|
                ViewingPartyUser.create!(
                  user_id: invitee_id.to_i,
                  viewing_party_id: party.id,
                  host: false
                )
            end

            render json: ViewingPartySerializer.new(party), status: :created 
        rescue => error
            render json: { error: "Unexpected error occurred: #{error.message}" }, status: :internal_server_error
        end
    end
end