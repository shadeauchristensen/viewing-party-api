class Api::V1::UsersController < ApplicationController
  def create
    user = User.new(user_params)
    if user.save
      render json: UserSerializer.new(user), status: :created
    else
      render json: ErrorSerializer.format_error(ErrorMessage.new(user.errors.full_messages.to_sentence, 400)), status: :bad_request
    end
  end

  def index
    render json: UserSerializer.format_user_list(User.all)
  end

  def show
    begin
      user = User.find(params[:id])
      render json: UserSerializer.new(user)
    rescue ActiveRecord::RecordNotFound
      render json: { message: "Invalid User ID", status: 404 }, status: :bad_request
  end

  private

  def user_params
    params.permit(:name, :username, :password, :password_confirmation)
  end
end