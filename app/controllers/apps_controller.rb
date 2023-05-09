# frozen_string_literal: true

class AppsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_app, only: %i[update]

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

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_app
    @app = App.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def app_params
    params.require(:app).permit(:id, :name, :description, :country, :artwork, :list_id)
  end
end
