from pydantic import BaseModel, EmailStr
from datetime import datetime


from pydantic import BaseModel, EmailStr, field_validator

class UserRegister(BaseModel):
    email: EmailStr
    username: str
    password: str

    @field_validator("password")
    def password_rules(cls, v):
        if len(v) < 6:
            raise ValueError("Şifre çok kısa")
        if len(v) > 72:
            raise ValueError("Şifre çok uzun")
        return v


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserOut(BaseModel):
    id: int
    email: str
    username: str
    is_active: bool
    created_at: datetime

    model_config = {"from_attributes": True}


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserOut
