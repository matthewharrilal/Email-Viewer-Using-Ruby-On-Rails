class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  require 'google/apis/gmail_v1'
  require 'gmail'

  # GET /users
  # GET /users.json

  def redirect
    client = Signet::OAuth2::Client.new({
                                            client_id: ENV.fetch('GOOGLE_API_CLIENT_ID'),
                                            client_secret: ENV.fetch('GOOGLE_API_CLIENT_SECRET'),
                                            authorization_uri: ENV.fetch('AUTH_URL'),
                                            scope: Google::Apis::GmailV1::AUTH_GMAIL_READONLY,
                                            redirect_uri: url_for(:action => :callback)
                                        })

    redirect_to client.authorization_uri.to_s
  end

  def callback
    client = Signet::OAuth2::Client.new({
                                            client_id: ENV.fetch('GOOGLE_API_CLIENT_ID'),
                                            client_secret: ENV.fetch('GOOGLE_API_CLIENT_SECRET'),
                                            token_credential_uri: ENV.fetch('TOKEN_URL'),
                                            redirect_uri: url_for(:action => :callback),
                                            code: params[:code]
                                        })

    response = client.fetch_access_token!

    session[:access_token] = response['access_token']

    redirect_to url_for(:action => :labels)
  end

  def index
    # redirect()
    # Gmail.client_id = "422730833804-9q4j2hlmmn6ab0n943qbjur4315b0h1u.apps.googleusercontent.com"
    # Gmail.client_secret = "THtO1j1ky9mfy2fylrVmB4fz"
    # Gmail.refresh_token = "matthew.harrilal@students.makeschool.com"
    # message = Gmail::Message.all
    #     byebug
    #

    gmail = Gmail.connect("basic.bob.make@gmail.com", "basic.bob")
    # @users = User.all
    @users = gmail.inbox.all
    byebug
    format.json { render :show, status: :created, location: @user }
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    UserMailer.registration_confirmation(@user).deliver_now
    respond_to do |format|
      if @user.save
        format.json { render :show, status: :created, location: @user }
      else
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :email, :birth_date)
    end
end
