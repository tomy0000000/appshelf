# frozen_string_literal: true

require 'faraday'
require 'json'

class AppsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_app, only: %i[show update destroy]
  before_action :fetch_app, only: %i[peak create update]

  def peak
    @body = JSON.pretty_generate(@body)
  end

  # GET /apps/1 or /apps/1.json
  def show; end

  # POST /apps or /apps.json
  def create
    app_data = @body['results'][0]
    @app = App.new(_id: app_data['trackId'].to_s, name: app_data['trackName'],
                   description: app_data['description'], list_id: params[:app][:list_id])

    respond_to do |format|
      if @app.save
        format.html { redirect_to app_url(@app), notice: 'App was successfully created.' }
        format.json { render :show, status: :created, location: @app }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @app.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /apps/1 or /apps/1.json
  def update
    app_data = @body['results'][0]
    respond_to do |format|
      if @app.update(name: app_data['trackName'], description: app_data['description'])
        format.html { redirect_to app_url(@app), notice: 'App was successfully updated.' }
        format.json { render :show, status: :ok, location: @app }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @app.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /apps/1 or /apps/1.json
  def destroy
    @app.destroy

    respond_to do |format|
      format.html { redirect_to apps_url, notice: 'App was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_app
    @app = App.find(params[:id])
  end

  def fetch_app
    app_id = params[:app] ? params[:app][:id] : params[:id]
    response = Faraday.get('https://itunes.apple.com/lookup', { id: app_id })
    @body = JSON.parse(response.body)

    return unless response.status != 200 || @body['resultCount'].zero?

    Rails.logger.debug { "App with ID #{app_id} does not exist" }
    @app = App.new
    flash.now[:notice] = "App with ID #{app_id} does not exist"
    render :show, status: :not_found
    nil
  end

  # Only allow a list of trusted parameters through.
  def app_params
    params.require(:app).permit(:id, :name, :description, :list_id)
  end
end
