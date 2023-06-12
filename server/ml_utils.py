import pickle
import pandas as pd
from location_utils import get_distance_between_cities, get_city_coords


model = pickle.load(open('model.pickle', 'rb'))
ALL_CONDITIONS_DB = ['depression', 'schizophrenia', 'ptsd', 'cancer', 'diabetes', 'dementia', 'anxiety', 'bipolar']

def process_raw_usermodel(user_data: dict) -> dict:
    return_dict = {}
    
    location = user_data['city']
    print(location)
    return_dict['location'] = get_city_coords(location)
    diagnosed_conditions = user_data['conditions']

    return_dict['sex'] = 0 if user_data['sex']  == 'F' else 1
    return_dict['age'] = int(user_data['age'])
    for condition in ALL_CONDITIONS_DB:
        return_dict[condition] = 1 if condition in diagnosed_conditions else 0
    return return_dict

def compare_user_match(user_1, user_2):
    try:
        user_1_data = process_raw_usermodel(user_1)
        user_2_data = process_raw_usermodel(user_2)
    except:
        return 0
    

    distance_kms = get_distance_between_cities(user_1_data['location'], user_2_data['location'])
    differnce_sex = abs(user_1_data['sex'] - user_2_data['sex'])
    difference_age = abs(user_1_data['age'] - user_2_data['age'])
    diff_cond_vals = [abs(user_1_data[condition] - user_2_data[condition]) for condition in ALL_CONDITIONS_DB]
    diff_conditions = 8 - sum(diff_cond_vals)

    pred = model.predict([[distance_kms, differnce_sex, difference_age, diff_conditions]])[0]
    return pred