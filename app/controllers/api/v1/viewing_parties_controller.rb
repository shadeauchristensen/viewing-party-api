class Api::V1::ViewingPartiesController < ApplicationController
    def create
        begin
            puts params.inspect
        attributes = params[:data][:attributes]
        host_id = params[:data][:id].to_i

        party = ViewingParty.create!(
          name: attributes[:name],
          start_time: attributes[:start_time],
          end_time: attributes[:end_time],
          movie_id: attributes[:movie_id],
          movie_title: attributes[:movie_title]
        )

        ViewingPartyUser.create!(
          user_id: host_id,
          viewing_party_id: party.id,
          host: true
        )

        attributes[:invitees].each do |invitee_id|
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