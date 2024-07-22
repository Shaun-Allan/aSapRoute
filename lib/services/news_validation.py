from flask import Flask, request, jsonify
from datetime import datetime, timedelta
from Countrydetails import countries
from gnews import GNews


app = Flask(__name__)

data = countries.all_countries()
countries_list = list(data.countries())

country = countries.all_countries()
states_codes = country.states()
state_names = [states_codes['India'][i]['name'] for i in range(len(states_codes['India']))]



states_names_single_word = []
for state in state_names:
    states_names_single_word.extend(state.split())


states_names_single_word = [x for x in states_names_single_word if x != 'and']
states_names_single_word

landslide_keywords = [
    "Landslide", "Landslides",
    "Landslip", "Landslips",
    "Debris", "Flow", "Debrisflow", "Debrisflows",
    "Mudslide", "Mudslides",
    "Rockslide", "Rockslides",
    "Rockfall", "Rockfalls",
    "Earthflow", "Earthflows",
    "Slope", "Failure", "Slopefailure", "Slopefailures",
    "Soil", "Erosion", "Soilerosion", "Soilerosions",
    "Mass", "Wasting", "Masswasting", "Masswastings",
    "Subsidence", "Subsidences",
    "Slope", "Stability", "Slopestability", "Slopestabilities",
    "Slump", "Slumps",
    "Creep", "Creeps",
    "Avalanche", "Avalanches",
    "Lahar", "Lahars",
    "Geohazard", "Geohazards",
    "Ground", "Movement", "Groundmovement", "Groundmovements",
    "Slope", "Deformation", "Slopedeformation", "Slopedeformations",
    "Seismic", "Activity", "Seismicactivity", "Seismicactivities",
    "Rain", "Induced", "Landslide", "Raininducedlandslide", "Raininducedlandslides",
    "Flood", "Related", "Landslide", "Floodrelatedlandslide", "Floodrelatedlandslides",
    "Hillside", "Collapse", "Hillsidecollapse", "Hillsidecollapses",
    "Terrain", "Instability", "Terraininstability", "Terraininstabilities",
    "Geotechnical", "Analysis", "Geotechnicalanalysis", "Geotechnicalanalyses",
    "Groundwater", "Pressure", "Groundwaterpressure", "Groundwaterpressures",
    "Slope", "Reinforcement", "Slopereinforcement", "Slopereinforcements",
    "Erosion", "Control", "Erosioncontrol", "Erosioncontrols",
    "Geological", "Survey", "Geologicalsurvey", "Geologicalsurveys",
    "Hazard", "Mapping", "Hazardmapping", "Hazardmappings",
    "Damage", "Damages",
    "Destruction", "Destructions",
    "Harm", "Harms",
    "Impact", "Impacts",
    "Ruin", "Ruins",
    "Catastrophe", "Catastrophes",
    "Devastation", "Devastations",
    "Disaster", "Disasters",
    "Loss", "Losses",
    "Desolation", "Desolations",
    "Wreck", "Wrecks",
    "Calamity", "Calamities",
    "Blight", "Blights",
    "Injury", "Injuries",
    "Trauma", "Traumas"
]

dates_list = [
    '1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th', '9th', '10th',
    '11th', '12th', '13th', '14th', '15th', '16th', '17th', '18th', '19th', '20th',
    '21st', '22nd', '23rd', '24th', '25th', '26th', '27th', '28th', '29th', '30th',
    '31st', "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December",
    "2010", "2011", "2012", "2013", "2014", "2015", "2016", "2017",
    "2018", "2019", "2020", "2021", "2022", "2023", "2024" ]

final_list = []
final_list = [x for x in landslide_keywords]
final_list = final_list + states_names_single_word
final_list = final_list + dates_list
#print(final_list)
final_list = [x.lower() for x in final_list]
#print(final_list)

def exp_key_extr(text,final_list):
  text_list =text.split()
  print(text_list)
  keywords =[]
  for i in text_list:
    if i.lower() in final_list:
      keywords.append(i)
  return keywords

def create_query(kword_list):
    """Takes keyword list and joins them
    to be used in google search"""
    query = " AND ".join(kword_list)
    return query

"""## News Hits"""
def filter_by_date(news_sources, days):
    valid_news = []
    current_date = datetime.now()
    date_limit = current_date - timedelta(days=days)

    for news in news_sources:
        try:
            news_date = datetime.strptime(news['published date'], "%a, %d %b %Y %H:%M:%S %Z")
            if news_date >= date_limit:
                valid_news.append(news)
        except ValueError as e:
            print(f"Date format error: {e}")

    return valid_news

def validate_news(news_source,keywords):
    article = google_news.get_full_article( news_source['url'])
    for j in keywords:
      if j not in article.text:
        return False
    return True

def check_verifiable_website(url):
    news_sites = [
        "https://www.livemint.com","https://timesofindia.indiatimes.com","https://www.thehindu.com","https://www.deccanherald.com",
        "https://www.ndtv.com","https://indianexpress.com","https://floodlist.com","https://www.aljazeera.com","https://www.reuters.com",
        "https://www.hindustantimes.com","https://www.indiatoday.in","https://indianexpress.com","https://www.news18.com"
    ]
    return any(url.startswith(site) for site in news_sites)

google_news = GNews(country='IN',period= '14d')

@app.route('/get_news', methods=['POST'])
def get_news():
    data = request.json
    text = data.get('text', '')

    keywords = exp_key_extr(text, final_list)
    query = create_query(keywords)
    print(query)

    news_sources = google_news.get_news(query)
    v_news = [news for news in news_sources if validate_news(news,keywords)]
    #news_sources_in_date_range = filter_by_date(v_news, 14)
    valid_news = [news for news in v_news if check_verifiable_website(news['publisher']['href'])]

    response = [{"title": news['title'], "published_date": news['published date']} for news in valid_news]

    return jsonify(response)

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=3000, debug=True)