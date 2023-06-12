# TODO: Install and import whisper
# Look at https://github.com/openai/whisper
import requests
import os
import whisper

model = whisper.load_model("base")

def download_audio(url: str) -> str:
    '''Downloads the audio file at the given url and returns the path to the downloaded file'''
    response = requests.get(url)
    print(url)
    filename = url.split('/')[-1]
    download_path = f"audio_uploads/{filename}".replace("%20", "").replace("'", "")
    open(download_path, "wb").write(response.content)
    return download_path

model = whisper.load_model("small")
def get_audio_transcription(url: str, target_lang: str = 'en') -> str:
    path = download_audio(url)
    audio = whisper.load_audio(path)
    audio = whisper.pad_or_trim(audio)
    mel = whisper.log_mel_spectrogram(audio).to(model.device)
    _, probs = model.detect_language(mel)
    options = whisper.DecodingOptions(fp16=False, language=target_lang)
    result = whisper.decode(model, mel, options)

    # Clear the audio path
    os.remove(path)
    return (result.text)