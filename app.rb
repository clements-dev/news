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
    @country_code = results.first.country_code
    city = results.first.city
    country = results.first.country
    if city==""
        @location_txt = country
    else
        @location_txt = country + "&emsp;|&emsp;" + city
    end

    # Get weather information for the previous location
    weather_forecast = ForecastIO.forecast(location_coord[0], location_coord[1]).to_hash

    # Get the news
    news_url = "https://newsapi.org/v2/top-headlines?country=" + @country_code + "&apiKey=" + news_key
    news_data = HTTParty.get(news_url).parsed_response.to_hash
    @blabla = news_data

    # -----------------------------------------------
    # Build weather
    # -----------------------------------------------
    weather_html = ""

    # -------------------
    # Current weather

    # Retrieve data
    weather_time = Time.at(weather_forecast["currently"]["time"])
    weather_icon = weather_forecast["currently"]["icon"]
    weather_summary = weather_forecast["currently"]["summary"]
    weather_temp  = weather_forecast["currently"]["temperature"]
    weather_wind  = weather_forecast["currently"]["windSpeed"]
    weather_uv = weather_forecast["currently"]["uvIndex"]

    # Build html
    weather_html = weather_html  + '<div class="col-md-2">'
    weather_html = weather_html  + '<div class="card bg-light mb-3 h-100" style="max-width: 18rem;">'
    weather_html = weather_html  + '<div class="card-header bg-secondary" style="color: white;">Today<br>' + weather_time.strftime("%b %d") + '</div>'
    weather_html = weather_html  + '  <div class="card-body">'
    weather_html = weather_html  + '    <img src="/img/' + weather_icon + '.svg">'
    weather_html = weather_html  + '    <h6 class="card-title"><b>' + "#{weather_summary}" + '</b></h6>'
    weather_html = weather_html  + '    <p class="card-text">Temp.: ' + "#{weather_temp}" + '&#176;F</p>'
    weather_html = weather_html  + '    <p class="card-text">Wind: ' + "#{weather_wind}" + '</p>'
    weather_html = weather_html  + '    <p class="card-text">UV Index: ' + "#{weather_uv}" + '</p>'
    weather_html = weather_html  + '  </div>'
    weather_html = weather_html  + '</div>'
    weather_html = weather_html  + '</div>'

    # -------------------
    # Forecast
    c = 1
    for dforecast in weather_forecast["daily"]["data"]
        c = c + 1
        # Maximum days to display
        if c > 6
            break
        end

        # Retrieve data
        weather_time = Time.at(dforecast["time"])
        weather_icon = dforecast["icon"]
        weather_summary = dforecast["summary"]
        weather_temp_h  = dforecast["temperatureHigh"]
        weather_temp_l  = dforecast["temperatureLow"]
        
        # Build html
        weather_html = weather_html  + '<div class="col-md-2">'
        weather_html = weather_html  + '<div class="card bg-light mb-3 h-100" style="max-width: 18rem;">'
        weather_html = weather_html  + '<div class="card-header">' + weather_time.strftime("%A") + '<br>' + weather_time.strftime("%b %d") + '</div>'
        weather_html = weather_html  + '  <div class="card-body">'
        weather_html = weather_html  + '    <img src="/img/' + "#{weather_icon}" + '.svg">'
        weather_html = weather_html  + '    <h6 class="card-title"><b>' + "#{weather_summary}" + '</b></h6>'
        weather_html = weather_html  + '    <p class="card-text">Temp. High: ' + "#{weather_temp_h}" + '&#176;F</p>'
        weather_html = weather_html  + '    <p class="card-text">Temp. Low: ' + "#{weather_temp_l}" + '&#176;F</p>'
        weather_html = weather_html  + '  </div>'
        weather_html = weather_html  + '</div>'
        weather_html = weather_html  + '</div>'
    end
    @display_weather = weather_html

    # -----------------------------------------------
    # Build news
    # -----------------------------------------------
    news_html = ""
    
    if news_data["totalResults"]>0

        news_html = news_html + '<div id="accordion">'

        c = 0
        for i_news in news_data["articles"]
            c = c + 1
            # Maximum news to display
            if c > 10
                break
            end

            # Retrieve data
            news_source = i_news["source"]["name"]
            news_author = i_news["author"]
            news_title = i_news["title"]
            news_description = i_news["description"]
            news_url = i_news["url"]
            news_img_url = i_news["urlToImage"]
            news_pub = i_news["publishedAt"]

            # Build html
            news_html = news_html + '<div class="row">'
            news_html = news_html + '<div class="col-md-12">'
            news_html = news_html + '<div class="card">'
            news_html = news_html + '   <div class="card-header" id="heading' + "#{c}" + '">'
            news_html = news_html + '       <h4 class="mb-0 text-left" style="font-weight: bold;">'
            news_html = news_html + '           <button class="btn" data-toggle="collapse" data-target="#collapse' + "#{c}" + '" aria-expanded="false" aria-controls="collapse' + "#{c}" + '">'
            news_html = news_html + '               <b>' + "#{news_title}" + '</b>'
            news_html = news_html + '           </button>'
            news_html = news_html + '       </h4>'
            news_html = news_html + '   </div>'
            news_html = news_html + ''
            news_html = news_html + '   <div id="collapse' + "#{c}" + '" class="collapse" aria-labelledby="heading' + "#{c}" + '" data-parent="#accordion">'
            news_html = news_html + '       <div class="card-body">'
            news_html = news_html + '           <div class="row">'
            news_html = news_html + '               <div class="col-md-3">'
            news_html = news_html + '                   <img src="' + "#{news_img_url}" + '" style="width: 100%; height: auto">'
            news_html = news_html + '               </div>'
            news_html = news_html + '               <div class="col-md-9 text-justify">'
            news_html = news_html + '                   <p>' + "#{news_description}" + '<i><a class="text-right" href="' + "#{news_url}" + '" target="_blank">'
            news_html = news_html + '                   <br>Read more...</a></i></p>'
            news_html = news_html + '                   <p><i>Source: ' + "#{news_source}" + ' | Author: ' + "#{news_author}" + '</i></p>'
            news_html = news_html + '               </div>'
            news_html = news_html + '           </div>'
            news_html = news_html + '       </div>'
            news_html = news_html + '   </div>'

            news_html = news_html + '</div>'
            news_html = news_html + '</div>'
            news_html = news_html + '</div>'
            news_html = news_html + '<div class="row"><p></p></div>'
        end

        news_html = news_html + '</div>'
    end

    @display_news = news_html

    view "news"
end