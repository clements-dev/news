require "sinatra"
require "sinatra/reloader"
require "geocoder"
require "forecast_io"
require "httparty"
require 'time'
def view(template); erb template.to_sym; end
before { puts "Parameters: #{params}" }                                     

# enter your Dark Sky API key here
ForecastIO.api_key = "2f5cea499b11e77ad6b3da05cd73855c"
news_key = "c1fd44e73a4d4b6f88ca7e816785c864"
news_url = "https://newsapi.org/v2/top-headlines?country=us&apiKey=" + news_key


get "/" do
    view "ask"
end

get "/news" do
    # Find the location coordinates
    results = Geocoder.search(params["set_location"])

    # Get location coordinates
    location_coord = results.first.coordinates # => [lat, long]
    country_code = results.first.country_code

    # Get weather information for the previous location
    weather_forecast = ForecastIO.forecast(location_coord[0], location_coord[1]).to_hash

    # Get the news
    news_url = "https://newsapi.org/v2/top-headlines?country=" + country_code + "&apiKey=" + news_key
    @news_data = HTTParty.get(news_url).parsed_response.to_hash

    # -----------------------------------------------
    # Build weather
    # -----------------------------------------------
    weather_html = ""

    # -------------------
    # Current weather
    weather_icon = weather_forecast["currently"]["icon"]
    weather_summary = weather_forecast["currently"]["summary"]
    weather_temp  = weather_forecast["currently"]["temperature"]
    weather_uv = weather_forecast["currently"]["uvIndex"]

    weather_html = weather_html  + '<div class="card bg-light mb-3" style="max-width: 18rem;">'
    weather_html = weather_html  + '<div class="card-header">Today</div>'
    weather_html = weather_html  + '  <div class="card-body">'
    weather_html = weather_html  + '    <img src="/img/' + weather_icon + '.svg" style="height: 50%; width: 50%">'
    weather_html = weather_html  + '    <h5 class="card-title">' + "#{weather_summary}" + '</h5>'
    weather_html = weather_html  + '    <p class="card-text">Temp.: ' + "#{weather_temp}" + '</p>'
    weather_html = weather_html  + '    <p class="card-text">UV Index: ' + "#{weather_uv}" + '</p>'
    weather_html = weather_html  + '  </div>'
    weather_html = weather_html  + '</div>'

    # -------------------
    # Forecast
    for dforecast in weather_forecast["daily"]["data"]
        weather_time = Time.at(dforecast["time"])
        weather_icon = dforecast["icon"]
        weather_summary = dforecast["summary"]
        weather_temp_h  = dforecast["temperatureHigh"]
        weather_temp_l  = dforecast["temperatureLow"]
        
        weather_html = weather_html  + '<div class="card bg-light mb-3" style="max-width: 18rem;">'
        weather_html = weather_html  + '<div class="card-header">' + weather_time.strftime("%a - %F") + '</div>'
        weather_html = weather_html  + '  <div class="card-body">'
        weather_html = weather_html  + '    <img src="/img/' + "#{weather_icon}" + '.svg" style="height: 50%; width: 50%">'
        weather_html = weather_html  + '    <h5 class="card-title">' + "#{weather_summary}" + '</h5>'
        weather_html = weather_html  + '    <p class="card-text">Temp. High: ' + "#{weather_temp_h}" + '</p>'
        weather_html = weather_html  + '    <p class="card-text">Temp. Low: ' + "#{weather_temp_l}" + '</p>'
        weather_html = weather_html  + '  </div>'
        weather_html = weather_html  + '</div>'
    end
    @display_weather = weather_html

    # -----------------------------------------------
    # Build news
    # -----------------------------------------------

    view "news"
end