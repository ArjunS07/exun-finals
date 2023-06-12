from geopy.geocoders import Nominatim
from geopy.distance import geodesic

geolocator = Nominatim(user_agent="exun-hackathons-app")

from geopy.geocoders import Nominatim
geolocator = Nominatim(user_agent='myapplication')

def get_city_coords(city: str) -> tuple:
    """Returns the coordinates of the city"""
    print(city)
    location = geolocator.geocode(city)
    if location is None:
        return (0, 0)
    return location.latitude, location.longitude

def get_distance_between_cities(city_1: str, city_2: str) -> float:
    """Returns the distance between two cities in km"""
    coords_1 = get_city_coords(city_1)
    coords_2 = get_city_coords(city_2)
    return geodesic(coords_1, coords_2).km