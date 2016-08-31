class RecommendationsController < ApplicationController

  def create
    @recommendation = Recommendation.new(params[:recommendation])
    @recommendation.save

  end

  private

    def recommendation_params
      params.require(:recommendation).permit(:userid, :post_date, :doctor_name)
    end
end
