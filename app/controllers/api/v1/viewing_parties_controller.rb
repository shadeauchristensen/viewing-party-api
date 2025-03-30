class Api::V1::ViewingPartiesController < ApplicationController
    def create
        begin
            data = params.require(:data).require(:attributes)

            party = ViewingParty.create!(
                name: data[:name],
                start_time: data[:start_time],
                end_time: data[:end_time],
                movie_id: data[:movie_id],
                movie_title: data[:movie_title]
            )

            valid_invitees = data[:invitees].filter_map { |id| User.find_by(id: id) }

            valid_invitees.each do |user|
                ViewingPartyUser.create!(
                    user_id: user.id,
                    viewing_party_id: party.id
                )
            end

            render json: ViewingPartySerializer.new(party), status: :created

            required_fields = [:name, :start_time, :end_time, :movie_id, :movie_title]

            required_fields.each do |field|
                if data[field].blank?
                    render json: { message: "Attribute #{field} is missing. Cannot be blank.", status: 400 }, status: :bad_request and return
                end
            end
        end
    end
end