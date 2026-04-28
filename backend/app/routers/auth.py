from fastapi import APIRouter, Depends, HTTPException, status, Body
from sqlalchemy.orm import Session
from ..core.database import get_db
from ..core.security import hash_password, verify_password, create_access_token, get_current_user
from ..models.user import User
from ..schemas.user import UserRegister, UserLogin, Token, UserOut

router = APIRouter(prefix="/auth", tags=["Auth"])


@router.post("/register", response_model=Token, status_code=201)
def register(payload: UserRegister, db: Session = Depends(get_db)):

    print("PASSWORD RAW:", payload.password)
    print("TYPE:", type(payload.password))
    print("LEN:", len(payload.password.encode()))

    if db.query(User).filter(User.email == payload.email).first():
        raise HTTPException(status_code=400, detail="Bu email zaten kayıtlı")

    if db.query(User).filter(User.username == payload.username).first():
        raise HTTPException(status_code=400, detail="Bu kullanıcı adı alınmış")

    user = User(
        email=payload.email,
        username=payload.username,
        hashed_password=hash_password(payload.password),
    )
    
    db.add(user)
    db.commit()
    db.refresh(user)
    
    token = create_access_token({"sub": str(user.id)})

    return Token(
        access_token=token, 
        user=UserOut.model_validate(user)
    )


@router.post("/login", response_model=Token)
def login(payload: UserLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == payload.email).first()
    if not user or not verify_password(payload.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Email veya şifre hatalı",
        )
    token = create_access_token({"sub": str(user.id)})
    return Token(access_token=token, user=UserOut.model_validate(user))


@router.get("/me", response_model=UserOut)
def get_me(current_user: User = Depends(get_current_user)):
    return current_user


@router.delete("/delete-account", status_code=204)
def delete_account(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Kullanıcı hesabını ve tüm ilişkili verileri kalıcı olarak siler."""
    db.delete(current_user)
    db.commit()


@router.post("/update-fcm-token")
def update_fcm_token(
    payload: dict = Body(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    current_user.fcm_token = payload.get("token")
    db.commit()
    return {"message": "Token güncellendi"}