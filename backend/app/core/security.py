from datetime import datetime, timedelta
from typing import Optional
from jose import JWTError, jwt
from passlib.context import CryptContext
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from .config import settings
from .database import get_db

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

PEPPER = "extra_secret"


def hash_password(password: str) -> str:
    if not isinstance(password, str):
        raise HTTPException(400, "Invalid password type")
    
    combined = password + PEPPER
    if len(combined.encode("utf-8")) > 72:
        combined = password[:60] + PEPPER
        
    return pwd_context.hash(combined)

def verify_password(plain: str, hashed: str) -> bool:
    combined = plain + PEPPER
    if len(combined.encode("utf-8")) > 72:
        combined = plain[:60] + PEPPER
    return pwd_context.verify(combined, hashed)


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    to_encode = data.copy()
    expire = datetime.utcnow() + (
        expires_delta or timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    )
    to_encode.update({
    "exp": expire,
    "sub": str(data.get("sub")),
    "type": "access"
})
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)


def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db),
):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Geçersiz kimlik bilgisi",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(
    token,
    settings.SECRET_KEY,
    algorithms=[settings.ALGORITHM],
    options={"verify_aud": False}
)
        
        if payload.get("type") != "access":
            raise credentials_exception
        
        user_id: str = payload.get("sub")
        if user_id is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    from ..models.user import User
    user = db.query(User).filter(User.id == int(user_id)).first()
    if user is None:
        raise credentials_exception
    return user
