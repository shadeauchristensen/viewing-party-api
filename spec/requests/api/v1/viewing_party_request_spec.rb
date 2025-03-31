require "rails_helper"

RSpec.describe "Viewing_Party API", type: :request do
    describe "POST api/v1/viewing_party" do 
        before(:each) do
            @invitee_1 = create(:user)
            @invitee_2 = create(:user, name: "Ceci", username: "titanic_forever")
            @invitee_3 = create(:user, name: "Peyton", username: "star_wars_geek_8")
        end

        it "HAPPY PATH: creates a viewing_party using ids from users", :vcr do
            party_attributes = {
                data: {
                    type: "viewing_party",
                    attributes: {
                        name: "Juliet's Bday Movie Bash!",
                        start_time: "2025-02-01T10:00:00.000Z",
                        end_time: "2025-02-01T14:30:00.000Z",
                        movie_id: 278,
                        movie_title: "The Shawshank Redemption",
                        invitees: [@invitee_1.id, @invitee_2.id, @invitee_3.id]
                    }
                }
            }

            post "/api/v1/viewing_parties", params: party_attributes

            expect(response).to have_http_status(:created)

            json = JSON.parse(response.body, symbolize_names: true)

            attributes = json[:data][:attributes]

            expect(attributes[:name]).to eq("Juliet's Bday Movie Bash!")
            expect(attributes[:movie_id]).to eq(278)
            expect(attributes[:movie_title]).to eq("The Shawshank Redemption")
            expect(attributes[:invitees].count).to eq(3)

            invitee_names = attributes[:invitees].map { |invitee| invitee[:name] }
            expect(invitee_names).to include("Barbara", "Ceci", "Peyton")
        end

        it "SAD PATH: returns 400 error if attributes are missing" do
            missing_attributes = {
                data: {
                    type: "viewing_party",
                    attributes: {
                        name: "",
                        start_time: "2025-02-01T10:00:00.000Z",
                        end_time: "2025-02-01T14:30:00.000Z",
                        movie_id: 278,
                        movie_title: "The Shawshank Redemption",
                        invitees: [@invitee_1.id, @invitee_2.id, @invitee_3.id]
                    }
                }
            }

            post "/api/v1/viewing_parties", params: missing_attributes

            expect(response).to have_http_status(:bad_request)

            json = JSON.parse(response.body, symbolize_names: true)

            expect(json[:message]).to eq("Attribute name is missing. Cannot be blank.")
            expect(json[:status]).to eq(400)
        end

        it "SAD PATH: returns 400 is end_time is earlier than start_time" do
            party_attributes = {
                data: {
                    type: "viewing_party",
                    attributes: {
                        name: "Juliet's Bday Movie Bash!",
                        start_time: "2025-02-01T14:30:00.000Z",
                        end_time: "2025-02-01T10:00:00.000Z",
                        movie_id: 278,
                        movie_title: "The Shawshank Redemption",
                        invitees: [@invitee_1.id, @invitee_2.id, @invitee_3.id]
                    }
                }
            }

            post "/api/v1/viewing_parties", params: party_attributes

            expect(response).to have_http_status(:bad_request)

            json = JSON.parse(response.body, symbolize_names: true)

            expect(json[:message]).to eq("End time cannot be BEFORE start time.")
            expect(json[:status]).to eq(400)
        end

        it "SAD PATH: returns 400 if the party length is shorter than the move runtime" do
            party_attributes = {
                data: {
                    type: "viewing_party",
                    attributes: {
                        name: "Juliet's Bday Movie Bash!",
                        start_time: "2025-02-01T10:00:00.000Z",
                        end_time: "2025-02-01T11:00:00.000Z",
                        movie_id: 278,
                        movie_title: "The Shawshank Redemption",
                        invitees: [@invitee_1.id, @invitee_2.id, @invitee_3.id]
                    }
                }
            }

            post "/api/v1/viewing_parties", params: party_attributes

            expect(response).to have_http_status(:bad_request)

            json = JSON.parse(response.body, symbolize_names: true)

            expect(json[:message]).to eq("Party duration cannot be shorter than the movies runtime (142 minutes.)")
            expect(json[:status]).to eq(400)
        end

        it "SAD PATH: returns and skips any user who is invalid" do
            party_attributes = {
                data: {
                    type: "viewing_party",
                    attributes: {
                        name: "Juliet's Bday Movie Bash!",
                        start_time: "2025-02-01T10:00:00.000Z",
                        end_time: "2025-02-01T14:30:00.000Z",
                        movie_id: 278,
                        movie_title: "The Shawshank Redemption",
                        invitees: [@invitee_1.id, 777888, 888999]
                    }
                }
            }

            post "/api/v1/viewing_parties", params: party_attributes

            expect(response).to have_http_status(:created)

            json = JSON.parse(response.body, symbolize_names: true)

            json_invitees = json[:data][:attributes][:invitees]

            expect(json_invitees.count).to eq(1)
            expect(json_invitees[0][:id]).to eq(@invitee_1.id)
        end
    end
end