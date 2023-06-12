from flask import Flask, request

app = Flask(__name__)

from ml_utils import compare_user_match
from audio_utils import get_audio_transcription
from sentiment_utils import get_avg_list_sentiment, TOO_NEG_THRESHOLD
from username_utils import random_name
import datetime

import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
firebaseConfig = {
  'apiKey': "AIzaSyB5ETUsuicHicsSaRwgEazkLNa9I8-B6mM",
  "authDomain": "loqui-e58cb.firebaseapp.com",
  "projectId": "loqui-e58cb",
  "storageBucket": "loqui-e58cb.appspot.com",
  "messagingSenderId": "200583734127",
  "appId": "1:200583734127:web:fa6297e18314a2dee4be9a"
}

firebase_app = firebase_admin.initialize_app(firebaseConfig)
db = firestore.client()

rooms = db.collection(u"rooms")
users = db.collection(u"users")

import time
@app.route('/username-generator', methods=['GET'])
def unique_username_generator():
    name = random_name()
    return name

@app.route('/transcribe-audio', methods=['POST'])
def transcribe_audio():
    '''Downloads the audio file at the given url and returns the string transcribed by openAI whisper'''
    print('Transcribing audio')
    audio_url = request.form['audio_url']
    room_id = request.form['room_id']
    message_id = request.form['message_id']
    transcribed = get_audio_transcription(audio_url)

    room = rooms.document(room_id)
    messages_collection = list(room.collections())[0]
    message = messages_collection.document(message_id)
    message.update({u'contents': transcribed})
    message.update({u'isAudio': True})
    return transcribed


def get_user_active_chats(user_data, user_id) -> int:
    '''Returns the number of active chats the user is in'''
    user = users.document(user_id)
    user_data = user.get().to_dict()
    user_rooms = rooms.where(u'members', u'array_contains', user_id).get()
    return len(user_rooms)

@app.route('/match-user', methods=['POST'])
def match_user():
    '''Finds the closest match for a user and opens a chatroom with them.'''
    

    """
    1. Get the user's data from the database
    2. Find all users who have less than 3 active chats OR are premium users
    3. Rank them based on their match score
    4. Open a chatroom model in the DB
    """

    user_id = request.form['user_id']
    print('Got user ID', user_id)
    target_user = users.document(user_id)
    if not target_user:
        return 'User not found'
    target_user_data = target_user.get().to_dict()

    # Get all users who have less than 3 active chats OR are premium users
    available_users = []
    for other_user in users.stream():
        other_user_data = other_user.to_dict()

        if other_user_data['isPremium'] or get_user_active_chats(other_user_data, other_user.id) < 3:
            # Check if the target user already has a chat with the other user
            rooms_with_target_user = rooms.where(u'members', u'array_contains', user_id).get()

            already_has_room = False
            for room in rooms_with_target_user:
                if other_user.id in room.to_dict()['members']:
                    already_has_room = True
                    break
            if not already_has_room:
                available_users.append(other_user)                    

    user_scores = [compare_user_match(available_user.to_dict(), target_user_data) for available_user in available_users]
    sorted_matches = sorted(zip(user_scores, available_users), key=lambda x: x[0], reverse=True)
    sorted_match_ids = [match[1].id for match in sorted_matches]

    selected_users = []
    if len (user_scores) == 0:
        return 'No users available'
    elif len(user_scores) < 3:
        selected_users  = sorted_matches
    else: 
        selected_users = sorted_matches[:3]

    rooms.add({
        u'members': [target_user.id, selected_users[0][1].id],
        u'timeOpened': datetime.datetime.now(),
        u'lastMessage': 'Chat was opened'
    })

    return 'Success'

@app.route('/check-chatroom-sentiment', methods=['GET'])
def check_chatroom_sentiment():
    '''Checks the sentiment of the chatroom and sends notification about sentiment if it is too negative'''
    chatroom_id = request.args['chatroom_id']
    try:
        room = rooms.document(chatroom_id)
    except:
        return "Error"

    messages = list(room.collections())[0]
    message_lists = {}
    for message in messages.stream():

        data = message.to_dict()
        contents = data['contents']
        sender_id = data['sender']
        if sender_id not in message_lists.keys():
            message_lists[sender_id] = [contents]
        else:
            message_lists[sender_id].append(contents)

    flagged_users = []
    for sender_id in message_lists.keys():
        messages = message_lists[sender_id]
        average_sender_sentiment = get_avg_list_sentiment(messages)
        print(f'Got sentiment {average_sender_sentiment} for {sender_id}')
        # if average_sender_sentiment <= TOO_NEG_THRESHOLD and len(messages) >= 3:
        if average_sender_sentiment <= TOO_NEG_THRESHOLD:
            flagged_users.append(sender_id)
    
    room.update({"flaggedUsers": flagged_users})
    return flagged_users

if __name__ == '__main__':
    app.debug = True
    app.run(port=4996)