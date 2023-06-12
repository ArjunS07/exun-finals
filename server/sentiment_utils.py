from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer
sid_obj = SentimentIntensityAnalyzer()

TOO_NEG_THRESHOLD = -0.6

def get_str_sentiment(text: str) -> float:
    """Returns the sentiment of the text """

    sentiment_dict = sid_obj.polarity_scores(text)
    return sentiment_dict['compound']
    # TODO

def get_avg_list_sentiment(text_list: list) -> float:
    """Returns the average sentiment of all messages in a list using get_str_sentiment"""
    sum_sentiment = sum([get_str_sentiment(text) for text in text_list])
    avg = sum_sentiment/len(text_list)
    return avg