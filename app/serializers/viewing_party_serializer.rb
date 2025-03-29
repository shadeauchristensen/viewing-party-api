class ViewingPartySerializer 
    include JSONAPI::Serializer

    set_type :viewing_party
    attributes :name, :start_time, :end_time, :movie_id, :movie_title

    attribute :invitees do |object|
        object.users.map do |user|
            {
                id: user.id,
                name: user.name,
                username: user.username
            }
        end
    end
end