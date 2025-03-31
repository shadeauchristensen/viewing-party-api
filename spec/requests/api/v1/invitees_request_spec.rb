require "rails_helper"

RSpec.describe "Invitee API", type: :request do
    describe "POST /api/v1/viewing_parties/:id/invitees" do
        before(:each) do
            @user = create(:user)
            @party=create(:viewing_party)
            create(:viewing_party_user, user: @user, viewing_party: @party)
        end

        it "HAPPY PATH: adds new invitee to an existing viewing party", :vcr do
            new_user = create(:user, username: "Test user")

            post "/api/v1/viewing_parties/#{@party.id}/invitees", params: { invitees_user_id: new_user.id }

            expect(response).to have_http_status(:created)

            json = JSON.parse(response.body, symbolize_names: true)

            invitees = json[:data][:attributes][:invitees]
            invitees_ids = invitees.map { |invitee| invitee[:id] }

            expect(invitees_ids).to include(new_user.id)
            expect(invitees.count).to eq(2)
        end

        it "SAD PATH: returns 400 if the viewing party ID isnt valid" do
            new_user = create(:user, username: "Test user")

            post "/api/v1/viewing_parties/9999/invitees", params: { invitees_user_id: new_user.id }

            expect(response).to have_http_status(:bad_request)

            json = JSON.parse(response.body, symbolize_names: true)

            expect(json[:error]).to eq("Couldn't find ViewingParty with 'id'=9999")
        end

        it "SAD PATH: returns 400 if the invitee user ID is invalid" do
            post "/api/v1/viewing_parties/#{@party.id}/invitees", params: { invitees_user_id: 999999 }
          
            expect(response).to have_http_status(:bad_request)
          
            json = JSON.parse(response.body, symbolize_names: true)

            expect(json[:error]).to eq("Couldn't find User with 'id'=999999")
        end
    end
end