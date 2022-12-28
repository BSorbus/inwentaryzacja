class StaticPagesController < ApplicationController

  caches_page :home, :home_alert, :declaration, :gzip => :best_speed

  def home
  end

  def home_alert
  end

  def declaration
  end

end
