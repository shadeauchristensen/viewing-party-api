class Api::V1::ViewingPartiesController < ApplicationController
    def create
        begin
            data = params.require(:data).require(:attributes)
            required_fields = [:name, :start_time, :end_time, :movie_id, :movie_title]

            missing_field = required_fields.find { |field| data[field].blank? }

            if missing_field
                render json: { message: "Attribute #{missing_field} is missing. Cannot be blank.", status: 400 }, status: :bad_request
            
            else
                if Time.parse(data[:end_time]) < Time.parse(data[:start_time])
                    render json: { message: "End time cannot be BEFORE start time.", status: 400 }, status: :bad_request
                    return
                end
                
                movie = MovieDbService.movie_details(data[:movie_id])
                movie_runtime = movie[:runtime]
                party_duration = Time.parse(data[:end_time]) - Time.parse(data[:start_time])
                party_duration_minutes = party_duration / 60 

                if party_duration_minutes < movie_runtime
                    render json: { message: "Party duration cannot be shorter than the movies runtime (#{movie_runtime} minutes.)", status: 400}, status: :bad_request
                    return
                end
                
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
            end
        end
    end
end