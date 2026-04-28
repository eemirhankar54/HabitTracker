from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import firebase_admin
from firebase_admin import credentials , messaging
from .core.database import Base, engine
from .routers import auth, habits
import os
from apscheduler.schedulers.background import BackgroundScheduler
from datetime import datetime
from .models import User , Habit
from .core.database import SessionLocal

# Tabloları oluştur (geliştirme için; production'da alembic kullan)
Base.metadata.create_all(bind=engine)


base_path = os.path.dirname(os.path.realpath(__file__))
json_path = os.path.join(base_path, "fire_base_service.json")

if not firebase_admin._apps: # Birden fazla kez başlatılmasını engellemek için
    cred = credentials.Certificate(json_path)
    firebase_admin.initialize_app(cred)
    
    
app = FastAPI(
    title="Daily Programming API",
    description="Alışkanlık takip uygulaması backend",
    version="1.0.0",
)

# CORS — Flutter uygulaması için
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Production'da Flutter app URL'ini yaz
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(habits.router)


@app.get("/", tags=["Root"])
def root():
    return {"message": "Daily Programming API çalışıyor 🚀"}

def check_and_send_reminders():
    db = SessionLocal() # Veritabanı bağlantısı
    now = datetime.now()
    
    # Şu anki saate ve dakikaya uygun alışkanlıkları bul
    habits_to_remind = db.query(Habit).filter(
        Habit.reminder_hour == now.hour,
        Habit.reminder_minute == now.minute
    ).all()

    for habit in habits_to_remind:
        user = db.query(User).filter(User.id == habit.user_id).first()
        if user and user.fcm_token:
            # Firebase üzerinden bildirimi gönder
            message = messaging.Message(
                notification=messaging.Notification(
                    title="Zinciri Kırma! 🔥",
                    body=f"{habit.icon_emoji} {habit.title} vaktin geldi!",
                ),
                token=user.fcm_token,
            )
            messaging.send(message)
    db.close()

# Zamanlayıcıyı başlat (Her dakika çalışır)
scheduler = BackgroundScheduler()
scheduler.add_job(check_and_send_reminders, 'cron', minute='*')
scheduler.start()
