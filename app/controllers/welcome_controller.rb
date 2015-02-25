class WelcomeController < ApplicationController
  def index
    @reports = Report.where(report_params)
  end

  private

  def report_params
    params.permit(:sort_by => nil, :number => nil)
  end
end
