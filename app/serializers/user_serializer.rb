class UserSerializer
  include JSONAPI::Serializer
  
  attributes :name, :username
  attribute :viewing_parties_hosted do |user|
    user.viewing_party_users.select(&:host).map do |vpu|
      party = vpu.viewing_party
      {
        id: party.id,
        name: party.name,
        start_time: party.start_time,
        end_time: party.end_time,
        movie_id: party.movie_id,
        movie_title: party.movie_title,
        host_id: user.id,
      }
    end
  end

  attribute :viewing_parties_invited do |user|
    user.viewing_party_users.reject(&:host).map do |vpu|
      party = vpu.viewing_party
      {
        id: party.id,
        name: party.name,
        start_time: party.start_time,
        end_time: party.end_time,
        movie_id: party.movie_id,
        movie_title: party.movie_title,
        host_id: party.viewing_party_users.find_by(host: true)&.user&.id
      }
    end
  end

  def self.format_user_list(users)
    { data:
        users.map do |user|
          {
            id: user.id.to_s,
            type: "user",
            attributes: {
              name: user.name,
              username: user.username
            }
          }
        end
    }
  end
end